import { z } from "zod";

export const createRoutineSchema = z
  .object({
    name: z.string().trim().min(1).max(80),
    is_favorite: z.boolean().optional(),
    assigned_day: z.number().int().min(0).max(6).nullable().optional(),
  })
  .strict();

export const createRoutineWithExercisesSchema = z
  .object({
    name: z.string().trim().min(1).max(80),
    is_favorite: z.boolean().optional().default(false),
    assigned_day: z.number().int().min(0).max(6).nullable().optional(),
    exercises: z
      .array(
        z
          .object({
            exercise_id: z.string().uuid(),
            order_index: z.number().int().min(0),
            target_sets: z.number().int().min(1).max(20).default(3),
            target_reps_min: z.number().int().min(1).max(100).default(8),
            target_reps_max: z.number().int().min(1).max(100).default(12),
            rest_seconds: z.number().int().min(0).max(1800).default(90),
          })
          .strict()
          .refine((d) => d.target_reps_max >= d.target_reps_min, {
            message: "target_reps_max must be >= target_reps_min",
            path: ["target_reps_max"],
          }),
      )
      .min(1)
      .max(50),
  })
  .strict();

export const updateRoutineSchema = z
  .object({
    name: z.string().trim().min(1).max(80).optional(),
    is_favorite: z.boolean().optional(),
    position: z.number().int().min(0).optional(),
    assigned_day: z.number().int().min(0).max(6).nullable().optional(),
  })
  .strict();

export const addRoutineExerciseSchema = z
  .object({
    exercise_id: z.string().uuid(),
    order_index: z.number().int().min(0),
    target_sets: z.number().int().min(1).max(20).default(3),
    target_reps_min: z.number().int().min(1).max(100).default(8),
    target_reps_max: z.number().int().min(1).max(100).default(12),
    rest_seconds: z.number().int().min(0).max(1800).default(90),
    notes: z.string().trim().max(300).optional(),
  })
  .strict()
  .refine((d) => d.target_reps_max >= d.target_reps_min, {
    message: "target_reps_max must be >= target_reps_min",
    path: ["target_reps_max"],
  });

export const updateRoutineExerciseSchema = z
  .object({
    order_index: z.number().int().min(0).optional(),
    target_sets: z.number().int().min(1).max(20).optional(),
    target_reps_min: z.number().int().min(1).max(100).optional(),
    target_reps_max: z.number().int().min(1).max(100).optional(),
    rest_seconds: z.number().int().min(0).max(1800).optional(),
    notes: z.string().trim().max(300).optional(),
  })
  .strict();

export const reorderRoutineExercisesSchema = z
  .object({
    order: z
      .array(z.object({ id: z.string().uuid(), order_index: z.number().int().min(0) }).strict())
      .min(1)
      .max(50),
  })
  .strict();
