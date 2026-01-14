# frozen_string_literal: true

module Hytale
  module Client
    class Player
      class EntityStats
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def version = data["Version"]

        def health
          stat("Health")
        end

        def max_health
          base = health || 0
          modifier = stat_modifier("Health", "Armor_ADDITIVE") || 0

          base + modifier
        end

        def stamina = stat("Stamina")
        def oxygen = stat("Oxygen")
        def mana = stat("Mana")

        def stat(name)
          data.dig("Stats", name, "Value")
        end

        def stat_modifier(stat_name, modifier_name)
          data.dig("Stats", stat_name, "Modifiers", modifier_name, "Amount")
        end

        def all_stats
          (data["Stats"] || {}).transform_values { |v| v["Value"] }
        end

        def to_h = data
      end
    end
  end
end
