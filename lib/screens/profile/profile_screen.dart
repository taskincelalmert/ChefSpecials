import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/achievement.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/follow_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/empty_state.dart';
import '../home/widgets/privacy_badge.dart';
import '../home/widgets/recipe_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final recipeProvider = context.watch<RecipeProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (!authProvider.isAuthenticated) {
      return _LoginRequiredProfileView();
    }

    final user = authProvider.userModel;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Initialize follow provider for current user
    context.read<FollowProvider>().initialize(user.uid, userName: user.fullName, userAvatar: user.photoUrl);

    final userRecipes = recipeProvider.allRecipes
        .where((r) => r.authorId == user.uid)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                // Profile card
                _buildProfileCard(context, l10n, user.photoUrl,
                    user.fullName, user.email, user.bio, user.createdAt,
                    user.username),
                const SizedBox(height: 16),
                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/my-recipes'),
                          child: _buildStatCard(
                            context: context,
                            icon: Icons.menu_book,
                            color: AppTheme.primaryColor,
                            count: userRecipes.length,
                            label: l10n.recipes,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push(
                            '/follow-list/${user.uid}',
                            extra: 0,
                          ),
                          child: _buildStatCard(
                            context: context,
                            icon: Icons.people_outline,
                            color: AppTheme.secondaryColor,
                            count: user.followersCount,
                            label: l10n.followers,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push(
                            '/follow-list/${user.uid}',
                            extra: 1,
                          ),
                          child: _buildStatCard(
                            context: context,
                            icon: Icons.person_add_outlined,
                            color: AppTheme.starColor,
                            count: user.followingCount,
                            label: l10n.following,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Feature links
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
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
                        if (user.isAdmin) ...[
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings,
                                color: AppTheme.errorColor,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              l10n.adminPanel,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: AppTheme.textTertiaryOf(context),
                            ),
                            onTap: () => context.push('/admin'),
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppTheme.neutralLightOf(context)
                                .withValues(alpha: 0.5),
                          ),
                        ],
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            l10n.mealPlanner,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                          onTap: () => context.push('/meal-planner'),
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppTheme.neutralLightOf(context)
                              .withValues(alpha: 0.5),
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: AppTheme.secondaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            l10n.shoppingLists,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                          onTap: () => context.push('/shopping-lists'),
                          dense: true,
                        ),
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppTheme.neutralLightOf(context)
                              .withValues(alpha: 0.5),
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.starColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.collections_bookmark_outlined,
                              color: AppTheme.starColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            l10n.collections,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                          onTap: () => context.push('/collections'),
                          dense: true,
                        ),
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppTheme.neutralLightOf(context)
                              .withValues(alpha: 0.5),
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.history,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            l10n.cookingHistory,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                          onTap: () => context.push('/cooking-history'),
                          dense: true,
                        ),
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppTheme.neutralLightOf(context)
                              .withValues(alpha: 0.5),
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.starColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: AppTheme.starColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            l10n.achievements,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                          onTap: () => context.push('/achievements'),
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildAchievementsPreview(context, l10n, user.uid),
                const SizedBox(height: 24),
                // My Recipes header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        l10n.myRecipes,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${userRecipes.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/my-recipes'),
                        child: Row(
                          children: [
                            Text(
                              l10n.viewAll,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Recipe list (show max 3 on profile)
                if (userRecipes.isNotEmpty)
                  ...userRecipes.take(3).map(
                    (recipe) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Stack(
                        children: [
                          RecipeCard(recipe: recipe),
                          Positioned(
                            top: 12,
                            right: 52,
                            child: PrivacyBadge(recipe: recipe),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: EmptyState(
                      icon: Icons.menu_book,
                      title: l10n.noRecipes,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        border: Border(
          bottom: BorderSide(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.profile,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfileCard(
    BuildContext context,
    AppLocalizations l10n,
    String? photoUrl,
    String fullName,
    String email,
    String? bio,
    DateTime createdAt,
    String? username,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
          boxShadow: [AppTheme.shadowOf(context)],
        ),
        child: Column(
          children: [
            // Avatar with gradient ring
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceOf(context),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: AppTheme.neutralSoft,
                            child: const Icon(Icons.person,
                                size: 40, color: AppTheme.textTertiary),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: AppTheme.neutralSoft,
                            child: const Icon(Icons.person,
                                size: 40, color: AppTheme.textTertiary),
                          ),
                        )
                      : Container(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            if (username != null) ...[
              const SizedBox(height: 4),
              Text(
                '@$username',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
            const SizedBox(height: 4),
            // Email
            Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textTertiary,
              ),
            ),
            // Bio
            if (bio != null && bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                bio,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            // Member since
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neutralSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.memberSince(
                      DateFormat('MMM yyyy').format(createdAt),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                      fontWeight: FontWeight.w500,
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

  Widget _buildAchievementsPreview(
      BuildContext context, AppLocalizations l10n, String userId) {
    final provider = context.watch<AchievementProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.read<AchievementProvider>().init(userId);
    });
    final recent = provider.unlockedAchievements.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push('/achievements'),
        child: Container(
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
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events,
                      size: 20, color: AppTheme.starColor),
                  const SizedBox(width: 8),
                  Text(
                    l10n.achievements,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      l10n.achievementsUnlocked(
                          provider.unlockedCount, provider.totalCount),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppTheme.textTertiary),
                ],
              ),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.noAchievementsYet,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textTertiaryOf(context),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    for (final ua in recent)
                      Builder(builder: (_) {
                        final a = Achievement.byId(ua.achievementId);
                        final color = a?.color ?? AppTheme.starColor;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: a?.gradient,
                              color: a == null
                                  ? AppTheme.starColor.withValues(alpha: 0.15)
                                  : null,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              a?.icon ?? Icons.emoji_events,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: AppTheme.textTertiaryOf(context).withValues(alpha: 0.4),
            ),
          ),
          Center(
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textTertiaryOf(context),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginRequiredProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 36,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.loginRequired,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.loginRequiredProfileMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryOf(context),
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusM),
                        ),
                      ),
                      child: Text(
                        l10n.signIn,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: Text(
                    l10n.signUp,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
