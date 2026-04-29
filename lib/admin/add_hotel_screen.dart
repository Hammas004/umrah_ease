import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/hotel.dart';
import '../services/hotel_service.dart';

/// Common hotel amenities available as toggleable chips.
const _kAmenities = [
  'Free Wi-Fi',
  'AC',
  'Breakfast',
  'Shuttle',
  'Prayer Room',
  'Haram View',
  'Gym',
  'Pool',
  'Spa',
  'Laundry',
  'Parking',
  'Restaurant',
  'All Meals',
  'Concierge',
  'Direct Haram Access',
];

/// Screen for adding a new hotel or editing an existing one.
/// Pass [hotel] to enter edit mode; leave null for add mode.
class AddHotelScreen extends ConsumerStatefulWidget {
  const AddHotelScreen({super.key, this.hotel});

  final Hotel? hotel;

  @override
  ConsumerState<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends ConsumerState<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _distanceCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _reviewCountCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _descriptionCtrl;

  late Set<String> _selectedAmenities;
  bool _isLoading = false;

  bool get _isEditMode => widget.hotel != null;

  @override
  void initState() {
    super.initState();
    final h = widget.hotel;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _locationCtrl = TextEditingController(text: h?.location ?? '');
    _distanceCtrl =
        TextEditingController(text: h != null ? h.distanceKm.toString() : '');
    _priceCtrl = TextEditingController(
        text: h != null ? h.pricePerNight.toInt().toString() : '');
    _ratingCtrl =
        TextEditingController(text: h != null ? h.rating.toString() : '');
    _reviewCountCtrl =
        TextEditingController(text: h != null ? h.reviewCount.toString() : '');
    _imageUrlCtrl = TextEditingController(text: h?.imageUrl ?? '');
    _descriptionCtrl = TextEditingController(text: h?.description ?? '');
    _selectedAmenities = Set<String>.from(h?.amenities ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _distanceCtrl.dispose();
    _priceCtrl.dispose();
    _ratingCtrl.dispose();
    _reviewCountCtrl.dispose();
    _imageUrlCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedAmenities.isEmpty) {
      _showSnack('Please select at least one amenity.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final hotel = Hotel(
        id: widget.hotel?.id ?? '',
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        distanceKm: double.parse(_distanceCtrl.text.trim()),
        pricePerNight: double.parse(_priceCtrl.text.trim()),
        currency: 'SAR',
        rating: double.parse(_ratingCtrl.text.trim()),
        reviewCount: int.parse(_reviewCountCtrl.text.trim()),
        amenities: _selectedAmenities.toList(),
        imageUrl: _imageUrlCtrl.text.trim().isNotEmpty
            ? _imageUrlCtrl.text.trim()
            : null,
        description: _descriptionCtrl.text.trim().isNotEmpty
            ? _descriptionCtrl.text.trim()
            : null,
      );

      final service = ref.read(hotelServiceProvider);

      if (_isEditMode) {
        await service.updateHotel(hotel);
        _showSnack('Hotel updated successfully!', success: true);
      } else {
        await service.addHotel(hotel);
        _showSnack('Hotel added successfully!', success: true);
        _clearForm();
      }
    } catch (e) {
      _showSnack('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _nameCtrl.clear();
    _locationCtrl.clear();
    _distanceCtrl.clear();
    _priceCtrl.clear();
    _ratingCtrl.clear();
    _reviewCountCtrl.clear();
    _imageUrlCtrl.clear();
    _descriptionCtrl.clear();
    setState(() => _selectedAmenities = {});
  }

  void _showSnack(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor:
            success ? AppColors.success : AppColors.error,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Hotel' : 'Add Hotel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hotel Details section ──────────────────────────────────
              _SectionHeader('Hotel Details'),
              const SizedBox(height: AppConstants.spaceMD),

              _FormField(
                label: 'Hotel Name',
                controller: _nameCtrl,
                hint: 'e.g. Makkah Clock Royal Tower',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter hotel name.' : null,
              ),
              const SizedBox(height: AppConstants.spaceMD),

              _FormField(
                label: 'City / Location',
                controller: _locationCtrl,
                hint: 'e.g. Makkah',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter city/location.' : null,
              ),
              const SizedBox(height: AppConstants.spaceMD),

              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Distance from Haram (km)',
                      controller: _distanceCtrl,
                      hint: '0.5',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required.';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Enter a valid number.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceMD),
                  Expanded(
                    child: _FormField(
                      label: 'Price / Night (SAR)',
                      controller: _priceCtrl,
                      hint: '500',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required.';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Enter a valid number.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMD),

              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Rating (1–5)',
                      controller: _ratingCtrl,
                      hint: '4.5',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required.';
                        }
                        final n = double.tryParse(v.trim());
                        if (n == null || n < 1 || n > 5) {
                          return 'Enter 1.0–5.0.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceMD),
                  Expanded(
                    child: _FormField(
                      label: 'Review Count',
                      controller: _reviewCountCtrl,
                      hint: '1200',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required.';
                        }
                        if (int.tryParse(v.trim()) == null) {
                          return 'Enter a whole number.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMD),

              _ImageUrlField(controller: _imageUrlCtrl),
              const SizedBox(height: AppConstants.spaceMD),

              // Description
              Text('Description (optional)',
                  style: AppTextStyles.titleSmall),
              const SizedBox(height: AppConstants.spaceSM),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText:
                      'Brief description of the hotel and its surroundings...',
                ),
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── Amenities section ──────────────────────────────────────
              _SectionHeader('Facilities & Amenities'),
              const SizedBox(height: 6),
              Text('Select all that apply',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: AppConstants.spaceMD),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kAmenities
                    .map((amenity) => _AmenityToggleChip(
                          label: amenity,
                          selected: _selectedAmenities.contains(amenity),
                          onToggle: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAmenities.add(amenity);
                              } else {
                                _selectedAmenities.remove(amenity);
                              }
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppConstants.spaceXL),

              // ── Submit button ──────────────────────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                              AppColors.textOnGold),
                        ),
                      )
                    : Text(_isEditMode ? 'UPDATE HOTEL' : 'ADD HOTEL'),
              ),
              const SizedBox(height: AppConstants.spaceLG),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 18, color: AppColors.primaryGold),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint),
          validator: validator,
        ),
      ],
    );
  }
}

// ── Image URL field with live preview ─────────────────────────────────────────

class _ImageUrlField extends StatefulWidget {
  const _ImageUrlField({required this.controller});
  final TextEditingController controller;

  @override
  State<_ImageUrlField> createState() => _ImageUrlFieldState();
}

class _ImageUrlFieldState extends State<_ImageUrlField> {
  String _previewUrl = '';

  @override
  void initState() {
    super.initState();
    _previewUrl = widget.controller.text.trim();
    widget.controller.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUrlChanged);
    super.dispose();
  }

  void _onUrlChanged() {
    final url = widget.controller.text.trim();
    // Only update preview when URL looks complete (starts with http)
    if (url.startsWith('http') || url.isEmpty) {
      setState(() => _previewUrl = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hotel Image URL (optional)',
            style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.url,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            prefixIcon: Icon(Icons.image_outlined),
          ),
        ),
        // Live preview
        if (_previewUrl.isNotEmpty) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppConstants.radiusMD),
            child: Image.network(
              _previewUrl,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 160,
                  color: AppColors.surfaceVariant,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMD),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image_outlined,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Text('Cannot load image — check the URL',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.error)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AmenityToggleChip extends StatelessWidget {
  const _AmenityToggleChip({
    required this.label,
    required this.selected,
    required this.onToggle,
  });

  final String label;
  final bool selected;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!selected),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGold.withValues(alpha: 0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(
            color: selected
                ? AppColors.primaryGold
                : AppColors.divider,
            width: selected ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded,
                  color: AppColors.primaryGold, size: 13),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color:
                    selected ? AppColors.primaryGold : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}