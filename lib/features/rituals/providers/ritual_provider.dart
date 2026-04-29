import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/ritual_step.dart';

// ── Static Umrah ritual content ───────────────────────────────────────────────
// These steps are used as the authoritative offline content.
// A future version can pull overrides from cached_rituals / Firestore.

const _umrahSteps = <RitualStep>[
  // ── Niyyah ─────────────────────────────────────────────────────────────────
  RitualStep(
    ritualGroup: 'Niyyah',
    stepNumber: 1,
    title: 'Making the Intention',
    arabicText: 'اللَّهُمَّ إِنِّي أُرِيدُ الْعُمْرَةَ فَيَسِّرْهَا لِي وَتَقَبَّلْهَا مِنِّي',
    transliteration:
        'Allāhumma innī urīdul-\'umrata fa-yassirha lī wa taqabbalhā minnī',
    englishText:
        'O Allah, I intend to perform Umrah, so make it easy for me and accept it from me.',
    instructions:
        'Stand at the Miqat boundary (or in the aircraft if you cross by air). Declare your sincere intention in your heart to perform Umrah solely for the sake of Allah.',
  ),

  // ── Ihram ──────────────────────────────────────────────────────────────────
  RitualStep(
    ritualGroup: 'Ihram',
    stepNumber: 1,
    title: 'Entering the State of Ihram',
    arabicText:
        'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ',
    transliteration:
        'Labbayk Allāhumma labbayk, labbayk lā sharīka laka labbayk, innal-ḥamda wan-ni\'mata laka wal-mulk, lā sharīka lak',
    englishText:
        'Here I am, O Allah, here I am. Here I am, You have no partner, here I am. Verily all praise, grace and sovereignty belong to You. You have no partner.',
    instructions:
        'Perform Ghusl (full bath). Men wear two white unsewn sheets of cloth; women wear their normal modest clothing covering all except face and hands. Pray 2 rak\'ahs Sunnah. Then pronounce the Talbiyah loudly and continue repeating it until you reach the Kaaba.',
  ),

  // ── Tawaf ──────────────────────────────────────────────────────────────────
  RitualStep(
    ritualGroup: 'Tawaf',
    stepNumber: 1,
    title: 'Beginning Tawaf — Facing the Black Stone',
    arabicText: 'بِسْمِ اللهِ، اللهُ أَكْبَرُ',
    transliteration: 'Bismillāh, Allāhu Akbar',
    englishText: 'In the name of Allah, Allah is the Greatest.',
    instructions:
        'Approach the Black Stone (Hajar al-Aswad). If possible, kiss it; otherwise touch it with your right hand or point towards it. Say "Bismillah, Allahu Akbar." Keep the Kaaba on your left. Perform 7 circuits counter-clockwise. Men perform Idhtiba (right shoulder uncovered) and Ramal (brisk walking) in the first 3 circuits.',
  ),
  RitualStep(
    ritualGroup: 'Tawaf',
    stepNumber: 2,
    title: 'Du\'a Between the Yemeni Corner and Black Stone',
    arabicText:
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    transliteration:
        'Rabbanā ātinā fid-dunyā ḥasanatan wa fil-ākhirati ḥasanatan wa qinā \'adhāban-nār',
    englishText:
        'Our Lord, give us good in this world and good in the Hereafter, and save us from the torment of the Fire.',
    instructions:
        'Between the Yemeni Corner (3rd corner) and the Black Stone, recite this du\'a. You may also make personal supplications during the rest of Tawaf. There is no specific du\'a for each circuit — use any dhikr, Qur\'an recitation, or heartfelt supplication.',
  ),
  RitualStep(
    ritualGroup: 'Tawaf',
    stepNumber: 3,
    title: 'Two Rak\'ahs Behind Maqam Ibrahim',
    arabicText:
        'وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّى',
    transliteration: 'Wattakhidhū min maqāmi Ibrāhīma muṣallā',
    englishText:
        '"And take the station of Ibrahim as a place of prayer." (Qur\'an 2:125)',
    instructions:
        'After completing 7 circuits, move to Maqam Ibrahim (the stone bearing Ibrahim\'s footprints). Recite the above verse, then pray 2 rak\'ahs. In the first rak\'ah recite Surah Al-Kafirun after Al-Fatihah; in the second recite Surah Al-Ikhlas. Then drink Zamzam water.',
  ),

  // ── Sa'i ───────────────────────────────────────────────────────────────────
  RitualStep(
    ritualGroup: "Sa'i",
    stepNumber: 1,
    title: 'Starting at Safa',
    arabicText:
        'إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ',
    transliteration: 'Innaṣ-ṣafā wal-marwata min sha\'ā\'irillāh',
    englishText:
        '"Indeed, Safa and Marwa are among the symbols of Allah." (Qur\'an 2:158)',
    instructions:
        'Ascend Mount Safa, face the Kaaba and recite this verse. Then make du\'a and dhikr facing the Kaaba three times, raising hands in supplication. Then begin walking towards Marwa.',
  ),
  RitualStep(
    ritualGroup: "Sa'i",
    stepNumber: 2,
    title: 'Walking & Running — Safa to Marwa',
    arabicText: 'رَبِّ اغْفِرْ وَارْحَمْ، إِنَّكَ أَنتَ الْأَعَزُّ الْأَكْرَمُ',
    transliteration:
        'Rabbigh-fir warḥam, innaka antal-a\'azzul-akram',
    englishText:
        'My Lord, forgive and have mercy. Indeed You are the Most Mighty, the Most Noble.',
    instructions:
        'Men jog briskly between the two green markers (on the valley floor); women walk at a normal pace. Make dhikr, Qur\'an recitation, or personal du\'a throughout. Each trip from Safa to Marwa or Marwa to Safa counts as one circuit. Complete 7 circuits (ending at Marwa).',
  ),

  // ── Halq / Taqsir ──────────────────────────────────────────────────────────
  RitualStep(
    ritualGroup: "Halq / Taqsir",
    stepNumber: 1,
    title: 'Shaving or Trimming the Hair',
    arabicText:
        'اللَّهُمَّ اغْفِرْ لِلْمُحَلِّقِينَ، اللَّهُمَّ اغْفِرْ لِلْمُحَلِّقِينَ، اللَّهُمَّ اغْفِرْ لِلْمُحَلِّقِينَ وَالْمُقَصِّرِينَ',
    transliteration:
        'Allāhumma-ghfir lil-muḥalliqīn (×3)... wal-muqaṣṣirīn',
    englishText:
        'O Allah, forgive those who shave their heads (×3)... and those who trim.',
    instructions:
        'Men shave the entire head (Halq, which is more rewarding) or trim at least one centimetre from all parts of the hair (Taqsir). Women trim the length of a fingertip from their hair — they do not shave. This act marks the completion of Umrah and you exit the state of Ihram. Congratulations — your Umrah is complete!',
  ),
];

// ── State ─────────────────────────────────────────────────────────────────────

class RitualGuideState {
  const RitualGuideState({
    required this.steps,
    required this.currentIndex,
  });

  final List<RitualStep> steps;
  final int currentIndex;

  RitualStep get current => steps[currentIndex];
  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == steps.length - 1;

  double get progressFraction =>
      steps.isEmpty ? 0 : (currentIndex + 1) / steps.length;

  RitualGuideState copyWith({int? currentIndex}) => RitualGuideState(
        steps: steps,
        currentIndex: currentIndex ?? this.currentIndex,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class RitualGuideNotifier extends Notifier<RitualGuideState> {
  @override
  RitualGuideState build() => const RitualGuideState(
        steps: _umrahSteps,
        currentIndex: 0,
      );

  void next() {
    if (!state.isLast) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previous() {
    if (!state.isFirst) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void jumpTo(int index) {
    if (index >= 0 && index < state.steps.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  void reset() => state = state.copyWith(currentIndex: 0);
}

final ritualGuideProvider =
    NotifierProvider<RitualGuideNotifier, RitualGuideState>(
  RitualGuideNotifier.new,
  name: 'ritualGuideProvider',
);

// ── Sa'i counter ──────────────────────────────────────────────────────────────

class SaiCounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    if (state < 7) state++;
  }

  void reset() => state = 0;
}

final saiCounterProvider = NotifierProvider<SaiCounterNotifier, int>(
  SaiCounterNotifier.new,
  name: 'saiCounterProvider',
);
