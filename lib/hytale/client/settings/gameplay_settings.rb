# frozen_string_literal: true

module Hytale
  module Client
    class Settings
      class GameplaySettings
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def camera_based_flying? = data["CameraBasedFlying"]
        def camera_based_climbing? = data["CameraBasedClimbing"]
        def auto_jump_obstacle? = data["AutoJumpObstacle"]
        def utility_quick_swap? = data["EnableUtilityQuickSwap"]
        def arachnophobia_mode? = data["EnableArachnophobiaMode"]

        def to_h = data
      end
    end
  end
end
