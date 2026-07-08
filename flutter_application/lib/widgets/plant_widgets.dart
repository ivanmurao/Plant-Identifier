import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant_models.dart';
import '../theme/app_theme.dart';

class ImageUploadCard extends StatelessWidget {
  final ImageEntry? entry;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final ValueChanged<PlantOrgan> onOrganChanged;

  const ImageUploadCard({
    super.key,
    required this.entry,
    required this.index,
    required this.onTap,
    this.onRemove,
    required this.onOrganChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (entry == null) return _EmptySlot(index: index, onTap: onTap);
    return _FilledSlot(
      entry: entry!,
      onTap: onTap,
      onRemove: onRemove,
      onOrganChanged: onOrganChanged,
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const _EmptySlot({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.morningMist,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.mossGreen.withOpacity(0.35),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.fernGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppTheme.mossGreen,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              index == 0 ? 'Add photo' : 'Add another',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.mossGreen,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  final ImageEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final ValueChanged<PlantOrgan> onOrganChanged;

  const _FilledSlot({
    required this.entry,
    required this.onTap,
    this.onRemove,
    required this.onOrganChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image preview
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(entry.filePath),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        // Organ selector at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
            child: _OrganDropdown(
              value: entry.organ,
              onChanged: onOrganChanged,
            ),
          ),
        ),
        // Remove button
        if (onRemove != null)
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OrganDropdown extends StatelessWidget {
  final PlantOrgan value;
  final ValueChanged<PlantOrgan> onChanged;

  const _OrganDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<PlantOrgan>(
        value: value,
        isDense: true,
        dropdownColor: AppTheme.textDark,
        icon: const Icon(Icons.keyboard_arrow_down,
            color: Colors.white70, size: 16),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        items: PlantOrgan.values
            .map(
              (o) => DropdownMenuItem(
                value: o,
                child: Text('${o.emoji} ${o.displayName}'),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confidence Badge
// ─────────────────────────────────────────────────────────────────────────────

class ConfidenceBadge extends StatelessWidget {
  final PlantResult result;
  final bool large;

  const ConfidenceBadge({super.key, required this.result, this.large = false});

  Color get _color {
    switch (result.confidenceTier) {
      case ConfidenceTier.high:   return AppTheme.highConf;
      case ConfidenceTier.medium: return AppTheme.midConf;
      case ConfidenceTier.low:    return AppTheme.lowConf;
    }
  }

  String get _label {
    switch (result.confidenceTier) {
      case ConfidenceTier.high:   return 'High';
      case ConfidenceTier.medium: return 'Medium';
      case ConfidenceTier.low:    return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = large ? 13.0 : 11.0;
    final vPad = large ? 5.0 : 3.0;
    final hPad = large ? 12.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$_label · ${result.scorePercent}',
            style: TextStyle(
              color: _color,
              fontSize: size,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plant Detail Card – primary result
// ─────────────────────────────────────────────────────────────────────────────

class PlantDetailCard extends StatelessWidget {
  final PlantResult result;
  final bool isPrimary;

  const PlantDetailCard({
    super.key,
    required this.result,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final species = result.species;

    if (isPrimary) return _PrimaryCard(result: result, species: species);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    species.primaryCommonName,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    species.scientificNameWithoutAuthor,
                    style: AppTheme.bodyMedium.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConfidenceBadge(result: result),
          ],
        ),
      ),
    );
  }
}

class _PrimaryCard extends StatelessWidget {
  final PlantResult result;
  final Species species;

  const _PrimaryCard({required this.result, required this.species});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best match',
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.mossGreen,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        species.primaryCommonName,
                        style: AppTheme.displayMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ConfidenceBadge(result: result, large: true),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Details grid
            _DetailRow(
              label: 'Scientific name',
              value: species.scientificNameWithoutAuthor,
              italic: true,
            ),
            if (species.scientificNameAuthorship.isNotEmpty) ...[
              const SizedBox(height: 10),
              _DetailRow(
                label: 'Authorship',
                value: species.scientificNameAuthorship,
              ),
            ],
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Family',
              value: species.family.scientificNameWithoutAuthor,
            ),
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Genus',
              value: species.genus.scientificNameWithoutAuthor,
              italic: true,
            ),
            if (species.commonNames.length > 1) ...[
              const SizedBox(height: 10),
              _CommonNamesRow(names: species.commonNames),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool italic;

  const _DetailRow({
    required this.label,
    required this.value,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTheme.labelLarge,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              fontSize: 15,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommonNamesRow extends StatelessWidget {
  final List<String> names;

  const _CommonNamesRow({required this.names});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 120,
          child: Text('Common names', style: AppTheme.labelLarge),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: names
                .map(
                  (n) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.fernGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      n,
                      style: AppTheme.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppTheme.forestGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading shimmer
// ─────────────────────────────────────────────────────────────────────────────

class IdentifyingOverlay extends StatefulWidget {
  const IdentifyingOverlay({super.key});

  @override
  State<IdentifyingOverlay> createState() => _IdentifyingOverlayState();
}

class _IdentifyingOverlayState extends State<IdentifyingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Animate the dot count
    _controller.addListener(() {
      final newCount = (_controller.value * 3).floor() + 1;
      if (newCount != _dotCount && mounted) {
        setState(() => _dotCount = newCount.clamp(1, 3));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.fernGreen
                      .withOpacity(0.1 + _pulse.value * 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_florist_outlined,
                  color: AppTheme.mossGreen,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Identifying plant${'.' * _dotCount}',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.mossGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scanning with Pl@ntNet AI',
                style: AppTheme.bodyMedium.copyWith(fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State Widget
// ─────────────────────────────────────────────────────────────────────────────

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.soilBrown.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.soilBrown,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.displayMedium.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Remaining requests counter chip
// ─────────────────────────────────────────────────────────────────────────────

class RemainingRequestsChip extends StatelessWidget {
  final int remaining;

  const RemainingRequestsChip({super.key, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final isLow = remaining < 50;
    final color = isLow ? AppTheme.soilBrown : AppTheme.mossGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLow ? Icons.warning_amber_rounded : Icons.api_outlined,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            '$remaining identifications left today',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
