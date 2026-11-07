# frozen_string_literal: true

# graphene ships as part of the gtk4 gem's own dependency closure; there is
# no standalone "graphene" gem to require.
require "gtk4"

module GnomeMaps
  # The floating zoom/rotate/locate control cluster laid over the map.
  #
  # Ported from upstream's data/ui/zoom-and-rotate-controls.blp and
  # src/zoomAndRotateControls.js: a reset-rotation button (shown only while
  # the map is actually rotated, behind a crossfade Revealer, and itself
  # drawn rotated to match the map) plus always-visible locate/zoom-out/
  # zoom-in buttons, all wired through `win.*` actions rather than direct
  # callbacks, exactly as the blueprint's `action-name` properties do.
  class ZoomAndRotateControls < Gtk::Box
    # Upstream's RotationButton: a plain Gtk.Button whose vfunc_snapshot
    # rotates its own icon to match the map's current rotation, pivoting
    # around the icon's center.
    class RotationButton < Gtk::Button
      def initialize(viewport)
        super()
        @viewport = viewport
      end

      def vfunc_snapshot(snapshot)
        snapshot.save
        rotation = @viewport.rotation
        if rotation != 0.0
          width = get_width
          height = get_height
          point = Graphene::Point.new
          point.init(width / 2.0, height / 2.0)
          snapshot.translate(point)
          snapshot.rotate(rotation * 180 / Math::PI)
          point.init(-width / 2.0, -height / 2.0)
          snapshot.translate(point)
        end
        super
        snapshot.restore
      end
    end

    def initialize(map_view:)
      super(:horizontal, 12)
      @map_view = map_view
      @map_view.viewport.signal_connect("notify::rotation") { update_rotation_button }
      update_rotation_button
    end

    attr_reader :map_view

    def build
      tap do |box|
        box.halign = :end
        box.valign = :end
        box.margin_start = 18
        box.margin_end = 18
        box.margin_top = 18
        box.margin_bottom = 18

        box.append(revealer)
        box.append(current_location_button)
        box.append(zoom_out_button)
        box.append(zoom_in_button)
      end
    end

    def revealer
      @revealer ||= Gtk::Revealer.new.tap do |r|
        r.transition_type = :crossfade
        r.child = rotation_button
      end
    end

    def rotation_button
      @rotation_button ||= RotationButton.new(map_view.viewport).tap do |btn|
        btn.action_name = "win.reset-rotation"
        btn.tooltip_text = "Reset Rotation"
        btn.icon_name = "navigate-north-symbolic"
        btn.add_css_class("card")
        btn.add_css_class("circular")
      end
    end

    def current_location_button
      @current_location_button ||= Gtk::Button.new.tap do |btn|
        btn.action_name = "win.goto-user-location"
        btn.tooltip_text = "Current Location"
        btn.icon_name = "find-location-symbolic"
        btn.add_css_class("card")
        btn.add_css_class("circular")
      end
    end

    def zoom_out_button
      @zoom_out_button ||= Gtk::Button.new.tap do |btn|
        btn.action_name = "win.zoom-out"
        btn.tooltip_text = "Zoom Out"
        btn.icon_name = "zoom-out-symbolic"
        btn.add_css_class("card")
        btn.add_css_class("circular")
      end
    end

    def zoom_in_button
      @zoom_in_button ||= Gtk::Button.new.tap do |btn|
        btn.action_name = "win.zoom-in"
        btn.tooltip_text = "Zoom In"
        btn.icon_name = "zoom-in-symbolic"
        btn.add_css_class("card")
        btn.add_css_class("circular")
      end
    end

    private

      # Mirrors upstream's _updateRotationButton: redraw the button while
      # rotated (so its own snapshot stays in sync), and only reveal it
      # while the map isn't at the default (north-up) rotation.
      def update_rotation_button
        rotation = map_view.viewport.rotation
        rotation_button.queue_draw if rotation != 0.0
        revealer.reveal_child = rotation != 0.0
      end
  end
end
