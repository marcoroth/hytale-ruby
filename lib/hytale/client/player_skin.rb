# frozen_string_literal: true

module Hytale
  module Client
    class PlayerSkin
      attr_reader :data, :uuid, :path

      def initialize(data, uuid: nil, path: nil)
        @data = data
        @uuid = uuid
        @path = path
      end

      def body_characteristic = data["bodyCharacteristic"]
      def underwear = data["underwear"]
      def face = data["face"]
      def ears = data["ears"]
      def mouth = data["mouth"]
      def haircut = data["haircut"]
      def facial_hair = data["facialHair"]
      def eyebrows = data["eyebrows"]
      def eyes = data["eyes"]
      def pants = data["pants"]
      def overpants = data["overpants"]
      def undertop = data["undertop"]
      def overtop = data["overtop"]
      def shoes = data["shoes"]
      def head_accessory = data["headAccessory"]
      def face_accessory = data["faceAccessory"]
      def ear_accessory = data["earAccessory"]
      def skin_feature = data["skinFeature"]
      def gloves = data["gloves"]
      def cape = data["cape"]

      def equipped_items
        data.reject { |_, v| v.nil? }
      end

      def empty_slots
        data.select { |_, v| v.nil? }.keys
      end

      def avatar_preview_path
        return nil unless uuid

        path = File.join(Config.avatar_previews_path, "#{uuid}.png")
        File.exist?(path) ? path : nil
      end

      def avatar_preview_data
        path = avatar_preview_path
        return nil unless path

        File.binread(path)
      end

      def haircut_texture_path
        Cosmetics.texture_path(:haircuts, haircut)
      end

      def facial_hair_texture_path
        Cosmetics.texture_path(:facial_hair, facial_hair)
      end

      def eyebrows_texture_path
        Cosmetics.texture_path(:eyebrows, eyebrows)
      end

      def eyes_texture_path
        Cosmetics.texture_path(:eyes, eyes)
      end

      def face_texture_path
        Cosmetics.texture_path(:faces, face)
      end

      def pants_texture_path
        Cosmetics.texture_path(:pants, pants)
      end

      def overpants_texture_path
        Cosmetics.texture_path(:overpants, overpants)
      end

      def undertop_texture_path
        Cosmetics.texture_path(:undertops, undertop)
      end

      def overtop_texture_path
        Cosmetics.texture_path(:overtops, overtop)
      end

      def shoes_texture_path
        Cosmetics.texture_path(:shoes, shoes)
      end

      def gloves_texture_path
        Cosmetics.texture_path(:gloves, gloves)
      end

      def cape_texture_path
        Cosmetics.texture_path(:capes, cape)
      end

      def head_accessory_texture_path
        Cosmetics.texture_path(:head_accessories, head_accessory)
      end

      def face_accessory_texture_path
        Cosmetics.texture_path(:face_accessories, face_accessory)
      end

      def ear_accessory_texture_path
        Cosmetics.texture_path(:ear_accessories, ear_accessory)
      end

      def texture_paths
        {
          haircut: haircut_texture_path,
          facial_hair: facial_hair_texture_path,
          eyebrows: eyebrows_texture_path,
          eyes: eyes_texture_path,
          face: face_texture_path,
          pants: pants_texture_path,
          overpants: overpants_texture_path,
          undertop: undertop_texture_path,
          overtop: overtop_texture_path,
          shoes: shoes_texture_path,
          gloves: gloves_texture_path,
          cape: cape_texture_path,
          head_accessory: head_accessory_texture_path,
          face_accessory: face_accessory_texture_path,
          ear_accessory: ear_accessory_texture_path
        }.compact
      end

      def to_s
        "PlayerSkin: #{uuid || 'unknown'}"
      end

      def to_h
        data
      end

      class << self
        def load(path)
          raise NotFoundError, "Player skin not found: #{path}" unless File.exist?(path)

          json = File.read(path)
          data = JSON.parse(json)
          uuid = File.basename(path, ".json")

          new(data, uuid: uuid, path: path)
        rescue JSON::ParserError => e
          raise ParseError, "Failed to parse player skin: #{e.message}"
        end

        def all
          skins_path = Config.player_skins_path
          return [] unless skins_path && File.directory?(skins_path)

          Dir.glob(File.join(skins_path, "*.json")).map do |path|
            load(path)
          end
        end

        def find(uuid)
          skins_path = Config.player_skins_path
          return nil unless skins_path

          path = File.join(skins_path, "#{uuid}.json")
          return nil unless File.exist?(path)

          load(path)
        end
      end
    end
  end
end
