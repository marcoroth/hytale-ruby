# frozen_string_literal: true

module Hytale
  module Client
    class Settings
      class InputBindings
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def [](action)
          data[action]
        end

        def actions
          data.keys
        end

        def to_h = data
      end
    end
  end
end
