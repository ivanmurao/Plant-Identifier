import 'dart:io';

import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../models/plant_identification.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/info_section.dart';

class ResultScreen extends StatefulWidget {
  final File image;
  final PlantIdentification result;

  const ResultScreen({
    super.key,
    required this.image,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveToHistoryIfValid();
  }

  /// Persists this scan to local history the moment the result screen
  /// opens — only when it's a confirmed plant with a usable access_token,
  /// so failed/uncertain scans don't clutter the history list.
  Future<void> _saveToHistoryIfValid() async {
    final result = widget.result;
    if (!result.isPlant || result.accessToken.isEmpty) return;

    await HistoryService.addEntry(
      HistoryEntry(
        accessToken: result.accessToken,
        imagePath: widget.image.path,
        plantName: result.scientificName,
        commonName: result.commonNames.isNotEmpty ? result.commonNames.first : null,
        probability: result.probability,
        scannedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Details'),
      ),
      body: !result.isPlant
          ? _buildNotAPlant(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderImage(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleBlock(),
                        const SizedBox(height: 20),
                        InfoSection(
                          title: 'Description',
                          icon: Icons.menu_book_outlined,
                          content: result.description,
                        ),
                        InfoSection(
                          title: 'Best Watering',
                          icon: Icons.water_drop_outlined,
                          content: result.bestWatering,
                        ),
                        InfoSection(
                          title: 'Best Light Condition',
                          icon: Icons.wb_sunny_outlined,
                          content: result.bestLightCondition,
                        ),
                        InfoSection(
                          title: 'Best Soil Type',
                          icon: Icons.grass_outlined,
                          content: result.bestSoilType,
                        ),
                        InfoSection(
                          title: 'Toxicity',
                          icon: Icons.warning_amber_outlined,
                          content: result.toxicity,
                        ),
                        InfoSection(
                          title: 'Cultural Significance',
                          icon: Icons.public_outlined,
                          content: result.culturalSignificance,
                        ),
                        if (result.wikiUrl != null) _buildSourceLink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderImage() {
    return Image.file(
      widget.image,
      height: 260,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTitleBlock() {
    final result = widget.result;
    final confidencePercent = (result.probability * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.commonNames.isNotEmpty)
          Text(
            result.commonNames.first,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        Text(
          result.scientificName,
          style: TextStyle(
            fontSize: result.commonNames.isNotEmpty ? 15 : 22,
            fontStyle: FontStyle.italic,
            fontWeight:
                result.commonNames.isNotEmpty ? FontWeight.w500 : FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$confidencePercent% match',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        if (result.commonNames.length > 1) ...[
          const SizedBox(height: 14),
          const Text(
            'Also known as',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.commonNames.skip(1).take(6).map((name) {
              return Chip(
                label: Text(name, style: const TextStyle(fontSize: 12)),
                backgroundColor: AppColors.background,
                side: BorderSide(color: AppColors.secondary),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSourceLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Source: ${widget.result.wikiUrl}',
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildNotAPlant(BuildContext context) {
    final result = widget.result;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              "We couldn't confirm a plant in this photo.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence that this is a plant: '
              '${(result.isPlantProbability * 100).toStringAsFixed(0)}%.\n'
              'Try a clearer, closer photo of a leaf or flower.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}