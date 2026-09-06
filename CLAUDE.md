# It's a Lemon

A whimsical SwiftUI iOS app: an animated lemon character that transforms into
other forms when the player taps secret dance-combo sequences.

Live on the App Store; iterating via TestFlight. Repo `sharkedup/lemon` is
**public** — treat every push as publishing.

- Bundle `com.kmsharkey.Lemon` · Team `QS983XC69J` · iOS 17+ · portrait only
- iPhone + iPad (`TARGETED_DEVICE_FAMILY: "1,2"`)

---

## In progress: privacy policy migration

The policy is moving out of this repo so this repo can go **private**. The new
public home is `sharkedup/lemon-privacy`, already live and verified at
<https://sharkedup.github.io/lemon-privacy/>.

**State as of 2026-09-06:** version 1.2 is **approved and released**, and
build 21 is on TestFlight. The Privacy Policy URL has **not** been changed yet;
the listing still points at `sharkedup.github.io/lemon/`, which keeps working
while this repo stays public.

**Decided 2026-09-06:** the URL swap rides along with the **next App Store
submission** rather than being done on its own. Nothing here is urgent until
that submission is being prepared — don't treat step 2 as outstanding work in
the meantime.

Remaining, in order:

1. ~~Wait for the in-review build to be approved.~~ Done.
2. Update the **Privacy Policy URL** in App Store Connect → App Information,
   as part of preparing the next App Store submission. Check the **Support
   URL** too — if it points at this repo or the old Pages site, it breaks the
   same way.
3. Load both URLs in a browser and confirm they resolve.
4. Flip this repo private.
5. Delete `docs/`, drop its row from the layout table, fix the "public" note in
   the header above, and delete this section.

**Do not flip private or delete `docs/` before step 3 passes** — until then
`sharkedup.github.io/lemon/` is the policy URL on a live app, and removing it
breaks a link Apple requires.

---

## Keeping these docs current

**Update `CLAUDE.md` when:**
- A form is added, removed, enabled, or shelved → update the shelved list below
- The add-a-form touch points change (e.g. the combo catalog refactor lands)
- The release pipeline changes — a new step, or a new place a version lives
- A new App Store asset requirement or rejection gotcha is discovered
- The art or shape-design workflow changes
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
| `Lemon/ContentView.swift` | ~2000 lines: scene, all forms, help page |
| `Lemon/Combos/ComboCatalog.swift` | Every combo — the single source of truth |
| `Lemon/Events/Event.swift` | `Schedule`, `Event`, `EventClock`, `EventCatalog` |
| `Lemon/Events/DebugSettings.swift` | TestFlight-gated overrides + banner text |
| `Lemon/Events/DebugPanel.swift` | The debug UI and form picker |
| `Lemon/PreviewGallery.swift` | Xcode previews of every form — dev only |
| `Lemon/ToneSynth.swift` | On-device tone synthesis |
| `Lemon/LemonApp.swift` | Entry point |
| `LemonTests/` | Unit tests — catalog invariants and combo matching |
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
- **`ComboDefinition`** / `ComboCatalog` — every combo, defined once. The help
  page's arrow strings are **derived** from `sequence` via `hintSteps`, so a
  hint cannot drift from what the game accepts. `ComboCatalog.reachable()` is
  what both matching and the help page read.
- **`Availability`** — `.always`, `.event(Event)`, or `.notReady`. Replaced the
  old `isEnabled` flag.
- **`Schedule`** — when an event is on. `.annual(from:through:)` wraps the year
  boundary (Dec 20 → Jan 6); `.oneOff(year:_:)` never repeats. Takes the
  calendar as a parameter so it stays pure and follows the player's local time.
- **`EventClock.now`** — injectable clock. Tests and previews replace it; call
  `EventClock.reset()` afterwards.
- **Reachability**: a discovered event combo stays playable after its window
  closes — the discovery is seasonal, the reward is permanent. See
  `ComboDefinition.isReachable(on:isDiscovered:)`.
- Catalog order matters: matching takes the first candidate fitting the tail of
  recent input, so an earlier entry shadows a later one whose sequence is a
  suffix of it. Guarded by a test.
- **`ComboDiscovery`** — UserDefaults-backed discovery and hint-reveal counts.
- **`Tune`** — per-form frequency arrays.
- **`RubyGeometry` / `RubyFurGeometry`** — Ruby is the most customised form:
  her own silhouette, her own face (`dogFace` — plain dark eyes vanish against
  her black mask), and procedural fur. Her body-local points live in
  `RubyGeometry` on the same 260 x 220 frame as `LemonShape`, the way
  `SpiderLegGeometry` does. Her black is `Fruit.rubyDark`, deliberately *not*
  `bodyColors.dark`, which also fills the body gradient's outer stop and the
  paws — darkening that turned her body and feet black too.
- **Baked randomness**: `RubyFurGeometry` scatters her fur once through a
  seeded `RubySeededRandom` into `static let`s. A `Shape` recomputes its path
  every frame, so a live random source there would re-scatter the fur each
  frame and shimmer during the dance.

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
7. Custom `Shape` struct(s) if needed — design them in SVG first, see below
8. `characterBody` branch — and add to the nub/leaf exclusion chain if it
   shouldn't get the default lemon stem. A form with its own silhouette also
   needs a branch where `bodyShape` is chosen (see `GhostShape`, `RubyShape`),
   and one that floats needs the arms/legs call sites skipped (see `isGhost`).
   Limbs have two per-form escapes at that call site: a `stroke` override for
   their colour (Daisy, Ruby) and `arms(yOffset:)` for where they attach — Ruby
   attaches hers low on the chest so they clear her ears.
9. `ComboDefinition` entry in `ComboCatalog` — id, emoji, name, sequence, kind,
   availability. The hint text derives itself; there is nothing to keep in sync.
10. `PreviewGallery.swift` — both the `allForms` grid array and its own
    `#Preview("<Name> — Detail")` block
11. Run the tests (below) — they catch a sequence that collides with an
    existing combo
12. Build, verify in the simulator, revert any test scaffolding

**Conventions**
- Every new form gets a `PreviewGallery` entry in the same change.
- New combos ship `availability: .always` — not staged off.
- Shelving beats deleting: set `availability: .notReady` and leave the art,
  tune and `PreviewGallery` entry in place.

**Currently shelved**: `singleSingleDoubleDouble`, `marble`, `lemonShark`,
`runner`

---

## Designing a new shape

**Draw it in SVG first. Do not iterate on geometry by rebuilding the app.**

A rebuild-and-screenshot cycle is about three minutes; an SVG render is about
five seconds. The speed matters less than the fact that bad directions can be
found and thrown away *before* anyone else has to look at them — the soccer ball
took four iterations and a full geometry rewrite this way, after failing over six
rebuild cycles the other way.

### The loop

1. Work through the intake questions (below), one at a time.
2. Generate a **grid of 4–6 variants** as one SVG, drawn on the real body
   silhouette with a stand-in face.
3. Rasterise and look at it:
   ```
   qlmanage -t -s 1100 -o . variants.svg     # writes variants.svg.png
   ```
   `qlmanage` scales to fit the *larger* dimension, so keep the canvas roughly
   square or the right-hand column gets cropped.
4. Discard the duds yourself, iterate, and only then send a sheet for a pick.
5. Port the chosen one to a `Shape`, then verify in the simulator — the port is
   the step where errors creep in, not the drawing.

The body silhouette, matching `LemonShape` on the 260 x 220 frame:

```
M 130,0 C 221,0 260,44 260,110 C 260,176 221,220 130,220
        C 39,220 0,176 0,110 C 0,44 39,0 130,0 Z
```

Because decoration layers are given that same 260 x 220 frame, SVG coordinates
port across directly — use `rect.midX`/`midY` as the centre and keep the radii.

### The intake questions

When a new form is announced, ask these **one at a time, waiting for each
answer** — not as a block. Skip any the user has already answered; several
usually arrive with the initial request.

1. **Reference** — "What should it look like? Paste an image, or name the
   real-world thing." Structure usually comes with it; ask for the geometry in
   words only if the reference is ambiguous.
2. **Must not read as** — "What would it be a failure to accidentally
   resemble?" The highest-value question of the set. Cartoon shapes fail by
   resembling something unintended, and that is invisible until someone says
   it. "Not a spider" would have killed two soccer ball attempts on sight, and
   "cute, not scary" shaped every jack-o'-lantern decision.
3. **Overlay or body** — pattern on the standard blob, or its own silhouette?
   The cheap path versus the expensive one. Offer it as a choice, with the cost
   difference stated.
4. **Arms and legs** — keep both, or does the form float or otherwise not want
   them? Only the ghost has needed "neither" so far, but it is invisible until
   asked.
5. **Availability** — evergreen, or gated to an event?

Propose answers for 3–5 rather than asking cold; they are usually inferable
from context, and a suggestion is faster to correct than a blank question.

### When panels have to meet

Build every panel from **one shared set of vertices** so adjoining panels use
the same corner points. Regular pentagons and hexagons do not tile a flat plane;
drawing them independently and hoping they line up leaves slivers and crossed
seams. See `SoccerPanelsShape`.

---

## Testing a form in the simulator

**Use the debug panel** — bottom of the help page, "Jump to a form…". It lists
every form including unfinished ones and switches to it immediately. No source
edits, so nothing to revert and nothing to accidentally commit. It works in
TestFlight too, which the alternatives below do not.

The panel also carries a **simulated date** (for previewing seasonal content
before its window) and a **show unfinished combos** toggle. Both persist across
launches, and a banner stays on screen the whole time either is active. It is
gated to debug builds and TestFlight via the `sandboxReceipt` check — App Store
builds never render it.

If you do need a source-level override for some reason, temporarily set these in
`ContentView.init`:

```swift
_currentForm = State(initialValue: .someForm)
_isAwake = State(initialValue: true)
_showBabyLemon = State(initialValue: true)
```

**Always revert that scaffolding before committing** and confirm with
`git diff`. Build and run:

```
xcodebuild -project Lemon.xcodeproj -scheme Lemon \
  -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build
```

---

## Automated tests

```
xcodebuild test -project Lemon.xcodeproj -scheme Lemon \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Local only — no CI. Tests run in milliseconds; the ~30s is build time.

**What they cover** — bugs that ship silently, where the app builds and looks
fine but is broken for players:

- No enabled combo's sequence is a suffix of another's. Matching compares the
  *tail* of recent input and takes the first candidate that fits, so a
  collision makes one combo unreachable — and which one loses depends on
  declaration order, so a reorder can flip it. The test flags the hazard, not
  just whether it currently misfires.
- Derived hint text still reproduces, byte for byte, the hand-written strings
  that shipped before the catalogs were unified.
- A hint has exactly as many steps as its combo has presses.
- Combo ids are unique, every entry has a name and emoji, `.notReady` combos
  can't be triggered, and a partial sequence matches nothing.
- Schedule boundaries: inclusive ends, the year-wrapping window, single days,
  one-offs not recurring, leap day, and that windows follow the supplied
  calendar rather than UTC.
- The reachability rules from §3 of `SEASONAL_STRATEGY.md`, including that a
  `.notReady` combo stays unreachable even with a discovery flag set.

**What they do not cover: anything visual.** If a form renders wrong, no test
will say so — that stays a simulator check by eye.

The snapshot of pre-unification hint strings is what proved Phase 1 didn't
change behaviour. Worth keeping — it still guards the derivation rule.

---

## Release pipeline

0. **Run the tests** (above). Red means don't ship.
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
