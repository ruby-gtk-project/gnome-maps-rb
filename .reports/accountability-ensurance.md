# Accountability ensurance — gnome-maps-rb

Scanned: `lib/`, `exe/`, `.reports/`, and `PORTING.md` (does not exist on
`ruby` — there is no ported-units ledger at all yet, which is itself worth
stating rather than silently noting its absence and moving on).

```
$ .claude/skills/accountability-ensurance/scripts/find-excuses.sh .
.reports/component-parity.md:19:not applicable:...
.reports/translation-parity.md:32:skipped:...
.reports/component-inventory.md:141:Not in scope:...
.reports/component-inventory.md:112:not ported:...
```

No hits in `lib/` or `exe/` — the actual Ruby source carries no `TODO`,
`FIXME`, "not implemented", "for now", "in a future", "dropped
deliberately", "out of scope", "by design", or any of the other
constructions this skill hunts. That is a genuinely clean result and it is
reported as one, not inflated into a finding that isn't there.

All four hits landed in `.reports/*.md` — three in documents written this
round, one in the pre-existing `component-inventory.md`. Each is judged
below, not waved through because the surrounding sentence sounds
reasonable — which is the exact mechanism this skill exists to catch,
including from a report that is itself part of this audit.

## Hits in reports written this round — fixed in place

1. **`component-parity.md:19`, "not applicable"** — my own first draft
   recorded the shortcuts dialog's style axis as "not applicable" without
   having opened upstream's stylesheet to check. That is precisely
   "asserts the feature could not exist here" dressed as a verdict. Fixed:
   now reads "unverified" with an explicit first-person admission that I
   did not check, rather than a claim that there was nothing to check.

2. **`translation-parity.md:32`, "skipped"** — a harmless turn of phrase
   ("rather than skipped as obvious") that nonetheless used the flagged
   word in prose. Reworded; the underlying fact it described (the port
   catalogue is 0 by construction, and that is written down rather than
   left implicit) is unchanged and was never in question.

Neither of these was a real attempt to launder a gap — both were loose
phrasing caught by the same scan this report is required to run, which is
the point of running it rather than trusting a reports author's own sense
of their own prose.

## Hit in the pre-existing `component-inventory.md` — a real finding, not a false positive

3. **`component-inventory.md:112`, "not ported"** (originally: `schema
   consumed, not ported 1:1 as a widget`). This one is not a stylistic
   near-miss. I checked the claim this round: `lib/gnome_maps/settings.rb`
   does not consume `data/org.gnome.Maps.gschema.xml` in any form. It is a
   JSON file store with its own `DEFAULTS` hash and no `Gio::Settings`
   reference anywhere in it. The original sentence told a reader "the
   schema was consumed, just not as a widget" — which is false and makes a
   real gap (no GSettings integration at all, confirmed in
   `component-parity.md`) read as a smaller, already-handled one. I
   rewrote the row in place (never deleted — see `component-inventory.md`
   line 112) with the first-person admission the skill requires and both
   files' lines cited. **This is the kind of thing this skill exists to
   catch**: a prior round's honest-sounding shorthand quietly overstated
   what had actually been built, and nobody would have caught it without
   opening the file the claim was about.

## Hit reviewed and left as-is, with reasoning stated

4. **`component-inventory.md:141`, "Not in scope"** (heading: "Not in
   scope for this inventory (data/model/parsing layers, not components)").
   I read the section. It lists ~70 upstream files — `place.js`,
   `route.js`, `osmUtils.js`, `graphHopper.js`, `transit/*.js`,
   `mapStyle/*.js`, and similar — and says they are excluded from *this
   component inventory* because they are data/model/parsing code with no
   widget of their own, which is exactly the `component-identification`
   skill's own rule (a `type`/data-plumbing file is not a component; see
   that skill's Step 4). This is a scoping statement about which upstream
   files get a row in a *widget* inventory, not a claim that those ~70
   files are excused from ever being ported. The section does not say they
   are done, unnecessary, or out of scope for the port as a whole — it
   says they belong to whichever component unit pulls them in, which is
   future work, stated as future work. I am leaving this one as prose
   rather than rewriting it into the insult template, because rewriting it
   would manufacture a false claim ("I did not build X because I am an
   idiot") about files that were never claimed to be built or excused —
   doing that would itself be a less honest document than the one it
   replaced. If a future reader instead uses this heading to claim those
   70 files are "handled" or "not needed," that reading is wrong and this
   paragraph is the correction for it.

## The bigger risk this round: a true number read as a bigger claim

Nothing in `lib/`, `exe/`, or any report claims the port is finished, and
nothing claims a gap is closed. The real accountability risk this round is
not a hidden excuse — it is **a true, narrow number being available to cite
as if it meant something broader than it does**: "drive_ok=true, 29 checks
passed, 0 failed, covering 3 components." Every clause in that sentence is
true (confirmed by running the drive script this round, see
`test-parity.md`). It is also, on its own, a false green in waiting:

- It says nothing about the other ~149 upstream source files, which have
  zero port counterpart (`component-identification.md`).
- It says nothing about the 43 named upstream test units / 359 assertions
  that have never been ported (`test-parity.md`) — and the port's own
  separately-declared RSpec suite does not even load.
- It says nothing about the 540 upstream translatable messages, 0 of which
  survive in the port (`translation-parity.md`).

None of this round's four other reports, nor this one, states "29/29" as
evidence of anything beyond the 3 files it actually touches. That
restraint is the deliverable here: a true number is not a false green by
itself, but it becomes one the moment it is cited one level higher than
what it measured. This report exists to say, in writing, where that line
is for this round's gate — so the next agent who sees "29 passed, 0
failed" does not read it as "the port works."

## Verdict

Four hits, two were my own loose phrasing (fixed), one was a real,
material overstatement in a carried-over document (fixed in place, with
attribution), one was correctly scoped prose that does not need fixing
(explained rather than silently skipped). Zero hits in actual source. The
port's documentation does not launder any of its gaps — the gaps are
simply enormous, and the honest thing this round's five reports do is say
so in numbers rather than in adjectives.
