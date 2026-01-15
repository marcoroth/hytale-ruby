# frozen_string_literal: true

module Hytale
  module Client
    module Zone
      ZONE_TO_REGION_PREFIX = {
        "Emerald_Wilds" => "Zone1",
        "Howling_Sands" => "Zone2",
        "Whisperfrost_Frontiers" => "Zone3",
        "Devastated_Lands" => "Zone4",
        "Oceans" => "Oceans",
      }.freeze

      REGION_PREFIX_TO_ZONE = ZONE_TO_REGION_PREFIX.invert.freeze

      class << self
        def all
          Locale.zones.keys.map { |id| new(id) }
        end

        def find(id)
          new(id) if Locale.zone_name(id)
        end

        def new(id)
          Zone::Base.new(id)
        end
      end

      class Base
        attr_reader :id

        def initialize(id)
          @id = id
        end

        def name
          Locale.zone_name(id) || id
        end

        def regions
          prefix = ZONE_TO_REGION_PREFIX[id]

          return [] unless prefix

          Region.all.select { |region| region.id.start_with?(prefix) }
        end

        def to_s = name
        def inspect = "#<Zone id=#{id.inspect} name=#{name.inspect}>"

        def ==(other)
          case other
          when Base then id == other.id
          when String then id == other
          else false
          end
        end

        alias eql? ==

        def hash
          id.hash
        end
      end
    end
  end
end
