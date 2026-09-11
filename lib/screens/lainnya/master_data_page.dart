import 'package:flutter/material.dart';
import 'package:nyawit/models/pekerja.dart';
import 'package:nyawit/models/produk.dart';
import 'package:nyawit/models/truk.dart';
import 'package:nyawit/models/lokasi_timbang.dart';
import 'package:nyawit/providers/master_data_provider.dart';

// ============================================================
// CONSTANT
// ============================================================

const Color _primaryGreen = Color(0xFF176B3A);
const Color _darkGreen = Color(0xFF0E4F2A);
const Color _lightGreen = Color(0xFFEAF5ED);
const Color _background = Color(0xFFF5F7F5);
const Color _textPrimary = Color(0xFF172019);
const Color _textSecondary = Color(0xFF7B847D);

// ============================================================
// PEKERJA PAGE
// ============================================================

class PekerjaPage extends StatefulWidget {
  const PekerjaPage({super.key});

  @override
  State<PekerjaPage> createState() => _PekerjaPageState();
}

class _PekerjaPageState extends State<PekerjaPage> {
  final PekerjaController _controller = PekerjaController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _controller.load();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MasterPage<Pekerja>(
      title: 'Pekerja',
      headerTitle: 'Data Pekerja',
      headerSubtitle: 'Kelola tenaga kerja perkebunan',
      icon: Icons.engineering_rounded,
      isLoading: _controller.isLoading,
      error: _controller.error,
      items: _controller.items,
      onRetry: _controller.load,
      onAdd: () => _edit(),
      itemTitle: (item) => item.nama,
      itemSubtitle: (item) =>
          '${item.noHp ?? 'No. HP belum diisi'} • ${item.alamat ?? 'Alamat belum diisi'}',
      itemStatus: (item) => item.status,
      onEdit: _edit,
      onDelete: (item) => _remove(item.id!),
      showBack: true,
    );
  }

  Future<void> _edit([Pekerja? item]) async {
    final result = await showModalBottomSheet<Pekerja>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PekerjaSheet(item: item),
    );

    if (result != null) {
      await _controller.save(result);
    }
  }

  Future<void> _remove(int id) async {
    if (await _confirmDelete(context, 'pekerja')) {
      await _controller.delete(id);
    }
  }
}

// ============================================================
// PRODUK PAGE
// ============================================================

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final ProdukController _controller = ProdukController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _controller.load();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MasterPage<Produk>(
      title: 'Produk',
      headerTitle: 'Data Produk',
      headerSubtitle: 'Kelola produk pupuk dan bahan perawatan',
      icon: Icons.inventory_2_rounded,
      isLoading: _controller.isLoading,
      error: _controller.error,
      items: _controller.items,
      onRetry: _controller.load,
      onAdd: () => _edit(),
      itemTitle: (item) => item.nama,
      itemSubtitle: (item) =>
          '${item.jenis} • ${item.satuanDefault} • ${item.aktif ? 'Aktif' : 'Nonaktif'}',
      itemStatus: (item) => item.aktif ? 'Aktif' : 'Nonaktif',
      onEdit: _edit,
      onDelete: (item) => _remove(item.id!),
      showBack: true,
    );
  }

  Future<void> _edit([Produk? item]) async {
    final result = await showModalBottomSheet<Produk>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProdukSheet(item: item),
    );

    if (result != null) {
      await _controller.save(result);
    }
  }

  Future<void> _remove(int id) async {
    if (await _confirmDelete(context, 'produk')) {
      await _controller.delete(id);
    }
  }
}

// ============================================================
// TRUK PAGE
// ============================================================

class TrukPage extends StatefulWidget {
  const TrukPage({super.key});

  @override
  State<TrukPage> createState() => _TrukPageState();
}

class _TrukPageState extends State<TrukPage> {
  final TrukController _controller = TrukController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _controller.load();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MasterPage<Truk>(
      title: 'Truk',
      headerTitle: 'Data Truk',
      headerSubtitle: 'Kelola kendaraan operasional',
      icon: Icons.local_shipping_rounded,
      isLoading: _controller.isLoading,
      error: _controller.error,
      items: _controller.items,
      onRetry: _controller.load,
      onAdd: () => _edit(),
      itemTitle: (item) => item.jenis,
      itemSubtitle: (item) =>
          'Supir: ${item.namaSupir} • ${item.noHp ?? 'No. HP belum diisi'}',
      itemStatus: (item) => item.status,
      onEdit: _edit,
      onDelete: (item) => _remove(item.id!),
      showBack: true,
    );
  }

  Future<void> _edit([Truk? item]) async {
    final result = await showModalBottomSheet<Truk>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TrukSheet(item: item),
    );

    if (result != null) {
      await _controller.save(result);
    }
  }

  Future<void> _remove(int id) async {
    if (await _confirmDelete(context, 'truk')) {
      await _controller.delete(id);
    }
  }
}

// ============================================================
// LOKASI TIMBANG PAGE
// ============================================================

class LokasiTimbangPage extends StatefulWidget {
  const LokasiTimbangPage({super.key});

  @override
  State<LokasiTimbangPage> createState() => _LokasiTimbangPageState();
}

class _LokasiTimbangPageState extends State<LokasiTimbangPage> {
  final LokasiTimbangController _controller = LokasiTimbangController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _controller.load();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MasterPage<LokasiTimbang>(
      title: 'Lokasi Timbang',
      headerTitle: 'Lokasi Timbang',
      headerSubtitle: 'Kelola pos timbang dan titik distribusi',
      icon: Icons.scale_rounded,
      isLoading: _controller.isLoading,
      error: _controller.error,
      items: _controller.items,
      onRetry: _controller.load,
      onAdd: () => _edit(),
      itemTitle: (item) => item.nama,
      itemSubtitle: (item) =>
          '${item.jenis.name} • ${item.alamat ?? 'Alamat belum diisi'}',
      itemStatus: (item) => item.aktif ? 'Aktif' : 'Nonaktif',
      onEdit: _edit,
      onDelete: (item) => _remove(item.id!),
      showBack: true,
    );
  }

  Future<void> _edit([LokasiTimbang? item]) async {
    final result = await showModalBottomSheet<LokasiTimbang>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LokasiTimbangSheet(item: item),
    );

    if (result != null) {
      await _controller.save(result);
    }
  }

  Future<void> _remove(int id) async {
    if (await _confirmDelete(context, 'lokasi timbang')) {
      await _controller.delete(id);
    }
  }
}

// ============================================================
// MASTER PAGE
// ============================================================

class _MasterPage<T> extends StatefulWidget {
  const _MasterPage({
    required this.title,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.icon,
    required this.items,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onAdd,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.itemStatus,
    required this.onEdit,
    required this.onDelete,
    this.showBack = false,
  });

  final String title;
  final String headerTitle;
  final String headerSubtitle;
  final IconData icon;

  final List<T> items;
  final bool isLoading;
  final Object? error;

  final Future<void> Function() onRetry;
  final VoidCallback onAdd;

  final String Function(T) itemTitle;
  final String Function(T) itemSubtitle;
  final String Function(T) itemStatus;

  final Future<void> Function(T) onEdit;
  final Future<void> Function(T) onDelete;
  final bool showBack;

  @override
  State<_MasterPage<T>> createState() => _MasterPageState<T>();
}

class _MasterPageState<T> extends State<_MasterPage<T>> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> _filteredItems() {
    if (_searchQuery.isEmpty) {
      return widget.items;
    }

    return widget.items.where((item) {
      final title = widget.itemTitle(item).toLowerCase();
      final subtitle = widget.itemSubtitle(item).toLowerCase();

      return title.contains(_searchQuery) || subtitle.contains(_searchQuery);
    }).toList();
  }

  int _activeCount() {
    return widget.items.where((item) {
      return widget.itemStatus(item).toLowerCase() == 'aktif';
    }).length;
  }

  int _inactiveCount() {
    return widget.items.length - _activeCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(child: _buildContent()),
      floatingActionButton:
          widget.items.isNotEmpty && !widget.isLoading && widget.error == null
          ? FloatingActionButton.extended(
              onPressed: widget.onAdd,
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Tambah',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const _LoadingView();
    }

    if (widget.error != null) {
      return _ErrorView(onRetry: widget.onRetry);
    }

    if (widget.items.isEmpty) {
      return _EmptyMaster(
        icon: widget.icon,
        title: widget.title,
        onAdd: widget.onAdd,
      );
    }

    final filtered = _filteredItems();

    return RefreshIndicator(
      color: _primaryGreen,
      onRefresh: widget.onRetry,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildTopBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHero(),
                const SizedBox(height: 16),
                _buildSearch(),
                const SizedBox(height: 18),
                _buildSectionHeader(filtered.length),
                const SizedBox(height: 10),
                if (filtered.isEmpty)
                  const _NoSearchResult()
                else
                  ...filtered.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MasterTile<T>(
                        item: item,
                        icon: widget.icon,
                        title: widget.itemTitle(item),
                        subtitle: widget.itemSubtitle(item),
                        status: widget.itemStatus(item),
                        onEdit: () => widget.onEdit(item),
                        onDelete: () => widget.onDelete(item),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TOP BAR
  // ==========================================================

  Widget _buildTopBar() {
    return SliverAppBar(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 68,
      titleSpacing: 20,
      title: Row(
        children: [
          if (widget.showBack)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: _textPrimary,
              ),
            ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(widget.icon, color: _primaryGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Master data',
                style: const TextStyle(fontSize: 11, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryGreen, _darkGreen],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -35,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 45,
            bottom: -75,
            child: Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Data',
                          style: TextStyle(
                            color: Color(0xFFBFE0CA),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Kelola data dengan mudah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 21),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      value: '${widget.items.length}',
                      label: 'Total',
                    ),
                  ),
                  _HeroDivider(),
                  Expanded(
                    child: _HeroStat(
                      value: '${_activeCount()}',
                      label: 'Aktif',
                    ),
                  ),
                  _HeroDivider(),
                  Expanded(
                    child: _HeroStat(
                      value: '${_inactiveCount()}',
                      label: 'Nonaktif',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  Widget _buildSearch() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E9E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari ${widget.title.toLowerCase()}...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9AA19C)),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _primaryGreen,
            size: 21,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: _searchController.clear,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: _textSecondary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SECTION HEADER
  // ==========================================================

  Widget _buildSectionHeader(int count) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Daftar Data',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: _textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _lightGreen,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count data',
            style: const TextStyle(
              color: _primaryGreen,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HERO STAT
// ============================================================

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB9D9C3),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      color: Colors.white.withValues(alpha: 0.13),
    );
  }
}

// ============================================================
// MASTER TILE
// ============================================================

class _MasterTile<T> extends StatelessWidget {
  const _MasterTile({
    required this.item,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onEdit,
    required this.onDelete,
  });

  final T item;
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final active = status.toLowerCase() == 'aktif';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE5EAE6)),
          ),
          child: Row(
            children: [
              // ICON
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: _primaryGreen, size: 23),
              ),

              const SizedBox(width: 13),

              // CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusBadge(status: status, active: active),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              // MENU
              PopupMenuButton<String>(
                tooltip: 'Menu',
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF8A938C),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  }

                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 19,
                          color: _primaryGreen,
                        ),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Hapus'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.active});

  final String status;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final background = active
        ? const Color(0xFFE7F5EB)
        : const Color(0xFFFFF1DF);

    final foreground = active
        ? const Color(0xFF238047)
        : const Color(0xFFB27008);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: foreground,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyMaster extends StatelessWidget {
  const _EmptyMaster({
    required this.icon,
    required this.title,
    required this.onAdd,
  });

  final IconData icon;
  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: _lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: _primaryGreen),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada $title',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Belum ada data yang tersedia.\nTambahkan data pertama untuk memulai.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Tambah Data',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// NO SEARCH RESULT
// ============================================================

class _NoSearchResult extends StatelessWidget {
  const _NoSearchResult();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 45),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF0ED),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: Color(0xFF8A938C),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Data tidak ditemukan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'Coba gunakan kata pencarian yang berbeda.',
            style: TextStyle(fontSize: 11, color: _textSecondary),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: _primaryGreen));
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 35,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Gagal memuat data',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Terjadi masalah saat mengambil data.\nSilakan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryGreen,
                side: const BorderSide(color: _primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CONFIRM DELETE
// ============================================================

Future<bool> _confirmDelete(BuildContext context, String label) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade500,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Hapus Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus $label ini?\n\n'
            'Data yang sudah dihapus tidak dapat dikembalikan.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: _textSecondary,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: _textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 5),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ) ??
      false;
}

// ============================================================
// PEKERJA SHEET
// ============================================================

class _PekerjaSheet extends StatefulWidget {
  const _PekerjaSheet({this.item});

  final Pekerja? item;

  @override
  State<_PekerjaSheet> createState() => _PekerjaSheetState();
}

class _PekerjaSheetState extends State<_PekerjaSheet> {
  final _key = GlobalKey<FormState>();

  late final TextEditingController _nama;
  late final TextEditingController _noHp;
  late final TextEditingController _alamat;
  late final TextEditingController _keterangan;

  late String _status;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _nama = TextEditingController(text: item?.nama);

    _noHp = TextEditingController(text: item?.noHp);

    _alamat = TextEditingController(text: item?.alamat);

    _keterangan = TextEditingController(text: item?.keterangan);

    _status = item?.status ?? 'Aktif';
  }

  @override
  void dispose() {
    _nama.dispose();
    _noHp.dispose();
    _alamat.dispose();
    _keterangan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),

              const SizedBox(height: 22),

              _SheetHeader(
                icon: Icons.engineering_rounded,
                title: isEdit ? 'Edit Pekerja' : 'Tambah Pekerja',
                subtitle: 'Masukkan informasi pekerja perkebunan.',
              ),

              const SizedBox(height: 24),

              _field(
                controller: _nama,
                label: 'Nama pekerja',
                hint: 'Contoh: Ahmad',
                icon: Icons.person_outline_rounded,
                required: true,
              ),

              _field(
                controller: _noHp,
                label: 'Nomor HP',
                hint: 'Contoh: 08123456789',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              _field(
                controller: _alamat,
                label: 'Alamat',
                hint: 'Masukkan alamat pekerja',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),

              _statusField(),

              _field(
                controller: _keterangan,
                label: 'Keterangan',
                hint: 'Catatan tambahan',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 8),

              _saveButton(
                label: isEdit ? 'Simpan Perubahan' : 'Tambah Pekerja',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: DropdownButtonFormField<String>(
        initialValue: _status,
        decoration: _inputDecoration(
          label: 'Status',
          icon: Icons.toggle_on_outlined,
        ),
        items: const [
          DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
          DropdownMenuItem(value: 'Nonaktif', child: Text('Nonaktif')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _status = value;
            });
          }
        },
      ),
    );
  }

  void _submit() {
    if (!_key.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();

    Navigator.pop(
      context,
      Pekerja(
        id: widget.item?.id,
        nama: _nama.text.trim(),
        noHp: _optional(_noHp),
        alamat: _optional(_alamat),
        status: _status,
        keterangan: _optional(_keterangan),
        createdAt: widget.item?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(label: label, hint: hint, icon: icon),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wajib diisi';
                }

                return null;
              }
            : null,
      ),
    );
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();

    return value.isEmpty ? null : value;
  }
}

// ============================================================
// PRODUK SHEET
// ============================================================

class _ProdukSheet extends StatefulWidget {
  const _ProdukSheet({this.item});

  final Produk? item;

  @override
  State<_ProdukSheet> createState() => _ProdukSheetState();
}

class _ProdukSheetState extends State<_ProdukSheet> {
  final _key = GlobalKey<FormState>();

  late final TextEditingController _nama;
  late final TextEditingController _satuan;
  late final TextEditingController _keterangan;

  late String _jenis;
  late bool _aktif;

  @override
  void initState() {
    super.initState();

    final item = widget.item;
    _nama = TextEditingController(text: item?.nama);
    _satuan = TextEditingController(text: item?.satuanDefault);
    _keterangan = TextEditingController(text: item?.keterangan);
    _jenis = item?.jenis ?? 'pupuk';
    _aktif = item?.aktif ?? true;
  }

  @override
  void dispose() {
    _nama.dispose();
    _satuan.dispose();
    _keterangan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 22),
              _SheetHeader(
                icon: Icons.inventory_2_rounded,
                title: isEdit ? 'Edit Produk' : 'Tambah Produk',
                subtitle: 'Kelola master data produk perawatan kebun.',
              ),
              const SizedBox(height: 24),
              _field(
                controller: _nama,
                label: 'Nama produk',
                hint: 'Contoh: Pupuk NPK',
                icon: Icons.label_important_outline_rounded,
                required: true,
              ),
              _jenisField(),
              _field(
                controller: _satuan,
                label: 'Satuan default',
                hint: 'Contoh: sak, kg, liter',
                icon: Icons.straighten_rounded,
                required: true,
              ),
              _statusSwitch(),
              _field(
                controller: _keterangan,
                label: 'Keterangan',
                hint: 'Catatan tambahan',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              _saveButton(
                label: isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jenisField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: DropdownButtonFormField<String>(
        initialValue: _jenis,
        decoration: _inputDecoration(
          label: 'Jenis produk',
          icon: Icons.category_outlined,
        ),
        items: const [
          DropdownMenuItem(value: 'pupuk', child: Text('Pupuk')),
          DropdownMenuItem(value: 'semprot', child: Text('Semprot')),
          DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _jenis = value;
            });
          }
        },
      ),
    );
  }

  Widget _statusSwitch() {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E7E3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _aktif ? const Color(0xFFE4F3E9) : const Color(0xFFECEFED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _aktif
                  ? Icons.check_circle_outline_rounded
                  : Icons.pause_circle_outline_rounded,
              color: _aktif ? _primaryGreen : _textSecondary,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status produk',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'Aktifkan agar bisa dipilih dalam perawatan',
                  style: TextStyle(fontSize: 10, color: _textSecondary),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _aktif,
            activeTrackColor: _primaryGreen,
            onChanged: (value) {
              setState(() {
                _aktif = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_key.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();

    Navigator.pop(
      context,
      Produk(
        id: widget.item?.id,
        nama: _nama.text.trim(),
        jenis: _jenis,
        satuanDefault: _satuan.text.trim(),
        aktif: _aktif,
        keterangan: _optional(_keterangan),
        createdAt: widget.item?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: _inputDecoration(label: label, hint: hint, icon: icon),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wajib diisi';
                }

                return null;
              }
            : null,
      ),
    );
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }
}

// ============================================================
// TRUK SHEET
// ============================================================

class _TrukSheet extends StatefulWidget {
  const _TrukSheet({this.item});

  final Truk? item;

  @override
  State<_TrukSheet> createState() => _TrukSheetState();
}

class _TrukSheetState extends State<_TrukSheet> {
  final _key = GlobalKey<FormState>();

  late final TextEditingController _jenis;
  late final TextEditingController _supir;
  late final TextEditingController _noHp;
  late final TextEditingController _keterangan;

  late String _status;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _jenis = TextEditingController(text: item?.jenis);

    _supir = TextEditingController(text: item?.namaSupir);

    _noHp = TextEditingController(text: item?.noHp);

    _keterangan = TextEditingController(text: item?.keterangan);

    _status = item?.status ?? 'Aktif';
  }

  @override
  void dispose() {
    _jenis.dispose();
    _supir.dispose();
    _noHp.dispose();
    _keterangan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),

              const SizedBox(height: 22),

              _SheetHeader(
                icon: Icons.local_shipping_rounded,
                title: isEdit ? 'Edit Truk' : 'Tambah Truk',
                subtitle: 'Kelola kendaraan operasional perkebunan.',
              ),

              const SizedBox(height: 24),

              _field(
                controller: _jenis,
                label: 'Jenis / Nama Truk',
                hint: 'Contoh: Truk Colt Diesel',
                icon: Icons.local_shipping_outlined,
                required: true,
              ),

              _field(
                controller: _supir,
                label: 'Nama Supir',
                hint: 'Masukkan nama supir',
                icon: Icons.person_outline_rounded,
                required: true,
              ),

              _field(
                controller: _noHp,
                label: 'Nomor HP',
                hint: 'Contoh: 08123456789',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              _statusField(),

              _field(
                controller: _keterangan,
                label: 'Keterangan',
                hint: 'Catatan tambahan',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 8),

              _saveButton(
                label: isEdit ? 'Simpan Perubahan' : 'Tambah Truk',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: DropdownButtonFormField<String>(
        initialValue: _status,
        decoration: _inputDecoration(
          label: 'Status',
          icon: Icons.toggle_on_outlined,
        ),
        items: const [
          DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
          DropdownMenuItem(value: 'Nonaktif', child: Text('Nonaktif')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _status = value;
            });
          }
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(label: label, hint: hint, icon: icon),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wajib diisi';
                }

                return null;
              }
            : null,
      ),
    );
  }

  void _submit() {
    if (!_key.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();

    Navigator.pop(
      context,
      Truk(
        id: widget.item?.id,
        jenis: _jenis.text.trim(),
        namaSupir: _supir.text.trim(),
        noHp: _optional(_noHp),
        status: _status,
        keterangan: _optional(_keterangan),
        createdAt: widget.item?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();

    return value.isEmpty ? null : value;
  }
}

// ============================================================
// LOKASI TIMBANG SHEET
// ============================================================

class _LokasiTimbangSheet extends StatefulWidget {
  const _LokasiTimbangSheet({this.item});

  final LokasiTimbang? item;

  @override
  State<_LokasiTimbangSheet> createState() => _LokasiTimbangSheetState();
}

class _LokasiTimbangSheetState extends State<_LokasiTimbangSheet> {
  final _key = GlobalKey<FormState>();

  late final TextEditingController _nama;
  late final TextEditingController _alamat;
  late final TextEditingController _keterangan;

  late WeighbridgeType _jenis;
  late bool _aktif;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _nama = TextEditingController(text: item?.nama);

    _alamat = TextEditingController(text: item?.alamat);

    _keterangan = TextEditingController(text: item?.keterangan);

    _jenis = item?.jenis ?? WeighbridgeType.ram;
    _aktif = item?.aktif ?? true;
  }

  @override
  void dispose() {
    _nama.dispose();
    _alamat.dispose();
    _keterangan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),

              const SizedBox(height: 22),

              _SheetHeader(
                icon: Icons.scale_rounded,
                title: isEdit ? 'Edit Lokasi Timbang' : 'Tambah Lokasi Timbang',
                subtitle: 'Kelola lokasi timbang dan distribusi TBS.',
              ),

              const SizedBox(height: 24),

              _field(
                controller: _nama,
                label: 'Nama Lokasi',
                hint: 'Contoh: RAM Aek Loba',
                icon: Icons.place_outlined,
                required: true,
              ),

              _jenisField(),

              _field(
                controller: _alamat,
                label: 'Alamat',
                hint: 'Masukkan alamat lokasi',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),

              _statusSwitch(),

              _field(
                controller: _keterangan,
                label: 'Keterangan',
                hint: 'Catatan tambahan',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 8),

              _saveButton(
                label: isEdit ? 'Simpan Perubahan' : 'Tambah Lokasi',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jenisField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: DropdownButtonFormField<WeighbridgeType>(
        initialValue: _jenis,
        decoration: _inputDecoration(
          label: 'Jenis Lokasi',
          icon: Icons.category_outlined,
        ),
        items: WeighbridgeType.values
            .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _jenis = value;
            });
          }
        },
      ),
    );
  }

  Widget _statusSwitch() {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E7E3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _aktif ? const Color(0xFFE4F3E9) : const Color(0xFFECEFED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _aktif
                  ? Icons.check_circle_outline_rounded
                  : Icons.pause_circle_outline_rounded,
              color: _aktif ? _primaryGreen : _textSecondary,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Lokasi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'Aktifkan lokasi untuk digunakan',
                  style: TextStyle(fontSize: 10, color: _textSecondary),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _aktif,
            activeTrackColor: _primaryGreen,
            onChanged: (value) {
              setState(() {
                _aktif = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: _inputDecoration(label: label, hint: hint, icon: icon),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wajib diisi';
                }

                return null;
              }
            : null,
      ),
    );
  }

  void _submit() {
    if (!_key.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();

    Navigator.pop(
      context,
      LokasiTimbang(
        id: widget.item?.id,
        nama: _nama.text.trim(),
        jenis: _jenis,
        alamat: _optional(_alamat),
        aktif: _aktif,
        keterangan: _optional(_keterangan),
        createdAt: widget.item?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();

    return value.isEmpty ? null : value;
  }
}

// ============================================================
// SHEET HEADER
// ============================================================

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _lightGreen,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: _primaryGreen, size: 25),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SHEET HANDLE
// ============================================================

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFD8DDD9),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

// ============================================================
// INPUT DECORATION
// ============================================================

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
  String? hint,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 20, color: const Color(0xFF7C877F)),
    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF707A73)),
    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFA0A7A2)),
    filled: true,
    fillColor: const Color(0xFFF7F9F7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFE1E6E2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFE1E6E2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: _primaryGreen, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
    ),
  );
}

// ============================================================
// SAVE BUTTON
// ============================================================

Widget _saveButton({required String label, required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    ),
  );
}
