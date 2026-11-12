import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/usage_limit_provider.dart';
import '../services/device_usage_service.dart';

class UsageSettingsPage extends StatefulWidget {
  const UsageSettingsPage({super.key});

  @override
  State<UsageSettingsPage> createState() => _UsageSettingsPageState();
}

class _UsageSettingsPageState extends State<UsageSettingsPage>
    with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.resumed) {
      context.read<UsageLimitProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsageLimitProvider>(
      builder: (context, usage, _) => Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF7F2),
          title: const Text('Usage limits'),
        ),
        body: usage.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _summaryCard(usage),
                  const SizedBox(height: 16),
                  if (usage.errorMessage != null)
                    _messageCard(usage.errorMessage!, isError: true),
                  if (!usage.isAndroid)
                    _messageCard(
                      'Device usage tracking and launcher features are currently Android-only.',
                    )
                  else ...[
                    _permissionCard(
                      context,
                      title: 'Usage access',
                      description: usage.hasUsageAccess
                          ? 'MindLess can read today’s combined app usage.'
                          : 'Allow usage access to measure total time across apps.',
                      enabled: usage.hasUsageAccess,
                      buttonLabel: usage.hasUsageAccess
                          ? 'Granted'
                          : 'Grant access',
                      onPressed: usage.openUsageSettings,
                    ),
                    const SizedBox(height: 12),
                    _permissionCard(
                      context,
                      title: 'Minimal launcher',
                      description: usage.isDefaultLauncher
                          ? 'MindLess is your home app. The essential-app screen appears when you return to Home after reaching the limit.'
                          : 'Choose MindLess as your home app to see essential apps on the Home screen after reaching the limit.',
                      enabled: usage.isDefaultLauncher,
                      buttonLabel: usage.isDefaultLauncher
                          ? 'Selected'
                          : 'Choose home app',
                      onPressed: usage.openHomeSettings,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ESSENTIAL APPS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF66716A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose the apps that remain available in the minimal launcher.',
                      style: TextStyle(color: Color(0xFF66716A)),
                    ),
                    const SizedBox(height: 8),
                    if (usage.launchableApps.isEmpty)
                      _messageCard(
                        'No launchable apps were found on this device.',
                      )
                    else
                      ...usage.launchableApps.map(
                        (app) => _appTile(context, usage, app),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Android does not let a regular app force-close or block other apps. '
                      'The limit switches the MindLess home screen when you return to Home.',
                      style: TextStyle(
                        color: Color(0xFF66716A),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _summaryCard(UsageLimitProvider usage) {
    final cycleStatus = usage.isUnrestrictedDay
        ? 'Day 7 of 7 · unrestricted'
        : 'Day ${usage.cycleDay} of 7 · limits active';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF163223),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily combined app limit',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          const Text(
            '5 hours',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(cycleStatus, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 2),
          Text(
            'Today: ${_formatDuration(usage.todayUsage)}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _permissionCard(
    BuildContext context, {
    required String title,
    required String description,
    required bool enabled,
    required String buttonLabel,
    required Future<void> Function() onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                enabled ? Icons.check_circle : Icons.info_outline,
                color: enabled
                    ? const Color(0xFF287344)
                    : const Color(0xFF8A6A32),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Color(0xFF66716A))),
          if (!enabled) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                try {
                  await onPressed();
                } catch (error) {
                  if (context.mounted) {
                    _showError(context, error);
                  }
                }
              },
              child: Text(buttonLabel),
            ),
          ],
        ],
      ),
    );
  }

  Widget _appTile(
    BuildContext context,
    UsageLimitProvider usage,
    InstalledApp app,
  ) {
    final selected = usage.essentialPackages.contains(app.packageName);
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: selected,
      title: Text(app.label),
      secondary: const Icon(Icons.apps_rounded, color: Color(0xFF163223)),
      activeColor: const Color(0xFF163223),
      onChanged: (value) async {
        try {
          await usage.setEssential(app.packageName, value ?? false);
        } catch (error) {
          if (context.mounted) {
            _showError(context, error);
          }
        }
      },
    );
  }

  Widget _messageCard(String message, {bool isError = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFDE8E5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? const Color(0xFF9C3025) : const Color(0xFF66716A),
        ),
      ),
    );
  }

  void _showError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not update settings: $error')),
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}m';
}
