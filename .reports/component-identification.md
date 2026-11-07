# Component identification — gnome-maps-rb

| | |
|---|---|
| Upstream | `origin/main` @ `9970d8f1` |
| Port | `ruby` @ `47d67faf` |
| Scanned | 2026-11-07 |

This repeats and reconfirms the opening survey already on `ruby` at
`.reports/component-inventory.md` (same branch tip for `lib/`; the only
commit since that survey added `test/drive_gnome_maps.rb` and
`test/gtk_driver.rb`, neither of which is a component). Numbers below are
re-derived this round, independently, to check that survey rather than cite
it as settled.

## Scale

- Upstream `src/*.js`: **152** files (confirmed via
  `git ls-tree -r --name-only origin/main | grep -E '^src/.*\.js$' | wc -l`).
- Upstream `data/ui/*.blp`: not separately re-counted this round; the prior
  survey recorded 37 and nothing has changed upstream-side to doubt it.
- Upstream `data/org.gnome.Maps.gschema.xml`: 1 schema, dozens of keys
  (`last-viewed-location`, `zoom-level`, `rotation`, `map-type`,
  `window-size`, `window-position`, and more — only the first six were read
  this round).
- Port `lib/*.rb`: **5** files total, of which **3** are real
  (`application.rb`, `settings.rb`, `shortcuts_dialog.rb`) and 2 are gem
  boilerplate (`gnome_maps.rb`, `gnome/maps/rb/version.rb`).

152 upstream source files map to 3 real port files. That ratio is the
finding; everything below is where the 3 actually stand.

## What exists, named and located

### `lib/gnome_maps/application.rb` ← `src/application.js` (partial)

- `Adwaita::ApplicationWindow` (1), title "gnome-maps" — upstream's
  `MapsApplicationWindow` is a full window with a header bar, a hamburger
  menu, a map view and a search bar; the port's is one window holding a
  `ToolbarView` with a bare `Adw::StatusPage` as its only content.
- `Adw::StatusPage`, icon `applications-engineering-symbolic` — this is not
  upstream's window content at all. It is a placeholder the port drew for
  itself; upstream has no "port not written yet" status page, obviously,
  because upstream is finished.
- Actions: `shortcuts_action` (`show-shortcuts`, window-scoped). Upstream
  installs this as `app.shortcuts` (application-scoped) plus
  `app.osm-account-setup`, `win.export-as-image`, `win.show-preferences`,
  `win.about` — four of upstream's five actions have no counterpart anywhere
  in the port.
- Window geometry persistence on `close-request`, wired to `Settings`. This
  is a real, working, upstream-equivalent behaviour (see the drive harness).

### `lib/gnome_maps/settings.rb` ← `src/settings.js` + `data/org.gnome.Maps.gschema.xml`

- Not a GSettings/GIO.Settings wrapper — the port is a hand-rolled
  JSON-file store (`Dir.home` config dir, `settings.json`) with a `DEFAULTS`
  hash. It answers `zoom_level`, `map_type`, `show_scale`,
  `last_viewed_location`, `window_maximized`, and persists them. It does not
  touch `org.gnome.Maps.gschema.xml` at all — the port ships no schema, so
  `gsettings get org.gnome.Maps ...` has nothing to read, and any other tool
  that inspects Maps' settings via dconf sees nothing.

### `lib/gnome_maps/shortcuts_dialog.rb` ← `data/ui/shortcuts-dialog.blp`

- `Adwaita::ShortcutsDialog`, built from a `SECTIONS` hash with two
  sections ("General", "Map View"), 9 items each. The drive harness confirms
  the dialog opens, both section titles and item counts, and that Quit is
  `<Primary>Q` and Search is `<Primary>F`. This is the one place the port's
  surface actually matches upstream's data on inspection — contingent on
  upstream's `shortcuts-dialog.blp` still listing exactly 9+9 items and those
  two accelerators, which was not re-diffed against `origin/main` this
  round (carried over from the prior survey; flagged as unverified-this-round
  below).

## What does not exist — named by upstream file, not by category

Every row below is **zero**, not partial, not "covered differently":

- **Windows**: `src/mainWindow.js` (the real main window: header bar,
  hamburger menu, map, search bar, place/route views slotted in) — 0.
- **Dialogs**: `exportViewDialog.js`, `osmAccountDialog.js`,
  `osmDiscardDialog.js`, `osmEditDialog.js`, `sendToDialog.js`,
  `preferences.js` — 0 of 6.
- **Pages**: `placeView.js`, `routeView.js`, `transitOptionsPanel.js`,
  `preferencesDownloads.js`, `preferencesDownloadNew.js`,
  `auxillaryView.js` — 0 of 6.
- **Rows**: 13 upstream row files (`favoriteListRow.js` through
  `transitStopRow.js`, `shape-layer-row`) — 0 of 13.
- **Popovers**: `favoritesPopover.js`, `layersPopover.js`,
  `placePopover.js`, `searchPopover.js` — 0 of 4.
- **The map itself**: `mapView.js`, `mapWalker.js` and every marker/layer
  class (14 files) — 0. There is no `Shumate` widget anywhere in `lib/`.
  gnome-maps-rb currently cannot display a map.
- **Search, routing, transit, OSM editing**: `placeEntry.js`, `searchBar.js`,
  `routeEntry.js`, `routeQuery.js`, `routingDelegator.js`, `osmEdit.js`,
  `osmConnection.js`, the entire `transit/` and `transit*.js` set (23
  files) — 0.
- **Print flow**: `printOperation.js` and the 4 layout files — 0.
- **Localization plumbing**: no `po/` directory at all (see
  `translation-parity.md`).

## Correction to the prior survey

The prior survey's header claims "571 tracked files outside `data/icons/`".
This round's `git ls-tree` count of the same exclusion is higher once
`data/shields/*` (170+ files) is included — the prior number likely also
excluded shields, or was counted before some upstream commits landed. Not
re-reconciled byte-for-byte this round; flagged rather than silently carried
forward as exact.

## Unverified this round (say so rather than imply it was checked)

- The 37-`.blp` count, the exact shortcuts-dialog content against a fresh
  diff of `origin/main`'s `data/ui/shortcuts-dialog.blp`, and the full
  `data/ui/*.blp` tree were **not** re-scanned this round — carried over
  from the existing `.reports/component-inventory.md`. If `origin/main` has
  moved since that survey was written, those specific numbers may be stale.
  Confirmed stable this round: `src/*.js` = 152, `lib/*.rb` = 5 (3 real).
- A full four-axis (`component-scan.sh`) run over the whole upstream `src/`
  tree did not finish inside this round's time budget (it was started twice
  and killed/timed out against 152 files plus the full `data/` tree). The
  partial run returned 314 rows before timing out at 100s. **This is itself
  a gap in the audit, not just in the port**: the opening-survey numbers
  above are accurate (file existence, counts, grep), but a row-by-row
  widget/CSS/signal table for each of the 149 missing upstream files was not
  produced. Given that 149 of 152 files have **zero** port counterpart, a
  per-widget table would currently read "upstream: N, port: 0" on every row
  — the file-level gap list above states the same fact at the resolution
  that matters right now. The per-widget table becomes necessary once a unit
  is actually picked up for porting (per the skill's own scoping rule), not
  before.
