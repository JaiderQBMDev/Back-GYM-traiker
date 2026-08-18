import { z } from "zod";

export const updateProfileSchema = z
  .object({
    full_name: z.string().trim().min(1).max(120).optional(),
    avatar_url: z.string().url().max(2048).optional(),
    height_cm: z.number().positive().max(300).optional(),
    weight_unit: z.enum(["kg", "lb"]).optional(),
    sex: z.enum(["male", "female"]).optional(),
    birth_year: z.number().int().min(1920).max(2020).optional(),
    training_days_per_week: z.number().int().min(1).max(7).optional(),
    fitness_goal: z
      .enum([
        "lose_fat",
        "gain_muscle",
        "improve_fitness",
        "increase_strength",
        "stay_healthy",
        "other",
      ])
      .optional(),
    experience_level: z
      .enum(["beginner", "intermediate", "advanced"])
      .optional(),
    routine_preference: z
      .enum(["create_own", "receive_recommended"])
      .optional(),
    onboarding_completed: z.boolean().optional(),
    timezone: z
      .string()
      .trim()
      .min(1)
      .max(64)
      .refine(
        (tz) => {
          try {
            Intl.DateTimeFormat(undefined, { timeZone: tz });
            return true;
          } catch {
            return false;
          }
        },
        { message: "Invalid IANA timezone" },
      )
      .optional(),
  })
  .strict();
