# frozen_string_literal: true

module GnomeMaps
  # Latitude/longitude limits a valid bounding box must stay within.
  #
  # Ported from the constants upstream's src/constants.js exports and that
  # src/boundingBox.js relies on for its default box and its isValid check.
  MIN_LATITUDE = -85.0511287798
  MAX_LATITUDE = 85.0511287798
  MIN_LONGITUDE = -180
  MAX_LONGITUDE = 180

  # A rectangular lat/lon bounding box.
  #
  # Ported from upstream's src/boundingBox.js. Defaults to the box "opposite"
  # of covering the whole visible world (left/right and top/bottom swapped
  # past their valid range), so that extending an unset box with any single
  # coordinate always enlarges it to fit that point.
  class BoundingBox
    attr_accessor :top, :left, :bottom, :right

    def initialize(top: MIN_LATITUDE, left: MAX_LONGITUDE, bottom: MAX_LATITUDE, right: MIN_LONGITUDE)
      @top = top
      @left = left
      @bottom = bottom
      @right = right
    end

    def copy
      BoundingBox.new(top: top, left: left, bottom: bottom, right: right)
    end

    # [longitude, latitude] of the box's center.
    def center
      [(right + left) / 2.0, (top + bottom) / 2.0]
    end

    # Extends this box so that everything `other` covers, this covers too.
    def compose(other)
      self.left = other.left if other.left < left
      self.right = other.right if other.right > right
      self.top = other.top if other.top > top
      self.bottom = other.bottom if other.bottom < bottom
      self
    end

    # Extends this box to guarantee it covers (latitude, longitude).
    def extend(latitude, longitude)
      self.left = longitude if longitude < left
      self.bottom = latitude if latitude < bottom
      self.right = longitude if longitude > right
      self.top = latitude if latitude > top
      self
    end

    def valid?
      left < right && bottom < top &&
        left.between?(MIN_LONGITUDE, MAX_LONGITUDE) &&
        right.between?(MIN_LONGITUDE, MAX_LONGITUDE) &&
        bottom.between?(MIN_LATITUDE, MAX_LATITUDE) &&
        top.between?(MIN_LATITUDE, MAX_LATITUDE)
    end

    # True when this box covers the point at (latitude, longitude).
    def covers?(latitude, longitude)
      latitude.between?(bottom, top) && longitude.between?(left, right)
    end

    def to_h
      {left: left, right: right, bottom: bottom, top: top}
    end
  end
end
