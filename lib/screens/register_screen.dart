import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onRegister, required this.onSignIn});

  final VoidCallback onRegister;
  final VoidCallback onSignIn;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ── colours ─────────────────────────────────────────────────────────────────
  static const _purple     = Color(0xFF4C3FD4);
  static const _labelGrey  = Color(0xFF6B6570);
  static const _inputBg    = Color(0xFFF3F3F4);
  static const _border     = Color(0xFFE0DEE5);
  static const _darkText   = Color(0xFF1A1A2E);

  // ── controllers ─────────────────────────────────────────────────────────────
  final _fullNameCtrl        = TextEditingController();
  final _emailCtrl           = TextEditingController();
  final _phoneCtrl           = TextEditingController();
  final _passwordCtrl        = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _dobCtrl             = TextEditingController();
  final _ageCtrl             = TextEditingController();
  final _heightCtrl          = TextEditingController();
  final _weightCtrl          = TextEditingController();
  final _bloodGroupCtrl      = TextEditingController();
  final _lmpCtrl             = TextEditingController();
  final _eddCtrl             = TextEditingController();
  final _prevPregCtrl        = TextEditingController();
  final _doctorCtrl          = TextEditingController();
  final _languageCtrl        = TextEditingController();
  final _notifCtrl           = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  String _pregnancyType = 'Single';

  @override
  void dispose() {
    for (final c in [
      _fullNameCtrl, _emailCtrl, _phoneCtrl, _passwordCtrl, _confirmPasswordCtrl,
      _dobCtrl, _ageCtrl, _heightCtrl, _weightCtrl, _bloodGroupCtrl,
      _lmpCtrl, _eddCtrl, _prevPregCtrl, _doctorCtrl, _languageCtrl, _notifCtrl,
    ]) {
      c.dispose();
    }
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
              const SizedBox(height: 32),

              // ── Logo row ──────────────────────────────────────────────────
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
                      color: _darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Headline ──────────────────────────────────────────────────
              Text(
                'Create account',
                style: sans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your pregnancy journey starts here',
                style: sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _labelGrey,
                ),
              ),
              const SizedBox(height: 28),

              // ══════════════════════════════════════════════════════════════
              // SECTION 1 – BASIC INFORMATION
              // ══════════════════════════════════════════════════════════════
              _SectionHeader(
                label: 'BASIC INFORMATION',
                chipLabel: 'Required',
                chipColor: _darkText,
                chipTextColor: Colors.white,
                sans: sans,
              ),
              const SizedBox(height: 16),

              _FL('Full name', required: true, sans: sans),
              const SizedBox(height: 6),
              _IF(
                controller: _fullNameCtrl,
                hint: 'e.g. Priya Nair',
                inputBg: _inputBg,
                border: _border,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              _FL('Email', required: true, sans: sans),
              const SizedBox(height: 6),
              _IF(
                controller: _emailCtrl,
                hint: 'you@email.com',
                keyboardType: TextInputType.emailAddress,
                inputBg: _inputBg,
                border: _border,
              ),
              const SizedBox(height: 16),

              // Phone – optional (shows label tag)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _FL('Phone', required: false, sans: sans),
                  const SizedBox(width: 6),
                  _OptionalTag(sans: sans),
                ],
              ),
              const SizedBox(height: 6),
              _IF(
                controller: _phoneCtrl,
                hint: '+91 …',
                keyboardType: TextInputType.phone,
                inputBg: _inputBg,
                border: _border,
              ),
              const SizedBox(height: 16),

              _FL('Password', required: true, sans: sans),
              const SizedBox(height: 6),
              _IF(
                controller: _passwordCtrl,
                hint: 'Min. 8 characters',
                obscure: _obscurePass,
                inputBg: _inputBg,
                border: _border,
                suffix: _EyeToggle(
                  obscure: _obscurePass,
                  onTap: () => setState(() => _obscurePass = !_obscurePass),
                  labelGrey: _labelGrey,
                ),
              ),
              const SizedBox(height: 16),

              _FL('Confirm password', required: true, sans: sans),
              const SizedBox(height: 6),
              _IF(
                controller: _confirmPasswordCtrl,
                hint: 'Re-enter password',
                obscure: _obscureConfirm,
                inputBg: _inputBg,
                border: _border,
                suffix: _EyeToggle(
                  obscure: _obscureConfirm,
                  onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  labelGrey: _labelGrey,
                ),
              ),
              const SizedBox(height: 28),

              // ══════════════════════════════════════════════════════════════
              // SECTION 2 – PERSONAL HEALTH DETAILS
              // ══════════════════════════════════════════════════════════════
              _SectionHeader(
                label: 'PERSONAL HEALTH DETAILS',
                chipLabel: 'Health profile',
                chipColor: const Color(0xFFFFE0EE),
                chipTextColor: const Color(0xFFD04476),
                sans: sans,
              ),
              const SizedBox(height: 16),

              // DOB + Age row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FL('Date of birth', required: true, sans: sans),
                        const SizedBox(height: 6),
                        _IF(
                          controller: _dobCtrl,
                          hint: 'DD/MM/YYYY',
                          keyboardType: TextInputType.datetime,
                          inputBg: _inputBg,
                          border: _border,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FL('Age', required: true, sans: sans),
                        const SizedBox(height: 6),
                        _IF(
                          controller: _ageCtrl,
                          hint: 'Years',
                          keyboardType: TextInputType.number,
                          inputBg: _inputBg,
                          border: _border,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Height + Weight row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FL('Height', required: true, sans: sans),
                        const SizedBox(height: 6),
                        _IF(
                          controller: _heightCtrl,
                          hint: 'cm / ft',
                          keyboardType: TextInputType.number,
                          inputBg: _inputBg,
                          border: _border,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FL('Pre-preg. weight', required: true, sans: sans),
                        const SizedBox(height: 6),
                        _IF(
                          controller: _weightCtrl,
                          hint: 'kg / lbs',
                          keyboardType: TextInputType.number,
                          inputBg: _inputBg,
                          border: _border,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _FL('Blood group', required: false, sans: sans),
                  const SizedBox(width: 6),
                  _OptionalTag(sans: sans),
                ],
              ),
              const SizedBox(height: 6),
              _IF(
                controller: _bloodGroupCtrl,
                hint: 'A+, B+, O-, etc.',
                inputBg: _inputBg,
                border: _border,
              ),
              const SizedBox(height: 28),

              // ══════════════════════════════════════════════════════════════
              // SECTION 3 – PREGNANCY INFORMATION
              // ══════════════════════════════════════════════════════════════
              _SectionHeader(
                label: 'PREGNANCY INFORMATION',
                chipLabel: 'Tracking',
                chipColor: const Color(0xFFD6F5EE),
                chipTextColor: const Color(0xFF1A8C6A),
                sans: sans,
              ),
              const SizedBox(height: 16),

              _FL('Last menstrual period (LMP)', required: true, sans: sans),
              const SizedBox(height: 6),
              _IF(
                controller: _lmpCtrl,
                hint: 'DD/MM/YYYY',
                keyboardType: TextInputType.datetime,
                inputBg: _inputBg,
                border: _border,
              ),
              const SizedBox(height: 16),

              // EDD + Pregnancy type row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _FL('Due date (EDD)', required: false, sans: sans),
                            const SizedBox(width: 4),
                            _OptionalTag(sans: sans),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _IF(
                          controller: _eddCtrl,
                          hint: 'Auto-calculated',
                          keyboardType: TextInputType.datetime,
                          inputBg: _inputBg,
                          border: _border,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FL('Pregnancy type', required: true, sans: sans),
                        const SizedBox(height: 6),
                        _DropdownField(
                          value: _pregnancyType,
                          items: const ['Single', 'Twins', 'Triplets+'],
                          onChanged: (v) => setState(() => _pregnancyType = v ?? 'Single'),
                          inputBg: _inputBg,
                          border: _border,
                          sans: sans,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _FL('Number of previous pregnancies', required: false, sans: sans),
                  const SizedBox(width: 6),
                  _OptionalTag(sans: sans),
                ],
              ),
              const SizedBox(height: 6),
              _IF(
                controller: _prevPregCtrl,
                hint: '0, 1, 2 …',
                keyboardType: TextInputType.number,
                inputBg: _inputBg,
                border: _border,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _FL('Doctor / midwife name', required: false, sans: sans),
                  const SizedBox(width: 6),
                  _OptionalTag(sans: sans),
                ],
              ),
              const SizedBox(height: 6),
              _IF(
                controller: _doctorCtrl,
                hint: 'Dr. …',
                inputBg: _inputBg,
                border: _border,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 28),

              // ══════════════════════════════════════════════════════════════
              // SECTION 4 – PREFERENCES
              // ══════════════════════════════════════════════════════════════
              _SectionHeader(
                label: 'PREFERENCES',
                chipLabel: 'Customise',
                chipColor: const Color(0xFFFFF3DF),
                chipTextColor: const Color(0xFFB07300),
                sans: sans,
              ),
              const SizedBox(height: 16),

              _FL('Language', required: true, sans: sans),
              const SizedBox(height: 6),
              _IF(
                controller: _languageCtrl,
                hint: 'English / Malayalam / …',
                inputBg: _inputBg,
                border: _border,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _FL('Notification preferences', required: false, sans: sans),
                  const SizedBox(width: 6),
                  _OptionalTag(sans: sans),
                ],
              ),
              const SizedBox(height: 6),
              _IF(
                controller: _notifCtrl,
                hint: 'Daily tips, reminders, alerts',
                inputBg: _inputBg,
                border: _border,
              ),
              const SizedBox(height: 28),

              // ── Disclaimer ────────────────────────────────────────────────
              RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _labelGrey,
                  ),
                  children: [
                    const TextSpan(text: 'By registering you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _purple,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _purple,
                      ),
                    ),
                    const TextSpan(text: '. Health data is stored securely.'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Create account button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Create my account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Sign in link ──────────────────────────────────────────────
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: _labelGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: widget.onSignIn,
                          child: Text(
                            'Sign in',
                            style: GoogleFonts.plusJakartaSans(
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
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ────────────────────────────────────────────────────────────

/// Section header: uppercase label + coloured pill chip.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.chipLabel,
    required this.chipColor,
    required this.chipTextColor,
    required this.sans,
  });

  final String label;
  final String chipLabel;
  final Color chipColor;
  final Color chipTextColor;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? letterSpacing,
  }) sans;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: sans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: const Color(0xFF4C3FD4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            chipLabel,
            style: sans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: chipTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Small grey "optional" tag displayed inline with a field label.
class _OptionalTag extends StatelessWidget {
  const _OptionalTag({required this.sans});

  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
  }) sans;

  @override
  Widget build(BuildContext context) {
    return Text(
      'optional',
      style: sans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFADADB5),
      ),
    );
  }
}

/// Field label with optional red asterisk.
class _FL extends StatelessWidget {
  const _FL(this.label, {required this.required, required this.sans});

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

/// Styled text input field.
class _IF extends StatelessWidget {
  const _IF({
    required this.controller,
    required this.hint,
    required this.inputBg,
    required this.border,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Color inputBg;
  final Color border;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
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

/// Password visibility toggle suffix icon.
class _EyeToggle extends StatelessWidget {
  const _EyeToggle({
    required this.obscure,
    required this.onTap,
    required this.labelGrey,
  });

  final bool obscure;
  final VoidCallback onTap;
  final Color labelGrey;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: labelGrey,
      ),
      onPressed: onTap,
    );
  }
}

/// Styled dropdown for pregnancy type.
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.inputBg,
    required this.border,
    required this.sans,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Color inputBg;
  final Color border;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
  }) sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          style: sans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A2E),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
