# frozen_string_literal: true

module Hytale
  module Client
    class Map
      # Renders map regions and chunks to PNG images
      # Uses average colors from block textures
      class Renderer
        CHUNK_SIZE = 16
        DEFAULT_SCALE = 1

        attr_reader :color_cache

        def initialize
          @color_cache = {}
        end

        def block_color(block_type)
          return color_cache[block_type] if color_cache.key?(block_type)

          color = calculate_block_color(block_type)
          color_cache[block_type] = color
          color
        end

        # Render a chunk using actual block textures
        # @param chunk [Chunk] The chunk to render
        # @param texture_scale [Integer] Size of each block in pixels (default 16 = full texture)
        # @param shading [Boolean] If true, apply height-based shading
        # @return [ChunkyPNG::Image] The rendered image
        def render_chunk_textured(chunk, texture_scale: 16, shading: true)
          require "chunky_png"

          width = CHUNK_SIZE * texture_scale
          height = CHUNK_SIZE * texture_scale
          png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

          chunk.surface_blocks.each_with_index do |row, block_z|
            row.each_with_index do |block, block_x|
              next unless block

              texture = load_block_texture(block.id)
              next unless texture

              out_x = block_x * texture_scale
              out_z = block_z * texture_scale

              texture_scale.times do |tz|
                texture_scale.times do |tx|
                  tex_x = (tx * texture.width / texture_scale) % texture.width
                  tex_z = (tz * texture.height / texture_scale) % texture.height

                  color = texture[tex_x, tex_z]

                  color = apply_height_shading(color, block.y, chunk.height) if shading

                  png[out_x + tx, out_z + tz] = color
                end
              end
            end
          end

          png
        end

        # Render a single chunk to a PNG image
        # @param chunk [Chunk] The chunk to render
        # @param scale [Integer] Scale factor (1 = 16x16, 2 = 32x32, etc.)
        # @param detailed [Boolean] If true, render each block individually using surface_at
        # @param shading [Boolean] If true, apply height-based shading for depth visualization
        def render_chunk(chunk, scale: DEFAULT_SCALE, detailed: false, shading: true)
          require "chunky_png"

          width = CHUNK_SIZE * scale
          height = CHUNK_SIZE * scale
          png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

          if detailed && chunk.height.positive?
            CHUNK_SIZE.times do |block_z|
              CHUNK_SIZE.times do |block_x|
                surface = chunk.surface_at(block_x, block_z)
                block_type = surface&.id || "Empty"
                color = block_color(block_type) || default_color(block_type)

                color = apply_height_shading(color, surface.y, chunk.height) if shading && surface

                scale.times do |dz|
                  scale.times do |dx|
                    px = (block_x * scale) + dx
                    pz = (block_z * scale) + dz
                    png[px, pz] = color
                  end
                end
              end
            end
          else
            block_types = chunk.block_types
            surface_block = find_surface_block(block_types)
            color = block_color(surface_block) || default_color(surface_block)

            (0...height).each do |y|
              (0...width).each do |x|
                png[x, y] = color
              end
            end
          end

          png
        end

        # Render a region to a PNG image
        # @param region [Region] The region to render
        # @param scale [Integer] Scale factor
        # @param detailed [Boolean] If true, render each block individually
        # @param shading [Boolean] If true, apply height-based shading
        def render_region(region, scale: DEFAULT_SCALE, detailed: false, shading: true)
          require "chunky_png"

          width = 32 * CHUNK_SIZE * scale
          height = 32 * CHUNK_SIZE * scale
          png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

          region.each_chunk do |chunk|
            next unless chunk.local_x && chunk.local_z

            chunk_x = chunk.local_x * CHUNK_SIZE * scale
            chunk_z = chunk.local_z * CHUNK_SIZE * scale

            if detailed && chunk.height.positive?
              CHUNK_SIZE.times do |block_z|
                CHUNK_SIZE.times do |block_x|
                  surface = chunk.surface_at(block_x, block_z)
                  block_type = surface&.id || "Empty"
                  color = block_color(block_type) || default_color(block_type)

                  color = apply_height_shading(color, surface.y, chunk.height) if shading && surface

                  scale.times do |dz|
                    scale.times do |dx|
                      px = chunk_x + (block_x * scale) + dx
                      pz = chunk_z + (block_z * scale) + dz

                      png[px, pz] = color if px < width && pz < height
                    end
                  end
                end
              end
            else
              surface_block = find_surface_block(chunk.block_types)
              color = block_color(surface_block) || default_color(surface_block)

              (0...(CHUNK_SIZE * scale)).each do |dz|
                (0...(CHUNK_SIZE * scale)).each do |dx|
                  x = chunk_x + dx
                  z = chunk_z + dz
                  png[x, z] = color if x < width && z < height
                end
              end
            end
          end

          png
        end

        # Render an entire map to a PNG image
        # @param map [Map] The map to render
        # @param scale [Integer] Scale factor
        # @param detailed [Boolean] If true, render each block individually
        # @param shading [Boolean] If true, apply height-based shading
        def render_map(map, scale: DEFAULT_SCALE, detailed: false, shading: true)
          require "chunky_png"

          bounds = map.bounds
          return nil unless bounds

          region_size = 32 * CHUNK_SIZE * scale
          width = bounds[:width] * region_size
          height = bounds[:height] * region_size

          png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

          map.regions.each do |region|
            region_x = (region.x - bounds[:min_x]) * region_size
            region_z = (region.z - bounds[:min_z]) * region_size

            region.each_chunk do |chunk|
              next unless chunk.local_x && chunk.local_z

              chunk_x = region_x + (chunk.local_x * CHUNK_SIZE * scale)
              chunk_z = region_z + (chunk.local_z * CHUNK_SIZE * scale)

              if detailed && chunk.height.positive?
                CHUNK_SIZE.times do |block_z|
                  CHUNK_SIZE.times do |block_x|
                    surface = chunk.surface_at(block_x, block_z)
                    block_type = surface&.id || "Empty"
                    color = block_color(block_type) || default_color(block_type)

                    color = apply_height_shading(color, surface.y, chunk.height) if shading && surface

                    scale.times do |dz|
                      scale.times do |dx|
                        px = chunk_x + (block_x * scale) + dx
                        pz = chunk_z + (block_z * scale) + dz

                        png[px, pz] = color if px < width && pz < height
                      end
                    end
                  end
                end
              else
                surface_block = find_surface_block(chunk.block_types)
                color = block_color(surface_block) || default_color(surface_block)

                (0...(CHUNK_SIZE * scale)).each do |dz|
                  (0...(CHUNK_SIZE * scale)).each do |dx|
                    x = chunk_x + dx
                    z = chunk_z + dz
                    png[x, z] = color if x < width && z < height
                  end
                end
              end
            end
          end

          png
        end

        def save_chunk(chunk, path, scale: DEFAULT_SCALE, detailed: false, shading: true)
          png = render_chunk(chunk, scale: scale, detailed: detailed, shading: shading)
          png.save(path)
          path
        end

        def save_region(region, path, scale: DEFAULT_SCALE, detailed: false, shading: true)
          png = render_region(region, scale: scale, detailed: detailed, shading: shading)
          png.save(path)
          path
        end

        def save_map(map, path, scale: DEFAULT_SCALE, detailed: false, shading: true)
          png = render_map(map, scale: scale, detailed: detailed, shading: shading)
          return nil unless png

          png.save(path)
          path
        end

        private

        # Apply height-based shading to give a sense of depth/elevation
        # Higher blocks are brighter, lower blocks are darker
        # @param color [Integer] ChunkyPNG color value
        # @param y [Integer] Block Y coordinate (height)
        # @param max_height [Integer] Maximum height in the chunk
        # @return [Integer] Shaded color
        def apply_height_shading(color, y, _max_height)
          require "chunky_png"

          # Normalize height to 0.0-1.0 range
          # Use a reasonable world height range (0-400) for normalization
          world_height = 400
          normalized = (y.to_f / world_height).clamp(0.0, 1.0)

          # Apply brightness modifier: 0.6 (dark/low) to 1.1 (bright/high)
          brightness = 0.6 + (normalized * 0.5)

          r = ChunkyPNG::Color.r(color)
          g = ChunkyPNG::Color.g(color)
          b = ChunkyPNG::Color.b(color)
          a = ChunkyPNG::Color.a(color)

          # Apply brightness and clamp to valid range
          r = (r * brightness).round.clamp(0, 255)
          g = (g * brightness).round.clamp(0, 255)
          b = (b * brightness).round.clamp(0, 255)

          ChunkyPNG::Color.rgba(r, g, b, a)
        end

        def calculate_block_color(block_type)
          texture_path = find_texture_path(block_type)
          return nil unless texture_path

          average_color_from_texture(texture_path)
        rescue StandardError
          nil
        end

        def load_block_texture(block_type)
          @texture_cache ||= {}
          return @texture_cache[block_type] if @texture_cache.key?(block_type)

          texture_path = find_texture_path(block_type)
          return @texture_cache[block_type] = nil unless texture_path

          @texture_cache[block_type] = ChunkyPNG::Image.from_file(texture_path)
        rescue StandardError
          @texture_cache[block_type] = nil
        end

        def find_texture_path(block_type)
          block = BlockType.new(block_type)
          return block.texture_path if block.texture_exists?

          base_name = block_type
          variations = [
            base_name,
            "#{base_name}_Sunny",
            "#{base_name}_Deep",
            "#{base_name}_Top",
            "#{base_name}_Side",
          ]

          variations.each do |name|
            path = Assets.block_texture_path(name)
            return path if File.exist?(path)
          end

          # Try stripping common suffixes to find base texture
          # e.g., Soil_Grass_Full -> Soil_Grass, Plant_Grass_Sharp_Tall -> Plant_Grass_Sharp
          suffixes_to_strip = ["_Full", "_Short", "_Tall", "_Small", "_Large", "_Medium", "_Wild", "_Stack"]

          suffixes_to_strip.each do |suffix|
            next unless base_name.end_with?(suffix)

            stripped = base_name.chomp(suffix)
            stripped_variations = [stripped, "#{stripped}_Sunny", "#{stripped}_Deep"]
            stripped_variations.each do |name|
              path = Assets.block_texture_path(name)
              return path if File.exist?(path)
            end
          end

          matching_textures = Assets.block_textures.select { |t| t.start_with?(base_name) }
          if matching_textures.any?
            colored = matching_textures.reject { |t| t.end_with?("_GS") }
            colored = matching_textures if colored.empty?

            preferred = colored.find { |t| t =~ /_Sunny$|_Deep$|_Top$/ }
            texture_name = preferred || colored.first

            return Assets.block_texture_path(texture_name)
          end

          nil
        end

        def average_color_from_texture(texture_path)
          require "chunky_png"

          png = ChunkyPNG::Image.from_file(texture_path)

          total_r = 0
          total_g = 0
          total_b = 0
          total_a = 0
          count = 0

          png.height.times do |y|
            png.width.times do |x|
              pixel = png[x, y]
              alpha = ChunkyPNG::Color.a(pixel)

              next if alpha < 128

              total_r += ChunkyPNG::Color.r(pixel)
              total_g += ChunkyPNG::Color.g(pixel)
              total_b += ChunkyPNG::Color.b(pixel)
              total_a += alpha

              count += 1
            end
          end

          return nil if count.zero?

          avg_r = (total_r / count).clamp(0, 255)
          avg_g = (total_g / count).clamp(0, 255)
          avg_b = (total_b / count).clamp(0, 255)
          avg_a = (total_a / count).clamp(0, 255)

          ChunkyPNG::Color.rgba(avg_r, avg_g, avg_b, avg_a)
        end

        def find_surface_block(block_types)
          priorities = [
            /Grass/,
            /Water/,
            /Sand/,
            /Snow/,
            /Ice/,
            /Dirt/,
            /Stone/,
            /Rock/,
          ]

          priorities.each do |pattern|
            match = block_types.find { |t| t =~ pattern }
            return match if match
          end

          block_types.find { |t| t !~ /^Env_|Empty/ } || block_types.first
        end

        def default_color(block_type)
          require "chunky_png"

          case block_type
          when /Grass/
            ChunkyPNG::Color.rgb(86, 125, 70)
          when /Water/
            ChunkyPNG::Color.rgba(64, 164, 223, 200)
          when /Sand/
            ChunkyPNG::Color.rgb(194, 178, 128)
          when /Snow/, /Ice/
            ChunkyPNG::Color.rgb(240, 240, 255)
          when /Dirt/
            ChunkyPNG::Color.rgb(139, 90, 43)
          when /Stone/, /Rock/
            ChunkyPNG::Color.rgb(128, 128, 128)
          when /Wood/
            ChunkyPNG::Color.rgb(139, 90, 43)
          when /Plant/
            ChunkyPNG::Color.rgb(34, 139, 34)
          when /Ore/
            ChunkyPNG::Color.rgb(70, 70, 80)
          when nil, /Empty/
            ChunkyPNG::Color::TRANSPARENT
          else
            ChunkyPNG::Color.rgb(100, 100, 100)
          end
        end
      end
    end
  end
end
