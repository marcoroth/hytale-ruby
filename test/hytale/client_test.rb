# frozen_string_literal: true

require "test_helper"

class ClientTest < Minitest::Spec
  before do
    skip_unless_game_installed
  end

  it "should return all block types" do
    block_types = Hytale::Client.block_types

    assert block_types.any?
    assert(block_types.all? { |b| b.is_a?(Hytale::Client::BlockType) })
  end

  it "should find a block type by id" do
    block = Hytale::Client.block_type("Rock_Stone")

    assert_instance_of Hytale::Client::BlockType, block
    assert_equal "Rock_Stone", block.id
  end

  it "should return all block type categories" do
    categories = Hytale::Client.block_type_categories

    assert_instance_of Array, categories
    assert_includes categories, "Rock"
  end

  it "should return block types in a category" do
    blocks = Hytale::Client.block_types_in_category("Rock")

    assert blocks.any?
    assert(blocks.all? { |b| b.category == "Rock" })
  end

  it "should return all item types" do
    item_types = Hytale::Client.item_types

    assert item_types.any?
    assert(item_types.all? { |i| i.is_a?(Hytale::Client::ItemType) })
  end

  it "should find an item type by id" do
    item = Hytale::Client.item_type("Weapon_Sword_Copper")

    assert_instance_of Hytale::Client::ItemType, item
    assert_equal "Weapon_Sword_Copper", item.id
  end

  it "should return all item type categories" do
    categories = Hytale::Client.item_type_categories

    assert_instance_of Array, categories
    assert_includes categories, "Weapon"
  end

  it "should return all locales" do
    locales = Hytale::Client.locales

    assert locales.any?
    assert(locales.all? { |l| l.is_a?(Hytale::Client::Locale) })
  end

  it "should find a locale by code" do
    locale = Hytale::Client.locale("en-US")

    assert_instance_of Hytale::Client::Locale, locale
    assert_equal "en-US", locale.code
  end

  it "should default to en-US locale" do
    locale = Hytale::Client.locale

    assert_instance_of Hytale::Client::Locale, locale
    assert_equal "en-US", locale.code
  end

  it "should alias blocks to block_types" do
    assert_equal Hytale::Client.block_types, Hytale::Client.blocks
  end

  it "should alias block to block_type" do
    assert_equal Hytale::Client.block_type("Rock_Stone").id, Hytale::Client.block("Rock_Stone").id
  end

  it "should alias items to item_types" do
    assert_equal Hytale::Client.item_types, Hytale::Client.items
  end

  it "should alias item to item_type" do
    assert_equal Hytale::Client.item_type("Weapon_Sword_Copper").id, Hytale::Client.item("Weapon_Sword_Copper").id
  end
end
