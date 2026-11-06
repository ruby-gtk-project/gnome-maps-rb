# frozen_string_literal: true

require 'json'
require 'fileutils'

module GnomeMaps
  # Settings holds the same keys as upstream's org.gnome.Maps GSettings schema
  # (data/org.gnome.Maps.gschema.xml), ported from src/settings.js.
  #
  # Upstream uses GSettings, which needs a compiled schema installed into the
  # system's glib-2.0/schemas directory. Requiring an install step to run the
  # app from a checkout is worse than the alternative, so the same keys,
  # defaults and semantics are backed by a small JSON file under
  # XDG_CONFIG_HOME instead, as the gnome-contacts-rb pilot does.
  class Settings
    DEFAULTS = {
      'last-viewed-location'          => [0.0, 0.0],
      'zoom-level'                    => 0,
      'rotation'                      => 0.0,
      'map-type'                      => 'MapsVectorSource',
      'window-size'                   => [],
      'window-position'               => [],
      'window-maximized'              => true,
      'max-search-results'            => 20,
      'recent-places-limit'           => 50,
      'recent-routes-limit'           => 5,
      'osm-username-oauth2'           => '',
      'transportation-type'           => 'pedestrian',
      'show-scale'                    => true,
      'vector-tile-source-url-pattern' => 'https://tileserver.gnome.org/data/v3/{z}/{x}/{y}.pbf',
      'measurement-system'            => 'system',
      'show-location-marker'          => true,
    }.freeze

    # The enum keys' valid nicks, for callers that want to validate a value
    # before storing it (as a real GSettings enum key would reject the rest).
    TRANSPORTATION_TYPES = %w[car bike pedestrian transit].freeze
    MEASUREMENT_SYSTEMS = %w[system metric imperial].freeze

    def initialize(path: nil)
      @path = path || default_path
      @values = DEFAULTS.merge(read)
    end

    def [](key) = @values.fetch(key.to_s, DEFAULTS[key.to_s])

    def []=(key, value)
      @values[key.to_s] = value
      write
      value
    end

    def location = @path

    DEFAULTS.each_key do |key|
      method_name = key.tr('-', '_')
      define_method(method_name) { self[key] }
      define_method(:"#{method_name}=") { |value| self[key] = value }
      if DEFAULTS[key] == false || DEFAULTS[key] == true
        define_method(:"#{method_name}?") { self[key] == true }
      end
    end

    private

      def default_path
        File.join(
          ENV.fetch('XDG_CONFIG_HOME', File.expand_path('~/.config')),
          'ruby-gnome-maps',
          'settings.json',
        )
      end

      def read
        File.exist?(@path) ? JSON.parse(File.read(@path)) : {}
      rescue JSON::ParserError => e
        warn "Error parsing #{@path}: #{e.message}"
        {}
      end

      def write
        FileUtils.mkdir_p(File.dirname(@path))
        File.write(@path, JSON.pretty_generate(@values))
      end
  end
end
