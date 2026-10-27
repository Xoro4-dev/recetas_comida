# recetas_comida

Aplicación para Android (APK) y iPhone (PWA) para guardar recetas, restaurantes y lugares favoritos en pareja.

## Stack
- Flutter (un solo código para Android y web/PWA)
- Firebase Firestore (sincronización, acceso con código de pareja)
- Cloudflare Workers (lectura de enlaces y llamadas a Gemini)
- OpenStreetMap (mapas)

## Estado
- [x] Andamiaje, tema pixel-art y menú principal con navegación por botones
- [ ] Recetas (estantería), Restaurantes, Rinconcitos, Lista de la compra
- [ ] Sincronización y servicio de extracción

## Desarrollo
```
flutter pub get
flutter test
flutter run -d chrome
flutter build apk
```
