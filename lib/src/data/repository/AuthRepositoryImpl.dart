import 'AuthRepository.dart';

class AuthRepositoryImpl implements AuthRepository {

  @override
  Future<String?> getUser() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isSignedIn() {
    throw UnimplementedError();
  }

  @override
  Future<void> signIn(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

}
