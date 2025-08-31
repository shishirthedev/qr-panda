import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickqr/features/login/bloc/login_bloc.dart';
import 'package:quickqr/features/login/bloc/login_event.dart';
import 'package:quickqr/features/login/bloc/login_state.dart';
import 'package:quickqr/features/login/repo/login_repo.dart';

void main() {
  group('LoginBloc', () {
    late LoginBloc loginBloc;
    late LoginRepository loginRepository;

    setUp(() {
      loginRepository = LoginRepository();
      loginBloc = LoginBloc(loginRepository: loginRepository);
    });

    tearDown(() {
      loginBloc.close();
    });

    test('initial state is correct', () {
      expect(loginBloc.state, LoginState.initial());
    });

    test('emits correct state when email changes', () {
      const email = 'test@example.com';
      
      loginBloc.add(const LoginEmailChanged(email));
      
      expect(loginBloc.state.email, email);
      expect(loginBloc.state.emailError, isNull);
    });

    test('emits error when invalid email is entered', () {
      const invalidEmail = 'invalid-email';
      
      loginBloc.add(const LoginEmailChanged(invalidEmail));
      
      expect(loginBloc.state.email, invalidEmail);
      expect(loginBloc.state.emailError, isNotNull);
      expect(loginBloc.state.emailError!.contains('valid email'), isTrue);
    });

    test('emits correct state when password changes', () {
      const password = 'password123';
      
      loginBloc.add(const LoginPasswordChanged(password));
      
      expect(loginBloc.state.password, password);
      expect(loginBloc.state.passwordError, isNull);
    });

    test('emits error when password is too short', () {
      const shortPassword = '123';
      
      loginBloc.add(const LoginPasswordChanged(shortPassword));
      
      expect(loginBloc.state.password, shortPassword);
      expect(loginBloc.state.passwordError, isNotNull);
      expect(loginBloc.state.passwordError!.contains('6 characters'), isTrue);
    });

    test('emits error when password is empty', () {
      const emptyPassword = '';
      
      loginBloc.add(const LoginPasswordChanged(emptyPassword));
      
      expect(loginBloc.state.password, emptyPassword);
      expect(loginBloc.state.passwordError, isNotNull);
      expect(loginBloc.state.passwordError!.contains('required'), isTrue);
    });

    test('isValid returns false when there are validation errors', () {
      loginBloc.add(const LoginEmailChanged('invalid-email'));
      loginBloc.add(const LoginPasswordChanged(''));
      
      expect(loginBloc.state.isValid, isFalse);
    });

    test('isValid returns true when there are no validation errors', () {
      loginBloc.add(const LoginEmailChanged('test@example.com'));
      loginBloc.add(const LoginPasswordChanged('password123'));
      
      expect(loginBloc.state.isValid, isTrue);
    });
  });
}
