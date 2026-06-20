# Troubleshooting Guide

## Common Issues

### 1. App Shows Loading Forever

**Symptoms:** The dashboard or transaction list displays a spinner indefinitely and never shows data.

**Cause:** The internal data stream failed to emit its initial value. This was a known bug (now fixed) where the broadcast stream lost its first event when no listener was subscribed.

**Fixes:**
1. **Restart the app** — fully close and reopen
2. **Clear app data:** Settings → Apps → TrackIO → Storage → Clear data
3. **Reinstall:** Uninstall and install the latest APK version

**If the issue persists** after updating to the latest version, verify the database was created:
```bash
# Using Android Debug Bridge
adb shell
run-as com.trackio.app
ls databases/
```

---

### 2. OCR Cannot Read the Receipt

**Symptoms:** The scanned receipt shows wrong store name, date, or amount.

**Common causes & solutions:**

| Issue | Solution |
|---|---|
| **Wrong text detected** | Ensure the receipt is flat, well-lit, and in focus |
| **Detects quantity instead of total** | This has been fixed in the latest version. The app now prioritizes "total" keywords, "kembali" context, and bottom-of-receipt scanning |
| **Blurry image** | Hold the camera steady or tap to focus before capturing |
| **Receipt is too long / folded** | Unfold the receipt and place it on a flat, high-contrast surface |
| **Amount is 0 or wrong** | Manually edit the amount in the result card before saving |

**Workaround:** The OCR result is fully editable — you can correct any field before confirming the transaction.

---

### 3. AI Chat Returns "Gagal menghubungi AI"

**Symptoms:** The AI responds with a failure message.

**Causes & solutions:**

| Cause | Solution |
|---|---|
| **No internet connection** | Check your WiFi or mobile data connection |
| **Invalid API key** | Go to Chat → Settings (gear icon) → verify the API key. Obtain a free key from [Google AI Studio](https://aistudio.google.com/) |
| **API key quota exceeded** | Free tier has rate limits. Wait a few minutes or upgrade |
| **API not enabled** | Enable the Generative Language API in [Google Cloud Console](https://console.cloud.google.com/apis/library/generativelanguage.googleapis.com) |
| **Wrong model region** | Ensure your API key is created for the correct region (try `us-central1` if unsure) |

---

### 4. Database Error on Launch

**Symptoms:** The app shows an error screen saying "Database tidak dapat dimuat" and closes.

**Causes & solutions:**

| Cause | Solution |
|---|---|
| **Corrupted database file** | Clear app data: Settings → Apps → TrackIO → Storage → Clear data |
| **Insufficient storage** | Free up device storage space |
| **Permission denied** | Ensure storage permissions are granted (Android 11+) |
| **Incompatible OS version** | TrackIO requires Android API 21+ (Android 5.0+) |

---

### 5. APK Build Fails

**Symptoms:** `flutter build apk` returns errors.

**Solutions:**

```bash
# Clean build cache
flutter clean

# Re-install dependencies
flutter pub get

# Build again
flutter build apk --debug
```

**Common Gradle errors:**

| Error | Solution |
|---|---|
| `Could not find method compile()` | Update Gradle version in `android/build.gradle.kts` |
| `Minimum supported Gradle version` | Run `flutter upgrade` or update Gradle wrapper |
| `Invalid keystore format` | Delete `android/app/debug.keystore` and rebuild (it regenerates automatically) |
| `java.lang.OutOfMemoryError` | Increase JVM heap in `android/gradle.properties`: `org.gradle.jvmargs=-Xmx4g` |

---

### 6. Transactions Not Persisting After Restart

**Symptoms:** Transactions added in a session disappear when the app is restarted.

**Cause (fixed):** Previously, the broadcast stream in the repository would lose its initial emission if no listener was subscribed. The app now uses an `async*` generator that always yields the initial data from the database before subscribing to live updates.

**If still experiencing issues:**
1. Verify the database file exists (see issue #1)
2. Check if the app has storage permissions
3. Ensure the device has sufficient free storage

---

### 7. Korean / Chinese Characters in Receipts

**Symptoms:** OCR shows incorrect characters on non-English receipts.

**Solution:** Google ML Kit supports multiple languages, but the app currently processes all text without language hint. For receipts in mixed languages, the text recognition may be less accurate. Manual correction is always available in the result card.

---

### 8. App Crashes on Specific Screens

**Symptoms:** The app crashes when navigating to a particular screen.

**Solutions:**

| Screen | Likely Cause | Fix |
|---|---|---|
| **Dashboard** | Database not initialized / empty | Clear app data → restart |
| **AI Chat** | Missing or invalid API key | Configure a valid API key |
| **OCR** | Camera permission denied | Grant camera/gallery permissions in system settings |
| **Score** | No transaction data | Add at least one transaction to generate a score |

**General fix for any crash:**
```bash
flutter clean
flutter pub get
flutter run
```

---

### 9. Theme / Color Issues

**Symptoms:** The app still shows green colors after update.

**Fix:** The old green theme was replaced with a dark teal theme. If you see green after updating:
1. Uninstall the old version completely
2. Rebuild with `flutter clean && flutter build apk`
3. Install the fresh APK

---

## Getting Help

If the issue is not listed here:

1. **Check the repository Issues page** — your problem may already be reported
2. **Create a new issue** with:
   - Device model and Android version
   - App version (build number)
   - Steps to reproduce
   - Screenshots or screen recording if applicable
