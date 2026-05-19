import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/screen_header.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permission when the user comes back from phone settings —
    // but only when push has actually been opted into.
    if (state == AppLifecycleState.resumed) {
      final provider = context.read<NotificationProvider>();
      final userId = context.read<AuthProvider>().userModel?.uid;
      if (userId != null && provider.pushEnabled) {
        provider.recheckPermission(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.notificationSettings,
            icon: Icons.notifications_outlined,
            iconColor: AppTheme.snackColor,
          ),
          Expanded(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  children: [
                    _buildMasterToggleCard(context, provider, l10n),
                    const SizedBox(height: 20),
                    if (provider.pushEnabled && provider.permissionDenied)
                      _buildPermissionBanner(context, l10n),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: provider.pushEnabled ? 1.0 : 0.45,
                      child: IgnorePointer(
                        ignoring: !provider.pushEnabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSectionLabel(context, l10n.mealReminders),
                            const SizedBox(height: 8),
                            _buildMealRemindersCard(context, provider, l10n),
                            const SizedBox(height: 20),
                            _buildSectionLabel(context, l10n.socialAlerts),
                            const SizedBox(height: 8),
                            _buildSocialAlertsCard(context, provider, l10n),
                          ],
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
  }

  Widget _buildMasterToggleCard(
    BuildContext context,
    NotificationProvider provider,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
        ),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              provider.pushEnabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pushNotifications,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.pushNotificationsDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryOf(context),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: provider.pushEnabled,
            onChanged: (value) async {
              final userId = context.read<AuthProvider>().userModel?.uid;
              if (userId == null) return;
              await provider.setPushEnabled(value);
              if (value && provider.permissionDenied && context.mounted) {
                final settings = await provider.currentSettings();
                if (settings.authorizationStatus ==
                    AuthorizationStatus.denied) {
                  await provider.openSystemSettings();
                }
              }
            },
            activeTrackColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBanner(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.errorColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.notificationsDisabled,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.notificationsDisabledDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryOf(context),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final userId =
                          context.read<AuthProvider>().userModel?.uid;
                      if (userId == null) return;
                      final provider = context.read<NotificationProvider>();
                      final settings = await provider.currentSettings();
                      // Once the OS has recorded an explicit denial it will
                      // silently no-op every subsequent requestPermission()
                      // call, so we send the user to system Settings.
                      if (settings.authorizationStatus ==
                          AuthorizationStatus.denied) {
                        await provider.openSystemSettings();
                      } else {
                        await provider.recheckPermission(userId);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.enableNotifications,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildSectionLabel(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textTertiaryOf(context),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildMealRemindersCard(
    BuildContext context,
    NotificationProvider provider,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
        ),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Column(
        children: [
          _buildMealReminderTile(
            context: context,
            label: l10n.breakfastReminder,
            icon: Icons.wb_sunny_outlined,
            color: AppTheme.breakfastColor,
            enabled: provider.breakfastEnabled,
            time: provider.breakfastTime,
            onToggle: provider.toggleBreakfastReminder,
            onTimeTap: () =>
                _pickTime(context, provider.breakfastTime, (time) {
              provider.setBreakfastTime(time);
            }),
          ),
          _buildDivider(context),
          _buildMealReminderTile(
            context: context,
            label: l10n.lunchReminder,
            icon: Icons.light_mode_outlined,
            color: AppTheme.lunchColor,
            enabled: provider.lunchEnabled,
            time: provider.lunchTime,
            onToggle: provider.toggleLunchReminder,
            onTimeTap: () =>
                _pickTime(context, provider.lunchTime, (time) {
              provider.setLunchTime(time);
            }),
          ),
          _buildDivider(context),
          _buildMealReminderTile(
            context: context,
            label: l10n.dinnerReminder,
            icon: Icons.dark_mode_outlined,
            color: AppTheme.dinnerColor,
            enabled: provider.dinnerEnabled,
            time: provider.dinnerTime,
            onToggle: provider.toggleDinnerReminder,
            onTimeTap: () =>
                _pickTime(context, provider.dinnerTime, (time) {
              provider.setDinnerTime(time);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMealReminderTile({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
    required TimeOfDay time,
    required Future<void> Function(bool) onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (enabled)
                  GestureDetector(
                    onTap: onTimeTap,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _formatTime(time),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onToggle,
            activeTrackColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialAlertsCard(
    BuildContext context,
    NotificationProvider provider,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
        ),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Column(
        children: [
          _buildSocialAlertTile(
            context: context,
            label: l10n.newRecipeAlerts,
            icon: Icons.restaurant_menu,
            color: AppTheme.primaryColor,
            enabled: provider.newRecipeAlerts,
            onToggle: provider.toggleNewRecipeAlerts,
          ),
          _buildDivider(context),
          _buildSocialAlertTile(
            context: context,
            label: l10n.commentAlerts,
            icon: Icons.comment_outlined,
            color: AppTheme.secondaryColor,
            enabled: provider.commentAlerts,
            onToggle: provider.toggleCommentAlerts,
          ),
          _buildDivider(context),
          _buildSocialAlertTile(
            context: context,
            label: l10n.followerAlerts,
            icon: Icons.person_add_outlined,
            color: AppTheme.starColor,
            enabled: provider.followerAlerts,
            onToggle: provider.toggleFollowerAlerts,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialAlertTile({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
    required Future<void> Function(bool) onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onToggle,
            activeTrackColor: AppTheme.primaryColor,
          ),
        ],
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    void Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      onPicked(picked);
    }
  }
}
