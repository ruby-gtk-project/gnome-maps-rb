# PORTING.md — ported-units ledger for gnome-maps-rb

Explicit ledger of what has actually been ported from upstream (`origin/main`
in this same repo) to the `ruby` branch, and what each unit's evidence is.
This file exists because a runtime-gate summary like "81 checks passed, 14
components" is easy to misread as broader coverage than it is. Read this file,
not that number, to know what is actually done.

A row only goes in "Ported" when there is a real check for it (drive-script
assertion, or an `rspec` spec) that exercises real behaviour, not merely that
a `require` didn't raise.

## Components (`lib/gnome_maps/*.rb`)

| Upstream file(s) | Port file | Dedicated check? |
|---|---|---|
| src/settings.js | lib/gnome_maps/settings.rb | collaborator only (used by other drive checks, no dedicated check) |
| src/shortcuts.js + blp | lib/gnome_maps/shortcuts_dialog.rb | drive script, check group |
| src/placeButtons.js (category rows) | lib/gnome_maps/poi_category_row.rb | drive script, check [22] |
| (category back-row widget) | lib/gnome_maps/poi_category_goback_row.rb | drive script, check [23] |
| src/transitMoreRow.js | lib/gnome_maps/transit_more_row.rb | drive script, check [25] |
| src/routeDetailsRow / instruction row | lib/gnome_maps/instruction_row.rb | drive script, check [21] |
| src/shapeLayerRow.js | lib/gnome_maps/shape_layer_row.rb | drive script, check [24] |
| src/mapView.js (Shumate wiring) | lib/gnome_maps/map_view.rb | drive script, collaborator in window checks |
| zoom/rotate overlay controls | lib/gnome_maps/zoom_and_rotate_controls.rb | drive script, check group |
| context menu (copy coords, geocode) | lib/gnome_maps/context_menu.rb | drive script, calls GeocodeGlib |
| src/application.js | lib/gnome_maps/application.rb | drive script, collaborator (app actions, ashpd/libgweather requires) |
| src/geocode.js (forward geocoding) | lib/gnome_maps/geocoder.rb | drive script, calls GeocodeGlib::Forward |
| OSM OAuth/PKCE connection | lib/gnome_maps/osm_connection.rb | drive script, calls Rest |
| src/preferences.js + blp | lib/gnome_maps/preferences.rb | drive script, check group |
| src/boundingBox.js | lib/gnome_maps/bounding_box.rb | **rspec spec** `spec/gnome_maps/bounding_box_spec.rb`, full port of `tests/boundingBoxTest.js` (13 examples) |

81 drive-script checks total across the rows above with a drive-script
column; see `test/drive_gnome_maps.rb`. `bounding_box.rb` is additionally
covered by a real RSpec suite now that the suite loads (see below).

## Upstream test files (`tests/*.js`) ported to `spec/*_spec.rb`

| Upstream test | Ruby spec | Status |
|---|---|---|
| tests/boundingBoxTest.js | spec/gnome_maps/bounding_box_spec.rb | Ported — 13 examples, all passing |
| tests/addressTest.js | — | not ported (depends on Address model, not yet ported) |
| tests/colorTest.js | — | not ported |
| tests/downloadsTest.js | — | not ported (depends on offline-tile backend, not yet ported) |
| tests/epafTest.js | — | not ported |
| tests/osmNamesTest.js | — | not ported (depends on Place model, not yet ported) |
| tests/placeIconsTest.js | — | not ported (depends on Place model) |
| tests/placeStoreTest.js | — | not ported (depends on PlaceStore model) |
| tests/placeZoomTest.js | — | not ported (depends on Place model) |
| tests/timeTest.js | — | not ported |
| tests/translationsTest.js | — | not ported (no gettext wiring yet) |
| tests/urisTest.js | — | not ported (needs Soup/Gtk URI parsing, deferred) |
| tests/utilsTest.js | — | not ported (large, depends on several unported models) |
| tests/wikipediaTest.js | — | not ported |

**The RSpec suite itself was broken before this pass**: `spec/spec_helper.rb`
hard-required `kettle/test/rspec`, a dev-only gem not present in the Nix dev
shell (`flake.nix` only carries plain `pkgs.rubyPackages_3_4.rspec`), so
`spec/*_spec.rb` could never load. It now falls back to plain RSpec the same
way the file already falls back for `kettle-soup-cover`. Separately,
`spec_helper.rb`'s `require "gnome/maps/rb"` had no backing file
(`lib/gnome/maps/rb.rb` did not exist, only `lib/gnome/maps/rb/version.rb`);
added it as a thin shim that requires the version file and `gnome_maps.rb`.
Both are prerequisites for porting any of the remaining 13 upstream test
files — now that the harness loads, each one can be ported once its
corresponding model exists.

## Binding gems (ashpd, geocode-glib, libgweather, librest, libshumate)

All five are declared in the gemspec, present in `nix/Gemfile` /
`nix/gemset.nix`, resolve via the typelibs `flake.nix`'s `gtkStack` carries,
and are `require`d and called on a live code path:

- `ashpd` / `libgweather` — `lib/gnome_maps/application.rb`
- `geocode-glib` — `lib/gnome_maps/geocoder.rb` (forward search) and
  `lib/gnome_maps/context_menu.rb` (reverse search)
- `librest` — `lib/gnome_maps/osm_connection.rb`
- `libshumate` — `lib/gnome_maps/map_view.rb`

Verified this pass with `nix develop --command xvfb-run -a ruby -e
'require "<gem>"'` for all five (all `OK`), and by re-running
`test/drive_gnome_maps.rb` (81/81 checks still pass, no regression).

## Known, documented gaps (not stubs — left out entirely)

- `src/geoclue.js` — no GeoClue2 typelib in `flake.nix` and ashpd 0.1.1 has
  no Location portal; `win.goto-user-location` is registered disabled with
  this reasoning in `lib/gnome_maps/application.rb`.
- Everything under "Components not implemented yet" in the task brief:
  main window, header bar, search bar/popover/place entry, Place/Route
  models and every widget depending on them (markers, sidebar, favorites,
  routing, transit), OSM edit/account/discard dialogs, export/send-to
  dialogs, offline-map downloads. None of these exist as stub files; they
  are simply absent from `lib/`.
