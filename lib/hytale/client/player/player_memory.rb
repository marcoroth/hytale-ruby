# frozen_string_literal: true

module Hytale
  module Client
    class Player
      class PlayerMemory
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def id = data["Id"]
        def npc_role = data["NPCRole"]
        def translation_key = data["TranslationKey"]
        def name_overridden? = data["IsMemoriesNameOverridden"]
        def captured_at = data["CapturedTimestamp"] ? Time.at(data["CapturedTimestamp"] / 1000.0) : nil
        def location_key = data["FoundLocationNameKey"]

        def location
          location_key&.split(".")&.last
        end

        def to_s = "#{npc_role} (#{location})"
        def to_h = data
      end
    end
  end
end
