# frozen_string_literal: true

require "gtk4"
require "adwaita"

module GnomeMaps
  # The app's preferences window.
  #
  # Ported from upstream's data/ui/preferences.blp and src/preferences.js: a
  # single "General" page with a "Map View" group (two switches, wired by
  # upstream through the window's own `show-scale`/`show-location-marker`
  # actions rather than Settings directly) and a "Measurements" group whose
  # ComboRow reads and writes Settings#measurement_system.
  #
  # Upstream's second page (src/preferencesDownloads.js, offline map
  # downloads) is not part of this round and is left off rather than shown
  # empty.
  class Preferences < Adwaita::PreferencesDialog
    MEASUREMENT_SYSTEMS = %w[system metric imperial].freeze

    def initialize(settings:)
      super()
      @settings = settings
      self.search_enabled = false
      self.content_width = 640
      self.content_height = 480
    end

    attr_reader :settings

    def build
      tap do |dialog|
        dialog.add(general_page)

        measurement_row.selected = MEASUREMENT_SYSTEMS.index(settings.measurement_system) || 0
        measurement_row.signal_connect("notify::selected") do
          settings.measurement_system = MEASUREMENT_SYSTEMS[measurement_row.selected]
        end
      end
    end

    def general_page
      @general_page ||= Adwaita::PreferencesPage.new.tap do |page|
        page.icon_name = "settings-symbolic"
        page.title = "General"
        page.add(map_view_group)
        page.add(measurements_group)
      end
    end

    def map_view_group
      @map_view_group ||= Adwaita::PreferencesGroup.new.tap do |group|
        group.title = "Map View"
        group.add(show_scale_row)
        group.add(show_location_marker_row)
      end
    end

    def show_scale_row
      @show_scale_row ||= Adwaita::SwitchRow.new.tap do |row|
        row.title = "Show Scale"
        row.action_name = "win.show-scale"
      end
    end

    def show_location_marker_row
      @show_location_marker_row ||= Adwaita::SwitchRow.new.tap do |row|
        row.title = "Show Location Marker"
        row.action_name = "win.show-location-marker"
      end
    end

    def measurements_group
      @measurements_group ||= Adwaita::PreferencesGroup.new.tap do |group|
        group.title = "Measurements"
        group.add(measurement_row)
      end
    end

    def measurement_row
      @measurement_row ||= Adwaita::ComboRow.new.tap do |row|
        row.title = "Measurement system"
        row.model = Gtk::StringList.new(["System Default", "Metric", "Imperial"])
      end
    end
  end
end
