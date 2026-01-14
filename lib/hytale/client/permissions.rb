# frozen_string_literal: true

module Hytale
  module Client
    class Permissions
      attr_reader :data, :path

      def initialize(data, path: nil)
        @data = data
        @path = path
      end

      def users
        data["users"] || {}
      end

      def groups
        data["groups"] || {}
      end

      def user_groups(uuid)
        users.dig(uuid, "groups") || []
      end

      def group_permissions(group_name)
        groups[group_name] || []
      end

      def user_permissions(uuid)
        user_groups(uuid).flat_map { |g| group_permissions(g) }.uniq
      end

      def op?(uuid)
        user_groups(uuid).include?("OP") || user_permissions(uuid).include?("*")
      end

      def to_h = data

      class << self
        def load(path)
          raise NotFoundError, "Permissions file not found: #{path}" unless File.exist?(path)

          json = File.read(path)
          data = JSON.parse(json)
          new(data, path: path)
        rescue JSON::ParserError => e
          raise ParseError, "Failed to parse permissions: #{e.message}"
        end
      end
    end
  end
end
