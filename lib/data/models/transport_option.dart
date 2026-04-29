/// A transport choice shown on the Select Transportation screen.
class TransportOption {
  const TransportOption({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    required this.priceFrom,
    required this.currency,
    required this.icon,
    required this.duration,
  });

  final String id;
  final String type;
  final String label;
  final String description;
  final double priceFrom;
  final String currency;
  final String icon;
  final String duration;

  static const List<TransportOption> mockList = [
    TransportOption(
      id: 't1',
      type: 'shuttle',
      label: 'Haram Shuttle',
      description: 'Comfortable AC coach running every 30 min between your hotel and Masjid Al-Haram.',
      priceFrom: 15,
      currency: 'SAR',
      icon: 'bus',
      duration: '10–20 min',
    ),
    TransportOption(
      id: 't2',
      type: 'taxi',
      label: 'Private Taxi',
      description: 'Door-to-door taxi service. Includes Arabic-speaking driver familiar with pilgrimage routes.',
      priceFrom: 45,
      currency: 'SAR',
      icon: 'taxi',
      duration: '5–15 min',
    ),
    TransportOption(
      id: 't3',
      type: 'metro',
      label: 'Makkah Metro',
      description: 'High-speed rail connecting Haram, Arafat, Muzdalifah and Mina. Hajj season only.',
      priceFrom: 10,
      currency: 'SAR',
      icon: 'train',
      duration: '8–12 min',
    ),
    TransportOption(
      id: 't4',
      type: 'walking',
      label: 'Walking Route',
      description: 'Guided walking path with rest stations and direction signs. Free of charge.',
      priceFrom: 0,
      currency: 'SAR',
      icon: 'walking',
      duration: '15–30 min',
    ),
  ];
}
