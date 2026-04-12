'use client';

import { useEffect } from 'react';

export default function ErrorPage({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Keep this for debugging; Next will also log in dev.
    // eslint-disable-next-line no-console
    console.error('Route error:', error);
  }, [error]);

  return (
    <div className="mx-auto max-w-3xl px-6 py-16">
      <div className="rounded-lg border border-minecraft-grass/20 bg-black/30 backdrop-blur-sm p-6">
        <h2 className="text-2xl font-bold text-white">Something went wrong on this page</h2>
        <p className="mt-2 text-gray-300">
          This is usually caused by a JavaScript error or a failed request. Please try again.
        </p>

        <div className="mt-6 flex flex-wrap gap-3">
          <button
            type="button"
            onClick={reset}
            className="px-4 py-2 rounded-md text-sm font-medium bg-minecraft-grass text-white hover:bg-minecraft-grass/80 transition-colors"
          >
            Try again
          </button>
          <button
            type="button"
            onClick={() => window.location.reload()}
            className="px-4 py-2 rounded-md text-sm font-medium text-gray-300 hover:bg-white/10 hover:text-white transition-colors"
          >
            Reload
          </button>
        </div>

        {process.env.NODE_ENV !== 'production' && (
          <pre className="mt-6 whitespace-pre-wrap break-words rounded-md border border-white/10 bg-black/40 p-4 text-xs text-gray-200">
            {String(error?.message || error)}
          </pre>
        )}
      </div>
    </div>
  );
}
