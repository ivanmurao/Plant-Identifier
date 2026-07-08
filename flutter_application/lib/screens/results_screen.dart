import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/plant_models.dart';
import '../theme/app_theme.dart';
import '../widgets/plant_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Results Screen – shows ranked identification results
// ─────────────────────────────────────────────────────────────────────────────

class ResultsScreen extends StatefulWidget {
  final PlantNetResponse response;

  const ResultsScreen({super.key, required this.response});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _itemFades;

  @override
  void initState() {
    super.initState();
    final itemCount = widget.response.results.length.clamp(1, 6);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + itemCount * 80),
    )..forward();

    _itemFades = List.generate(itemCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _copyScientificName(String name) {
    Clipboard.setData(ClipboardData(text: name));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$name"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final response = widget.response;
    final topResult = response.topResult;

    return Scaffold(
      backgroundColor: AppTheme.morningMist,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppTheme.parchment,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppTheme.forestGreen,
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Identification result'),
            actions: [
              if (topResult != null)
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 20),
                  color: AppTheme.mossGreen,
                  tooltip: 'Copy scientific name',
                  onPressed: () => _copyScientificName(
                    topResult.species.scientificNameWithoutAuthor,
                  ),
                ),
              const SizedBox(width: 4),
            ],
          ),

          // ── No results state ─────────────────────────────────────────────
          if (response.results.isEmpty)
            SliverFillRemaining(
              child: ErrorStateWidget(
                title: 'No match found',
                message:
                    'Try uploading a clearer photo, or add a photo of the flower or leaf specifically.',
                onRetry: () => Navigator.pop(context),
              ),
            ),

          // ── Results content ──────────────────────────────────────────────
          if (response.results.isNotEmpty) ...[
            // Remaining requests chip
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    RemainingRequestsChip(
                      remaining: response.remainingIdentificationRequests,
                    ),
                  ],
                ),
              ),
            ),

            // Primary result card
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _itemFades[0],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(_itemFades[0]),
                    child: GestureDetector(
                      onLongPress: topResult != null
                          ? () => _copyScientificName(
                                topResult.species.scientificNameWithoutAuthor,
                              )
                          : null,
                      child: PlantDetailCard(
                        result: response.results.first,
                        isPrimary: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Other results header
            if (response.results.length > 1)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Other possibilities',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ),

            // Other result cards (up to 5 additional)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final result = response.results[index + 1];
                    final fadeIndex = (index + 1).clamp(0, _itemFades.length - 1);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FadeTransition(
                        opacity: _itemFades[fadeIndex],
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.06),
                            end: Offset.zero,
                          ).animate(_itemFades[fadeIndex]),
                          child: PlantDetailCard(result: result),
                        ),
                      ),
                    );
                  },
                  childCount: (response.results.length - 1).clamp(0, 5),
                ),
              ),
            ),

            // Attribution + disclaimer
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(child: _buildAttribution()),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ],
      ),
      // Scan again FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: AppTheme.forestGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.camera_alt_outlined, size: 20),
        label: const Text(
          'Scan another',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAttribution() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.parchment,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                'Powered by Pl@ntNet',
                style: AppTheme.labelLarge.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Identification results are provided by the Pl@ntNet AI engine. '
            'Confidence scores reflect the likelihood of each match — always '
            'verify with local experts for important decisions.',
            style: AppTheme.bodyMedium.copyWith(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}
