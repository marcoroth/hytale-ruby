# frozen_string_literal: true

module Hytale
  module Client
    module Zone
      class Region
        class << self
          def all
            Locale.regions.keys.map { |id| new(id) }
          end

          def find(id)
            new(id) if Locale.region_name(id)
          end
        end

        attr_reader :id

        def initialize(id)
          @id = id
        end

        def name
          Locale.region_name(id) || id
        end

        def zone
          zone_id = REGION_PREFIX_TO_ZONE.find { |prefix, _| id.start_with?(prefix) }&.last

          Zone.new(zone_id) if zone_id
        end

        def to_s = name
        def inspect = "#<Zone::Region id=#{id.inspect} name=#{name.inspect}>"

        def ==(other)
          case other
          when Region then id == other.id
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
