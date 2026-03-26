'use client';

import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';
import { getClientLangFromCookie, type Lang } from '@/lib/i18n';

type LangContextValue = {
  lang: Lang;
  setLang: (lang: Lang) => void;
};

const LangContext = createContext<LangContextValue | null>(null);

export function LangProvider({ initialLang, children }: { initialLang: Lang; children: ReactNode }) {
  const [lang, setLang] = useState<Lang>(initialLang);

  useEffect(() => {
    // On mount, sync with the actual cookie value (may differ from server-provided initialLang
    // if middleware set the cookie after the server component read it).
    const cookieLang = getClientLangFromCookie();
    if (cookieLang !== lang) {
      setLang(cookieLang);
    }

    const sync = () => setLang(getClientLangFromCookie());
    window.addEventListener('langchange', sync);
    return () => window.removeEventListener('langchange', sync);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const value = useMemo<LangContextValue>(() => ({ lang, setLang }), [lang]);

  return <LangContext.Provider value={value}>{children}</LangContext.Provider>;
}

export function useLangContext() {
  return useContext(LangContext);
}
