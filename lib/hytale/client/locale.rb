# frozen_string_literal: true

module Hytale
  module Client
    # Provides localized strings from game language files
    # Supports all available game languages
    class Locale
      DEFAULT_LOCALE = "en-US"

      attr_reader :code, :language, :region

      def initialize(code)
        @code = code
        @language, @region = code.split("-")
      end

      def translations
        self.class.translations(code)
      end

      def t(key, fallback: true)
        self.class.t(key, locale: code, fallback: fallback)
      end

      alias translate t

      def zone_name(zone_id)
        self.class.zone_name(zone_id, locale: code)
      end

      def region_name(region_id)
        self.class.region_name(region_id, locale: code)
      end

      def item_name(item_id)
        self.class.item_name(item_id, locale: code)
      end

      def item_description(item_id)
        self.class.item_description(item_id, locale: code)
      end

      def zones
        self.class.zones(locale: code)
      end

      def regions
        self.class.regions(locale: code)
      end

      def to_s
        code
      end

      def inspect
        "#<Hytale::Client::Locale code=#{code.inspect}>"
      end

      class << self
        def available
          @available ||= detect_available_locales
        end

        def default
          DEFAULT_LOCALE
        end

        def find(code)
          return nil unless available.include?(code)

          new(code)
        end

        def all
          available.map { |code| new(code) }
        end

        # Get a translation by key
        # @param key [String] The translation key (e.g., "map.region.Zone1_Tier1")
        # @param locale [String] The locale to use (default: en-US)
        # @param fallback [Boolean] If true, fall back to English when translation missing
        # @return [String, nil] The translated string or nil if not found
        def t(key, locale: DEFAULT_LOCALE, fallback: true)
          result = translations(locale)[key]

          # Fall back to English if translation missing and fallback enabled
          if result.nil? && fallback && locale != DEFAULT_LOCALE
            result = translations(DEFAULT_LOCALE)[key]
          end

          result
        end

        alias translate t

        # Get all translations for a locale
        # @param locale [String] The locale (default: en-US)
        # @return [Hash] Key-value hash of all translations
        def translations(locale = DEFAULT_LOCALE)
          @translations ||= {}
          @translations[locale] ||= load_translations(locale)
        end

        # Get zone display name
        # @param zone_id [String] The zone ID (e.g., "Emerald_Wilds")
        # @param locale [String] The locale (default: en-US)
        def zone_name(zone_id, locale: DEFAULT_LOCALE)
          t("map.zone.#{zone_id}", locale: locale)
        end

        # Get region display name
        # @param region_id [String] The region ID (e.g., "Zone1_Tier1")
        # @param locale [String] The locale (default: en-US)
        def region_name(region_id, locale: DEFAULT_LOCALE)
          t("map.region.#{region_id}", locale: locale)
        end

        # Get item display name
        # @param item_id [String] The item ID (e.g., "Weapon_Sword_Copper")
        # @param locale [String] The locale (default: en-US)
        def item_name(item_id, locale: DEFAULT_LOCALE)
          t("items.#{item_id}.name", locale: locale)
        end

        # Get item description
        # @param item_id [String] The item ID
        # @param locale [String] The locale (default: en-US)
        def item_description(item_id, locale: DEFAULT_LOCALE)
          t("items.#{item_id}.description", locale: locale)
        end

        # Get all zone names
        # @param locale [String] The locale (default: en-US)
        # @return [Hash] zone_id => display_name
        def zones(locale: DEFAULT_LOCALE)
          prefix = "map.zone."
          translations(locale)
            .select { |k, _| k.start_with?(prefix) }
            .transform_keys { |k| k.delete_prefix(prefix) }
        end

        # Get all region names
        # @param locale [String] The locale (default: en-US)
        # @return [Hash] region_id => display_name
        def regions(locale: DEFAULT_LOCALE)
          prefix = "map.region."
          translations(locale)
            .select { |k, _| k.start_with?(prefix) }
            .transform_keys { |k| k.delete_prefix(prefix) }
        end

        # Search translations by key pattern
        # @param pattern [Regexp, String] Pattern to match against keys
        # @param locale [String] The locale (default: en-US)
        # @return [Hash] Matching key-value pairs
        def search(pattern, locale: DEFAULT_LOCALE)
          pattern = Regexp.new(pattern) if pattern.is_a?(String)
          translations(locale).select { |k, _| k.match?(pattern) }
        end

        # Clear cached translations and available locales
        def reload!
          @translations = nil
          @available = nil
        end

        private

        def detect_available_locales
          Assets.list("Server/Languages")
            .map { |f| f.split("/")[2] }
            .uniq
            .reject { |l| l.nil? || l.end_with?(".lang") }
            .sort
        end

        def load_translations(locale)
          result = {}

          server_lang = load_lang_file("Server/Languages/#{locale}/server.lang")
          result.merge!(server_lang) if server_lang

          result
        end

        def load_lang_file(path)
          return nil unless Assets.extract(path)

          full_path = Assets.cached_path(path)

          return nil unless File.exist?(full_path)

          parse_lang_file(File.read(full_path))
        rescue StandardError
          nil
        end

        def parse_lang_file(content)
          result = {}
          current_key = nil
          current_value = []
          in_multiline = false

          content.each_line do |line|
            line = line.chomp

            if in_multiline
              if line.end_with?("\\")
                current_value << line[0..-2]
              else
                current_value << line
                result[current_key] = current_value.join("\n")
                in_multiline = false
                current_key = nil
                current_value = []
              end
            elsif line =~ /^([a-zA-Z0-9_.]+)\s*=\s*(.*)$/
              key = $1
              value = $2

              if value.end_with?("\\")
                current_key = key
                current_value = [value[0..-2]]
                in_multiline = true
              else
                result[key] = value
              end
            end
          end

          result
        end
      end
    end
  end
end
