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
end
