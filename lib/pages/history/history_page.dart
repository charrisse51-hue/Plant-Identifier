import 'package:flutter/material.dart';
import 'package:flutter_projects/color/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_projects/pages/information/information_page.dart';
import 'history_page_model.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryPageModel(),
      child: const _HistoryPageView(),
    );
  }
}

class _HistoryPageView extends StatelessWidget {
  const _HistoryPageView();

  Color _confidenceColor(double confidence) {
    if (confidence >= 75) return Colors.green;
    if (confidence >= 50) return Colors.amber.shade700;
    return Colors.redAccent;
  }

  String _confidenceLabel(double confidence) {
    if (confidence >= 75) return 'High';
    if (confidence >= 50) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<HistoryPageModel>(context);

    if (model.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (model.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load plant history:\n${model.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: model.refreshHistory,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (model.history.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                'No plant history yet.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8, left: 15, right: 15),
        child: Column(
          children: [
            // Top action bar for Select All and Delete controls
            _buildActionBar(context, model),
            const SizedBox(height: 6),
            // History items list
            Expanded(
              child: RefreshIndicator(
                onRefresh: model.refreshHistory,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 85),
                  itemCount: model.history.length,
                  itemBuilder: (context, index) {
                    final plant = model.history[index];
                    final rawId = plant['id'];
                    final int plantId = rawId is int
                        ? rawId
                        : (int.tryParse(rawId?.toString() ?? '') ?? 0);
                    final commonName = plant['common_name'] ?? 'Unknown';
                    final scientificName = plant['scientific_name'] ?? 'Unknown';
                    final imageUrl = plant['image_url'];
                    final rawConfidence = plant['confidence'];
                    final double? confidence = rawConfidence is num
                        ? rawConfidence.toDouble()
                        : null;
                    final isSelected = model.selectedIds.contains(plantId);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: model.isSelectionMode && isSelected
                            ? const BorderSide(
                                color: AppColors.primaryDark10,
                                width: 1.5,
                              )
                            : BorderSide.none,
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onLongPress: () {
                          if (!model.isSelectionMode) {
                            model.toggleSelectionMode(true);
                          }
                          model.toggleItemSelection(plantId);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Selection Checkbox
                            if (model.isSelectionMode)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Checkbox(
                                  value: isSelected,
                                  activeColor: AppColors.primaryDark10,
                                  onChanged: (_) {
                                    model.toggleItemSelection(plantId);
                                  },
                                ),
                              ),
                            // Clickable area for opening plant details
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (model.isSelectionMode) {
                                    model.toggleItemSelection(plantId);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InformationPage(
                                          imageUrl: imageUrl ?? '',
                                          predictedIndex: 0,
                                          speciesId: plant['species_id'] ?? 0,
                                          commonName: commonName,
                                          scientificName: scientificName,
                                          confidence: confidence,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: model.isSelectionMode ? 4 : 10,
                                  ),
                                  child: Row(
                                    children: [
                                      // Thumbnail
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: imageUrl != null && imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stackTrace) {
                                                  return Container(
                                                    width: 64,
                                                    height: 64,
                                                    color: AppColors.primaryDark70,
                                                    child: const Icon(
                                                        Icons.image_not_supported,
                                                        color: Colors.white),
                                                  );
                                                },
                                              )
                                            : Container(
                                                width: 64,
                                                height: 64,
                                                color: AppColors.primaryDark70,
                                                child: const Icon(
                                                    Icons.local_florist,
                                                    color: Colors.white),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Text info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              commonName,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              scientificName,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                overflow: TextOverflow.ellipsis,
                                                fontStyle: FontStyle.italic,
                                                color: AppColors.surfaceA50,
                                              ),
                                            ),
                                            if (confidence != null) ...[
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _confidenceColor(
                                                          confidence)
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: _confidenceColor(
                                                        confidence),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.bar_chart_rounded,
                                                      size: 12,
                                                      color: _confidenceColor(
                                                          confidence),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      '${confidence.toStringAsFixed(1)}% • ${_confidenceLabel(confidence)}',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            _confidenceColor(
                                                                confidence),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Single Delete button (visible when NOT in selection mode)
                            if (!model.isSelectionMode)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.redAccent, size: 24),
                                  tooltip: 'Remove from history',
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title:
                                            const Text('Remove from History'),
                                        content: Text(
                                            'Remove "$commonName" from your history?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                                foregroundColor:
                                                    Colors.redAccent),
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Remove'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true) {
                                      try {
                                        await model.deletePlant(plant['id']);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Removed from history'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Failed to delete: $e'),
                                              backgroundColor: Colors.redAccent,
                                              duration:
                                                  const Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, HistoryPageModel model) {
    if (model.isSelectionMode) {
      final selectedCount = model.selectedCount;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceA10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Checkbox(
              value: model.isAllSelected,
              activeColor: AppColors.primaryDark10,
              tristate: selectedCount > 0 && !model.isAllSelected,
              onChanged: (_) => model.toggleSelectAll(),
            ),
            Text(
              model.isAllSelected
                  ? 'All selected (${model.history.length})'
                  : '$selectedCount selected',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Spacer(),
            // Cancel selection mode
            TextButton(
              onPressed: () => model.toggleSelectionMode(false),
              child: const Text('Cancel'),
            ),
            // Delete Selected button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: const Icon(Icons.delete_forever_rounded, size: 18),
              label: Text(
                model.isAllSelected
                    ? 'Delete All'
                    : 'Delete ($selectedCount)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: selectedCount == 0
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(model.isAllSelected
                              ? 'Delete All History'
                              : 'Delete Selected History'),
                          content: Text(
                            model.isAllSelected
                                ? 'Are you sure you want to delete ALL (${model.history.length}) history items? This action cannot be undone.'
                                : 'Are you sure you want to delete $selectedCount selected item(s)?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          await model.deleteSelected();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  model.history.isEmpty
                                      ? 'All history cleared successfully'
                                      : 'Selected items deleted successfully',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete: $e'),
                                backgroundColor: Colors.redAccent,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      }
                    },
            ),
          ],
        ),
      );
    }

    // Default bar when not in selection mode: Quick action row
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${model.history.length} identified ${model.history.length == 1 ? 'plant' : 'plants'}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.surfaceA50,
          ),
        ),
        Row(
          children: [
            // "Select" button to activate checkbox selection mode
            TextButton.icon(
              icon: const Icon(Icons.checklist_rounded, size: 18),
              label: const Text('Select'),
              onPressed: () => model.toggleSelectionMode(true),
            ),
            // Quick "Clear All" button
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              icon: const Icon(Icons.delete_sweep_rounded, size: 18),
              label: const Text('Clear All'),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All History'),
                    content: Text(
                      'Are you sure you want to delete ALL (${model.history.length}) plants from your history? This cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await model.deleteAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All history cleared successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to clear history: $e'),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
