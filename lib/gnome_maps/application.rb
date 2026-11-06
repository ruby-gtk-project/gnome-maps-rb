# frozen_string_literal: true

require "gtk4"
require "adwaita"

module GnomeMaps
  # The port's application: one window, and a status page saying the port has
  # not been written yet. Everything else grows from here — replace the status
  # page with the real content, keep the shape.
  #
  # House style (see .claude/skills/ruby-gtk): every widget is a memoized
  # method, all configuration lives in its `tap`, assembly happens only in
  # `build`, and the launcher is one expression.
  class Application
    def build
      app.tap do
        app.signal_connect("activate") do
          window.tap do |win|
            win.content = toolbar_view
            win.add_action(shortcuts_action)
            win.signal_connect("close-request") do
              remember_window_geometry
              false
            end
          end

          toolbar_view.tap do |view|
            view.add_top_bar(header_bar)
            view.content = status_page
          end

          restore_window_geometry
          window.present
        end
      end
    end

    # Adwaita::Application is broken in the Ruby bindings; the application
    # object comes from Gtk and only the window is Adwaita.
    def app = @app ||= Gtk::Application.new("org.rubygtkproject.GnomeMaps", :default_flags)

    def window
      @window ||= Adwaita::ApplicationWindow.new(app).tap do |win|
        win.title = "gnome-maps"
      end
    end

    def toolbar_view = @toolbar_view ||= Adwaita::ToolbarView.new
    def header_bar = @header_bar ||= Adwaita::HeaderBar.new

    def status_page
      @status_page ||= Adwaita::StatusPage.new.tap do |page|
        page.title = "gnome-maps"
        page.description = "The Ruby port has not been written yet."
        page.icon_name = "applications-engineering-symbolic"
      end
    end

    def settings = @settings ||= Settings.new

    def shortcuts_action
      @shortcuts_action ||= Gio::SimpleAction.new("show-shortcuts").tap do |action|
        action.signal_connect("activate") do
          ShortcutsDialog.new.build.present(window)
        end
      end
    end

    private

      # Restores the window size and maximized state the previous run saved,
      # as src/settings.js backs upstream's window-size/-maximized keys.
      def restore_window_geometry
        size = settings.window_size
        (size.is_a?(Array) && size.length == 2).then do |has_saved_size|
          if has_saved_size
            window.set_default_size(*size)
          end
        end
        settings.window_maximized?.then do |maximized|
          if maximized
            window.maximize
          end
        end
      end

      def remember_window_geometry
        settings.window_maximized = window.maximized?
        window.maximized?.then do |maximized|
          if maximized
            nil
          else
            settings.window_size = [window.default_width, window.default_height]
          end
        end
      end
  end
end
