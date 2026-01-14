# frozen_string_literal: true

module Hytale
  module Client
    class Player
      class ItemStorage
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def capacity = data["Capacity"]
        def type = data["Id"]

        def items
          (data["Items"] || {}).map do |slot, item_data|
            Item.new(item_data, slot: slot.to_i)
          end
        end

        def [](slot)
          item_data = data.dig("Items", slot.to_s)

          Item.new(item_data, slot: slot) if item_data
        end

        def to_h = data
      end
    end
  end
end
