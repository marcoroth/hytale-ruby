# frozen_string_literal: true

module Hytale
  module Client
    class World
      class ClientEffects
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def sun_height_percent = data["SunHeightPercent"]
        def sun_angle_degrees = data["SunAngleDegrees"]
        def bloom_intensity = data["BloomIntensity"]
        def bloom_power = data["BloomPower"]
        def sun_intensity = data["SunIntensity"]
        def sunshaft_intensity = data["SunshaftIntensity"]

        def to_h = data
      end
    end
  end
end
