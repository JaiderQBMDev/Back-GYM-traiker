import { Router } from "express";
import { z } from "zod";
import { AppError, asyncHandler, dbError } from "../middleware/errors.js";
import { validate } from "../middleware/validate.js";
import { progressQuerySchema } from "../schemas/session.schema.js";
import {
  getUserTimezone,
  localDateString,
  localWeekdayIndex,
  startOfLocalIsoWeek,
  startOfLocalMonth,
  startOfPreviousLocalMonth,
} from "../lib/timezone.js";

export const statsRouter = Router();

// dashboard — streak, this-week stats, next routine, last session, training days
statsRouter.get(
  "/dashboard",
  asyncHandler(async (req, res) => {
    const userId = req.user!.id;
    const timezone = await getUserTimezone(req);
    const now = new Date();
    const weekStart = startOfLocalIsoWeek(now, timezone);

    const [
      { data: streak, error: streakError },
      { data: weekSessions, error: weekError },
      { data: nextRoutines },
      { data: lastSessions, error: lastError },
    ] = await Promise.all([
      req.supabase!.rpc("get_current_streak", { p_user_id: userId, p_timezone: timezone }),
      req
        .supabase!.from("workout_session_stats")
        .select("*")
        .eq("status", "completed")
        .gte("started_at", weekStart.toISOString()),
      req
        .supabase!.from("routine_summary")
        .select("*")
        .order("last_completed_at", { ascending: true, nullsFirst: true }),
      req
        .supabase!.from("workout_session_stats")
        .select("*")
        .eq("status", "completed")
        .order("started_at", { ascending: false })
        .limit(1),
    ]);
    if (streakError) throw dbError(400, streakError);
    if (weekError) throw dbError(400, weekError);
    if (lastError) throw dbError(400, lastError);

    const trainingDays = Array.from({ length: 7 }, (_, idx) => {
      const dayDate = new Date(weekStart.getTime() + idx * 86_400_000);
      const dayLabel = localDateString(dayDate, timezone);
      return (weekSessions ?? []).some((s) => {
        const started = new Date(s.started_at as string);
        return localDateString(started, timezone) === dayLabel;
      });
    });

    const routines = nextRoutines ?? [];
    const todayDay = localWeekdayIndex(now, timezone);

    const hasAnyAssignedDay = routines.some((r: any) => r.assigned_day !== null);
    const todayRoutine = routines.find((r: any) => r.assigned_day === todayDay);

    let nr: any = null;
    let isRestDay = false;
    let upcoming: { name: string; day_label: string } | null = null;

    if (todayRoutine) {
      nr = todayRoutine;
    } else if (hasAnyAssignedDay) {
      isRestDay = true;
      const dayLabels = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      for (let offset = 1; offset <= 6; offset++) {
        const checkDay = (todayDay + offset) % 7;
        const found = routines.find((r: any) => r.assigned_day === checkDay);
        if (found) {
          upcoming = { name: (found as any).name, day_label: offset === 1 ? 'Mañana' : dayLabels[checkDay]! };
          break;
        }
      }
    } else {
      nr = routines[0] ?? null;
    }

    const ls = lastSessions?.[0];

    res.json({
      streak: streak ?? 0,
      this_week: {
        sessions: (weekSessions ?? []).length,
        total_volume_kg: (weekSessions ?? []).reduce(
          (acc: number, s: any) => acc + Number(s.total_volume_kg ?? 0),
          0,
        ),
      },
      training_days: trainingDays,
      is_rest_day: isRestDay,
      upcoming_routine: upcoming,
      next_routine: nr
        ? { id: nr.routine_id, name: nr.name, exercise_count: Number(nr.exercise_count) }
        : null,
      last_session: ls
        ? {
            id: ls.session_id,
            routine_name_snapshot: ls.routine_name_snapshot,
            started_at: ls.started_at,
            duration_minutes: Number(ls.duration_minutes ?? 0),
            total_sets: Number(ls.total_sets ?? 0),
            total_volume_kg: Number(ls.total_volume_kg ?? 0),
            has_pr: ls.has_pr ?? false,
          }
        : null,
    });
  }),
);

statsRouter.get(
  "/streak",
  asyncHandler(async (req, res) => {
    const timezone = await getUserTimezone(req);
    const { data, error } = await req
      .supabase!.rpc("get_current_streak", { p_user_id: req.user!.id, p_timezone: timezone });
    if (error) throw dbError(400, error);
    res.json({ streak: data ?? 0 });
  }),
);

// weekly volume — last 8 weeks of total volume per week
statsRouter.get(
  "/weekly-volume",
  asyncHandler(async (req, res) => {
    const timezone = await getUserTimezone(req);
    const weeks = 8;
    const now = new Date();
    const cutoff = new Date(now);
    cutoff.setDate(cutoff.getDate() - weeks * 7);

    const { data: sessions, error } = await req
      .supabase!.from("workout_session_stats")
      .select("started_at, total_volume_kg")
      .eq("status", "completed")
      .gte("started_at", cutoff.toISOString())
      .order("started_at", { ascending: true });
    if (error) throw dbError(400, error);

    const weeklyMap = new Map<string, number>();
    for (let i = 0; i < weeks; i++) {
      const d = new Date(now);
      d.setDate(d.getDate() - i * 7);
      const isoWeek = getIsoWeekLabel(d, timezone);
      weeklyMap.set(isoWeek, 0);
    }

    for (const s of sessions ?? []) {
      const label = getIsoWeekLabel(new Date(s.started_at as string), timezone);
      weeklyMap.set(label, (weeklyMap.get(label) ?? 0) + Number(s.total_volume_kg ?? 0));
    }

    const result = Array.from(weeklyMap.entries())
      .map(([week, volume_kg]) => ({ week, volume_kg: Math.round(volume_kg) }))
      .reverse();

    res.json(result);
  }),
);

// trained exercises — exercises the user has logged sets for, with stats
statsRouter.get(
  "/trained-exercises",
  asyncHandler(async (req, res) => {
    const { data: sets, error } = await req
      .supabase!.from("workout_sets")
      .select("exercise_id, weight_kg, reps, is_personal_record, completed_at, exercises(name, muscle_group)")
      .eq("is_completed", true)
      .order("completed_at", { ascending: false });
    if (error) throw dbError(400, error);

    const exerciseMap = new Map<string, {
      exercise_id: string;
      name: string;
      muscle_group: string;
      best_weight_kg: number;
      total_sets: number;
      last_performed: string;
    }>();

    for (const s of sets ?? []) {
      const ex = s.exercises as unknown as { name: string; muscle_group: string } | null;
      if (!ex) continue;
      const existing = exerciseMap.get(s.exercise_id);
      if (existing) {
        existing.total_sets++;
        if ((s.weight_kg ?? 0) > existing.best_weight_kg) {
          existing.best_weight_kg = s.weight_kg ?? 0;
        }
      } else {
        exerciseMap.set(s.exercise_id, {
          exercise_id: s.exercise_id,
          name: ex.name,
          muscle_group: ex.muscle_group,
          best_weight_kg: s.weight_kg ?? 0,
          total_sets: 1,
          last_performed: s.completed_at as string,
        });
      }
    }

    res.json(Array.from(exerciseMap.values()));
  }),
);

function getIsoWeekLabel(date: Date, timezone: string): string {
  return localDateString(startOfLocalIsoWeek(date, timezone), timezone);
}

const exerciseIdParamSchema = z.object({ exerciseId: z.string().uuid() }).strict();

// per-exercise progress
statsRouter.get(
  "/exercises/:exerciseId/progress",
  validate(exerciseIdParamSchema, "params"),
  validate(progressQuerySchema, "query"),
  asyncHandler(async (req, res) => {
    const exerciseId = req.params.exerciseId;
    const { period } = req.query as unknown as { period: "1m" | "3m" | "6m" | "1y" | "all" };
    const timezone = await getUserTimezone(req);

    const cutoff = new Date();
    const monthsBack = { "1m": 1, "3m": 3, "6m": 6, "1y": 12, all: null }[period];
    if (monthsBack !== null) cutoff.setMonth(cutoff.getMonth() - monthsBack);

    const [
      { data: pr, error: prError },
      { data: rawSets, error: setsError },
      { data: exerciseRow },
    ] = await Promise.all([
      req.supabase!.from("personal_records").select("*").eq("exercise_id", exerciseId).maybeSingle(),
      req
        .supabase!.from("workout_sets")
        .select("weight_kg, reps, is_personal_record, completed_at, session_id, workout_sessions(id, started_at, status)")
        .eq("exercise_id", exerciseId)
        .eq("is_completed", true)
        .order("completed_at", { ascending: true }),
      req.supabase!.from("exercises").select("name, muscle_group").eq("id", exerciseId).maybeSingle(),
    ]);
    if (prError) throw dbError(400, prError);
    if (setsError) throw dbError(400, setsError);

    const allSets = (rawSets ?? []).filter((row) => {
      const session = row.workout_sessions as unknown as { id: string; started_at: string; status: string } | null;
      return session !== null;
    });

    const periodSets = allSets.filter((row) => {
      if (monthsBack === null) return true;
      const session = row.workout_sessions as unknown as { started_at: string };
      return new Date(session.started_at) >= cutoff;
    });

    // Chart data: max weight per session date
    const chartMap = new Map<string, { date: string; weight_kg: number }>();
    for (const s of periodSets) {
      const session = s.workout_sessions as unknown as { started_at: string };
      const dateKey = localDateString(new Date(session.started_at), timezone);
      const existing = chartMap.get(dateKey);
      const w = s.weight_kg ?? 0;
      if (!existing || w > existing.weight_kg) {
        chartMap.set(dateKey, { date: dateKey, weight_kg: w });
      }
    }
    const chart_data = Array.from(chartMap.values()).sort((a, b) => a.date.localeCompare(b.date));

    // Monthly volume comparison
    const now = new Date();
    const thisMonthStart = startOfLocalMonth(now, timezone);
    const lastMonthStart = startOfPreviousLocalMonth(now, timezone);
    let volThisMonth = 0;
    let volLastMonth = 0;
    for (const s of allSets) {
      const session = s.workout_sessions as unknown as { started_at: string };
      const d = new Date(session.started_at);
      const vol = (s.weight_kg ?? 0) * (s.reps ?? 0);
      if (d >= thisMonthStart) volThisMonth += vol;
      else if (d >= lastMonthStart && d < thisMonthStart) volLastMonth += vol;
    }
    const volume_change_pct = volLastMonth > 0 ? Math.round(((volThisMonth - volLastMonth) / volLastMonth) * 100) : null;

    // Recent sessions with sets detail (last 5 session dates)
    const sessionMap = new Map<string, {
      session_id: string;
      date: string;
      sets: { reps: number; weight_kg: number; is_pr: boolean }[];
      has_pr: boolean;
      total_volume: number;
    }>();
    for (const s of allSets) {
      const session = s.workout_sessions as unknown as { id: string; started_at: string };
      const existing = sessionMap.get(session.id);
      const setData = {
        reps: s.reps ?? 0,
        weight_kg: s.weight_kg ?? 0,
        is_pr: s.is_personal_record ?? false,
      };
      if (existing) {
        existing.sets.push(setData);
        existing.total_volume += setData.reps * setData.weight_kg;
        if (setData.is_pr) existing.has_pr = true;
      } else {
        sessionMap.set(session.id, {
          session_id: session.id,
          date: localDateString(new Date(session.started_at), timezone),
          sets: [setData],
          has_pr: setData.is_pr,
          total_volume: setData.reps * setData.weight_kg,
        });
      }
    }
    const recent_sessions = Array.from(sessionMap.values())
      .sort((a, b) => b.date.localeCompare(a.date))
      .slice(0, 5);

    res.json({
      exercise_name: exerciseRow?.name ?? null,
      muscle_group: exerciseRow?.muscle_group ?? null,
      personal_record: pr ? { weight_kg: pr.weight_kg, date: pr.completed_at } : null,
      volume_this_month: Math.round(volThisMonth),
      volume_change_pct,
      chart_data,
      recent_sessions,
    });
  }),
);
