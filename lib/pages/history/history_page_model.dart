import 'package:flutter/material.dart';
import 'package:flutter_projects/api/history_plants_api.dart';

class HistoryPageModel extends ChangeNotifier {
  List<dynamic> history = [];
  bool isLoading = true;
  String? errorMessage;

  // Multi-select state
  bool isSelectionMode = false;
  final Set<int> selectedIds = {};

  HistoryPageModel() {
    loadHistory();
  }

  bool get isAllSelected =>
      history.isNotEmpty && selectedIds.length == history.length;

  int get selectedCount => selectedIds.length;

  void toggleSelectionMode([bool? force]) {
    isSelectionMode = force ?? !isSelectionMode;
    if (!isSelectionMode) {
      selectedIds.clear();
    }
    notifyListeners();
  }

  void toggleItemSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
      if (selectedIds.isEmpty) {
        // Optional: keep selection mode active or leave it on
      }
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }

  void toggleSelectAll() {
    if (isAllSelected) {
      selectedIds.clear();
    } else {
      selectedIds.clear();
      for (final item in history) {
        final id = item['id'];
        if (id is int) {
          selectedIds.add(id);
        } else if (id != null) {
          selectedIds.add(int.tryParse(id.toString()) ?? 0);
        }
      }
    }
    notifyListeners();
  }

  Future<void> loadHistory() async {
    isLoading = true;
    errorMessage = null;
    selectedIds.clear();
    isSelectionMode = false;
    notifyListeners();
    try {
      final result = await HistoryPlantsApi.fetchHistory();
      history = result;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHistory() => loadHistory();

  Future<void> deletePlant(dynamic id) async {
    final parsedId = id is int ? id : int.parse(id.toString());
    selectedIds.remove(parsedId);
    final idx = history.indexWhere((p) => p['id'] == id);
    if (idx != -1) {
      final removed = history.removeAt(idx);
      notifyListeners();
      try {
        await HistoryPlantsApi.deleteHistory(parsedId);
      } catch (e) {
        history.insert(idx, removed);
        notifyListeners();
        rethrow;
      }
    }
  }

  /// Deletes all items currently selected by the checkboxes
  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) return;

    if (isAllSelected) {
      await deleteAll();
      return;
    }

    final idsToDelete = selectedIds.toList();
    final removedItems = history.where((p) => idsToDelete.contains(p['id'])).toList();
    history.removeWhere((p) => idsToDelete.contains(p['id']));
    selectedIds.clear();
    if (history.isEmpty) {
      isSelectionMode = false;
    }
    notifyListeners();

    try {
      await HistoryPlantsApi.deleteSelectedHistory(idsToDelete);
    } catch (e) {
      // Restore on failure
      history.addAll(removedItems);
      history.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes ALL history entries
  Future<void> deleteAll() async {
    if (history.isEmpty) return;
    final backup = List<dynamic>.from(history);
    history.clear();
    selectedIds.clear();
    isSelectionMode = false;
    notifyListeners();

    try {
      await HistoryPlantsApi.deleteAllHistory();
    } catch (e) {
      history = backup;
      notifyListeners();
      rethrow;
    }
  }
}
