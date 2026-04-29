import 'package:cloud_firestore/cloud_firestore.dart';

/// A hotel listing shown on the Select Your Stay screen.
/// Supports both static mock data and Firestore documents.
class Hotel {
  const Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.distanceKm,
    required this.pricePerNight,
    required this.currency,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    this.imageUrl,
    this.description,
    this.createdAt,
  });

  final String id;
  final String name;
  final String location;
  final double distanceKm;
  final double pricePerNight;
  final String currency;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final String? imageUrl;
  final String? description;
  final DateTime? createdAt;

  // ── Firestore serialization ───────────────────────────────────────────────

  factory Hotel.fromMap(Map<String, dynamic> map, String docId) {
    return Hotel(
      id: docId,
      name: map['name'] as String? ?? '',
      location: map['location'] as String? ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      pricePerNight: (map['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'SAR',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      amenities: List<String>.from((map['amenities'] as List?) ?? []),
      imageUrl: map['imageUrl'] as String?,
      description: map['description'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Map used when creating a new document (includes server timestamp).
  Map<String, dynamic> toCreateMap() => {
        'name': name,
        'location': location,
        'distanceKm': distanceKm,
        'pricePerNight': pricePerNight,
        'currency': currency,
        'rating': rating,
        'reviewCount': reviewCount,
        'amenities': amenities,
        if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
        if (description != null && description!.isNotEmpty)
          'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      };

  /// Map used when updating an existing document (preserves original createdAt).
  Map<String, dynamic> toUpdateMap() => {
        'name': name,
        'location': location,
        'distanceKm': distanceKm,
        'pricePerNight': pricePerNight,
        'currency': currency,
        'rating': rating,
        'reviewCount': reviewCount,
        'amenities': amenities,
        if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
        if (description != null && description!.isNotEmpty)
          'description': description,
      };

  Hotel copyWith({
    String? id,
    String? name,
    String? location,
    double? distanceKm,
    double? pricePerNight,
    String? currency,
    double? rating,
    int? reviewCount,
    List<String>? amenities,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
  }) =>
      Hotel(
        id: id ?? this.id,
        name: name ?? this.name,
        location: location ?? this.location,
        distanceKm: distanceKm ?? this.distanceKm,
        pricePerNight: pricePerNight ?? this.pricePerNight,
        currency: currency ?? this.currency,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        amenities: amenities ?? this.amenities,
        imageUrl: imageUrl ?? this.imageUrl,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
      );

  // ── Mock data (used as fallback in development) ───────────────────────────

  static const bool _isProduction = bool.fromEnvironment('IS_PRODUCTION');
  static List<Hotel> get hotels => _isProduction ? [] : mockList;

  static const List<Hotel> mockList = [
    Hotel(
      id: 'h1',
      name: 'Makkah Clock Royal Tower',
      location: 'Makkah',
      distanceKm: 0.2,
      pricePerNight: 850,
      currency: 'SAR',
      rating: 4.8,
      reviewCount: 2341,
      amenities: ['Haram View', 'Breakfast', 'Prayer Room', 'Shuttle'],
      imageUrl:
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=600&fit=crop',
    ),
    Hotel(
      id: 'h2',
      name: 'Hilton Suites Makkah',
      location: 'Makkah',
      distanceKm: 0.5,
      pricePerNight: 620,
      currency: 'SAR',
      rating: 4.6,
      reviewCount: 1892,
      amenities: ['Breakfast', 'Pool', 'Gym', 'Shuttle'],
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&fit=crop',
    ),
    Hotel(
      id: 'h3',
      name: 'Swissôtel Al Maqam',
      location: 'Makkah',
      distanceKm: 0.3,
      pricePerNight: 730,
      currency: 'SAR',
      rating: 4.7,
      reviewCount: 1640,
      amenities: ['Haram View', 'Spa', 'Multiple Restaurants', 'Shuttle'],
      imageUrl:
          'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=600&fit=crop',
    ),
    Hotel(
      id: 'h4',
      name: 'Dar Al Tawhid Intercontinental',
      location: 'Makkah',
      distanceKm: 0.1,
      pricePerNight: 990,
      currency: 'SAR',
      rating: 4.9,
      reviewCount: 3100,
      amenities: ['Direct Haram Access', 'All Meals', 'Concierge', 'Spa'],
      imageUrl:
          'https://images.unsplash.com/photo-1612965607446-25de1684f2b0?w=600&fit=crop',
    ),
    Hotel(
      id: 'h5',
      name: 'Le Méridien Towers Makkah',
      location: 'Makkah',
      distanceKm: 0.8,
      pricePerNight: 480,
      currency: 'SAR',
      rating: 4.4,
      reviewCount: 988,
      amenities: ['Breakfast', 'Free Wi-Fi', 'Shuttle'],
      imageUrl:
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600&fit=crop',
    ),
    Hotel(
      id: 'h6',
      name: 'Mather Al Jawar',
      location: 'Makkah',
      distanceKm: 0.6,
      pricePerNight: 390,
      currency: 'SAR',
      rating: 4.3,
      reviewCount: 754,
      amenities: ['Prayer Room', 'Free Wi-Fi', 'Laundry', 'Shuttle'],
      imageUrl:
          'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=600&fit=crop',
    ),
    Hotel(
      id: 'h7',
      name: 'Voco Makkah',
      location: 'Makkah',
      distanceKm: 0.4,
      pricePerNight: 560,
      currency: 'SAR',
      rating: 4.5,
      reviewCount: 1123,
      amenities: ['Haram View', 'Breakfast', 'Gym', 'Shuttle'],
      imageUrl:
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=600&fit=crop',
    ),
    Hotel(
      id: 'h8',
      name: 'Badar Al Masa Hotel',
      location: 'Makkah',
      distanceKm: 0.9,
      pricePerNight: 320,
      currency: 'SAR',
      rating: 4.2,
      reviewCount: 612,
      amenities: ['Free Wi-Fi', 'Prayer Room', 'Restaurant', 'Parking'],
      imageUrl:
          'https://images.unsplash.com/photo-1596436100371-68c4c99892fc?w=600&fit=crop',
    ),
  ];
}