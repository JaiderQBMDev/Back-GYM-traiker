import { z } from "zod";

export const updateProfileSchema = z
  .object({
    full_name: z.string().trim().min(1).max(120).optional(),
    avatar_url: z.string().url().max(2048).optional(),
    height_cm: z.number().positive().max(300).optional(),
    weight_unit: z.enum(["kg", "lb"]).optional(),
  })
  .strict();
