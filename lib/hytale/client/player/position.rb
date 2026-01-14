# frozen_string_literal: true

module Hytale
  module Client
    class Player
      Position = Data.define(:x, :y, :z) do
        def to_s = "(#{x&.round(2)}, #{y&.round(2)}, #{z&.round(2)})"
        def to_a = [x, y, z]
      end
    end
  end
end
