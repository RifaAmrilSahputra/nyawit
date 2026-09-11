import 'package:flutter/foundation.dart';
import 'package:nyawit/models/pekerja.dart';
import 'package:nyawit/models/produk.dart';
import 'package:nyawit/models/truk.dart';
import 'package:nyawit/repositories/pekerja_repository.dart';
import 'package:nyawit/repositories/produk_repository.dart';
import 'package:nyawit/repositories/truk_repository.dart';
import 'package:nyawit/models/lokasi_timbang.dart';
import 'package:nyawit/repositories/lokasi_timbang_repository.dart';

class PekerjaController extends ChangeNotifier {
  final PekerjaRepository _repository = PekerjaRepository();
  List<Pekerja> items = [];
  bool isLoading = true;
  Object? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repository.getAll();
    } catch (exception) {
      error = exception;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save(Pekerja item) async {
    if (item.id == null) {
      await _repository.insert(item);
    } else {
      await _repository.update(item);
    }
    await load();
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    await load();
  }
}

class ProdukController extends ChangeNotifier {
  final ProdukRepository _repository = ProdukRepository();
  List<Produk> items = [];
  bool isLoading = true;
  Object? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repository.getAll();
    } catch (exception) {
      error = exception;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save(Produk item) async {
    if (item.id == null) {
      await _repository.insert(item);
    } else {
      await _repository.update(item);
    }
    await load();
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    await load();
  }
}

class TrukController extends ChangeNotifier {
  final TrukRepository _repository = TrukRepository();
  List<Truk> items = [];
  bool isLoading = true;
  Object? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repository.getAll();
    } catch (exception) {
      error = exception;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save(Truk item) async {
    if (item.id == null) {
      await _repository.insert(item);
    } else {
      await _repository.update(item);
    }
    await load();
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    await load();
  }
}

class LokasiTimbangController extends ChangeNotifier {
  final LokasiTimbangRepository _repository = LokasiTimbangRepository();
  List<LokasiTimbang> items = [];
  bool isLoading = true;
  Object? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repository.getAll();
    } catch (exception) {
      error = exception;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save(LokasiTimbang item) async {
    if (item.id == null) {
      await _repository.insert(item);
    } else {
      await _repository.update(item);
    }
    await load();
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    await load();
  }
}
