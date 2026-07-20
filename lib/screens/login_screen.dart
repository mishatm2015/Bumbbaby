import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  /// Called when the user taps Sign In or Continue with Google.
  final VoidCallback onLogin;

  /// Called when the user taps "Register here".
  final VoidCallback onRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  static const _purple = Color(0xFF4C3FD4);
  static const _labelGrey = Color(0xFF6B6570);
  static const _inputBg = Color(0xFFF3F3F4);
  static const _border = Color(0xFFE0DEE5);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36),

              // ── Logo row ──────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('🌸', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'MamaBloom',
                    style: sans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // ── Headline ──────────────────────────────────────
              Text(
                'Welcome back',
                style: sans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to your account',
                style: sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _labelGrey,
                ),
              ),
              const SizedBox(height: 32),

              // ── Section label ─────────────────────────────────
              Text(
                'LOGIN DETAILS',
                style: sans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: _purple,
                ),
              ),
              const SizedBox(height: 14),

              // ── Email field ───────────────────────────────────
              _FieldLabel('Email address', required: true, sans: sans),
              const SizedBox(height: 6),
              _InputField(
                controller: _emailCtrl,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                inputBg: _inputBg,
                border: _border,
              ),
              const SizedBox(height: 18),

              // ── Password field ────────────────────────────────
              _FieldLabel('Password', required: true, sans: sans),
              const SizedBox(height: 6),
              _InputField(
                controller: _passwordCtrl,
                hint: '••••••••',
                obscure: _obscure,
                inputBg: _inputBg,
                border: _border,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: _labelGrey,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),

              // ── Forgot password ───────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _purple,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Sign in button ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Sign in',
                    style: sans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Divider ───────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE0DEE5))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: sans(
                        fontSize: 13,
                        color: _labelGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0DEE5))),
                ],
              ),
              const SizedBox(height: 20),

              // ── Google button ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: widget.onLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A2E),
                    side: const BorderSide(color: Color(0xFFE0DEE5), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Simple G logo
                      const _GoogleIcon(),
                      const SizedBox(width: 10),
                      Text(
                        'Continue with Google',
                        style: sans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Register link ─────────────────────────────────
              Center(
                child: RichText(
                  text: TextSpan(
                    style: sans(
                      fontSize: 13,
                      color: _labelGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: 'No account? '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: widget.onRegister,
                          child: Text(
                            'Register here',
                            style: sans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _purple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, {required this.required, required this.sans});

  final String label;
  final bool required;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
  }) sans;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: sans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
        children: [
          TextSpan(text: label),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFE85A5A)),
            ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.inputBg,
    required this.border,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Color inputBg;
  final Color border;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFFADADB5),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: inputBg,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4C3FD4), width: 1.5),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GPainter()),
    );
  }
}

class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    void arc(double start, double sweep, Color color) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..strokeWidth = size.width * 0.22
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt,
      );
    }

    const pi = 3.1415926535;
    arc(-pi / 4, pi / 2, const Color(0xFF4285F4));       // blue right
    arc(pi / 4, pi / 2, const Color(0xFF34A853));        // green bottom
    arc(3 * pi / 4, pi / 2, const Color(0xFFFBBC05));   // yellow left
    arc(5 * pi / 4, pi / 2, const Color(0xFFEA4335));   // red top

    // White fill for interior
    canvas.drawCircle(
      center,
      r * 0.56,
      Paint()..color = Colors.white,
    );

    // Inner blue arc for the "G" cut
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.38, size.width * 0.5, size.height * 0.24),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_GPainter _) => false;
}
