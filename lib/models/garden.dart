class Garden {
  const Garden({
    required this.id,
    required this.name,
    required this.location,
    required this.area,
    required this.treeCount,
    required this.workerCount,
    required this.status,
    required this.defaultTruck,
    required this.shippingMethod,
    required this.weighbridgeLocation,
    required this.lastHarvest,
    required this.monthlyIncome,
    required this.monthlyCost,
  });

  final String id;
  final String name;
  final String location;
  final String area;
  final int treeCount;
  final int workerCount;
  final String status;
  final String defaultTruck;
  final String shippingMethod;
  final String weighbridgeLocation;
  final String lastHarvest;
  final String monthlyIncome;
  final String monthlyCost;
}
