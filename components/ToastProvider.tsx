'use client';

import { createElement, useEffect, useState } from 'react';

/**
 * Isolated wrapper that loads react-toastify's ToastContainer purely at
 * runtime so Turbopack's static analysis cannot break the reference.
 */
export default function ToastProvider() {
  const [mod, setMod] = useState<any>(null);

  useEffect(() => {
    let cancelled = false;
    import('react-toastify').then((m) => {
      if (!cancelled) setMod(m);
    });
    return () => { cancelled = true; };
  }, []);

  if (!mod) return null;

  // Defensively resolve – covers both ESM named export and CJS .default
  const TC = mod.ToastContainer ?? mod.default?.ToastContainer ?? mod.default;

  if (!TC || typeof TC !== 'function') return null;

  return createElement(TC, {
    position: 'top-right',
    autoClose: 3000,
    hideProgressBar: false,
    newestOnTop: true,
    closeOnClick: true,
    rtl: false,
    pauseOnFocusLoss: true,
    draggable: true,
    pauseOnHover: true,
    theme: 'dark',
  });
}
