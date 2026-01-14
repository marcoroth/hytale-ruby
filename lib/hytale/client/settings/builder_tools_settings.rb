# frozen_string_literal: true

module Hytale
  module Client
    class Settings
      class BuilderToolsSettings
        attr_reader :data

        def initialize(data)
          @data = data
        end

        def tool_reach_distance = data["ToolReachDistance"]
        def brush_shape_rendering? = data["EnableBrushShapeRendering"]
        def brush_opacity = data["BrushOpacity"]
        def selection_opacity = data["SelectionOpacity"]
        def display_legend? = data["DisplayLegend"]
        def laser_pointer_color = data["LaserPointerColor"]
        def flight_inertia = data["FlightInertia"]
        def no_clip? = data["EnableNoClip"]
        def fullbright? = data["FullbrightEnabled"]

        def to_h = data
      end
    end
  end
end
