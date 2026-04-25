import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Écran de connexion / inscription
class LoginScreen extends StatefulWidget {
  final bool isLogin;

  const LoginScreen({super.key, this.isLogin = true});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _isLogin;
  late PageController _pageController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _markazIdController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
    _pageController = PageController(initialPage: _isLogin ? 0 : 1);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _markazIdController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _switchPage(bool login) {
    setState(() {
      _isLogin = login;
      _errorMessage = null;
    });
    _pageController.animateToPage(
      login ? 0 : 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Tous les champs doivent être remplis');
      return;
    }

    if (!_emailController.text.contains('@')) {
      setState(() => _errorMessage = 'Email invalide');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();

      // Vérifier que markazId n'est pas vide
      const markazId = 'default-markaz'; // À remplacer par UI réelle

      await authService.login(
        email: _emailController.text,
        password: _passwordController.text,
        markazId: markazId,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      String errorMsg = 'Erreur inconnue lors de la connexion';

      try {
        // Essayer de formater le message d'erreur
        final errorStr = e.toString();
        if (errorStr.contains('Exception: ')) {
          errorMsg = errorStr.replaceAll('Exception: ', '');
        } else if (errorStr.isNotEmpty) {
          errorMsg = errorStr;
        }
      } catch (_) {
        // Si on ne peut pas formater, utiliser le message par défaut
        errorMsg = 'Erreur de connexion. Veuillez réessayer.';
      }

      setState(() => _errorMessage = errorMsg);
      print('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Tous les champs doivent être remplis');
      return;
    }

    if (!_emailController.text.contains('@')) {
      setState(() => _errorMessage = 'Email invalide');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();

      // Vérifier que markazId n'est pas vide
      const markazId = 'default-markaz'; // À remplacer par UI réelle

      await authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        markazId: markazId,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      String errorMsg = 'Erreur inconnue lors de la création du compte';

      try {
        // Essayer de formater le message d'erreur
        final errorStr = e.toString();
        if (errorStr.contains('Exception: ')) {
          errorMsg = errorStr.replaceAll('Exception: ', '');
        } else if (errorStr.isNotEmpty) {
          errorMsg = errorStr;
        }
      } catch (_) {
        // Si on ne peut pas formater, utiliser le message par défaut
        errorMsg = 'Erreur lors de la création du compte. Veuillez réessayer.';
      }

      setState(() => _errorMessage = errorMsg);
      print('Register error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A7F55), Color(0xFF2EAA73)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Page view
          SafeArea(
            bottom: false,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildLoginPage(),
                _buildRegisterPage(),
              ],
            ),
          ),

          // Bouton retour (haut gauche)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Logo
            const MarkaziLogo(size: 56, lightMode: true),

            const SizedBox(height: 24),

            // Titre
            Text(
              'Se connecter',
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Accédez à votre compte markaz',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),

            const SizedBox(height: 32),

            // Message d'erreur
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),

            if (_errorMessage != null) const SizedBox(height: 16),

            // Email input
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'votre.email@exemple.com',
              icon: Icons.email_outlined,
              enabled: !_isLoading,
            ),

            const SizedBox(height: 16),

            // Password input
            _buildTextField(
              controller: _passwordController,
              label: 'Mot de passe',
              hint: 'Au moins 6 caractères',
              icon: Icons.lock_outline,
              obscure: true,
              enabled: !_isLoading,
            ),

            const SizedBox(height: 32),

            // Bouton connexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : Text(
                        'Se connecter',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Lien vers inscription
            Center(
              child: GestureDetector(
                onTap: () => _switchPage(false),
                child: RichText(
                  text: TextSpan(
                    text: "Pas encore de compte ? ",
                    style: GoogleFonts.cairo(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    children: [
                      TextSpan(
                        text: 'Créer un compte',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Logo
            const MarkaziLogo(size: 56, lightMode: true),

            const SizedBox(height: 24),

            // Titre
            Text(
              'Créer un compte',
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Rejoignez Markazi en quelques secondes',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),

            const SizedBox(height: 32),

            // Message d'erreur
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),

            if (_errorMessage != null) const SizedBox(height: 16),

            // Nom input
            _buildTextField(
              controller: _nameController,
              label: 'Nom complet',
              hint: 'Ex: Ahmed Ben Ali',
              icon: Icons.person_outline,
              enabled: !_isLoading,
            ),

            const SizedBox(height: 16),

            // Email input
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'votre.email@exemple.com',
              icon: Icons.email_outlined,
              enabled: !_isLoading,
            ),

            const SizedBox(height: 16),

            // Password input
            _buildTextField(
              controller: _passwordController,
              label: 'Mot de passe',
              hint: 'Au moins 6 caractères',
              icon: Icons.lock_outline,
              obscure: true,
              enabled: !_isLoading,
            ),

            const SizedBox(height: 32),

            // Bouton créer compte
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : Text(
                        'Créer un compte',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Lien vers connexion
            Center(
              child: GestureDetector(
                onTap: () => _switchPage(true),
                child: RichText(
                  text: TextSpan(
                    text: "Vous avez déjà un compte ? ",
                    style: GoogleFonts.cairo(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    children: [
                      TextSpan(
                        text: 'Se connecter',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          style: GoogleFonts.cairo(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            suffixIcon: obscure
                ? Icon(
                    Icons.visibility_off,
                    color: Colors.white.withValues(alpha: 0.5),
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
