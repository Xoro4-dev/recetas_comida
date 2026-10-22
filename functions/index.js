// Envía una notificación push a la pareja cuando se crea un "ping".
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
admin.initializeApp();

const TEXTS = {
  tequiero: 'Te quiero 💕', teamo: 'Te amoooooo 😍', cerveza: '¿Una servesa? 🍺',
  pitillet: '¿Un pitillet? 🚬', mimos: 'Necesito mimos 🥺',
};

exports.onPing = onDocumentCreated('spaces/{space}/pings/{id}', async (event) => {
  const ping = event.data.data();
  const tokens = await admin.firestore().collection('spaces').doc(event.params.space).collection('tokens').get();
  const targets = tokens.docs.map((d) => d.data()).filter((t) => t.user !== ping.from).map((t) => t.token);
  if (!targets.length) return;
  await admin.messaging().sendEachForMulticast({
    tokens: targets,
    data: { title: `De ${ping.from}`, body: TEXTS[ping.button] || ping.button },
  });
});
