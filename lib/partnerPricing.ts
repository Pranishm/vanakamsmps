export type PartnerDurationKind = 'CUSTOM' | 'MONTHLY';

export type PartnerPricingConfig = {
  // slotTotalsEur[slotIndex][dayIndex] => total price for that slot and day count (dayIndex=0 => 1 day)
  slotTotalsEur: number[][];

  // vipTotalsEur[dayIndex] => total price for VIP (slot=0) and day count
  vipTotalsEur: number[];
};

export const PARTNER_SLOTS = 10;
export const PARTNER_MAX_DAYS = 30;

// Paid placement is limited to VIP + slots #1–#5.
// Slots #6–#10 are free but require admin approval.
export const PARTNER_PAID_MAX_SLOT = 5;

// VIP is a special pinned slot that always appears above #1
export const PARTNER_VIP_SLOT = 0;

export function isVipSlot(slot: number): boolean {
  return Math.floor(Number(slot)) === PARTNER_VIP_SLOT;
}

export function isPaidPartnerSlot(slot: number): boolean {
  const s = Math.floor(Number(slot));
  return s === PARTNER_VIP_SLOT || (s >= 1 && s <= PARTNER_PAID_MAX_SLOT);
}

export function isFreePartnerSlot(slot: number): boolean {
  const s = Math.floor(Number(slot));
  return s > PARTNER_PAID_MAX_SLOT && s <= PARTNER_SLOTS;
}

const DEFAULT_DAILY_PRICES_INR = [
  500.0, // #1
  400.0, // #2
  300.0, // #3
  250.0, // #4
  200.0, // #5
  150.0, // #6
  120.0, // #7
  100.0, // #8
  80.0,  // #9
  60.0,  // #10
];

function getVipDailyPrice(): number {
  const raw = Number(process.env.PARTNER_VIP_DAILY_PRICE_INR);
  if (Number.isFinite(raw) && raw >= 0) return raw;
  // Default: notably more expensive than slot #1
  return DEFAULT_DAILY_PRICES_INR[0] * 2;
}

export function getDefaultPartnerPricingConfigFromEnv(): PartnerPricingConfig {
  const daily = getSlotDailyPrices();
  const slotTotalsEur = daily.map((d) =>
    Array.from({ length: PARTNER_MAX_DAYS }, (_, idx) => {
      const days = idx + 1;
      const total = Number(d) * days;
      return Math.round(total * 100) / 100;
    })
  );

  const vipDaily = getVipDailyPrice();
  const vipTotalsEur = Array.from({ length: PARTNER_MAX_DAYS }, (_, idx) => {
    const days = idx + 1;
    const total = Number(vipDaily) * days;
    return Math.round(total * 100) / 100;
  });

  // Ensure correct shape
  const normalized = slotTotalsEur.length === PARTNER_SLOTS ? slotTotalsEur : Array.from({ length: PARTNER_SLOTS }, () => Array(PARTNER_MAX_DAYS).fill(0));
  return { slotTotalsEur: normalized, vipTotalsEur };
}

export function getPartnerCurrency(): string {
  return String(process.env.PARTNER_CURRENCY || process.env.SHOP_CURRENCY || 'INR').toUpperCase();
}

export function getMonthlyDiscountPct(): number {
  const raw = Number(process.env.PARTNER_MONTHLY_DISCOUNT_PCT ?? 15);
  if (!Number.isFinite(raw)) return 15;
  return Math.min(80, Math.max(0, raw));
}

export function getSlotDailyPrices(): number[] {
  const raw = String(process.env.PARTNER_SLOT_DAILY_PRICES_JSON || '').trim();
  if (!raw) return DEFAULT_DAILY_PRICES_INR;
  try {
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return DEFAULT_DAILY_PRICES_INR;
    const nums = parsed.map((n) => Number(n)).filter((n) => Number.isFinite(n) && n >= 0);
    if (nums.length !== PARTNER_SLOTS) return DEFAULT_DAILY_PRICES_INR;
    return nums;
  } catch {
    return DEFAULT_DAILY_PRICES_INR;
  }
}

export function getDailyPrice(slot: number): number {
  const idx = Math.floor(slot) - 1;
  const prices = getSlotDailyPrices();
  if (idx < 0 || idx >= prices.length) return prices[prices.length - 1];
  return prices[idx];
}

export function getDailyPriceWithConfig(slot: number, config: PartnerPricingConfig): number {
  if (isVipSlot(slot)) {
    const day1 = Array.isArray(config?.vipTotalsEur) ? Number(config.vipTotalsEur[0]) : NaN;
    if (Number.isFinite(day1) && day1 >= 0) return Math.round(day1 * 100) / 100;
    return getVipDailyPrice();
  }
  const idx = Math.floor(slot) - 1;
  const row = Array.isArray(config?.slotTotalsEur) ? config.slotTotalsEur[idx] : null;
  const day1 = Array.isArray(row) ? Number(row[0]) : NaN;
  if (Number.isFinite(day1) && day1 >= 0) return Math.round(day1 * 100) / 100;
  return getDailyPrice(slot);
}

export function normalizeDays(kind: PartnerDurationKind, daysRaw?: number): number {
  if (kind === 'MONTHLY') return 30;
  const d = Math.floor(Number(daysRaw || 0));
  if (!Number.isFinite(d) || d <= 0) return 1;
  return Math.min(PARTNER_MAX_DAYS, Math.max(1, d));
}

export function computeTotalAmount(params: {
  slot: number;
  kind: PartnerDurationKind;
  days?: number;
}): { days: number; dailyPrice: number; discountPct: number; totalAmount: number; dailyPriceEur: number; totalEur: number } {
  return computeTotalAmountWithConfig({
    slot: params.slot,
    kind: params.kind,
    days: params.days,
    config: getDefaultPartnerPricingConfigFromEnv(),
  });
}

export const computeTotalEur = computeTotalAmount;

export function computeTotalAmountWithConfig(params: {
  slot: number;
  kind: PartnerDurationKind;
  days?: number;
  config: PartnerPricingConfig;
}): { days: number; dailyPrice: number; discountPct: number; totalAmount: number; dailyPriceEur: number; totalEur: number } {
  const days = normalizeDays(params.kind, params.days);

  if (isVipSlot(params.slot)) {
    const fromTable = Array.isArray(params.config?.vipTotalsEur) ? Number(params.config.vipTotalsEur[days - 1]) : NaN;
    const fallbackDaily = getDailyPriceWithConfig(PARTNER_VIP_SLOT, params.config);

    const total = Number.isFinite(fromTable) && fromTable >= 0
      ? Math.round(fromTable * 100) / 100
      : Math.round((fallbackDaily * days) * 100) / 100;

    const daily = days > 0 ? total / days : total;

    return {
      days,
      dailyPrice: Math.round(daily * 100) / 100,
      discountPct: 0,
      totalAmount: total,

      // Backward compatibility aliases
      dailyPriceEur: Math.round(daily * 100) / 100,
      totalEur: total,
    };
  }

  const slotIdx = Math.floor(params.slot) - 1;
  const row = Array.isArray(params.config?.slotTotalsEur) ? params.config.slotTotalsEur[slotIdx] : null;
  const fromTable = Array.isArray(row) ? Number(row[days - 1]) : NaN;
  const fallbackDaily = getDailyPriceWithConfig(params.slot, params.config);

  const total = Number.isFinite(fromTable) && fromTable >= 0
    ? Math.round(fromTable * 100) / 100
    : Math.round((fallbackDaily * days) * 100) / 100;

  const daily = days > 0 ? total / days : total;

  return {
    days,
    dailyPrice: Math.round(daily * 100) / 100,
    discountPct: 0,
    totalAmount: total,

    // Backward compatibility aliases
    dailyPriceEur: Math.round(daily * 100) / 100,
    totalEur: total,
  };
}

export const computeTotalEurWithConfig = computeTotalAmountWithConfig;
