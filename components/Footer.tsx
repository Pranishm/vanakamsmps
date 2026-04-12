'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { FaDiscord, FaTiktok, FaYoutube, FaHeart, FaInstagram, FaCcVisa, FaCcMastercard, FaCcAmex, FaPaypal, FaStripe } from 'react-icons/fa';
import { useEffect, useState } from 'react';
import { t } from '@/lib/i18n';
import { useClientLang } from '@/lib/useClientLang';
import { Input, Button } from '@/components/ui';

const Footer = () => {
  const lang = useClientLang();
  const pathname = usePathname() || '';
  const isHome = pathname === '/';
  const currentYear = new Date().getFullYear();
  const [newsletterEmail, setNewsletterEmail] = useState('');
  const [newsletterLoading, setNewsletterLoading] = useState(false);
  const [newsletterDone, setNewsletterDone] = useState(false);
  const [newsletterError, setNewsletterError] = useState('');
  const [amexLogoError, setAmexLogoError] = useState(false);
  const [amexLogoSrc, setAmexLogoSrc] = useState('/amex.png');

  useEffect(() => {
    setAmexLogoError(false);
    setAmexLogoSrc(`/amex.png?v=${Date.now()}`);
  }, []);

  const subscribeNewsletter = async (e: React.FormEvent) => {
    e.preventDefault();
    setNewsletterError('');
    setNewsletterDone(false);
    setNewsletterLoading(true);
    try {
      const response = await fetch('/api/newsletter/subscribe', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: newsletterEmail, source: 'footer', lang }),
      });
      const data = await response.json().catch(() => ({}));
      if (!response.ok) {
        throw new Error(String((data as any)?.error || t(lang, 'footer.newsletter.error')));
      }

      setNewsletterDone(true);
      setNewsletterEmail('');
    } catch (err: any) {
      setNewsletterError(err?.message || t(lang, 'footer.newsletter.error'));
    } finally {
      setNewsletterLoading(false);
    }
  };

  return (
    <footer
      className={`relative mt-16 overflow-hidden sm:mt-20 ${isHome
          ? 'border-t border-minecraft-diamond/15 bg-[linear-gradient(180deg,rgba(2,7,20,0.72),rgba(2,10,26,0.94))]'
          : 'border-t border-transparent bg-[linear-gradient(180deg,rgba(14,17,26,0.94),rgba(16,18,28,0.98))]'
        }`}
    >
      <div aria-hidden className="pointer-events-none absolute inset-0">
        <div
          className={`absolute inset-x-0 top-0 h-32 ${isHome
              ? 'bg-[linear-gradient(180deg,rgba(71,209,232,0.1),transparent)]'
              : 'bg-[linear-gradient(180deg,rgba(255,214,226,0.08),transparent)]'
            }`}
        />
        <div
          className={`absolute -left-16 top-12 h-44 w-44 rounded-full blur-3xl ${isHome ? 'bg-minecraft-diamond/12' : 'bg-rose-300/8'
            }`}
        />
        <div
          className={`absolute right-0 top-10 h-56 w-56 rounded-full blur-3xl ${isHome ? 'bg-minecraft-grass/10' : 'bg-amber-200/6'
            }`}
        />
        <div
          className={`absolute inset-0 [background-image:linear-gradient(rgba(255,255,255,0.08)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.08)_1px,transparent_1px)] [background-size:28px_28px] ${isHome ? 'opacity-[0.08]' : 'opacity-[0.05]'
            }`}
        />
      </div>
      <div className="relative mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8 lg:py-12">
        <div className="grid grid-cols-1 gap-10 md:grid-cols-2 xl:grid-cols-4 xl:gap-12">
          {/* About */}
          <div className="xl:col-span-1">
            <h3 className="mb-3 text-lg font-bold text-gray-900 dark:text-white">VANAKAMSMPs</h3>
            <p className="text-sm leading-6 text-gray-600 dark:text-gray-400">
              {t(lang, 'footer.about')}
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="mb-4 text-lg font-bold text-gray-900 dark:text-white">{t(lang, 'footer.quickLinks')}</h3>
            <ul className="space-y-2">
              <li>
                <Link href="/" className="text-gray-600 dark:text-gray-400 hover:text-minecraft-grass transition-colors text-sm">
                  {t(lang, 'nav.home')}
                </Link>
              </li>
              <li>
                <Link href="/shop" className="text-gray-600 dark:text-gray-400 hover:text-minecraft-grass transition-colors text-sm">
                  {t(lang, 'nav.shop')}
                </Link>
              </li>
              <li>
                <Link href="/rules" className="text-gray-600 dark:text-gray-400 hover:text-minecraft-grass transition-colors text-sm">
                  {t(lang, 'nav.rules')}
                </Link>
              </li>
              <li>
                <Link href="/support" className="text-gray-600 dark:text-gray-400 hover:text-minecraft-grass transition-colors text-sm">
                  {t(lang, 'nav.support')}
                </Link>
              </li>
              <li>
                <Link href="/partner" className="text-gray-600 dark:text-gray-400 hover:text-minecraft-grass transition-colors text-sm">
                  {t(lang, 'nav.partner')}
                </Link>
              </li>
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h3 className="mb-4 text-lg font-bold text-gray-900 dark:text-white">{t(lang, 'footer.legal')}</h3>
            <ul className="space-y-2">
              <li>
                <Link href="/terms" className="text-gray-600 dark:text-gray-400 hover:text-minecraft-grass transition-colors text-sm">
                  {t(lang, 'footer.terms')}
                </Link>
              </li>
              <li>
                <Link href="/privacy" className="text-gray-600 dark:text-gray-400 hover:text-minecraft-grass transition-colors text-sm">
                  {t(lang, 'footer.privacy')}
                </Link>
              </li>
              <li>
                <Link href="/cookies" className="text-gray-600 dark:text-gray-400 hover:text-minecraft-grass transition-colors text-sm">
                  {t(lang, 'footer.cookies')}
                </Link>
              </li>
            </ul>
          </div>

          {/* Social */}
          <div>
            <h3 className="mb-4 text-lg font-bold text-gray-900 dark:text-white">{t(lang, 'footer.follow')}</h3>
            <div className="flex items-center space-x-4">
              <a
                href={process.env.NEXT_PUBLIC_DISCORD_URL || '#'}
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-600 dark:text-gray-400 hover:text-[#5865F2] hover:-translate-y-1 transition-all"
              >
                <FaDiscord size={28} />
              </a>
              <a
                href={process.env.NEXT_PUBLIC_TIKTOK_URL || '#'}
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:-translate-y-1 transition-all"
              >
                <FaTiktok size={28} />
              </a>
              <a
                href={process.env.NEXT_PUBLIC_YOUTUBE_URL || '#'}
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-600 dark:text-gray-400 hover:text-[#FF0000] hover:-translate-y-1 transition-all"
              >
                <FaYoutube size={28} />
              </a>
              <a
                href="#"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-600 dark:text-gray-400 hover:text-[#E1306C] hover:-translate-y-1 transition-all"
              >
                <FaInstagram size={28} />
              </a>
            </div>

            <div className="mt-6">
              <div className="text-gray-900 dark:text-white font-semibold text-sm mb-2">{t(lang, 'footer.newsletter.title')}</div>
              <div className="text-xs text-gray-600 dark:text-gray-400 mb-3">{t(lang, 'footer.newsletter.subtitle')}</div>
              <form onSubmit={subscribeNewsletter} className="relative mt-2">
                <input
                  type="email"
                  value={newsletterEmail}
                  onChange={(e) => setNewsletterEmail(e.target.value)}
                  placeholder={t(lang, 'footer.newsletter.placeholder')}
                  disabled={newsletterLoading}
                  className="w-full rounded-full border border-gray-300 dark:border-white/20 bg-white/80 dark:bg-black/30 px-5 py-3.5 pr-32 text-sm text-gray-900 dark:text-gray-100 placeholder-gray-500 transition-colors focus:border-minecraft-grass focus:outline-none focus:ring-1 focus:ring-minecraft-grass"
                />
                <button
                  type="submit"
                  disabled={newsletterLoading || !newsletterEmail.trim()}
                  className="absolute right-1 top-1 bottom-1 rounded-full bg-minecraft-grass px-5 text-sm font-semibold text-white shadow-sm transition-all hover:bg-green-500 disabled:opacity-50"
                >
                  {newsletterLoading ? t(lang, 'footer.newsletter.loading') : t(lang, 'footer.newsletter.submit')}
                </button>
              </form>
              {newsletterDone ? (
                <div className="mt-2 text-xs text-green-600 dark:text-green-400">{t(lang, 'footer.newsletter.success')}</div>
              ) : null}
              {newsletterError ? (
                <div className="mt-2 text-xs text-red-600 dark:text-red-400">{newsletterError}</div>
              ) : null}
            </div>
          </div>
        </div>

        <div className={`mt-8 pt-8 ${isHome ? 'border-t border-white/10' : 'border-t border-white/5'}`}>
          <div className="flex flex-col items-center gap-3 mb-6">
            <div className="text-xs font-semibold tracking-wide text-gray-600 dark:text-gray-400">
              {t(lang, 'footer.payments')}
            </div>
            <div className="flex flex-wrap items-center justify-center gap-4">
              <span className="inline-flex items-center text-gray-400 hover:text-[#003087] transition-colors" aria-label="PayPal" title="PayPal">
                <FaPaypal size={32} />
              </span>
              <span className="inline-flex items-center text-gray-400 hover:text-[#1A1F71] transition-colors" aria-label="Visa" title="Visa">
                <FaCcVisa size={32} />
              </span>
              <span className="inline-flex items-center text-gray-400 hover:text-[#EB001B] transition-colors" aria-label="Mastercard" title="Mastercard">
                <FaCcMastercard size={32} />
              </span>
              <span className="inline-flex items-center text-gray-400 hover:text-[#2E77BB] transition-colors" aria-label="American Express" title="American Express">
                <FaCcAmex size={32} />
              </span>
              <span className="inline-flex items-center text-gray-400 hover:text-[#635BFF] transition-colors" aria-label="Stripe" title="Stripe">
                <FaStripe size={32} />
              </span>
            </div>
          </div>

          <p className="flex items-center justify-center text-center text-sm text-gray-600 dark:text-gray-400">
            © {currentYear} VANAKAMSMPs. {t(lang, 'footer.madeWith')}{' '}
            <FaHeart className="mx-1 text-red-500" /> {t(lang, 'footer.forCommunity')}
          </p>
          <p className="text-center text-gray-500 dark:text-gray-500 text-xs mt-2">
            {t(lang, 'footer.notAffiliated')}
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
