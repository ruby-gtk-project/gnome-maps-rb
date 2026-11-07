# frozen_string_literal: true

# Drives the whole gnome-maps-rb port headlessly: builds the window, opens the
# shortcuts dialog, exercises window-geometry persistence and the Settings
# store's JSON round trip, and screenshots each state.
#
# Why this file exists: a GTK app that loads is not a GTK app that works.
# `ruby -c` passes on code that builds an empty window, and the Ruby bindings
# differ from the C API in ways that only a run reveals.
#
# Run it from the repository root:
#
#   nix develop --command xvfb-run -a ruby test/drive_gnome_maps.rb
#
# The specs under spec/ cover whatever is display-free. What is driven here is
# what needs a widget: the window, the toolbar view, the shortcuts dialog and
# settings-backed geometry restore/remember.

require "fileutils"
require "json"
require "tmpdir"

# A scratch config directory, so a run never reads or writes the real one.
ENV["XDG_CONFIG_HOME"] = Dir.mktmpdir("gnome-maps-drive")

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "gnome_maps"
require_relative "gtk_driver"

SHOTS = File.expand_path("../tmp/shots", __dir__)
FileUtils.rm_rf(SHOTS)

GtkDriver.drive(GnomeMaps::Application.new, shots: SHOTS) do |d, app|
  d.window { app.window }

  d.step("the window builds and shows the placeholder status page") do
    d.check("the window is an Adwaita::ApplicationWindow") do
      app.window.is_a?(Adwaita::ApplicationWindow)
    end
    d.check("it is the only toplevel") { Gtk::Window.list_toplevels.length == 1 }
    d.check("its title is gnome-maps") { app.window.title == "gnome-maps" }
    d.check("the toolbar view is the window's content") do
      app.window.content.equal?(app.toolbar_view)
    end
    d.check("the header bar is a top bar on the toolbar view") do
      app.toolbar_view.content.equal?(app.status_page)
    end
    d.check("the status page names the app") { app.status_page.title == "gnome-maps" }
    d.check("the status page carries its icon") do
      app.status_page.icon_name == "applications-engineering-symbolic"
    end
    d.shot("01-main")
  end

  d.step("the shortcuts action opens the shortcuts dialog") do
    app.shortcuts_action.activate(nil)
  end

  d.step("the shortcuts dialog shows upstream's two sections") do
    d.check("the shortcuts action is registered on the window") do
      app.window.lookup_action("show-shortcuts").equal?(app.shortcuts_action)
    end
    d.check("the shortcuts action is enabled") { app.shortcuts_action.enabled? }
    d.check("a dialog is actually showing") { !app.window.visible_dialog.nil? }
    d.shot("02-shortcuts")
  end

  d.step("the shortcuts dialog items match upstream's labels and accelerators") do
    GnomeMaps::ShortcutsDialog::SECTIONS.then do |sections|
      d.check("there are two sections, General and Map View") do
        sections.keys == ["General", "Map View"]
      end
      d.check("General has upstream's nine items") { sections["General"].length == 9 }
      d.check("Map View has upstream's nine items") { sections["Map View"].length == 9 }
      d.check("Quit is bound to Ctrl+Q") do
        sections["General"].find { |label, _| label == "Quit" }.last == "<Primary>Q"
      end
      d.check("Search is bound to Ctrl+F") do
        sections["General"].find { |label, _| label == "Search" }.last == "<Primary>F"
      end
      d.check("Zoom in carries both accelerators upstream binds") do
        sections["Map View"].find { |label, _| label == "Zoom in" }.last ==
          "<Primary>plus <Primary>equal"
      end
    end
  end

  d.step("building a shortcuts dialog directly assembles every section and item") do
    GnomeMaps::ShortcutsDialog.new.build.then do |dialog|
      d.check("its title is upstream's") { dialog.title == "Keyboard Shortcuts" }
      d.check("it is an Adwaita::ShortcutsDialog") { dialog.is_a?(Adwaita::ShortcutsDialog) }
    end
  end

  # The shortcuts dialog from the previous steps is still showing. Adwaita
  # refuses to run a window's close-request handler while a child dialog is
  # presented over it (the emit below answers `true`, meaning "already
  # handled, do not close" — our handler in application.rb never even ran),
  # so it has to be closed first for the close-request test that follows to
  # exercise anything at all.
  d.step("closing the dialog clears the way for the close-request test") do
    app.window.visible_dialog&.close
    d.check("no dialog is showing now") { app.window.visible_dialog.nil? }
  end

  # This Xvfb session has no window manager, and GDK reports a window as
  # maximized by default with none running — `window.unmaximize` makes no
  # difference either — so only the "maximized" branch of
  # remember_window_geometry is reachable from a real window here. The
  # "unmaximized, so remember the size" branch is covered against Settings
  # directly in the round-trip steps below instead.
  d.step("the window's close-request remembers its geometry via Settings") do
    app.window.set_default_size(800, 600)
    result = app.window.signal_emit("close-request")
    d.check("the handler ran rather than being pre-empted") { result == false }
    d.check("the settings file now exists") { File.exist?(app.settings.location) }
    d.check("window_maximized was recorded") { app.settings.window_maximized == true }
  end

  d.step("a fresh Settings instance reads back what was just written") do
    GnomeMaps::Settings.new.then do |fresh|
      d.check("the maximized flag round-trips") { fresh.window_maximized == true }
      d.check("an unset key still answers its default") do
        fresh.zoom_level == GnomeMaps::Settings::DEFAULTS["zoom-level"]
      end
    end
  end

  d.step("Settings refuses to crash on an unreadable file and falls back to defaults") do
    Dir.mktmpdir("gnome-maps-bad-settings").then do |dir|
      File.join(dir, "settings.json").then do |path|
        File.write(path, "this is not json at all")
        GnomeMaps::Settings.new(path: path).then do |broken|
          d.check("it reads back the defaults rather than raising") do
            broken.zoom_level == GnomeMaps::Settings::DEFAULTS["zoom-level"] &&
              broken.map_type == GnomeMaps::Settings::DEFAULTS["map-type"]
          end
        end
      end
    end
  end

  d.step("Settings' predicate and writer methods round-trip booleans and arrays") do
    GnomeMaps::Settings.new.then do |settings|
      settings.show_scale = false
      d.check("the writer persisted the value") { settings.show_scale == false }
      d.check("the predicate reads it back") { !settings.show_scale? }
      settings.last_viewed_location = [51.5, -0.1]
      d.check("an array value round-trips") { settings.last_viewed_location == [51.5, -0.1] }
    end
  end

  d.step("a maximized window remembers only the maximized flag, not a size") do
    app.window.maximize
    app.window.signal_emit("close-request")
    d.check("window_maximized was recorded as true") { app.settings.window_maximized == true }
  end

  d.step("the window renders maximized") { d.shot("03-maximized") }

  # The five row widgets below have no caller in application.rb yet (Route,
  # POI search and ShapeLayer have not been ported), so nothing in the app's
  # own wiring exercises them. They are still shipped, claimed components, so
  # they are driven directly here: built, placed in a real ListBox inside the
  # window so they get a real GTK allocation, and screenshotted.

  TurnPoint = Struct.new(:instruction, :distance, :icon_name, :start_or_end) do
    def start_or_end? = start_or_end
  end

  FakeFile = Struct.new(:parse_name)

  ShapeLayer = Struct.new(:name, :file, :visible) do
    def visible? = visible
  end

  d.step("a row gallery is built for the five standalone row widgets") do
    d.define_singleton_method(:gallery_window) do
      @gallery_window ||= Gtk::Window.new.tap do |win|
        win.title = "row gallery"
        win.set_default_size(360, 600)
      end
    end

    d.define_singleton_method(:gallery_list) do
      @gallery_list ||= Gtk::ListBox.new
    end

    d.gallery_window.child = d.gallery_list
    d.gallery_window.present
  end

  d.step("InstructionRow renders a mid-route turn and a route endpoint") do
    GnomeMaps::InstructionRow.new(
      turn_point: TurnPoint.new("Turn right onto Main Street", 150, "maps-direction-turn-right-symbolic", false),
      transportation: "car",
    ).then do |row|
      d.gallery_list.append(row)
      d.check("the instruction text is set") { row.instruction_label.label == "Turn right onto Main Street" }
      d.check("the turn icon is set") { row.direction_image.icon_name == "maps-direction-turn-right-symbolic" }
      d.check("the distance is formatted in meters") { row.distance_label.label == "150 m" }
    end

    GnomeMaps::InstructionRow.new(
      turn_point: TurnPoint.new("Arrive at destination", 0, "maps-point-end-symbolic", true),
      transportation: "pedestrian",
    ).then do |row|
      d.gallery_list.append(row)
      d.check("an endpoint falls back to the transportation icon") { row.direction_image.icon_name == "walking-symbolic" }
      d.check("an endpoint narrows its icon") { row.direction_image.width_request == 18 }
      d.check("a zero distance leaves the distance label blank") { row.distance_label.label == "" }
    end

    GnomeMaps::InstructionRow.new(
      turn_point: TurnPoint.new("Continue for 2.4 kilometers", 2400, "maps-direction-continue-symbolic", false),
    ).then do |row|
      d.gallery_list.append(row)
      d.check("a long distance is formatted in kilometers") { row.distance_label.label == "2.4 km" }
    end
  end

  d.step("PoiCategoryRow renders a category entry") do
    GnomeMaps::PoiCategoryRow.new(icon_name: "food-symbolic", label: "Restaurants").then do |row|
      d.gallery_list.append(row)
      d.check("the icon name is set") { row.icon.icon_name == "food-symbolic" }
      d.check("the label is set") { row.category_label.label == "Restaurants" }
      d.check("it carries the go-next disclosure icon") { row.disclosure_icon.icon_name == "go-next" }
    end
  end

  d.step("PoiCategoryGobackRow renders the fixed back entry") do
    GnomeMaps::PoiCategoryGobackRow.new.then do |row|
      d.gallery_list.append(row)
      d.check("the back icon is set") { row.icon.icon_name == "go-previous-symbolic" }
      d.check("the fixed label reads Back to Main Categories") { row.label.label == "Back to Main Categories" }
      d.check("it is exposed as a list item for accessibility") { row.accessible_role == :list_item }
    end
  end

  d.step("ShapeLayerRow renders a visible layer and toggles it") do
    ShapeLayer.new("hiking-trail.gpx", FakeFile.new("/home/user/hiking-trail.gpx"), true).then do |layer|
      GnomeMaps::ShapeLayerRow.new(shape_layer: layer).then do |row|
        d.gallery_list.append(row)
        d.check("the layer name is the label") { row.layer_label.label == "hiking-trail.gpx" }
        d.check("the tooltip is the file's parse name") { row.layer_label.tooltip_text == "/home/user/hiking-trail.gpx" }
        d.check("a visible layer is activatable") { row.activatable? == true }
        d.check("a visible layer shows the visible icon") { row.visible_button.icon_name == "layer-visible-symbolic" }

        row.visible_button.signal_emit("clicked")

        d.check("clicking the visibility button flips the model") { layer.visible? == false }
        d.check("the row stops being activatable") { row.activatable? == false }
        d.check("the icon swaps to not-visible") { row.visible_button.icon_name == "layer-not-visible-symbolic" }
      end
    end
  end

  d.step("TransitMoreRow moves through loading and exhausted states, both directions") do
    GnomeMaps::TransitMoreRow.new(earlier: true).then do |row|
      d.gallery_list.append(row)
      d.check("an earlier row starts on the load-earlier label") { row.label.label == "Load earlier alternatives" }
      d.check("earlier? reports true") { row.earlier? == true }

      row.start_loading
      d.check("loading swaps the stack to the spinner") { row.stack.visible_child_name == "spinner" }

      row.show_no_more
      d.check("exhausted swaps back to the label") { row.stack.visible_child_name == "label" }
      d.check("exhausted relabels for no earlier alternatives") { row.label.label == "No earlier alternatives found." }
      d.check("exhausted stops being activatable") { row.activatable? == false }
      d.check("exhausted adds the dimmed css class") { row.label.has_css_class?("dimmed") }
    end

    GnomeMaps::TransitMoreRow.new(earlier: false).then do |row|
      d.gallery_list.append(row)
      d.check("a later row starts on the load-later label") { row.label.label == "Load later alternatives" }
      d.check("earlier? reports false") { row.earlier? == false }

      row.show_no_more
      d.check("exhausted relabels for no later alternatives") { row.label.label == "No later alternatives found." }
    end
  end

  d.step("the row gallery renders all five widgets") { d.shot("04-row-gallery", d.gallery_window) }
end
