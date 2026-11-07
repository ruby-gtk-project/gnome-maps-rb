# frozen_string_literal: true

require 'adwaita'

module GnomeMaps
  # PoiCategoryRow is one entry in the POI category list the search popover
  # shows (e.g. "Restaurants", "ATMs").
  #
  # Ported from upstream's src/poiCategoryRow.js and
  # data/ui/poi-category-row.blp: a leading icon named for the category, the
  # category's translated label, and a trailing "go-next" disclosure icon.
  class PoiCategoryRow < Gtk::ListBoxRow
    def initialize(icon_name:, label:)
      super()
      self.margin_top = 6
      self.margin_start = 6
      self.margin_end = 6
      self.child = box.tap do |b|
        b.append(icon)
        b.append(category_label)
        b.append(disclosure_icon)
      end
      icon.icon_name = icon_name
      category_label.label = label
    end

    def box = @box ||= Gtk::Box.new(:horizontal, 6)

    def icon = @icon ||= Gtk::Image.new.tap { |img| img.valign = :center }

    def category_label
      @category_label ||= Gtk::Label.new.tap do |l|
        l.ellipsize = :end
        l.lines = 0
        l.xalign = 0
      end
    end

    def disclosure_icon
      @disclosure_icon ||= Gtk::Image.new(icon_name: 'go-next').tap do |img|
        img.halign = :end
        img.valign = :center
        img.hexpand = true
      end
    end
  end
end
