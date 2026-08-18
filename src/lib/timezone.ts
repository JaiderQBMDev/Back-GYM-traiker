import type { Request } from "express";

const DEFAULT_TIMEZONE = "UTC";

/** Fetches the calling user's stored IANA timezone, defaulting to UTC if unset or unreadable. */
export async function getUserTimezone(req: Request): Promise<string> {
  const { data } = await req
    .supabase!.from("profiles")
    .select("timezone")
    .eq("id", req.user!.id)
    .maybeSingle();
  return data?.timezone ?? DEFAULT_TIMEZONE;
}

/** Formats a Date as YYYY-MM-DD using the given IANA timezone's wall-clock date. */
export function localDateString(date: Date, timeZone: string): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
}

const WEEKDAY_INDEX: Record<string, number> = {
  Mon: 0,
  Tue: 1,
  Wed: 2,
  Thu: 3,
  Fri: 4,
  Sat: 5,
  Sun: 6,
};

/** Day of week in the given timezone, Monday = 0 .. Sunday = 6. */
export function localWeekdayIndex(date: Date, timeZone: string): number {
  const weekday = new Intl.DateTimeFormat("en-US", { timeZone, weekday: "short" }).format(date);
  return WEEKDAY_INDEX[weekday]!;
}

function getOffsetMinutes(utcInstant: Date, timeZone: string): number {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone,
    hour12: false,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  }).formatToParts(utcInstant);
  const get = (type: string) => Number(parts.find((p) => p.type === type)!.value);
  const asIfUtc = Date.UTC(get("year"), get("month") - 1, get("day"), get("hour") % 24, get("minute"), get("second"));
  return (asIfUtc - utcInstant.getTime()) / 60_000;
}

/** Resolves the UTC instant for local midnight of `date`'s calendar day in `timeZone`. */
export function startOfLocalDay(date: Date, timeZone: string): Date {
  const dateStr = localDateString(date, timeZone);
  const naiveUtc = new Date(`${dateStr}T00:00:00.000Z`);
  const offsetMinutes = getOffsetMinutes(naiveUtc, timeZone);
  return new Date(naiveUtc.getTime() - offsetMinutes * 60_000);
}

/** Resolves the UTC instant for local midnight of the Monday starting `date`'s local ISO week. */
export function startOfLocalIsoWeek(date: Date, timeZone: string): Date {
  const dayIdx = localWeekdayIndex(date, timeZone);
  const localMidnight = startOfLocalDay(date, timeZone);
  return new Date(localMidnight.getTime() - dayIdx * 86_400_000);
}

/** Resolves the UTC instant for local midnight of the 1st of the given local year/month (1-12). */
export function startOfLocalMonthFromParts(year: number, month: number, timeZone: string): Date {
  const naiveUtc = new Date(Date.UTC(year, month - 1, 1, 0, 0, 0));
  const offsetMinutes = getOffsetMinutes(naiveUtc, timeZone);
  return new Date(naiveUtc.getTime() - offsetMinutes * 60_000);
}

/** Resolves the UTC instant for local midnight of the 1st of `date`'s local month. */
export function startOfLocalMonth(date: Date, timeZone: string): Date {
  const [year, month] = localDateString(date, timeZone).split("-").map(Number);
  return startOfLocalMonthFromParts(year!, month!, timeZone);
}

/** Resolves the UTC instant for local midnight of the 1st of the month before `date`'s local month. */
export function startOfPreviousLocalMonth(date: Date, timeZone: string): Date {
  const [year, month] = localDateString(date, timeZone).split("-").map(Number);
  return month === 1
    ? startOfLocalMonthFromParts(year! - 1, 12, timeZone)
    : startOfLocalMonthFromParts(year!, month! - 1, timeZone);
}
