import type { NextFunction, Request, Response } from "express";
import { AppError } from "./errors.js";

/**
 * Lightweight in-memory per-user rate limiter.
 *
 * Limits each authenticated user to `maxRequests` requests per `windowMs`.
 * Designed for small deployments — uses a simple Map with periodic cleanup
 * instead of Redis.
 */
export function userRateLimit({
  windowMs = 60_000,
  maxRequests = 100,
} = {}) {
  const hits = new Map<string, { count: number; resetAt: number }>();

  // Sweep expired entries every window to avoid unbounded memory growth.
  const cleanup = setInterval(() => {
    const now = Date.now();
    for (const [key, entry] of hits) {
      if (entry.resetAt <= now) hits.delete(key);
    }
  }, windowMs);
  // Allow the process to exit even if the timer is still active.
  cleanup.unref();

  return (req: Request, _res: Response, next: NextFunction) => {
    const userId = req.user?.id;
    // Should never happen — this middleware runs after requireAuth — but be
    // safe and let the request through rather than crashing.
    if (!userId) return next();

    const now = Date.now();
    let entry = hits.get(userId);

    if (!entry || entry.resetAt <= now) {
      entry = { count: 1, resetAt: now + windowMs };
      hits.set(userId, entry);
      return next();
    }

    entry.count += 1;

    if (entry.count > maxRequests) {
      const retryAfterSec = Math.ceil((entry.resetAt - now) / 1000);
      throw new AppError(429, `Rate limit exceeded. Try again in ${retryAfterSec}s.`);
    }

    next();
  };
}
