import { Router } from "express";
import { AppError, asyncHandler } from "../middleware/errors.js";
import { requireAdmin } from "../middleware/requireAdmin.js";
import { validate } from "../middleware/validate.js";
import { uuidParamSchema } from "../schemas/common.schema.js";
import { createExerciseSchema, listExercisesQuerySchema, updateExerciseSchema } from "../schemas/exercise.schema.js";

export const exercisesRouter = Router();

/** Escape LIKE/ILIKE wildcards so user input is matched literally. */
function escapeLike(value: string): string {
  return value.replace(/[%_\\]/g, (ch) => `\\${ch}`);
}

// GET — any authenticated user can list/search exercises
exercisesRouter.get(
  "/",
  validate(listExercisesQuerySchema, "query"),
  asyncHandler(async (req, res) => {
    const { muscle_group, search } = req.query as unknown as { muscle_group?: string; search?: string };
    let query = req.supabase!.from("exercises").select("*").order("name", { ascending: true });
    if (muscle_group) query = query.eq("muscle_group", muscle_group);
    if (search) query = query.ilike("name", `%${escapeLike(search)}%`);
    const { data, error } = await query;
    if (error) throw new AppError(400, error.message);
    res.json(data);
  }),
);

// POST — admin only
exercisesRouter.post(
  "/",
  requireAdmin,
  validate(createExerciseSchema),
  asyncHandler(async (req, res) => {
    const { data, error } = await req
      .supabase!.from("exercises")
      .insert({ ...req.body, owner_id: null })
      .select()
      .single();
    if (error) throw new AppError(400, error.message);
    res.status(201).json(data);
  }),
);

// PATCH — admin only
exercisesRouter.patch(
  "/:id",
  requireAdmin,
  validate(uuidParamSchema, "params"),
  validate(updateExerciseSchema),
  asyncHandler(async (req, res) => {
    const { data, error } = await req
      .supabase!.from("exercises")
      .update(req.body)
      .eq("id", req.params.id)
      .select()
      .single();
    if (error || !data) throw new AppError(404, "Exercise not found");
    res.json(data);
  }),
);

// DELETE — admin only
exercisesRouter.delete(
  "/:id",
  requireAdmin,
  validate(uuidParamSchema, "params"),
  asyncHandler(async (req, res) => {
    const { error, count } = await req
      .supabase!.from("exercises")
      .delete({ count: "exact" })
      .eq("id", req.params.id);
    if (error) throw new AppError(400, error.message);
    if (!count) throw new AppError(404, "Exercise not found");
    res.status(204).send();
  }),
);

// POST /:id/image — admin only, upload exercise image
exercisesRouter.post(
  "/:id/image",
  requireAdmin,
  validate(uuidParamSchema, "params"),
  asyncHandler(async (req, res) => {
    const { image_url } = req.body as { image_url: string };
    if (!image_url || typeof image_url !== "string") {
      throw new AppError(400, "image_url is required");
    }

    const { data, error } = await req
      .supabase!.from("exercises")
      .update({ image_url })
      .eq("id", req.params.id)
      .select()
      .single();
    if (error || !data) throw new AppError(404, "Exercise not found");
    res.json(data);
  }),
);
