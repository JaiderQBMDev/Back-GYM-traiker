import { Router } from "express";
import { z } from "zod";
import { AppError, asyncHandler } from "../middleware/errors.js";
import { validate } from "../middleware/validate.js";
import { progressQuerySchema } from "../schemas/session.schema.js";

export const statsRouter = Router();

function startOfIsoWeek(date: Date): Date {
  const d = new Date(date);
  const day = (d.getDay() + 6) % 7; // 0 = Monday
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() - day);
  return d;
}

// dashboard — screen 2b: streak, this-week bars, next suggested routine
statsRouter.get(
  "/dashboard",
  asyncHandler(async (req, res) => {
    const userId = req.user!.id;
    const weekStart = startOfIsoWeek(new Date());

    const [{ data: streak, error: streakError }, { data: weekSessions, error: weekError }, { data: nextRoutines }] =
      await Promise.all([
        req.supabase!.rpc("get_current_streak", { p_user_id: userId }),
        req
          .supabase!.from("workout_session_stats")
          .select("*")
          .eq("status", "completed")
          .gte("started_at", weekStart.toISOString()),
        req
          .supabase!.from("routine_summary")
          .select("*")
          .order("last_completed_at", { ascending: true, nullsFirst: true })
          .limit(1),
      ]);
    if (streakError) throw new AppError(400, streakError.message);
    if (weekError) throw new AppError(400, weekError.message);

    const days = ["L", "M", "X", "J", "V", "S", "D"];
    const perDay = days.map((label, idx) => {
      const dayDate = new Date(weekStart);
      dayDate.setDate(weekStart.getDate() + idx);
      const trained = (weekSessions ?? []).some((s) => {
        const started = new Date(s.started_at as string);
        return started.toDateString() === dayDate.toDateString();
      });
      return { label, trained };
    });

    res.json({
      streak: streak ?? 0,
      sessionsThisWeek: (weekSessions ?? []).length,
      totalVolumeThisWeekKg: (weekSessions ?? []).reduce((acc, s) => acc + Number(s.total_volume_kg ?? 0), 0),
      week: perDay,
      nextSuggestedRoutine: nextRoutines?.[0] ?? null,
    });
  }),
);

statsRouter.get(
  "/streak",
  asyncHandler(async (req, res) => {
    const { data, error } = await req.supabase!.rpc("get_current_streak", { p_user_id: req.user!.id });
    if (error) throw new AppError(400, error.message);
    res.json({ streak: data ?? 0 });
  }),
);

const exerciseIdParamSchema = z.object({ exerciseId: z.string().uuid() }).strict();

// per-exercise progress — screen 2g: PR card + chart of max weight per session
statsRouter.get(
  "/exercises/:exerciseId/progress",
  validate(exerciseIdParamSchema, "params"),
  validate(progressQuerySchema, "query"),
  asyncHandler(async (req, res) => {
    const exerciseId = req.params.exerciseId;
    const { period } = req.query as unknown as { period: "1m" | "3m" | "6m" | "1y" | "all" };

    const cutoff = new Date();
    const monthsBack = { "1m": 1, "3m": 3, "6m": 6, "1y": 12, all: null }[period];
    if (monthsBack !== null) cutoff.setMonth(cutoff.getMonth() - monthsBack);

    const [{ data: pr, error: prError }, { data: rawSets, error: setsError }] = await Promise.all([
      req.supabase!.from("personal_records").select("*").eq("exercise_id", exerciseId).maybeSingle(),
      req
        .supabase!.from("workout_sets")
        .select("weight_kg, reps, completed_at, session:workout_sessions(started_at, status)")
        .eq("exercise_id", exerciseId)
        .eq("is_completed", true)
        .order("completed_at", { ascending: true }),
    ]);
    if (prError) throw new AppError(400, prError.message);
    if (setsError) throw new AppError(400, setsError.message);

    // RLS on the embedded workout_sessions already limits this to the
    // caller's own sessions; filter here for status + period window.
    const sets = (rawSets ?? []).filter((row) => {
      const session = row.session as unknown as { started_at: string; status: string } | null;
      if (!session || session.status !== "completed") return false;
      if (monthsBack !== null && new Date(session.started_at) < cutoff) return false;
      return true;
    });

    res.json({ personalRecord: pr ?? null, sets });
  }),
);
