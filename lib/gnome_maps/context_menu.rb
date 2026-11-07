# frozen_string_literal: true

require "gtk4"
require "geocode-glib"

module GnomeMaps
  # The map's right-click/long-press context menu.
  #
  # Ported from upstream's data/ui/context-menu.blp (a Gio::Menu model with
  # two sections) and the menu-handling half of src/mapView.js: a
  # Gtk::PopoverMenu built from that model, popped up at the clicked point,
  # backed by a "view" action group.
  #
  # Only the two actions this port can back with real behavior are wired up:
  # copy-location puts a real `geo:` URI (GeocodeGlib::Location#to_uri, the
  # same call upstream's own _onCopyLocationActivated makes) on the
  # clipboard. The other four actions upstream wires here — routing and
  # adding an OSM location — depend on components this round does not
  # include (no route planner, no OSM edit dialog), so they are registered,
  # present in the menu exactly as upstream's blueprint lists them, and
  # disabled, the same way GTK disables an action tied to a capability the
  # current state can't serve.
  class ContextMenu
    def initialize(widget:)
      @widget = widget
      @latitude = 0.0
      @longitude = 0.0
    end

    attr_reader :widget

    # Attaches the popover to the widget, inserts the "view" action group,
    # and wires the secondary-click and long-press gestures that open it at
    # the pressed point, as upstream's MapView constructor does for its own
    # `this.map`.
    def attach
      popover.set_parent(widget)
      widget.insert_action_group("view", action_group)
      widget.add_controller(secondary_click_gesture)
      widget.add_controller(long_press_gesture)
      self
    end

    def menu_model
      @menu_model ||= Gio::Menu.new.tap do |menu|
        menu.append_section(nil, route_section)
        menu.append_section(nil, location_section)
      end
    end

    def popover
      @popover ||= Gtk::PopoverMenu.new(menu_model).tap do |pm|
        pm.has_arrow = false
      end
    end

    def action_group
      @action_group ||= Gio::SimpleActionGroup.new.tap do |group|
        group.add_action(route_from_here_action)
        group.add_action(add_intermediate_destination_action)
        group.add_action(route_to_here_action)
        group.add_action(clear_route_action)
        group.add_action(copy_location_action)
        group.add_action(add_osm_location_action)
      end
    end

    private

      def route_section
        Gio::Menu.new.tap do |section|
          section.append("Route from Here", "view.route-from-here")
          section.append("Add Intermediate Destination", "view.add-intermediate-destination")
          section.append("Route to Here", "view.route-to-here")
          section.append("Clear Current Route", "view.clear-route")
        end
      end

      def location_section
        Gio::Menu.new.tap do |section|
          section.append("Copy Location", "view.copy-location")
          section.append("Add to OpenStreetMap…", "view.add-osm-location")
        end
      end

      # These four depend on the route planner (routeQuery, route-from-here
      # et al in upstream's mapView.js), which this round doesn't port.
      def route_from_here_action = Gio::SimpleAction.new("route-from-here").tap { |a| a.enabled = false }
      def add_intermediate_destination_action = Gio::SimpleAction.new("add-intermediate-destination").tap { |a| a.enabled = false }
      def route_to_here_action = Gio::SimpleAction.new("route-to-here").tap { |a| a.enabled = false }
      def clear_route_action = Gio::SimpleAction.new("clear-route").tap { |a| a.enabled = false }

      # Depends on the OSM edit dialog this round doesn't port.
      def add_osm_location_action = Gio::SimpleAction.new("add-osm-location").tap { |a| a.enabled = false }

      def copy_location_action
        Gio::SimpleAction.new("copy-location").tap do |action|
          action.signal_connect("activate") { copy_location }
        end
      end

      def copy_location
        widget.clipboard.set(
          GeocodeGlib::Location.new(@latitude, @longitude, 0.0).to_uri(GeocodeGlib::LocationURIScheme::GEO),
        )
      end

      def secondary_click_gesture
        @secondary_click_gesture ||= Gtk::GestureClick.new.tap do |gesture|
          gesture.button = Gdk::BUTTON_SECONDARY
          gesture.signal_connect("pressed") { |_g, _n, x, y| show_at(x, y) }
        end
      end

      def long_press_gesture
        @long_press_gesture ||= Gtk::GestureLongPress.new.tap do |gesture|
          gesture.touch_only = true
          gesture.signal_connect("pressed") { |_g, x, y| show_at(x, y) }
        end
      end

      # Remembers the clicked coordinate (as upstream's _showContextMenuAt
      # does via this._latitude/this._longitude) and pops the menu up there.
      def show_at(x, y)
        @latitude, @longitude = viewport.widget_coords_to_location(widget, x, y)
        popover.pointing_to = Gdk::Rectangle.new(x.to_i, y.to_i, 0, 0)
        popover.popup
      end

      def viewport = widget.respond_to?(:viewport) ? widget.viewport : widget.map.viewport
  end
end
