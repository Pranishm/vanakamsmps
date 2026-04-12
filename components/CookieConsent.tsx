'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { Badge, Button, Card } from '@/components/ui';
import { useClientLang } from '@/lib/useClientLang';

function getCookie(name: string): string | null {
  if (typeof document === 'undefined') return null;
  const parts = String(document.cookie || '').split(';');
  for (const part of parts) {
    const [rawKey, ...rest] = part.trim().split('=');
    if (rawKey === name) return decodeURIComponent(rest.join('='));
  }
  return null;
}

function setCookie(name: string, value: string, maxAgeSeconds: number) {
  if (typeof document === 'undefined') return;
  const secure = typeof window !== 'undefined' && window.location?.protocol === 'https:';
  const attrs = [
    `Path=/`,
    `Max-Age=${Math.max(0, Math.floor(maxAgeSeconds))}`,
    `SameSite=Lax`,
    secure ? 'Secure' : '',
  ]
    .filter(Boolean)
    .join('; ');
  document.cookie = `${name}=${encodeURIComponent(value)}; ${attrs}`;
}

export default function CookieConsent() {
  const [visible, setVisible] = useState(false);
  const lang = useClientLang();

  useEffect(() => {
    const sync = () => {
      const existing = getCookie('cookie_consent');
      if (existing === 'accepted' || existing === 'rejected') {
        setVisible(false);
        return;
      }
      setVisible(true);
    };

    sync();
    window.addEventListener('cookie-consent-updated', sync);
    return () => window.removeEventListener('cookie-consent-updated', sync);
  }, []);

  const copy = useMemo(() => {
    if (lang === 'en') {
      return {
        title: 'Cookies',
        text: 'We use cookies to improve your experience and to keep essential features working.',
        accept: 'Accept',
        reject: 'Reject',
        policy: 'Privacy policy',
        essential: 'Essential',
      };
    }

    return {
      title: 'Cookies',
      text: 'Usamos cookies para mejorar tu experiencia y mantener funciones esenciales.',
      accept: 'Aceptar',
      reject: 'Rechazar',
      policy: 'Política de privacidad',
      essential: 'Esenciales',
    };
  }, [lang]);

  if (!visible) return null;

  return (
    <div className="fixed bottom-24 right-4 md:bottom-8 md:left-8 md:right-auto z-[1100] max-w-sm w-full animate-in slide-in-from-bottom-5 fade-in duration-500">
      <div className="overflow-hidden rounded-2xl border border-white/10 bg-[linear-gradient(180deg,rgba(17,24,39,0.95),rgba(3,7,18,0.98))] shadow-[0_20px_60px_-15px_rgba(0,0,0,0.7)] backdrop-blur-xl p-5">
        <div className="mb-4 flex items-center gap-3">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-minecraft-diamond/20 text-minecraft-diamond shadow-[inset_0_0_12px_rgba(71,209,232,0.3)]">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2a10 10 0 1 0 10 10 4 4 0 0 1-5-5 4 4 0 0 1-5-5"/><path d="M8.5 8.5v.01"/><path d="M16 12.5v.01"/><path d="M12 16v.01"/><path d="M11 11v.01"/><path d="M15 17v.01"/></svg>
          </div>
          <div>
            <h3 className="font-bold text-white text-base">{copy.title}</h3>
            <Badge variant="info" className="text-[10px] uppercase py-0 px-1.5 leading-tight">{copy.essential}</Badge>
          </div>
        </div>
        
        <p className="mb-5 text-sm leading-relaxed text-gray-300">
          {copy.text}{' '}
          <Link href="/privacy" className="font-semibold text-minecraft-diamond hover:underline hover:text-cyan-300 transition-colors">
            {copy.policy}
          </Link>
        </p>

        <div className="flex flex-col gap-2 relative z-10">
          <button
            onClick={() => {
              setCookie('cookie_consent', 'accepted', 60 * 60 * 24 * 180);
              window.dispatchEvent(new Event('cookie-consent-updated'));
              setVisible(false);
            }}
            className="w-full rounded-xl bg-gradient-to-r from-minecraft-grass to-minecraft-diamond px-4 py-2.5 text-sm font-bold text-white shadow-lg shadow-minecraft-diamond/20 transition-all hover:-translate-y-0.5 hover:shadow-minecraft-diamond/30"
          >
            {copy.accept}
          </button>
          <button
            onClick={() => {
              setCookie('cookie_consent', 'rejected', 60 * 60 * 24 * 180);
              window.dispatchEvent(new Event('cookie-consent-updated'));
              setVisible(false);
            }}
            className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-2.5 text-sm font-medium text-gray-300 transition-colors hover:bg-white/10 hover:text-white"
          >
            {copy.reject}
          </button>
        </div>
      </div>
    </div>
  );
}
