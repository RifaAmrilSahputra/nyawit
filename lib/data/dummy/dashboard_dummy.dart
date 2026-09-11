import 'package:nyawit/models/activity.dart';

class DashboardOverview {
  const DashboardOverview({
    required this.harvestThisMonth,
    required this.totalIncome,
    required this.totalCost,
    required this.netProfit,
    required this.lastHarvest,
    required this.recentActivities,
    required this.upcomingActivities,
    required this.harvestCostSummary,
    required this.careCostSummary,

    // Tambahan dashboard
    required this.totalGarden,
    required this.totalBlock,
    required this.totalWorker,
    required this.totalTruck,
    required this.harvestTarget,
    required this.harvestProgress,
    required this.averageHarvest,
    required this.unpaidCost,
    required this.totalHarvestTransaction,
    required this.productionTrend,
    required this.incomeTrend,
    required this.costTrend,
    required this.gardenPerformance,
    required this.costDistribution,
  });

  final String harvestThisMonth;
  final String totalIncome;
  final String totalCost;
  final String netProfit;

  final String lastHarvest;

  final List<ActivityItem> recentActivities;
  final List<ActivityItem> upcomingActivities;

  final String harvestCostSummary;
  final String careCostSummary;

  // Statistik kebun
  final String totalGarden;
  final String totalBlock;
  final String totalWorker;
  final String totalTruck;

  // Statistik panen
  final String harvestTarget;
  final double harvestProgress;
  final String averageHarvest;
  final String unpaidCost;
  final String totalHarvestTransaction;

  // Data grafik
  final List<double> productionTrend;
  final List<double> incomeTrend;
  final List<double> costTrend;

  // Performa kebun
  final List<GardenPerformance> gardenPerformance;

  // Distribusi biaya
  final List<CostDistribution> costDistribution;
}

class GardenPerformance {
  const GardenPerformance({
    required this.name,
    required this.harvest,
    required this.target,
    required this.progress,
  });

  final String name;
  final double harvest;
  final double target;
  final double progress;
}

class CostDistribution {
  const CostDistribution({required this.name, required this.value});

  final String name;
  final double value;
}

const dashboardOverview = DashboardOverview(
  harvestThisMonth: '18.600 kg',
  totalIncome: 'Rp 248.500.000',
  totalCost: 'Rp 98.750.000',
  netProfit: 'Rp 149.750.000',

  lastHarvest: 'Pabrik Sawit Kaltim • 12 Agustus',

  // ==========================================================
  // AKTIVITAS TERBARU
  // ==========================================================
  recentActivities: [
    ActivityItem(
      id: 'a1',
      type: ActivityType.panen,
      title: 'Panen blok A1',
      gardenName: 'Kebun Balam Jaya',
      date: '12 Agustus 2026',
      amount: '2.480 kg',
      cost: 'Rp 7.200.000',
      status: 'Terkirim',
      paymentStatus: 'Lunas',
    ),

    ActivityItem(
      id: 'a2',
      type: ActivityType.pupuk,
      title: 'Pupuk NPK blok B2',
      gardenName: 'Kebun Balam Jaya',
      date: '10 Agustus 2026',
      amount: '-',
      cost: 'Rp 4.500.000',
      status: 'Selesai',
      paymentStatus: 'Belum dibayar',
    ),

    ActivityItem(
      id: 'a3',
      type: ActivityType.semprot,
      title: 'Semprot hama blok C1',
      gardenName: 'Kebun Sentosa',
      date: '08 Agustus 2026',
      amount: '-',
      cost: 'Rp 2.300.000',
      status: 'Selesai',
      paymentStatus: 'Lunas',
    ),

    ActivityItem(
      id: 'a4',
      type: ActivityType.panen,
      title: 'Panen blok B3',
      gardenName: 'Kebun Sumber Makmur',
      date: '06 Agustus 2026',
      amount: '1.950 kg',
      cost: 'Rp 6.100.000',
      status: 'Terkirim',
      paymentStatus: 'Lunas',
    ),

    ActivityItem(
      id: 'a5',
      type: ActivityType.pupuk,
      title: 'Pemupukan blok A3',
      gardenName: 'Kebun Sentosa',
      date: '04 Agustus 2026',
      amount: '-',
      cost: 'Rp 3.200.000',
      status: 'Selesai',
      paymentStatus: 'Lunas',
    ),
  ],

  // ==========================================================
  // KEGIATAN MENDATANG
  // ==========================================================
  upcomingActivities: [
    ActivityItem(
      id: 'u1',
      type: ActivityType.tunas,
      title: 'Tunas baru blok D4',
      gardenName: 'Kebun Balam Jaya',
      date: '25 Agustus 2026',
      amount: '-',
      cost: 'Rp 1.800.000',
      status: 'Jadwal',
      paymentStatus: 'Menunggu',
    ),

    ActivityItem(
      id: 'u2',
      type: ActivityType.lainnya,
      title: 'Inspeksi alat panen',
      gardenName: 'Kebun Sumber Makmur',
      date: '27 Agustus 2026',
      amount: '-',
      cost: 'Rp 900.000',
      status: 'Direncanakan',
      paymentStatus: 'Menunggu',
    ),

    ActivityItem(
      id: 'u3',
      type: ActivityType.pupuk,
      title: 'Pemupukan blok C2',
      gardenName: 'Kebun Sentosa',
      date: '29 Agustus 2026',
      amount: '-',
      cost: 'Rp 3.500.000',
      status: 'Jadwal',
      paymentStatus: 'Menunggu',
    ),
  ],

  // ==========================================================
  // BIAYA
  // ==========================================================
  harvestCostSummary: 'Rp 31.400.000',
  careCostSummary: 'Rp 18.650.000',

  // ==========================================================
  // DATA UMUM
  // ==========================================================
  totalGarden: '3',
  totalBlock: '24',
  totalWorker: '18',
  totalTruck: '4',

  // ==========================================================
  // PANEN
  // ==========================================================
  harvestTarget: '22.000 kg',
  harvestProgress: 0.845,
  averageHarvest: '2.325 kg',
  unpaidCost: 'Rp 8.700.000',
  totalHarvestTransaction: '8 kali',

  // ==========================================================
  // GRAFIK PRODUKSI
  // Senin - Minggu
  // ==========================================================
  productionTrend: [2100, 2450, 1980, 2760, 2250, 2910, 2680],

  // Pendapatan mingguan
  incomeTrend: [28, 35, 31, 42, 38, 41, 44],

  // Biaya mingguan
  costTrend: [13, 15, 12, 18, 14, 16, 11],

  // ==========================================================
  // PERFORMA KEBUN
  // ==========================================================
  gardenPerformance: [
    GardenPerformance(
      name: 'Balam Jaya',
      harvest: 8200,
      target: 9500,
      progress: 0.863,
    ),

    GardenPerformance(
      name: 'Sentosa',
      harvest: 6100,
      target: 7000,
      progress: 0.871,
    ),

    GardenPerformance(
      name: 'Sumber Makmur',
      harvest: 4300,
      target: 5500,
      progress: 0.782,
    ),
  ],

  // ==========================================================
  // DISTRIBUSI BIAYA
  // ==========================================================
  costDistribution: [
    CostDistribution(name: 'Panen', value: 31.4),

    CostDistribution(name: 'Perawatan', value: 18.65),

    CostDistribution(name: 'Pupuk', value: 12.5),

    CostDistribution(name: 'Semprot', value: 8.2),

    CostDistribution(name: 'Lainnya', value: 5.4),
  ],
);
