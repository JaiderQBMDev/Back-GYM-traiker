import { z } from "zod";

export const startSessionSchema = z.object({ routine_id: z.string().uuid() }).strict();

export const finishSessionSchema = z.object({ status: z.enum(["completed", "cancelled"]) }).strict();

// is_personal_record is intentionally NOT accepted from the client — the
// server computes it by comparing against the personal_records view.
export const logSetSchema = z
  .object({
    exercise_id: z.string().uuid(),
    routine_exercise_id: z.string().uuid().optional(),
    set_number: z.number().int().min(1).max(50),
    reps: z.number().int().min(0).max(200).optional(),
    weight_kg: z.number().min(0).max(500).optional(),
    is_completed: z.boolean().default(true),
  })
  .strict();

export const updateSetSchema = z
  .object({
    reps: z.number().int().min(0).max(200).optional(),
    weight_kg: z.number().min(0).max(500).optional(),
    is_completed: z.boolean().optional(),
  })
  .strict();

export const progressQuerySchema = z
  .object({
    period: z.enum(["1m", "3m", "6m", "1y", "all"]).default("3m"),
  })
  .strict();
