import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_projects/color/app_colors.dart';
import '../information/information_page.dart';
import 'myplants_page_model.dart';

class MyplantsPage extends StatelessWidget {
  const MyplantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyplantsPageModel(),
      child: const _MyplantsPageView(),
    );
  }
}

class _MyplantsPageView extends StatelessWidget {
  const _MyplantsPageView();

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
    final model = Provider.of<MyplantsPageModel>(context);

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
                'Failed to load saved plants:\n${model.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: model.refreshPlants,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (model.plants.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No saved plants yet.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final plants = model.plants;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: RefreshIndicator(
          onRefresh: model.refreshPlants,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 85),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              final commonName = plant['common_name'] ?? 'Unknown';
              final scientificName = plant['scientific_name'] ?? 'Unknown';
              final imageUrl = plant['image_url'];
              final rawConfidence = plant['confidence'];
              final double? confidence = rawConfidence is num
                  ? rawConfidence.toDouble()
                  : null;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
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
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 64,
                                            height: 64,
                                            color: AppColors.primaryDark70,
                                            child: const Icon(Icons.image_not_supported),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 64,
                                        height: 64,
                                        color: AppColors.primaryDark70,
                                        child: const Icon(Icons.local_florist, color: Colors.white),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _confidenceColor(confidence).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _confidenceColor(confidence),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.bar_chart_rounded,
                                              size: 12,
                                              color: _confidenceColor(confidence),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${confidence.toStringAsFixed(1)}% • ${_confidenceLabel(confidence)}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _confidenceColor(confidence),
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
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
                        tooltip: 'Remove from Saved',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Remove Saved Plant'),
                              content: Text('Remove "$commonName" from saved plants?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            try {
                              await model.deletePlant(plant['id']);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Removed plant successfully'),
                                    duration: Duration(seconds: 2),
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
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
