# frozen_string_literal: true

module Hytale
  module Client
    # Parses .prefab.json.lpf files containing prefab structure data
    #
    # File format:
    #   Header (21 bytes):
    #     - Palette offset (2 bytes, BE) = typically 21
    #     - Header value (2 bytes, BE) = typically 10
    #     - Reserved/dimensions (10 bytes)
    #     - Palette count (2 bytes, BE)
    #     - Reserved (5 bytes)
    #
    #   Block Palette:
    #     - N entries, each:
    #       - String length (1 byte)
    #       - Block name (N bytes)
    #       - Flags (2 bytes, BE)
    #       - Block ID (2 bytes, BE)
    #       - Extra data (1 byte)
    #
    #   Placement Data:
    #     - Block placement coordinates (format varies)
    #
    class Prefab
      HEADER_SIZE = 21

      attr_reader :path

      def initialize(path)
        @path = path
        @data = nil
        @header_parsed = false
        @palette = nil
      end

      def filename
        File.basename(path)
      end

      def name
        filename.sub(/\.prefab\.json\.lpf$/, "")
      end

      def size
        File.size(path)
      end

      def size_kb
        (size / 1024.0).round(2)
      end

      def modified_at
        File.mtime(path)
      end

      def palette_offset
        parse_header unless @header_parsed
        @palette_offset
      end

      def palette_count
        parse_header unless @header_parsed
        @palette_count
      end

      def palette
        @palette ||= parse_palette
      end

      def block_names
        palette.map(&:name)
      end

      def block_ids
        palette.map(&:block_id)
      end

      def block_by_id(id)
        palette.find { |entry| entry.block_id == id }
      end

      def block_by_name(name)
        palette.find { |entry| entry.name == name }
      end

      def category
        parts = path.split(File::SEPARATOR)
        prefabs_index = parts.index("Prefabs")

        return nil unless prefabs_index && parts.length > prefabs_index + 1

        parts[prefabs_index + 1]
      end

      def subcategory
        parts = path.split(File::SEPARATOR)
        prefabs_index = parts.index("Prefabs")

        return nil unless prefabs_index && parts.length > prefabs_index + 2

        parts[prefabs_index + 2]
      end

      def to_s
        "Prefab: #{name} (#{palette.size} block types, #{size_kb} KB)"
      end

      def to_h
        {
          name: name,
          path: path,
          size: size,
          category: category,
          palette: palette.map(&:to_h),
        }
      end

      class << self
        def load(path)
          raise NotFoundError, "Prefab not found: #{path}" unless File.exist?(path)

          new(path)
        end
      end

      private

      def data
        @data ||= File.binread(path)
      end

      def parse_header
        return if @header_parsed

        @palette_offset = data[0, 2].unpack1("n")
        # Bytes 2-3: header value (unused)
        # Bytes 4-13: reserved/dimension data
        @palette_count = data[14, 2].unpack1("n")

        @header_parsed = true
      end

      def parse_palette
        parse_header unless @header_parsed

        entries = []
        pos = @palette_offset

        @palette_count.times do |index|
          break if pos >= data.size

          str_len = data[pos].ord
          pos += 1

          break if pos + str_len + 5 > data.size

          name = data[pos, str_len]
          pos += str_len

          flags = data[pos, 2].unpack1("n")
          pos += 2

          block_id = data[pos, 2].unpack1("n")
          pos += 2

          extra = data[pos].ord
          pos += 1

          entries << PaletteEntry.new(
            index: index,
            name: name,
            flags: flags,
            block_id: block_id,
            extra: extra
          )
        end

        entries
      end
    end
  end
end
