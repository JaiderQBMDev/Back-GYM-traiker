import type { NextFunction, Request, Response } from "express";
import type { ZodTypeAny } from "zod";
import { AppError } from "./errors.js";

type Part = "body" | "query" | "params";

/**
 * Parses and replaces req[part] with the validated/coerced data.
 * `.strict()` schemas (used throughout) reject unknown keys — this is what
 * stops a client from smuggling fields like user_id/owner_id/is_personal_record
 * into a request body to overwrite server-computed values.
 */
export function validate(schema: ZodTypeAny, part: Part = "body") {
  return (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse(req[part]);
    if (!result.success) {
      throw new AppError(400, `Invalid ${part}: ${JSON.stringify(result.error.flatten().fieldErrors)}`);
    }
    req[part] = result.data;
    next();
  };
}
