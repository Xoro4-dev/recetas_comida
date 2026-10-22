// Service worker de notificaciones push (se activa al configurar Firebase).
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');
importScripts('./config.sw.js');
if (self.FIREBASE_CONFIG) {
  firebase.initializeApp(self.FIREBASE_CONFIG);
  firebase.messaging().onBackgroundMessage((p) => {
    self.registration.showNotification(p.data.title, { body: p.data.body, icon: 'icons/icon-192.png', tag: 'ping' });
  });
}
