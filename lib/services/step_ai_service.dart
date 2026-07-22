import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

/// A short, friendly AI coaching note about the user's walking activity.
class StepInsight {
  const StepInsight({required this.message, required this.fromAi});

  final String message;

  /// True when the text came from the Gemini model, false when it fell back to
  /// the on-device rule-based coach.
  final bool fromAi;
}

/// Generates personalized activity guidance for a pregnant user based on their
/// step count.
///
/// Primary path: Firebase AI Logic (Gemini). If that is not configured/enabled
/// or the call fails for any reason, it degrades gracefully to a deterministic
/// on-device coach so the feature always shows something useful.
class StepAiService {
  StepAiService({GenerativeModel? model}) : _model = model;

  GenerativeModel? _model;

  static const _modelName = 'gemini-2.5-flash';

  GenerativeModel _resolveModel() {
    return _model ??= FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 160,
      ),
      systemInstruction: Content.text(
        'You are a warm, encouraging prenatal wellness coach in a pregnancy '
        'app. Give brief, safe activity guidance for pregnant users based on '
        'their daily step count. Keep it to 2 short sentences, upbeat and '
        'non-judgmental. Never give medical diagnoses; suggest resting or '
        'contacting a doctor if steps are unusually high or the user may be '
        'overexerting. Do not use markdown.',
      ),
    );
  }

  Future<StepInsight> insight({
    required int steps,
    required int goal,
    required int trimester,
    required double distanceKm,
  }) async {
    final prompt =
        'Trimester: $trimester. Steps today: $steps. Daily goal: $goal steps '
        '(~${distanceKm.toStringAsFixed(1)} km walked). '
        'Give one motivating, pregnancy-safe tip for the rest of the day.';

    try {
      final response = await _resolveModel().generateContent([
        Content.text(prompt),
      ]);
      final text = response.text?.trim();
      if (text != null && text.isNotEmpty) {
        return StepInsight(message: text, fromAi: true);
      }
    } catch (e) {
      debugPrint('StepAiService: Gemini unavailable, using local coach: $e');
    }

    return StepInsight(
      message: _localCoach(steps: steps, goal: goal, trimester: trimester),
      fromAi: false,
    );
  }

  /// Deterministic fallback used when the model can't be reached.
  String _localCoach({
    required int steps,
    required int goal,
    required int trimester,
  }) {
    final ratio = goal == 0 ? 0.0 : steps / goal;

    if (steps == 0) {
      return 'No steps logged yet today. A gentle 10-minute stroll is a lovely '
          'way to boost your energy and mood — listen to your body and take it slow.';
    }
    if (ratio >= 1.3) {
      return "You've comfortably passed your goal — wonderful! Remember to "
          'hydrate, rest when you feel tired, and avoid overexerting yourself today.';
    }
    if (ratio >= 1.0) {
      return "Goal reached — amazing work! Keep the rest of your day relaxed "
          'and enjoy some well-earned rest with your feet up.';
    }
    if (ratio >= 0.6) {
      final remaining = (goal - steps).clamp(0, goal);
      return "You're most of the way there — about $remaining steps to go. A "
          'short walk after your next meal would get you across the line.';
    }
    if (trimester == 3) {
      return 'Every step counts, especially now. Short, frequent walks are '
          'easier on your body in the third trimester than one long one.';
    }
    return 'Good start! A little movement each hour adds up fast — try a few '
        'gentle walks today and keep water close by.';
  }
}
