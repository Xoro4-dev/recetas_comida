# recetas_comida

Aplicación para Android (APK) y iPhone (PWA) para guardar recetas, restaurantes y lugares favoritos en pareja.

## Stack
- Flutter (un solo código para Android y web/PWA)
- Firebase Firestore (sincronización, acceso con código de pareja)
- Cloudflare Workers (lectura de enlaces y llamadas a Gemini)
- OpenStreetMap (mapas)

## Estado
- [x] Andamiaje, tema pixel-art y menú principal con navegación por botones
- [x] Código de pareja y Lista de la compra (sincronizada con Firestore)
- [ ] Recetas (estantería), Restaurantes, Rinconcitos
- [ ] Servicio de extracción (Cloudflare Worker + Gemini)

## Configurar Firebase
1. Crea un proyecto en Firebase, activa **Firestore** y registra una app web y una Android.
2. Pega `firestore.rules` en Firestore > Reglas y publícalas.
3. Compila pasando la configuración (sin ella la app funciona en modo local, sin sincronizar):
```
flutter build apk --dart-define=FIREBASE_PROJECT_ID=... --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=... --dart-define=FIREBASE_MESSAGING_SENDER_ID=...
```
Usa el `appId` de la app Android para el APK y el de la web para la PWA.

## Desarrollo
```
flutter pub get
flutter test
flutter run -d chrome
flutter build apk
```
