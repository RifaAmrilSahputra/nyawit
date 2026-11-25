import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nyawit/app.dart';
import 'package:nyawit/core/database/database_backup_service.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final _backupService = DatabaseBackupService();
  bool _isBusy = false;

  Future<void> _createBackup() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      final content = await _backupService.createBackup();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = await FilePicker.saveFile(
        dialogTitle: 'Simpan backup Nyawit',
        fileName: 'nyawit_backup_$timestamp.json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: Uint8List.fromList(utf8.encode(content)),
      );

      if (path != null && mounted) {
        _showMessage('Backup berhasil disimpan.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal membuat backup: $error', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _restoreBackup() async {
    if (_isBusy) return;
    final themeController = ThemeScope.of(context);
    setState(() => _isBusy = true);

    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Pilih file backup Nyawit',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        throw const FormatException('Isi file backup tidak dapat dibaca.');
      }

      final content = utf8.decode(bytes);
      final summary = await _backupService.inspectBackup(content);
      if (!mounted) return;

      final confirmed = await _confirmRestore(file.name, summary);
      if (confirmed != true || !mounted) return;

      final restored = await _backupService.restoreBackup(content);
      await themeController.load(force: true);
      if (!mounted) return;

      _showMessage(
        'Restore berhasil. ${restored.totalRows} baris data dipulihkan.',
      );
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal memulihkan backup: $error', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<bool?> _confirmRestore(
    String fileName,
    DatabaseBackupSummary summary,
  ) {
    final colors = Theme.of(context).colorScheme;
    final date = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(summary.createdAt.toLocal());

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: colors.error),
        title: const Text('Ganti seluruh data?'),
        content: Text(
          'Backup "$fileName" dibuat $date dan berisi '
          '${summary.totalRows} baris data. '
          'Semua data lokal saat ini akan diganti dan tindakan ini tidak '
          'dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            child: const Text('Ganti data'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Backup dan restore',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _BackupInfoCard(),
          const SizedBox(height: 18),
          _BackupActionCard(
            icon: Icons.cloud_download_outlined,
            title: 'Backup data',
            description:
                'Simpan salinan semua data Nyawit ke file JSON agar dapat '
                'dipindahkan atau dipulihkan nanti.',
            buttonLabel: 'Buat backup',
            onPressed: _isBusy ? null : _createBackup,
          ),
          const SizedBox(height: 12),
          _BackupActionCard(
            icon: Icons.settings_backup_restore_rounded,
            title: 'Restore data',
            description:
                'Pilih file backup Nyawit. Restore akan mengganti seluruh '
                'data aplikasi pada perangkat ini.',
            buttonLabel: 'Pilih file backup',
            onPressed: _isBusy ? null : _restoreBackup,
            isDestructive: true,
          ),
          if (_isBusy) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}

class _BackupInfoCard extends StatelessWidget {
  const _BackupInfoCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF173123), Color(0xFF0E1D15)]
              : [colors.primary, Color.lerp(colors.primary, colors.tertiary, .4)!],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF86EFAC).withValues(alpha: .22)
              : colors.primary.withValues(alpha: .18),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: Colors.white, size: 23),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Backup mencakup data kebun, panen, perawatan, data master, '
              'relasi, dan pengaturan aplikasi. Simpan file di tempat yang '
              'aman.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupActionCard extends StatelessWidget {
  const _BackupActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (isDestructive ? colors.error : colors.primary)
                      .withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? colors.error : colors.primary,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            description,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: isDestructive
                ? OutlinedButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.folder_open_rounded),
                    label: Text(buttonLabel),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: colors.error,
                      side: BorderSide(
                        color: colors.error.withValues(alpha: .5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.save_alt_rounded),
                    label: Text(buttonLabel),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
