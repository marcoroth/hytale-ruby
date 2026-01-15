# frozen_string_literal: true

require "test_helper"

class ItemTypeTest < Minitest::Spec
  before do
    skip_unless_game_installed
    Hytale::Client::ItemType.reload!
  end

  it "should return all item types" do
    all = Hytale::Client::ItemType.all

    assert all.any?
    assert(all.all? { |i| i.is_a?(Hytale::Client::ItemType) })
  end

  it "should return the item type count" do
    count = Hytale::Client::ItemType.count

    assert count.positive?
    assert_equal Hytale::Client::ItemType.all.count, count
  end

  it "should find an existing item by id" do
    item = Hytale::Client::ItemType.find("Weapon_Sword_Copper")

    assert_instance_of Hytale::Client::ItemType, item
    assert_equal "Weapon_Sword_Copper", item.id
  end

  it "should return nil for nonexistent item" do
    item = Hytale::Client::ItemType.find("NonExistent_Item")

    assert_nil item
  end

  it "should filter items by category" do
    weapons = Hytale::Client::ItemType.where(category: "Weapon")

    assert weapons.any?
    assert(weapons.all? { |i| i.category == "Weapon" })
  end

  it "should filter items by quality" do
    items = Hytale::Client::ItemType.where(quality: "Common")

    assert items.any?
    assert(items.all? { |i| i.quality == "Common" })
  end

  it "should filter items by multiple attributes" do
    items = Hytale::Client::ItemType.where(category: "Weapon", quality: "Common")

    assert(items.all? { |i| i.category == "Weapon" && i.quality == "Common" })
  end

  it "should return all categories" do
    categories = Hytale::Client::ItemType.categories

    assert_instance_of Array, categories
    assert_includes categories, "Weapon"
    assert_includes categories, "Armor"
    assert_includes categories, "Tool"
  end

  it "should return all qualities" do
    qualities = Hytale::Client::ItemType.qualities

    assert_instance_of Array, qualities
    assert_includes qualities, "Common"
  end

  it "should return the item id" do
    item = Hytale::Client::ItemType.new("Weapon_Sword_Copper")

    assert_equal "Weapon_Sword_Copper", item.id
  end

  it "should return the localized name" do
    item = Hytale::Client::ItemType.find("Weapon_Sword_Copper")

    assert_equal "Copper Sword", item.name if item
  end

  it "should support locale parameter for name" do
    item = Hytale::Client::ItemType.find("Weapon_Sword_Copper")

    assert_equal "Copper Sword", item.name(locale: "de-DE") if item
  end

  it "should fall back to formatted id for unknown items" do
    item = Hytale::Client::ItemType.new("Unknown_Item_Type")

    assert_equal "Unknown Item Type", item.name
  end

  it "should extract the category from id" do
    item = Hytale::Client::ItemType.new("Weapon_Sword_Copper")

    assert_equal "Weapon", item.category
  end

  it "should extract the subcategory from id" do
    item = Hytale::Client::ItemType.new("Weapon_Sword_Copper")

    assert_equal "Sword", item.subcategory
  end

  it "should return the quality" do
    item = Hytale::Client::ItemType.find("Weapon_Sword_Copper")

    assert_equal "Common", item.quality if item
  end

  it "should return the item level" do
    item = Hytale::Client::ItemType.find("Weapon_Sword_Copper")

    assert item.item_level.is_a?(Integer) if item&.item_level
  end

  it "should return max durability" do
    item = Hytale::Client::ItemType.find("Weapon_Sword_Copper")

    assert item.max_durability.is_a?(Integer) if item&.max_durability
  end

  it "should return recipe inputs" do
    item = Hytale::Client::ItemType.find("Weapon_Sword_Copper")

    return unless item&.recipe

    inputs = item.recipe_inputs

    assert_instance_of Array, inputs
  end

  it "should return the icon path" do
    item = Hytale::Client::ItemType.find("Weapon_Sword_Copper")

    return unless item

    path = item.icon_path

    assert path.include?("Icons")
    assert path.end_with?(".png")
  end

  it "should check if icon exists" do
    item = Hytale::Client::ItemType.find("Weapon_Sword_Copper")

    assert item.icon_exists? if item
  end

  it "should fall back to bow icon for shortbow" do
    item = Hytale::Client::ItemType.new("Weapon_Shortbow_Copper")

    return unless item.icon_exists?

    assert item.icon_path.include?("Bow")
  end

  it "should include class name in to_s" do
    item = Hytale::Client::ItemType.new("Weapon_Sword_Copper")

    assert item.to_s.include?("ItemType")
  end

  it "should include class and id in inspect" do
    item = Hytale::Client::ItemType.new("Weapon_Sword_Copper")

    assert item.inspect.include?("Hytale::Client::ItemType")
    assert item.inspect.include?("Weapon_Sword_Copper")
  end

  it "should convert to a hash" do
    item = Hytale::Client::ItemType.find("Weapon_Sword_Copper")

    return unless item

    hash = item.to_h

    assert_equal "Weapon_Sword_Copper", hash[:id]
    assert_equal "Weapon", hash[:category]
    assert hash.key?(:name)
    assert hash.key?(:quality)
  end

  it "should compare items by id" do
    item1 = Hytale::Client::ItemType.new("Weapon_Sword_Copper")
    item2 = Hytale::Client::ItemType.new("Weapon_Sword_Copper")
    item3 = Hytale::Client::ItemType.new("Tool_Pickaxe_Copper")

    assert_equal item1, item2
    refute_equal item1, item3
  end

  it "should have equal hash codes for equal items" do
    item1 = Hytale::Client::ItemType.new("Weapon_Sword_Copper")
    item2 = Hytale::Client::ItemType.new("Weapon_Sword_Copper")

    assert_equal item1.hash, item2.hash
  end
end
