# frozen_string_literal: true

module Hytale
  module Client
    class Player
      class Inventory
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def version = data["Version"]

        def storage
          @storage ||= ItemStorage.new(data["Storage"] || {})
        end

        def backpack
          @backpack ||= ItemStorage.new(data["Backpack"] || {})
        end

        def hotbar
          @hotbar ||= ItemStorage.new(data["HotBar"] || {})
        end

        def armor
          @armor ||= ItemStorage.new(data["Armor"] || {})
        end

        def utility
          @utility ||= ItemStorage.new(data["Utility"] || {})
        end

        def tools
          @tools ||= ItemStorage.new(data["Tool"] || {})
        end

        def active_hotbar_slot = data["ActiveHotbarSlot"]
        def sort_type = data["SortType"]

        def backpack?
          backpack&.simple?
        end

        def all_items
          [storage, backpack, hotbar, armor, utility, tools].flat_map(&:items)
        end

        def to_h = data
      end
    end
  end
end
