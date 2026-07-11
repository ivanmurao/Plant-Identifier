import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  const SizedBox(height: 28),
                  _buildSectionTitle('Quick Tips', Icons.lightbulb_outline),
                  const SizedBox(height: 12),
                  _buildTipTile(
                    step: '1',
                    title: 'Frame the plant clearly',
                    subtitle:
                        'Center a single leaf or flower in good lighting for the most accurate match.',
                  ),
                  _buildTipTile(
                    step: '2',
                    title: 'Avoid busy backgrounds',
                    subtitle:
                        'A plain background helps the scanner isolate the plant from clutter.',
                  ),
                  _buildTipTile(
                    step: '3',
                    title: 'Hold steady while capturing',
                    subtitle:
                        'Keep the camera still for a second before capturing so the app can scan properly.',
                  ),
                  _buildTipTile(
                    step: '4',
                    title: 'Check the results carefully',
                    subtitle:
                        'Review the match percentage — similar species can look alike at a glance.',
                    isLast: true,
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle('What Our Scanning App Can Do', Icons.eco_outlined),
                  const SizedBox(height: 12),
                  _buildCapabilityCard(
                    icon: Icons.search,
                    title: 'Instant Plant Identification',
                    description:
                        'Recognizes thousands of plant species from a single photo in seconds.',
                  ),
                  _buildCapabilityCard(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Toxicity Information',
                    description:
                        'Provides toxicity details to help determine whether a plant is safe or potentially harmful to humans and animals.',
                  ),
                  _buildCapabilityCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Care Recommendations',
                    description:
                        'Gives watering, sunlight, and soil guidance tailored to each species.',
                  ),
                  _buildCapabilityCard(
                    icon: Icons.public_outlined,
                    title: 'Cultural Importance',
                    description:
                        'Highlights the plant’s cultural significance, traditional uses, and overall importance where available.',
                    isLast: true,
                  ),
                  const SizedBox(height: 28),
                  _buildAboutApiNote(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- App Bar ----------

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      expandedHeight: 130,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: const Text(
          'Information',
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
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Section Title ----------

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2A22),
          ),
        ),
      ],
    );
  }

  // ---------- Tip Tile ----------

  Widget _buildTipTile({
    required String step,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7EEE9)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                step,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: Color(0xFF1E2A22),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7A70),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Capability Card ----------

  Widget _buildCapabilityCard({
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: Color(0xFF1E2A22),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF6B7A70),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- About the API footnote ----------

  Widget _buildAboutApiNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_outlined, color: AppColors.secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Plant Scan uses a cloud-based identification API to analyze your photos. '
              'An internet connection is required for scanning, and results may vary '
              'slightly depending on image quality and lighting.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.secondary.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}