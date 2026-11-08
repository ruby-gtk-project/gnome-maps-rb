# Component parity — gnome-maps-rb

| | |
|---|---|
| Upstream | `main` @ `9970d8f1` |
| Port | `ruby` @ `c846de15` |
| Units with full (4-axis) parity | **0 / 14 ported units** — several are close, none clear all four axes without a flagged gap or an unverified axis |

Per the skill's own rule: parity is only claimed for a unit actually driven
and checked on count/style/behaviour/text. Nothing below is claimed beyond
what `test/drive_gnome_maps.rb` (81/81 passing, confirmed this round) or a
direct read of the two source trees actually shows.

## Unit: shortcuts dialog — `data/ui/shortcuts-dialog.blp` → `shortcuts_dialog.rb`

| Axis | Upstream | Port | Verdict |
|---|---|---|---|
| Widget/count | 2 sections × 9 items | same, driven (`[3]`) | match |
| Style | not diffed against `data/*.css` this round | — | **unverified**, said plainly |
| Behaviour | opened via `app.shortcuts` (app-scoped); `<Primary>Q` Quit, `<Primary>F` Search | opened via `win.show-shortcuts` (window-scoped); same two accelerators, driven | **gap**: action namespace differs (app- vs window-scoped). A system shortcut-override tool or script targeting `app.shortcuts` finds nothing. |
| Text | not re-diffed against a fresh `origin/main:data/ui/shortcuts-dialog.blp` this round | — | **unverified** |

## Unit: window shell + actions — `src/application.js`/`src/mainWindow.js` → `application.rb`

| Axis | Upstream | Port | Verdict |
|---|---|---|---|
| Widget | `MapsApplicationWindow`: header bar, hamburger menu, map, search bar, place/route sidebar | `Adwaita::ApplicationWindow` → `ToolbarView` with header bar + search bar as top bars, `ToastOverlay` → `Gtk::Overlay` holding the live map + zoom controls + context menu | **partial match**: the map/search/header-bar skeleton is real and assembled (confirmed by reading `application.rb` directly — earlier drafts of this report described a placeholder `Adw::StatusPage` that is no longer, and may never have been, accurate; corrected here). Still missing: a hamburger/primary menu and a place/route detail sidebar — a search hit recenters the map but has nowhere to render place details |
| Actions | `app.osm-account-setup`, `app.shortcuts`, `win.export-as-image`, `win.show-preferences`, `win.about`, plus map/zoom/location/scale actions wired into the real UI | 9 `win.*` actions exist and are driven (`show-shortcuts`, `sign-in-osm`, `show-preferences`, `zoom-in`, `zoom-out`, `reset-rotation`, `goto-user-location` [disabled], `show-scale`, `show-location-marker`) | **partial** — action *surface* grew a lot since the last report, but `win.export-as-image` and `win.about` still have no counterpart, and `goto-user-location` is permanently disabled pending the Geoclue/Ashpd location component |
| Behaviour | window-geometry persistence on close | same, driven, passes | **match** |
| Text | window title (not diffed), no `_()`/gettext marker | literal `"gnome-maps"` | **gap** (also flagged in `translation-parity.md`) |

## Unit: zoom/rotate controls — `data/ui/zoom-and-rotate-controls.blp` → `zoom_and_rotate_controls.rb`

| Axis | Upstream | Port | Verdict |
|---|---|---|---|
| Widget | overlay buttons bound to `win.zoom-in`/`win.zoom-out`/compass reset | same shape, driven (`[2]`): actions enabled, reachable from the window, activating `zoom-in` moves the real viewport | **match on the behaviour actually driven** |
| Style | not diffed | — | **unverified** |
| Text | tooltips/labels not diffed against upstream's `.blp` strings | — | **unverified** |

This is the strongest unit in the port this round — it is wired to a real
`Shumate` viewport, not a stub — but "style" and "text" were not checked,
so it is not claimed as full 4-axis parity either.

## Unit: preferences dialog — `data/ui/preferences.blp` → `preferences.rb`

| Axis | Upstream | Port | Verdict |
|---|---|---|---|
| Widget | `Adw.PreferencesDialog` with a general page and a downloads page (`preferences-downloads.blp`, offline-region management) | opens as a real `Adw` dialog, driven (`app.preferences_action.activate`, checked that `window.visible_dialog` is set, then closed) | **partial match** on the one page it has |
| Behaviour | `show-scale` / `show-location-marker` switches read/write GSettings | `show-scale` switch starts matching `Settings`' saved value and a toggle round-trips back through `Settings`, driven and passing | **match**, for the one switch actually driven (`show-location-marker` exists as an action per `application.rb` but is not separately exercised in this step) |
| Completeness | ships a downloads/offline-maps page | `preferencesDownloads.js`/`preferences-download-row.blp`/`preferences-download-new.blp` have no port counterpart (`component-identification.md`) | **gap**: even though the general page is real and driven, the dialog as upstream ships it (general + downloads) is not fully present |
| Style/Text | not diffed | — | **unverified** |

## Unit: context menu — `data/ui/context-menu.blp` → `context_menu.rb`

| Axis | Upstream | Port | Verdict |
|---|---|---|---|
| Widget/actions | right-click menu: "What's here?"/copy coordinates, add OSM location, route from/to here | `copy-location` (enabled), `route-from-here` and `add-osm-location` (registered but disabled), driven | **partial match** — the enabled/disabled split is deliberate and documented in the drive script's own check names ("no route planner this round", "no OSM edit dialog this round"), which is honest framing, not a hidden gap |
| Behaviour | copying a location writes a `geo:` URI | driven: `show_at` then `activate_action("copy-location", nil)`, then asserts the window clipboard actually received content | **match**, and non-trivially so — it's a real clipboard write, not a stub |
| Integration | attached to `mapView.js`'s right-click gesture in the real window | the drive script calls `app.context_menu.send(:show_at, ...)` directly (note `send` — it is a private method being reached into), not by simulating an actual right-click gesture on the map widget | **gap, named precisely**: the menu's own actions are proven; whether a real right-click on the live map actually opens it has not been driven — the test reaches past the public API to force it open |
| Style/Text | not diffed | — | **unverified** |

## Unit: five standalone row widgets — instruction/POI-category/POI-category-goback/transit-more/shape-layer rows

| Axis | Upstream | Port | Verdict |
|---|---|---|---|
| Widget/behaviour | each row's upstream `.blp` + `.js` | driven individually, 26 checks across the 5 rows (`[21]`–`[25]`), all passing, including a visibility-toggle round trip on `ShapeLayerRow` | **closest thing to a clean match in the app** on the axes actually driven |
| Model backing | each row is backed by a real upstream model (`Place`/`Route::TurnPoint`, `ShapeLayer`, a transit itinerary) | each duck-types a hash/stub in place of that model (confirmed in `component-identification.md`) | **gap, named rather than hidden**: these rows are real widgets, correctly shaped, but nothing in the real app yet produces the data they'd be fed in production — they are proven in isolation, not integrated |
| Style/Text | not diffed against upstream CSS/strings | — | **unverified** |

## Every other upstream unit (≈135 of ~152 `src/*.js` + remaining `.blp`)

**0 driven, 0 checked.** Map markers/layers, search, routing, transit,
OSM editing, print/export, and the real window assembly do not exist in
`lib/` at all — see `component-identification.md`'s gap list, which is the
record for these.

## Verdict

No unit clears all four axes this round. The zoom/rotate controls, the
context menu, the preferences dialog, and the five row widgets are all
real and driven with behavioural checks that actually exercise them (not
just construct-and-discard) — genuine progress over the prior round, where
two of these three newest files would have had zero coverage. But every
one of them still has at least one unexamined axis (style and/or text, in
every single case), and the context menu's own drive test reaches past its
public API (`send(:show_at, ...)`) rather than proving the real right-click
gesture path works. The window itself, which is the one component every
user sees first, is a real assembly of header bar, search bar, live map,
zoom controls, and context menu — not a placeholder, correcting what an
earlier draft of this report claimed — but it still has no hamburger menu,
no place/route sidebar, and no search-results surface. 81/81 drive checks
passing is a true and growing
number; it is not evidence of component parity for the ~90% of upstream's
components (markers, search, routing, transit, OSM editing, print/export,
the real window layout) it doesn't touch.
