import '../widgets/auth_button.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_form_field.dart';
import 'package:go_router/go_router.dart';
import '../widgets/social_login_button.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConfig.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(authErrorProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.spacingL),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConfig.spacingXXL),
                  
                  // Logo and Title
                  _buildHeader(),
                  
                  const SizedBox(height: AppConfig.spacingXXL),
                  
                  // Login Form
                  _buildLoginForm(authState, isLoading, error),
                  
                  const SizedBox(height: AppConfig.spacingL),
                  
                  // Social Login
                  _buildSocialLogin(),
                  
                  const SizedBox(height: AppConfig.spacingL),
                  
                  // Register Link
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.construction,
            size: 40,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: AppConfig.spacingL),
        
        // Title
        Text(
          'Connexion',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: AppConfig.spacingS),
        
        // Subtitle
        Text(
          'Connectez-vous à votre compte',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthState authState, bool isLoading, String? error) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Error Message
          if (error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConfig.spacingM),
              margin: const EdgeInsets.only(bottom: AppConfig.spacingM),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: AppConfig.spacingS),
                  Expanded(
                    child: Text(
                      error,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Email Field
          AuthFormField(
            controller: _emailController,
            label: 'Email',
            hint: 'Entrez votre email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppConfig.spacingM),
          
          // Password Field
          AuthFormField(
            controller: _passwordController,
            label: 'Mot de passe',
            hint: 'Entrez votre mot de passe',
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outlined,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              if (value.length < AppConfig.minPasswordLength) {
                return 'Le mot de passe doit contenir au moins ${AppConfig.minPasswordLength} caractères';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppConfig.spacingM),
          
          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text('Se souvenir de moi'),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/auth/forgot-password'),
                child: const Text('Mot de passe oublié ?'),
              ),
            ],
          ),
          
          const SizedBox(height: AppConfig.spacingL),
          
          // Login Button
          AuthButton(
            text: 'Se connecter',
            onPressed: isLoading ? null : _handleLogin,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.spacingM),
              child: Text(
                'Ou continuer avec',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: AppConfig.spacingL),
        
        Row(
          children: [
            Expanded(
              child: SocialLoginButton(
                text: 'Google',
                icon: Icons.g_mobiledata,
                onPressed: _handleGoogleLogin,
              ),
            ),
            
            const SizedBox(width: AppConfig.spacingM),
            
            Expanded(
              child: SocialLoginButton(
                text: 'Facebook',
                icon: Icons.facebook,
                onPressed: _handleFacebookLogin,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous n\'avez pas de compte ? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/auth/register'),
          child: const Text('S\'inscrire'),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
        rememberMe: _rememberMe,
      );
      
      if (success && mounted) {
        context.go('/home');
      }
    }
  }

  void _handleGoogleLogin() {
    // Implement Google login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connexion Google en cours...')),
    );
  }

  void _handleFacebookLogin() {
    // Implement Facebook login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connexion Facebook en cours...')),
    );
  }
}
