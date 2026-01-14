# frozen_string_literal: true

module Hytale
  module Client
    class Map
      class Marker
        attr_reader :data, :id

        def initialize(data, id: nil)
          @data = data
          @id = id
        end

        def position
          pos = data["Position"] || {}
          Player::Position.new(pos["X"], pos["Y"], pos["Z"])
        end

        def x = position.x
        def y = position.y
        def z = position.z

        def name_key
          data["Name"]
        end

        def name
          return nil unless name_key

          parts = name_key.split(".")
          name_part = parts[-2] || parts.last

          name_part.gsub("_", " ")
        end

        def icon
          data["Icon"]
        end

        def marker_id
          data["MarkerId"]
        end

        def to_s
          "#{name} at #{position}"
        end
      end
    end
  end
end
