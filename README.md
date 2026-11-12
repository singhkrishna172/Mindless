# MindLess

MindLess includes an Android daily usage limit and minimal launcher:

- The default daily limit is five hours combined across apps.
- Days 1–6 of the repeating seven-day cycle enforce the limit. Day 7 is
  unrestricted, and the cycle restarts automatically on day 8.
- Grant **Usage Access** and choose MindLess as the Android home app in Usage
  limits settings. Select the apps to keep available in the minimal launcher.
- Usage totals and essential-app selections are stored locally on the device.

Android requires the user to grant Usage Access and select a default home app.
A regular app cannot force-close or block other apps, so the minimal launcher
appears when the user returns to Home after the limit is reached. Device-wide
usage tracking and launcher support are currently Android-only.
