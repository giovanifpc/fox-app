const VERSION = 'fox-v1.0.5';
const CACHE = 'fox-app-' + VERSION;

// Assets estáticos — cache-first (não mudam com frequência)
const SHELL_ASSETS = [
  './site.webmanifest',
  './app-icon.svg',
  './app-icon-192.png',
  './app-icon-512.png',
  './fox-logo-sem-fundo.svg',
  './banner alongamento.png',
  './exercises.json',
];

// Páginas HTML — pré-cacheadas mas servidas com network-first
const SHELL_HTML = [
  './',
  './index.html',
  './login.html',
  './training.html',
  './nutri.html',
  './minha-area.html',
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(c => c.addAll([...SHELL_HTML, ...SHELL_ASSETS]))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const url = e.request.url;

  // Sempre rede: Supabase, APIs externas, admin, CDNs
  if (
    url.includes('supabase.co') ||
    url.includes('googleapis') ||
    url.includes('cdn.jsdelivr') ||
    url.includes('/admin')
  ) return;

  if (e.request.method !== 'GET') return;

  const isHTML = e.request.destination === 'document' ||
    /\.html(\?|$)/.test(url) ||
    url.endsWith('/');

  if (isHTML) {
    // Network-first para HTML: cliente sempre recebe versão nova quando online
    e.respondWith(
      fetch(e.request)
        .then(res => {
          if (res.ok) {
            caches.open(CACHE).then(c => c.put(e.request, res.clone()));
          }
          return res;
        })
        .catch(() => caches.match(e.request))
    );
    return;
  }

  // Cache-first para assets: performance, fallback para rede
  e.respondWith(
    caches.match(e.request).then(cached => {
      const net = fetch(e.request).then(res => {
        if (res && res.status === 200 && res.type !== 'opaque') {
          caches.open(CACHE).then(c => c.put(e.request, res.clone()));
        }
        return res;
      }).catch(() => null);
      return cached || net;
    })
  );
});

self.addEventListener('message', e => {
  if (e.data === 'skipWaiting') self.skipWaiting();
});
