# Accountability ensurance — gnome-maps-rb

| | |
|---|---|
| Upstream | `main` @ `9970d8f1` |
| Port | `ruby` @ `c846de15` |

Scanned: `lib/`, `exe/`, `.reports/`. `PORTING.md` still does not exist on
`ruby` — there is still no ported-units ledger outside `.reports/`, which
is itself worth stating again rather than silently noting its absence a
second round running.

```
$ grep -rniE "TODO|FIXME|not implemented|for now|in a future" lib exe .reports
```

(ran directly, plus the skill's `find-excuses.sh` against `.`)

**Zero hits in `lib/` or `exe/`.** Across all 14 `lib/gnome_maps/*.rb`
files and `exe/gnome-maps` — up from 3 real files at the last round's
audit — there is still no `TODO`, `FIXME`, "not implemented", "for now",
"in a future", or any of `find-excuses.sh`'s other flagged constructions
anywhere in actual source. That is a genuinely clean result, reported as
one: the port is not hiding unfinished work behind a comment that waves it
away. What's missing is simply missing — not built, not stubbed, not
rationalized in a code comment.

Every hit `find-excuses.sh` returns is inside `.reports/*.md`. Reviewed
below, not waved through.

## Hits reviewed this round

Most hits are the reports *discussing* these exact flagged phrases — e.g.
`accountability-ensurance.md` itself quoting "TODO, FIXME, not
implemented..." to describe what it scanned for, or `component-inventory.md`
explaining why a "not in scope"/"by design" judgment from an earlier round
was or wasn't a real excuse. Re-reading each of these this round: they are
meta-discussion of the skill's own vocabulary, not fresh laundering. They
are not rewritten again because doing so a second time would just be
quoting a quote.

The hits worth checking as *new* writing this round are in
`component-identification.md` (written fresh this round, superseding the
prior one at the same path):

- `component-identification.md:47` and `:51`, "duck-types an unported
  `Route::TurnPoint`" / "duck-types an unported `ShapeLayer` model" — these
  name the exact missing class by name, in the row where the dependent
  widget is listed as done. This is the skill's own prescribed shape for
  a real gap statement (name the behaviour, don't hide it) rather than an
  excuse — "unported" here is not standing in for "this doesn't need to
  exist," it's pointing at a specific file (`Route::TurnPoint`,
  `ShapeLayer`) that still needs to be written. Kept as-is.
- `component-identification.md:112`, in the verdict, "several of those 14
  duck-type unported model classes rather than being complete" — same
  judgment, summary form. Kept as-is.

No hit in any report written or touched this round asserts a gap is
closed, not needed, or out of scope for the port as a whole. The
`component-inventory.md` lines flagged again by the script (`:13` "by
design", `:77`/`:142`–`144` "n/a", `:145` "out of scope") are the same
lines the prior round's accountability pass already reviewed and left
in place with reasoning recorded (see that file's own history and the
prior `accountability-ensurance.md`, kept below as the record of that
decision) — re-reviewed this round and the reasoning still holds: they
scope a *component* inventory away from data/model files that have no
widget of their own, which is the `component-identification` skill's own
rule, not a claim that those files are excused from the port.

## The real risk this round: a true, growing number read as a bigger claim

The runtime gate for this round is `drive_ok=true, 81 checks passed, 0
failed, covering 14 components`. Every clause is independently true
(re-run this round: 81/81, confirmed). It is also, read alone, the same
kind of false-green-in-waiting the prior round's report warned about at
29/3 — now at a bigger, more persuasive-sounding scale:

- "14 components" overstates how many `lib/*.rb` files the drive script
  gives a *dedicated* check to. Read closely (done in `test-parity.md`
  this round), the 81 checks are organized around roughly 10 named steps/
  files; the other ~4 of the 14 current `lib/` files are touched only as
  collaborators pulled in by those steps, not driven in their own right.
  This is now written down explicitly in `test-parity.md` so the gap
  between "14 components in `lib/`" and "14 components the drive exercises
  on their own" doesn't quietly collapse into one number.
- It says nothing about the ~140 upstream `src/*.js`/`data/ui/*.blp` files
  with zero port counterpart (`component-identification.md`), nothing
  about the 43 named upstream test units / 359 assertions never ported,
  whose own RSpec suite still fails to load with 0 spec files underneath
  it even when it would (`test-parity.md`, re-confirmed this round by
  actually running it), and nothing about the 540 upstream translatable
  messages, 0 of which survive, a gap that has grown rather than shrunk
  as new user-visible strings were added this round with no `_()` marker
  (`translation-parity.md`).
- One correction this round went the *other* direction, worth recording
  precisely because it cuts against "the port looks more done than it is":
  an earlier draft of `component-identification.md`/`component-parity.md`
  (written fresh this round, before being checked against the current
  `application.rb`) described the main window as a bare `Adw::StatusPage`
  placeholder. Reading `application.rb` directly showed that description
  was wrong — the window is a real, assembled header bar + search bar +
  live map + zoom controls + context menu. That was caught and fixed in
  place in both reports before being finalized here, rather than shipped
  as a stale, overly-pessimistic claim. Recorded here so the correction
  itself is auditable, not just the corrected text.

None of the five reports this round, including this one, cites "81
passed" or "14 components" as evidence of anything beyond what was
actually driven and checked file-by-file. That restraint, plus actually
running every command this round claims was run (the RSpec failure, the
81/81 drive, the grep against `lib`/`exe`) rather than trusting the
gate's own summary or a prior round's numbers, is the deliverable.

## Verdict

Zero excuses found in actual source (`lib/`, `exe/`) across both this
round's 14 files and the prior round's 3. The hits inside `.reports/` are
either meta-discussion of the skill's own vocabulary or specific,
honestly-named gaps rather than laundering. The one real risk identified
and corrected this round is scale, not deception: a true, larger "81
passed / 14 components" headline could be read as covering far more than
it does, and the breakdown needed to prevent that misreading is now
written into `test-parity.md` and this report rather than left implicit.
