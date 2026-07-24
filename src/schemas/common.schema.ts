import { z } from "zod";

export const uuidParamSchema = z.object({ id: z.string().uuid() }).strict();

export const paginationQuerySchema = z
  .object({
    limit: z.coerce.number().int().min(1).max(100).default(20),
    offset: z.coerce.number().int().min(0).default(0),
  })
  .strict();

export const MUSCLE_GROUPS = [
  "pecho",
  "espalda",
  "piernas",
  "hombros",
  "biceps",
  "triceps",
  "abdomen",
  "gluteos",
  "pantorrillas",
  "cardio",
  "otro",
] as const;
