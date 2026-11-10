import Link from 'next/link';
import { loadPublicStorePlans, publicEffectivePrice, type PublicStorePlan } from '@/lib/publicStoreCatalog';

// Membership prices and feature lists should follow the same live catalog used by
// the shop and the already-installed mobile app.
export const dynamic = 'force-dynamic';

export const metadata = {
  title: 'VKP Memberships & Collections | VANAKAMSMPs',
  description: 'Compare VKP, VKP+ and VKP++ memberships, plus the planned one-time collections for VANAKAMSMPs.',
};

const membershipFallbacks = [
  {
    name: 'VKP', label: 'Basic premium', accent: '#5eead4',
    group: 'vkp',
    prices: [{ term: '30 days', price: 50 }, { term: '14 days', price: 30 }],
    benefits: ['3 extra homes', 'Custom [VKP] chat prefix', '/craft and /enderchest', '+2 auction listings', '1 daily VKP reward', 'Exclusive VKP kit', 'Premium join message', 'Exclusive chat colours'],
  },
  {
    name: 'VKP+', label: 'Advanced premium', accent: '#d8a4ff', featured: true,
    group: 'vkpplus',
    prices: [{ term: '30 days', price: 80 }, { term: '14 days', price: 50 }],
    benefits: ['6 extra homes', 'All VKP benefits', '/anvil, /stonecutter and /loom', '+5 auction listings', '2 daily VKP+ rewards', 'Exclusive VKP+ kit', 'Custom nickname', 'Join and leave messages with particles', 'Priority support'],
  },
  {
    name: 'VKP++', label: 'Ultimate premium', accent: '#ffc857',
    group: 'vkpplusplus',
    prices: [{ term: '30 days', price: 100 }, { term: '14 days', price: 70 }],
    benefits: ['10 extra homes', 'All VKP and VKP+ benefits', '/grindstone and /smithingtable', '+10 auction listings', '3 daily VKP++ rewards', 'Exclusive VKP++ kit', 'Advanced nickname options', 'Trails, particles and cosmetics', 'Priority support and login effects', 'Premium area access', 'Monthly reward'],
  },
];

type MembershipPrice = { term: string; price: number; listPrice?: number };
type Membership = (typeof membershipFallbacks)[number] & {
  prices: MembershipPrice[];
  benefits: string[];
};

async function getMembershipCatalog(): Promise<{ memberships: Membership[]; live: boolean }> {
  let products: PublicStorePlan[] = [];
  let live = false;
  try {
    products = (await loadPublicStorePlans()).filter((product) => !product.hidden);
    live = products.length > 0;
  } catch {
    // Keep the comparison page useful during a store outage, but label the
    // displayed amounts as last-known prices instead of implying a live read.
  }

  const memberships = membershipFallbacks.map((fallback) => {
    const matching = products.filter((product) => product.minecraftGroup.toLowerCase() === fallback.group);
    const currentPlan = matching.find((product) => product.durationDays === 30);
    const termPrices = [30, 14].map((days) => {
      const product = matching.find((row) => row.durationDays === days);
      const defaultPrice = fallback.prices.find((row) => row.term === `${days} days`)?.price ?? 0;
      return {
        term: `${days} days`,
        price: product ? publicEffectivePrice(product) : defaultPrice,
        ...(product?.salePrice != null && product.salePrice < product.price ? { listPrice: product.price } : {}),
      };
    });

    return {
      ...fallback,
      prices: termPrices,
      benefits: currentPlan?.features?.length ? currentPlan.features : fallback.benefits,
    };
  });

  return { memberships, live };
}

const collections = [
  { name: 'Adventurer Pack', subtitle: 'Starter', price: 49, accent: '#54d8e8', icon: '✦', benefits: ['2 CrazyCrates keys', 'Adventurer cosmetics', 'Starter decor items', 'Profile badge', 'Welcome reward'] },
  { name: "Builder’s Edition", subtitle: 'Creator', price: 99, accent: '#69e58a', icon: '▦', benefits: ['Builder cosmetics', 'Decorative block bundle', 'Builder profile badge', 'Building-themed crate keys', 'Extra claim allowance, if configured'] },
  { name: 'Champion Edition', subtitle: 'Competitive', price: 149, accent: '#ff7373', icon: '⚔', benefits: ['Champion cosmetics', 'Victory particles', 'Champion profile badge', 'PvP-themed crate keys', 'Kill and victory effects', 'Tournament registration priority'] },
  { name: 'Legendary Collection', subtitle: 'Premium bundle', price: 249, accent: '#c792ff', icon: '◇', benefits: ['Legendary cosmetics', 'Pet cosmetics', 'Animated particles', 'Legendary crate keys', 'Profile badge', 'Lobby showcase effect'] },
  { name: 'Ultimate Collection', subtitle: 'Top bundle', price: 399, accent: '#ffc857', icon: '♛', benefits: ['All Legendary cosmetics', 'Extra pet cosmetics', 'Ultimate animated trails', 'Profile showcase and badge', 'Bonus mystery crate keys', 'Monthly cosmetic reward for 30 days'] },
];

export default async function Memberships() {
  const { memberships, live: liveCatalog } = await getMembershipCatalog();

  return (
    <main className="min-h-screen overflow-hidden bg-[#08090d] px-4 py-10 text-white sm:px-6 sm:py-16">
      <div className="pointer-events-none fixed inset-0 -z-0 bg-[radial-gradient(ellipse_at_50%_0%,rgba(83,35,61,0.32),transparent_58%)]" />
      <div className="relative z-10 mx-auto max-w-7xl">
        <Link href="/shop" className="inline-flex items-center gap-2 text-sm font-semibold text-rose-200/80 transition hover:text-white">← Back to the shop</Link>

        <header className="mx-auto mb-12 mt-10 max-w-3xl text-center sm:mb-16 sm:mt-14">
          <p className="text-xs font-bold uppercase tracking-[.3em] text-rose-300">VANAKAMSMPs · Season 2</p>
          <h1 className="mt-4 text-4xl font-black tracking-tight sm:text-6xl">Choose your place in the server.</h1>
          <p className="mx-auto mt-5 max-w-2xl text-base leading-7 text-white/60">Compare the VKP memberships and the one-time collection ideas. Rank prices are listed for both 30-day and 14-day terms.</p>
        </header>

        <section aria-labelledby="membership-heading">
          <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
            <div><p className="text-xs font-bold uppercase tracking-[.25em] text-rose-300">Timed memberships</p><h2 id="membership-heading" className="mt-2 text-2xl font-extrabold sm:text-3xl">VKP rank benefits</h2></div>
            <span className="rounded-full border border-white/10 bg-white/[.04] px-3 py-1.5 text-xs text-white/55">{liveCatalog ? 'Live store prices · ' : 'Last-known prices · '}14-day and 30-day plans</span>
          </div>
          <div className="grid items-stretch gap-5 lg:grid-cols-3">
            {memberships.map((plan) => (
              <article key={plan.name} className={`relative flex flex-col overflow-hidden rounded-3xl border bg-[#101117] p-6 shadow-[0_24px_70px_-45px_rgba(0,0,0,.95)] ${plan.featured ? 'border-fuchsia-300/50 lg:-translate-y-2' : 'border-white/10'}`}>
                <div aria-hidden className="absolute inset-x-0 top-0 h-36 opacity-20" style={{ background: `radial-gradient(ellipse at top, ${plan.accent}, transparent 70%)` }} />
                <div className="relative flex items-start justify-between gap-3">
                  <div><p className="text-xs font-bold uppercase tracking-[.2em] text-white/45">{plan.label}</p><h3 className="mt-2 text-3xl font-black" style={{ color: plan.accent }}>{plan.name}</h3></div>
                  {plan.featured && <span className="rounded-full border border-fuchsia-200/30 bg-fuchsia-300/10 px-3 py-1 text-[10px] font-extrabold uppercase tracking-wider text-fuchsia-100">Popular</span>}
                </div>
                <div className="relative mt-6 grid grid-cols-2 gap-2">
                  {plan.prices.map((price) => <div key={price.term} className="rounded-2xl border border-white/10 bg-black/25 p-3"><p className="text-[10px] font-bold uppercase tracking-[.16em] text-white/45">{price.term}</p><p className="mt-1 text-2xl font-black">₹{price.price}</p>{price.listPrice != null && <p className="text-xs text-white/40 line-through">₹{price.listPrice}</p>}</div>)}
                </div>
                <ul className="relative mt-6 flex-1 space-y-2.5 text-sm leading-5 text-white/75">
                  {plan.benefits.map((benefit) => <li key={benefit} className="flex gap-2.5"><span className="font-black" style={{ color: plan.accent }}>✓</span><span>{benefit}</span></li>)}
                </ul>
                <Link href="/shop" className="relative mt-7 block rounded-xl px-4 py-3 text-center text-sm font-extrabold text-black transition hover:brightness-110" style={{ backgroundColor: plan.accent }}>View plans and availability</Link>
              </article>
            ))}
          </div>
        </section>

        <section aria-labelledby="collections-heading" className="mt-16 sm:mt-20">
          <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
            <div><p className="text-xs font-bold uppercase tracking-[.25em] text-amber-200">One-time collections</p><h2 id="collections-heading" className="mt-2 text-2xl font-extrabold sm:text-3xl">Cosmetics, crates and showcases</h2></div>
            <span className="rounded-full border border-amber-200/20 bg-amber-200/[.06] px-3 py-1.5 text-xs text-amber-100/70">Preview · rewards not connected yet</span>
          </div>
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-5">
            {collections.map((pack) => (
              <article key={pack.name} className="flex flex-col rounded-2xl border border-white/10 bg-[#101117] p-5">
                <span aria-hidden className="grid h-11 w-11 place-items-center rounded-xl border border-white/10 bg-black/30 text-2xl" style={{ color: pack.accent }}>{pack.icon}</span>
                <p className="mt-5 text-[10px] font-bold uppercase tracking-[.18em] text-white/40">{pack.subtitle}</p>
                <h3 className="mt-1 min-h-12 text-lg font-extrabold leading-6">{pack.name}</h3>
                <p className="mt-4 text-3xl font-black" style={{ color: pack.accent }}>₹{pack.price}</p>
                <p className="mt-1 text-xs text-white/40">one-time · planned price</p>
                <ul className="mt-5 flex-1 space-y-2 text-xs leading-5 text-white/65">{pack.benefits.map((benefit) => <li key={benefit} className="flex gap-2"><span style={{ color: pack.accent }}>•</span><span>{benefit}</span></li>)}</ul>
                <div className="mt-5 rounded-lg border border-white/10 bg-white/[.03] px-3 py-2 text-center text-xs font-semibold text-white/45">Coming soon · not for sale</div>
              </article>
            ))}
          </div>
          <p className="mt-4 text-xs leading-5 text-white/40">Collection prices and rewards are previews. They are not in checkout until the server has a verified way to grant every listed item and cosmetic.</p>
        </section>

        <aside className="mt-12 rounded-2xl border border-rose-200/15 bg-rose-950/20 p-5 text-sm leading-6 text-white/65 sm:p-6">
          <h2 className="font-bold text-white">Payment and delivery</h2>
          <p className="mt-2">Rank orders use the current store checkout. UPI payment status may require staff verification; the rank is applied after the payment is confirmed. Keep your order reference and payment reference if you need help. Collection packs shown above are previews and cannot currently be purchased.</p>
          <Link href="/support?category=BILLING" className="mt-3 inline-flex font-bold text-rose-200 underline underline-offset-4 hover:text-white">Get help with an order</Link>
        </aside>
      </div>
    </main>
  );
}
