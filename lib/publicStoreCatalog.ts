/** Read-only view of the public store catalog for server-rendered information pages. */
export type PublicStorePlan = {
  id: string;
  name: string;
  price: number;
  salePrice: number | null;
  durationDays: number | null;
  description: string;
  features: string[];
  minecraftGroup: string;
  custom: boolean;
  hidden: boolean;
};

const STORE_ORIGIN = String(process.env.WEB_STORE_ORIGIN || 'https://vanakamsmps.duckdns.org').replace(/\/+$/, '');

export async function loadPublicStorePlans(): Promise<PublicStorePlan[]> {
  const response = await fetch(`${STORE_ORIGIN}/api/products`, {
    cache: 'no-store',
    signal: AbortSignal.timeout(10_000),
  });
  if (!response.ok) throw new Error('Store catalog unavailable');
  const rows: unknown = await response.json();
  if (!Array.isArray(rows)) throw new Error('Invalid store catalog');
  return rows as PublicStorePlan[];
}

export function publicEffectivePrice(plan: Pick<PublicStorePlan, 'price' | 'salePrice'>) {
  return plan.salePrice != null && plan.salePrice < plan.price ? plan.salePrice : plan.price;
}
