import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Ініціалізує Firebase перед запуском застосунку.
/// Викликається один раз у main() до runApp().
Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
