import { Router } from "express";
import { AppError, asyncHandler, dbError } from "../middleware/errors.js";
import { validate } from "../middleware/validate.js";
import { uuidParamSchema } from "../schemas/common.schema.js";
import {
  listBodyMeasurementsQuerySchema,
  updateBodyMeasurementSchema,
  upsertBodyMeasurementSchema,
} from "../schemas/bodyMeasurement.schema.js";
import { getUserTimezone, localDateString } from "../lib/timezone.js";

export const bodyMeasurementsRouter = Router();

bodyMeasurementsRouter.get(
  "/",
  validate(listBodyMeasurementsQuerySchema, "query"),
  asyncHandler(async (req, res) => {
    const { from, to } = req.query as unknown as { from?: string; to?: string };
    let query = req.supabase!.from("body_measurements").select("*").order("recorded_on", { ascending: false });
    if (from) query = query.gte("recorded_on", from);
    if (to) query = query.lte("recorded_on", to);
    const { data, error } = await query;
    if (error) throw dbError(400, error);
    res.json(data);
  }),
);

bodyMeasurementsRouter.post(
  "/",
  validate(upsertBodyMeasurementSchema),
  asyncHandler(async (req, res) => {
    const body = req.body as Record<string, unknown>;
    const recordedOn = body.recorded_on ?? localDateString(new Date(), await getUserTimezone(req));
    const { data, error } = await req
      .supabase!.from("body_measurements")
      .upsert(
        { ...body, user_id: req.user!.id, recorded_on: recordedOn },
        { onConflict: "user_id,recorded_on" },
      )
      .select()
      .single();
    if (error) throw dbError(400, error);
    res.status(201).json(data);
  }),
);

bodyMeasurementsRouter.patch(
  "/:id",
  validate(uuidParamSchema, "params"),
  validate(updateBodyMeasurementSchema),
  asyncHandler(async (req, res) => {
    const { data, error } = await req
      .supabase!.from("body_measurements")
      .update(req.body)
      .eq("id", req.params.id)
      .eq("user_id", req.user!.id)
      .select()
      .single();
    if (error || !data) throw new AppError(404, "Measurement not found");
    res.json(data);
  }),
);

bodyMeasurementsRouter.delete(
  "/:id",
  validate(uuidParamSchema, "params"),
  asyncHandler(async (req, res) => {
    const { error, count } = await req
      .supabase!.from("body_measurements")
      .delete({ count: "exact" })
      .eq("id", req.params.id)
      .eq("user_id", req.user!.id);
    if (error) throw dbError(400, error);
    if (!count) throw new AppError(404, "Measurement not found");
    res.status(204).send();
  }),
);
