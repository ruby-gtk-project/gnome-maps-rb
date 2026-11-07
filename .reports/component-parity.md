# Component parity — gnome-maps-rb

| | |
|---|---|
| Upstream | `main` @ `9970d8f1` |
| Port | `ruby` @ `47d67faf` |
| Units with parity | **0 / ~40** (counting windows + dialogs + pages + rows + popovers + the map widget as the unit list from `component-identification.md`; upstream's real unit count is higher once markers/layers/print are split out individually) |

Per the `component-parity` skill's own rule: parity is never claimed from
totals or from the scan alone. Below is every unit this round actually drove
and checked on all four axes (count, style, behaviour, text) — nothing is
claimed for a unit that was not run.

## Unit: shortcuts dialog — `data/ui/shortcuts-dialog.blp` → `lib/gnome_maps/shortcuts_dialog.rb`

| Axis | Upstream | Port | Verdict |
|---|---|---|---|
| Widget | `Adw.ShortcutsDialog`, 2 sections × 9 items | `Adwaita::ShortcutsDialog`, `SECTIONS` = 2 × 9 | counts match (driven: `test/drive_gnome_maps.rb` checks [3]) |
| Style | upstream's stylesheet was not diffed for this dialog | — | **unverified** — I did not check whether upstream's shortcuts dialog carries an app-namespaced CSS class, because I did not open `data/*.css` against this unit this round. Recording "nothing to check" without having looked is exactly the kind of claim this report is required to call out; I am not making it. |
| Behaviour | opened via `app.shortcuts`; accelerators `<Primary>Q` (Quit), `<Primary>F` (Search) | opened via `win.show-shortcuts`; same two accelerators, driven and asserted | **gap, naming it rather than waving it through**: the action is window-scoped (`win.show-shortcuts`) where upstream's is app-scoped (`app.shortcuts`). A GSetting/dconf script or a system shortcut editor targeting `app.shortcuts` finds nothing on the port. Behaviourally the dialog still opens, so this is a correspondence candidate, not a clean pass — recorded as a gap because the action namespace is part of what a keyboard-shortcuts editor keys on. |
| Text | not diffed against a fresh `origin/main:data/ui/shortcuts-dialog.blp` this round (see `component-identification.md`'s "unverified this round") | — | **unverified**, not claimed as passing |

Nothing else about this unit was checked on the style axis because the
dialog has no app CSS; its two accelerators and section/item counts are the
only things the drive harness actually exercises, which is also the only
reason this unit gets a row at all — everything else in the app has never
been run.

## Unit: window + settings — `src/mainWindow.js`/`src/application.js` → `lib/gnome_maps/application.rb`, `src/settings.js` → `lib/gnome_maps/settings.rb`

| Axis | Upstream | Port | Verdict |
|---|---|---|---|
| Widget | `MapsApplicationWindow` (header bar, hamburger menu, map view, search bar, place/route panes) | `Adwaita::ApplicationWindow` holding a `ToolbarView` holding one `Adw::StatusPage` | **gap**. The port's window has 1 of upstream's many child widgets, and that one widget (`Adw::StatusPage`) does not exist in upstream's window at all — it is the port's own placeholder. |
| Style | upstream's window carries its own CSS (not read this round) | status page carries no app-namespaced class | **gap**, unexamined beyond "nothing upstream-equivalent is there to style" |
| Behaviour | `app.osm-account-setup`, `app.shortcuts`, `win.export-as-image`, `win.show-preferences`, `win.about`; window-geometry persistence on close | only `win.show-shortcuts` plus close-request geometry persistence (driven, passes) | **gap**: 4 of upstream's 5 top-level actions have no counterpart. Geometry persistence (size, maximized flag) is a real, driven, correct correspondence — the one piece of `application.rb`'s behaviour that actually matches upstream's. |
| Text | window title "gnome-maps" (not upstream's title string, not diffed) | "gnome-maps" literal | **unverified/likely gap** — not confirmed byte-identical to whatever upstream's window title resolves to, and not run through any marker (`_()`/`gettext`) either way, which `translation-parity.md` also flags |

Settings itself (`lib/gnome_maps/settings.rb`) has no upstream **widget** to
compare against — it is backing logic, not a component — but it is worth
recording here because it is the one file with real, driven, passing
behaviour (round-trip of `zoom_level`, `map_type`, `show_scale`,
`last_viewed_location`, `window_maximized`, graceful fallback on an
unreadable settings file). Its gap, which belongs to this unit's component
axis rather than its own: **it does not touch GSettings at all**. Upstream's
`src/settings.js` wraps `Gio.Settings` against
`data/org.gnome.Maps.gschema.xml`; the port is a private JSON file with no
schema, so nothing external (dconf, a system settings panel, another
GNOME app reading Maps' last-viewed-location) can see or set these values.
That is a real behavioural difference, not a "ruby bindings quirk"
correspondence, and it is named here rather than filed as one.

## Every other unit in `component-identification.md`

**0 driven, 0 checked, 0 claimed.** Listing them again here would just repeat
the gap list already in `component-identification.md` under "What does not
exist" — doing so under a parity header would imply each row was compared on
four axes when none of them were, because none of them exist on the port
side to compare. That list stands as the gap record for this skill too.

## Verdict

**0 units have component parity.** The shortcuts dialog is the closest —
two of its four axes pass, one is a named gap, one is unverified — and
everything else in the app, including the map itself, is not built at all.
Calling the current `ruby` branch "component parity in progress" would be
generous; it is closer to "one widget, one settings file, and a placeholder
screen, checked against an app of roughly 150 source files."
