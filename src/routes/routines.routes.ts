import { Router } from "express";
import { AppError, asyncHandler } from "../middleware/errors.js";
import { validate } from "../middleware/validate.js";
import { uuidParamSchema } from "../schemas/common.schema.js";
import {
  addRoutineExerciseSchema,
  createRoutineSchema,
  reorderRoutineExercisesSchema,
  updateRoutineExerciseSchema,
  updateRoutineSchema,
} from "../schemas/routine.schema.js";

export const routinesRouter = Router();

// list — screen 2c "Mis Rutinas" (exercise count + last completed date)
routinesRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    const { data, error } = await req
      .supabase!.from("routine_summary")
      .select("*")
      .order("is_favorite", { ascending: false })
      .order("position", { ascending: true });
    if (error) throw new AppError(400, error.message);
    res.json(data);
  }),
);

routinesRouter.post(
  "/",
  validate(createRoutineSchema),
  asyncHandler(async (req, res) => {
    const { data, error } = await req
      .supabase!.from("routines")
      .insert({ ...req.body, user_id: req.user!.id })
      .select()
      .single();
    if (error) throw new AppError(400, error.message);
    res.status(201).json(data);
  }),
);

// detail — screen 2d, routine + ordered exercises with exercise info
routinesRouter.get(
  "/:id",
  validate(uuidParamSchema, "params"),
  asyncHandler(async (req, res) => {
    const { data, error } = await req
      .supabase!.from("routines")
      .select("*, routine_exercises(*, exercises(*))")
      .eq("id", req.params.id)
      .order("order_index", { referencedTable: "routine_exercises", ascending: true })
      .single();
    if (error || !data) throw new AppError(404, "Routine not found");
    res.json(data);
  }),
);

routinesRouter.patch(
  "/:id",
  validate(uuidParamSchema, "params"),
  validate(updateRoutineSchema),
  asyncHandler(async (req, res) => {
    const { data, error } = await req
      .supabase!.from("routines")
      .update(req.body)
      .eq("id", req.params.id)
      .eq("user_id", req.user!.id)
      .select()
      .single();
    if (error || !data) throw new AppError(404, "Routine not found");
    res.json(data);
  }),
);

routinesRouter.delete(
  "/:id",
  validate(uuidParamSchema, "params"),
  asyncHandler(async (req, res) => {
    const { error, count } = await req
      .supabase!.from("routines")
      .delete({ count: "exact" })
      .eq("id", req.params.id)
      .eq("user_id", req.user!.id);
    if (error) throw new AppError(400, error.message);
    if (!count) throw new AppError(404, "Routine not found");
    res.status(204).send();
  }),
);

routinesRouter.post(
  "/:id/exercises",
  validate(uuidParamSchema, "params"),
  validate(addRoutineExerciseSchema),
  asyncHandler(async (req, res) => {
    // RLS on routine_exercises checks the parent routine's ownership, so an
    // insert against a routine the caller doesn't own is rejected there too.
    const { data, error } = await req
      .supabase!.from("routine_exercises")
      .insert({ ...req.body, routine_id: req.params.id })
      .select("*, exercises(*)")
      .single();
    if (error) throw new AppError(400, error.message);
    res.status(201).json(data);
  }),
);

routinesRouter.patch(
  "/:id/exercises/:reId",
  validate(uuidParamSchema.extend({ reId: uuidParamSchema.shape.id }), "params"),
  validate(updateRoutineExerciseSchema),
  asyncHandler(async (req, res) => {
    const { data, error } = await req
      .supabase!.from("routine_exercises")
      .update(req.body)
      .eq("id", req.params.reId)
      .eq("routine_id", req.params.id)
      .select("*, exercises(*)")
      .single();
    if (error || !data) throw new AppError(404, "Routine exercise not found");
    res.json(data);
  }),
);

routinesRouter.delete(
  "/:id/exercises/:reId",
  validate(uuidParamSchema.extend({ reId: uuidParamSchema.shape.id }), "params"),
  asyncHandler(async (req, res) => {
    const { error, count } = await req
      .supabase!.from("routine_exercises")
      .delete({ count: "exact" })
      .eq("id", req.params.reId)
      .eq("routine_id", req.params.id);
    if (error) throw new AppError(400, error.message);
    if (!count) throw new AppError(404, "Routine exercise not found");
    res.status(204).send();
  }),
);

routinesRouter.patch(
  "/:id/exercises/reorder",
  validate(uuidParamSchema, "params"),
  validate(reorderRoutineExercisesSchema),
  asyncHandler(async (req, res) => {
    const { order } = req.body as { order: { id: string; order_index: number }[] };
    // Each update is scoped to this routine_id, so an id belonging to a
    // different routine (even one the caller owns) is silently a no-op.
    const results = await Promise.all(
      order.map(({ id, order_index }) =>
        req
          .supabase!.from("routine_exercises")
          .update({ order_index })
          .eq("id", id)
          .eq("routine_id", req.params.id),
      ),
    );
    const failed = results.find((r) => r.error);
    if (failed?.error) throw new AppError(400, failed.error.message);
    res.status(204).send();
  }),
);
