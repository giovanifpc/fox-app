const VERSION = 'fox-v1.0.3';
const CACHE = 'fox-app-' + VERSION;

const SHELL = [
  './',
  './index.html',
  './login.html',
  './training.html',
  './nutri.html',
  './minha-area.html',
  './site.webmanifest',
  './app-icon.svg',
  './app-icon-192.png',
  './app-icon-512.png',
  './fox-logo-sem-fundo.svg',
  './banner alongamento.png',
  './exercises.json',
];

// Instala: pré-cacheia o shell
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting())
  );
});

// Ativa: apaga caches antigos e toma controle imediato
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// Fetch: Supabase sempre na rede; resto cache-first com fallback de rede
self.addEventListener('fetch', e => {
  const url = e.request.url;

  // Supabase, auth, APIs externas e admin — sempre rede
  if (url.includes('supabase.co') || url.includes('googleapis') || url.includes('cdn.jsdelivr') || url.includes('/admin')) {
    return; // deixa o browser resolver normalmente
  }

  // GET only
  if (e.request.method !== 'GET') return;

  e.respondWith(
    caches.match(e.request).then(cached => {
      const networkFetch = fetch(e.request).then(res => {
        if (res && res.status === 200 && res.type !== 'opaque') {
          const clone = res.clone();
          caches.open(CACHE).then(c => c.put(e.request, clone));
        }
        return res;
      }).catch(() => null);

      // Retorna cache imediatamente; atualiza em background
      return cached || networkFetch;
    })
  );
});

// Mensagem para forçar update a partir do app
self.addEventListener('message', e => {
  if (e.data === 'skipWaiting') self.skipWaiting();
});
