import 'package:flutter/material.dart';
import 'package:nyawit/data/dummy/activity_dummy.dart';
import 'package:nyawit/models/activity.dart';

class KegiatanPage extends StatefulWidget {
  const KegiatanPage({super.key});

  @override
  State<KegiatanPage> createState() => _KegiatanPageState();
}

class _KegiatanPageState extends State<KegiatanPage> {
  ActivityType selectedFilter = ActivityType.semua;

  @override
  Widget build(BuildContext context) {
    final filteredActivities = selectedFilter == ActivityType.semua
        ? dummyActivities
        : dummyActivities.where((item) => item.type == selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kegiatan'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_rounded)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            children: [
              ActivityFilterBar(
                selected: selectedFilter,
                onChanged: (value) => setState(() => selectedFilter = value),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredActivities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return ActivityCard(item: filteredActivities[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityFilterBar extends StatelessWidget {
  const ActivityFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ActivityType selected;
  final ValueChanged<ActivityType> onChanged;

  static const _filters = [
    ActivityType.semua,
    ActivityType.panen,
    ActivityType.tunas,
    ActivityType.semprot,
    ActivityType.pupuk,
    ActivityType.lainnya,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selectedFilter = filter == selected;

          return ChoiceChip(
            label: Text(_labelFor(filter)),
            selected: selectedFilter,
            onSelected: (_) => onChanged(filter),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  String _labelFor(ActivityType type) {
    switch (type) {
      case ActivityType.semua:
        return 'Semua';
      case ActivityType.panen:
        return 'Panen';
      case ActivityType.tunas:
        return 'Tunas';
      case ActivityType.semprot:
        return 'Semprot';
      case ActivityType.pupuk:
        return 'Pupuk';
      case ActivityType.lainnya:
        return 'Lainnya';
    }
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final typeColor = switch (item.type) {
      ActivityType.panen => Colors.green,
      ActivityType.tunas => Colors.teal,
      ActivityType.semprot => Colors.blue,
      ActivityType.pupuk => Colors.orange,
      ActivityType.lainnya => Colors.grey,
      _ => Colors.black,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  switch (item.type) {
                    ActivityType.panen => Icons.agriculture_rounded,
                    ActivityType.tunas => Icons.eco_rounded,
                    ActivityType.semprot => Icons.local_florist_rounded,
                    ActivityType.pupuk => Icons.grass_rounded,
                    ActivityType.lainnya => Icons.event_note_rounded,
                    _ => Icons.event_note_rounded,
                  },
                  color: typeColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.status,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (item.type == ActivityType.panen) ...[
            _ActivityMeta(label: 'Tanggal', value: item.date),
            _ActivityMeta(label: 'Kebun', value: item.gardenName),
            _ActivityMeta(label: 'Berat panen', value: item.amount),
            _ActivityMeta(label: 'Harga', value: item.cost),
            _ActivityMeta(label: 'Biaya panen', value: item.cost),
            _ActivityMeta(label: 'Status', value: item.status),
          ] else ...[
            _ActivityMeta(label: 'Jenis kegiatan', value: item.title),
            _ActivityMeta(label: 'Kebun', value: item.gardenName),
            _ActivityMeta(label: 'Tanggal', value: item.date),
            _ActivityMeta(label: 'Biaya', value: item.cost),
            _ActivityMeta(
              label: 'Status pembayaran',
              value: item.paymentStatus,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityMeta extends StatelessWidget {
  const _ActivityMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
