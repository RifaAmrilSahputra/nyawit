import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nyawit/screens/dashboard/dashboard_page.dart';
import 'package:nyawit/screens/kebun/kebun_page.dart';
import 'package:nyawit/screens/panen/panen_page.dart';
import 'package:nyawit/screens/perawatan/perawatan_page.dart';
import 'package:nyawit/screens/lainnya/lainnya_page.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  // Data icon dan label dipertahankan tanpa perubahan.
  static const List<({IconData unselected, IconData selected, String label})>
  _navItems = [
    (
      unselected: Icons.dashboard_outlined,
      selected: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    (
      unselected: Icons.forest_outlined,
      selected: Icons.forest_rounded,
      label: 'Kebun',
    ),
    (
      unselected: Icons.eco_outlined,
      selected: Icons.eco_rounded,
      label: 'Panen',
    ),
    (
      unselected: Icons.bloodtype_outlined,
      selected: Icons.bloodtype_rounded,
      label: 'Perawatan',
    ),
    (
      unselected: Icons.apps_outlined,
      selected: Icons.apps_rounded,
      label: 'Lainnya',
    ),
  ];

  static const BorderRadius _navigationRadius = BorderRadius.all(
    Radius.circular(30),
  );

  static const BorderRadius _indicatorRadius = BorderRadius.all(
    Radius.circular(24),
  );

  void _onNavigationTap(int index) {
    if (_selectedIndex == index) return;

    HapticFeedback.lightImpact();

    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCurrentPage() {
    return switch (_selectedIndex) {
      0 => const DashboardPage(),
      1 => const KebunPage(),
      2 => const PanenPage(),
      3 => const PerawatanPage(),
      _ => const LainnyaPage(),
    };
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 64,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: _navigationRadius,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(
                    alpha: isDark ? 0.16 : 0.07,
                  ),
                  blurRadius: 20,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
                if (isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: _navigationRadius,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainer.withValues(alpha: 0.96)
                      : colorScheme.surface.withValues(alpha: 0.96),
                  borderRadius: _navigationRadius,
                  border: Border.all(
                    color: isDark
                        ? colorScheme.outline.withValues(alpha: 0.14)
                        : colorScheme.outlineVariant.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = constraints.maxWidth / _navItems.length;

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // Animated selected indicator.
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            left: (_selectedIndex * itemWidth) + 2,
                            top: 1,
                            bottom: 1,
                            width: itemWidth - 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(
                                  alpha: isDark ? 0.88 : 0.82,
                                ),
                                borderRadius: _indicatorRadius,
                              ),
                            ),
                          ),

                          // Navigation buttons.
                          Row(
                            children: List.generate(_navItems.length, (index) {
                              final item = _navItems[index];
                              final isSelected = _selectedIndex == index;

                              return Expanded(
                                child: _NavigationItem(
                                  item: item,
                                  isSelected: isSelected,
                                  colorScheme: colorScheme,
                                  onTap: () => _onNavigationTap(index),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,

      // Halaman tetap diinisialisasi sesuai tab yang dipilih.
      body: _buildCurrentPage(),

      bottomNavigationBar: _buildBottomNavigation(context, colorScheme, isDark),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.item,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  final ({IconData unselected, IconData selected, String label}) item;

  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Icon(
                isSelected ? item.selected : item.unselected,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
