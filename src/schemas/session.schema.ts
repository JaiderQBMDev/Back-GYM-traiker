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

export const logPastSessionSchema = z
  .object({
    routine_name: z.string().min(1).max(200),
    date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    duration_minutes: z.number().int().min(1).max(600).optional(),
    exercises: z
      .array(
        z.object({
          exercise_id: z.string().uuid(),
          sets: z
            .array(
              z.object({
                reps: z.number().int().min(0).max(200),
                weight_kg: z.number().min(0).max(500),
              }),
            )
            .min(1)
            .max(50),
        }),
      )
      .min(1)
      .max(30),
  })
  .strict();

export const progressQuerySchema = z
  .object({
    period: z.enum(["1m", "3m", "6m", "1y", "all"]).default("3m"),
  })
  .strict();
