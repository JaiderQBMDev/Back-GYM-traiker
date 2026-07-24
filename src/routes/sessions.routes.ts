import { Router } from "express";
import { AppError, asyncHandler } from "../middleware/errors.js";
import { validate } from "../middleware/validate.js";
import { paginationQuerySchema, uuidParamSchema } from "../schemas/common.schema.js";
import { finishSessionSchema, logSetSchema, startSessionSchema, updateSetSchema } from "../schemas/session.schema.js";

export const sessionsRouter = Router();

// history — screens 2b/2f/2g read from this view (duration, volume, sets, PR badge)
sessionsRouter.get(
  "/",
  validate(paginationQuerySchema, "query"),
  asyncHandler(async (req, res) => {
    const { limit, offset } = req.query as unknown as { limit: number; offset: number };
    const { data, error } = await req
      .supabase!.from("workout_session_stats")
      .select("*")
      .order("started_at", { ascending: false })
      .range(offset, offset + limit - 1);
    if (error) throw new AppError(400, error.message);
    res.json(data);
  }),
);

sessionsRouter.post(
  "/",
  validate(startSessionSchema),
  asyncHandler(async (req, res) => {
    const { routine_id } = req.body as { routine_id: string };

    // RLS already scopes this select to the caller's own routines, so a
    // routine_id belonging to another user resolves to "not found" here.
    const { data: routine, error: routineError } = await req
      .supabase!.from("routines")
      .select("id, name")
      .eq("id", routine_id)
      .single();
    if (routineError || !routine) throw new AppError(404, "Routine not found");

    const { data, error } = await req
      .supabase!.from("workout_sessions")
      .insert({
        user_id: req.user!.id,
        routine_id: routine.id,
        routine_name_snapshot: routine.name,
        status: "in_progress",
        started_at: new Date().toISOString(),
      })
      .select()
      .single();
    if (error) throw new AppError(400, error.message);
    res.status(201).json(data);
  }),
);

sessionsRouter.get(
  "/:id",
  validate(uuidParamSchema, "params"),
  asyncHandler(async (req, res) => {
    const [{ data: session, error: sessionError }, { data: sets, error: setsError }] = await Promise.all([
      req.supabase!.from("workout_session_stats").select("*").eq("session_id", req.params.id).single(),
      req
        .supabase!.from("workout_sets")
        .select("*, exercises(name, muscle_group)")
        .eq("session_id", req.params.id)
        .order("set_number", { ascending: true }),
    ]);
    if (sessionError || !session) throw new AppError(404, "Session not found");
    if (setsError) throw new AppError(400, setsError.message);
    res.json({ ...session, sets });
  }),
);

sessionsRouter.patch(
  "/:id",
  validate(uuidParamSchema, "params"),
  validate(finishSessionSchema),
  asyncHandler(async (req, res) => {
    const { status } = req.body as { status: "completed" | "cancelled" };
    // Only an in_progress session can be finished, and only once.
    const { data, error, count } = await req
      .supabase!.from("workout_sessions")
      .update({ status, ended_at: new Date().toISOString() }, { count: "exact" })
      .eq("id", req.params.id)
      .eq("user_id", req.user!.id)
      .eq("status", "in_progress")
      .select()
      .single();
    if (error || !count) throw new AppError(409, "Session not found or already finished");
    res.json(data);
  }),
);

sessionsRouter.post(
  "/:id/sets",
  validate(uuidParamSchema, "params"),
  validate(logSetSchema),
  asyncHandler(async (req, res) => {
    const sessionId = req.params.id;
    const body = req.body as {
      exercise_id: string;
      routine_exercise_id?: string;
      set_number: number;
      reps?: number;
      weight_kg?: number;
      is_completed: boolean;
    };

    const { data: session, error: sessionError } = await req
      .supabase!.from("workout_sessions")
      .select("id, status")
      .eq("id", sessionId)
      .eq("user_id", req.user!.id)
      .single();
    if (sessionError || !session) throw new AppError(404, "Session not found");
    if (session.status !== "in_progress") throw new AppError(409, "Session is not active");

    const isPersonalRecord = await computeIsPersonalRecord(
      req.supabase!,
      body.exercise_id,
      body.weight_kg,
      body.is_completed,
    );

    const { data, error } = await req
      .supabase!.from("workout_sets")
      .upsert(
        {
          session_id: sessionId,
          exercise_id: body.exercise_id,
          routine_exercise_id: body.routine_exercise_id ?? null,
          set_number: body.set_number,
          reps: body.reps ?? null,
          weight_kg: body.weight_kg ?? null,
          is_completed: body.is_completed,
          completed_at: body.is_completed ? new Date().toISOString() : null,
          is_personal_record: isPersonalRecord,
        },
        { onConflict: "session_id,exercise_id,set_number" },
      )
      .select()
      .single();
    if (error) throw new AppError(400, error.message);
    res.status(201).json(data);
  }),
);

sessionsRouter.patch(
  "/:id/sets/:setId",
  validate(uuidParamSchema.extend({ setId: uuidParamSchema.shape.id }), "params"),
  validate(updateSetSchema),
  asyncHandler(async (req, res) => {
    const body = req.body as { reps?: number; weight_kg?: number; is_completed?: boolean };

    const { data: session, error: sessionError } = await req
      .supabase!.from("workout_sessions")
      .select("id, status")
      .eq("id", req.params.id)
      .eq("user_id", req.user!.id)
      .single();
    if (sessionError || !session) throw new AppError(404, "Session not found");
    if (session.status !== "in_progress") throw new AppError(409, "Session is not active");

    const { data: existing, error: existingError } = await req
      .supabase!.from("workout_sets")
      .select("id, exercise_id")
      .eq("id", req.params.setId)
      .eq("session_id", req.params.id)
      .single();
    if (existingError || !existing) throw new AppError(404, "Set not found");

    const patch: Record<string, unknown> = { ...body };
    if (body.is_completed) patch.completed_at = new Date().toISOString();
    if (body.weight_kg !== undefined || body.is_completed !== undefined) {
      patch.is_personal_record = await computeIsPersonalRecord(
        req.supabase!,
        existing.exercise_id,
        body.weight_kg,
        body.is_completed ?? true,
      );
    }

    const { data, error } = await req
      .supabase!.from("workout_sets")
      .update(patch)
      .eq("id", req.params.setId)
      .select()
      .single();
    if (error) throw new AppError(400, error.message);
    res.json(data);
  }),
);

sessionsRouter.delete(
  "/:id/sets/:setId",
  validate(uuidParamSchema.extend({ setId: uuidParamSchema.shape.id }), "params"),
  asyncHandler(async (req, res) => {
    const { error, count } = await req
      .supabase!.from("workout_sets")
      .delete({ count: "exact" })
      .eq("id", req.params.setId)
      .eq("session_id", req.params.id);
    if (error) throw new AppError(400, error.message);
    if (!count) throw new AppError(404, "Set not found");
    res.status(204).send();
  }),
);

/**
 * Server-side PR check — the client never gets to declare a set a personal
 * record. Compares the incoming weight against the user's best completed
 * set for that exercise (via the personal_records view, which is itself
 * RLS-scoped to the caller).
 */
async function computeIsPersonalRecord(
  supabase: NonNullable<Express.Request["supabase"]>,
  exerciseId: string,
  weightKg: number | undefined,
  isCompleted: boolean,
): Promise<boolean> {
  if (!isCompleted || weightKg === undefined) return false;
  const { data } = await supabase
    .from("personal_records")
    .select("weight_kg")
    .eq("exercise_id", exerciseId)
    .maybeSingle();
  const bestSoFar = data?.weight_kg ?? 0;
  return weightKg > bestSoFar;
}
