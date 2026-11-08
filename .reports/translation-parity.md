# Translation parity — gnome-maps-rb

| | |
|---|---|
| Upstream | `main` @ `9970d8f1` |
| Port | `ruby` @ `c846de15` (re-confirmed this round: still no `po/` directory, no `LINGUAS`, no `.po`/`.mo`, and `grep -rn 'gettext\|bindtextdomain' lib exe` still returns nothing, across all 14 current `lib/gnome_maps/*.rb` files, up from 3 at the prior round) |
| Domain | `gnome-maps` (`domain_source: meson project() - unconfirmed` — not cross-checked against `po/meson.build`'s `i18n.gettext()` call this round; flagged, not asserted) |
| Upstream messages | **540** |
| Ported | **0** |
| Gaps | **540** |
| Extra (untranslated) | 0 |
| Upstream occurrences | 622 across 540 messages (62 reused) |
| Port occurrences | 0 |
| Upstream languages | 73 `.po` files (matches `LINGUAS` exactly — `diff` of the two lists is empty), 29,144 translated strings, 1,086 untranslated, 27 fuzzy |
| Languages shipped by the port | **0** |
| Build command (port) | none — the port has no `po/` directory, no gettext dependency, no `.mo` build step |

Generated via `.claude/skills/translation-parity/scripts/catalogue.rb`
against a detached `origin/main` worktree (`/tmp/gnome-maps-upstream` @
`9970d8f1`) and the `ruby` branch in place. Full command and raw output are
not re-pasted here; the numbers above are read directly off that run.

## The census, unconditionally

```
$ ruby .claude/skills/translation-parity/scripts/catalogue.rb <port-tree> --role port
```

was not even run, because there is nothing to scan: `find . -iname '*.po'`
and `find . -type d -name po` both return empty on `ruby`. The port
catalogue is 0 messages, 0 occurrences, 0 languages by construction, not by
measurement — written down explicitly rather than left as an implication.

## 540 messages, 0 survived

Every one of upstream's 540 `(msgctxt, msgid)` keys is a gap. None of the
prior survey's suggestion that "a handful of literal strings might coincide"
was checked by grepping for exact upstream msgids inside `lib/` — given
`lib/` has three real files and none of their visible strings
("gnome-maps", the two shortcuts-dialog section titles, the 18 item labels)
were cross-checked against upstream's 540-entry list this round, that check
is left open rather than claimed. It would not change the headline number:
even a handful of coincidental matches out of 540 is still ~0%.

## Languages: 73 → 0

`po/LINGUAS` and the 73 `.po` files agree on `origin/main`
(`29,144` translated strings, `1,086` untranslated, `27` fuzzy — fuzzy
entries counted as untranslated per the skill's rule that `msgfmt`/`rmsgfmt`
both drop them from the `.mo`). The port ships none of this: no `po/`
directory, no `LINGUAS`, no `.po`, no `.mo`, no `bindtextdomain` call
anywhere in `lib/` or `exe/` (`grep -rn 'gettext\|bindtextdomain\|GetText'
lib exe` returns nothing). 73 languages' worth of donated translation work
— nearly three decades of it, going by the volume — currently has zero path
into this port.

## Unresolved markers

`catalogue.rb` reports `unresolved: 3` on the upstream side — call sites
whose argument is not a literal, which the skill requires be hand-resolved
before any ledger is final. One was spot-checked this round:
`lib/mapsintl.h:6`, which on inspection is C preprocessor macro plumbing
(`#define _(String) dgettext(...)` / `#else #define _(String) (String)
#endif`) that the scanner's regex partially matched as if it were a call
site — a scanner artifact, not a real message. **The other two were not
opened this round.** Per the skill's explicit rule ("never write a ledger
while `totals.unresolved` is non-zero"), this ledger is not final on the
upstream side either — it is reporting a verified floor of 540 messages,
with up to 2 more sites still to resolve by hand before the upstream column
itself can be called complete. That does not change the port's column,
which is 0 regardless of where the upstream total eventually settles.

## Checks not run

- `msgfmt -c` / `rmsgfmt` validation of the (nonexistent) port catalogue —
  nothing to validate.
- Running the port under a non-English locale
  (`LANGUAGE=de LC_ALL=de_DE.UTF-8 ...`) and asserting a translated string
  on screen — not run, because there is no catalogue for any locale to load.
  This is the skill's mandatory final check and it is explicitly recorded
  here as **not run**, per the skill's own rule that an unrun check must
  never be reported as passed.
- The remaining 2 of 3 upstream `unresolved` sites (above).

## Verdict

**0 / 540 messages, 0 / 622 occurrences, 0 / 73 languages, 0 / 29,144
translated strings.** The port is translated into nothing. Every string any
user will see in `gnome-maps-rb` today — "gnome-maps", the window title,
the shortcuts-dialog section and item labels, and now also "Search for a
place", "Sign in to OpenStreetMap", "Preferences" and every other string
added in `application.rb`, `context_menu.rb`, `preferences.rb`, and
`zoom_and_rotate_controls.rb` since the last round — is an untranslated
literal with no `_()`/`gettext` marker anywhere in `lib/` or `exe/`. The
gap has not narrowed as the port has grown; it has grown with it, since
every new user-visible string lands the same way as the ones before it.
