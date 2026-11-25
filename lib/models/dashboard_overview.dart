import 'package:nyawit/models/activity.dart';

class DashboardOverview {
  const DashboardOverview({
    required this.monthLabel,
    required this.harvestThisMonth,
    required this.totalIncome,
    required this.totalCost,
    required this.netProfit,
    required this.lastHarvestGarden,
    required this.lastHarvestDate,
    required this.lastHarvestAmount,
    required this.lastHarvestMethod,
    required this.recentActivities,
    required this.upcomingActivities,
    required this.harvestCostSummary,
    required this.careCostSummary,
    required this.totalGarden,
    required this.totalTrees,
    required this.totalWorker,
    required this.totalTruck,
    required this.averageHarvest,
    required this.unpaidCost,
    required this.hasUnpaidCost,
    required this.totalHarvestTransaction,
    required this.monthLabels,
    required this.productionTrend,
    required this.incomeTrend,
    required this.costTrend,
    required this.gardenPerformance,
    required this.costDistribution,
  });

  final String monthLabel;
  final String harvestThisMonth;
  final String totalIncome;
  final String totalCost;
  final String netProfit;
  final String? lastHarvestGarden;
  final String? lastHarvestDate;
  final String? lastHarvestAmount;
  final String? lastHarvestMethod;
  final List<ActivityItem> recentActivities;
  final List<ActivityItem> upcomingActivities;
  final String harvestCostSummary;
  final String careCostSummary;
  final String totalGarden;
  final String totalTrees;
  final String totalWorker;
  final String totalTruck;
  final String averageHarvest;
  final String unpaidCost;
  final bool hasUnpaidCost;
  final String totalHarvestTransaction;
  final List<String> monthLabels;
  final List<double> productionTrend;
  final List<double> incomeTrend;
  final List<double> costTrend;
  final List<GardenPerformance> gardenPerformance;
  final List<CostDistribution> costDistribution;
}

class GardenPerformance {
  const GardenPerformance({
    required this.name,
    required this.harvest,
    required this.contribution,
  });

  final String name;
  final double harvest;
  final double contribution;
}

class CostDistribution {
  const CostDistribution({required this.name, required this.value});

  final String name;
  final double value;
}
