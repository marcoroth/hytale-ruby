# frozen_string_literal: true

module Hytale
  module Client
    class Settings
      class MouseSettings
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def inverted? = data["MouseInverted"]
        def x_speed = data["MouseXSpeed"]
        def y_speed = data["MouseYSpeed"]
        def sensitivity = [x_speed, y_speed]
        def invert_scroll? = data["InvertMouseWheelScrollDirection"]

        def to_h = data
      end
    end
  end
end
