/// A single step in a ritual sequence (Tawaf circuit, Ihram instruction, etc.)
class RitualStep {
  const RitualStep({
    required this.ritualGroup,
    required this.stepNumber,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.englishText,
    required this.instructions,
  });

  final String ritualGroup;
  final int stepNumber;
  final String title;
  final String arabicText;
  final String transliteration;
  final String englishText;
  final String instructions;
}
