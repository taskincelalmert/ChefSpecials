import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/screen_header.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.loadDashboard();
      provider.seedCategories();
      provider.loadAppeals();
    });
  }

  Future<void> _refresh() async {
    final provider = context.read<AdminProvider>();
    await provider.loadDashboard();
    await provider.loadAppeals();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AdminProvider>();
    final stats = provider.dashboardStats;
    final pendingCount = provider.pendingAppeals.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.adminPanel,
            icon: Icons.admin_panel_settings,
            iconColor: AppTheme.primaryColor,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      children: [
                        // Stat cards grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.1,
                          children: [
                            _buildStatCard(
                              context: context,
                              icon: Icons.people,
                              color: AppTheme.primaryColor,
                              count: stats['totalUsers'] ?? 0,
                              label: l10n.totalUsers,
                            ),
                            _buildStatCard(
                              context: context,
                              icon: Icons.restaurant_menu,
                              color: AppTheme.dinnerColor,
                              count: stats['totalRecipes'] ?? 0,
                              label: l10n.totalRecipes,
                            ),
                            _buildStatCard(
                              context: context,
                              icon: Icons.comment,
                              color: AppTheme.secondaryColor,
                              count: stats['totalComments'] ?? 0,
                              label: l10n.totalComments,
                            ),
                            _buildStatCard(
                              context: context,
                              icon: Icons.trending_up,
                              color: AppTheme.starColor,
                              count: stats['activeToday'] ?? 0,
                              label: l10n.activeToday,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Navigation tiles
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceOf(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.neutralLightOf(context)
                                  .withValues(alpha: 0.5),
                            ),
                            boxShadow: [AppTheme.shadowOf(context)],
                          ),
                          child: Column(
                            children: [
                              _buildNavTile(
                                context: context,
                                icon: Icons.people,
                                color: AppTheme.secondaryColor,
                                title: l10n.userManagement,
                                onTap: () => context.push('/admin/users'),
                              ),
                              _buildDivider(context),
                              _buildNavTile(
                                context: context,
                                icon: Icons.restaurant_menu,
                                color: AppTheme.dinnerColor,
                                title: l10n.recipeModeration,
                                onTap: () => context.push('/admin/recipes'),
                              ),
                              _buildDivider(context),
                              _buildNavTile(
                                context: context,
                                icon: Icons.category,
                                color: AppTheme.starColor,
                                title: l10n.categoryManagement,
                                onTap: () =>
                                    context.push('/admin/categories'),
                              ),
                              _buildDivider(context),
                              _buildNavTile(
                                context: context,
                                icon: Icons.campaign,
                                color: AppTheme.snackColor,
                                title: l10n.adminAnnouncements,
                                onTap: () =>
                                    context.push('/admin/announcements'),
                              ),
                              _buildDivider(context),
                              _buildNavTile(
                                context: context,
                                icon: Icons.gavel,
                                color: AppTheme.errorColor,
                                title: l10n.banAppeals,
                                badge: pendingCount > 0
                                    ? pendingCount
                                    : null,
                                onTap: () =>
                                    context.push('/admin/appeals'),
                              ),
                              _buildDivider(context),
                              _buildNavTile(
                                context: context,
                                icon: Icons.flag_outlined,
                                color: AppTheme.errorColor,
                                title: l10n.adminReports,
                                onTap: () =>
                                    context.push('/admin/reports'),
                              ),
                              _buildDivider(context),
                              _buildNavTile(
                                context: context,
                                icon: Icons.history,
                                color: AppTheme.textSecondaryOf(context),
                                title: l10n.auditLog,
                                onTap: () =>
                                    context.push('/admin/audit-log'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
        ),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textTertiaryOf(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    int? badge,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          if (badge != null) const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: AppTheme.textTertiaryOf(context),
          ),
        ],
      ),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
    );
  }
}
