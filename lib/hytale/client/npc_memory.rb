# frozen_string_literal: true

module Hytale
  module Client
    class NPCMemory
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def id = data["Id"]
      def npc_role = data["NPCRole"]
      def translation_key = data["TranslationKey"]
      def name_overridden? = data["IsMemoriesNameOverridden"]

      def captured_at
        timestamp = data["CapturedTimestamp"]
        timestamp ? Time.at(timestamp / 1000.0) : nil
      end

      def location_key = data["FoundLocationNameKey"]

      def location
        location_key&.split(".")&.last
      end

      def friendly_name
        npc_role&.gsub("_", " ")
      end

      def to_s
        "#{friendly_name} found at #{location}"
      end

      def to_h = data
    end
  end
end
