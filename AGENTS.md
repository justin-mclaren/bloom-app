AGENTS.md — Skincare AI (iOS, Swift + Core ML, Codemagic)

This file is the single source of truth for async agents working on the project. It defines the scope, constraints, checklists, commands, and verification steps. Follow it exactly. Prefer small, atomic PRs.

⸻

0) Mission & Non‑Goals

Mission: Ship an iOS MVP that captures selfies, runs a rule‑based (mock) analysis, and outputs a 4‑step routine, with Codemagic CI delivering builds to TestFlight.

Non‑Goals (for this iteration): Android, real ML inference, cloud storage, commerce.

⸻

1) Repo Conventions
•Package manager: SwiftPM only. No CocoaPods.
•Project generator: Tuist. The committed source of truth is under /Tuist and /Projects/**. Generated Xcode files should not be committed.
•Branching: feature branches → PR → squash merge into main.
•Code style: Swift 5.10+, SwiftUI; prefer actor for concurrency boundaries.
•Localization: EN only (scaffold Localizable.strings).

⸻

2) Targets / Modules

Projects/
  App/                # SwiftUI app shell & navigation
  CameraFeature/      # AVFoundation preview + photo capture + lighting check
  MLCore/             # Stub analyzer (mock). Real ML in v2.
  Recommendations/    # Rule engine + product store (local JSON)
  DesignSystem/       # UI components (Analyzing banner, trait bars, cards)
  DataKit/            # Local persistence (JSON files) + privacy toggle
Tuist/                # Project.swift, Dependencies.swift, Config.swift
codemagic.yaml        # CI pipeline

⸻

3) Task Board (Iteration 1)
1.Scaffold Tuist project (targets above). ✅ Definition of Done (DoD): tuist generate succeeds locally.
2.Camera preview & capture (front camera) with guidance overlay + capture 3 photos (front/left/right). DoD: tap “Take Photo” 3× navigates to Questionnaire.
3.Lighting check: histogram‑based; show prompt if too dark/bright; allow retake. DoD: simulate by covering camera → prompt shows.
4.Questionnaire: goals (multi‑select), budget (segmented), fragrance‑free (toggle). DoD: values persisted in memory for this session.
5.Mock analyzer: 400–600ms delay returns deterministic Traits. DoD: returns struct with 6 fields + quality score.
6.Recommendations: load products.json; apply rules; output ≤ 4 steps including SPF. DoD: routine renders product names + rationale.
7.Privacy: default ON “Delete photos after analysis”. If ON, images are not written to disk. DoD: project has zero writes to Documents when ON.
8.Results UI: trait bars + routine card list. DoD: list shows 6 bars + 4 steps.
9.Codemagic CI: build tests on PR, archive + TestFlight on main. DoD: one successful TF upload from CI.

⸻

4) Commands & Local Environment

# Install Tuist
brew install tuist || true

# Bootstrap project (must succeed, otherwise PR is blocked)
tuist install
tuist generate

# Build & test locally (pick the generated workspace or project)
xcodebuild -list
xcodebuild -scheme SkincareAI -destination 'platform=iOS Simulator,name=iPhone 16' clean test

# Run app
open SkincareAI.xcworkspace  # or .xcodeproj if generated

⸻

5) Codemagic CI/CD

Secrets that must exist in Codemagic:
•APP_STORE_CONNECT_PRIVATE_KEY (base64 of AuthKey_XXXX.p8)
•APP_STORE_CONNECT_KEY_ID
•APP_STORE_CONNECT_ISSUER_ID

Expected behavior:
•PRs: CI runs build/tests only (publishing OFF in Codemagic UI).
•main pushes: CI archives and uploads to TestFlight.

Log checkpoints (must verify after each run):
•tuist install and tuist generate completed
•xcodebuild ... clean test succeeded with tests passed
•Archive created at $CM_BUILD_DIR/App.xcarchive
•Upload to TestFlight step finished (or artifact .ipa uploaded)

⸻

6) Data Contracts

// MLCore
public struct Traits: Codable, Equatable {
  public var oilyTzone: Double
  public var dryness: Double
  public var acneLikelihood: Double
  public var redness: Double
  public var wrinkles: Double
  public var hyperpigmentation: Double
  public var sensitivityRisk: Double
  public var qualityScore: Double
  public static let empty = Traits(oilyTzone:0.5, dryness:0.5, acneLikelihood:0.5, redness:0.5, wrinkles:0.5, hyperpigmentation:0.5, sensitivityRisk:0.5, qualityScore:0.8)
}

public struct Questionnaire: Codable {
  public var goals: [String]      // e.g., "acne", "hydration"
  public var budget: String       // "low" | "mid" | "high"
  public var fragranceFreeOnly: Bool
}

public struct Product: Codable, Identifiable {
  public let id: String
  public let brand: String
  public let name: String
  public let category: String     // cleanser|treatment|moisturizer|spf
  public let price: Double
  public let tags: [String]
  public let spf: Int?
}

products.json sample rows:

[
  {"id":"c1","brand":"Acme","name":"Gentle Gel Cleanser","category":"cleanser","price":12.0,"tags":["fragrance-free"],"spf":null},
  {"id":"t1","brand":"Acme","name":"2% BHA Serum","category":"treatment","price":14.0,"tags":["bha","acne","fragrance-free"],"spf":null},
  {"id":"m1","brand":"Acme","name":"Lightweight Moisturizer","category":"moisturizer","price":15.0,"tags":["hydrating","fragrance-free"],"spf":null},
  {"id":"s1","brand":"Acme","name":"Daily SPF 50","category":"spf","price":17.0,"tags":["fragrance-free"],"spf":50}
]

⸻

7) Rule Engine (MVP)

Pseudocode:

start with empty routine
add cleanser (fragrance-free if requested)
if 'acne' in goals -> add treatment with tag 'bha' or 'acne'
else if 'tone' in goals -> add 'vitc' or 'niacinamide'
else if 'hydration' in goals -> prefer 'hydrating' moisturizer
add moisturizer (rich if dryness>0.6 else lightweight)
add SPF to AM routine always
limit to 4 total steps

DoD: Given Traits(acneLikelihood>0.55) and goals includes acne, routine contains a BHA treatment and SPF.

⸻

8) UI Contract
•CameraCaptureView: shows preview + circular guide. Button text: “Take Photo (1/3)”. After 3 photos → push Questionnaire.
•QuestionnaireView: Multi-select goals, segmented budget, fragrance toggle. Button: “See Results”.
•AnalyzingBanner: shows while mock analyzer runs (400–600 ms).
•ResultsView: trait bars for 6 traits; routine cards with STEP: Product Name and one‑line rationale.
•SettingsView: toggle “Delete photos after analysis (recommended)” default ON; “Delete All Data” button.

⸻

9) Tests (must pass in CI)
•Unit: RuleEngineTests →
•when goals=[“acne”], returns a treatment containing tag bha and includes SPF.
•when fragranceFreeOnly=true, all picks contain fragrance-free tag.
•routine count ≤ 4.
•UI smoke (XCTest minimal): app launches, navigates Capture → Questionnaire → Results without crash.

⸻

10) Privacy & Safety Checklist
•No network calls from analyzer or camera flow.
•Photos never written to disk if delete toggle ON (default).
•NSCameraUsageDescription present and truthful.
•Results copy includes “Not medical advice.”

⸻

11) PR Template (copy into .github/pull_request_template.md)

## What
- Brief description

## Why
- Link to task / acceptance criteria

## How
- Key changes

## Screenshots / Videos
- [ ] Added

## Checklists
- [ ] `tuist generate` succeeds locally
- [ ] Unit tests pass locally
- [ ] No new warnings in build
- [ ] Privacy checklist satisfied

⸻

12) Troubleshooting Runbook
•CI fails at tuist generate: ensure Tuist/Dependencies.swift exists; run tuist install locally and commit lock if used.
•Signing errors: confirm Codemagic has ASC API key; App ID for com.yourorg.skincareai exists; xcode_automatic_signing: true set.
•Simulator test timeout: lower test simulator device to iPhone 15; ensure no camera hardware access in tests.
•Routine empty: verify products.json is packaged as a resource in Recommendations target.

⸻

13) Deliverables for This Iteration
•Working app build (simulator) with flows above
•Passing unit tests in CI
•First TestFlight build from main
•Short README with run instructions

⸻

14) Handoff Notes (Next Iteration)
•Replace mock analyzer with Core ML model (.mlmodel) and Vision pipeline.
•Persist assessments; add weekly progress and before/after gallery.
•Expand catalog and add ingredient metadata.
