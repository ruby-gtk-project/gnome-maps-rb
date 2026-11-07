# frozen_string_literal: true

require 'adwaita'

module GnomeMaps
  # ShapeLayerRow is one entry in the layers popover listing an imported
  # shape layer (GeoJSON/GPX/KML), with a visibility toggle and a close
  # button.
  #
  # Ported from upstream's src/layersPopover.js (the ShapeLayerRow class
  # within it) and data/ui/shape-layer-row.blp.
  #
  # `shape_layer` is duck-typed against upstream's ShapeLayer: it must
  # respond to #name, #file (anything responding to #parse_name) and
  # #visible? / #visible=. ShapeLayer itself has not been ported yet.
  class ShapeLayerRow < Gtk::ListBoxRow
    attr_reader :shape_layer

    def initialize(shape_layer:)
      super()
      @shape_layer = shape_layer
      self.child = row_box.tap do |b|
        b.append(spacer)
        b.append(layer_label)
        b.append(visible_button)
        b.append(close_button)
      end
      layer_label.label = shape_layer.name
      layer_label.tooltip_text = shape_layer.file.parse_name
      self.activatable = shape_layer.visible?
      visible_button.signal_connect('clicked') { toggle_visibility }
    end

    def row_box
      @row_box ||= Gtk::Box.new(:horizontal, 6).tap do |b|
        b.margin_top = 6
        b.margin_bottom = 6
      end
    end

    def spacer = @spacer ||= Gtk::Separator.new(:horizontal).tap { |s| s.add_css_class('spacer') }

    def layer_label
      @layer_label ||= Gtk::Label.new.tap do |l|
        l.hexpand = true
        l.ellipsize = :end
        l.xalign = 0
      end
    end

    def visible_button
      @visible_button ||= Gtk::Button.new.tap do |b|
        b.hexpand = true
        b.halign = :end
        b.tooltip_text = 'Toggle visible'
        b.icon_name = 'layer-visible-symbolic'
        b.add_css_class('flat')
        b.add_css_class('circular')
      end
    end

    def close_button
      @close_button ||= Gtk::Button.new.tap do |b|
        b.hexpand = true
        b.halign = :end
        b.tooltip_text = 'Remove Shape Layer'
        b.icon_name = 'window-close-symbolic'
        b.add_css_class('flat')
        b.add_css_class('circular')
      end
    end

    private

      def toggle_visibility
        shape_layer.visible = !shape_layer.visible?
        self.activatable = shape_layer.visible?
        visible_button.icon_name = shape_layer.visible? ? 'layer-visible-symbolic' : 'layer-not-visible-symbolic'
      end
  end
end
