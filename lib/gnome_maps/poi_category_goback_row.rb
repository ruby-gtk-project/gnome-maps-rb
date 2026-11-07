# frozen_string_literal: true

require 'adwaita'

module GnomeMaps
  # PoiCategoryGobackRow is the "back to main categories" entry at the top of
  # a POI category sub-list.
  #
  # Ported from upstream's src/poiCategoryGobackRow.js and
  # data/ui/poi-category-goback-row.blp: a leading "go-previous-symbolic"
  # icon and a fixed label, with no state of its own.
  class PoiCategoryGobackRow < Gtk::ListBoxRow
    def initialize
      super()
      self.margin_top = 6
      self.margin_start = 6
      self.margin_end = 6
      self.accessible_role = :list_item
      self.child = box.tap do |b|
        b.append(icon)
        b.append(label)
      end
    end

    def box = @box ||= Gtk::Box.new(:horizontal, 6)

    def icon
      @icon ||= Gtk::Image.new(icon_name: 'go-previous-symbolic').tap do |img|
        img.valign = :center
      end
    end

    def label
      @label ||= Gtk::Label.new('Back to Main Categories').tap do |l|
        l.xalign = 0
      end
    end
  end
end
