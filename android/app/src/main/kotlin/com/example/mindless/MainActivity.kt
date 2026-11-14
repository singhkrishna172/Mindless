package com.example.mindless

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "mindless/device_usage"
    private val preferences by lazy {
        getSharedPreferences("mindless_settings", MODE_PRIVATE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getConfiguration" -> {
                        result.success(
                            mapOf(
                                "cycleStartDate" to preferences.getString(
                                    "cycle_start_date",
                                    null,
                                ),
                                "essentialPackages" to preferences.getStringSet(
                                    "essential_packages",
                                    emptySet(),
                                )?.toList().orEmpty(),
                                "dailyLimitMinutes" to preferences.getInt(
                                    "daily_limit_minutes",
                                    -1,
                                ),
                                "lastLimitSetupDate" to preferences.getString(
                                    "last_limit_setup_date",
                                    null,
                                ),
                            ),
                        )
                    }

                    "saveConfiguration" -> {
                        val cycleStartDate = call.argument<String>("cycleStartDate")
                        val essentialPackages =
                            call.argument<List<String>>("essentialPackages")
                        val dailyLimitMinutes =
                            call.argument<Int>("dailyLimitMinutes") ?: -1
                        val lastLimitSetupDate =
                            call.argument<String>("lastLimitSetupDate")

                        if (cycleStartDate == null || essentialPackages == null) {
                            result.error(
                                "INVALID_CONFIGURATION",
                                "Cycle date and essential apps are required.",
                                null,
                            )
                        } else {
                            val editor = preferences.edit()
                                .putString("cycle_start_date", cycleStartDate)
                                .putStringSet(
                                    "essential_packages",
                                    essentialPackages.toSet(),
                                )
                            if (dailyLimitMinutes > 0) {
                                editor.putInt("daily_limit_minutes", dailyLimitMinutes)
                            }
                            if (lastLimitSetupDate != null) {
                                editor.putString("last_limit_setup_date", lastLimitSetupDate)
                            }
                            editor.apply()
                            result.success(null)
                        }
                    }

                    "hasUsageAccess" -> result.success(hasUsageAccess())
                    "isDefaultLauncher" -> result.success(isDefaultLauncher())
                    "getTodayUsageMilliseconds" -> {
                        if (!hasUsageAccess()) {
                            result.error(
                                "USAGE_ACCESS_REQUIRED",
                                "Grant Usage Access in Android settings first.",
                                null,
                            )
                        } else {
                            result.success(getTodayUsageMilliseconds())
                        }
                    }
                    "getUsageOverview" -> {
                        if (!hasUsageAccess()) {
                            result.error(
                                "USAGE_ACCESS_REQUIRED",
                                "Grant Usage Access in Android settings first.",
                                null,
                            )
                        } else {
                            result.success(getUsageOverview())
                        }
                    }

                    "getLaunchableApps" -> result.success(getLaunchableApps())
                    "openUsageSettings" -> openSettings(
                        result,
                        Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS),
                    )

                    "openHomeSettings" -> openSettings(
                        result,
                        Intent(Settings.ACTION_HOME_SETTINGS),
                    )

                    "launchApp" -> {
                        val packageName = call.argument<String>("packageName")
                        val launchIntent = packageName?.let {
                            packageManager.getLaunchIntentForPackage(it)
                        }
                        if (launchIntent == null) {
                            result.error(
                                "APP_NOT_LAUNCHABLE",
                                "The selected app is no longer available.",
                                null,
                            )
                        } else {
                            try {
                                startActivity(launchIntent)
                                result.success(null)
                            } catch (error: ActivityNotFoundException) {
                                result.error(
                                    "APP_NOT_LAUNCHABLE",
                                    error.message,
                                    null,
                                )
                            }
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(APP_OPS_SERVICE) as AppOpsManager
        return appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName,
        ) == AppOpsManager.MODE_ALLOWED
    }

    private fun isDefaultLauncher(): Boolean {
        val homeIntent = Intent(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_HOME)
            .addCategory(Intent.CATEGORY_DEFAULT)
        val homePackage = packageManager.resolveActivity(
            homeIntent,
            android.content.pm.PackageManager.MATCH_DEFAULT_ONLY,
        )?.activityInfo?.packageName
        return homePackage == packageName
    }

    private fun getTodayUsageMilliseconds(): Long {
        val now = System.currentTimeMillis()
        return getUsageStats(startOfDay(now), now).values.sum()
    }

    private fun getUsageOverview(): Map<String, Any> {
        val now = System.currentTimeMillis()
        val todayStart = startOfDay(now)
        val todayStats = getUsageStats(todayStart, now)
        val appLabels = getLaunchableApps().associate {
            it.getValue("packageName") to it.getValue("label")
        }
        val mostUsedApps = todayStats.entries
            .filter { it.value > 0L && appLabels.containsKey(it.key) }
            .sortedByDescending { it.value }
            .map { (appPackage, milliseconds) ->
                mapOf(
                    "packageName" to appPackage,
                    "label" to appLabels.getValue(appPackage),
                    "usageMilliseconds" to milliseconds,
                )
            }
        val lastSevenDays = (6 downTo 0).map { daysAgo ->
            val dayStart = java.util.Calendar.getInstance().apply {
                timeInMillis = todayStart
                add(java.util.Calendar.DAY_OF_YEAR, -daysAgo)
            }.timeInMillis
            val dayEnd = if (daysAgo == 0) {
                now
            } else {
                java.util.Calendar.getInstance().apply {
                    timeInMillis = dayStart
                    add(java.util.Calendar.DAY_OF_YEAR, 1)
                }.timeInMillis
            }
            getUsageStats(dayStart, dayEnd).values.sum()
        }

        return mapOf(
            "todayUsageMilliseconds" to todayStats.values.sum(),
            "lastSevenDaysMilliseconds" to lastSevenDays,
            "mostUsedApps" to mostUsedApps,
        )
    }

    private fun getUsageStats(start: Long, end: Long): Map<String, Long> {
        val usageStatsManager =
            getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        return usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            start,
            end,
        ).orEmpty()
            .asSequence()
            .filter { it.packageName != packageName }
            .groupBy { it.packageName }
            .mapValues { (_, stats) ->
                stats.sumOf { it.totalTimeInForeground.coerceAtLeast(0L) }
            }
    }

    private fun startOfDay(timestamp: Long): Long {
        return java.util.Calendar.getInstance().apply {
            timeInMillis = timestamp
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 0)
            set(java.util.Calendar.SECOND, 0)
            set(java.util.Calendar.MILLISECOND, 0)
        }.timeInMillis
    }

    private fun getLaunchableApps(): List<Map<String, String>> {
        val launcherIntent = Intent(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_LAUNCHER)
        return packageManager.queryIntentActivities(launcherIntent, 0)
            .asSequence()
            .map { result ->
                result.activityInfo.packageName to
                    result.loadLabel(packageManager).toString()
            }
            .filter { it.first != packageName }
            .distinctBy { it.first }
            .sortedBy { it.second.lowercase() }
            .map { (packageName, label) ->
                mapOf("packageName" to packageName, "label" to label)
            }
            .toList()
    }

    private fun openSettings(
        result: MethodChannel.Result,
        intent: Intent,
    ) {
        try {
            startActivity(intent)
            result.success(null)
        } catch (error: ActivityNotFoundException) {
            result.error("SETTINGS_UNAVAILABLE", error.message, null)
        }
    }
}
