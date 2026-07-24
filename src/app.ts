import cors from "cors";
import express from "express";
import rateLimit from "express-rate-limit";
import helmet from "helmet";
import { pinoHttp } from "pino-http";
import { allowedOrigins, env, isProd } from "./config/env.js";
import { errorHandler, notFoundHandler } from "./middleware/errors.js";
import { apiRouter } from "./routes/index.js";

export function createApp() {
  const app = express();

  // Don't leak the framework/version in responses.
  app.disable("x-powered-by");
  // Trust the first reverse proxy hop in production (typical single-proxy
  // deploy); override with TRUST_PROXY env var for custom topologies.
  // In development we default to `false` so req.ip isn't spoofable locally.
  const trustProxy = env.TRUST_PROXY !== undefined
    ? (Number.isFinite(Number(env.TRUST_PROXY)) ? Number(env.TRUST_PROXY) : env.TRUST_PROXY)
    : (isProd ? 1 : false);
  app.set("trust proxy", trustProxy);

  app.use(helmet());
  app.use(
    cors({
      origin(origin, callback) {
        // Allow same-origin/non-browser requests (no Origin header) and
        // anything explicitly whitelisted via FRONTEND_ORIGIN.
        if (!origin || allowedOrigins.includes(origin)) {
          callback(null, true);
          return;
        }
        callback(new Error("Not allowed by CORS"));
      },
      credentials: false, // auth is via Bearer token, not cookies — no CSRF surface to cover
    }),
  );
  app.use(express.json({ limit: "100kb" }));
  app.use(
    pinoHttp({
      redact: ["req.headers.authorization"],
      autoLogging: { ignore: (req) => req.url === "/health" },
    }),
  );

  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 300,
    standardHeaders: true,
    legacyHeaders: false,
  });
  app.use(limiter);

  app.get("/health", (_req, res) => res.json({ status: "ok" }));
  app.use("/api", apiRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
