import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../local/database_helper.dart';
import '../models/umrah_guide.dart';

/// Mediates between the local sqflite cache and the Firestore `umrah_guides`
/// collection.  All reads go through the local DB first; Firestore is only
/// consulted when the cache is empty (or an explicit refresh is requested).
class GuideRepository {
  GuideRepository({
    required FirebaseFirestore firestore,
    required DatabaseHelper db,
  })  : _firestore = firestore,
        _db = db;

  final FirebaseFirestore _firestore;
  final DatabaseHelper _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.colUmrahGuides);

  // ── Local ─────────────────────────────────────────────────────────────────

  Future<bool> hasLocalGuides() => _db.hasUmrahGuides();

  Future<List<UmrahGuide>> getLocalGuides() async {
    final rows = await _db.getAllUmrahGuides();
    return rows.map(UmrahGuide.fromMap).toList();
  }

  Future<void> _persistGuides(List<UmrahGuide> guides) =>
      _db.cacheUmrahGuides(guides.map((g) => g.toMap()).toList());

  Future<void> clearLocalGuides() => _db.clearUmrahGuides();

  // ── Remote ────────────────────────────────────────────────────────────────

  Future<List<UmrahGuide>> fetchFromFirestore() async {
    final snap = await _col.orderBy('category').orderBy('step_order').get();
    return snap.docs
        .map((doc) => UmrahGuide.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  // ── Cache-first load ──────────────────────────────────────────────────────

  /// Returns guides from the local cache.  If the cache is empty, fetches from
  /// Firestore; falls back to built-in seed data when offline or Firestore is
  /// empty, so the screen is never blank on first launch.
  Future<List<UmrahGuide>> loadGuides() async {
    // Wrap local DB access in its own try/catch: if the umrah_guides table is
    // missing (stale schema on an existing install), fall through to seed data
    // instead of surfacing a "no such table" crash to the UI.
    try {
      if (await hasLocalGuides()) {
        return await getLocalGuides();
      }
    } catch (_) {}

    try {
      final remote = await fetchFromFirestore();
      if (remote.isNotEmpty) {
        try { await _persistGuides(remote); } catch (_) {}
        return remote;
      }
    } catch (_) {}

    // Firestore unavailable or empty — seed built-in guides and cache them.
    final seeded = _seedGuides();
    try { await _persistGuides(seeded); } catch (_) {}
    return seeded;
  }

  // ── Seed data ─────────────────────────────────────────────────────────────

  List<UmrahGuide> _seedGuides() {
    final now = DateTime.now().toUtc();
    final items = <Map<String, dynamic>>[
      // ── Ihram ──────────────────────────────────────────────────────────────
      {
        'id': 'seed_ihram_1', 'category': 'Ihram', 'step_order': 0,
        'title': 'Intention (Niyyah)',
        'arabic_text': 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً',
        'body': 'Make the intention for Umrah in your heart and recite the Talbiyah. The Niyyah must be made at or before the Miqat.',
      },
      {
        'id': 'seed_ihram_2', 'category': 'Ihram', 'step_order': 1,
        'title': 'Wearing the Ihram Garments',
        'body': 'Men wear two white unstitched sheets (Rida and Izar). Women wear their normal modest clothing. Perform Ghusl and apply no perfume after wearing Ihram.',
      },
      {
        'id': 'seed_ihram_3', 'category': 'Ihram', 'step_order': 2,
        'title': 'The Talbiyah',
        'arabic_text': 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ',
        'body': 'Recite the Talbiyah continuously from the Miqat until you begin Tawaf. Men recite it aloud; women softly.',
      },
      // ── Tawaf ─────────────────────────────────────────────────────────────
      {
        'id': 'seed_tawaf_1', 'category': 'Tawaf', 'step_order': 0,
        'title': 'Entering Masjid Al-Haram',
        'body': 'Enter with your right foot and recite the masjid entrance du\'a. Proceed toward the Kaaba while in a state of Wudu.',
      },
      {
        'id': 'seed_tawaf_2', 'category': 'Tawaf', 'step_order': 1,
        'title': 'Starting Tawaf at the Black Stone',
        'arabic_text': 'بِسْمِ اللَّهِ وَاللَّهُ أَكْبَرُ',
        'body': 'Begin at the Black Stone (Hajar Al-Aswad). If possible, kiss it; otherwise point toward it and say "Bismillah Allahu Akbar". Complete 7 counter-clockwise circuits.',
      },
      {
        'id': 'seed_tawaf_3', 'category': 'Tawaf', 'step_order': 2,
        'title': 'Du\'a Between the Yemeni Corner and Black Stone',
        'arabic_text': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        'body': 'Between the Yemeni corner and the Black Stone, recite this du\'a in each circuit. You may also make personal supplications throughout Tawaf.',
      },
      {
        'id': 'seed_tawaf_4', 'category': 'Tawaf', 'step_order': 3,
        'title': 'Prayer at Maqam Ibrahim',
        'arabic_text': 'وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلًّى',
        'body': 'After completing 7 circuits, pray 2 Rak\'ahs behind Maqam Ibrahim. Recite Surah Al-Kafirun in the first and Surah Al-Ikhlas in the second.',
      },
      // ── Sa\'i ──────────────────────────────────────────────────────────────
      {
        'id': 'seed_sai_1', 'category': 'Sa\'i', 'step_order': 0,
        'title': 'Proceeding to Safa',
        'arabic_text': 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ',
        'body': 'After Tawaf, go to the hill of Safa. Recite this verse when you approach it. Face the Kaaba, raise your hands, and make du\'a.',
      },
      {
        'id': 'seed_sai_2', 'category': 'Sa\'i', 'step_order': 1,
        'title': 'Walking Between Safa and Marwa',
        'body': 'Walk 7 times between Safa and Marwa. Safa to Marwa is one lap; Marwa to Safa is another. Men jog briskly between the green markers; women walk at a normal pace.',
      },
      {
        'id': 'seed_sai_3', 'category': 'Sa\'i', 'step_order': 2,
        'title': 'Du\'a at Marwa',
        'body': 'At each hill, face the Kaaba, raise your hands, and make du\'a. You may recite the same du\'a as at Safa. Sa\'i ends at Marwa on the 7th pass.',
      },
      // ── Halq / Taqsir ──────────────────────────────────────────────────────
      {
        'id': 'seed_halq_1', 'category': 'Halq & Taqsir', 'step_order': 0,
        'title': 'Shaving or Trimming Hair',
        'body': 'Men should shave the entire head (Halq) or trim at least 2.5 cm from all parts (Taqsir). Shaving is preferred. Women trim a fingertip-length from their hair.',
      },
      {
        'id': 'seed_halq_2', 'category': 'Halq & Taqsir', 'step_order': 1,
        'title': 'Coming Out of Ihram',
        'body': 'After Halq or Taqsir, all Ihram restrictions are lifted. You may resume normal clothing, use perfume, and resume all regular activities.',
      },
      // ── Du\'as & Etiquettes ────────────────────────────────────────────────
      {
        'id': 'seed_dua_1', 'category': 'Du\'as & Etiquettes', 'step_order': 0,
        'title': 'Entering Makkah',
        'arabic_text': 'اللَّهُمَّ هَذَا حَرَمُكَ وَأَمْنُكَ فَحَرِّمْنِي عَلَى النَّارِ',
        'body': 'Recite this du\'a when you first see the Kaaba. It is a moment of acceptance — raise your hands and ask Allah for whatever you wish.',
      },
      {
        'id': 'seed_dua_2', 'category': 'Du\'as & Etiquettes', 'step_order': 1,
        'title': 'Drinking Zamzam Water',
        'arabic_text': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا وَاسِعًا وَشِفَاءً مِنْ كُلِّ دَاءٍ',
        'body': 'Face the Kaaba, drink Zamzam in 3 sips, and recite this du\'a. Zamzam is available throughout the Masjid.',
      },
    ];

    return items.map((m) => UmrahGuide(
      id: m['id'] as String,
      title: m['title'] as String,
      category: m['category'] as String,
      body: m['body'] as String,
      arabicText: m['arabic_text'] as String?,
      stepOrder: m['step_order'] as int,
      cachedAt: now,
    )).toList();
  }

  /// Force-refreshes the cache: clears local data, fetches from Firestore, and
  /// re-persists.  Falls back to seed data if Firestore is unreachable so the
  /// screen is never left empty after a failed refresh.
  Future<List<UmrahGuide>> refreshGuides() async {
    try { await clearLocalGuides(); } catch (_) {}
    try {
      final remote = await fetchFromFirestore();
      if (remote.isNotEmpty) {
        try { await _persistGuides(remote); } catch (_) {}
        return remote;
      }
    } catch (_) {}
    final seeded = _seedGuides();
    try { await _persistGuides(seeded); } catch (_) {}
    return seeded;
  }
}
