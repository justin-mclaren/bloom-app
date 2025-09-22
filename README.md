# SkincareAI

SwiftUI prototype that captures three guided selfies, runs a stubbed on-device skin analysis, and returns a four-step AM/PM routine driven by local JSON rules. Builds are generated with Tuist and delivered through Codemagic.

## Getting started

1. Install Tuist (once):
   ```bash
   brew install tuist || true
   ```
2. Bootstrap the workspace:
   ```bash
   tuist install
   tuist generate
   ```
3. Open the generated `SkincareAI.xcworkspace` in Xcode 15.4 or later and select the **SkincareAI** scheme.

## Running tests

```bash
xcodebuild -scheme SkincareAI -destination 'platform=iOS Simulator,name=iPhone 16' clean test
```

## Codemagic CI

Codemagic runs `tuist generate`, simulator tests on pull requests, and archives + uploads to TestFlight on `main`. Configure the following secrets in the Codemagic UI before running builds:

- `APP_STORE_CONNECT_PRIVATE_KEY` (base64 encoded `.p8`)
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`

## Privacy checklist

- Camera access prompt explains on-device analysis.
- “Delete photos after analysis (recommended)” is enabled by default and prevents disk writes.
- A Settings screen allows clearing any stored photos.
- Results include the disclaimer “Not medical advice.”
