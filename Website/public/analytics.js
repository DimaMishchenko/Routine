if (window.location.protocol === 'https:' && window.location.hostname === 'routine.dimasike.com'
    && !document.querySelector('script[data-cf-beacon]')) {
  const beacon = document.createElement('script');
  beacon.type = 'module';
  beacon.src = 'https://static.cloudflareinsights.com/beacon.min.js';
  beacon.dataset.cfBeacon = JSON.stringify({ token: '247c6a4a17ed43d8870ba01940e739ee' });
  document.head.append(beacon);
}
