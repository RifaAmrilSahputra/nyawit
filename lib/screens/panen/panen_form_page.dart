import 'package:flutter/material.dart';
import 'package:nyawit/models/panen.dart';
import 'package:nyawit/screens/panen/panen_page.dart';

/// Public form entry point for creating and editing harvest transactions.
/// The existing implementation is kept intact in PanenPage's implementation
/// library so this refactor does not alter CRUD or validation behavior.
class PanenFormPage extends StatefulWidget {
  const PanenFormPage({
    super.key,
    this.panen,
    this.initialKebunId,
    this.lockKebun = false,
  });

  final Panen? panen;
  final int? initialKebunId;
  final bool lockKebun;

  @override
  State<PanenFormPage> createState() => _PanenFormPageEntryState();
}

class _PanenFormPageEntryState extends State<PanenFormPage> {
  @override
  Widget build(BuildContext context) {
    return PanenFormPageImplementation(
      panen: widget.panen,
      initialKebunId: widget.initialKebunId,
      lockKebun: widget.lockKebun,
    );
  }
}
