# frozen_string_literal: true

module Hytale
  module Client
    class Settings
      class AudioSettings
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def output_device = data["OutputDevice"]
        def master_volume = data["MasterVolume"]
        def output_mode = data["OutputMode"]

        def music_volume = category_volumes["Music"]
        def ambient_volume = category_volumes["Ambient"]
        def sfx_volume = category_volumes["SFX"]
        def ui_volume = category_volumes["UI"]

        def category_volumes
          data["CategoryVolumes"] || {}
        end

        def to_h = data
      end
    end
  end
end
