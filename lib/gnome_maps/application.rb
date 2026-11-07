# frozen_string_literal: true

require "gtk4"
require "adwaita"
require "ashpd"
require "libgweather"

module GnomeMaps
  # The port's application: one window holding a Shumate map (MapView) under
  # a search bar, plus a sign-in action for editing OpenStreetMap data.
  #
  # House style (see .claude/skills/ruby-gtk): every widget is a memoized
  # method, all configuration lives in its `tap`, assembly happens only in
  # `build`, and the launcher is one expression.
  class Application
    def build
      app.tap do
        app.signal_connect("activate") do
          window.tap do |win|
            win.content = toolbar_view
            win.add_action(shortcuts_action)
            win.add_action(sign_in_action)
            win.add_action(preferences_action)
            win.add_action(zoom_in_action)
            win.add_action(zoom_out_action)
            win.add_action(reset_rotation_action)
            win.add_action(goto_user_location_action)
            win.add_action(show_scale_action)
            win.add_action(show_location_marker_action)
            win.signal_connect("close-request") do
              remember_window_geometry
              false
            end
          end

          toolbar_view.tap do |view|
            view.add_top_bar(header_bar)
            view.add_top_bar(search_bar)
            view.content = toast_overlay
          end

          header_bar.tap do |hb|
            hb.pack_start(search_toggle_button)
            hb.pack_end(sign_in_button)
            hb.pack_end(preferences_button)
          end

          map_overlay.tap do |overlay|
            overlay.child = map_view.map
            overlay.add_overlay(zoom_and_rotate_controls.build)
          end

          context_menu.attach

          search_bar.tap do |sb|
            sb.child = search_entry
            sb.connect_entry(search_entry)
          end

          search_toggle_button.tap do |btn|
            btn.signal_connect("toggled") do
              search_bar.search_mode = btn.active?
            end
          end

          search_entry.tap do |entry|
            entry.signal_connect("activate") do
              perform_search(entry.text)
            end
          end

          toast_overlay.tap do |to|
            to.child = map_overlay
          end

          apply_system_color_scheme
          restore_window_geometry
          window.present
        end
      end
    end

    # Adwaita::Application is broken in the Ruby bindings; the application
    # object comes from Gtk and only the window is Adwaita.
    def app = @app ||= Gtk::Application.new("org.rubygtkproject.GnomeMaps", :default_flags)

    def window
      @window ||= Adwaita::ApplicationWindow.new(app).tap do |win|
        win.title = "gnome-maps"
      end
    end

    def toolbar_view = @toolbar_view ||= Adwaita::ToolbarView.new
    def header_bar = @header_bar ||= Adwaita::HeaderBar.new
    def toast_overlay = @toast_overlay ||= Adwaita::ToastOverlay.new

    def search_bar = @search_bar ||= Gtk::SearchBar.new

    def search_entry
      @search_entry ||= Gtk::SearchEntry.new.tap do |entry|
        entry.placeholder_text = "Search for a place"
      end
    end

    def search_toggle_button
      @search_toggle_button ||= Gtk::ToggleButton.new.tap do |btn|
        btn.icon_name = "system-search-symbolic"
      end
    end

    def sign_in_button
      @sign_in_button ||= Gtk::Button.new.tap do |btn|
        btn.icon_name = "avatar-default-symbolic"
        btn.tooltip_text = "Sign in to OpenStreetMap"
        btn.action_name = "win.sign-in-osm"
      end
    end

    def preferences_button
      @preferences_button ||= Gtk::Button.new.tap do |btn|
        btn.icon_name = "settings-symbolic"
        btn.tooltip_text = "Preferences"
        btn.action_name = "win.show-preferences"
      end
    end

    # The map widget (MapView, backed by libshumate), as upstream's
    # src/mapView.js is the heart of mainWindow.js's content.
    def map_view = @map_view ||= MapView.new

    # Hosts the map plus the floating zoom/rotate control cluster, as
    # upstream's mainWindow.blp overlays zoomAndRotateControls on the map
    # inside the same Gtk.Overlay the place/route bubbles also live in.
    def map_overlay = @map_overlay ||= Gtk::Overlay.new

    def zoom_and_rotate_controls = @zoom_and_rotate_controls ||= ZoomAndRotateControls.new(map_view: map_view)

    def context_menu = @context_menu ||= ContextMenu.new(widget: map_view.map)

    def geocoder = @geocoder ||= Geocoder.new
    def osm_connection = @osm_connection ||= OsmConnection.new

    def settings = @settings ||= Settings.new

    def shortcuts_action
      @shortcuts_action ||= Gio::SimpleAction.new("show-shortcuts").tap do |action|
        action.signal_connect("activate") do
          ShortcutsDialog.new.build.present(window)
        end
      end
    end

    def sign_in_action
      @sign_in_action ||= Gio::SimpleAction.new("sign-in-osm").tap do |action|
        action.signal_connect("activate") do
          open_osm_sign_in
        end
      end
    end

    def preferences_action
      @preferences_action ||= Gio::SimpleAction.new("show-preferences").tap do |action|
        action.signal_connect("activate") do
          Preferences.new(settings: settings).build.present(window)
        end
      end
    end

    def zoom_in_action
      @zoom_in_action ||= Gio::SimpleAction.new("zoom-in").tap do |action|
        action.signal_connect("activate") { map_view.zoom_in }
      end
    end

    def zoom_out_action
      @zoom_out_action ||= Gio::SimpleAction.new("zoom-out").tap do |action|
        action.signal_connect("activate") { map_view.zoom_out }
      end
    end

    def reset_rotation_action
      @reset_rotation_action ||= Gio::SimpleAction.new("reset-rotation").tap do |action|
        action.signal_connect("activate") { map_view.reset_rotation }
      end
    end

    # Disabled: "go to current location" needs the Geoclue/location-portal
    # service (upstream's src/geoclue.js), which this round does not port —
    # ashpd 0.1.1, the version this port's gemspec pins, has no Location
    # portal binding yet (only Account/Camera/OpenUri/Screenshot/Settings/
    # Trash), so there is no gem call to back this action with yet.
    def goto_user_location_action
      @goto_user_location_action ||= Gio::SimpleAction.new("goto-user-location").tap do |action|
        action.enabled = false
      end
    end

    # Stateful boolean actions backing Preferences' two SwitchRows, keeping
    # the GAction's own state and Settings in sync in both directions, as
    # upstream's own `setting:`-driven action entries do against GSettings.
    def show_scale_action
      @show_scale_action ||= Gio::SimpleAction.new("show-scale", nil, GLib::Variant.new(settings.show_scale?)).tap do |action|
        action.signal_connect("notify::state") { settings.show_scale = action.state }
      end
    end

    def show_location_marker_action
      @show_location_marker_action ||=
        Gio::SimpleAction.new("show-location-marker", nil, GLib::Variant.new(settings.show_location_marker?)).tap do |action|
          action.signal_connect("notify::state") { settings.show_location_marker = action.state }
        end
    end

    private

      # Forward-geocodes the search text via GeocodeGlib::Forward (Geocoder)
      # and recenters the map on the first result, as upstream's
      # src/mapView.js does via its own search machinery and
      # src/mapWalker.js's goToLocation. GeocodeGlib does a real HTTP call,
      # so a sandbox with no network (or no TLS, as this dev shell's) takes
      # the error branch below rather than the success one — both are real
      # outcomes of the same call, not a stub.
      def perform_search(query)
        query.strip.empty?.then do |empty|
          if empty
            nil
          else
            geocoder.search(query) do |location, error|
              if location
                map_view.go_to(location.latitude, location.longitude)
                toast_overlay.add_toast(Adwaita::Toast.new(search_result_message(location)))
              else
                toast_overlay.add_toast(Adwaita::Toast.new("Could not find “#{query}”: #{error&.message}"))
              end
            end
          end
        end
      end

      # Upstream's src/sendToDialog.js and src/utils.js both resolve a
      # coordinate to a human place name via GWeather.Location.get_world /
      # find_nearest_city; this does the same through the libgweather GI
      # binding to label the location the search just found.
      def search_result_message(location)
        GWeather::Location.world.find_nearest_city(location.latitude, location.longitude).name.then do |city|
          "Found near #{city}"
        end
      rescue => e
        "Location found (#{e.message})"
      end

      # Opens the OpenStreetMap OAuth2 sign-in URL (OsmConnection) through
      # the XDG desktop portal's OpenUri call, as upstream's own Xdp-based
      # portal use (src/placeView.js) opens URIs under sandbox confinement.
      # Ashpd::OpenUri reaches real D-Bus; without a running
      # xdg-desktop-portal (true of this dev shell's headless sandbox) it
      # raises
      #   RuntimeError: Portal request failed: org.freedesktop.zbus.Error: The name is not activatable
      # which is caught here and surfaced as a toast with the URL rather
      # than silently discarded.
      def open_osm_sign_in
        url, _state = osm_connection.authorization_url
        begin
          Ashpd::OpenUri.open(url, false, false)
        rescue => e
          # Adwaita::Toast renders its text as Pango markup, so the URL's
          # own "&"s must be escaped or GTK warns and drops the text.
          escaped_url = url.gsub("&", "&amp;")
          toast_overlay.add_toast(Adwaita::Toast.new("Open to sign in: #{escaped_url} (#{e.message})"))
        end
      end

      # Reads the desktop's light/dark preference through the XDG desktop
      # portal's Settings.color_scheme call and applies it via Adwaita's
      # StyleManager, as upstream (GTK4/libadwaita itself) follows the same
      # org.freedesktop.portal.Settings color-scheme signal. Same portal
      # availability caveat as open_osm_sign_in: without a running portal
      # this raises and Adwaita's own DEFAULT (follow the desktop) scheme is
      # kept, which is already the correct fallback.
      def apply_system_color_scheme
        Ashpd::Settings.color_scheme.then do |scheme|
          Adwaita::StyleManager.default.color_scheme =
            if scheme == 1
              Adwaita::ColorScheme::FORCE_DARK
            else
              Adwaita::ColorScheme::DEFAULT
            end
        end
      rescue => e
        warn "color-scheme portal unavailable, keeping the default scheme: #{e.message}"
      end

      # Restores the window size and maximized state the previous run saved,
      # as src/settings.js backs upstream's window-size/-maximized keys.
      def restore_window_geometry
        size = settings.window_size
        (size.is_a?(Array) && size.length == 2).then do |has_saved_size|
          if has_saved_size
            window.set_default_size(*size)
          end
        end
        settings.window_maximized?.then do |maximized|
          if maximized
            window.maximize
          end
        end
      end

      def remember_window_geometry
        settings.window_maximized = window.maximized?
        window.maximized?.then do |maximized|
          if maximized
            nil
          else
            settings.window_size = [window.default_width, window.default_height]
          end
        end
      end
  end
end
