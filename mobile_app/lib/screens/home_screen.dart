import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

/// Screen 4: Home Screen (Citizen Dashboard)
///
/// Displays a welcome header with the authenticated citizen's info,
/// quick actions for reporting an issue and viewing submitted reports,
/// a profile section, and logout functionality.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _confirmAndLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your JanSamasya account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await context.read<AuthService>().logout();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  String _formatTitleCase(String text) {
    if (text.trim().isEmpty) return '';
    return text
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.user;
    final primaryBlue = Theme.of(context).colorScheme.primary;

    final locationParts = <String>[
      if (user?.area != null && user!.area!.isNotEmpty)
        _formatTitleCase(user.area!),
      if (user?.state != null && user!.state.isNotEmpty)
        _formatTitleCase(user.state),
    ];
    final locationLabel = locationParts.isNotEmpty
        ? locationParts.join(', ')
        : 'Citizen Account';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JanSamasya',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'Report. Track. Resolve.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _confirmAndLogout(context),
            icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Header Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFFDBEAFE),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.username ?? 'Citizen',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFFDBEAFE),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                locationLabel,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Report civic problems in your locality and monitor resolution progress directly from your phone.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFEFF6FF),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Civic Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Primary Action 1: Report an Issue
                  _DashboardActionCard(
                    icon: Icons.add_a_photo_outlined,
                    iconBgColor: const Color(0xFFEFF6FF),
                    iconColor: primaryBlue,
                    title: 'Report an Issue',
                    subtitle:
                        'Submit a new civic complaint with category details and optional photo evidence.',
                    onTap: () => Navigator.of(context).pushNamed('/report'),
                  ),
                  const SizedBox(height: 12),

                  // Primary Action 2: My Reports
                  _DashboardActionCard(
                    icon: Icons.assignment_outlined,
                    iconBgColor: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF059669),
                    title: 'My Reports',
                    subtitle:
                        'View your submitted civic complaints and check their current status.',
                    onTap: () => Navigator.of(context).pushNamed('/my-reports'),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Profile Section Card
                  _DashboardActionCard(
                    icon: Icons.person_outline,
                    iconBgColor: const Color(0xFFF3F4F6),
                    iconColor: const Color(0xFF374151),
                    title: 'My Profile',
                    subtitle:
                        'View your registered account details, state, and service area.',
                    onTap: () => Navigator.of(context).pushNamed('/profile'),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  CustomButton(
                    label: 'Logout',
                    icon: Icons.logout,
                    isOutlined: true,
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: const Color(0xFFDC2626),
                    onPressed: () => _confirmAndLogout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable dashboard card used on [HomeScreen].
class _DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
