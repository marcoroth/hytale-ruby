# frozen_string_literal: true

module Hytale
  module Client
    class Player
      class DeathPosition
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def marker_id
          data["MarkerId"]
        end

        def day
          data["Day"]
        end

        def position
          transform = data["Transform"] || {}

          Position.new(transform["X"], transform["Y"], transform["Z"])
        end

        def rotation
          transform = data["Transform"] || {}

          Rotation.new(transform["Pitch"], transform["Yaw"], transform["Roll"])
        end

        def x = position.x
        def y = position.y
        def z = position.z

        def to_s
          "Death on day #{day} at #{position}"
        end

        def inspect
          "#<DeathPosition day=#{day} position=#{position}>"
        end
      end
    end
  end
end
