# frozen_string_literal: true

require "libshumate"

module GnomeMaps
  # The map widget. Upstream's src/mapView.js builds its MapView out of a
  # Shumate.Map wired to its own tile/marker/route layers; here the whole
  # thing is Shumate::SimpleMap, the libshumate GI binding's own batteries-
  # included widget, which already owns a Shumate::Viewport and a tile
  # layer for us.
  #
  # House style (see .claude/skills/ruby-gtk): a memoized widget method, its
  # styling in `tap`, no local variables for config.
  class MapView
    DEFAULT_ZOOM = 12

    def map
      @map ||= Shumate::SimpleMap.new.tap do |m|
        m.map_source = map_source
        m.show_zoom_buttons = true
      end
    end

    def viewport = map.viewport

    # Centers the view on a coordinate and sets the zoom, as upstream's
    # src/mapWalker.js MapWalker#goToLocation does via Shumate.Viewport's
    # own `latitude=`/`longitude=`/`zoom_level=`.
    def go_to(latitude, longitude, zoom: DEFAULT_ZOOM)
      viewport.tap do |v|
        v.latitude = latitude
        v.longitude = longitude
        v.zoom_level = zoom
      end
    end

    private

      # Upstream's src/mapSource.js registers several Shumate.MapSource
      # backends (vector tiles, raster, OSM); OSM's Mapnik raster source is
      # the one libshumate ships a ready-made id for, so it is the baseline
      # here rather than reimplementing the vector style pipeline.
      def map_source_registry
        @map_source_registry ||= Shumate::MapSourceRegistry.new.tap(&:populate_defaults)
      end

      def map_source
        @map_source ||= map_source_registry.get_by_id(Shumate::MAP_SOURCE_OSM_MAPNIK)
      end
  end
end
