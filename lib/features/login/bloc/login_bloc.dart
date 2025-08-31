// login_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/login_repo.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository loginRepository;

  LoginBloc({required this.loginRepository}) : super(LoginState.initial()) {
    on<LoginEmailChanged>((event, emit) {
      final emailError = _validateEmail(event.email);
      emit(state.copyWith(
        email: event.email,
        emailError: emailError,
        isFailure: false,
        loginError: null,
      ));
    });

    on<LoginPasswordChanged>((event, emit) {
      final passwordError = _validatePassword(event.password);
      emit(state.copyWith(
        password: event.password,
        passwordError: passwordError,
        isFailure: false,
        loginError: null,
      ));
    });

    on<LoginSubmitted>((event, emit) async {
      // Validate before submitting
      final emailError = _validateEmail(state.email);
      final passwordError = _validatePassword(state.password);
      
      if (emailError != null || passwordError != null) {
        emit(state.copyWith(
          emailError: emailError,
          passwordError: passwordError,
        ));
        return;
      }

      emit(state.copyWith(
        isSubmitting: true,
        isFailure: false,
        isSuccess: false,
        loginError: null,
      ));

      try {
        final success = await loginRepository.login(state.email, state.password);
        if (success) {
          emit(state.copyWith(
            isSubmitting: false,
            isSuccess: true,
          ));
        } else {
          emit(state.copyWith(
            isSubmitting: false,
            isFailure: true,
            loginError: 'Invalid email or password',
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          isSubmitting: false,
          isFailure: true,
          loginError: 'Login failed. Please try again.',
        ));
      }
    });
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
