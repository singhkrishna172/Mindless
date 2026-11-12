import 'package:flutter/services.dart';

class InstalledApp {
  const InstalledApp({required this.packageName, required this.label});

  final String packageName;
  final String label;
}

class AppUsage {
  const AppUsage({
    required this.packageName,
    required this.label,
    required this.usage,
  });

  final String packageName;
  final String label;
  final Duration usage;
}

class UsageOverview {
  const UsageOverview({
    required this.todayUsage,
    required this.lastSevenDays,
    required this.mostUsedApps,
  });

  final Duration todayUsage;
  final List<Duration> lastSevenDays;
  final List<AppUsage> mostUsedApps;
}

class DeviceUsageService {
  static const MethodChannel _channel = MethodChannel('mindless/device_usage');

  Future<Map<String, dynamic>> getConfiguration() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'getConfiguration',
    );
    return result ?? <String, dynamic>{};
  }

  Future<void> saveConfiguration({
    required String cycleStartDate,
    required Set<String> essentialPackages,
  }) {
    return _channel.invokeMethod<void>('saveConfiguration', {
      'cycleStartDate': cycleStartDate,
      'essentialPackages': essentialPackages.toList(),
    });
  }

  Future<bool> hasUsageAccess() async {
    return await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
  }

  Future<bool> isDefaultLauncher() async {
    return await _channel.invokeMethod<bool>('isDefaultLauncher') ?? false;
  }

  Future<int> getTodayUsageMilliseconds() async {
    return await _channel.invokeMethod<int>('getTodayUsageMilliseconds') ?? 0;
  }

  Future<UsageOverview> getUsageOverview() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'getUsageOverview',
    );
    if (result == null) {
      throw PlatformException(
        code: 'EMPTY_USAGE_OVERVIEW',
        message: 'Android returned no usage overview.',
      );
    }

    final weeklyUsage =
        result['lastSevenDaysMilliseconds'] as List<dynamic>? ?? const [];
    final mostUsedApps = result['mostUsedApps'] as List<dynamic>? ?? const [];

    return UsageOverview(
      todayUsage: Duration(
        milliseconds: result['todayUsageMilliseconds'] as int,
      ),
      lastSevenDays: weeklyUsage
          .map((milliseconds) => Duration(milliseconds: milliseconds as int))
          .toList(growable: false),
      mostUsedApps: mostUsedApps
          .map((item) {
            final app = item as Map<Object?, Object?>;
            return AppUsage(
              packageName: app['packageName']! as String,
              label: app['label']! as String,
              usage: Duration(milliseconds: app['usageMilliseconds']! as int),
            );
          })
          .toList(growable: false),
    );
  }

  Future<List<InstalledApp>> getLaunchableApps() async {
    final result = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'getLaunchableApps',
    );
    return (result ?? const <Map<Object?, Object?>>[])
        .map(
          (app) => InstalledApp(
            packageName: app['packageName']! as String,
            label: app['label']! as String,
          ),
        )
        .toList(growable: false);
  }

  Future<void> openUsageSettings() {
    return _channel.invokeMethod<void>('openUsageSettings');
  }

  Future<void> openHomeSettings() {
    return _channel.invokeMethod<void>('openHomeSettings');
  }

  Future<void> launchApp(String packageName) {
    return _channel.invokeMethod<void>('launchApp', <String, Object>{
      'packageName': packageName,
    });
  }
}
