import type { NextFunction, Request, Response } from "express";
import { AppError, asyncHandler } from "./errors.js";

export const requireAdmin = asyncHandler(async (req: Request, _res: Response, next: NextFunction) => {
  const { data, error } = await req
    .supabase!.from("profiles")
    .select("is_admin")
    .eq("id", req.user!.id)
    .single();

  if (error || !data?.is_admin) {
    throw new AppError(403, "Admin access required");
  }

  next();
});
