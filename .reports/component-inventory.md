# gnome-maps-rb component inventory

Survey of upstream `org.gnome.Maps` (read from `origin/main`) against the
`ruby` branch's `lib/`. Scope per the `component-identification` skill: every
user-facing component — windows, dialogs, pages, rows, menus, popovers,
keyboard shortcuts, preferences, actions, empty/error states — plus the
`.blp` UI files, GSettings schema, GResource manifests and the `po/`
catalogue. No app code was written for this pass.

Upstream is GJS (JavaScript + GtkBuilder/`.blp`), so each row below is a
`.js` file paired with its `.blp` template where one exists (upstream's own
house style: one `Foo` class in `src/foo.js`, one `<template class="Foo">`
in `data/ui/foo.blp`). The `ruby` branch has no `.ui`/`.blp` files by design
— widgets are built declaratively in Ruby (see `ruby-gtk` skill) — so the
"Port target" column is always a `lib/*.rb` path.

Legend for **Exists**: `yes` = the `lib/*.rb` file is present and the class
is required from `lib/gnome_maps.rb`; `partial` = a file exists but is a
stand-in/duck-typed collaborator rather than a full port of the named
upstream file; `no` = nothing yet.

## Already in `lib/` (8 components)

| Upstream file(s) | Port target | Kind | Exists |
|---|---|---|---|
| `src/application.js`, `src/main.js` | `lib/gnome_maps/application.rb` | application | yes |
| `src/mapView.js`, `src/mapSource.js`, `src/mapWalker.js` | `lib/gnome_maps/map_view.rb` | widget (map) | yes — built on `Shumate::SimpleMap` directly rather than reimplementing tile/marker/route layers |
| `src/geocode.js`, `src/photonGeocode.js`, `src/graphHopperGeocode.js` | `lib/gnome_maps/geocoder.rb` | service | yes — uses `GeocodeGlib::Forward` instead of upstream's own Photon/GraphHopper HTTP backends |
| `src/osmConnection.js` | `lib/gnome_maps/osm_connection.rb` | service (OAuth2/PKCE) | yes — uses `Rest::OAuth2Proxy`/`Rest::PkceCodeChallenge` |
| `src/settings.js`, `data/org.gnome.Maps.gschema.xml` | `lib/gnome_maps/settings.rb` | settings store | yes — JSON-file substitute for GSettings, same keys/defaults |
| `data/ui/instruction-row.blp` + `src/instructionRow.js` | `lib/gnome_maps/instruction_row.rb` | row | yes (duck-types an unported `Route::TurnPoint`) |
| `data/ui/poi-category-row.blp` + `src/poiCategoryRow.js` | `lib/gnome_maps/poi_category_row.rb` | row | yes |
| `data/ui/poi-category-goback-row.blp` + `src/poiCategoryGobackRow.js` | `lib/gnome_maps/poi_category_goback_row.rb` | row | yes |
| `data/ui/transit-more-row.blp` + `src/transitMoreRow.js` | `lib/gnome_maps/transit_more_row.rb` | row | yes |
| `data/ui/shape-layer-row.blp` + the `ShapeLayerRow` class in `src/layersPopover.js` | `lib/gnome_maps/shape_layer_row.rb` | row | yes (duck-types an unported `ShapeLayer`) |
| `data/ui/shortcuts-dialog.blp` | `lib/gnome_maps/shortcuts_dialog.rb` | dialog (keyboard shortcuts) | yes — `Adwaita::ShortcutsDialog` |

(That's 11 upstream units landing in 8 `lib/*.rb` files once the two rows
folded into `layersPopover.js` and the two POI rows are counted individually
— matches the 8 files currently under `lib/gnome_maps/`.)

## Missing — main window and chrome

| Upstream file(s) | Port target | Kind | Exists |
|---|---|---|---|
| `src/mainWindow.js` + `data/ui/main-window.blp` | `lib/gnome_maps/main_window.rb` | window | no — `application.rb` currently builds an ad hoc window/toolbar directly; this should become its own class |
| `src/headerBar.js` + `data/ui/headerbar-left.blp` + `data/ui/headerbar-right.blp` | `lib/gnome_maps/header_bar.rb` | widget (header bar, left+right halves) | no |
| `src/searchBar.js` | `lib/gnome_maps/search_bar.rb` | widget (search entry) | no |
| `src/searchPopover.js` | `lib/gnome_maps/search_popover.rb` | popover (search results list) | no |
| `src/placeEntry.js` | `lib/gnome_maps/place_entry.rb` | widget (autocomplete entry, used by search bar and route entries) | no |
| `data/ui/context-menu.blp` + context-menu wiring in `src/mapView.js` | `lib/gnome_maps/context_menu.rb` | menu (right-click: "What's here?", copy coords, add OSM location, route from/to here) | no |
| `data/ui/zoom-and-rotate-controls.blp` + `src/zoomAndRotateControls.js` | `lib/gnome_maps/zoom_and_rotate_controls.rb` | widget (map overlay buttons) | no |
| `data/ui/layers-popover.blp` + `src/layersPopover.js` (popover shell; `ShapeLayerRow` already ported above) | `lib/gnome_maps/layers_popover.rb` | popover (map-type + imported-layer list) | no |
| `data/ui/favorites-popover.blp` + `src/favoritesPopover.js` | `lib/gnome_maps/favorites_popover.rb` | popover | no |
| `data/ui/favorite-list-row.blp` + `src/favoriteListRow.js` | `lib/gnome_maps/favorite_list_row.rb` | row | no |

## Missing — place details

| Upstream file(s) | Port target | Kind | Exists |
|---|---|---|---|
| `data/ui/place-view.blp` + `src/placeView.js` | `lib/gnome_maps/place_view.rb` | page/sidebar (place detail panel) | no |
| `data/ui/place-popover.blp` + `src/placePopover.js` | `lib/gnome_maps/place_popover.rb` | popover (disambiguation list) | no |
| `data/ui/place-list-row.blp` + `src/placeListRow.js` | `lib/gnome_maps/place_list_row.rb` | row (recent/favorite place) | no |
| `data/ui/place-buttons.blp` + `src/placeButtons.js` | `lib/gnome_maps/place_buttons.rb` | widget (favorite/share/route/edit-on-OSM button row) | no |
| `src/placeViewImage.js` | `lib/gnome_maps/place_view_image.rb` | widget (Wikimedia thumbnail in place view) | no |
| `src/placeFormatter.js`, `src/placeIcons.js` | `lib/gnome_maps/place_formatter.rb`, `lib/gnome_maps/place_icons.rb` | formatter/lookup (not widgets, but feed every row/popover above) | no |
| `src/placeStore.js`, `src/storedRoute.js` | `lib/gnome_maps/place_store.rb` | model (recent places / routes persistence) | no |
| `src/place.js`, `src/osmTypes.js`, `src/osmNames.js`, `src/poiCategories.js` | `lib/gnome_maps/place.rb` + data tables | model | no |

## Missing — directions / routing

| Upstream file(s) | Port target | Kind | Exists |
|---|---|---|---|
| `data/ui/route-view.blp` + `src/routeView.js` | `lib/gnome_maps/route_view.rb` | page (turn-by-turn sidebar; hosts `InstructionRow`, already ported) | no |
| `data/ui/route-entry.blp` + `src/routeEntry.js` | `lib/gnome_maps/route_entry.rb` | row (from/to entry in the route planner) | no |
| `src/route.js`, `src/routeQuery.js`, `src/routingDelegator.js` | `lib/gnome_maps/route.rb` | model/controller | no |
| `src/graphHopper.js`, `src/overpass.js` | n/a | backend HTTP client, no widget | no |
| `src/turnPointMarker.js`, `src/userLocationMarker.js`, `src/mapMarker.js`, `src/placeMarker.js`, `src/iconMarker.js`, `src/circleIconMarker.js` | `lib/gnome_maps/markers/*.rb` | widget (`Shumate::Marker` subclasses) | no |

## Missing — transit directions

| Upstream file(s) | Port target | Kind | Exists |
|---|---|---|---|
| `data/ui/transit-options-panel.blp` + `src/transitOptionsPanel.js` | `lib/gnome_maps/transit_options_panel.rb` | panel | no |
| `data/ui/transit-itinerary-row.blp` + `src/transitItineraryRow.js` | `lib/gnome_maps/transit_itinerary_row.rb` | row | no |
| `data/ui/transit-leg-header.blp` + `src/transitLegHeader.js` | `lib/gnome_maps/transit_leg_header.rb` | widget | no |
| `data/ui/transit-leg-row.blp` + `src/transitLegRow.js` | `lib/gnome_maps/transit_leg_row.rb` | row | no |
| `data/ui/transit-juncture-row.blp` + `src/transitJunctureRow.js` | `lib/gnome_maps/transit_juncture_row.rb` | row | no |
| `data/ui/transit-stop-row.blp` + `src/transitStopRow.js` | `lib/gnome_maps/transit_stop_row.rb` | row | no |
| `data/ui/transit-arrival-destination-row.blp` + `src/transitArrivalDestinationRow.js` | `lib/gnome_maps/transit_arrival_destination_row.rb` | row | no |
| `src/transitRowTrackSegment.js`, `src/transitRouteLabel.js` | `lib/gnome_maps/transit_route_label.rb` | widget | no |
| `src/transit.js`, `src/transit/*.js` (arrival, departure, itinerary, juncture, leg, plan, route, routeType, stop, utils, constants, hvt), `src/transitous.js`, `src/motis.js` | `lib/gnome_maps/transit/*.rb` | model/backend client | no |
| `src/transitArrivalMarker.js`, `src/transitBoardMarker.js`, `src/transitWalkMarker.js`, `src/transitPathLayer.js` | `lib/gnome_maps/markers/transit_*.rb` | widget (markers/path overlay) | no |
| `src/transitPrintLayout.js` | `lib/gnome_maps/transit_print_layout.rb` | print layout | no |

## Missing — OSM editing

| Upstream file(s) | Port target | Kind | Exists |
|---|---|---|---|
| `data/ui/osm-edit-dialog.blp` + `src/osmEditDialog.js` | `lib/gnome_maps/osm_edit_dialog.rb` | dialog | no |
| `data/ui/osm-account-dialog.blp` + `src/osmAccountDialog.js` | `lib/gnome_maps/osm_account_dialog.rb` | dialog (sign-in) | no |
| `data/ui/osm-discard-dialog.blp` + `src/osmDiscardDialog.js` | `lib/gnome_maps/osm_discard_dialog.rb` | dialog (confirm discard) | no |
| `src/osmEdit.js`, `src/osmUtils.js` | `lib/gnome_maps/osm_edit.rb` | controller (changeset submit, duck-types the unported `lib/maps-osm*.c` GObjects) | no |

## Missing — import / export / sharing

| Upstream file(s) | Port target | Kind | Exists |
|---|---|---|---|
| `data/ui/export-view-dialog.blp` + `src/exportViewDialog.js` | `lib/gnome_maps/export_view_dialog.rb` | dialog (export visible map as image) | no |
| `data/ui/send-to-dialog.blp` + `src/sendToDialog.js` | `lib/gnome_maps/send_to_dialog.rb` | dialog (share place) | no |
| `data/ui/open-with-row.blp` | `lib/gnome_maps/open_with_row.rb` | row (used inside send-to dialog's app chooser) | no |
| `data/ui/auxillary-view.blp` + `src/auxillaryView.js` | `lib/gnome_maps/auxillary_view.rb` | widget (print-preview side panel) | no |
| `src/shapeLayer.js`, `src/geoJSONShapeLayer.js`, `src/gpxShapeLayer.js`, `src/kmlShapeLayer.js`, `src/geoJSONSource.js`, `src/fitShapeLayer.js` | `lib/gnome_maps/shape_layer.rb` + subclasses | model (imported layer, backs `ShapeLayerRow`, already ported) | no |
| `src/printOperation.js`, `src/printLayout.js`, `src/longPrintLayout.js`, `src/shortPrintLayout.js` | `lib/gnome_maps/print_*.rb` | controller/layout | no |
| `src/thumbnails.js` | `lib/gnome_maps/thumbnails.rb` | service | no |

## Missing — preferences

| Upstream file(s) | Port target | Kind | Exists |
|---|---|---|---|
| `data/ui/preferences.blp` + `src/preferences.js` | `lib/gnome_maps/preferences.rb` | dialog (`Adw.PreferencesDialog`) | no |
| `data/ui/preferences-downloads.blp` + `src/preferencesDownloads.js` | `lib/gnome_maps/preferences_downloads.rb` | page | no |
| `data/ui/preferences-download-row.blp` | `lib/gnome_maps/preferences_download_row.rb` | row | no |
| `data/ui/preferences-download-new.blp` + `src/preferencesDownloadNew.js` | `lib/gnome_maps/preferences_download_new.rb` | dialog/row (pick a new offline region) | no |
| `src/offlineDataSource.js`, `src/downloads.js` | `lib/gnome_maps/offline_data_source.rb` | model/service | no |

## Missing — app-level actions, menus, empty/error states

| Upstream source | Port target | Kind | Exists |
|---|---|---|---|
| Primary menu + `win.*`/`app.*` actions installed in `src/mainWindow.js` / `src/application.js` (preferences, shortcuts, about, quit, import file, etc.) | folded into `main_window.rb` / `application.rb` | actions | partial — `application.rb` only installs sign-in; the rest are not yet re-created |
| `GLib.Application` command-line handling (open URI / file args) in `src/application.js` | `application.rb` | actions | no |
| No-results state in `src/searchPopover.js`; no-route / geocode-failure states in `src/placeEntry.js`, `src/routeQuery.js` | respective widget files above | empty/error state | no |
| `src/mapWalker.js` "go to my location" (ties into `geoclue.js`) | `map_view.rb` (extend) | action/controller | partial — `application.rb` has a GWeather nearest-city lookup but no live Geoclue/location-portal binding yet |
| `src/geoclue.js` | `lib/gnome_maps/geoclue.rb` or folded into `application.rb` | service (should use `Ashpd`'s location portal, already required) | no |

## Supporting resources (not widgets, but required for parity)

| Upstream | Port target | Status |
|---|---|---|
| `data/org.gnome.Maps.gschema.xml` | `lib/gnome_maps/settings.rb` DEFAULTS | ported as a JSON-file substitute (see file header); key set should be diffed against the schema as more settings get used |
| `data/org.gnome.Maps.data.gresource.xml.in`, `src/org.gnome.Maps.src.gresource.xml.in`, `tests/org.gnome.Maps.test.gresource.xml.in` | n/a | GResource bundling has no Ruby-port equivalent; assets (icons, shields, style.css) need a plain asset-loading story once UI work starts consuming them |
| `data/style.css` | n/a yet | upstream's custom CSS classes (map markers, popovers, shields) aren't themed yet; needed once the corresponding widgets are ported |
| `data/icons/**`, `data/shields/**` | n/a yet | icon/shield assets referenced by `placeIcons.js`/`mapStyle/*` once those are ported |
| `po/*.po`, `po/LINGUAS`, `po/POTFILES.in` | — | translation catalogue; see `translation-parity` skill, out of scope for this pass |
| `data/org.gnome.Maps.metainfo.xml.in.in`, `data/org.gnome.Maps.desktop.in.in` | — | appstream/desktop metadata, not a widget; check against `exe/gnome-maps` and gemspec metadata separately |
| `lib/maps-osm*.c`, `lib/maps-shield.c`, `lib/maps-sprite-source.c`, `lib/maps-sync-map-source.c`, `lib/maps-download-store.c` | various `lib/gnome_maps/*.rb` above (osm_edit, shape_layer, markers) | upstream's own C helper library (GObjects used from JS); several already-ported files duck-type these (noted above) rather than porting them 1:1 — worth a decision once the owning component is ported for real |

## Mandatory binding-gem check (ashpd, geocode-glib, libgweather, librest, libshumate)

All five are wired correctly on `ruby` right now — no regression found:

| Gem | `require`d in | Called on a live path (not stubbed/rescued away) |
|---|---|---|
| `ashpd` (`Ashpd`) | `lib/gnome_maps/application.rb` | `Ashpd::OpenUri.open` (open URL in browser) and `Ashpd::Settings.color_scheme` |
| `libgweather` (`GWeather`) | `lib/gnome_maps/application.rb` | `GWeather::Location.world.find_nearest_city` |
| `librest` (`Rest`) | `lib/gnome_maps/osm_connection.rb` | `Rest::OAuth2Proxy.new` / `#build_authorization_url`, `Rest::PkceCodeChallenge.new` |
| `libshumate` (`Shumate`) | `lib/gnome_maps/map_view.rb` | `Shumate::SimpleMap`, `Shumate::MapSourceRegistry`, `Shumate::Viewport` |
| `geocode-glib` (`GeocodeGlib`) | `lib/gnome_maps/geocoder.rb` | `GeocodeGlib::Forward.new(...).search_async` |

The gemspec, `nix/Gemfile`, and the typelib wiring in `flake.nix` were not
touched — they already matched this. No hand-rolled stand-in for any of
these five namespaces was found elsewhere in `lib/`. The missing-component
tables above do note two places where the *next* component to land should
reach for an existing gem rather than hand-roll: the location lookup in
`mapWalker.js`/`geoclue.js` should use `Ashpd`'s location-portal API (already
a dependency via `application.rb`'s `require "ashpd"`), not a raw
`Gio::DBusProxy` to Geoclue.

## Totals

- Upstream `src/*.js` + `data/ui/*.blp` component-bearing files surveyed: 100 `.js` files, 33 `.blp` files.
- Ported to `lib/` today: 8 files (11 upstream units, see first table).
- Remaining user-facing components identified above: ~70, grouped into 9 areas
  (chrome, place details, directions, transit, OSM editing, import/export,
  preferences, app actions/menus, supporting resources).
