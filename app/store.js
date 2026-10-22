import { firebaseConfig, vapidKey } from './config.js';

// Interfaz común: subscribe(col, cb) -> unsub, add(col, obj), update(col, id, patch), remove(col, id)
// Colecciones: recipes, restaurants, pings
function localStore(space) {
  const key = (c) => `nosotros:${space}:${c}`;
  const read = (c) => JSON.parse(localStorage.getItem(key(c)) || '[]');
  const write = (c, v) => localStorage.setItem(key(c), JSON.stringify(v));
  const bc = 'BroadcastChannel' in window ? new BroadcastChannel('nosotros-' + space) : null;
  const subs = {};
  const emit = (c) => (subs[c] || []).forEach((cb) => cb(read(c)));
  bc && (bc.onmessage = (e) => emit(e.data));
  const changed = (c) => { emit(c); bc && bc.postMessage(c); };
  return {
    mode: 'local',
    subscribe(c, cb) {
      (subs[c] ||= []).push(cb);
      cb(read(c));
      return () => (subs[c] = subs[c].filter((x) => x !== cb));
    },
    async add(c, obj) {
      const item = { ...obj, id: crypto.randomUUID(), createdAt: Date.now() };
      write(c, [...read(c), item]);
      changed(c);
    },
    async update(c, id, patch) {
      write(c, read(c).map((i) => (i.id === id ? { ...i, ...patch } : i)));
      changed(c);
    },
    async remove(c, id) {
      write(c, read(c).filter((i) => i.id !== id));
      changed(c);
    },
    async enablePush() { return false; },
  };
}

async function firebaseStore(space) {
  const V = '10.12.2';
  const app = await import(`https://www.gstatic.com/firebasejs/${V}/firebase-app.js`);
  const fs = await import(`https://www.gstatic.com/firebasejs/${V}/firebase-firestore.js`);
  const fbApp = app.initializeApp(firebaseConfig);
  const db = fs.getFirestore(fbApp);
  const col = (c) => fs.collection(db, 'spaces', space, c);
  return {
    mode: 'firebase',
    subscribe(c, cb) {
      return fs.onSnapshot(fs.query(col(c), fs.orderBy('createdAt')), (snap) =>
        cb(snap.docs.map((d) => ({ ...d.data(), id: d.id }))));
    },
    async add(c, obj) { await fs.addDoc(col(c), { ...obj, createdAt: Date.now() }); },
    async update(c, id, patch) { await fs.updateDoc(fs.doc(db, 'spaces', space, c, id), patch); },
    async remove(c, id) { await fs.deleteDoc(fs.doc(db, 'spaces', space, c, id)); },
    async enablePush(user) {
      if (!vapidKey || !('Notification' in window)) return false;
      if ((await Notification.requestPermission()) !== 'granted') return false;
      const m = await import(`https://www.gstatic.com/firebasejs/${V}/firebase-messaging.js`);
      const reg = await navigator.serviceWorker.register('./firebase-messaging-sw.js');
      const token = await m.getToken(m.getMessaging(fbApp), { vapidKey, serviceWorkerRegistration: reg });
      await fs.setDoc(fs.doc(db, 'spaces', space, 'tokens', user), { token, user });
      return true;
    },
  };
}

export async function createStore(space) {
  if (firebaseConfig) {
    try { return await firebaseStore(space); } catch (e) { console.error('Firebase falló, modo local', e); }
  }
  return localStore(space);
}
