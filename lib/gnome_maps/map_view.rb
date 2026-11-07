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

    # Zooms in one step, as upstream's own zoomIn: if the current zoom is
    # close to the next even level, skip to the one after that so a tap
    # doesn't just nudge the view by a fraction.
    def zoom_in
      zoom = viewport.zoom_level
      fraction = zoom - zoom.floor
      target = fraction < 0.7 ? (zoom + 1).floor : (zoom + 2).floor
      shumate_map.go_to_full_with_duration(viewport.latitude, viewport.longitude, [target, viewport.max_zoom_level].min, 200)
    end

    # Zooms out one step, mirroring zoom_in's fraction snapping.
    def zoom_out
      zoom = viewport.zoom_level
      fraction = zoom - zoom.floor
      target = fraction > 0.3 ? zoom.floor : (zoom - 1).floor
      shumate_map.go_to_full_with_duration(viewport.latitude, viewport.longitude, [target, viewport.min_zoom_level].max, 200)
    end

    # Straightens the map, as upstream's reset-rotation action does by
    # setting Shumate.Viewport#rotation directly to 0.
    def reset_rotation
      viewport.rotation = 0.0
    end

    private

      # Shumate::SimpleMap#map returns the inner Shumate::Map it wraps
      # (distinct from MapView#map, this class's own widget accessor), which
      # is where go_to_full_with_duration actually lives.
      def shumate_map = map.map

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
