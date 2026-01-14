# frozen_string_literal: true

module Hytale
  module Client
    class Player
      Vector3 = Data.define(:x, :y, :z) do
        def to_s = "(#{x&.round(4)}, #{y&.round(4)}, #{z&.round(4)})"
        def magnitude = Math.sqrt(((x || 0)**2) + ((y || 0)**2) + ((z || 0)**2))
      end
    end
  end
end
