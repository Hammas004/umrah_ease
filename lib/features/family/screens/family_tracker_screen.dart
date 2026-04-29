import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FamilyTrackerScreen extends StatefulWidget {
  const FamilyTrackerScreen({super.key});

  @override
  State<FamilyTrackerScreen> createState() =>
      _FamilyTrackerScreenState();
}

class _FamilyTrackerScreenState extends State<FamilyTrackerScreen> {
  final _members = [
    _Member(
        name: 'Ahmed (You)',
        status: 'At Masjid Al-Haram',
        lastSeen: 'Now',
        isOnline: true,
        initials: 'A'),
    _Member(
        name: 'Fatimah',
        status: 'Hotel — Makkah Clock Tower',
        lastSeen: '5 min ago',
        isOnline: true,
        initials: 'F'),
    _Member(
        name: 'Ibrahim',
        status: 'Zamzam Area',
        lastSeen: '12 min ago',
        isOnline: false,
        initials: 'I'),
    _Member(
        name: 'Mariam',
        status: 'Sa\'i Corridor',
        lastSeen: '3 min ago',
        isOnline: true,
        initials: 'M'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Family Safety Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Add member',
            onPressed: () => _showAddMemberDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Map placeholder ─────────────────────────────────────────
          Container(
            height: 200,
            margin: const EdgeInsets.all(AppConstants.spaceMD),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2230),
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
              border: Border.all(color: AppColors.cardBorder, width: 0.5),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_rounded,
                          color: AppColors.textMuted, size: 40),
                      const SizedBox(height: 8),
                      Text('Live Location Map',
                          style: AppTextStyles.bodySmall),
                      Text('Requires GPS & location permission',
                          style: AppTextStyles.labelSmall),
                    ],
                  ),
                ),
                // Mock member pins
                ..._members.asMap().entries.map((e) {
                  final offsets = [
                    const Offset(0.5, 0.5),
                    const Offset(0.7, 0.35),
                    const Offset(0.3, 0.6),
                    const Offset(0.55, 0.7),
                  ];
                  return Positioned(
                    left: MediaQuery.of(context).size.width * offsets[e.key].dx * 0.7,
                    top: 200 * offsets[e.key].dy * 0.7,
                    child: _MapPin(member: e.value),
                  );
                }),
              ],
            ),
          ),

          // ── Member list ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMD),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Group Members', style: AppTextStyles.titleMedium),
                Text('${_members.length} members',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceSM),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMD),
              itemCount: _members.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spaceSM),
              itemBuilder: (_, i) => _MemberCard(member: _members[i]),
            ),
          ),

          // ── SOS ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Send SOS?'),
                    content: const Text(
                        'This will send your GPS location to all family members and emergency contacts.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('SOS sent to family members'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        },
                        child: const Text('Send SOS'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.emergency_rounded),
              label: const Text('Send SOS to Family'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppConstants.spaceMD,
          AppConstants.spaceMD,
          AppConstants.spaceMD,
          MediaQuery.of(ctx).viewInsets.bottom + AppConstants.spaceMD,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Family Member',
                style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceMD),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: 'Member name or phone number'),
            ),
            const SizedBox(height: AppConstants.spaceMD),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Invite sent — requires backend integration')),
                );
              },
              child: const Text('Send Invite'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Member data ───────────────────────────────────────────────────────────────

class _Member {
  const _Member({
    required this.name,
    required this.status,
    required this.lastSeen,
    required this.isOnline,
    required this.initials,
  });
  final String name;
  final String status;
  final String lastSeen;
  final bool isOnline;
  final String initials;
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _MapPin extends StatelessWidget {
  const _MapPin({required this.member});
  final _Member member;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: member.isOnline
                ? AppColors.primaryGold
                : AppColors.surfaceVariant,
            border: Border.all(color: AppColors.backgroundDark, width: 2),
          ),
          child: Center(
            child: Text(member.initials,
                style: AppTextStyles.labelSmall.copyWith(
                    color: member.isOnline
                        ? AppColors.textOnGold
                        : AppColors.textMuted)),
          ),
        ),
        Container(
          width: 2,
          height: 8,
          color: member.isOnline
              ? AppColors.primaryGold
              : AppColors.surfaceVariant,
        ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});
  final _Member member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceVariant,
                  border: Border.all(
                    color: member.isOnline
                        ? AppColors.success
                        : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(member.initials,
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.primaryGold)),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: member.isOnline
                        ? AppColors.success
                        : AppColors.textMuted,
                    border: Border.all(
                        color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppConstants.spaceMD),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.textMuted, size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(member.status,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Last seen
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(member.lastSeen, style: AppTextStyles.labelSmall),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
