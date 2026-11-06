# frozen_string_literal: true

require 'adwaita'

module GnomeMaps
  # Keyboard shortcuts overview dialog.
  #
  # Ported from upstream's data/ui/shortcuts-dialog.blp, an Adw.ShortcutsDialog
  # with a "General" section and a "Map View" section. The items and
  # accelerators below are the same ones blueprint declares.
  class ShortcutsDialog < Adwaita::ShortcutsDialog
    SECTIONS = {
      'General'  => [
        ['Show Preferences', '<Primary>comma'],
        ['Show Shortcuts', '<Primary>question'],
        ['Search', '<Primary>F'],
        ['Explore points-of-interest', '<Primary><Shift>F'],
        ['Show last search results', '<Primary>R'],
        ['Show route planner', '<Primary>D'],
        ['Print route', '<Primary>P'],
        ['Quit', '<Primary>Q'],
        ['Open main menu', 'F10']
      ],
      'Map View' => [
        ['Zoom in', '<Primary>plus <Primary>equal'],
        ['Zoom out', '<Primary>minus'],
        ['Rotate clockwise', '<Alt>Right'],
        ['Rotate counter-clockwise', '<Alt>Left'],
        ['Reset rotation', '<Alt>Up'],
        ['Toggle scale', '<Shift><Primary>S'],
        ['Go to current location', '<Primary>L'],
        ['Open shape layer', '<Primary>O'],
        ['Toggle location marker', '<Shift><Primary>L']
      ],
    }.freeze

    def initialize
      super()
      self.title = 'Keyboard Shortcuts'
    end

    def build
      tap do |dialog|
        SECTIONS.each do |title, items|
          dialog.add(section(title, items))
        end
      end
    end

    private

      def section(title, items)
        Adwaita::ShortcutsSection.new.tap do |section|
          section.title = title
          items.each { |label, accelerator| section.add(item(label, accelerator)) }
        end
      end

    # Positional, not keyword, arguments.
      def item(label, accelerator) = Adwaita::ShortcutsItem.new(label, accelerator)
  end
end
