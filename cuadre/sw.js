// Guarda la página y sus librerías para abrir rápido y sin internet; siempre intenta la versión nueva primero. Los datos (Apps Script) no se guardan:
// lo que se registra sin conexión queda en la cola del equipo (COLA, IndexedDB) y se envía al volver internet.
const CACHE = 'cuadre-202610251703';
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(['./', './manifest.webmanifest', './iconos/icon-192.png', './iconos/icon-fondo-192.png']))); self.skipWaiting(); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(k => Promise.all(k.filter(x => x !== CACHE).map(x => caches.delete(x))))); self.clients.claim(); });
self.addEventListener('fetch', e => {
  const u = new URL(e.request.url);
  // Sin internet también abre: la página y las librerías (PDF, gráficos, lector de carnet, letras) quedan guardadas al usarse
  const libreria = /^(cdnjs\.cloudflare\.com|cdn\.jsdelivr\.net|fastly\.jsdelivr\.net|unpkg\.com|fonts\.googleapis\.com|fonts\.gstatic\.com)$/.test(u.hostname);
  if (e.request.method !== 'GET' || (u.origin !== location.origin && !libreria)) return;
  // La página de la app siempre se pide nueva a GitHub (sin la copia que el navegador guarda hasta 10 minutos); las librerías, normal
  const pedido = u.origin === location.origin ? fetch(e.request, { cache: 'no-cache' }) : fetch(e.request);
  e.respondWith(pedido.then(r => { const c = r.clone(); caches.open(CACHE).then(x => x.put(e.request, c)); return r; }).catch(() => caches.match(e.request)));
});