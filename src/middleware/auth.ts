import type { NextFunction, Request, Response } from "express";
import { authClient, createUserScopedClient } from "../lib/supabase.js";
import { AppError, asyncHandler } from "./errors.js";

const BEARER_PREFIX = "Bearer ";

/**
 * Requires a valid Supabase-issued JWT on every request. The token is
 * verified against Supabase's Auth server (auth.getUser), which confirms
 * signature, expiry, and that the session hasn't been revoked. The request
 * then gets its own Supabase client bound to that token, so every
 * downstream query runs as that user under RLS — the route handlers never
 * see or need a privileged key.
 */
export const requireAuth = asyncHandler(async (req: Request, _res: Response, next: NextFunction) => {
  const header = req.headers.authorization;
  if (!header || !header.startsWith(BEARER_PREFIX)) {
    throw new AppError(401, "Missing bearer token");
  }

  const accessToken = header.slice(BEARER_PREFIX.length).trim();
  if (!accessToken) {
    throw new AppError(401, "Missing bearer token");
  }

  const { data, error } = await authClient.auth.getUser(accessToken);
  if (error || !data.user) {
    throw new AppError(401, "Invalid or expired session");
  }

  req.user = data.user;
  req.supabase = createUserScopedClient(accessToken);
  next();
});
