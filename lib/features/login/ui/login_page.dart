import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../repo/login_repo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(loginRepository: LoginRepository()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Title Section
                const Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Login Form
                BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Login successful!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (state.isFailure && state.loginError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.loginError!),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      children: [
                        // Email Field
                        _buildEmailField(context, state),
                        const SizedBox(height: 20),

                        // Password Field
                        _buildPasswordField(context, state),
                        const SizedBox(height: 32),

                        // Login Button
                        _buildLoginButton(context, state),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Demo Credentials
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Demo Credentials',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Email: test@test.com\nPassword: 123456',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context, LoginState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: (email) => context
              .read<LoginBloc>()
              .add(LoginEmailChanged(email)),
          keyboardType: TextInputType.emailAddress,
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Colors.grey,
            ),
          ),
        ),
        if (state.emailError != null) ...[
          const SizedBox(height: 8),
          Text(
            state.emailError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context, LoginState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: (password) => context
              .read<LoginBloc>()
              .add(LoginPasswordChanged(password)),
          obscureText: true,
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: const Icon(
              Icons.lock_outlined,
              color: Colors.grey,
            ),
          ),
        ),
        if (state.passwordError != null) ...[
          const SizedBox(height: 8),
          Text(
            state.passwordError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: state.isSubmitting || !state.isValid
            ? null
            : () => context.read<LoginBloc>().add(LoginSubmitted()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: state.isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
