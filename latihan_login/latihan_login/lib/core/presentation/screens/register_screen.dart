import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../constants/colors.dart';
import '../../data/database/database_helper.dart';
import '../../utils/app_snack_bar.dart';
import '../../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_text_field.dart';

/// Halaman pendaftaran akun baru ke tabel `user`.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Validasi konfirmasi password memakai password saat ini.
    final confirmError = Validators.confirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
    );
    if (confirmError != null) {
      AppSnackBar.error(context, confirmError);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      if (await DatabaseHelper.isEmailRegistered(email)) {
        if (!mounted) return;
        AppSnackBar.error(context, AppConstants.msgEmailRegistered);
        return;
      }

      await DatabaseHelper.insertUser(
        name: _nameController.text,
        email: email,
        password: _passwordController.text,
      );

      if (!mounted) return;
      AppSnackBar.success(context, AppConstants.msgRegisterSuccess);
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, '${AppConstants.msgDatabaseError}: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.createAccount)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.formMaxWidth,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.tagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            label: AppConstants.labelName,
                            hintText: AppConstants.hintName,
                            icon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: Validators.name,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            label: AppConstants.labelEmail,
                            hintText: AppConstants.hintEmail,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: AppConstants.labelPassword,
                            hintText: AppConstants.hintPassword,
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: AppConstants.labelConfirmPassword,
                            hintText: AppConstants.hintConfirmPassword,
                            icon: Icons.lock_reset_outlined,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) => Validators.confirmPassword(
                              value,
                              _passwordController.text,
                            ),
                            onFieldSubmitted: (_) => _handleRegister(),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                              child: Text(
                                _obscurePassword
                                    ? 'Tampilkan password'
                                    : 'Sembunyikan password',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomButton(
                            text: AppConstants.buttonRegister,
                            icon: Icons.person_add_alt_1,
                            isLoading: _isLoading,
                            onPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppConstants.haveAccount,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(AppConstants.buttonLogin),
                        ),
                      ],
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
}
