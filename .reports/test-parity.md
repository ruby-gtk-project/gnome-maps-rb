# Test parity — gnome-maps-rb

| | |
|---|---|
| Upstream | `main` @ `9970d8f1` |
| Port | `ruby` @ `47d67faf` |
| Upstream tests | **43 named units / 359 assertion call sites** (see methodology) |
| Ported | **0** |
| Gaps | **43** |
| Test command (port) | `ruby -e 'require "rspec/core"; exit RSpec::Core::Runner.run(["--format","progress","--require","spec_helper","spec"])'` — **does not run**; see "the suite that never ran" below |

## Methodology — why the number is "43", not a round figure

`test-parity`'s own `test-census.sh` returns **0** against upstream's
`tests/` tree. That is a scanner miss, not an empty suite: GNOME Maps'
upstream tests are plain GJS scripts that neither use Jasmine's `it(...)`
nor any framework the script recognizes. They are counted by hand instead,
per the skill's explicit instruction to treat the script's output as a lead
and open the files when it returns nothing plausible.

Two shapes exist in `tests/*.js`:

1. **Named function per case** — `function osmTypeToStringTest() { ... }`,
   `function testPlaceStore() { ... }` — called from the bottom of the file.
   Counted: `boundingBoxTest.js` 8, `timeTest.js` 3, `addressTest.js` 1,
   `epafTest.js` 2, `colorTest.js` 3, `utilsTest.js` 10, `urisTest.js` 5,
   `placeIconsTest.js` 2, `placeStoreTest.js` 5 = **39 named functions**.
2. **Flat module-level scripts**, no function wrapper at all —
   `osmNamesTest.js`, `wikipediaTest.js`, `downloadsTest.js`,
   `placeZoomTest.js` — each is a sequence of `JsUnit.assertEquals(...)`
   calls run top-to-bottom at module load. Counted as **1 unit per file**
   (4 files), because there is no sub-identifier to key a ledger row on
   without inventing one upstream never wrote.

39 + 4 = **43 named units**, declared in `tests/meson.build`'s `tests` array
(confirmed: that array lists exactly these 14 files, cross-checked per the
skill's "declared vs censused" step — nothing is registered there that the
hand-census missed, and nothing was censused that the build file doesn't
run).

Underneath those 43 units sit **359 individual `JsUnit.assert*()` call
sites** (counted via `grep -oh 'JsUnit\.assert[A-Za-z]*(' tests/*.js | wc -l`),
ranging from 3 (`epafTest.js`) to 125 (`translationsTest.js`) per file. The
43 is the ledger's row count, matching this skill's "one row per named
test/table" rule; the 359 is reported alongside because it is what each row
actually pins — `translationsTest.js` alone is 125 assertions behind one
file-level unit, and collapsing it to "1 of 43" would understate what a
single gap costs.

**Not done this round**: a one-sentence purpose statement for each of the
43 units (what each pins, in terms of app behaviour) — the skill asks for
this before any unit is marked anything, and it was not written for all 43
in the time available. What follows is the file-level census, honestly
short of that depth; no row below is claimed `ported`, so the missing
purpose statements do not change the verdict, but they are an open item for
whoever closes these gaps next.

## Census

| # | Upstream file | Named units | Assertions | Port test | State |
|---|---|---:|---:|---|---|
| 1 | `tests/addressTest.js` | 1 | 8 | — | gap |
| 2 | `tests/boundingBoxTest.js` | 8 | 35 | — | gap |
| 3 | `tests/colorTest.js` | 3 | 14 | — | gap |
| 4 | `tests/downloadsTest.js` | 1 | 6 | — | gap |
| 5 | `tests/epafTest.js` | 2 | 3 | — | gap |
| 6 | `tests/osmNamesTest.js` | 1 | 6 | — | gap |
| 7 | `tests/placeIconsTest.js` | 2 | 8 | — | gap |
| 8 | `tests/placeStoreTest.js` | 5 | 54 | — | gap |
| 9 | `tests/placeZoomTest.js` | 1 | 4 | — | gap |
| 10 | `tests/timeTest.js` | 3 | 17 | — | gap |
| 11 | `tests/translationsTest.js` | 1 | 125 | — | gap |
| 12 | `tests/urisTest.js` | 5 | 11 | — | gap |
| 13 | `tests/utilsTest.js` | 10 | 54 | — | gap |
| 14 | `tests/wikipediaTest.js` | 1 | 14 | — | gap |
| | **Total** | **43 (rows) / 359 (assertions)** | | | **0 ported, 43 gaps** |

Every row is a gap. None of the 43 named upstream units, and none of the 359
assertions behind them, has any counterpart anywhere in the port's own
`test/` or `spec/` trees — confirmed by reading every port test file that
exists (there are two: `test/drive_gnome_maps.rb`, `test/gtk_driver.rb`), and
neither one references `address`, `boundingBox`, `color`, `downloads`,
`epaf`, `osmNames`, `placeIcons`, `placeStore`, `placeZoom`, `time`,
`translations`, `uris`, `utils`, or `wikipedia` logic in any form.

## The suite that never ran

The port declares an RSpec suite (`spec/spec_helper.rb`, `.rspec`,
`spec/README.md`) and advertises its run command in the dev shell banner.
Run exactly as the drive shell prints it:

```
$ nix develop --command ruby -e 'require "rspec/core"; exit RSpec::Core::Runner.run(["--format", "progress", "--require", "spec_helper", "spec"])'
Failure/Error: require "kettle/test/rspec"
LoadError:
  cannot load such file -- kettle/test/rspec
0 examples, 0 failures, 2 errors occurred outside of examples
```

`spec/spec_helper.rb` requires a gem (`kettle-soup-cover`'s companion
`kettle/test/rspec`) that is not resolvable in the dev shell's bundle, so
`spec_helper` itself cannot load. There are also, separately, **zero**
`*_spec.rb` files under `spec/` — `find spec -name '*_spec.rb' | wc -l` is 0
— so even a working `spec_helper` would run nothing. Two independent reasons
for the same fact: **the RSpec suite has never been green, because it has
never run, because there is nothing in it to run even if it did.**

This is exactly the failure mode the runtime gate for this round
(`drive_ok=true, 29 checks passed, 0 failed, covering 3 components`) can
make invisible if read alone: those 29 checks are real, they are
`test/drive_gnome_maps.rb`'s own `check(...)` calls (confirmed by running it
this round — see below), and they are **not** RSpec examples, **not** any
of the 43 upstream units above, and they cover exactly 3 files
(`application.rb`, `settings.rb`, `shortcuts_dialog.rb`). A reader who sees
"29 passed, 0 failed" without also seeing "0 examples, 0 failures, 2 errors"
from the sibling suite, and without seeing that upstream has 43 named units
none of which are among the 29, would reasonably conclude more coverage
exists than does.

## This round's own drive run

```
$ nix develop --command xvfb-run -a ruby test/drive_gnome_maps.rb
...
29 of 29 checks passed
DRIVE OK
```

Confirmed by running it, not by trusting the stated gate. All 29 checks are
against `application.rb` (window shape, actions), `shortcuts_dialog.rb`
(sections/items/accelerators), and `settings.rb` (round-trip, defaults,
malformed-file fallback). These are useful, real, passing checks — and they
are entirely **extra** by this skill's definition: none of them was written
from an upstream test, because none of the 3 files they cover has an
upstream test file backing it in the first place (`application.js`,
`settings.js`, and the shortcuts dialog's `.blp` are not among the 14 files
`tests/meson.build` runs). They are listed under `## Extra` below, not
counted toward the 43.

## Extra

- `test/drive_gnome_maps.rb` — 29 checks driving the window, the shortcuts
  dialog, and `Settings`' JSON round-trip/fallback behaviour. Real,
  passing, driven headlessly. Not a port of any upstream test.

## Verdict

**0 / 43 named units ported (0 / 359 assertions). The RSpec suite the port
declares does not load and contains no examples.** The only tests that
exist and pass are 29 checks the port wrote for itself, covering 3 of
upstream's ~150 source files. Upstream's entire safety net — including
125 assertions in `translationsTest.js` alone — has not been inherited.
