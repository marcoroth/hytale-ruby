# frozen_string_literal: true

require "fileutils"
require "tmpdir"

module Hytale
  module Client
    class Map
      REGION_SIZE = 512        # Blocks per region (32 chunks × 16 blocks)
      CHUNKS_PER_REGION = 32   # Chunks per region in each dimension
      CHUNK_SIZE = 16          # Blocks per chunk in each dimension

      attr_reader :world_path, :world_name

      def initialize(world_path, world_name: "default")
        @world_path = world_path
        @world_name = world_name
      end

      def chunks_path
        File.join(world_path, "universe", "worlds", world_name, "chunks")
      end

      def resources_path
        File.join(world_path, "universe", "worlds", world_name, "resources")
      end

      def regions
        return [] unless File.directory?(chunks_path)

        Dir.glob(File.join(chunks_path, "*.region.bin")).map do |path|
          Region.new(path)
        end
      end

      def region_at(x, z)
        regions.find { |r| r.x == x && r.z == z }
      end

      # Get the region containing the given world coordinates
      # @param x [Integer] World X coordinate
      # @param z [Integer] World Z coordinate
      # @return [Region, nil] The region or nil if not loaded
      def region_at_world(x, z)
        region_x, region_z = world_to_region_coords(x, z)
        region_at(region_x, region_z)
      end

      # Get the chunk containing the given world coordinates
      # @param x [Integer] World X coordinate
      # @param z [Integer] World Z coordinate
      # @return [Chunk, nil] The chunk or nil if not loaded
      def chunk_at(x, z)
        region = region_at_world(x, z)
        return nil unless region

        local_x, local_z = world_to_chunk_local_coords(x, z)
        region.chunk_data(local_x, local_z)
      end

      # Get the block at the given world coordinates
      # @param x [Integer] World X coordinate
      # @param y [Integer] World Y coordinate (height)
      # @param z [Integer] World Z coordinate
      # @return [Block, nil] The block or nil if not loaded
      def block_at(x, y, z)
        chunk = chunk_at(x, z)
        return nil unless chunk

        block_x, block_z = world_to_block_local_coords(x, z)

        chunk.block_at(block_x, y, block_z)
      end

      # Convert world coordinates to region coordinates
      # Region 0 covers 0..511, region -1 covers -512..-1, etc.
      # @return [Array<Integer>] [region_x, region_z]
      def world_to_region_coords(x, z)
        region_x = floor_div(x, REGION_SIZE)
        region_z = floor_div(z, REGION_SIZE)

        [region_x, region_z]
      end

      # Convert world coordinates to chunk-local coordinates within a region
      # @return [Array<Integer>] [chunk_local_x, chunk_local_z] (0-31)
      def world_to_chunk_local_coords(x, z)
        region_local_x = ((x % REGION_SIZE) + REGION_SIZE) % REGION_SIZE
        region_local_z = ((z % REGION_SIZE) + REGION_SIZE) % REGION_SIZE

        chunk_local_x = region_local_x / CHUNK_SIZE
        chunk_local_z = region_local_z / CHUNK_SIZE

        [chunk_local_x, chunk_local_z]
      end

      # Convert world coordinates to block-local coordinates within a chunk
      # @return [Array<Integer>] [block_local_x, block_local_z] (0-15)
      def world_to_block_local_coords(x, z)
        block_local_x = ((x % CHUNK_SIZE) + CHUNK_SIZE) % CHUNK_SIZE
        block_local_z = ((z % CHUNK_SIZE) + CHUNK_SIZE) % CHUNK_SIZE

        [block_local_x, block_local_z]
      end

      private

      def floor_div(a, b)
        (a.to_f / b).floor
      end

      public

      def bounds
        return nil if regions.empty?

        xs = regions.map(&:x)
        zs = regions.map(&:z)

        {
          min_x: xs.min,
          max_x: xs.max,
          min_z: zs.min,
          max_z: zs.max,
          width: xs.max - xs.min + 1,
          height: zs.max - zs.min + 1,
        }
      end

      def markers
        markers_path = File.join(resources_path, "BlockMapMarkers.json")
        return [] unless File.exist?(markers_path)

        data = JSON.parse(File.read(markers_path))

        (data["Markers"] || {}).map do |id, marker_data|
          Marker.new(marker_data, id: id)
        end
      end

      def time
        time_path = File.join(resources_path, "Time.json")
        return nil unless File.exist?(time_path)

        data = JSON.parse(File.read(time_path))

        data["Now"]
      end

      def total_size
        regions.sum(&:size)
      end

      def total_size_mb
        (total_size / 1024.0 / 1024.0).round(2)
      end

      def block_types
        types = Set.new

        regions.each do |region|
          types.merge(region.block_types)
        rescue StandardError
          # Skip regions that fail to parse
        end

        types.to_a.sort
      end

      # Render map to PNG file
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
        renderer.save_map(self, path, scale: scale, detailed: detailed, shading: shading)
      end

      def cache_path(scale: 1, detailed: false, shading: true)
        save_name = world_path.split("Saves/")[1]&.split("/")&.first || "unknown"

        cache_dir = File.join(
          Dir.tmpdir,
          "hytale_cache",
          save_name,
          world_name
        )

        mode = detailed ? "detailed" : "fast"
        shading_suffix = shading ? "" : "_noshade"
        filename = "map_#{scale}x_#{mode}#{shading_suffix}.png"

        File.join(cache_dir, filename)
      end

      def cached?(scale: 1, detailed: false, shading: true)
        File.exist?(cache_path(scale: scale, detailed: detailed, shading: shading))
      end

      def clear_cache!
        cache_dir = File.dirname(cache_path)
        FileUtils.rm_rf(cache_dir) if File.directory?(cache_dir)
      end

      def to_ascii(players: [])
        return "No regions explored" if regions.empty?

        b = bounds
        lines = []

        header = "     "

        (b[:min_x]..b[:max_x]).each { |x| header += x.to_s.center(3) }
        lines << header
        lines << "    #{"-" * (((b[:max_x] - b[:min_x] + 1) * 3) + 2)}"

        player_regions = players.map do |p|
          pos = p.position
          region_x = (pos.x / 512.0).floor
          region_z = (pos.z / 512.0).floor

          [region_x, region_z, p.name[0].upcase]
        end

        (b[:min_z]..b[:max_z]).each do |z|
          row = "#{z.to_s.rjust(3)} |"

          (b[:min_x]..b[:max_x]).each do |x|
            region = region_at(x, z)
            player_here = player_regions.find { |px, pz, _| px == x && pz == z }

            cell = if player_here
                     " #{player_here[2]} "
                   elsif region
                     size_indicator = case region.size
                                      when 0..1_000_000 then " . "
                                      when 1_000_001..10_000_000 then " o "
                                      when 10_000_001..20_000_000 then " O "
                                      else " # "
                                      end

                     size_indicator
                   else
                     "   "
                   end

            row += cell
          end

          row += "|"

          lines << row
        end

        lines << "    #{"-" * (((b[:max_x] - b[:min_x] + 1) * 3) + 2)}"
        lines << ""
        lines << "Legend: . = small, o = medium, O = large, # = huge, Letter = player"

        lines.join("\n")
      end
    end
  end
end
