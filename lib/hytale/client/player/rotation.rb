# frozen_string_literal: true

module Hytale
  module Client
    class Player
      Rotation = Data.define(:pitch, :yaw, :roll) do
        def to_s = "(pitch: #{pitch&.round(2)}, yaw: #{yaw&.round(2)}, roll: #{roll&.round(2)})"
      end
    end
  end
end
