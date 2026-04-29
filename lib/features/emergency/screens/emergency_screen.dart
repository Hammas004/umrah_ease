import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Emergency Assistance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── SOS button ────────────────────────────────────────────────
            _SosButton(),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Saudi emergency numbers ───────────────────────────────────
            Text('Emergency Numbers', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceSM),
            ..._saudiContacts.map((c) => _ContactCard(contact: c)),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Nearest hospitals ─────────────────────────────────────────
            Text('Nearest Hospitals', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceSM),
            ..._hospitals.map((h) => _HospitalCard(hospital: h)),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Embassies ─────────────────────────────────────────────────
            Text('Embassy Contacts', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceSM),
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceMD),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMD),
                border:
                    Border.all(color: AppColors.cardBorder, width: 0.5),
              ),
              child: Text(
                'Contact your country\'s embassy in Riyadh or consulate in Jeddah for passport, legal, or major medical emergencies. Your travel insurance provider also maintains a 24/7 emergency helpline — check your policy card.',
                style: AppTextStyles.bodyMedium,
              ),
            ),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Safety tips ───────────────────────────────────────────────
            Text('Safety Tips', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceSM),
            _SafetyTips(),

            const SizedBox(height: AppConstants.spaceXL),
          ],
        ),
      ),
    );
  }
}

// ── SOS button ────────────────────────────────────────────────────────────────

class _SosButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calling Saudi Emergency — 911'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: Border.all(color: AppColors.error, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emergency_rounded,
                color: AppColors.error, size: 40),
            const SizedBox(height: AppConstants.spaceSM),
            Text('HOLD FOR SOS — CALL 911',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.error)),
            const SizedBox(height: 4),
            Text('Hold 2 seconds to call Saudi emergency services',
                style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

const _saudiContacts = [
  _Contact(
    label: 'Police',
    number: '999',
    icon: Icons.local_police_rounded,
    color: AppColors.error,
  ),
  _Contact(
    label: 'Ambulance',
    number: '997',
    icon: Icons.local_hospital_rounded,
    color: Color(0xFFE53935),
  ),
  _Contact(
    label: 'Civil Defence (Fire)',
    number: '998',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFF4511E),
  ),
  _Contact(
    label: 'Haj Unified Operations',
    number: '920004848',
    icon: Icons.support_agent_rounded,
    color: AppColors.primaryGold,
  ),
  _Contact(
    label: 'Lost Pilgrim Hotline',
    number: '0114542282',
    icon: Icons.person_search_rounded,
    color: AppColors.primaryGold,
  ),
];

const _hospitals = [
  _Hospital(
      name: 'King Abdulaziz Hospital',
      distance: '1.4 km',
      area: 'Al-Zaher, Makkah'),
  _Hospital(
      name: 'Al-Noor Specialist Hospital',
      distance: '2.1 km',
      area: 'Ibrahim Al-Khalil St, Makkah'),
  _Hospital(
      name: 'Ajyad Emergency Hospital',
      distance: '0.6 km',
      area: 'Adjacent to Masjid Al-Haram'),
];

class _Contact {
  const _Contact(
      {required this.label,
      required this.number,
      required this.icon,
      required this.color});
  final String label;
  final String number;
  final IconData icon;
  final Color color;
}

class _Hospital {
  const _Hospital(
      {required this.name,
      required this.distance,
      required this.area});
  final String name;
  final String distance;
  final String area;
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact});
  final _Contact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSM),
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMD, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: contact.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(contact.icon, color: contact.color, size: 20),
          ),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.label, style: AppTextStyles.titleSmall),
                Text(contact.number, style: AppTextStyles.goldLabel),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Calling ${contact.number}…')),
              );
            },
            icon: const Icon(Icons.call_rounded,
                color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({required this.hospital});
  final _Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSM),
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_hospital_rounded,
              color: AppColors.primaryGold, size: 22),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.name, style: AppTextStyles.titleSmall),
                Text(hospital.area, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(hospital.distance,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.primaryGold)),
          ),
        ],
      ),
    );
  }
}

class _SafetyTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tips = [
      'Stay hydrated — drink 500 ml of water every hour during Tawaf and Sa\'i',
      'Memorise your hotel name, address, and room number in Arabic if possible',
      'Wear an ID wristband with your name, hotel, and group leader\'s number',
      'Keep emergency contacts saved offline in your phone',
      'Never leave children unattended near the Kaaba area',
    ];

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: tips.asMap().entries.map((e) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: e.key < tips.length - 1 ? 10 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: AppColors.primaryGold, size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(e.value,
                        style: AppTextStyles.bodyMedium)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
