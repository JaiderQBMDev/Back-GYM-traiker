import { z } from "zod";

export const upsertBodyMeasurementSchema = z
  .object({
    recorded_on: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/, "expected YYYY-MM-DD")
      .optional(),
    weight_kg: z.number().min(20).max(400).optional(),
    chest_cm: z.number().min(30).max(200).optional(),
    waist_cm: z.number().min(30).max(200).optional(),
    bicep_cm: z.number().min(10).max(100).optional(),
    thigh_cm: z.number().min(10).max(150).optional(),
    notes: z.string().trim().max(300).optional(),
  })
  .strict();

export const updateBodyMeasurementSchema = upsertBodyMeasurementSchema;

export const listBodyMeasurementsQuerySchema = z
  .object({
    from: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
    to: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  })
  .strict();
