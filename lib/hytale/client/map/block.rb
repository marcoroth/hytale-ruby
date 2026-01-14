# frozen_string_literal: true

module Hytale
  module Client
    class Map
      # Represents a specific block at coordinates in the world.
      # Contains a reference to its BlockType for texture/category info.
      class Block
        attr_reader :block_type, :x, :y, :z, :chunk

        # @param block_type [BlockType] The type of this block
        # @param x [Integer] Local X coordinate within chunk (0-15)
        # @param y [Integer] Y coordinate (height)
        # @param z [Integer] Local Z coordinate within chunk (0-15)
        # @param chunk [Chunk, nil] The chunk this block belongs to
        def initialize(block_type, x:, y:, z:, chunk: nil)
          @block_type = block_type
          @x = x
          @y = y
          @z = z
          @chunk = chunk
        end

        def id
          block_type.id
        end

        def name
          block_type.name
        end

        def category
          block_type.category
        end

        def subcategory
          block_type.subcategory
        end

        def texture_path
          block_type.texture_path
        end

        def texture_exists?
          block_type.texture_exists?
        end

        def texture_data
          block_type.texture_data
        end

        def world_x
          return nil unless chunk&.world_x

          chunk.world_x + x
        end

        def world_z
          return nil unless chunk&.world_z

          chunk.world_z + z
        end

        def world_y
          y
        end

        def world_position
          return nil unless world_x && world_z

          [world_x, world_y, world_z]
        end

        def local_position
          [x, y, z]
        end

        def empty?
          id == "Empty" || id.start_with?("Air")
        end

        def solid?
          !empty? && !liquid?
        end

        def liquid?
          ["Water", "Lava"].include?(category)
        end

        def vegetation?
          category == "Plant" || id.include?("Grass")
        end

        def to_s
          position = world_position ? "(#{world_x}, #{world_y}, #{world_z})" : "(#{x}, #{y}, #{z})"

          "Block: #{name} at #{position}"
        end

        def inspect
          "#<Hytale::Client::Map::Block id=#{id.inspect} x=#{x} y=#{y} z=#{z}>"
        end

        def to_h
          {
            id: id,
            name: name,
            category: category,
            x: x,
            y: y,
            z: z,
            world_x: world_x,
            world_y: world_y,
            world_z: world_z,
          }
        end

        def ==(other)
          return false unless other.is_a?(Block)

          other.id == id && other.x == x && other.y == y && other.z == z &&
            other.chunk == chunk
        end

        def eql?(other)
          self == other
        end

        def hash
          [id, x, y, z, chunk&.object_id].hash
        end
      end
    end
  end
end
