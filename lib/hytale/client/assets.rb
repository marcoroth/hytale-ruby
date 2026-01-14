# frozen_string_literal: true

module Hytale
  module Client
    class Assets
      BLOCK_TEXTURES_PATH = "Common/BlockTextures"
      ITEM_ICONS_PATH = "Common/Icons/ItemsGenerated"

      class << self
        def cache_path
          Config.assets_cache_path
        end

        def zip_path
          Config.assets_path
        end

        def ensure_extracted!
          return if @extracted
          return unless zip_path

          extract_all unless File.directory?(cache_path) && count.positive?

          @extracted = true
        end

        def cached?(path)
          ensure_extracted!

          File.exist?(cached_path(path))
        end

        def cached_path(path)
          File.expand_path(path, cache_path)
        end

        def read(path)
          full_path = cached_path(path)
          return File.binread(full_path) if File.exist?(full_path)

          nil
        end

        def extract_all
          return 0 unless zip_path

          require_zip!

          count = 0

          Zip::File.open(zip_path) do |zip|
            zip.entries.each do |entry|
              next if entry.directory?

              output_path = cached_path(entry.name)

              next if File.exist?(output_path)

              FileUtils.mkdir_p(File.dirname(output_path))
              File.binwrite(output_path, entry.get_input_stream.read)

              count += 1
            end
          end

          count
        end

        def extract(path)
          return false unless zip_path

          require_zip!

          output_path = cached_path(path)
          return true if File.exist?(output_path)

          Zip::File.open(zip_path) do |zip|
            entry = zip.find_entry(path)
            return false unless entry

            FileUtils.mkdir_p(File.dirname(output_path))
            File.binwrite(output_path, entry.get_input_stream.read)
          end

          true
        rescue Zip::Error
          false
        end

        def extract_directory(dir_path)
          return 0 unless zip_path

          require_zip!

          count = 0
          prefix = dir_path.end_with?("/") ? dir_path : "#{dir_path}/"

          Zip::File.open(zip_path) do |zip|
            zip.entries.each do |entry|
              next if entry.directory?
              next unless entry.name.start_with?(prefix)

              output_path = cached_path(entry.name)
              next if File.exist?(output_path)

              FileUtils.mkdir_p(File.dirname(output_path))
              File.binwrite(output_path, entry.get_input_stream.read)

              count += 1
            end
          end

          count
        end

        def list(dir_path = nil)
          return [] unless zip_path

          require_zip!

          prefix = if dir_path
                     dir_path.end_with?("/") ? dir_path : "#{dir_path}/"
                   end

          Zip::File.open(zip_path) do |zip|
            entries = zip.entries.reject(&:directory?)
            entries = entries.select { |e| e.name.start_with?(prefix) } if prefix

            entries.map(&:name).sort
          end
        rescue Zip::Error
          []
        end

        def directories
          return [] unless zip_path

          require_zip!

          Zip::File.open(zip_path) do |zip|
            zip.entries
               .map { |e| e.name.split("/").first(2).join("/") }
               .uniq
               .reject { |d| d.include?(".") }
               .sort
          end
        rescue Zip::Error
          []
        end

        def clear!
          FileUtils.rm_rf(cache_path)
        end

        def count
          return 0 unless File.directory?(cache_path)

          Dir.glob(File.join(cache_path, "**", "*")).count { |f| File.file?(f) }
        end

        def block_textures
          list(BLOCK_TEXTURES_PATH)
            .reject { |p| p.include?("/_") }
            .map { |p| File.basename(p, ".png") }
        end

        def extract_block_textures
          extract_directory(BLOCK_TEXTURES_PATH)
        end

        def block_texture_path(name)
          name = "#{name}.png" unless name.end_with?(".png")

          cached_path("#{BLOCK_TEXTURES_PATH}/#{name}")
        end

        def item_icons
          list(ITEM_ICONS_PATH).map { |p| File.basename(p, ".png") }
        end

        def extract_item_icons
          extract_directory(ITEM_ICONS_PATH)
        end

        def item_icon_path(name)
          name = "#{name}.png" unless name.end_with?(".png")

          cached_path("#{ITEM_ICONS_PATH}/#{name}")
        end

        def item_icon_exists?(name)
          ensure_extracted!

          File.exist?(item_icon_path(name))
        end

        private

        def require_zip!
          require "zip"
        rescue LoadError
          raise Error, "rubyzip gem required for asset extraction: gem install rubyzip"
        end
      end
    end
  end
end
