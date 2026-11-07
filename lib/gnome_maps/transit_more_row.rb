# frozen_string_literal: true

require 'adwaita'

module GnomeMaps
  # TransitMoreRow is the trailing/leading row in a transit itinerary list
  # that loads more alternatives, either earlier or later than what is shown.
  #
  # Ported from upstream's src/transitMoreRow.js and
  # data/ui/transit-more-row.blp: a Stack that swaps between a label and a
  # spinner while loading, which then settles into a dimmed "no more found"
  # label once the search is exhausted.
  class TransitMoreRow < Gtk::ListBoxRow
    def initialize(earlier:)
      super()
      @earlier = earlier
      self.child = grid.tap do |g|
        g.margin_start = 12
        g.margin_end = 12
        g.margin_top = 12
        g.margin_bottom = 12
        g.attach(stack, 0, 0, 1, 1)
      end
      label.label = @earlier ? 'Load earlier alternatives' : 'Load later alternatives'
    end

    def earlier? = @earlier

    def start_loading
      stack.visible_child_name = 'spinner'
    end

    def show_no_more
      self.activatable = false
      label.add_css_class('dimmed')
      stack.visible_child_name = 'label'
      label.label = @earlier ? 'No earlier alternatives found.' : 'No later alternatives found.'
    end

    def grid = @grid ||= Gtk::Grid.new

    def stack
      @stack ||= Gtk::Stack.new.tap do |s|
        s.add_named(label, 'label')
        s.add_named(spinner, 'spinner')
      end
    end

    def label
      @label ||= Gtk::Label.new.tap do |l|
        l.hexpand = true
        l.vexpand = true
      end
    end

    def spinner = @spinner ||= Adwaita::Spinner.new
  end
end
