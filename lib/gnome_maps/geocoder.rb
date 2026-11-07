# frozen_string_literal: true

require "geocode-glib"

module GnomeMaps
  # Forward geocoding: turns search text into a place. Upstream's
  # src/geocode.js dispatches to its own Photon/GraphHopper HTTP backends;
  # this port instead asks GeocodeGlib::Forward, the geocode-glib GI
  # binding's own forward-search object, which does the HTTP call itself.
  class Geocoder
    # Calls `callback` with (location, error): a GeocodeGlib::Location on
    # success, or (nil, the raised error) when the search found nothing or
    # failed (no network, no match, etc).
    def search(query, &callback)
      GeocodeGlib::Forward.new(query).search_async(nil) do |source, result|
        begin
          callback.call(source.search_finish(result).first, nil)
        rescue => e
          callback.call(nil, e)
        end
      end
    end
  end
end
