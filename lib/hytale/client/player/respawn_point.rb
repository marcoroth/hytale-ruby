# frozen_string_literal: true

module Hytale
  module Client
    class Player
      class RespawnPoint
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def name
          data["Name"]
        end

        def position
          pos = data["RespawnPosition"] || {}

          Position.new(pos["X"], pos["Y"], pos["Z"])
        end

        def block_position
          pos = data["BlockPosition"] || {}

          Position.new(pos["X"], pos["Y"], pos["Z"])
        end

        def x = position.x
        def y = position.y
        def z = position.z

        def to_s
          "#{name} at #{position}"
        end

        def inspect
          "#<RespawnPoint name=#{name.inspect} position=#{position}>"
        end
      end
    end
  end
end
