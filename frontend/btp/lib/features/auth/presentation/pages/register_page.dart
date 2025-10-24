import '../widgets/auth_button.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_form_field.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // final List<String> _selectedSectors = []; // TODO: Implement sector selection

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(authErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Créer un compte',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: AppConfig.spacingS),
                
                Text(
                  'Rejoignez notre communauté multi-secteurs',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                
                const SizedBox(height: AppConfig.spacingXXL),
                
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
                
                // First Name
                AuthFormField(
                  controller: _firstNameController,
                  label: 'Prénom',
                  hint: 'Entrez votre prénom',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    if (value.length < AppConfig.minNameLength) {
                      return 'Le prénom doit contenir au moins ${AppConfig.minNameLength} caractères';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppConfig.spacingM),
                
                // Last Name
                AuthFormField(
                  controller: _lastNameController,
                  label: 'Nom',
                  hint: 'Entrez votre nom',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    if (value.length < AppConfig.minNameLength) {
                      return 'Le nom doit contenir au moins ${AppConfig.minNameLength} caractères';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppConfig.spacingM),
                
                // Email
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
                
                // Phone
                AuthFormField(
                  controller: _phoneController,
                  label: 'Téléphone (optionnel)',
                  hint: 'Entrez votre numéro de téléphone',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
                
                const SizedBox(height: AppConfig.spacingM),
                
                // Password
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
                
                // Confirm Password
                AuthFormField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  hint: 'Confirmez votre mot de passe',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppConfig.spacingL),
                
                // Register Button
                AuthButton(
                  text: 'S\'inscrire',
                  onPressed: isLoading ? null : _handleRegister,
                  isLoading: isLoading,
                ),
                
                const SizedBox(height: AppConfig.spacingL),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous avez déjà un compte ? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/auth/login'),
                      child: const Text('Se connecter'),
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

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription en cours...')),
      );
      
      // Navigate to login page
      context.go('/auth/login');
    }
  }
}
