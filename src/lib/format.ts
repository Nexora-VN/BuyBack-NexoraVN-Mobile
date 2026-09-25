function groupThousands(digits: string): string {
  return digits.replace(/\B(?=(\d{3})+(?!\d))/g, ".");
}

export function formatVnd(value: number | string | bigint): string {
  if (typeof value === "string" && !/^-?\d+(\.\d+)?$/.test(value)) return "—";
  const amount =
    typeof value === "bigint"
      ? value
      : typeof value === "string" && /^-?\d+$/.test(value)
        ? BigInt(value)
        : BigInt(Math.trunc(Number(value) || 0));
  const negative = amount < 0n;
  const digits = (negative ? -amount : amount).toString();
  return `${negative ? "-" : ""}${groupThousands(digits)} ₫`;
}

export function formatDateTime(value: string | Date): string {
  if (!value || Number.isNaN(new Date(value).getTime())) return "—";
  return new Intl.DateTimeFormat("vi-VN", {
    dateStyle: "short",
    timeStyle: "short",
    timeZone: "Asia/Ho_Chi_Minh",
  }).format(new Date(value));
}

export function initials(value?: string | null): string {
  if (!value) return "BB";
  return value
    .split(/\s+/)
    .slice(-2)
    .map((part) => part[0]?.toUpperCase())
    .join("");
}
