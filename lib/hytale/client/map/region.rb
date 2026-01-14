# frozen_string_literal: true

require "fileutils"
require "tmpdir"

module Hytale
  module Client
    class Map
      # Parses .region.bin files containing chunk data
      #
      # File format:
      #   Header (32 bytes):
      #     - "HytaleIndexedStorage" (20 bytes magic)
      #     - Version (4 bytes, BE) = 1
      #     - Chunk count (4 bytes, BE) = 1024 (32x32 chunks per region)
      #     - Index table size (4 bytes, BE) = 4096
      #
      #   Index Table (4096 bytes):
      #     - 1024 entries of 4 bytes each (BE)
      #     - Non-zero = chunk exists at that position
      #
      #   Data Section:
      #     - Chunks stored at 4096-byte aligned positions
      #     - Each chunk: [decompressed_size 4B BE] [compressed_size 4B BE] [ZSTD data]
      #
      class Region
        MAGIC = "HytaleIndexedStorage"
        HEADER_SIZE = 32
        CHUNKS_PER_REGION = 1024 # 32x32
        CHUNK_ALIGNMENT = 4096

        attr_reader :path, :x, :z

        def initialize(path)
          @path = path
          @x, @z = parse_coordinates
          @data = nil
          @header_parsed = false
        end

        def filename
          File.basename(path)
        end

        def size
          File.size(path)
        end

        def size_mb
          (size / 1024.0 / 1024.0).round(2)
        end

        def modified_at
          File.mtime(path)
        end

        def header
          parse_header unless @header_parsed

          {
            version: @version,
            chunk_count: @chunk_count,
            index_table_size: @index_table_size,
            data_start: @data_start,
          }
        end

        def chunk_count
          parse_header unless @header_parsed

          index_table.count { |v| v > 0 }
        end

        def block_types
          @block_types ||= extract_block_types
        end

        def chunk_exists?(local_x, local_z)
          idx = (local_z * 32) + local_x
          return false if idx < 0 || idx >= CHUNKS_PER_REGION

          parse_header unless @header_parsed

          index_table[idx] > 0
        end

        def chunk_data(local_x, local_z)
          idx = (local_z * 32) + local_x

          return nil if idx < 0 || idx >= CHUNKS_PER_REGION

          chunk_at_index(idx)
        end

        def each_chunk
          return enum_for(:each_chunk) unless block_given?

          index_table.each_with_index do |sector, idx|
            next if sector == 0

            chunk = chunk_at_index(idx)

            yield chunk if chunk
          end
        end

        def chunk_at_index(idx)
          return nil if idx < 0 || idx >= CHUNKS_PER_REGION

          parse_header unless @header_parsed

          sector = index_table[idx]
          return nil if sector == 0

          parse_chunk_at_sector(sector, idx)
        end

        def chunks
          @chunks ||= parse_chunks
        end

        def to_s
          "Region (#{x}, #{z}) - #{size_mb} MB, #{chunk_count} chunks"
        end

        # Render region to PNG file
        # @param path [String, nil] Output file path (nil = use cache path)
        # @param scale [Integer] Scale factor (1 = 1 pixel per block)
        # @param detailed [Boolean] If true, render each block individually (slower but accurate)
        # @param shading [Boolean] If true, apply height-based shading for depth visualization
        # @param cache [Boolean] If true, use cached image if available
        def render_to_png(path = nil, scale: 1, detailed: false, shading: true, cache: true)
          path ||= cache_path(scale: scale, detailed: detailed, shading: shading)

          return path if cache && File.exist?(path)

          FileUtils.mkdir_p(File.dirname(path))

          renderer = Renderer.new
          renderer.save_region(self, path, scale: scale, detailed: detailed, shading: shading)
        end

        def cache_path(scale: 1, detailed: false, shading: true)
          save_name = path.split("Saves/")[1]&.split("/")&.first || "unknown"
          world_name = path.split("/worlds/")[1]&.split("/")&.first || "default"

          cache_dir = File.join(
            Dir.tmpdir,
            "hytale_cache",
            save_name,
            world_name,
            "regions"
          )

          mode = detailed ? "detailed" : "fast"
          shading_suffix = shading ? "" : "_noshade"
          filename = "region_#{x}_#{z}_#{scale}x_#{mode}#{shading_suffix}.png"

          File.join(cache_dir, filename)
        end

        def cached?(scale: 1, detailed: false, shading: true)
          File.exist?(cache_path(scale: scale, detailed: detailed, shading: shading))
        end

        def clear_cache!
          Dir.glob(File.join(File.dirname(cache_path), "region_#{x}_#{z}_*.png")).each do |f|
            File.delete(f)
          end
        end

        private

        def data
          @data ||= File.binread(path)
        end

        def parse_coordinates
          match = filename.match(/^(-?\d+)\.(-?\d+)\.region\.bin$/)
          return [0, 0] unless match

          [match[1].to_i, match[2].to_i]
        end

        def parse_header
          magic = data[0, 20]

          raise ParseError, "Invalid region file magic" unless magic == MAGIC

          @version = data[20, 4].unpack1("L>")
          @chunk_count = data[24, 4].unpack1("L>")
          @index_table_size = data[28, 4].unpack1("L>")
          @data_start = HEADER_SIZE + @index_table_size
          @header_parsed = true
        end

        def index_table
          @index_table ||= begin
            parse_header unless @header_parsed

            table = []

            CHUNKS_PER_REGION.times do |i|
              offset = HEADER_SIZE + (i * 4)
              table << data[offset, 4].unpack1("L>")
            end

            table
          end
        end

        def parse_chunks
          parse_header unless @header_parsed

          result = {}

          index_table.each_with_index do |sector, idx|
            next if sector == 0

            chunk_data = parse_chunk_at_sector(sector, idx)
            result[idx] = chunk_data if chunk_data
          end

          result
        end

        def parse_chunk_at_sector(sector, idx = nil)
          # Sector is 1-based index into 4096-byte slots
          # ZSTD data position = data_start + 8 + (sector - 1) * 4096
          # Header (8 bytes) is immediately before ZSTD data
          zstd_position = @data_start + 8 + ((sector - 1) * CHUNK_ALIGNMENT)
          header_position = zstd_position - 8

          return nil if zstd_position + 4 > data.size

          zstd_magic = data[zstd_position, 4]
          return nil unless zstd_magic == "\x28\xB5\x2F\xFD".b

          # Read chunk header: [decompressed_size 4B BE] [compressed_size 4B BE]
          decompressed_size = data[header_position, 4].unpack1("L>")
          compressed_size = data[header_position + 4, 4].unpack1("L>")

          return nil if compressed_size == 0 || zstd_position + compressed_size > data.size

          compressed_data = data[zstd_position, compressed_size]

          begin
            decompressed = decompress(compressed_data)

            Chunk.new(decompressed, index: idx, region: self)
          rescue StandardError => e
            warn "Failed to decompress chunk #{idx}: #{e.message}" if $DEBUG

            nil
          end
        end

        def extract_block_types
          types = Set.new

          each_chunk do |chunk|
            chunk.block_types.each { |t| types << t }
          end

          types.to_a.sort
        end

        def decompress(compressed_data)
          require "zstd-ruby"

          Zstd.decompress(compressed_data)
        rescue LoadError
          raise Error, "zstd-ruby gem required for region parsing: gem install zstd-ruby"
        end
      end
    end
  end
end
