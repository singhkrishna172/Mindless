import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../services/device_usage_service.dart';

class UsageLimitProvider extends ChangeNotifier {
  UsageLimitProvider({DeviceUsageService? service})
    : _service = service ?? DeviceUsageService();

  static const Duration defaultDailyLimit = Duration(hours: 5);
  Duration _dailyLimit = defaultDailyLimit;

  final DeviceUsageService _service;

  DateTime? _cycleStartDate;
  Duration _todayUsage = Duration.zero;
  List<Duration> _lastSevenDaysUsage = const [];
  List<AppUsage> _mostUsedApps = const [];
  List<InstalledApp> _launchableApps = const [];
  Set<String> _essentialPackages = {};
  bool _hasUsageAccess = false;
  bool _isDefaultLauncher = false;
  bool _isLoading = true;
  String? _errorMessage;

  Duration get dailyLimit => _dailyLimit;

  void setDailyLimit(Duration limit) {
    if (limit > Duration.zero) {
      _dailyLimit = limit;
      notifyListeners();
    }
  }

  DateTime? get cycleStartDate => _cycleStartDate;
  Duration get todayUsage => _todayUsage;
  List<Duration> get lastSevenDaysUsage => _lastSevenDaysUsage;
  List<AppUsage> get mostUsedApps => _mostUsedApps;
  List<InstalledApp> get launchableApps => _launchableApps;
  Set<String> get essentialPackages => Set.unmodifiable(_essentialPackages);
  bool get hasUsageAccess => _hasUsageAccess;
  bool get isDefaultLauncher => _isDefaultLauncher;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isUnrestrictedDay => cycleDay == 7;
  bool get isLimitReached =>
      isAndroid && !isUnrestrictedDay && _todayUsage >= dailyLimit;
  Duration get remainingTime {
    final remaining = dailyLimit - _todayUsage;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  int get cycleDay => cycleDayFor(_cycleStartDate, DateTime.now());

  static int cycleDayFor(DateTime? cycleStartDate, DateTime date) {
    if (cycleStartDate == null) return 1;
    final start = DateTime(
      cycleStartDate.year,
      cycleStartDate.month,
      cycleStartDate.day,
    );
    final today = DateTime(date.year, date.month, date.day);
    final elapsedDays = today.difference(start).inDays;
    if (elapsedDays < 0) return 1;
    return (elapsedDays % 7) + 1;
  }

  Future<void> initialize() async {
    if (!isAndroid) {
      _errorMessage =
          'Device usage controls are currently available on Android.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final configuration = await _service.getConfiguration();
      final startDate = configuration['cycleStartDate'] as String?;
      _cycleStartDate = startDate == null
          ? _dateOnly(DateTime.now())
          : DateTime.parse(startDate);
      _essentialPackages = {
        for (final packageName
            in (configuration['essentialPackages'] as List<dynamic>? ??
                const <dynamic>[]))
          packageName as String,
      };
      if (startDate == null) {
        await _saveConfiguration();
      }
      await refresh();
    } on PlatformException catch (error) {
      _errorMessage = error.message ?? 'Could not load device usage settings.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (!isAndroid) return;
    try {
      _errorMessage = null;
      _hasUsageAccess = await _service.hasUsageAccess();
      _isDefaultLauncher = await _service.isDefaultLauncher();
      _launchableApps = await _service.getLaunchableApps();
      if (_hasUsageAccess) {
        final overview = await _service.getUsageOverview();
        _todayUsage = overview.todayUsage;
        _lastSevenDaysUsage = overview.lastSevenDays;
        _mostUsedApps = overview.mostUsedApps;
      } else {
        _todayUsage = Duration.zero;
        _lastSevenDaysUsage = const [];
        _mostUsedApps = const [];
      }
      _isLoading = false;
      notifyListeners();
    } on PlatformException catch (error) {
      _errorMessage = error.message ?? 'Could not refresh device usage.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setEssential(String packageName, bool isEssential) async {
    final previousPackages = _essentialPackages;
    final updatedPackages = Set<String>.of(_essentialPackages);
    if (isEssential) {
      updatedPackages.add(packageName);
    } else {
      updatedPackages.remove(packageName);
    }
    _essentialPackages = updatedPackages;
    notifyListeners();
    try {
      await _saveConfiguration();
    } on PlatformException catch (error) {
      _essentialPackages = previousPackages;
      _errorMessage = error.message ?? 'Could not save essential apps.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> openUsageSettings() => _service.openUsageSettings();

  Future<void> openHomeSettings() => _service.openHomeSettings();

  Future<void> launchApp(String packageName) => _service.launchApp(packageName);

  Future<void> _saveConfiguration() {
    return _service.saveConfiguration(
      cycleStartDate: _dateOnly(_cycleStartDate ?? DateTime.now())
          .toIso8601String()
          .substring(0, 10),
      essentialPackages: _essentialPackages,
    );
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
