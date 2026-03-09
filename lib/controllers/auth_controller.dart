import 'package:todo_app/services/firebase_auth_service.dart';

class AuthController {
  final FirebaseAuthService service = FirebaseAuthService();

  Future login(String email, String password) {
    return service.login(email, password);
  }

  Future signup(String email, String password) {
    return service.signup(email, password);
  }

  Future logout() {
    return service.logout();
  }
}