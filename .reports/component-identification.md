# Component identification — gnome-maps-rb

| | |
|---|---|
| Upstream | `origin/main` @ `9970d8f1` |
| Port | `ruby` @ `c846de15` |
| Scanned | 2026-11-08 |

This supersedes the prior pass at the same path (last written against
`ruby` @ `47d67faf`). Three files landed since then —
`lib/gnome_maps/context_menu.rb`, `lib/gnome_maps/preferences.rb`,
`lib/gnome_maps/zoom_and_rotate_controls.rb` — plus, earlier in the same
run of commits, `poi_category_row.rb`, `poi_category_goback_row.rb`,
`transit_more_row.rb`, `shape_layer_row.rb`, `instruction_row.rb`,
`geocoder.rb`, `osm_connection.rb`. Numbers below are re-derived from the
current tree, not carried forward.

## Scale

- Upstream `src/*.js`: **152** files (`git ls-tree -r --name-only
  origin/main | grep -E '^src/.*\.js$' | wc -l`).
- Upstream `data/ui/*.blp`: **38** files (same command, `data/ui`).
- Upstream `po/*.po`: **73** files (see `translation-parity.md`).
- Port `lib/gnome_maps/*.rb`: **14** files, all real (no stub/boilerplate
  files left uncounted besides the gem's own `lib/gnome_maps.rb` and
  `lib/gnome/maps/rb/version.rb`, which are not components).

14 port files against 152 upstream `src/*.js` files (plus 38 `.blp`
templates they're built from) is still roughly a 1:11 ratio of components
landed to components named. The three-plus-eight added since the last
inventory are real, driven progress — not a reason to call this close to
done.

## What exists, named and located (14 files)

| Port file | Upstream source(s) | Note |
|---|---|---|
| `application.rb` | `src/application.js`, `src/mainWindow.js` (partial) | assembles a real window: `ToolbarView` with a header bar (search toggle, sign-in, preferences buttons) and a `Gtk::SearchBar` as top bars, a `ToastOverlay` → `Gtk::Overlay` holding the live `Shumate` map plus the zoom/rotate controls and the context menu attached to it; 9 `win.*` actions (`show-shortcuts`, `sign-in-osm`, `show-preferences`, `zoom-in`, `zoom-out`, `reset-rotation`, `goto-user-location` [disabled], `show-scale`, `show-location-marker`). This is a real, assembled, driven main window, not the placeholder `Adw::StatusPage` the prior round of this report described — **that description is stale and corrected here.** Still missing from it: a sidebar for place/route details, a search-results popover (the search entry's `activate` performs a lookup but there is nowhere for results to render — see below), and 2 of upstream's 5 top-level actions (`win.export-as-image`, `win.about`) |
| `map_view.rb` | `src/mapView.js`, `src/mapSource.js`, `src/mapWalker.js` | `Shumate::SimpleMap` wrapper; no markers, no routing/transit layers, no shape layers rendered on it yet |
| `geocoder.rb` | `src/geocode.js`, `src/photonGeocode.js`, `src/graphHopperGeocode.js` | uses `GeocodeGlib::Forward` rather than upstream's Photon/GraphHopper HTTP backends — a substitute, not a port of the named files |
| `osm_connection.rb` | `src/osmConnection.js` | OAuth2/PKCE via `Rest::OAuth2Proxy` |
| `settings.rb` | `src/settings.js`, `data/org.gnome.Maps.gschema.xml` | hand-rolled JSON file store, not `Gio::Settings` — ships no schema, invisible to dconf/gsettings |
| `shortcuts_dialog.rb` | `data/ui/shortcuts-dialog.blp` | `Adwaita::ShortcutsDialog`, 2 sections × 9 items, driven |
| `preferences.rb` | `data/ui/preferences.blp`, `src/preferences.js` | new this round; not yet verified against `preferences-downloads.blp`/`preferencesDownloads.js` (offline maps page) — see gaps below |
| `context_menu.rb` | `data/ui/context-menu.blp` + map-view wiring in `src/mapView.js` | new this round |
| `zoom_and_rotate_controls.rb` | `data/ui/zoom-and-rotate-controls.blp`, `src/zoomAndRotateControls.js` | new this round; driven against real `win.zoom-in`/`win.zoom-out`/`win.reset-rotation` actions |
| `instruction_row.rb` | `data/ui/instruction-row.blp`, `src/instructionRow.js` | duck-types an unported `Route::TurnPoint` |
| `poi_category_row.rb` | `data/ui/poi-category-row.blp`, `src/poiCategoryRow.js` | — |
| `poi_category_goback_row.rb` | `data/ui/poi-category-goback-row.blp`, `src/poiCategoryGobackRow.js` | — |
| `transit_more_row.rb` | `data/ui/transit-more-row.blp`, `src/transitMoreRow.js` | — |
| `shape_layer_row.rb` | `data/ui/shape-layer-row.blp`, `ShapeLayerRow` in `src/layersPopover.js` | duck-types an unported `ShapeLayer` model |

## What does not exist — named by upstream file, not by category

Everything not in the table above is **zero**, including:

- **The main window's remaining pieces**: `application.rb` does now
  assemble a real header bar, search bar, map, zoom controls, and context
  menu (corrected above). What is still missing from it: a hamburger/primary
  menu, a place/route detail sidebar, and anywhere for search results to
  render — `perform_search` (confirmed by reading `application.rb`) calls
  the geocoder and recenters the map on a hit, but there is no
  `searchPopover.js` equivalent, so a search with multiple candidate
  results, or one that needs disambiguation, has nowhere to show them.
- **Dialogs**: `exportViewDialog.js`, `osmAccountDialog.js`,
  `osmDiscardDialog.js`, `osmEditDialog.js`, `sendToDialog.js` — 0 of 5
  (`preferences.js` moved to "exists" above, but its downloads sub-page
  did not).
- **Pages**: `placeView.js`, `routeView.js`, `transitOptionsPanel.js`,
  `preferencesDownloads.js`, `preferencesDownloadNew.js`,
  `auxillaryView.js` — 0 of 6.
- **Popovers**: `favoritesPopover.js`, `layersPopover.js`,
  `placePopover.js`, `searchPopover.js` — 0 of 4 (the layers popover's one
  row class, `ShapeLayerRow`, is ported; the popover shell that hosts it is
  not).
- **Rows**: `favoriteListRow.js`, `placeListRow.js`, `routeEntry.js`,
  `openWithRow.js`, `preferencesDownloadRow.js`, the 7 transit row files
  (`transitItineraryRow.js`, `transitLegHeader.js`, `transitLegRow.js`,
  `transitJunctureRow.js`, `transitStopRow.js`,
  `transitArrivalDestinationRow.js`) — 0 of 12.
- **Markers / map layers**: `turnPointMarker.js`, `userLocationMarker.js`,
  `mapMarker.js`, `placeMarker.js`, `iconMarker.js`, `circleIconMarker.js`,
  `transitArrivalMarker.js`, `transitBoardMarker.js`,
  `transitWalkMarker.js`, `transitPathLayer.js`, shape-layer subclasses
  (`geoJSONShapeLayer.js`, `gpxShapeLayer.js`, `kmlShapeLayer.js`,
  `fitShapeLayer.js`) — 0 of ~14. The map can display tiles but nothing can
  be drawn on it.
- **Search, routing, transit backends**: `placeEntry.js`, `searchBar.js`,
  `searchPopover.js`, `routeQuery.js`, `routingDelegator.js`,
  `graphHopper.js`, `overpass.js`, `transit.js` and the whole `transit/`
  tree (plan/route/leg/juncture/stop/arrival/departure/utils/constants/hvt,
  `transitous.js`, `motis.js`) — 0.
- **OSM editing**: `osmEdit.js`, `osmUtils.js`, and the three dialogs above
  — 0. `osm_connection.rb` provides OAuth plumbing only; nothing calls it
  to actually submit a changeset.
- **Import/export/print**: `printOperation.js` + 4 layout files,
  `thumbnails.js`, `exportViewDialog.js`, `sendToDialog.js` — 0.
- **Place model/formatting**: `place.js`, `placeStore.js`,
  `placeFormatter.js`, `placeIcons.js`, `osmTypes.js`, `osmNames.js`,
  `poiCategories.js`, `storedRoute.js` — 0. Every row ported so far
  (`instruction_row.rb`, `shape_layer_row.rb`) duck-types these rather than
  having a real model underneath.
- **Geoclue / live location**: `src/geoclue.js` — 0; `goto_user_location`
  action exists in `application.rb` but is permanently disabled, by its own
  code comment, for lack of this component.
- **Localization**: no `po/` directory at all (0 of 73 catalogues; see
  `translation-parity.md`).

## Verdict

14 of ~152+38 upstream component-bearing files have a `lib/` counterpart,
and even several of those 14 duck-type unported model classes rather than
being complete. The main window is real and assembled this round (header
bar, search bar, live map, zoom controls, context menu all present and
wired to each other) — a correction upward from the prior round's report,
which described a placeholder that no longer matches the code. What still
does not exist: the map cannot show a marker or a route line, there is no
search-results UI, no routing, no transit, no OSM editing, no offline-map
downloads page, and no localization. Real, incremental progress happened
since the last inventory (+3 files this commit, +8 before that) — stated
as such, not inflated past what it is, and not understated by repeating a
stale description either.
