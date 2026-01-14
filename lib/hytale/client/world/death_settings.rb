# frozen_string_literal: true

module Hytale
  module Client
    class World
      class DeathSettings
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def respawn_controller = data.dig("RespawnController", "Type")
        def items_loss_mode = data["ItemsLossMode"]
        def items_loss_percentage = data["ItemsAmountLossPercentage"]
        def durability_loss_percentage = data["ItemsDurabilityLossPercentage"]

        def to_h = data
      end
    end
  end
end
