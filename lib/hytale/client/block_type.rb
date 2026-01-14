# frozen_string_literal: true

module Hytale
  module Client
    # Represents a type of block (e.g., "Rock_Stone", "Soil_Grass")
    # This is the definition/template of a block type with texture and category info.
    # For positioned blocks in the world, see Block.
    class BlockType
      attr_reader :id

      def initialize(id)
        @id = id
      end

      def category
        parts = id.split("_")

        parts.first if parts.any?
      end

      def subcategory
        parts = id.split("_")

        parts[1] if parts.length > 2
      end

      def name
        id.tr("_", " ")
      end

      def state_definition?
        id.start_with?("*")
      end

      def base_id
        state_definition? ? id[1..] : id
      end

      def texture_name
        "#{base_id}.png"
      end

      def texture_path
        find_texture_path || Assets.block_texture_path(texture_name)
      end

      def texture_exists?
        !!find_texture_path
      end

      def texture_data
        path = find_texture_path

        return nil unless path

        relative_path = path.sub(Assets.cache_path + "/", "")

        Assets.read(relative_path)
      end

      private

      def find_texture_path
        path = Assets.block_texture_path(texture_name)

        return path if File.exist?(path)

        variants = [
          "#{base_id}_Sunny",
          "#{base_id}_Deep",
          "#{base_id}_Top",
          "#{base_id}_Side",
          base_id
        ]

        variants.each do |variant|
          path = Assets.block_texture_path("#{variant}.png")
          return path if File.exist?(path)
        end

        nil
      end

      public

      def to_s
        "BlockType: #{name}"
      end

      def inspect
        "#<Hytale::Client::BlockType id=#{id.inspect}>"
      end

      def to_h
        {
          id: id,
          category: category,
          name: name,
          texture_path: texture_path
        }
      end

      def ==(other)
        other.is_a?(BlockType) && other.id == id
      end

      def eql?(other)
        self == other
      end

      def hash
        id.hash
      end

      class << self
        def all
          @all ||= load_all_blocks
        end

        def find(id)
          all.find { |block| block.id == id }
        end

        def where(category: nil, subcategory: nil)
          results = all
          results = results.select { |b| b.category == category } if category
          results = results.select { |b| b.subcategory == subcategory } if subcategory

          results
        end

        def categories
          all.map(&:category).compact.uniq.sort
        end

        def subcategories
          all.map(&:subcategory).compact.uniq.sort
        end

        def count
          all.count
        end

        def reload!
          @all = nil
        end

        def all_textures
          Assets.block_textures
        end

        private

        def load_all_blocks
          texture_names = Assets.block_textures

          block_ids = texture_names
            .reject { |t| t.start_with?("T_") }  # Helper textures (T_Crack_*, etc.)
            .reject { |t| t.start_with?("_") }   # Internal textures
            .reject { |t| t.end_with?("_GS") }   # Greyscale variants
            .uniq
            .sort

          block_ids.map { |id| new(id) }
        end
      end
    end
  end
end
