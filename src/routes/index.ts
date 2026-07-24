import { Router } from "express";
import { requireAuth } from "../middleware/auth.js";
import { userRateLimit } from "../middleware/userRateLimit.js";
import { bodyMeasurementsRouter } from "./bodyMeasurements.routes.js";
import { exercisesRouter } from "./exercises.routes.js";
import { profileRouter } from "./profile.routes.js";
import { routinesRouter } from "./routines.routes.js";
import { sessionsRouter } from "./sessions.routes.js";
import { statsRouter } from "./stats.routes.js";

export const apiRouter = Router();

// Every route below requires a valid Supabase session — there is no
// unauthenticated read access to any app data.
apiRouter.use(requireAuth);

// Per-user rate limit applied after auth so each user gets their own bucket.
apiRouter.use(userRateLimit({ windowMs: 60_000, maxRequests: 100 }));

apiRouter.use("/profile", profileRouter);
apiRouter.use("/exercises", exercisesRouter);
apiRouter.use("/routines", routinesRouter);
apiRouter.use("/sessions", sessionsRouter);
apiRouter.use("/body-measurements", bodyMeasurementsRouter);
apiRouter.use("/stats", statsRouter);
