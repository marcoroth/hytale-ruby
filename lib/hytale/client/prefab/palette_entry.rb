# frozen_string_literal: true

module Hytale
  module Client
    class Prefab
      class PaletteEntry
        attr_reader :index, :name, :flags, :block_id, :extra

        def initialize(index:, name:, flags:, block_id:, extra:)
          @index = index
          @name = name
          @flags = flags
          @block_id = block_id
          @extra = extra
        end

        def state_definition?
          name.start_with?("*")
        end

        def base_name
          state_definition? ? name[1..] : name
        end

        def block_category
          parts = name.split("_")

          return parts[0] if parts.any?

          nil
        end

        def to_s
          "#{name} (ID: 0x#{format("%04X", block_id)})"
        end

        def to_h
          {
            index: index,
            name: name,
            flags: flags,
            block_id: block_id,
            extra: extra,
          }
        end
      end
    end
  end
end
