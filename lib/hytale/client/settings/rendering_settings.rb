# frozen_string_literal: true

module Hytale
  module Client
    class Settings
      class RenderingSettings
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def render_scale = data["RenderScale"]
        def view_distance = data["ViewDistance"]
        def lod = data["Lod"]
        def anti_aliasing = data["AntiAliasing"]
        def shadows = data["Shadows"]
        def shading = data["Shading"]
        def bloom = data["Bloom"]
        def sunshaft? = data["UseSunshaft"]
        def depth_of_field = data["DepthOfField"]
        def water = data["Water"]
        def foliage_fading? = data["UseFoliageFading"]
        def particles = data["Particles"]

        def to_h = data
      end
    end
  end
end
