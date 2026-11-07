# Component inventory — gnome-maps-rb

Surveyed against `origin/main` (upstream GNOME Maps, GJS). This is the opening
survey of a fresh fork: a file-level map of every user-facing component to the
`lib/*.rb` file it should become, not yet a widget/CSS/signal breakdown (that
is `component-parity`'s job, once a unit is picked to port).

Current state of `ruby`: `lib/` has exactly one real component —
`lib/gnome_maps/application.rb`, the `GnomeMaps::Application` class with a
window, a header bar and a placeholder status page — plus the gem's
boilerplate (`lib/gnome_maps.rb`, `lib/gnome/maps/rb/version.rb`). Everything
below marked "no" does not exist yet.

Upstream totals: 571 tracked files outside `data/icons/`; 141 `src/*.js`
files; 37 `data/ui/*.blp` templates; 1 GSettings schema
(`data/org.gnome.Maps.gschema.xml`); 4 GResource manifests; 76 `po/*.po`
catalogues plus `POTFILES.in`/`LINGUAS`.

## Window

| Upstream file(s) | → `lib/*.rb` | Kind | Exists? |
|---|---|---|---|
| `src/mainWindow.js` + `data/ui/main-window.blp` (incl. hamburger menu, `app.shortcuts` action, `win.export-as-image`, `win.show-preferences`, `win.about`) | `lib/gnome_maps/main_window.rb` | window + menu + actions | no |
| `src/application.js` | `lib/gnome_maps/application.rb` | application (actions: `app.osm-account-setup`, `app.shortcuts`, accelerators) | **partial** — window/header-bar/status-page placeholder exists; no real actions, no command-line handling, no accelerator map |
| `src/headerBar.js` + `data/ui/headerbar-left.blp` + `data/ui/headerbar-right.blp` | `lib/gnome_maps/header_bar.rb` | headerbar (two template halves, one class) | **partial** — a bare header bar exists inside `application.rb`; not its own file, no left/right content |

## Dialogs

| Upstream file(s) | → `lib/*.rb` | Kind | Exists? |
|---|---|---|---|
| `src/exportViewDialog.js` + `data/ui/export-view-dialog.blp` | `lib/gnome_maps/export_view_dialog.rb` | dialog | no |
| `src/osmAccountDialog.js` + `data/ui/osm-account-dialog.blp` | `lib/gnome_maps/osm_account_dialog.rb` | dialog | no |
| `src/osmDiscardDialog.js` + `data/ui/osm-discard-dialog.blp` | `lib/gnome_maps/osm_discard_dialog.rb` | dialog | no |
| `src/osmEditDialog.js` + `data/ui/osm-edit-dialog.blp` | `lib/gnome_maps/osm_edit_dialog.rb` | dialog | no |
| `src/sendToDialog.js` + `data/ui/send-to-dialog.blp` + `data/ui/open-with-row.blp` (row within) | `lib/gnome_maps/send_to_dialog.rb` | dialog (+ row) | no |
| `src/preferences.js` + `data/ui/preferences.blp` | `lib/gnome_maps/preferences_dialog.rb` | dialog (`Adw.PreferencesDialog`) | no |
| `data/ui/shortcuts-dialog.blp` (`Adw.ShortcutsDialog`; no backing `.js` — built from the resource by `app.shortcuts`) | `lib/gnome_maps/shortcuts_dialog.rb` | dialog (keyboard shortcuts) | no |

## Pages / views

| Upstream file(s) | → `lib/*.rb` | Kind | Exists? |
|---|---|---|---|
| `src/placeView.js` + `data/ui/place-view.blp` (+ `src/placeViewImage.js` for the image slot) | `lib/gnome_maps/place_view.rb` | page | no |
| `src/routeView.js` + `data/ui/route-view.blp` | `lib/gnome_maps/route_view.rb` | page | no |
| `src/transitOptionsPanel.js` + `data/ui/transit-options-panel.blp` (driven by `src/transitOptions.js`, the option model) | `lib/gnome_maps/transit_options_panel.rb` | page/panel | no |
| `src/preferencesDownloads.js` + `data/ui/preferences-downloads.blp` (+ `data/ui/preferences-download-row.blp` for its rows) | `lib/gnome_maps/preferences_downloads.rb` | page | no |
| `src/preferencesDownloadNew.js` + `data/ui/preferences-download-new.blp` | `lib/gnome_maps/preferences_download_new.rb` | page | no |
| `src/auxillaryView.js` + `data/ui/auxillary-view.blp` | `lib/gnome_maps/auxillary_view.rb` | view | no |

## Rows

| Upstream file(s) | → `lib/*.rb` | Kind | Exists? |
|---|---|---|---|
| `src/favoriteListRow.js` + `data/ui/favorite-list-row.blp` | `lib/gnome_maps/favorite_list_row.rb` | row | no |
| `src/instructionRow.js` + `data/ui/instruction-row.blp` | `lib/gnome_maps/instruction_row.rb` | row | no |
| `src/placeListRow.js` + `data/ui/place-list-row.blp` | `lib/gnome_maps/place_list_row.rb` | row | no |
| `src/poiCategoryGobackRow.js` + `data/ui/poi-category-goback-row.blp` | `lib/gnome_maps/poi_category_goback_row.rb` | row | no |
| `src/poiCategoryRow.js` (driven by `src/poiCategories.js`) + `data/ui/poi-category-row.blp` | `lib/gnome_maps/poi_category_row.rb` | row | no |
| `src/routeEntry.js` + `data/ui/route-entry.blp` | `lib/gnome_maps/route_entry.rb` | row | no |
| `src/transitArrivalDestinationRow.js` + `data/ui/transit-arrival-destination-row.blp` | `lib/gnome_maps/transit_arrival_destination_row.rb` | row | no |
| `src/transitItineraryRow.js` + `data/ui/transit-itinerary-row.blp` | `lib/gnome_maps/transit_itinerary_row.rb` | row | no |
| `src/transitJunctureRow.js` + `data/ui/transit-juncture-row.blp` | `lib/gnome_maps/transit_juncture_row.rb` | row | no |
| `src/transitLegHeader.js` + `data/ui/transit-leg-header.blp` | `lib/gnome_maps/transit_leg_header.rb` | row/header | no |
| `src/transitLegRow.js` + `data/ui/transit-leg-row.blp` (+ `src/transitRowTrackSegment.js` for its track-segment sub-widget) | `lib/gnome_maps/transit_leg_row.rb` | row | no |
| `src/transitMoreRow.js` + `data/ui/transit-more-row.blp` | `lib/gnome_maps/transit_more_row.rb` | row | no |
| `src/transitStopRow.js` + `data/ui/transit-stop-row.blp` | `lib/gnome_maps/transit_stop_row.rb` | row | no |
| `data/ui/shape-layer-row.blp` (backed by `src/layersPopover.js`, one row per loaded shape layer) | `lib/gnome_maps/shape_layer_row.rb` | row | no |

## Popovers

| Upstream file(s) | → `lib/*.rb` | Kind | Exists? |
|---|---|---|---|
| `src/favoritesPopover.js` + `data/ui/favorites-popover.blp` | `lib/gnome_maps/favorites_popover.rb` | popover | no |
| `src/layersPopover.js` + `data/ui/layers-popover.blp` | `lib/gnome_maps/layers_popover.rb` | popover (owns shape-layer-row) | no |
| `src/placePopover.js` + `data/ui/place-popover.blp` | `lib/gnome_maps/place_popover.rb` | popover | no |
| `src/searchPopover.js` (no `.blp`; built in code, hosts search-result rows and the "no results" empty state) | `lib/gnome_maps/search_popover.rb` | popover + empty state | no |

## Menus

| Upstream file(s) | → `lib/*.rb` | Kind | Exists? |
|---|---|---|---|
| `data/ui/context-menu.blp` (backed by `src/mapView.js`; right-click map menu — "What's here?", "Copy location", geo: URI) | `lib/gnome_maps/map_view.rb` (menu built alongside the map widget) | menu | no |
| `hamburgerMenu` inside `data/ui/main-window.blp` | `lib/gnome_maps/main_window.rb` | menu | no |

## Map widget, markers & layers (all user-visible, driven by `Shumate`)

| Upstream file(s) | → `lib/*.rb` | Kind | Exists? |
|---|---|---|---|
| `src/mapView.js` | `lib/gnome_maps/map_view.rb` | widget (the map itself; owns context menu) | no |
| `src/mapWalker.js` | `lib/gnome_maps/map_walker.rb` | controller (pan/zoom animation, not a widget) | no |
| `src/zoomAndRotateControls.js` + `data/ui/zoom-and-rotate-controls.blp` | `lib/gnome_maps/zoom_and_rotate_controls.rb` | widget | no |
| `src/placeButtons.js` + `data/ui/place-buttons.blp` | `lib/gnome_maps/place_buttons.rb` | widget | no |
| `src/placeEntry.js` | `lib/gnome_maps/place_entry.rb` | widget (search entry) | no |
| `src/searchBar.js` | `lib/gnome_maps/search_bar.rb` | widget | no |
| `src/mapMarker.js` | `lib/gnome_maps/map_marker.rb` | widget (marker base class) | no |
| `src/placeMarker.js` | `lib/gnome_maps/place_marker.rb` | widget (marker) | no |
| `src/iconMarker.js` | `lib/gnome_maps/icon_marker.rb` | widget (marker) | no |
| `src/circleIconMarker.js` | `lib/gnome_maps/circle_icon_marker.rb` | widget (marker) | no |
| `src/userLocationMarker.js` | `lib/gnome_maps/user_location_marker.rb` | widget (marker) | no |
| `src/turnPointMarker.js` | `lib/gnome_maps/turn_point_marker.rb` | widget (marker) | no |
| `src/transitArrivalMarker.js` | `lib/gnome_maps/transit_arrival_marker.rb` | widget (marker) | no |
| `src/transitBoardMarker.js` | `lib/gnome_maps/transit_board_marker.rb` | widget (marker) | no |
| `src/transitWalkMarker.js` | `lib/gnome_maps/transit_walk_marker.rb` | widget (marker) | no |
| `src/transitPathLayer.js` | `lib/gnome_maps/transit_path_layer.rb` | layer (route polyline overlay) | no |
| `src/shapeLayer.js`, `src/geoJSONShapeLayer.js`, `src/gpxShapeLayer.js`, `src/kmlShapeLayer.js`, `src/fitShapeLayer.js` | `lib/gnome_maps/shape_layer.rb` (+ subclasses) | layer (imported-file overlays feeding `shape-layer-row`) | no |
| `src/transitRouteLabel.js` | `lib/gnome_maps/transit_route_label.rb` | widget (route-number badge) | no |

## Preferences (GSettings-backed)

| Upstream file(s) | → `lib/*.rb` | Kind | Exists? |
|---|---|---|---|
| `data/org.gnome.Maps.gschema.xml` | `lib/gnome_maps/settings.rb` | GSettings schema | no — **correction, 2026-11-07**: the original note here, "(schema consumed, not ported 1:1 as a widget)", overstated this. I checked `lib/gnome_maps/settings.rb` this round and it does not read `data/org.gnome.Maps.gschema.xml` at all, in any form — it is a hand-rolled JSON file store with its own `DEFAULTS` hash, not a `Gio::Settings` wrapper. Nothing in the schema (its key names, types, defaults, or the schema file itself) is consumed, because I am an idiot who wrote "schema consumed" without opening the file to check it. Upstream: `src/settings.js` wraps `Gio.Settings` against this schema, so `gsettings get org.gnome.Maps zoom-level` works. Port: `lib/gnome_maps/settings.rb` reads/writes its own `settings.json`; `gsettings get org.gnome.Maps zoom-level` sees nothing, because the port installs no schema. See `component-parity.md` and `translation-parity.md` for the same gap recorded against the settings unit and against the schema's translatable `<summary>`/`<description>` strings. |
| `src/settings.js` | `lib/gnome_maps/settings.rb` | service (wraps the schema above) | no |
| `src/preferences.js`, `src/preferencesDownloads.js`, `src/preferencesDownloadNew.js` | see Dialogs/Pages above | preferences UI | no |

## Error / empty states

| Upstream file(s) | → `lib/*.rb` | Kind | Exists? |
|---|---|---|---|
| placeholder status page built ad hoc in `src/application.js`'s window setup | `lib/gnome_maps/application.rb` | empty state (`Adw.StatusPage`, "port not written yet") | **yes** — this is the one piece of real UI already in the port, and it is a placeholder, not upstream's actual empty/error states |
| `src/searchPopover.js` "no results" row | `lib/gnome_maps/search_popover.rb` | empty state | no |
| map-load / network-error handling in `src/mapView.js`, `src/osmEdit.js`, `src/osmEditDialog.js` | respective files above | error state | no |

## Print flow (dialog-adjacent; triggered from `win.export-as-image` / route printing)

| Upstream file(s) | → `lib/*.rb` | Kind | Exists? |
|---|---|---|---|
| `src/printOperation.js` | `lib/gnome_maps/print_operation.rb` | controller (wraps `Gtk.PrintOperation`) | no |
| `src/printLayout.js`, `src/longPrintLayout.js`, `src/shortPrintLayout.js`, `src/transitPrintLayout.js` | `lib/gnome_maps/print_layout.rb` (+ subclasses) | layout (drawn page, not a widget) | no |

## Keyboard shortcuts & actions summary

- `app.osm-account-setup`, `app.shortcuts` — installed on the application (`src/application.js` → `lib/gnome_maps/application.rb`).
- `win.export-as-image`, `win.show-preferences`, `win.about` — installed on the main window (`src/mainWindow.js` → `lib/gnome_maps/main_window.rb`).
- Accelerators (`<Primary>comma` preferences, `<Primary>question` shortcuts, `<Primary>F` search, and the rest listed in `data/ui/shortcuts-dialog.blp`) are set up wherever the actions above are installed — none exist on `ruby` yet.

## Localization

- `po/POTFILES.in`, `po/LINGUAS`, 76 `po/*.po` catalogues — translation-parity's domain, not listed as components. Flagged here only because the task asked for the catalogue to be surveyed: it exists upstream in full and has no counterpart on `ruby` (no `po/` directory at all yet).

## Not in scope for this inventory (data/model/parsing layers, not components)

For completeness: upstream's `src/` also contains ~70 files that are pure
data/model/parsing/network code with no widget of their own — e.g. `place.js`,
`route.js`, `location.js`, `osmUtils.js`, `graphHopper.js`, `overpass.js`,
`wikipedia.js`, `transit/*.js`, `mapStyle/*.js`, `geojson-vt/*`, `xmldom/*`,
`togeojson/*`, `thumbnails.js`, `jsonStorage.js`, `downloads.js`,
`offlineDataSource.js`, `geoclue.js`, `geocode.js`, `photonGeocode.js`,
`graphHopperGeocode.js`, `motis.js`, `transitous.js`, `overpass.js`, `http.js`,
`uris.js`, `utils.js`, `time.js`, `color.js`, `constants.js`, `epaf.js`,
`boundingBox.js`, `address.js`, `placeFormatter.js`, `placeIcons.js`,
`placeStore.js`, `routingDelegator.js`, `routeQuery.js`, `osmConnection.js`,
`osmOAuthProxyCall.js`, `osmNames.js`, `osmTypes.js`, `osmUtils.js`,
`wikipedia.js`, `translations.js`, `prototypes.js`, `mapSource.js`,
`mapStyle/mapStyle.js` and its per-layer-type siblings, `pmtiles.js`,
`gfx.js`. These back the components above (place data feeds `place_view.rb`
and the marker/row classes, `transit/*.js` feeds the transit rows and panel,
`mapStyle/*.js` feeds `map_view.rb`'s rendering) but are not themselves
user-facing widgets, so this survey does not give each one its own `lib/*.rb`
row — they belong to whichever component unit pulls them in when that unit is
ported.
