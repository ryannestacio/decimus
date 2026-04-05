import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/tomas.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _SacredPalette.marianBlue.withValues(alpha: 0.70),
                    const Color(0xFF14263E).withValues(alpha: 0.84),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _SacredBackdropPainter()),
            ),
          ),
          const SafeArea(child: BodyHome()),
        ],
      ),
    );
  }
}

class _SacredPalette {
  static const Color marianBlue = Color(0xFF1F3A5F);
  static const Color ivory = Color(0xFFF7F4EE);
  static const Color matteGold = Color(0xFFC8A96B);
  static const Color graphite = Color(0xFF2B2B2B);
}

class BodyHome extends StatefulWidget {
  const BodyHome({super.key});

  @override
  State<BodyHome> createState() => _BodyHomeState();
}

class _BodyHomeState extends State<BodyHome> {
  bool _showContent = false;

  final List<_MenuItem> _items = const [
    _MenuItem(
      title: 'Recebiveis',
      subtitle: 'Doacoes, dizimo e eventos.',
      icon: Icons.volunteer_activism_outlined,
      route: '/recebiveis',
    ),
    _MenuItem(
      title: 'Despesas',
      subtitle: 'Contas a pagar e gastos em geral.',
      icon: Icons.receipt_long_outlined,
      route: '/despesas',
    ),
    _MenuItem(
      title: 'Devedores',
      subtitle: 'Pagamentos pendentes e quitados.',
      icon: Icons.person_search_outlined,
      route: '/devedores',
    ),
    _MenuItem(
      title: 'Caixa',
      subtitle: 'Resumo financeiro e relatorios.',
      icon: Icons.account_balance_wallet_outlined,
      route: '/caixa',
    ),
    _MenuItem(
      title: 'Mural',
      subtitle: 'Avisos, eventos e missas.',
      icon: Icons.notification_important_outlined,
      route: '/mural',
    ),
  ];

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

  Future<void> _confirmLogout() async {
    final router = GoRouter.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _SacredPalette.ivory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Deseja sair?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: _SacredPalette.graphite,
            ),
          ),
          content: Text(
            'Voce sera desconectado da sua conta atual.',
            style: GoogleFonts.sourceSans3(
              fontSize: 16,
              color: _SacredPalette.graphite,
              height: 1.3,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _SacredPalette.marianBlue,
                textStyle: GoogleFonts.sourceSans3(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Nao'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                router.go('/login');
              },
              style: FilledButton.styleFrom(
                backgroundColor: _SacredPalette.marianBlue,
                foregroundColor: _SacredPalette.ivory,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(
          width: 28,
          height: 28,
          child: CustomPaint(
            painter: _CrossMarkPainter(_SacredPalette.matteGold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Menu principal',
            style: GoogleFonts.playfairDisplay(
              fontSize: 38,
              fontWeight: FontWeight.w600,
              color: _SacredPalette.graphite,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _confirmLogout,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _SacredPalette.marianBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: _SacredPalette.ivory,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(_MenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        elevation: 1.8,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => context.go(item.route),
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _SacredPalette.marianBlue.withValues(alpha: 0.14),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _SacredPalette.matteGold.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: _SacredPalette.marianBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: _SacredPalette.graphite,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _SacredPalette.graphite.withValues(
                            alpha: 0.74,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: _SacredPalette.marianBlue.withValues(alpha: 0.74),
                ),
              ],
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
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
                    width: 1.2,
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
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 8),
                      Text(
                        'Escolha um modulo para continuar sua rotina financeira.',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _SacredPalette.graphite.withValues(
                            alpha: 0.80,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      for (final item in _items) _buildMenuTile(item),
                      const SizedBox(height: 8),
                      Text(
                        '(c) 2026 por Ryan Estacio',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _SacredPalette.graphite.withValues(
                            alpha: 0.64,
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
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
