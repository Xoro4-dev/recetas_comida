# recetas_comida 💞

App para dos (iPhone + Android) hecha como **PWA**: se instala desde el navegador, sin App Store ni Play Store, sin Mac y sin cuenta de desarrollador.

## Funciones
- **Mimos**: botones "Te quiero", "Te amoooooo", "¿Una servesa?", "¿Un pitillet?", "Necesito mimos". Al pulsar uno, la otra persona ve una pantalla temática (corazones, cervezas…), vibración y voz; con Firebase configurado también llega notificación push.
- **Recetas**: guarda enlaces/textos de TikTok, Instagram o WhatsApp. Pega la descripción o los comentarios y se extraen los ingredientes (sección "Ingredientes" o líneas con cantidades). Agrupadas por tipo, con check y lista global de ingredientes.
- **Restaurantes**: añade con enlace de Google Maps (el nombre se extrae del enlace), agrupados por tipo y con check de "ya fuimos".

## Probar ahora (modo local, sin instalar nada más que Node)
```
npm start      # sirve la carpeta app en http://localhost:8080
npm test       # pruebas del analizador
```
Abre dos pestañas con el mismo código de pareja y distinto nombre: los botones de cariño se emulan entre ellas. Chrome DevTools permite emular Android/iPhone.

## Conectar los dos móviles (Firebase, gratis)
1. Crea un proyecto en <https://console.firebase.google.com>, activa **Firestore** y añade una app Web. Copia la config en `app/config.js` y `app/config.sw.js`.
2. En Cloud Messaging genera la clave **VAPID** y ponla en `app/config.js` (`vapidKey`).
3. `npm i -g firebase-tools && firebase login && firebase deploy` (las funciones de push requieren plan Blaze; sin él, la app sigue sincronizando y mostrando los avisos con la app abierta).
4. Abre la URL de Hosting en el iPhone (Safari) → Compartir → **Añadir a pantalla de inicio** (iOS 16.4+ para push) y en Android (Chrome) → **Instalar app**.
5. En ambos móviles usa el mismo código de pareja.

**Seguridad**: las reglas de `firestore.rules` son abiertas; usa un código de pareja largo e impredecible o añade Firebase Auth.

## Qué instalar
Solo **Node.js** (ya instalado) y, para desplegar, `firebase-tools`. Visual Studio Code sirve para editar; Android Studio solo es útil como emulador opcional.
