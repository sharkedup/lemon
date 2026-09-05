# It's a Lemon

A whimsical SwiftUI iOS app: an animated lemon character that transforms into
other forms when the player taps secret dance-combo sequences.

Live on the App Store; iterating via TestFlight. Repo `sharkedup/lemon` is
**public** — treat every push as publishing.

- Bundle `com.kmsharkey.Lemon` · Team `QS983XC69J` · iOS 17+ · portrait only
- iPhone + iPad (`TARGETED_DEVICE_FAMILY: "1,2"`)

---

## Keeping these docs current

**Update `CLAUDE.md` when:**
- A form is added, removed, enabled, or shelved → update the shelved list below
- The add-a-form touch points change (e.g. the combo catalog refactor lands)
- The release pipeline changes — a new step, or a new place a version lives
- A new App Store asset requirement or rejection gotcha is discovered
- A convention changes

**Update `SEASONAL_STRATEGY.md` when:**
- One of its open questions gets decided
- A phase lands — move the now-true facts into this file and mark the phase done
- The `Availability` / `Event` / `Schedule` model changes

Do this **in the same change** that causes it, not as a follow-up pass.

A `.githooks/pre-commit` hook warns (never blocks) when a commit changes combo
entries, an `isEnabled` flag, or adds a Swift file without touching either doc.
It is deliberately narrow — it stays quiet for ordinary code changes. Enable it
once per clone:

```
git config core.hooksPath .githooks
```

---

## Layout

| File | What |
|---|---|
| `Lemon/ContentView.swift` | ~2000 lines: scene, all forms, combos, help page |
| `Lemon/PreviewGallery.swift` | Xcode previews of every form — dev only |
| `Lemon/ToneSynth.swift` | On-device tone synthesis |
| `Lemon/LemonApp.swift` | Entry point |
| `project.yml` | XcodeGen spec — `.xcodeproj` is generated |
| `docs/index.html` | App Store privacy policy, served via GitHub Pages |
| `SEASONAL_STRATEGY.md` | Planned time-gated holiday content (not yet built) |

Run `xcodegen generate` after adding files or changing `project.yml`. Not needed
for edits inside existing files.

## Key types in ContentView.swift

- **`Fruit`** — every form. Each case needs entries in several switches.
- **`characterBody(form:)`** — builds body, face, decorations, arms, legs for any
  form. Used by both the main character *and* `babyLemonCompanion`, so a new
  form works on the baby companion for free.
- **`Combo`** / `combos` / `activeCombos` — sequences and what they trigger.
- **`ComboHint`** / `hints` — **duplicates** the combo sequences as emoji strings
  inside `HelpView`. Kept in sync by hand; a typo here silently lies to the
  player. Scheduled for removal in Phase 1 of `SEASONAL_STRATEGY.md`.
- **`ComboDiscovery`** — UserDefaults-backed discovery and hint-reveal counts.
- **`Tune`** — per-form frequency arrays.

Custom `Shape` structs use one of two coordinate styles: the `fraction(_:_:_:)`
helper, or polar/trig from `rect.midX`/`midY`. Match whichever the neighbouring
shape uses.

---

## Adding a form

1. `Fruit` enum case
2. `bodyColors` switch case
3. Boolean flag if the form needs special rendering (e.g. `isSoccerBall`)
4. `name` switch case
5. `Tune` static array + `tune` switch case
6. `bannerText` switch case
7. Custom `Shape` struct(s) if needed
8. `characterBody` branch — and add to the nub/leaf exclusion chain if it
   shouldn't get the default lemon stem
9. `Combo` entry — verify the sequence is unique against every existing combo
10. `ComboHint` entry — sequence retyped as emoji; **must match step 9 exactly**
11. `PreviewGallery.swift` — both the `allForms` grid array and its own
    `#Preview("<Name> — Detail")` block
12. Build, verify in the simulator, revert any test scaffolding

**Conventions**
- Every new form gets a `PreviewGallery` entry in the same change.
- New combos ship `isEnabled: true` — not staged disabled.
- Shelving beats deleting: set `isEnabled: false` on both the `Combo` and its
  `ComboHint`, leave the art and tune in place.

**Currently shelved**: `singleSingleDoubleDouble`, `ruby`, `marble`,
`lemonShark`, `runner`, `soccerBall`

---

## Testing a form in the simulator

Temporarily override in `ContentView.init`:

```swift
_currentForm = State(initialValue: .someForm)
_isAwake = State(initialValue: true)
_showBabyLemon = State(initialValue: true)
```

Or use the `DEMO_FORM` env var via `SIMCTL_CHILD_DEMO_FORM=...` at launch.

**Always revert test scaffolding before committing** and confirm with
`git diff`. Build and run:

```
xcodebuild -project Lemon.xcodeproj -scheme Lemon \
  -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build
```

---

## Release pipeline

1. Bump `CFBundleVersion` in **both** `project.yml` **and** `Lemon/Info.plist` —
   they must match
2. `xcodegen generate`
3. Commit and push
4. `xcodebuild archive -project Lemon.xcodeproj -scheme Lemon -configuration Release -destination 'generic/platform=iOS' -archivePath build/Lemon.xcarchive`
5. `xcodebuild -exportArchive -archivePath build/Lemon.xcarchive -exportOptionsPlist build/ExportOptions.plist -exportPath build/export`

`ExportOptions.plist` uses `destination: upload`, so step 5 uploads straight to
App Store Connect.

Bump `CFBundleShortVersionString` (also in both files) only when Apple closes
the pre-release train — i.e. the current marketing version has gone live on the
App Store and uploads start failing with "Invalid Pre-Release Train".

Never commit, push, or ship unless explicitly asked.

---

## App Store assets

**Screenshots** — device pixel dimensions:

| Display | Pixels | Simulator |
|---|---|---|
| 6.9" iPhone | 1320 × 2868 | |
| 6.5" iPhone | 1284 × 2778 | iPhone 14 Plus |
| 13" iPad | 2064 × 2752 | iPad Pro 13-inch |

**App Preview videos** — **different dimensions from screenshots**:

- 6.5": **886 × 1920** (portrait) or 1920 × 886 — *not* the screenshot size
- Duration 15–30s
- **Must contain an audio track.** A video with no audio track at all is
  rejected with the misleading error "your app preview contains unsupported or
  corrupted audio". `xcrun simctl io ... recordVideo` captures video only, so
  recordings need a silent AAC track muxed in before upload.

**Listing text limits**: Subtitle 30 chars · Promotional Text 170 · Keywords 100
(comma-separated, no spaces). App name and subtitle are already indexed for
search — don't spend keyword budget repeating those words.

Promotional Text can be changed **without** App Store review; description,
subtitle, and keywords cannot.
