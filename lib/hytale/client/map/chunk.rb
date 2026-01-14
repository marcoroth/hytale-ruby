# frozen_string_literal: true

require "fileutils"
require "tmpdir"

module Hytale
  module Client
    class Map
      # Represents a single chunk of terrain data
      #
      # Chunks are 16x16xN blocks of terrain data.
      # The binary format appears to contain:
      #   - Block palette (string identifiers for block types)
      #   - Block data (indices into palette + state data)
      #   - Additional metadata
      #
      class Chunk
        CHUNK_WIDTH = 16
        CHUNK_DEPTH = 16

        attr_reader :data, :index, :region

        def initialize(data, index: nil, region: nil)
          @data = data
          @index = index
          @region = region
          @parsed = false
        end

        def size
          data.bytesize
        end

        def local_x
          return nil unless index

          index % 32
        end

        def local_z
          return nil unless index

          index / 32
        end

        def world_x
          return nil unless region && local_x

          (region.x * 32 * CHUNK_WIDTH) + (local_x * CHUNK_WIDTH)
        end

        def world_z
          return nil unless region && local_z

          (region.z * 32 * CHUNK_DEPTH) + (local_z * CHUNK_DEPTH)
        end

        def block_types
          @block_types ||= extract_block_types
        end

        def block_palette
          @block_palette ||= extract_palette
        end

        def has_block?(block_type)
          block_types.include?(block_type)
        end

        def has_water?
          block_types.any? { |t| t.include?("Water") }
        end

        def has_vegetation?
          block_types.any? { |t| t.include?("Plant") || t.include?("Grass") || t.include?("Tree") }
        end

        def terrain_type
          if has_water?
            :water
          elsif block_types.any? { |t| t.include?("Sand") }
            :desert
          elsif block_types.any? { |t| t.include?("Snow") || t.include?("Ice") }
            :snow
          elsif has_vegetation?
            :grassland
          else
            :rocky
          end
        end

        def to_s
          position = if local_x && local_z
                       "(#{local_x}, #{local_z})"
                     else
                       "##{index}"
                     end

          "Chunk #{position} - #{size} bytes, #{block_types.size} block types"
        end

        def inspect
          "#<Hytale::Client::Map::Chunk index=#{index} size=#{size} block_types=#{block_types.size}>"
        end

        # Returns the sections parsed from the chunk data
        # Each section contains block data for a vertical slice of the chunk
        def sections
          @sections ||= parse_sections
        end

        # Returns a 16x16 grid of the topmost Block at each X,Z position
        # @return [Array<Array<Block, nil>>] 2D array indexed as [z][x]
        def surface_blocks
          @surface_blocks ||= begin
            grid = Array.new(CHUNK_DEPTH) { Array.new(CHUNK_WIDTH) }

            CHUNK_DEPTH.times do |z|
              CHUNK_WIDTH.times do |x|
                grid[z][x] = surface_at(x, z)
              end
            end

            grid
          end
        end

        # Returns a simple top-down view of the chunk as a 2D array
        # Each cell contains the name of the topmost visible block at that X,Z position
        def top_down_view
          @top_down_view ||= generate_top_down_view
        end

        def to_ascii_map
          view = top_down_view
          return "No block data" if view.empty?

          lines = []

          view.each do |row|
            line = row.map do |block|
              case block
              when /Grass/ then "G"
              when /Dirt/ then "D"
              when /Stone/ then "S"
              when /Rock/ then "R"
              when /Water/ then "~"
              when /Sand/ then "."
              when /Wood/ then "W"
              when /Plant/ then "P"
              when /Empty/, nil then " "
              else "?"
              end
            end.join

            lines << line
          end

          lines.join("\n")
        end

        # Render chunk to PNG file
        # @param path [String] Output file path
        # @param scale [Integer] Scale factor (1 = 16x16 pixels)
        # @param detailed [Boolean] If true, render each block individually
        # @param shading [Boolean] If true, apply height-based shading for depth visualization
        def render_to_png(path, scale: 1, detailed: true, shading: true)
          renderer = Renderer.new
          renderer.save_chunk(self, path, scale: scale, detailed: detailed, shading: shading)
        end

        # Render chunk using actual block textures
        # @param path [String, nil] Output file path (nil = use cache path)
        # @param texture_scale [Integer] Pixels per block (16 = full texture resolution)
        # @param shading [Boolean] If true, apply height-based shading
        # @param cache [Boolean] If true, use cached image if available
        def render_textured(path = nil, texture_scale: 16, shading: true, cache: true)
          path ||= cache_path(texture_scale: texture_scale, shading: shading)

          return path if cache && File.exist?(path)

          FileUtils.mkdir_p(File.dirname(path))

          renderer = Renderer.new
          png = renderer.render_chunk_textured(self, texture_scale: texture_scale, shading: shading)
          png.save(path)

          path
        end

        # Returns the cache path for this chunk's rendered image
        # @param texture_scale [Integer] Texture scale used
        # @param shading [Boolean] Whether shading is enabled
        # @return [String] Cache file path
        def cache_path(texture_scale: 16, shading: true)
          return nil unless region

          save_name = region.path.split("/").find do |p|
            p.include?("Saves")
          end&.then { |_| region.path.split("Saves/")[1]&.split("/")&.first } || "unknown"
          world_name = region.path.split("/worlds/")[1]&.split("/")&.first || "default"

          cache_dir = File.join(
            Dir.tmpdir,
            "hytale_cache",
            save_name,
            world_name,
            "regions",
            "#{region.x}_#{region.z}"
          )

          shading_suffix = shading ? "" : "_noshade"
          filename = "chunk_#{local_x}_#{local_z}_#{texture_scale}x#{shading_suffix}.png"

          File.join(cache_dir, filename)
        end

        def cached?(texture_scale: 16, shading: true)
          path = cache_path(texture_scale: texture_scale, shading: shading)
          path && File.exist?(path)
        end

        def clear_cache!
          path = cache_path
          return unless path

          dir = File.dirname(path)
          FileUtils.rm_rf(dir) if File.directory?(dir)
        end

        # Returns a Block instance at local coordinates (x, y, z) within this chunk
        # x, z: 0-15 (horizontal position within chunk)
        # y: 0-N (vertical position, 0 = bottom)
        #
        # @return [Block, nil] Block instance or nil if out of bounds
        def block_at(x, y, z)
          type_id = block_type_at(x, y, z)
          return nil unless type_id

          block_type = get_or_create_block_type(type_id)
          Block.new(block_type, x: x, y: y, z: z, chunk: self)
        end

        # Returns the block type ID (string) at local coordinates
        # Use this for performance-critical code that doesn't need Block instances
        #
        # @return [String, nil] Block type ID (e.g., "Rock_Stone") or nil
        def block_type_at(x, y, z)
          return nil unless x.between?(0, CHUNK_WIDTH - 1)
          return nil unless z.between?(0, CHUNK_DEPTH - 1)

          parsed = parsed_block_data
          return nil unless parsed

          palette = parsed[:palette]
          block_data = parsed[:block_data]

          return nil if y.negative? || y >= parsed[:height]

          block_index = (z * CHUNK_WIDTH) + x

          # Encoding depends on palette size:
          # - Palette <= 16: 4-bit encoding (128 bytes per layer, 2 blocks per byte)
          # - Palette > 16: 8-bit encoding (256 bytes per layer, 1 block per byte)
          if palette.size <= 16
            layer_offset = y * 128
            byte_offset = layer_offset + (block_index / 2)

            return nil if byte_offset >= block_data.size

            byte = block_data[byte_offset].ord
            index = if block_index.even?
                      byte & 0x0F
                    else
                      (byte >> 4) & 0x0F
                    end
          else
            layer_offset = y * 256
            byte_offset = layer_offset + block_index

            return nil if byte_offset >= block_data.size

            index = block_data[byte_offset].ord
          end

          return nil if index.zero? # Index 0 is always air/void

          palette[index]
        end

        # Returns the height (number of Y layers) in this chunk section
        def height
          parsed = parsed_block_data
          return 0 unless parsed

          parsed[:height]
        end

        # Finds the highest non-empty block at the given X, Z position
        #
        # @return [Block, nil] The surface Block instance or nil if none found
        def surface_at(x, z)
          return nil unless x.between?(0, CHUNK_WIDTH - 1)
          return nil unless z.between?(0, CHUNK_DEPTH - 1)

          (height - 1).downto(0) do |y|
            type_id = block_type_at(x, y, z)
            next if type_id.nil? || type_id == "Empty" || type_id.start_with?("Air")

            block_type = get_or_create_block_type(type_id)
            return Block.new(block_type, x: x, y: y, z: z, chunk: self)
          end

          nil
        end

        def parsed_block_data
          @parsed_block_data ||= parse_block_data_structure
        end

        private

        def block_type_cache
          @block_type_cache ||= {}
        end

        def get_or_create_block_type(type_id)
          block_type_cache[type_id] ||= BlockType.new(type_id)
        end

        # Parses the BSON-like block data structure
        # Format:
        #   Header (9 bytes): 00 00 00 0a 01 00 [palette_count] 00 00
        #   Palette entries: [length 1B] [name] [metadata 4B with index at byte 2]
        #   Block data: 4-bit packed indices (128 bytes per Y layer)
        #
        # Chunks contain multiple sections for different Y ranges. This method
        # finds the section containing surface blocks (Grass, Soil_Dirt, etc.)
        # for accurate terrain rendering.
        def parse_block_data_structure
          sections = find_all_block_sections
          return nil if sections.empty?

          # Sections are ordered by Y-level (higher index = higher elevation)
          # Prefer the LAST (highest) section with surface blocks
          surface_sections = sections.select { |s| s[:has_surface_blocks] }

          section = if surface_sections.any?
                      surface_sections.last
                    else
                      sections.max_by { |s| s[:data_size] }
                    end

          parse_section_data(section[:data_marker], section[:data_size])
        end

        def find_all_block_sections
          sections = []
          position = 0

          while (block_marker = data.index("\x03Block\x00", position))
            data_marker = data.index("\x05Data\x00", block_marker)
            break unless data_marker && data_marker < block_marker + 100

            data_size = begin
              data[data_marker + 6, 4].unpack1("V")
            rescue StandardError
              0
            end
            next if data_size.zero?

            position = block_marker + 1

            raw_data = data[data_marker + 11, [data_size, 500].min]
            has_surface = raw_data&.match?(/Soil_Grass|Soil_Dirt[^_]|Soil_Pathway/)

            sections << {
              block_marker: block_marker,
              data_marker: data_marker,
              data_size: data_size,
              has_surface_blocks: has_surface,
            }
          end

          sections
        end

        def parse_section_data(data_marker, data_size)
          raw_data = data[data_marker + 11, data_size]
          return nil unless raw_data && raw_data.size > 20

          palette_count = raw_data[6].ord
          return nil if palette_count.zero? || palette_count > 64

          # Parse palette entries starting at offset 9
          # Index 0 is implicitly air/void (no block data)
          offset = 9
          palette = {}

          palette_count.times do
            break if offset >= raw_data.size - 10

            len = raw_data[offset].ord
            break if len.zero? || len > 100

            name = raw_data[offset + 1, len]
            meta = raw_data[offset + 1 + len, 4]
            break unless meta && meta.size >= 3

            # Index is at byte 2 of the 4-byte metadata
            index = meta[2].ord
            palette[index] = name if index < 256

            offset += 1 + len + 4
          end

          block_data = raw_data[offset..]
          return nil unless block_data&.size&.positive?

          # Calculate height based on encoding:
          # - Palette <= 16: 4-bit encoding (128 bytes per layer)
          # - Palette > 16: 8-bit encoding (256 bytes per layer)
          bytes_per_layer = palette.size <= 16 ? 128 : 256
          height = block_data.size / bytes_per_layer

          {
            palette: palette,
            block_data: block_data,
            height: height,
          }
        end

        def extract_block_types
          types = Set.new

          data.scan(/(?:Rock|Soil|Water|Plant|Wood|Ore|Sand|Stone|Env|Air|Grass|Snow|Ice|Lava|Clay|Metal|Crystal|Fungi)_[A-Za-z_0-9]+/) do |match|
            types << match
          end

          types.to_a.sort
        end

        def extract_palette
          palette = []
          position = 0

          while position < data.size - 2
            length = begin
              data[position].ord
            rescue StandardError
              0
            end

            if length.positive? && length < 64 && position + 1 + length <= data.size
              string = data[position + 1, length]

              if string =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/
                palette << string
                position += 1 + length

                next
              end
            end

            position += 1
          end

          palette.uniq
        end

        # Parse the "ChunkSection" blocks from the chunk data
        # Each section represents a 16x16x16 vertical slice
        def parse_sections
          sections = []

          block_sections = find_block_data_sections
          sections.concat(block_sections)

          sections
        end

        def find_block_data_sections
          sections = []
          position = 0

          while position < data.size - 100
            block_marker = data.index("Block", position)
            break unless block_marker

            data_marker = data.index("Data", block_marker)

            if data_marker && data_marker < block_marker + 100
              section = parse_block_data_section(data_marker)

              sections << section if section
            end

            position = block_marker + 1
          end

          sections
        end

        # After "Data" there's a size marker and then the block data
        # Format appears to be: "Data" + 0x00 + size(4 bytes) + 0x00*4 + palette + block_data
        def parse_block_data_section(data_offset)
          position = data_offset + 4
          return nil if position + 4 >= data.size

          size = begin
            data[position + 1, 4].unpack1("L<")
          rescue StandardError
            0
          end
          return nil if size.zero? || size > 100_000

          palette = {}
          palette_end = nil

          search_start = position
          search_end = [position + size + 100, data.size].min
          search_data = data[search_start...search_end]

          search_data.scan(/([A-Za-z]+_[A-Za-z_]+)[\x00-\x10]/) do |match|
            name = match[0]
            next unless name =~ /\A(Rock|Soil|Water|Plant|Wood|Ore|Sand|Stone|Env|Air|Grass|Snow|Ice|Empty)_/

            match_position = search_data.index(name)
            next unless match_position

            index_position = match_position + name.length

            if index_position + 4 < search_data.size
              index_data = search_data[index_position, 4]
              index = begin
                index_data.bytes[2]
              rescue StandardError
                nil
              end

              palette[index] = name if index
            end

            palette_end = search_start + match_position + name.length + 4
          end

          palette[1] ||= "Empty" if search_data.include?("Empty")

          {
            offset: data_offset,
            size: size,
            palette: palette,
            palette_end: palette_end,
          }
        end

        # Create a 16x16 grid for the top-down view
        def generate_top_down_view
          view = Array.new(CHUNK_DEPTH) { Array.new(CHUNK_WIDTH) }

          palette = build_primary_palette
          return view if palette.empty?

          block_data_areas = find_block_data_arrays

          block_data_areas.each do |area|
            next unless area[:data] && area[:palette]

            fill_view_from_data(view, area)
          end

          view
        end

        def build_primary_palette
          palette = {}

          block_types.each_with_index do |name, index|
            palette[index] = name
          end

          palette
        end

        # Find areas in the chunk that contain block index data
        # These are typically after a palette section and contain repeated byte values
        def find_block_data_arrays
          areas = []

          block_types.each do |block_type|
            type_position = data.index(block_type)
            next unless type_position

            after_type = type_position + block_type.length + 10

            next unless after_type < data.size - 256

            sample = data[after_type, 256]
            byte_counts = Hash.new(0)
            sample.bytes.each { |b| byte_counts[b] += 1 }

            max_count = byte_counts.values.max || 0

            next unless max_count > 128

            dominant_byte = byte_counts.key(max_count)

            areas << {
              offset: after_type,
              dominant_value: dominant_byte,
              palette: build_section_palette(type_position),
              data: sample,
            }
          end

          areas
        end

        def build_section_palette(section_start)
          palette = {}

          search_start = [0, section_start - 100].max
          search_end = [section_start + 200, data.size].min
          search_data = data[search_start...search_end]

          position = 0

          while position < search_data.size - 10
            length = begin
              search_data[position].ord
            rescue StandardError
              0
            end

            if length > 4 && length < 30
              string = begin
                search_data[position + 1, length]
              rescue StandardError
                ""
              end

              if string =~ /\A(Rock|Soil|Water|Plant|Wood|Ore|Sand|Stone|Env|Air|Grass|Snow|Ice|Empty)_[A-Za-z_]*\z/ || string == "Empty"
                index_position = position + 1 + length + 2
                index = begin
                  search_data[index_position].ord
                rescue StandardError
                  nil
                end

                palette[index] = str if index && index < 16
                position += length + 5

                next
              end
            end

            position += 1
          end

          palette
        end

        # Fill the 16x16 view from packed block data
        # Block data uses 2 bits per block when palette has <=4 entries
        def fill_view_from_data(view, area)
          palette = area[:palette]
          return if palette.empty?

          bits_per_block = calculate_bits_per_block(palette.size)
          return if bits_per_block.zero?

          dominant_block = palette.values.find { |n| n =~ /Grass|Soil|Rock|Stone/ } || palette.values.first

          CHUNK_DEPTH.times do |z|
            CHUNK_WIDTH.times do |x|
              view[z][x] ||= dominant_block
            end
          end
        end

        def calculate_bits_per_block(palette_size)
          case palette_size
          when 0 then 0
          when 1..2 then 1
          when 3..4 then 2
          when 5..16 then 4
          else 8
          end
        end
      end
    end
  end
end
