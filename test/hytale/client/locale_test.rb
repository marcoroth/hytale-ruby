# frozen_string_literal: true

require "test_helper"

class LocaleTest < Minitest::Spec
  before do
    skip_unless_game_installed
    Hytale::Client::Locale.reload!
  end

  it "should return available locales" do
    locales = Hytale::Client::Locale.available

    assert_includes locales, "en-US"
    assert_includes locales, "de-DE"
    assert_includes locales, "es-ES"
    assert_includes locales, "fr-FR"
    assert_includes locales, "pt-BR"
    assert_includes locales, "ru-RU"
  end

  it "should default to en-US" do
    assert_equal "en-US", Hytale::Client::Locale.default
  end

  it "should find a locale by code" do
    locale = Hytale::Client::Locale.find("en-US")

    assert_instance_of Hytale::Client::Locale, locale
    assert_equal "en-US", locale.code
    assert_equal "en", locale.language
    assert_equal "US", locale.region
  end

  it "should return nil for invalid locale" do
    locale = Hytale::Client::Locale.find("invalid")

    assert_nil locale
  end

  it "should return all locales as objects" do
    locales = Hytale::Client::Locale.all

    assert(locales.all? { |l| l.is_a?(Hytale::Client::Locale) })
    assert_equal Hytale::Client::Locale.available.count, locales.count
  end

  it "should return zone translations" do
    zones = Hytale::Client::Locale.zones

    assert_instance_of Hash, zones
    assert_equal "Emerald Wilds", zones["Emerald_Wilds"]
    assert_equal "Howling Sands", zones["Howling_Sands"]
  end

  it "should return region translations" do
    regions = Hytale::Client::Locale.regions

    assert_instance_of Hash, regions
    assert_equal "Drifting Plains", regions["Zone1_Tier1"]
    assert_equal "Seedling Woods", regions["Zone1_Tier2"]
    assert_equal "The Fens", regions["Zone1_Tier3"]
    assert_equal "Forgotten Temple", regions["ForgottenTemple"]
  end

  it "should translate zone names" do
    assert_equal "Emerald Wilds", Hytale::Client::Locale.zone_name("Emerald_Wilds")
    assert_nil Hytale::Client::Locale.zone_name("NonExistent")
  end

  it "should translate region names" do
    assert_equal "Drifting Plains", Hytale::Client::Locale.region_name("Zone1_Tier1")
    assert_nil Hytale::Client::Locale.region_name("NonExistent")
  end

  it "should translate item names" do
    name = Hytale::Client::Locale.item_name("Weapon_Sword_Copper")

    assert_equal "Copper Sword", name
  end

  it "should fall back to English for missing translations" do
    result = Hytale::Client::Locale.t("map.region.Zone1_Tier1", locale: "de-DE", fallback: true)

    assert_equal "Drifting Plains", result
  end

  it "should return nil without fallback for missing translations" do
    result = Hytale::Client::Locale.t("map.region.Zone1_Tier1", locale: "de-DE", fallback: false)

    assert_nil result
  end

  it "should search translations by pattern" do
    results = Hytale::Client::Locale.search(/^map\.region\./)

    assert(results.keys.all? { |k| k.start_with?("map.region.") })
    assert results.key?("map.region.Zone1_Tier1")
  end

  it "should provide instance methods for translations" do
    locale = Hytale::Client::Locale.find("en-US")

    assert_equal "Drifting Plains", locale.region_name("Zone1_Tier1")
    assert_equal "Emerald Wilds", locale.zone_name("Emerald_Wilds")
    assert_equal "Copper Sword", locale.item_name("Weapon_Sword_Copper")
  end

  it "should format to_s as the locale code" do
    locale = Hytale::Client::Locale.find("en-US")

    assert_equal "en-US", locale.to_s
  end

  it "should format inspect with locale code" do
    locale = Hytale::Client::Locale.find("en-US")

    assert_equal '#<Hytale::Client::Locale code="en-US">', locale.inspect
  end
end
