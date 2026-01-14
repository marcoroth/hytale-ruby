# frozen_string_literal: true

module Hytale
  module Client
    class Player
      class Item
        attr_reader :data, :slot

        def initialize(data, slot: nil)
          @data = data
          @slot = slot
        end

        def id = data["Id"]
        def name = id&.gsub("_", " ")
        def type = ItemType.find(id) || ItemType.new(id)
        def quantity = data["Quantity"]
        def durability = data["Durability"]
        def max_durability = data["MaxDurability"]

        def durability_percent
          return nil unless durability && max_durability && max_durability > 0

          (durability / max_durability * 100).round(1)
        end

        def damaged?
          durability && max_durability && durability < max_durability
        end

        def icon_path
          find_icon_path || Assets.item_icon_path(id)
        end

        def icon_exists?
          !!find_icon_path
        end

        private

        def find_icon_path
          path = Assets.item_icon_path(id)
          return path if File.exist?(path)

          variations = generate_icon_variations(id)

          variations.each do |variation|
            path = Assets.item_icon_path(variation)
            return path if File.exist?(path)
          end

          alternate_paths = generate_alternate_paths(id)

          alternate_paths.each do |alt_path|
            full_path = Assets.cached_path(alt_path)
            return full_path if File.exist?(full_path)
          end

          nil
        end

        def generate_icon_variations(item_id)
          variations = []

          if item_id.include?("Shortbow")
            variations << item_id.gsub("Shortbow", "Bow")
          end

          if item_id.include?("Longbow")
            variations << item_id.gsub("Longbow", "Bow")
          end

          if item_id.include?("Longsword")
            variations << item_id.gsub("Longsword", "Sword")
          end

          variations
        end

        def generate_alternate_paths(item_id)
          paths = []

          # EditorTool_Paint -> Common/Icons/Items/EditorTools/Paint.png
          if item_id.start_with?("EditorTool_")
            tool_name = item_id.sub("EditorTool_", "")

            paths << "Common/Icons/Items/EditorTools/#{tool_name}.png"
          end

          paths
        end

        public

        def to_s
          string = name.to_s

          string += " x#{quantity}" if quantity && quantity > 1
          string += " (#{durability_percent}%)" if durability_percent && durability_percent < 100

          string
        end

        def to_h = data
      end
    end
  end
end
