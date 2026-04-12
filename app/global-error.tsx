'use client';

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <html>
      <body>
        <div style={{ padding: 24, fontFamily: 'system-ui, -apple-system, Segoe UI, Roboto' }}>
          <h2 style={{ fontSize: 20, fontWeight: 700 }}>Critical error</h2>
          <p style={{ marginTop: 8 }}>The application encountered a global failure. You can try again.</p>
          <div style={{ marginTop: 16, display: 'flex', gap: 12 }}>
            <button
              onClick={reset}
              style={{ padding: '8px 12px', borderRadius: 8, border: '1px solid #ccc' }}
            >
              Try again
            </button>
            <button
              onClick={() => window.location.reload()}
              style={{ padding: '8px 12px', borderRadius: 8, border: '1px solid #ccc' }}
            >
              Reload
            </button>
          </div>
          {process.env.NODE_ENV !== 'production' && (
            <pre style={{ marginTop: 16, whiteSpace: 'pre-wrap' }}>{String(error?.message || error)}</pre>
          )}
        </div>
      </body>
    </html>
  );
}
