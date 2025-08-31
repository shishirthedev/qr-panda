class LoginRepository {
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate API call - return true for correct credentials, throw exception for wrong ones
    if (email == "test@test.com" && password == "123456") {
      return true;
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
