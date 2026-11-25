// Dark Routine service worker v5: força a atualização do HTML publicado.
const V='dr-v5';
const A=['./','./index.html','./manifest.webmanifest','./icon-192.png','./icon-512.png'];
self.addEventListener('install',event=>{
  event.waitUntil((async()=>{
    const cache=await caches.open(V);
    await Promise.all(A.map(async url=>{
      try {
        const response=await fetch(url,{cache:'reload'});
        if(response.ok) await cache.put(url,response);
      } catch (_) {}
    }));
    await self.skipWaiting();
  })());
});
self.addEventListener('activate',event=>{
  event.waitUntil((async()=>{
    const keys=await caches.keys();
    await Promise.all(keys.filter(key=>key.startsWith('dr-')&&key!==V).map(key=>caches.delete(key)));
    await self.clients.claim();
  })());
});
self.addEventListener('fetch',event=>{
  const request=event.request;
  if(request.method!=='GET') return;
  const url=new URL(request.url);
  if(url.origin!==self.location.origin) return;
  const isPage=request.mode==='navigate'||url.pathname.endsWith('/index.html')||url.pathname.endsWith('/');
  if(isPage){
    event.respondWith((async()=>{
      const cache=await caches.open(V);
      try{
        const fresh=await fetch(request,{cache:'no-store'});
        if(fresh.ok) await cache.put('./index.html',fresh.clone());
        return fresh;
      }catch(_){
        return (await cache.match(request))||(await cache.match('./index.html'))||(await cache.match('./'));
      }
    })());
    return;
  }
  event.respondWith((async()=>{
    const cache=await caches.open(V);
    const cached=await cache.match(request);
    if(cached) return cached;
    try{
      const fresh=await fetch(request);
      if(fresh.ok) await cache.put(request,fresh.clone());
      return fresh;
    }catch(error){throw error;}
  })());
});
