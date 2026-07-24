import { Router } from "express";
import { AppError, asyncHandler } from "../middleware/errors.js";
import { validate } from "../middleware/validate.js";
import { updateProfileSchema } from "../schemas/profile.schema.js";

export const profileRouter = Router();

profileRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    const { data, error } = await req.supabase!.from("profiles").select("*").eq("id", req.user!.id).single();

    if (error && error.code === "PGRST116") {
      const meta = req.user!.user_metadata ?? {};
      const { data: created, error: insertErr } = await req
        .supabase!.from("profiles")
        .insert({
          id: req.user!.id,
          full_name: meta.full_name ?? null,
          avatar_url: meta.avatar_url ?? null,
        })
        .select()
        .single();
      if (insertErr) throw new AppError(400, insertErr.message);
      return res.status(201).json(created);
    }

    if (error) throw new AppError(404, "Profile not found");
    res.json(data);
  }),
);

profileRouter.patch(
  "/",
  validate(updateProfileSchema),
  asyncHandler(async (req, res) => {
    const { data, error } = await req
      .supabase!.from("profiles")
      .update(req.body)
      .eq("id", req.user!.id)
      .select()
      .single();
    if (error) throw new AppError(400, error.message);
    res.json(data);
  }),
);
