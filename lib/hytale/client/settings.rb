# frozen_string_literal: true

module Hytale
  module Client
    class Settings
      attr_reader :data, :path

      def initialize(data, path: nil)
        @data = data
        @path = path
      end

      # Display settings
      def fullscreen? = data["Fullscreen"]
      def maximized? = data["Maximized"]
      def window_width = data["WindowWidth"]
      def window_height = data["WindowHeight"]
      def window_size = [window_width, window_height]
      def vsync? = data["VSync"]
      def fps_limit = data["FpsLimit"]
      def unlimited_fps? = data["UnlimitedFps"]
      def field_of_view = data["FieldOfView"]

      # Rendering settings
      def rendering
        @rendering ||= RenderingSettings.new(data["RenderingSettings"] || {})
      end

      # Input settings
      def input_bindings
        @input_bindings ||= InputBindings.new(data["InputBindings"] || {})
      end

      def mouse_settings
        @mouse_settings ||= MouseSettings.new(data["MouseSettings"] || {})
      end

      # Audio settings
      def audio
        @audio ||= AudioSettings.new(data["AudioSettings"] || {})
      end

      # Gameplay settings
      def gameplay
        @gameplay ||= GameplaySettings.new(data["GameplaySettings"] || {})
      end

      # Builder tools settings
      def builder_tools
        @builder_tools ||= BuilderToolsSettings.new(data["BuilderToolsSettings"] || {})
      end

      # UI preferences
      def hide_hud? = data["HideHud"]
      def hide_hotbar? = data["HideHotbar"]
      def hide_compass? = data["HideCompass"]
      def hide_chat? = data["HideChat"]
      def diagnostic_mode? = data["DiagnosticMode"]
      def display_combat_text? = data["DisplayCombatText"]
      def sprint_fov_effect? = data["SprintFovEffect"]
      def view_bobbing_effect? = data["ViewBobbingEffect"]
      def camera_shake_effect? = data["CameraShakeEffect"]

      def to_h
        data
      end

      class << self
        def load(path: Config.settings_path)
          raise NotFoundError, "Settings file not found: #{path}" unless File.exist?(path)

          json = File.read(path)
          data = JSON.parse(json)
          new(data, path: path)
        rescue JSON::ParserError => e
          raise ParseError, "Failed to parse settings: #{e.message}"
        end
      end
    end
  end
end
