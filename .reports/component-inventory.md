# gnome-maps-rb — upstream component inventory

Survey step for the full-parity port. Upstream is GNOME Maps on `origin/main`
(GJS + blueprint, GTK4/Libadwaita/libshumate). The port is the `ruby` branch.

Read with `git show origin/main:<path>`. Nothing upstream is checked out or merged.

- Upstream UI source: 130 `src/*.js` files (excluding vendored `geojson-vt/`,
  `xmldom/`, `togeojson/`, and the 16-file `src/mapStyle/` map-style data set),
  38 `data/ui/*.blp` blueprints, 1 GSettings schema (16 keys), 2 GResource
  manifests, `data/style.css`, `data/osm-types.json`, a 10-file C helper
  library in `lib/maps-*.c`.
- Port `lib/` today: `lib/gnome_maps.rb`, `lib/gnome_maps/application.rb`
  (a scaffold whose window holds a single "not written yet" status page), and
  `lib/gnome/maps/rb/version.rb`.
- **Every user-facing component below is absent from the port.** Parity work
  starts from zero; the scaffold's window and header bar are placeholders, not
  ports of `main-window.blp`.

## Component → port file map

A blueprint and its GJS class are one component: the `.blp` holds the tree,
the CSS classes and the signal handler names; the `.js` holds the callbacks and
the runtime-built widgets. Both halves land in the single `lib/*.rb` file.

### Window, layout and chrome

| Upstream | Port file | Kind | Present |
|---|---|---|---|
| `src/application.js` | `lib/application.rb` | application (actions `app.osm-account-setup`, `app.search`, `app.quit`; `HANDLES_OPEN`/`HANDLES_COMMAND_LINE`; `--version`, `--search`, `[FILE…\|URI]`) | no (scaffold only) |
| `src/main.js` | `lib/main.rb` | entry point | no |
| `src/mainWindow.js` + `data/ui/main-window.blp` | `lib/main_window.rb` | window (`Adw.ApplicationWindow`, `Adw.Breakpoint` max-width:700sp, `Adw.MultiLayoutView` wide/narrow, `Adw.OverlaySplitView`, `Adw.BottomSheet`, `Adw.ToastOverlay`, `Adw.HeaderBar`, `ActionBar`, `Revealer` + `Shumate.License`, back/print-route/close-sidebar buttons, `Gtk.DropTarget` for shape-layer drops, 19 `win.*` actions) | no |
| `data/ui/main-window.blp` → `hamburgerMenu` | `lib/main_window.rb` | menu (OSM account setup, Export as Image, Preferences, Keyboard Shortcuts, About Maps) | no |
| `src/headerBar.js` + `data/ui/headerbar-left.blp`, `data/ui/headerbar-right.blp` | `lib/header_bar.rb` | header-bar halves (`HeaderBarLeft`, `HeaderBarRight`, both `Gtk.Box`; duplicated into the narrow-mode `ActionBar`) | no |
| `src/auxillaryView.js` + `data/ui/auxillary-view.blp` | `lib/auxillary_view.rb` | sidebar/bottom-sheet host (`Gtk.Grid` + stack: `routeView`, `placeView`, POI browser) | no |
| `src/zoomAndRotateControls.js` + `data/ui/zoom-and-rotate-controls.blp` | `lib/zoom_and_rotate_controls.rb` | map overlay controls (zoom in/out, rotate, compass) | no |
| `data/ui/shortcuts-dialog.blp` | `lib/shortcuts_dialog.rb` | keyboard shortcuts (`Adw.ShortcutsDialog`, 2 sections, 18 items) | no |
| `data/ui/context-menu.blp` | `lib/context_menu.rb` | map context menu (`view.route-from-here`, `add-intermediate-destination`, `route-to-here`, `clear-route`, `copy-location`, `add-osm-location`) | no |
| `src/layersPopover.js` + `data/ui/layers-popover.blp` | `lib/layers_popover.rb` | popover menu (`Gtk.PopoverMenu`, layers `ListBox`, Open Shape Layer…) | no |
| `src/layersPopover.js` + `data/ui/shape-layer-row.blp` | `lib/shape_layer_row.rb` | row (`Gtk.ListBoxRow`, visibility toggle, remove) | no |

### Map view and markers

| Upstream | Port file | Kind | Present |
|---|---|---|---|
| `src/mapView.js` | `lib/map_view.rb` | view (`Gtk.Overlay` over `Shumate.SimpleMap`; the `view.*` context actions, long-press gesture, shape-layer loading, go-to-geo-URI/HTTP-URL) | no |
| `src/mapSource.js` | `lib/map_source.rb` | support (vector/aerial tile sources, sprite source) | no |
| `src/mapWalker.js` | `lib/map_walker.rb` | support (animated go-to) | no |
| `src/mapMarker.js` | `lib/map_marker.rb` | marker base (`Shumate.Marker`) | no |
| `src/iconMarker.js` | `lib/icon_marker.rb` | marker | no |
| `src/circleIconMarker.js` | `lib/circle_icon_marker.rb` | marker | no |
| `src/placeMarker.js` | `lib/place_marker.rb` | marker | no |
| `src/turnPointMarker.js` | `lib/turn_point_marker.rb` | marker | no |
| `src/userLocationMarker.js` | `lib/user_location_marker.rb` | marker (`UserLocationMarker` + `AccuracyCircleMarker`) | no |
| `src/transitArrivalMarker.js` | `lib/transit_arrival_marker.rb` | marker | no |
| `src/transitBoardMarker.js` | `lib/transit_board_marker.rb` | marker | no |
| `src/transitWalkMarker.js` | `lib/transit_walk_marker.rb` | marker | no |
| `src/transitPathLayer.js` | `lib/transit_path_layer.rb` | map layer (`Shumate.PathLayer`) | no |
| `src/shapeLayer.js` | `lib/shape_layer.rb` | map layer base | no |
| `src/fitShapeLayer.js` | `lib/fit_shape_layer.rb` | map layer | no |
| `src/geoJSONShapeLayer.js` | `lib/geo_json_shape_layer.rb` | map layer | no |
| `src/gpxShapeLayer.js` | `lib/gpx_shape_layer.rb` | map layer | no |
| `src/kmlShapeLayer.js` | `lib/kml_shape_layer.rb` | map layer | no |
| `src/geoJSONSource.js` | `lib/geo_json_source.rb` | map source | no |
| `src/geoJSONStyle.js` | `lib/geo_json_style.rb` | support | no |
| `src/offlineDataSource.js` | `lib/offline_data_source.rb` | map source (`Shumate.DataSource`) | no |

### Search and places

| Upstream | Port file | Kind | Present |
|---|---|---|---|
| `src/searchBar.js` | `lib/search_bar.rb` | search entry (subclasses `PlaceEntry`, header-bar title widget; `win.find` ⌃F) | no |
| `src/placeEntry.js` | `lib/place_entry.rb` | entry (`Gtk.Entry` with place completion) | no |
| `src/searchPopover.js` | `lib/search_popover.rb` | popover base | no |
| `src/placePopover.js` + `data/ui/place-popover.blp` | `lib/place_popover.rb` | results popover (incl. no-results and error states) | no |
| `src/placeListRow.js` + `data/ui/place-list-row.blp` | `lib/place_list_row.rb` | row | no |
| `src/favoriteListRow.js` + `data/ui/favorite-list-row.blp` | `lib/favorite_list_row.rb` | row (subclasses `PlaceListRow`) | no |
| `src/favoritesPopover.js` + `data/ui/favorites-popover.blp` | `lib/favorites_popover.rb` | popover (`Gtk.Popover`, favourites list, empty state) | no |
| `src/placeView.js` + `data/ui/place-view.blp` | `lib/place_view.rb` | detail page (`Gtk.Box`: title, thumbnail, opening hours, contact rows, Wikipedia extract, OSM edit entry point) | no |
| `src/placeViewImage.js` | `lib/place_view_image.rb` | widget (`Gtk.Widget`, custom-drawn cropped thumbnail) | no |
| `src/placeButtons.js` + `data/ui/place-buttons.blp` | `lib/place_buttons.rb` | button row (route-to, favourite toggle, send-to, edit on OSM) | no |
| `src/place.js` | `lib/place.rb` | model (`GObject.Object`) | no |
| `src/placeStore.js` | `lib/place_store.rb` | model (`PlaceStore`, `PlaceStoreItem`; recents + favourites persistence) | no |
| `src/placeFormatter.js` | `lib/place_formatter.rb` | support (user-visible title/detail strings) | no |
| `src/placeIcons.js` | `lib/place_icons.rb` | support (POI → icon name) | no |
| `src/placeZoom.js` | `lib/place_zoom.rb` | support | no |
| `src/storedRoute.js` | `lib/stored_route.rb` | model | no |
| `src/thumbnails.js` | `lib/thumbnails.rb` | support | no |
| `src/wikipedia.js` | `lib/wikipedia.rb` | support (article/logo fetch for the place view) | no |
| `src/transitPlace.js` | `lib/transit_place.rb` | model | no |

### POI browser

| Upstream | Port file | Kind | Present |
|---|---|---|---|
| `src/poiCategories.js` | `lib/poi_categories.rb` | model + translated category names (`win.browse` ⇧⌃F) | no |
| `src/poiCategoryRow.js` + `data/ui/poi-category-row.blp` | `lib/poi_category_row.rb` | row | no |
| `src/poiCategoryGobackRow.js` + `data/ui/poi-category-goback-row.blp` | `lib/poi_category_goback_row.rb` | row | no |

### Routing

| Upstream | Port file | Kind | Present |
|---|---|---|---|
| `src/routeView.js` + `data/ui/route-view.blp` | `lib/route_view.rb` | page (`Gtk.Box`; mode switcher, itinerary list, transit disclaimer popover, transit itinerary header, error/empty states) | no |
| `src/routeEntry.js` + `data/ui/route-entry.blp` | `lib/route_entry.rb` | row (`Gtk.Grid`; start/via/end entry with add/remove/reorder, DnD) | no |
| `src/instructionRow.js` + `data/ui/instruction-row.blp` | `lib/instruction_row.rb` | row | no |
| `src/routeQuery.js` | `lib/route_query.rb` | model (`RouteQuery`, `QueryPoint`) | no |
| `src/route.js` | `lib/route.rb` | model (`Route`, `TurnPoint`) | no |
| `src/routingDelegator.js` | `lib/routing_delegator.rb` | support | no |
| `src/graphHopper.js` | `lib/graph_hopper.rb` | service (user-visible routing error strings) | no |
| `src/graphHopperGeocode.js` | `lib/graph_hopper_geocode.rb` | service | no |
| `src/photonGeocode.js` | `lib/photon_geocode.rb` | service | no |
| `src/photonUtils.js` | `lib/photon_utils.rb` | support | no |
| `src/geocode.js` | `lib/geocode.rb` | service factory | no |
| `src/overpass.js` | `lib/overpass.rb` | service | no |
| `src/geoclue.js` | `lib/geoclue.rb` | service (location permission / "location services disabled" state) | no |
| `src/location.js` | `lib/location.rb` | model | no |

### Transit

| Upstream | Port file | Kind | Present |
|---|---|---|---|
| `src/transitOptionsPanel.js` + `data/ui/transit-options-panel.blp` | `lib/transit_options_panel.rb` | panel (`Gtk.Grid`; time/date popovers, transit-mode toggles) | no |
| `src/transitOptions.js` | `lib/transit_options.rb` | model | no |
| `src/transitItineraryRow.js` + `data/ui/transit-itinerary-row.blp` | `lib/transit_itinerary_row.rb` | row | no |
| `src/transitLegRow.js` + `data/ui/transit-leg-row.blp` | `lib/transit_leg_row.rb` | row | no |
| `src/transitLegHeader.js` + `data/ui/transit-leg-header.blp` | `lib/transit_leg_header.rb` | header widget | no |
| `src/transitJunctureRow.js` + `data/ui/transit-juncture-row.blp` | `lib/transit_juncture_row.rb` | row | no |
| `src/transitStopRow.js` + `data/ui/transit-stop-row.blp` | `lib/transit_stop_row.rb` | row | no |
| `src/transitArrivalDestinationRow.js` + `data/ui/transit-arrival-destination-row.blp` | `lib/transit_arrival_destination_row.rb` | row | no |
| `src/transitMoreRow.js` + `data/ui/transit-more-row.blp` | `lib/transit_more_row.rb` | row ("Load later/earlier alternatives") | no |
| `src/transitRouteLabel.js` | `lib/transit_route_label.rb` | widget (coloured line badge) | no |
| `src/transitRowTrackSegment.js` | `lib/transit_row_track_segment.rb` | widget (custom-drawn) | no |
| `src/transit.js`, `src/transit/utils.js` | `lib/transit/utils.rb` | support (translated from/to/headsign/arrival/departure labels) | no |
| `src/transit/itinerary.js` | `lib/transit/itinerary.rb` | model (translated duration strings) | no |
| `src/transit/leg.js` | `lib/transit/leg.rb` | model (translated strings) | no |
| `src/transit/plan.js` | `lib/transit/plan.rb` | model (translated no-route/error strings) | no |
| `src/transit/juncture.js`, `arrival.js`, `departure.js`, `stop.js`, `route.js`, `routeType.js`, `hvt.js`, `constants.js` | `lib/transit/*.rb` (8 files) | models/support | no |
| `src/motis.js` | `lib/motis.rb` | transit provider (user-visible error strings) | no |
| `src/transitous.js` | `lib/transitous.rb` | transit provider | no |

### OpenStreetMap editing

| Upstream | Port file | Kind | Present |
|---|---|---|---|
| `src/osmEditDialog.js` + `data/ui/osm-edit-dialog.blp` | `lib/osm_edit_dialog.rb` | dialog (`Adw.Dialog`; tag editor rows, type search, comment, upload, error state) | no |
| `src/osmAccountDialog.js` + `data/ui/osm-account-dialog.blp` | `lib/osm_account_dialog.rb` | dialog (`Adw.Dialog`; OAuth2 sign-in, signed-in and error states) | no |
| `src/osmDiscardDialog.js` + `data/ui/osm-discard-dialog.blp` | `lib/osm_discard_dialog.rb` | alert dialog (`Adw.AlertDialog`) | no |
| `src/osmEdit.js` | `lib/osm_edit.rb` | support | no |
| `src/osmConnection.js` | `lib/osm_connection.rb` | service (translated upload errors) | no |
| `src/osmOAuthProxyCall.js` | `lib/osm_oauth_proxy_call.rb` | service | no |
| `src/osmTypes.js` + `data/osm-types.json` | `lib/osm_types.rb` | model + translated type titles | no |
| `src/osmUtils.js` | `lib/osm_utils.rb` | support | no |
| `src/osmNames.js` | `lib/osm_names.rb` | support (localised name selection) | no |

### Preferences, downloads, export, sharing, printing

| Upstream | Port file | Kind | Present |
|---|---|---|---|
| `src/preferences.js` + `data/ui/preferences.blp` | `lib/preferences_dialog.rb` | preferences (`Adw.PreferencesDialog`; `win.show-preferences` ⌃,) | no |
| `src/preferencesDownloads.js` + `data/ui/preferences-downloads.blp` | `lib/preferences_downloads.rb` | preferences page (`Adw.PreferencesPage`, offline-area list, empty state) | no |
| `src/preferencesDownloadNew.js` + `data/ui/preferences-download-new.blp` | `lib/preferences_download_new.rb` | nav page (`Adw.NavigationPage`) + `AreaSelectOverlay`, `AreaSelectDragHandle` custom widgets | no |
| `data/ui/preferences-download-row.blp` | `lib/preferences_download_row.rb` | row (`Adw.ExpanderRow`) | no |
| `src/downloads.js` | `lib/downloads.rb` | model (`DownloadManager`, `DownloadArea`; progress and failure strings) | no |
| `src/pmtiles.js` | `lib/pmtiles.rb` | support | no |
| `src/exportViewDialog.js` + `data/ui/export-view-dialog.blp` | `lib/export_view_dialog.rb` | dialog (`Adw.Dialog`; `win.export-as-image`, file chooser, error state) | no |
| `src/sendToDialog.js` + `data/ui/send-to-dialog.blp` | `lib/send_to_dialog.rb` | dialog (`Adw.Dialog`) | no |
| `src/sendToDialog.js` + `data/ui/open-with-row.blp` | `lib/open_with_row.rb` | row (`Gtk.ListBoxRow`) | no |
| `src/printOperation.js` | `lib/print_operation.rb` | print operation (`win.print-route` ⌃P) | no |
| `src/printLayout.js` | `lib/print_layout.rb` | print layout base | no |
| `src/shortPrintLayout.js` | `lib/short_print_layout.rb` | print layout | no |
| `src/longPrintLayout.js` | `lib/long_print_layout.rb` | print layout | no |
| `src/transitPrintLayout.js` | `lib/transit_print_layout.rb` | print layout | no |

### Cross-cutting support

| Upstream | Port file | Kind | Present |
|---|---|---|---|
| `src/settings.js` + `data/org.gnome.Maps.gschema.xml` | `lib/settings.rb` | settings (16 keys: last-viewed-location, zoom-level, rotation, map-type, window-size/position/maximized, max-search-results, recent-places-limit, recent-routes-limit, osm-username-oauth2, transportation-type, show-scale, vector-tile-source-url-pattern, measurement-system, show-location-marker) | no |
| `src/utils.js` | `lib/utils.rb` | support (`addActions`, accels, toast helper, pretty time/distance/population, imperial vs metric) | no |
| `src/translations.js` | `lib/translations.rb` | support (opening hours, religion — heavily translated) | no |
| `src/time.js` | `lib/time.rb` | support | no |
| `src/address.js` | `lib/address.rb` | support (per-country address formats) | no |
| `src/color.js` | `lib/color.rb` | support (contrast for transit badges) | no |
| `src/gfx.js` | `lib/gfx.rb` | support (badge and highway-shield drawing) | no |
| `src/uris.js` | `lib/uris.rb` | support (geo:, maps:, OSM URL parsing) | no |
| `src/http.js` | `lib/http.rb` | support | no |
| `src/jsonStorage.js` | `lib/json_storage.rb` | support | no |
| `src/boundingBox.js` | `lib/bounding_box.rb` | support | no |
| `src/epaf.js` | `lib/epaf.rb` | support (encoded polyline) | no |
| `src/constants.js` | `lib/constants.rb` | support | no |
| `src/prototypes.js` | — | not ported (JS monkey-patches) | n/a |
| `data/style.css` | `lib/styles.rb` (inline `Gtk::CssProvider`) | styling | no |
| `data/org.gnome.Maps.data.gresource.xml.in`, `src/...src.gresource.xml.in` | — | not ported (no GResource; widgets built in Ruby, assets loaded from disk) | n/a |
| `data/icons/private/**` (≈190 symbolic SVGs), `data/icons/stations/**` (33), `data/shields/**` | ship as port data, icon search path added at startup | assets | no |
| `po/` (73 locales, `POTFILES.in` lists 32 blueprints + 40 JS files + 3 data files) | `po/` + gettext in the port | translations | no |

### Upstream code with no Ruby-side counterpart yet

| Upstream | Notes |
|---|---|
| `lib/maps-sync-map-source.c/.h`, `lib/maps-sprite-source.c/.h`, `lib/maps-shield.c/.h`, `lib/maps-download-store.c/.h`, `lib/maps-osm*.c/.h` (10 pairs) | A C library exposed to GJS as the `GnomeMaps` typelib. `GeoJSONSource` extends `GnomeMaps.SyncMapSource`; the OSM XML parser/serialiser and the shield renderer live here. Ruby has no binding, so each has to be reimplemented in Ruby or the C library built and introspected. |
| `src/mapStyle/*.js` (16 files) | The vector map style as JS data structures handed to libshumate. Large, data-only, user-visible as the map itself. |
| `src/geojson-vt/`, `src/xmldom/`, `src/togeojson/` | Vendored third-party JS; replace with Ruby equivalents rather than port. |
| `tests/*.js` (14 suites) | Upstream unit tests for address, boundingBox, color, downloads, epaf, osmNames, placeIcons, placeStore, placeZoom, time, translations, uris, utils, wikipedia — the targets for the port's own specs. |

## Blockers

1. **No `Shumate` typelib in the dev shell.** `GI_TYPELIB_PATH` holds Gtk-4.0,
   Adw-1, Gdk, Gsk, Pango, Rsvg and the GLib stack, and nothing else. Verified:
   `Repository.default.require("Shumate", nil)` raises
   `GObjectIntrospection::RepositoryError::TypelibNotFound`. libshumate is the
   map widget, the marker layers, the tile sources and the license widget — the
   centre of the app. `flake.nix` must add libshumate (and a Ruby loader for it)
   before `lib/map_view.rb` and every marker and layer file can exist.
2. **No `GeocodeGlib` typelib** either, so `Location` (which upstream extends
   from `Geocode.Location`) and the geocoder plumbing have no base class.
3. **No `Rest`/`Soup` typelib**, so OSM OAuth2 (`osmOAuthProxyCall.js` extends
   `Rest.OAuth`) and every HTTP service need a Ruby HTTP stack instead.
4. **The `GnomeMaps` C helper library has no Ruby binding.** Map source base
   class, sprite source, highway shields, offline download store and the whole
   OSM XML layer are C. Decide per file: reimplement in Ruby, or build and
   introspect the C library from the flake.
5. **Blueprint is not available to the port by design.** All 38 `.blp` trees
   must be rewritten as memoized Ruby widget methods, which means the CSS
   classes and `signal => $handler` bindings in them are the spec, not an import.
6. **`Adwaita::Application` is broken in the Ruby bindings** (noted in the
   scaffold), yet upstream's `Application` extends `Adw.Application` and relies
   on `HANDLES_OPEN`/`HANDLES_COMMAND_LINE` plus `vfunc_open`,
   `vfunc_command_line`, `vfunc_dbus_register` and `vfunc_shutdown`. The port
   must get the same behaviour from `Gtk::Application`.
7. **No `Adw.ShortcutsDialog`, `Adw.MultiLayoutView`, `Adw.BottomSheet`,
   `Adw.LayoutSlot` or `Adw.Breakpoint` usage exists in the pilot port**, so the
   main window's adaptive layout is unproven in Ruby and needs a spike before
   `lib/main_window.rb` is written.
8. **Printing**: upstream uses `Gtk.PrintOperation` with four hand-built
   layouts; the Ruby binding surface for print operations is untested here.
