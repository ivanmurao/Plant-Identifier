import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/plant_models.dart';
import '../services/plantnet_service.dart';
import '../theme/app_theme.dart';
import '../widgets/plant_widgets.dart';
import 'results_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Scanner Screen – image upload + identify
// ─────────────────────────────────────────────────────────────────────────────

class ScannerScreen extends StatefulWidget {
  final PlantNetService plantNetService;

  const ScannerScreen({super.key, required this.plantNetService});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final List<ImageEntry> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isIdentifying = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  static const int _maxImages = 5;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Image picking ────────────────────────────────────────────────────────

  Future<void> _pickImage({required ImageSource source}) async {
    if (_images.length >= _maxImages) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1920,
      );
      if (picked == null) return;

      setState(() {
        _images.add(ImageEntry(filePath: picked.path));
      });
    } catch (e) {
      if (mounted) {
        _showSnack('Could not access camera / gallery. Check permissions.');
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _updateOrgan(int index, PlantOrgan organ) {
    setState(() => _images[index].organ = organ);
  }

  void _showSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.parchment,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Add photo', style: AppTheme.displayMedium.copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Text(
                'Choose a clear photo of the plant — flower, leaf, or whole plant works best.',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _SourceTile(
                icon: Icons.camera_alt_outlined,
                label: 'Take a photo',
                subtitle: 'Use your camera',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(source: ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _SourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                subtitle: 'Pick an existing photo',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(source: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Identification ───────────────────────────────────────────────────────

  Future<void> _identify() async {
    if (_images.isEmpty || _isIdentifying) return;

    setState(() => _isIdentifying = true);

    try {
      final response = await widget.plantNetService.identify(_images);

      if (!mounted) return;

      if (response.results.isEmpty) {
        _showSnack('No matching plants found. Try a clearer image.');
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ResultsScreen(response: response),
        ),
      );
    } on PlantNetException catch (e) {
      if (mounted) {
        _showErrorDialog(title: e.title, message: e.message);
      }
    } finally {
      if (mounted) setState(() => _isIdentifying = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorDialog({required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.parchment,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTheme.displayMedium.copyWith(fontSize: 18)),
        content: Text(message, style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_florist, color: AppTheme.mossGreen, size: 20),
            SizedBox(width: 8),
            Text('PlantID'),
          ],
        ),
        actions: [
          if (_images.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _images.clear()),
              child: const Text(
                'Clear',
                style: TextStyle(color: AppTheme.mossGreen),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fade,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(child: _buildHeader()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(child: _buildImageGrid()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(child: _buildTips()),
                ),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 140),
                ),
              ],
            ),
          ),

          // Identify button fixed at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(),
          ),

          // Full-screen loading overlay
          if (_isIdentifying)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0xCCF2F7F2),
                child: IdentifyingOverlay(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identify a plant',
          style: AppTheme.displayLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Add up to $_maxImages photos of the same plant for better accuracy.',
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    // Show filled slots + one empty slot (if under max)
    final totalSlots = (_images.length < _maxImages)
        ? _images.length + 1
        : _maxImages;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: totalSlots == 1 ? 1 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: totalSlots == 1 ? 16 / 9 : 1,
      ),
      itemCount: totalSlots,
      itemBuilder: (context, index) {
        final hasImage = index < _images.length;
        return ImageUploadCard(
          entry: hasImage ? _images[index] : null,
          index: index,
          onTap: hasImage
              ? _showSourcePicker // tap filled slot to replace
              : _showSourcePicker,
          onRemove: hasImage ? () => _removeImage(index) : null,
          onOrganChanged: hasImage
              ? (organ) => _updateOrgan(index, organ)
              : (_) {},
        );
      },
    );
  }

  Widget _buildTips() {
    if (_images.isEmpty) return _EmptyHint();
    return const SizedBox.shrink();
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.parchment,
        border: const Border(
          top: BorderSide(color: AppTheme.divider),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.forestGreen.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image count indicator
          if (_images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.morningMist,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.fromBorderSide(
                    const BorderSide(color: AppTheme.divider),
                  ),
                ),
                child: Text(
                  '${_images.length}/${_maxImages}',
                  style: AppTheme.labelLarge.copyWith(
                    color: AppTheme.forestGreen,
                  ),
                ),
              ),
            ),

          Expanded(
            child: ElevatedButton.icon(
              onPressed: _images.isEmpty ? null : _identify,
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text('Identify plant'),
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: AppTheme.mossGreen.withOpacity(0.25),
                disabledForegroundColor: AppTheme.mossGreen.withOpacity(0.5),
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.morningMist,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.fernGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.forestGreen, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      )),
                  Text(subtitle, style: AppTheme.bodyMedium.copyWith(fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tips = [
      ('🌸', 'Photograph the flower', 'Flowers give the strongest identification signal'),
      ('🍃', 'Include a leaf', 'Add a leaf photo for higher accuracy'),
      ('☀️', 'Use good lighting', 'Natural daylight gives clearest results'),
      ('📐', 'Fill the frame', 'Get close so the plant part fills the image'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips for best results',
          style: AppTheme.labelLarge.copyWith(color: AppTheme.forestGreen),
        ),
        const SizedBox(height: 12),
        ...tips.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.$1, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.$2,
                        style: AppTheme.bodyLarge.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        t.$3,
                        style: AppTheme.bodyMedium.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
