const CACHE_NAME = 'vanakam-smp-v2';

self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll([
        '/',
        '/widget-template.html'
    ]))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((k) => caches.delete(k))
      );
    })
  );
  self.clients.claim();
});

// Priority network-first, fallback to cache
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  event.respondWith(
    fetch(event.request)
      .then((networkRes) => {
        // Cache API responses gracefully
        if (event.request.url.includes('/api/')) {
           const clone = networkRes.clone();
           caches.open(`${CACHE_NAME}-api`).then(c => c.put(event.request, clone));
        }
        return networkRes;
      })
      .catch(async () => {
        const cached = await caches.match(event.request);
        if (cached) return cached;
        // API fallback from dedicated db cache
        if (event.request.url.includes('/api/')) {
            const apiCache = await caches.match(event.request, { cacheName: `${CACHE_NAME}-api` });
            return apiCache || new Response(JSON.stringify({ server: 'offline', players: 0 }), { headers: { 'Content-Type': 'application/json' }});
        }
      })
  );
});

// Periodic background sync handling for live widgets
self.addEventListener('periodicsync', (event) => {
  if (event.tag === 'sync-server-status') {
    event.waitUntil(syncStatus());
  }
});

async function syncStatus() {
  try {
    const res = await fetch('https://vanakam.me/api/status');
    const data = await res.json();
    const cache = await caches.open(`${CACHE_NAME}-api`);
    await cache.put('https://vanakam.me/api/status', new Response(JSON.stringify(data), {
      headers: { 'Content-Type': 'application/json' }
    }));

    // Alert all connected web clients / widgets
    const clients = await self.clients.matchAll();
    clients.forEach(c => c.postMessage({ type: 'STATUS_UPDATE', data }));
  } catch (err) {
    console.error('[SW] API Widget Sync failed', err);
  }
}

// Push notifications mapping natively integrated 
self.addEventListener('push', (event) => {
  let data = { title: "VANAKAM SMPs", body: "Server Event Starting Now!" };
  if (event.data) {
    data = event.data.json();
  }
  
  event.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: '/icon-192.png',
      badge: '/icon-192.png',
      data: data.url || 'https://vanakam.me/',
      vibrate: [200, 100, 200]
    })
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.openWindow(event.notification.data || 'https://vanakam.me/')
  );
});
