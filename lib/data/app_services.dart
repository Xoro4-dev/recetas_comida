import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firestore_shopping_repository.dart';
import 'shopping_repository.dart';

/// Configuración de Firebase inyectada en compilación con --dart-define
/// (FIREBASE_API_KEY, FIREBASE_APP_ID, FIREBASE_MESSAGING_SENDER_ID,
/// FIREBASE_PROJECT_ID). Sin ella la app funciona en modo local.
class AppServices {
  AppServices._({
    required this.firebaseReady,
    required this.prefs,
    String? coupleCode,
  }) : _coupleCode = coupleCode;

  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _prefKey = 'couple_code';

  final bool firebaseReady;
  final SharedPreferences prefs;
  String? _coupleCode;
  ShoppingRepository? _shopping;

  static Future<AppServices> init() async {
    var ready = false;
    if (_projectId.isNotEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
          appId: String.fromEnvironment('FIREBASE_APP_ID'),
          messagingSenderId:
              String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
          projectId: _projectId,
        ),
      );
      ready = true;
    }
    final prefs = await SharedPreferences.getInstance();
    return AppServices._(
      firebaseReady: ready,
      prefs: prefs,
      coupleCode: prefs.getString(_prefKey),
    );
  }

  /// Para tests: servicios en modo local con preferencias dadas.
  factory AppServices.local(SharedPreferences prefs) => AppServices._(
        firebaseReady: false,
        prefs: prefs,
        coupleCode: prefs.getString(_prefKey),
      );

  String? get coupleCode => _coupleCode;

  static String normalizeCode(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static bool isValidCode(String code) => code.length >= 8;

  Future<void> setCoupleCode(String raw) async {
    final code = normalizeCode(raw);
    await prefs.setString(_prefKey, code);
    _coupleCode = code;
    _shopping = null;
  }

  Future<void> leaveCouple() async {
    await prefs.remove(_prefKey);
    _coupleCode = null;
    _shopping = null;
  }

  ShoppingRepository get shopping => _shopping ??= (firebaseReady
      ? FirestoreShoppingRepository(_coupleCode!)
      : InMemoryShoppingRepository());
}
