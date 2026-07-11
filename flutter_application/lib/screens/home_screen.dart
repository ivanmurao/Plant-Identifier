import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/plant_id_service.dart';
import '../theme/app_theme.dart';
import '../widgets/source_option_card.dart';
import 'result_screen.dart';
import 'aboutus_screen.dart';
import 'information_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final PlantIdService _plantIdService = PlantIdService();

  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _errorMessage = null);
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked == null) return;
      setState(() => _selectedImage = File(picked.path));
    } catch (e) {
      setState(() => _errorMessage = 'Could not access camera/gallery: $e');
    }
  }

  Future<void> _identify() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _plantIdService.identify(_selectedImage!);
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(image: _selectedImage!, result: result),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetSelection() {
    setState(() {
      _selectedImage = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  automaticallyImplyLeading: false,
  centerTitle: true,

  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Hero(
        tag: 'app_brand_logo',
        child: Image.asset(
          'assets/images/logo.png',
          height: 32,
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 10),
      const Hero(
        tag: 'app_title_text',
        child: Material(
          color: Colors.transparent,
          child: Text(
            'PLANT SCAN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    ],
  ),

  actions: [
    PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      onSelected: (value) {
        switch (value) {
          case 'history':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HistoryScreen(),
              ),
            );
            break;

          case 'info':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InformationScreen(),
              ),
            );
            break;

          case 'aboutus':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AboutUsScreen(),
              ),
            );
            break;
        }
      },

      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'history',
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: AppColors.primary,
              ),
              SizedBox(width: 12),
              Text('History'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'info',
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
              ),
              SizedBox(width: 12),
              Text('Information'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'aboutus',
          child: Row(
            children: [
              Icon(
                Icons.groups_outlined,
                color: AppColors.primary,
              ),
              SizedBox(width: 12),
              Text('About Us'),
            ],
          ),
        ),
      ],
    ),
  ],
),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Expanded(
                child: Center(
                  child: _selectedImage == null
                      ? _buildIdleState()
                      : _buildPreviewState(),
                ),
              ),
              const SizedBox(height: 24),
              if (_selectedImage == null) ...[
                _buildGuidelinesCard(),
                const SizedBox(height: 24),
              ],
              _selectedImage == null ? _buildSourcePicker() : _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.filter_center_focus_outlined,
          size: 72,
          color: AppColors.primary.withOpacity(0.4),
        ),
        const SizedBox(height: 16),
        const Text(
          'Scan a plant to get details instantly',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPreviewState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary, width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

 Widget _buildGuidelinesCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8F3),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFE5E7DD),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tips for best results',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C6B5F),
          ),
        ),
        const SizedBox(height: 16),

        _buildTipRow(
          icon: Icons.local_florist,
          iconColor: Color(0xFFFF69B4),
          title: 'Photograph the flower',
          subtitle: 'Flowers give the strongest identification signal',
        ),

        const SizedBox(height: 14),

        _buildTipRow(
          icon: Icons.eco,
          iconColor: Color(0xFF4CAF50),
          title: 'Include a leaf',
          subtitle: 'Add a leaf photo for higher accuracy',
        ),

        const SizedBox(height: 14),

        _buildTipRow(
          icon: Icons.wb_sunny,
          iconColor: Color(0xFFFFC107),
          title: 'Use good lighting',
          subtitle: 'Natural daylight gives clearest results',
        ),

        const SizedBox(height: 14),

        _buildTipRow(
          icon: Icons.crop_free,
          iconColor: Color(0xFF64B5F6),
          title: 'Fill the frame',
          subtitle: 'Get close so the plant part fills the image',
        ),
      ],
    ),
  );
}

  Widget _buildTipRow({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        color: iconColor,
        size: 22,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B4B4B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8B8B8B),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildSourcePicker() {
    return Row(
      children: [
        Expanded(
          child: SourceOptionCard(
            icon: Icons.camera_alt_outlined,
            label: 'Take Photo',
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SourceOptionCard(
            icon: Icons.photo_library_outlined,
            label: 'From Gallery',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _identify,
            icon: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.eco_outlined),
            label: Text(_isLoading ? 'Identifying...' : 'Identify Plant'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _resetSelection,
            child: const Text('Choose Another Photo'),
          ),
        ),
      ],
    );
  }
}