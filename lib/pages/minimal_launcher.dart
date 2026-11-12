import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/usage_limit_provider.dart';
import 'usage_settings.dart';

class MinimalLauncherPage extends StatelessWidget {
  const MinimalLauncherPage({super.key, this.isManual = false});

  final bool isManual;

  @override
  Widget build(BuildContext context) {
    return Consumer<UsageLimitProvider>(
      builder: (context, usage, _) => Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        appBar: isManual
            ? AppBar(
                backgroundColor: const Color(0xFFFAF7F2),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close Minimal Launcher',
                ),
                title: const Text(
                  'Minimal Launcher',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                actions: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Close'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF163223),
                    ),
                  ),
                ],
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const Icon(
                  Icons.spa_outlined,
                  size: 38,
                  color: Color(0xFF163223),
                ),
                const SizedBox(height: 18),
                const Text(
                  'A little more space.',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF163223),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isManual
                      ? 'Your selected essential apps are gathered here.'
                      : 'You’ve reached today’s 5-hour combined app limit. '
                            'Your essential apps are still here.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 26),
                if (usage.essentialPackages.isEmpty)
                  _emptyEssentials(context, compact: isManual)
                else
                  Expanded(
                    flex: 3,
                    child: ListView(
                      children: usage.launchableApps
                          .where(
                            (app) => usage.essentialPackages.contains(
                              app.packageName,
                            ),
                          )
                          .map(
                            (app) => Card(
                              color: Colors.white,
                              elevation: 0,
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFE9F0E9),
                                  child: Icon(
                                    Icons.apps_rounded,
                                    color: Color(0xFF163223),
                                  ),
                                ),
                                title: Text(
                                  app.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () async {
                                  try {
                                    await usage.launchApp(app.packageName);
                                  } catch (error) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Could not open ${app.label}: $error',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                if (usage.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    usage.errorMessage!,
                    style: const TextStyle(color: Color(0xFF9C3025)),
                  ),
                ],
                const Spacer(),
                Center(
                  child: Text(
                    isManual
                        ? 'Opened manually · Day ${usage.cycleDay} of 7'
                        : 'Day ${usage.cycleDay} of 7 · ${usage.isUnrestrictedDay ? 'unrestricted day' : 'daily limit reached'}',
                    style: const TextStyle(color: Color(0xFF66716A)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: usage.refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh usage'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const UsageSettingsPage(),
                    ),
                  ),
                  child: const Center(child: Text('Manage essential apps')),
                ),
                if (isManual) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Exit Pause Mode & Return'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF163223),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyEssentials(BuildContext context, {required bool compact}) {
    return Expanded(
      flex: 3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!compact) ...[
              const Icon(
                Icons.apps_rounded,
                size: 38,
                color: Color(0xFF66716A),
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              'No essential apps selected yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF66716A)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const UsageSettingsPage(),
                ),
              ),
              child: const Text('Choose essential apps'),
            ),
          ],
        ),
      ),
    );
  }
}
