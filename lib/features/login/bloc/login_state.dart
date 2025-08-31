import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String email;
  final String password;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String? emailError;
  final String? passwordError;
  final String? loginError;

  const LoginState({
    required this.email,
    required this.password,
    required this.isSubmitting,
    required this.isSuccess,
    required this.isFailure,
    this.emailError,
    this.passwordError,
    this.loginError,
  });

  factory LoginState.initial() {
    return const LoginState(
      email: '',
      password: '',
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
      emailError: null,
      passwordError: null,
      loginError: null,
    );
  }

  LoginState copyWith({
    String? email,
    String? password,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? emailError,
    String? passwordError,
    String? loginError,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      loginError: loginError ?? this.loginError,
    );
  }

  bool get isValid => emailError == null && passwordError == null;

  @override
  List<Object?> get props => [
        email,
        password,
        isSubmitting,
        isSuccess,
        isFailure,
        emailError,
        passwordError,
        loginError,
      ];
}
