# Mobile Deployment Guide — GeneBreed AI (Flutter → Codemagic)

This walks through everything needed to get `mobile/` building signed Android (APK/AAB) and
iOS (IPA) artifacts on Codemagic, using the `codemagic.yaml` already committed at the repo root.

## 1. What's already in place

- `mobile/` — a Flutter app (Dart 3.12 / Flutter 3.44 stable) implementing all 9 GeneBreed AI
  modules natively, sharing the same domain data and genetics engine as the web app.
- `mobile/android/` — Gradle Kotlin DSL build, `compileSdk`/`targetSdk` pinned to whatever the
  installed Flutter SDK currently ships (36 as of Flutter 3.44 — i.e. always the current Android
  API level Flutter officially supports), `minSdk` 24. Release builds are minified with R8
  (`isMinifyEnabled`/`isShrinkResources`) and read signing config from `android/key.properties`,
  which is **git-ignored** — see §2.
- `mobile/ios/` — bundle identifier `com.genebreedai.genebreedAi`, deployment target iOS 13.0,
  `NSPhotoLibraryUsageDescription` set for the Field Notebook's image picker.
- `codemagic.yaml` — an `android-workflow` and an `ios-workflow`, each running `flutter pub get`,
  `flutter analyze`, `flutter test`, then a release build.
- App icon: `mobile/assets/icon/app_icon.png` (+ `app_icon_foreground.png` for Android adaptive
  icons), wired through `flutter_launcher_icons` in `pubspec.yaml`. Already generated into
  `android/app/src/main/res/mipmap-*` and `ios/Runner/Assets.xcassets/AppIcon.appiconset/`; re-run
  `dart run flutter_launcher_icons` after changing the source image.

## 2. Android signing

Release builds are signed using `android/key.properties` (never committed — see
`android/.gitignore`) plus a `.jks` keystore file. `android/key.properties.example` documents the
expected format.

### Option A — Codemagic builds the signed artifact (recommended)

1. Generate a keystore once (locally, or reuse the one already generated for you — see the
   delivery notes for this task):
   ```bash
   keytool -genkeypair -v -keystore genebreed-ai-release.jks -alias genebreedai \
     -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Base64-encode it: `base64 -w0 genebreed-ai-release.jks > genebreed-ai-release.jks.base64`.
3. In Codemagic: **Team settings → Environment variables** → create a group named
   `android_signing` (this exact name is referenced in `codemagic.yaml`) containing:
   - `ANDROID_KEYSTORE` — paste the base64 string from step 2 (mark **Secure**).
   - `ANDROID_KEYSTORE_PASSWORD` — the keystore password (**Secure**).
   - `ANDROID_KEY_ALIAS` — `genebreedai` (or whatever alias you used).
   - `ANDROID_KEY_PASSWORD` — the key password (**Secure**; same as the keystore password for a
     modern PKCS12 keystore, which `keytool` creates by default).
4. Run the `android-workflow`. Its first script decodes `ANDROID_KEYSTORE` back into a `.jks` file
   and writes `key.properties` at build time — nothing secret ever touches git.

### Option B — build locally

Copy `android/key.properties.example` to `android/key.properties`, fill in real values, place the
`.jks` file where `storeFile` points (relative to `android/app/`), then run
`flutter build apk --release` / `flutter build appbundle --release` from `mobile/`.

**Never commit `key.properties` or any `.jks` file.** Both are already covered by
`android/.gitignore`.

## 3. iOS signing

iOS code signing requires an active **Apple Developer Program** membership — this cannot be
provisioned from a text-based coding session, so the steps below are things you (the account
holder) need to do once in the Apple/App Store Connect and Codemagic dashboards.

1. **Register the App ID** in the Apple Developer portal: `com.genebreedai.genebreedAi`
   (must match `ios/Runner.xcodeproj`'s `PRODUCT_BUNDLE_IDENTIFIER`, already set to this value).
2. **Create the app record** in App Store Connect with the same bundle ID.
3. **Create an App Store Connect API key**: App Store Connect → Users and Access → Integrations →
   App Store Connect API → generate a key with the **App Manager** role. Note the Key ID, Issuer
   ID, and download the `.p8` private key file.
4. **Register the integration in Codemagic**: Team settings → Integrations → App Store Connect →
   add the Issuer ID, Key ID, and the `.p8` contents, and name the integration
   `codemagic_asc_api_key` (this exact name is referenced by `codemagic.yaml`'s
   `integrations.app_store_connect` key — rename both together if you use a different name).
5. That's it — Codemagic's `ios_signing` block plus the `app-store-connect fetch-signing-files` /
   `keychain add-certificates` / `xcode-project use-profiles` steps in `codemagic.yaml` handle
   certificate and provisioning-profile creation automatically on every build. No manual `.p12`
   certificates or `.mobileprovision` files need to be generated or stored.

## 4. Triggering builds

- Push to the branch Codemagic is watching (or trigger manually from the Codemagic dashboard).
- `android-workflow` produces `.apk` (sideload/testing) and `.aab` (Play Store upload) artifacts.
- `ios-workflow` produces a `.ipa`, optionally auto-published to TestFlight
  (`submit_to_testflight: true` is already set; flip `submit_to_app_store: true` when ready for
  review).

## 5. Publishing to the stores (beyond CI)

- **Play Store**: create the app in Google Play Console, upload the first `.aab` manually once to
  establish the listing, then optionally uncomment the `google_play` publishing block in
  `codemagic.yaml` with a service-account JSON credential for fully automated releases thereafter.
- **App Store**: TestFlight publishing is already wired via the `app_store_connect` integration;
  submitting for App Store review the first time still requires filling out App Store listing
  metadata (screenshots, description, privacy details) in App Store Connect.

## 6. Local development without any signing set up

`flutter run` (debug) and `flutter build apk --debug` work with zero configuration — Android debug
builds use Flutter's built-in debug keystore automatically, and iOS Simulator builds don't require
a distribution certificate at all. Signing only matters for release/distribution artifacts.
