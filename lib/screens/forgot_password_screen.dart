import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Écran "mot de passe oublié" (CDC section 8.1). Corrige doc/audit.md,
/// point C2 : ce flux existait côté API mais n'avait jamais été construit
/// côté app — aucun lien, aucun écran.
///
/// Déroulé en deux étapes sur un seul écran : demande du code par email,
/// puis saisie du code reçu + nouveau mot de passe.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _codeRequested = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _errorMessage = 'Entrez un email valide');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthService>().forgotPassword(email: _emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _codeRequested = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code envoyé par email. Vérifiez aussi vos spams.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_codeController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      setState(() => _errorMessage = 'Tous les champs doivent être remplis');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthService>().resetPassword(
            email: _emailController.text.trim(),
            token: _codeController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe réinitialisé. Connectez-vous.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A7F55), Color(0xFF2EAA73)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const MarkaziLogo(size: 56, lightMode: true),
                    const SizedBox(height: 24),
                    Text(
                      'Mot de passe oublié',
                      style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _codeRequested
                          ? 'Entrez le code reçu par email et votre nouveau mot de passe.'
                          : 'Entrez votre email, un code de réinitialisation vous sera envoyé.',
                      style: GoogleFonts.cairo(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: 32),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                        ),
                        child: Text(_errorMessage!, style: GoogleFonts.cairo(color: Colors.white, fontSize: 13)),
                      ),
                    if (!_codeRequested) ..._buildRequestStep() else ..._buildResetStep(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRequestStep() {
    return [
      _field(_emailController, 'Email', 'votre.email@exemple.com', Icons.email_outlined),
      const SizedBox(height: 32),
      _submitButton(_isLoading ? 'Envoi...' : 'Envoyer le code', _requestCode),
    ];
  }

  List<Widget> _buildResetStep() {
    return [
      _field(_codeController, 'Code reçu par email', 'Collez le code ici', Icons.pin_outlined),
      const SizedBox(height: 16),
      _field(_passwordController, 'Nouveau mot de passe', 'Au moins 6 caractères', Icons.lock_outline, obscure: true),
      const SizedBox(height: 16),
      _field(_confirmController, 'Confirmer le mot de passe', '', Icons.lock_outline, obscure: true),
      const SizedBox(height: 24),
      _submitButton(_isLoading ? 'Réinitialisation...' : 'Réinitialiser le mot de passe', _resetPassword),
      const SizedBox(height: 12),
      Center(
        child: TextButton(
          onPressed: _isLoading ? null : () => setState(() => _codeRequested = false),
          child: Text(
            "Je n'ai pas reçu de code, recommencer",
            style: GoogleFonts.cairo(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
          ),
        ),
      ),
    ];
  }

  Widget _submitButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
              )
            : Text(label, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, String hint, IconData icon, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          enabled: !_isLoading,
          style: GoogleFonts.cairo(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(color: Colors.white.withValues(alpha: 0.5)),
            prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white, width: 2)),
          ),
        ),
      ],
    );
  }
}
