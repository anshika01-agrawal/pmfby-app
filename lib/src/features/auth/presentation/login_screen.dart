import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authService.initialize();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogin(bool isFarmer) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (password.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.login(email, password);

      if (success) {
        final user = _authService.getCurrentUser();
        if (user != null &&
            ((isFarmer && user.role == 'farmer') ||
                (!isFarmer && user.role == 'official'))) {
          if (mounted) {
            context.go('/dashboard');
          }
        } else {
          _showError('Invalid role. Please login with the correct account type.');
        }
      } else {
        _showError('Invalid email or password');
      }
    } catch (e) {
      _showError('Login failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).padding.top + 40),
                // App name
                SizedBox(
                  width: screenWidth * 0.9,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Krashi Bandhu',
                      style:
                          Theme.of(context).textTheme.displayLarge?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                fontSize: screenWidth * 0.15,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                // Tagline
                SizedBox(
                  width: screenWidth * 0.85,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Making Crop Insurance Faster and Fairer',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: screenWidth * 0.055,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 48.0),
                // Email field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: !_showPassword,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24.0),
                // Farmer login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _handleLogin(true),
                    icon: const Icon(Icons.agriculture),
                    label: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Login as Farmer'),
                  ),
                ),
                const SizedBox(height: 12.0),
                // Official login button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _handleLogin(false),
                    icon: const Icon(Icons.security),
                    label: const Text('Login as Official'),
                  ),
                ),
                const SizedBox(height: 24.0),
                // Register button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Register here'),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                // Demo credentials info
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Credentials:',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: farmer@demo.com | Password: demo123',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Email: official@demo.com | Password: demo123',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                // Registration link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        'Register Here',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
