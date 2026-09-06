# Seasonal Content Strategy

How time-gated content — month-long holiday packs (Halloween, Thanksgiving,
winter, …) and short one-off events alike — gets built, shipped, and unlocked,
and the refactoring that has to land before the first pack.

Status: agreed in principle. **Phases 1 and 2 landed** (see §4); open
questions at the bottom.

**Keeping this current:** update this doc in the same change that decides one of
its open questions, changes the `Availability` / `Event` / `Schedule` model, or
lands a phase. When a phase lands, migrate the now-true facts into `CLAUDE.md`
and mark the phase done here — this file holds rationale and plans, `CLAUDE.md`
holds what is true today.

---

## 1. Core strategy: ship dormant, unlock by date

Every seasonal pack ships in the binary as soon as it's built. A date window
decides when it becomes reachable. **The seasonal window is the feature flag.**

We do *not* branch-and-release per holiday. The reason is a constraint that's
easy to overlook: users have to **update** to get a new binary.

- A pack released in late October only reaches users who auto-updated in time.
  Everyone else sees nothing, and one slow review week kills the whole holiday.
- A pack shipped dormant in September lights up on Oct 1 on every device that
  already has it — no review risk, no update race.

This also means a slipped App Store review is no longer fatal. The content just
turns on whenever the build lands.

---

## 2. Availability model

One field, three mutually exclusive cases. This replaces `Combo.isEnabled`.

```swift
enum Availability {
    case always          // evergreen — always reachable
    case event(Event)    // reachable only inside its schedule
    case notReady        // never reachable; exists for PreviewGallery only
}
```

Content under construction is `.notReady`. When the art and tune land, it
becomes `.event(.halloween)`. Moving between states is a one-line edit.

`.notReady` wins unconditionally — a draft is never triggerable, even if its id
somehow already has a discovery flag set.

### Event, not Season — schedule separated from theme

"Season" conflates two things: *what* the content is and *when* it's on.
Separating them means a one-day event needs no parallel system — it's the same
struct with a different schedule.

```swift
/// WHEN — purely a time predicate.
enum Schedule {
    case annual(from: MonthDay, through: MonthDay)  // wraps: Dec 20 → Jan 6
    case oneOff(year: Int, MonthDay)                // never repeats
    // .day(MonthDay) is sugar for annual(from: x, through: x)
}

/// WHAT — a named themed bundle.
struct Event {
    let id: String            // "halloween", "leapDay"
    let schedule: Schedule
    let skin: Skin?           // nil = no decoration
    let returnsCopy: String   // "Back in October" / "Gone until next year"
}
```

- A month-long Halloween pack and a one-day surprise are the same type.
- `returnsCopy` is per-event because "Back in October" is wrong for a one-off.
- **Floating dates** (4th Thursday of November) are deliberately omitted. Add a
  `nthWeekday` case only if a pack actually needs one — "all of November" is
  covered by `annual`.

### Currently shelved combos

These stay `.notReady` indefinitely and are **not** seasonal candidates:

`singleSingleDoubleDouble`, `ruby`, `marble`, `lemonShark`, `runner`

They keep their code, art, tunes, and `PreviewGallery` entries. Seasonal packs
are built from new forms.

---

## 3. Display logic

| Availability | Player state | Triggerable? | Help page |
|---|---|---|---|
| `.always` | undiscovered | yes | listed as `???` |
| `.always` | discovered | yes | listed, named |
| `.event` | in window, undiscovered | yes | listed as `???` |
| `.event` | in window, discovered | yes | listed, named |
| `.event` | out of window, discovered | yes | listed, dimmed — `returnsCopy` |
| `.event` | out of window, undiscovered | no | hidden entirely |
| `.notReady` | any | no | hidden entirely |

**Out of window + discovered stays triggerable.** Nothing is ever taken away
from the player. The *discovery moment* is seasonal; the reward is permanent.
This also avoids "my ghost lemon disappeared" as a support issue.

**Out of window + undiscovered is hidden, not `???`.** A permanently
uncompletable row in the help list reads as a bug, not a tease.

This applies to **all** events regardless of length. Noted tension: at one or
two days, hiding means a player who opened the app on the wrong day never learns
the content existed at all. That's an accepted cost for now — revisit only if
short events actually get built (§9).

### Two rules that fall out of this

**Triggering is gated; rendering never is.**
The window controls whether a combo *fires*, not whether a form can be *drawn*.
Someone who transforms at 11:58pm on Oct 31 does not get snapped back to a plain
lemon two minutes later. `PreviewGallery` renders forms directly and is
unaffected by any of this.

**Skins follow the calendar; forms follow discovery.**
The seasonal decoration is pure rendering, so it respects the window
strictly — on Oct 1, off Nov 1, no discovery involved. A hat that lingered into
December because it had been "earned" would just look broken.

### Discovery reset

The existing reset-progress action clears seasonal discoveries along with
everything else.

---

## 4. Architecture work

Three phases. Phases 1 and 2 have landed; Phase 3 is the first pack itself.

### Phase 1 — unify the combo catalog ✅ DONE

Combos used to be defined **twice** — once as real `[InputAction]` sequences in
`ContentView`, and again as hand-typed emoji strings in `HelpView`, with two
separate `isEnabled` flags kept in sync by hand. A typo produced a hint that
lied to the player, and nothing caught it.

Both are now [`Lemon/Combos/ComboCatalog.swift`](Lemon/Combos/ComboCatalog.swift):
`ComboDefinition` holds the sequence once, and `hintSteps` derives the help
page's arrows from it. A snapshot test proves the derived strings reproduce the
shipped ones byte for byte.

`Availability` replaced `isEnabled` with `.always` / `.notReady`; Phase 2 adds
the `.event(Event)` case below.

The shape that landed:

```swift
struct ComboDefinition {
    let id: String
    let emoji: String
    let name: String
    let sequence: [InputAction]
    let kind: ComboKind
    let availability: Availability
    let alwaysRevealed: Bool

    /// Derived from `sequence` — never hand-typed.
    var hintSteps: [String] { ... }
}
```

**Hint derivation rule** (verified against every existing hint, including
Daisy's double-twirl):

- `.direction(.up|.down|.left|.right)` → `⬆️` / `⬇️` / `⬅️` / `➡️`
- first `.twirl` → `"then Twirl!"`
- any subsequent `.twirl` → `"Twirl again!"`

`ContentView` and `HelpView` both read the one catalog. The sequence
exists in exactly one place. **Nothing outstanding — Phase 2 can start whenever.**

### Phase 2 — schedules and clock ✅ DONE

Shipped: `Schedule`, `Event`, `EventClock`, `EventCatalog`, the `.event`
case on `Availability`, the reachability rules from §3, `scenePhase`
recomputation, and the debug panel below.

Proven end to end by the first date-gated combo, `jackOLantern`: hidden from
the help page on a real September date, and present once the debug panel's
simulated date is moved into October.

```swift
struct MonthDay { let month: Int; let day: Int }

extension Schedule {
    // Wrapping matters: Dec 20 → Jan 6 needs (date >= start || date <= end)
    func contains(_ date: Date, calendar: Calendar) -> Bool
}

enum EventClock {
    static var now: () -> Date = { Date() }   // injectable
}
```

- Use the user's **local** calendar so holidays feel local.
- The year-wrapping case silently breaks and only surfaces on Dec 20. It needs
  a test (see §7).
- **Timezone precision scales inversely with window length.** A month-long
  window is forgiving at the boundaries; a 24-hour window is not, and a player
  who travels mid-event can watch the day shift under them. Short events need
  their own boundary tests.

### Where the schedule config lives

**Swift data, in one `EventCatalog.swift` — pure data, no logic.**

Three options were considered, and two of them are the same thing:

| Approach | Change without a build? | Verdict |
|---|---|---|
| Swift data | No | **Chosen** — type-safe, no failure modes |
| Bundled JSON | No | Identical shipping story, but adds parsing, error handling, and a silent-failure mode where malformed JSON means no event content. Strictly worse. |
| Remote config | Yes | The only real "config", but needs hosting, offline fallback, and caching — turns an offline fidget toy into something with infrastructure |

The main thing remote config would buy is fixing a *wrong window* after ship.
A boundary test is a far cheaper mitigation. Keep the `Schedule` type clean
enough that a remote source could be swapped behind it later if that changes.

### The debug panel

Date-gated content is untestable without a way to pretend it's October, and
TestFlight builds are Release builds — so neither a launch environment
variable nor `#if DEBUG` reaches them. This panel is what makes
seasonal work testable at all, and it ships as part of Phase 2.

**Gating.** A TestFlight install is detectable at runtime because its receipt is
named `sandboxReceipt` rather than `receipt`:

```swift
Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
```

Same binary; the panel is simply not rendered for App Store users. It's a
heuristic rather than a guarantee, but the worst case if it ever misfired is
somebody seeing Halloween early.

**Where it lives.** A plain "Debug" section at the bottom of the help page,
below the Reset button — *not* behind a secret gesture. The gate already does
the hiding, so obscurity buys nothing and costs you remembering which gesture it
was three months later.

**What it does.**

1. **Set a simulated date.** Overrides `EventClock.now`, persisted in
   UserDefaults, clearable in one tap.
2. **Show unfinished combos** — folds `.notReady` into the matchable set.
   **Default off**, so TestFlight matches production until deliberately changed;
   otherwise testers report problems with forms that were already shelved and
   their attention goes to the wrong place.
3. **Jump to any form**, including `.notReady` ones — transforms the character
   immediately, no sequence required. This is the one that matters most for
   display work, and it replaces the edit-`init`/rebuild/screenshot/revert loop
   in `CLAUDE.md`, along with its standing risk of committing test scaffolding.

**One banner for all of it.** While any override is active, show a single line —
`Debug · simulated date Oct 15 · unfinished combos shown`. Without it, someone
flips a switch, forgets, and files a confusing bug weeks later.

**What it still doesn't cover.** An override bypasses real `Date()`, so it
proves our logic works, not that the system clock path does. Change the device
or simulator date for real once before shipping each pack — once per pack, not
per build.

### Availability re-evaluation

**When does the app notice the date changed?** SwiftUI won't re-render just
because the clock ticked past midnight, so somebody with the app open at 11:59pm
on Sept 30 would sit there with no Halloween.

Recompute when `scenePhase` becomes `.active`. Most people background the app,
so that covers nearly all real usage for very little code — but it has to be
deliberate, and it needs its own test. Otherwise the bug surfaces on the one
night of the year it matters.

### Phase 3 — pack content and the seasonal skin layer

Pack *forms* can be built now — `jackOLantern` is the first, gated to the
Halloween event. The skin layer below is still outstanding.

Every form gets the seasonal decoration composed over it, with a per-form
opt-out. This is the only genuinely *new* architecture in this plan — everything
else is reorganizing what exists.

- A new overlay slot in `characterBody`, which already takes `form:` and is
  shared by the main character and the baby companion, so the baby inherits the
  skin for free.
- Strictly schedule-driven, no discovery involved.
- **Applies to every form, not just the plain lemon** — otherwise a player
  sitting in Donut form on Oct 20 sees no Halloween at all, which undercuts the
  point of a skin.
- The per-form opt-out exists for visual collisions (a witch hat over the
  Princess crown, or over the Donut, which has no head to speak of).

### File organisation

[`ContentView.swift`](Lemon/ContentView.swift) is still ~2000 lines even after
Phase 1 moved the catalog out. Four packs would make it unmanageable, and — more
importantly — make Halloween and Thanksgiving work collide in the same lines.

```
Lemon/
  ContentView.swift           scene, animation, input handling
  Combos/ComboCatalog.swift   the single combo registry
  Events/Event.swift          Schedule, Event, clock (Availability lives
                              in ComboCatalog.swift as of Phase 1)
  Events/EventCatalog.swift   the schedule config — pure data
  Events/Skins.swift          seasonal overlay layer
  Events/DebugPanel.swift     TestFlight-gated date / form overrides
  Forms/HalloweenForms.swift  shapes + colors, one file per pack
  Forms/WinterForms.swift
```

### What NOT to refactor

The `Fruit` enum switches (`bodyColors`, `name`, `tune`, `bannerText`) get
tedious at 16+ cases, but the compiler enforces exhaustiveness — that's the
*protective* kind of tedium. Leave them alone. Revisit a `FormSpec` dictionary
only if it genuinely starts to hurt.

---

## 5. Branching strategy

Trunk-based. The date gate removes the reason to keep release branches.

- **`main` is always shippable and always submittable.**
- **One short-lived branch per pack**: `feat/pack-halloween`. Merge the moment
  the pack is complete — the window keeps it dormant regardless of merge date.
- **Incremental app fixes go straight to `main`**, as they do today. No need to
  add ceremony that isn't buying anything.
- **Tag what gets submitted** (`build-17`) so a TestFlight build maps back to a
  commit.

The one risk to respect: a merged-but-unfinished pack is dormant, but a crash in
*shared* code still ships. Keeping pack code in its own files means the catalog
entry is the only shared line a pack touches.

---

## 6. Release calendar

Packs are batched. There is no need for one release per holiday.

| Submit by | Contains | Activates |
|---|---|---|
| ~Sept 10 | Halloween + Thanksgiving | Oct 1 / Nov 1 |
| ~Nov 5 | Winter | Dec 1 |
| ~Feb 1 | Spring / Valentine | as dated |

**Rule of thumb: submit at least 3 weeks before a window opens**, so review and
update penetration both have room.

**Promotional Text can be changed without review.** Seasonal marketing copy
("🎃 Halloween forms are here!") can be swapped on Oct 1 and back on Nov 1 with
zero submissions.

---

## 7. Testing

Three layers, because they cover different things:

- **Unit tests** in `LemonTests/` — `Schedule.contains` takes both the date and
  the calendar as parameters, so no mechanism is needed. Covered today: window
  ends inclusive, the year-wrap (Dec 20 → Jan 6), single days, one-offs not
  recurring, leap day, timezone, and the reachability rules from §3.
- **Simulator**, for looking at things: the debug panel works in debug builds
  too, and `EventClock.now` can be set directly in an Xcode Preview. Also how
  App Store screenshots of seasonal content get taken out of season.
- **TestFlight**, via the debug panel — the only option that reaches a Release
  build, and so the only way testers see seasonal or unfinished content.

**Not covered by tests:** the `scenePhase` recompute. Verifying it needs a UI
test harness that isn't worth standing up for one line — it's checked by
inspection instead.

**Real-clock check once per pack.** Every override above bypasses `Date()`.
Change the device date for real before shipping a pack.

**`PreviewGallery` shows every form regardless of availability**, unchanged from
today's convention.

---

## 8. Adding one seasonal form (checklist)

After Phase 1, per form:

1. `Fruit` enum case
2. `bodyColors` switch case
3. `name` switch case
4. `tune` switch case + `Tune` static array
5. `bannerText` switch case
6. Shape struct(s) + `characterBody` branch, in the pack's own file
7. One `ComboDefinition` entry — sequence typed **once**
8. `PreviewGallery` entry (grid array + `#Preview` block)

---

## 9. Decisions and open questions

### Settled

- **Long windows.** With a small user base, reach beats scarcity — prefer the
  full month (Oct 1 – 31) over a tight window. Revisit if the base grows enough
  that scarcity becomes the more valuable feeling.
- **Hide out-of-window content**, globally, regardless of event length. No
  locked-teaser rows.
- **Seasonal packs are the priority.** Everything below is secondary to getting
  Halloween out.

### Open — short events and daily rotation

Under consideration, not committed. Two related ideas:

- **Short one-off events** — a single form for a day or a few days.
- **Daily rotation** — a different form surfaced every day of the calendar, as
  an ongoing engagement mechanic rather than a holiday tie-in.

**The reach problem.** The app has no push notifications, so a one-day event is
only seen by people who happen to open the app that day. Mitigations: widen the
window to ~3 days, or announce it via Promotional Text (free, no review).
Daily rotation partly sidesteps this — if there's *always* something today, no
single day has to be caught.

**Architecturally, rotation slots in as another `Schedule` case** rather than
needing a parallel system — which is the payoff of having split *when* from
*what* in §2. It needs to be **deterministic from the date** (e.g. index into a
pool by day-of-year) so every player sees the same thing on the same day, with
no server and no stored state:

```swift
case rotating(pool: String, slot: Int)   // on when dayOfYear % poolSize == slot
```

**But it probably shouldn't live in the combo list.** A rotation is a daily
*surprise*, not a secret to *discover* — and under the "hide out-of-window" rule
the help page would churn every day as entries appeared and vanished. Rotation
likely wants its own surface ("Today's Lemon") with its own display rules,
leaving the combo/hint list for evergreen and event content. Worth settling
before building any of it.
