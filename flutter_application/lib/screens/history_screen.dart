import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/history_entry.dart';
import '../models/plant_identification.dart';
import '../services/history_service.dart';
import '../services/plant_id_service.dart';
import '../theme/app_theme.dart';
import '../widgets/info_section.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<HistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = HistoryService.getHistory();
  }

  Future<void> _refresh() async {
    setState(_loadHistory);
    await _historyFuture;
  }

  Future<void> _deleteEntry(HistoryEntry entry) async {
    await HistoryService.deleteEntry(entry.accessToken);
    setState(_loadHistory);
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear all history?'),
        content: const Text(
            'This will remove every saved scan from this device. This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService.clearAll();
      setState(_loadHistory);
    }
  }

  void _openDetail(HistoryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HistoryDetailSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: FutureBuilder<List<HistoryEntry>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                final entries = snapshot.data ?? [];
                if (entries.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entries.length} saved scan${entries.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: Color(0xFF6B7A70),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...entries.map(
                          (entry) => _buildHistoryCard(entry),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- App Bar ----------

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      expandedHeight: 130,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined),
          tooltip: 'Clear all',
          onPressed: _confirmClearAll,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: const Text(
          'Scan History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Empty State ----------

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco_outlined, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'No scans yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2A22),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Identify a plant and it will show up here so you can revisit it anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7A70), height: 1.4),
          ),
        ],
      ),
    );
  }

  // ---------- History Card ----------

  Widget _buildHistoryCard(HistoryEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(entry.accessToken),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        onDismissed: (_) => _deleteEntry(entry),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openDetail(entry),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _buildThumbnail(entry.imagePath),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.plantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                            color: Color(0xFF1E2A22),
                          ),
                        ),
                        if (entry.commonName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            entry.commonName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF6B7A70),
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('MMM d, yyyy · h:mm a').format(entry.scannedAt),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF9AA79E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildConfidenceBadge(entry.probability),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      return Container(
        width: 64,
        height: 64,
        color: AppColors.primary.withOpacity(0.08),
        child: Icon(Icons.image_not_supported_outlined,
            color: AppColors.primary.withOpacity(0.5), size: 24),
      );
    }
    return Image.file(file, width: 64, height: 64, fit: BoxFit.cover);
  }

  Widget _buildConfidenceBadge(double probability) {
    final percent = (probability * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$percent%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HistoryDetailSheet extends StatefulWidget {
  final HistoryEntry entry;
  const _HistoryDetailSheet({required this.entry});

  @override
  State<_HistoryDetailSheet> createState() => _HistoryDetailSheetState();
}

class _HistoryDetailSheetState extends State<_HistoryDetailSheet> {
  final _service = PlantIdService();
  late Future<PlantIdentification> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.retrieveIdentification(widget.entry.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: FutureBuilder<PlantIdentification>(
                  future: _detailFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent, size: 32),
                              const SizedBox(height: 10),
                              Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF6B7A70)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final result = snapshot.data!;
                    final confidencePercent =
                        (result.probability * 100).toStringAsFixed(0);

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(widget.entry.imagePath),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (result.commonNames.isNotEmpty)
                          Text(
                            result.commonNames.first,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2A22),
                            ),
                          ),
                        Text(
                          result.scientificName,
                          style: TextStyle(
                            fontSize: result.commonNames.isNotEmpty ? 14 : 19,
                            fontStyle: FontStyle.italic,
                            fontWeight: result.commonNames.isNotEmpty
                                ? FontWeight.w500
                                : FontWeight.bold,
                            color: const Color(0xFF6B7A70),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$confidencePercent% match',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Originally scanned on '
                            '${DateFormat('MMM d, yyyy · h:mm a').format(widget.entry.scannedAt)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF9AA79E),
                            ),
                          ),
                        ),
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
                        if (result.wikiUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Source: ${result.wikiUrl}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9AA79E),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}