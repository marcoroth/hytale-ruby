# frozen_string_literal: true

require "json"

module Hytale
  module Client
    # Represents a type of item with its full definition from game assets
    # This includes stats, recipes, quality, etc.
    class ItemType
      ITEMS_PATH = "Server/Item/Items"
      ICONS_PATH = "Common/Icons/ItemsGenerated"

      attr_reader :id

      def initialize(id, data: nil)
        @id = id
        @data = data
      end

      def data
        @data ||= load_definition
      end

      def name(locale: nil)
        if locale
          Locale.item_name(id, locale: locale) || id.tr("_", " ")
        else
          Locale.item_name(id) || id.tr("_", " ")
        end
      end

      def description(locale: nil)
        if locale
          Locale.item_description(id, locale: locale)
        else
          Locale.item_description(id)
        end
      end

      def category
        parts = id.split("_")

        parts.first if parts.any?
      end

      def subcategory
        parts = id.split("_")

        parts[1] if parts.length > 2
      end

      def parent
        data&.dig("Parent")
      end

      def quality
        data&.dig("Quality")
      end

      def item_level
        data&.dig("ItemLevel")
      end

      def max_durability
        data&.dig("MaxDurability")
      end

      def max_stack_size
        data&.dig("MaxStackSize")
      end

      def recipe
        data&.dig("Recipe")
      end

      def recipe_inputs
        recipe&.dig("Input") || []
      end

      def recipe_time
        recipe&.dig("TimeSeconds")
      end

      def model_path
        data&.dig("Model")
      end

      def texture_path
        data&.dig("Texture")
      end

      def icon_relative_path
        data&.dig("Icon")
      end

      def icon_path
        @icon_path ||= find_icon_path
      end

      def icon_exists?
        path = icon_path
        path && File.exist?(path)
      end

      def definition_exists?
        !!find_definition_path
      end

      def to_s
        "ItemType: #{name}"
      end

      def inspect
        "#<Hytale::Client::ItemType id=#{id.inspect} quality=#{quality.inspect}>"
      end

      def to_h
        {
          id: id,
          name: name,
          category: category,
          quality: quality,
          item_level: item_level,
          max_durability: max_durability,
          icon_path: icon_path,
        }
      end

      def ==(other)
        other.is_a?(ItemType) && other.id == id
      end

      def eql?(other)
        self == other
      end

      def hash
        id.hash
      end

      class << self
        def all
          @all ||= load_all_items
        end

        def find(id)
          all.find { |item| item.id == id }
        end

        def where(category: nil, quality: nil)
          results = all

          results = results.select { |i| i.category == category } if category
          results = results.select { |i| i.quality == quality } if quality

          results
        end

        def categories
          all.map(&:category).compact.uniq.sort
        end

        def qualities
          all.map(&:quality).compact.uniq.sort
        end

        def count
          all.count
        end

        def reload!
          @all = nil
          @definition_paths = nil
        end

        def definition_paths
          @definition_paths ||= Assets.list(ITEMS_PATH)
                                      .select { |f| f.end_with?(".json") }
                                      .to_h { |f| [File.basename(f, ".json"), f] }
        end

        private

        def load_all_items
          icon_ids = Assets.item_icons
          definition_ids = definition_paths.keys
          all_ids = (icon_ids + definition_ids).uniq.sort

          all_ids.map { |id| new(id) }
        end
      end

      private

      def find_icon_path
        path = Assets.item_icon_path(id)

        return path if File.exist?(path)

        variations = generate_icon_variations

        variations.each do |variation|
          path = Assets.item_icon_path(variation)

          return path if File.exist?(path)
        end

        if id.start_with?("EditorTool_")
          tool_name = id.sub("EditorTool_", "")
          path = Assets.cached_path("Common/Icons/Items/EditorTools/#{tool_name}.png")

          return path if File.exist?(path)
        end

        nil
      end

      def generate_icon_variations
        variations = []

        variations << id.gsub("Shortbow", "Bow") if id.include?("Shortbow")
        variations << id.gsub("Longbow", "Bow") if id.include?("Longbow")
        variations << id.gsub("Longsword", "Sword") if id.include?("Longsword")

        variations
      end

      def find_definition_path
        self.class.definition_paths[id]
      end

      def load_definition
        relative_path = find_definition_path

        return nil unless relative_path

        Assets.extract(relative_path)
        full_path = Assets.cached_path(relative_path)

        return nil unless File.exist?(full_path)

        JSON.parse(File.read(full_path))
      rescue JSON::ParserError
        nil
      end
    end
  end
end
