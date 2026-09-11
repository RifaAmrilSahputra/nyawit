enum ActivityType { semua, panen, tunas, semprot, pupuk, lainnya }

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.gardenName,
    required this.date,
    required this.amount,
    required this.cost,
    required this.status,
    required this.paymentStatus,
  });

  final String id;
  final ActivityType type;
  final String title;
  final String gardenName;
  final String date;
  final String amount;
  final String cost;
  final String status;
  final String paymentStatus;
}
