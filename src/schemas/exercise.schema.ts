import { z } from "zod";
import { MUSCLE_GROUPS } from "./common.schema.js";

export const createExerciseSchema = z
  .object({
    name: z.string().trim().min(2).max(80),
    muscle_group: z.enum(MUSCLE_GROUPS),
    equipment: z.string().trim().max(80).optional(),
    notes: z.string().trim().max(500).optional(),
    image_url: z.string().url().max(500).optional(),
  })
  .strict();

export const updateExerciseSchema = createExerciseSchema.partial().strict();

export const uploadExerciseImageSchema = z
  .object({
    image_url: z.string().url().max(2048),
  })
  .strict();

export const listExercisesQuerySchema = z
  .object({
    muscle_group: z.enum(MUSCLE_GROUPS).optional(),
    search: z.string().trim().max(80).optional(),
  })
  .strict();
