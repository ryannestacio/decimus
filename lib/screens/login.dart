import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F3A5F), Color(0xFF14263E)],
          ),
        ),
        child: Stack(
          children: const [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _SacredBackdropPainter()),
              ),
            ),
            SafeArea(child: BodyLogin()),
          ],
        ),
      ),
    );
  }
}

class _SacredPalette {
  static const Color marianBlue = Color(0xFF1F3A5F);
  static const Color ivory = Color(0xFFF7F4EE);
  static const Color matteGold = Color(0xFFC8A96B);
  static const Color graphite = Color(0xFF2B2B2B);
  static const Color hopeGreen = Color(0xFF4F7A5A);
}

class BodyLogin extends StatefulWidget {
  const BodyLogin({super.key});

  @override
  State<BodyLogin> createState() => _BodyLoginState();
}

class _BodyLoginState extends State<BodyLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _showContent = true;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validation() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      _showFeedback('Revise os campos destacados antes de entrar.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      context.go('/home');

      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      _showFeedback(_translateFirebaseError(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _translateFirebaseError(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      return 'Nao encontramos uma conta com este e-mail.';
    }
    if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
      return 'Senha invalida. Tente novamente.';
    }
    if (e.code == 'too-many-requests') {
      return 'Muitas tentativas. Aguarde um pouco e tente de novo.';
    }
    return 'Nao foi possivel entrar agora. Tente novamente em instantes.';
  }

  void _showFeedback(String message, {bool isError = true}) {
    if (!mounted) return;

    final backgroundColor =
        isError ? Colors.red.shade700 : _SacredPalette.hopeGreen;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor,
        ),
      );
  }

  Future<void> _openPolicyDialog({
    required String title,
    required String content,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _SacredPalette.ivory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _SacredPalette.graphite,
            ),
          ),
          content: Text(
            content,
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              height: 1.4,
              color: _SacredPalette.graphite,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Fechar',
                style: GoogleFonts.sourceSans3(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _SacredPalette.marianBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isEmailValid(email)) {
      _showFeedback('Informe um e-mail valido para recuperar sua senha.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showFeedback(
        'Enviamos um link de recuperacao para $email.',
        isError: false,
      );
    } on FirebaseAuthException catch (e) {
      _showFeedback(_translateFirebaseError(e));
    }
  }

  bool _isEmailValid(String email) {
    const emailPattern = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
    return RegExp(emailPattern).hasMatch(email);
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: _SacredPalette.marianBlue.withValues(alpha: 0.24),
        width: 1.1,
      ),
    );

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: GoogleFonts.sourceSans3(
        fontSize: 16,
        color: _SacredPalette.graphite.withValues(alpha: 0.50),
      ),
      labelStyle: GoogleFonts.sourceSans3(
        fontSize: 16,
        color: _SacredPalette.graphite.withValues(alpha: 0.75),
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, size: 22, color: _SacredPalette.marianBlue),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _SacredPalette.matteGold,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.8),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _SacredPalette.matteGold.withValues(alpha: 0.7),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.09),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/imagem1login.png',
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) {
                return const DecoratedBox(
                  decoration: BoxDecoration(color: _SacredPalette.ivory),
                  child: Icon(
                    Icons.account_circle_outlined,
                    size: 70,
                    color: _SacredPalette.marianBlue,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
        const SizedBox(
          width: 30,
          height: 30,
          child: CustomPaint(
            painter: _CrossMarkPainter(_SacredPalette.matteGold),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Bem-vindo',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 44,
            fontWeight: FontWeight.w600,
            color: _SacredPalette.graphite,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Que bom ter voce de volta',
          textAlign: TextAlign.center,
          style: GoogleFonts.sourceSans3(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _SacredPalette.graphite.withValues(alpha: 0.80),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _validation,
        style: ElevatedButton.styleFrom(
          elevation: 2.5,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          backgroundColor: _SacredPalette.marianBlue,
          foregroundColor: _SacredPalette.ivory,
          disabledBackgroundColor: _SacredPalette.marianBlue.withValues(
            alpha: 0.80,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child:
              _isLoading
                  ? Row(
                    key: const ValueKey('loading'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _SacredPalette.ivory,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Entrando...',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    'Entrar',
                    key: const ValueKey('label'),
                    style: GoogleFonts.sourceSans3(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _showContent ? 1 : 0,
            curve: Curves.easeOut,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              offset: _showContent ? Offset.zero : const Offset(0, 0.05),
              curve: Curves.easeOut,
              child: Container(
                decoration: BoxDecoration(
                  color: _SacredPalette.ivory.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: _SacredPalette.matteGold.withValues(alpha: 0.45),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SacredPalette.graphite,
                          ),
                          decoration: _inputDecoration(
                            labelText: 'E-mail',
                            hintText: 'seuemail@dominio.com',
                            icon: Icons.alternate_email_rounded,
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Por favor, informe seu e-mail.';
                            }
                            if (!_isEmailValid(text)) {
                              return 'Digite um e-mail valido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SacredPalette.graphite,
                          ),
                          onFieldSubmitted: (_) => _validation(),
                          decoration: _inputDecoration(
                            labelText: 'Senha',
                            hintText: 'Digite sua senha',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _SacredPalette.marianBlue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Por favor, informe sua senha.';
                            }
                            if (text.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres.';
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                _isLoading ? null : _handleForgotPassword,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              foregroundColor: _SacredPalette.marianBlue,
                              textStyle: GoogleFonts.sourceSans3(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Esqueci minha senha'),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildActionButton(),
                        const SizedBox(height: 20),
                        Divider(
                          color: _SacredPalette.marianBlue.withValues(
                            alpha: 0.16,
                          ),
                          thickness: 1,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Ao entrar, voce concorda com nossos',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 16,
                                color: _SacredPalette.graphite.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _openPolicyDialog(
                                  title: 'Termos de uso',
                                  content:
                                      'Utilize o Decimus de forma responsavel, '
                                      'mantendo seus dados corretos e protegendo '
                                      'seu acesso pessoal.',
                                );
                              },
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                foregroundColor: _SacredPalette.marianBlue,
                                textStyle: GoogleFonts.sourceSans3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Termos'),
                            ),
                            Text(
                              'e',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 16,
                                color: _SacredPalette.graphite.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _openPolicyDialog(
                                  title: 'Privacidade',
                                  content:
                                      'Seus dados sao tratados com confidencialidade '
                                      'e utilizados somente para as funcionalidades '
                                      'do aplicativo.',
                                );
                              },
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                foregroundColor: _SacredPalette.marianBlue,
                                textStyle: GoogleFonts.sourceSans3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Privacidade'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '(c) 2026 por Ryan Estacio\nTodos os direitos reservados.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            height: 1.35,
                            color: _SacredPalette.graphite.withValues(
                              alpha: 0.68,
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
        ),
      ),
    );
  }
}

class _CrossMarkPainter extends CustomPainter {
  const _CrossMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.8;

    final centerX = size.width / 2;
    canvas.drawLine(
      Offset(centerX, size.height * 0.1),
      Offset(centerX, size.height * 0.9),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.42),
      Offset(size.width * 0.72, size.height * 0.42),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrossMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SacredBackdropPainter extends CustomPainter {
  const _SacredBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

    final stainedGlassPaint =
        Paint()
          ..color = _SacredPalette.matteGold.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill;

    final outerArch =
        Path()
          ..moveTo(size.width * 0.15, size.height)
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.24,
            size.width * 0.85,
            size.height,
          );
    canvas.drawPath(outerArch, linePaint);

    final innerArch =
        Path()
          ..moveTo(size.width * 0.28, size.height)
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.42,
            size.width * 0.72,
            size.height,
          );
    canvas.drawPath(innerArch, linePaint);

    final stainedGlassLeft =
        Path()
          ..moveTo(size.width * 0.03, size.height * 0.14)
          ..lineTo(size.width * 0.34, size.height * 0.04)
          ..lineTo(size.width * 0.45, size.height * 0.20)
          ..lineTo(size.width * 0.12, size.height * 0.30)
          ..close();
    canvas.drawPath(stainedGlassLeft, stainedGlassPaint);

    final stainedGlassRight =
        Path()
          ..moveTo(size.width * 0.62, size.height * 0.08)
          ..lineTo(size.width * 0.97, size.height * 0.20)
          ..lineTo(size.width * 0.84, size.height * 0.37)
          ..lineTo(size.width * 0.58, size.height * 0.24)
          ..close();
    canvas.drawPath(stainedGlassRight, stainedGlassPaint);

    final crossPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round;

    final crossCenter = Offset(size.width * 0.89, size.height * 0.22);
    canvas.drawLine(
      Offset(crossCenter.dx, crossCenter.dy - 22),
      Offset(crossCenter.dx, crossCenter.dy + 22),
      crossPaint,
    );
    canvas.drawLine(
      Offset(crossCenter.dx - 12, crossCenter.dy - 2),
      Offset(crossCenter.dx + 12, crossCenter.dy - 2),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
