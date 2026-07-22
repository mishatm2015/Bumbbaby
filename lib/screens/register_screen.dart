import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onRegister, required this.onSignIn});

  final VoidCallback onRegister;
  final VoidCallback onSignIn;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = AuthService();
  final _users = UserRepository();

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
  final _dobCtrl             = TextEditingController();
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
  bool _loading        = false;
  String _pregnancyType = 'Single';

  @override
  void dispose() {
    for (final c in [
      _fullNameCtrl, _emailCtrl, _phoneCtrl, _passwordCtrl,
      _dobCtrl, _heightCtrl, _weightCtrl, _bloodGroupCtrl,
      _lmpCtrl, _eddCtrl, _prevPregCtrl, _doctorCtrl, _languageCtrl, _notifCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static final _dateFmtRegExp = RegExp(r'^\d{2}/\d{2}/\d{4}$');

  DateTime? _parseDate(String value) {
    final v = value.trim();
    if (!_dateFmtRegExp.hasMatch(v)) return null;
    final parts = v.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    try {
      final d = DateTime(year, month, day);
      if (d.day != day || d.month != month || d.year != year) return null;
      return d;
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? initialDate,
    ValueChanged<DateTime>? onPicked,
  }) async {
    FocusScope.of(context).unfocus();
    final existing = _parseDate(controller.text);
    var initial = existing ?? initialDate ?? DateTime.now();
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _purple),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      controller.text = _formatDate(picked);
      onPicked?.call(picked);
    });
  }

  String? _validate() {
    if (_fullNameCtrl.text.trim().isEmpty) return 'Full name is required.';
    if (_emailCtrl.text.trim().isEmpty) return 'Email is required.';
    if (_passwordCtrl.text.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (_dobCtrl.text.trim().isEmpty) return 'Date of birth is required.';
    if (_parseDate(_dobCtrl.text) == null) {
      return 'Enter date of birth as DD/MM/YYYY.';
    }
    if (_heightCtrl.text.trim().isEmpty) return 'Height is required.';
    if (_weightCtrl.text.trim().isEmpty) return 'Pre-pregnancy weight is required.';
    if (_lmpCtrl.text.trim().isEmpty) return 'LMP date is required.';
    if (_parseDate(_lmpCtrl.text) == null) {
      return 'Enter LMP as DD/MM/YYYY.';
    }
    if (_eddCtrl.text.trim().isNotEmpty && _parseDate(_eddCtrl.text) == null) {
      return 'Enter EDD as DD/MM/YYYY.';
    }
    return null;
  }

  int? _ageFromDob() {
    final dob = _parseDate(_dobCtrl.text);
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age >= 0 ? age : null;
  }

  Future<void> _createAccount() async {
    final error = _validate();
    if (error != null) {
      _showMessage(error);
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await _auth.register(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      final user = cred.user;
      if (user == null) throw Exception('Account created but user is null.');

      await _auth.updateDisplayName(_fullNameCtrl.text);

      final profile = UserProfile(
        uid: user.uid,
        email: _emailCtrl.text.trim(),
        fullName: _fullNameCtrl.text.trim(),
        phone: _optional(_phoneCtrl),
        dateOfBirth: _dobCtrl.text.trim(),
        age: _ageFromDob(),
        height: _heightCtrl.text.trim(),
        prePregnancyWeight: _weightCtrl.text.trim(),
        bloodGroup: _optional(_bloodGroupCtrl),
        lmp: _lmpCtrl.text.trim(),
        edd: _optional(_eddCtrl),
        pregnancyType: _pregnancyType,
        previousPregnancies: int.tryParse(_prevPregCtrl.text.trim()),
        doctorName: _optional(_doctorCtrl),
        language: _optional(_languageCtrl) ?? 'English',
        notificationPrefs: _optional(_notifCtrl),
        createdAt: DateTime.now(),
      );
      await _users.createProfile(profile);

      if (!mounted) return;
      widget.onRegister();
    } catch (e) {
      if (!mounted) return;
      _showMessage(AuthService.messageFor(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _optional(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
                hint: 'Min. 6 characters',
                obscure: _obscurePass,
                inputBg: _inputBg,
                border: _border,
                suffix: _EyeToggle(
                  obscure: _obscurePass,
                  onTap: () => setState(() => _obscurePass = !_obscurePass),
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

              // Date of birth (type or pick from calendar)
              _FL('Date of birth', required: true, sans: sans),
              const SizedBox(height: 6),
              _IF(
                controller: _dobCtrl,
                hint: 'DD/MM/YYYY',
                keyboardType: TextInputType.datetime,
                inputBg: _inputBg,
                border: _border,
                inputFormatters: [_DateTextInputFormatter()],
                suffix: _CalendarButton(
                  labelGrey: _labelGrey,
                  onTap: () => _pickDate(
                    controller: _dobCtrl,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    initialDate: DateTime(DateTime.now().year - 25),
                  ),
                ),
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
                inputFormatters: [_DateTextInputFormatter()],
                suffix: _CalendarButton(
                  labelGrey: _labelGrey,
                  onTap: () => _pickDate(
                    controller: _lmpCtrl,
                    firstDate: DateTime.now().subtract(const Duration(days: 300)),
                    lastDate: DateTime.now(),
                    onPicked: (lmp) {
                      // EDD = LMP + 280 days (Naegele's rule)
                      _eddCtrl.text =
                          _formatDate(lmp.add(const Duration(days: 280)));
                    },
                  ),
                ),
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
                          hint: 'DD/MM/YYYY',
                          keyboardType: TextInputType.datetime,
                          inputBg: _inputBg,
                          border: _border,
                          inputFormatters: [_DateTextInputFormatter()],
                          suffix: _CalendarButton(
                            labelGrey: _labelGrey,
                            onTap: () => _pickDate(
                              controller: _eddCtrl,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 30)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 300)),
                            ),
                          ),
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

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _FL('Language', required: false, sans: sans),
                  const SizedBox(width: 6),
                  _OptionalTag(sans: sans),
                ],
              ),
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
                  onPressed: _loading ? null : _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
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

/// Calendar suffix icon that opens a date picker.
class _CalendarButton extends StatelessWidget {
  const _CalendarButton({required this.onTap, required this.labelGrey});

  final VoidCallback onTap;
  final Color labelGrey;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.calendar_today_outlined,
        size: 20,
        color: labelGrey,
      ),
      onPressed: onTap,
    );
  }
}

/// Formats digits into DD/MM/YYYY as the user types.
class _DateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 8 ? digits.substring(0, 8) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(trimmed[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
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
