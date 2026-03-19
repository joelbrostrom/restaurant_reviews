import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordbite/providers/providers.dart';
import 'package:nordbite/theme.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NordBiteTheme.warmWhite,
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Text(
                      'NordBite',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: NordBiteTheme.coral,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp ? 'Create your account' : 'Welcome back',
                      style: GoogleFonts.karla(
                        fontSize: 16,
                        color: NordBiteTheme.charcoal.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: NordBiteTheme.charcoal.withValues(
                              alpha: 0.06,
                            ),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isSignUp ? 'Sign Up' : 'Sign In',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: NordBiteTheme.charcoal,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed:
                                  (_loading || _googleLoading)
                                      ? null
                                      : _signInWithGoogle,
                              icon:
                                  _googleLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Image.network(
                                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                        width: 20,
                                        height: 20,
                                        errorBuilder:
                                            (_, _, _) => const Icon(
                                              Icons.g_mobiledata_rounded,
                                              size: 24,
                                            ),
                                      ),
                              label: Text(
                                _isSignUp
                                    ? 'Continue with Google'
                                    : 'Sign in with Google',
                                style: GoogleFonts.karla(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: NordBiteTheme.charcoal,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: NordBiteTheme.charcoal.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: NordBiteTheme.charcoal.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'or',
                                  style: GoogleFonts.karla(
                                    fontSize: 13,
                                    color: NordBiteTheme.charcoal.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: NordBiteTheme.charcoal.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.karla(fontSize: 15),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            style: GoogleFonts.karla(fontSize: 15),
                            onSubmitted: (_) => _submit(),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: GoogleFonts.karla(
                                        color: Colors.red,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              child:
                                  _loading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Text(
                                        _isSignUp
                                            ? 'Create Account'
                                            : 'Sign In',
                                      ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isSignUp
                                    ? 'Already have an account?'
                                    : 'Don\'t have an account?',
                                style: GoogleFonts.karla(
                                  fontSize: 13,
                                  color: NordBiteTheme.charcoal.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    () => setState(() {
                                      _isSignUp = !_isSignUp;
                                      _error = null;
                                    }),
                                child: Text(
                                  _isSignUp ? 'Sign In' : 'Sign Up',
                                  style: GoogleFonts.karla(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Continue without signing in',
                        style: GoogleFonts.karla(
                          fontSize: 14,
                          color: NordBiteTheme.charcoal.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });

    try {
      final firebase = ref.read(firebaseServiceProvider);
      await firebase.signInWithGoogle();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _googleLoading = false;
          _error = _friendlyError(e.toString());
        });
      }
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter email and password');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final firebase = ref.read(firebaseServiceProvider);
      if (_isSignUp) {
        await firebase.signUp(email, password);
      } else {
        await firebase.signIn(email, password);
      }
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = _friendlyError(e.toString());
        });
      }
    }
  }

  String _friendlyError(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email';
    }
    if (error.contains('wrong-password')) return 'Incorrect password';
    if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email';
    }
    if (error.contains('invalid-email')) return 'Please enter a valid email';
    if (error.contains('weak-password')) return 'Password is too weak';
    if (error.contains('popup-closed-by-user') || error.contains('cancelled')) {
      return 'Sign-in was cancelled';
    }
    if (error.contains('account-exists-with-different-credential')) {
      return 'An account already exists with this email using a different sign-in method';
    }
    if (error.contains('network')) {
      return 'Network error — check your connection';
    }
    return 'Something went wrong. Please try again.';
  }
}
