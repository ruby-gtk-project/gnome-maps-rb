# frozen_string_literal: true

require 'adwaita'

module GnomeMaps
  # InstructionRow is one turn-by-turn step in the route sidebar's
  # instruction list.
  #
  # Ported from upstream's src/instructionRow.js and
  # data/ui/instruction-row.blp: a direction icon, the instruction text
  # (wrapped to 3 lines), and the distance to the next turn.
  #
  # `turn_point` is duck-typed against upstream's Route::TurnPoint: it must
  # respond to #instruction, #distance, #icon_name and #start_or_end?
  # (upstream's TurnPoint.Type.START / .END). Route itself has not been
  # ported yet, so callers build their own turn point objects until it is.
  class InstructionRow < Gtk::ListBoxRow
    TRANSPORTATION_ICONS = {
      'pedestrian' => 'walking-symbolic',
      'bike' => 'cycling-symbolic',
      'car' => 'driving-symbolic',
    }.freeze

    attr_reader :turn_point

    def initialize(turn_point:, transportation: nil, lines: nil)
      super()
      @turn_point = turn_point
      self.child = box.tap do |b|
        b.append(direction_image)
        b.append(instruction_label)
        b.append(distance_label)
      end
      if lines
        instruction_label.lines = lines
      end
      instruction_label.label = turn_point.instruction
      direction_image.icon_name = icon_name_for(transportation)
      if turn_point.start_or_end?
        direction_image.margin_start = 6
        direction_image.margin_end = 6
        direction_image.width_request = 18
        direction_image.icon_size = :small
      end
      if turn_point.distance.to_f > 0
        distance_label.label = pretty_distance(turn_point.distance)
      end
    end

    def box
      @box ||= Gtk::Box.new(:horizontal, 6).tap do |b|
        b.height_request = 48
        b.baseline_position = :top
        b.margin_start = 6
        b.margin_end = 12
      end
    end

    def direction_image = @direction_image ||= Gtk::Image.new.tap { |img| img.icon_size = :large }

    def instruction_label
      @instruction_label ||= Gtk::Label.new.tap do |l|
        l.halign = :start
        l.xalign = 0
        l.margin_top = 6
        l.margin_bottom = 6
        l.use_underline = true
        l.wrap = true
        l.ellipsize = :end
        l.width_chars = 20
        l.max_width_chars = 20
        l.lines = 3
        l.hexpand = true
        l.vexpand = true
      end
    end

    def distance_label
      @distance_label ||= Gtk::Label.new.tap do |l|
        l.halign = :end
        l.use_underline = true
        l.lines = 3
      end
    end

    private

      def icon_name_for(transportation)
        if turn_point.start_or_end?
          TRANSPORTATION_ICONS[transportation] || 'maps-point-start-symbolic'
        else
          turn_point.icon_name
        end
      end

      # Mirrors upstream's Utils.prettyDistance: meters under 1km, otherwise
      # kilometers to one decimal place.
      def pretty_distance(meters)
        meters < 1000 ? "#{meters.round} m" : format('%.1f km', meters / 1000.0)
      end
  end
end
