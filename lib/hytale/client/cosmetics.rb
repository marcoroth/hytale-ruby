# frozen_string_literal: true

module Hytale
  module Client
    class Cosmetics
      CATALOG_PATH = "Cosmetics/CharacterCreator"

      CATALOG_FILES = {
        body_characteristics: "BodyCharacteristics.json",
        capes: "Capes.json",
        ear_accessories: "EarAccessory.json",
        ears: "Ears.json",
        eyebrows: "Eyebrows.json",
        eyes: "Eyes.json",
        face_accessories: "FaceAccessory.json",
        faces: "Faces.json",
        facial_hair: "FacialHair.json",
        gloves: "Gloves.json",
        haircuts: "Haircuts.json",
        head_accessories: "HeadAccessory.json",
        mouths: "Mouths.json",
        overpants: "Overpants.json",
        overtops: "Overtops.json",
        pants: "Pants.json",
        shoes: "Shoes.json",
        skin_features: "SkinFeatures.json",
        undertops: "Undertops.json",
        underwear: "Underwear.json",
      }.freeze

      class << self
        def catalog(type)
          @catalogs ||= {}
          @catalogs[type] ||= load_catalog(type)
        end

        # Handle format like "VikinManBun.BrownDark" - split off the color variant
        def find(type, id)
          base_id = id.to_s.split(".").first

          catalog(type)&.find { |item| item["Id"] == base_id }
        end

        def texture_path(type, id)
          item = find(type, id)
          return nil unless item

          variant_name = variant(id)

          if variant_name && item["Textures"]
            variant_data = item["Textures"][variant_name]

            return Assets.cached_path("Common/#{variant_data["Texture"]}") if variant_data && variant_data["Texture"]
          end

          texture = item["GreyscaleTexture"] || item["Texture"]

          return nil unless texture

          Assets.cached_path("Common/#{texture}")
        end

        def model_path(type, id)
          item = find(type, id)
          return nil unless item

          model = item["Model"]
          return nil unless model

          Assets.cached_path("Common/#{model}")
        end

        def variant(id)
          parts = id.to_s.split(".")

          parts.length > 1 ? parts[1..].join(".") : nil
        end

        private

        def load_catalog(type)
          filename = CATALOG_FILES[type]
          return nil unless filename

          path = Assets.cached_path("#{CATALOG_PATH}/#{filename}")
          return nil unless File.exist?(path)

          JSON.parse(File.read(path))
        rescue JSON::ParserError
          nil
        end
      end
    end
  end
end
