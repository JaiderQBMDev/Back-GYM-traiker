import type { NextFunction, Request, Response } from "express";
import { isProd } from "../config/env.js";

export class AppError extends Error {
  statusCode: number;
  constructor(statusCode: number, message: string) {
    super(message);
    this.statusCode = statusCode;
  }
}

type AsyncHandler = (req: Request, res: Response, next: NextFunction) => Promise<unknown>;

/** Wraps an async route handler so thrown/rejected errors reach errorHandler. */
export function asyncHandler(fn: AsyncHandler) {
  return (req: Request, res: Response, next: NextFunction) => {
    fn(req, res, next).catch(next);
  };
}

const SAFE_DB_MESSAGES: Record<string, string> = {
  "23505": "A record with that value already exists",
  "23503": "Referenced record not found",
  "23514": "Value out of allowed range",
  "42501": "Insufficient permissions",
  PGRST116: "Record not found",
};

export function dbError(
  statusCode: number,
  supabaseError: { message: string; code?: string },
  fallback = "Request failed",
): AppError {
  const safeMessage = (supabaseError.code && SAFE_DB_MESSAGES[supabaseError.code]) || fallback;
  const err = new AppError(statusCode, safeMessage);
  (err as any).internalDetail = supabaseError.message;
  return err;
}

export function notFoundHandler(req: Request, res: Response) {
  res.status(404).json({ error: "Not found" });
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function errorHandler(err: unknown, req: Request, res: Response, _next: NextFunction) {
  if (err instanceof AppError) {
    if ((err as any).internalDetail) {
      req.log?.warn({ detail: (err as any).internalDetail }, "db error returned to client");
    }
    res.status(err.statusCode).json({ error: err.message });
    return;
  }

  // Log full detail server-side only — never leak internals (stack traces,
  // Postgres error text, etc.) to the client.
  req.log?.error({ err }, "unhandled error");
  console.error(err);
  res.status(500).json({ error: "Internal server error" });
}
