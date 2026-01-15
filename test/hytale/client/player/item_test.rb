# frozen_string_literal: true

require "test_helper"

class ItemTest < Minitest::Spec
  it "should return the item id" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Weapon_Sword_Copper" })

    assert_equal "Weapon_Sword_Copper", item.id
  end

  it "should return the item name" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Weapon_Sword_Copper" })

    assert_equal "Weapon Sword Copper", item.name
  end

  it "should return the item slot" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Weapon_Sword_Copper" }, slot: 5)

    assert_equal 5, item.slot
  end

  it "should return the quantity" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Food_Apple", "Quantity" => 10 })

    assert_equal 10, item.quantity
  end

  it "should return durability values" do
    item = Hytale::Client::Player::Item.new({
                                              "Id" => "Tool_Pickaxe_Copper",
                                              "Durability" => 75.0,
                                              "MaxDurability" => 100.0,
                                            })

    assert_equal 75.0, item.durability
    assert_equal 100.0, item.max_durability
  end

  it "should calculate durability percent" do
    item = Hytale::Client::Player::Item.new({
                                              "Id" => "Tool_Pickaxe_Copper",
                                              "Durability" => 75.0,
                                              "MaxDurability" => 100.0,
                                            })

    assert_equal 75.0, item.durability_percent
  end

  it "should round durability percent to one decimal" do
    item = Hytale::Client::Player::Item.new({
                                              "Id" => "Tool_Pickaxe_Copper",
                                              "Durability" => 33.33,
                                              "MaxDurability" => 100.0,
                                            })

    assert_equal 33.3, item.durability_percent
  end

  it "should return nil durability percent when no durability" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Food_Apple" })

    assert_nil item.durability_percent
  end

  it "should return nil durability percent when max is zero" do
    item = Hytale::Client::Player::Item.new({
                                              "Id" => "Tool_Pickaxe_Copper",
                                              "Durability" => 50.0,
                                              "MaxDurability" => 0.0,
                                            })

    assert_nil item.durability_percent
  end

  it "should be damaged when durability is less than max" do
    item = Hytale::Client::Player::Item.new({
                                              "Id" => "Tool_Pickaxe_Copper",
                                              "Durability" => 75.0,
                                              "MaxDurability" => 100.0,
                                            })

    assert item.damaged?
  end

  it "should not be damaged when durability equals max" do
    item = Hytale::Client::Player::Item.new({
                                              "Id" => "Tool_Pickaxe_Copper",
                                              "Durability" => 100.0,
                                              "MaxDurability" => 100.0,
                                            })

    refute item.damaged?
  end

  it "should not be damaged when item has no durability" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Food_Apple" })

    refute item.damaged?
  end

  it "should return the item type" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Weapon_Sword_Copper" })
    type = item.type

    assert_instance_of Hytale::Client::ItemType, type
    assert_equal "Weapon_Sword_Copper", type.id
  end

  it "should return the icon path" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Weapon_Sword_Copper" })
    path = item.icon_path

    assert path.include?("Icons")
    assert path.end_with?(".png")
  end

  it "should check if icon exists" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Weapon_Sword_Copper" })

    assert item.icon_exists?
  end

  it "should fall back to bow icon for shortbow" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Weapon_Shortbow_Copper" })

    return unless item.icon_exists?

    assert item.icon_path.include?("Bow")
  end

  it "should format to_s with just name for single items" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Weapon_Sword_Copper", "Quantity" => 1 })

    assert_equal "Weapon Sword Copper", item.to_s
  end

  it "should format to_s with quantity for stacked items" do
    item = Hytale::Client::Player::Item.new({ "Id" => "Food_Apple", "Quantity" => 10 })

    assert_equal "Food Apple x10", item.to_s
  end

  it "should format to_s with durability percent when damaged" do
    item = Hytale::Client::Player::Item.new({
                                              "Id" => "Tool_Pickaxe_Copper",
                                              "Quantity" => 1,
                                              "Durability" => 50.0,
                                              "MaxDurability" => 100.0,
                                            })

    assert_equal "Tool Pickaxe Copper (50.0%)", item.to_s
  end

  it "should not show durability in to_s when at full durability" do
    item = Hytale::Client::Player::Item.new({
                                              "Id" => "Tool_Pickaxe_Copper",
                                              "Quantity" => 1,
                                              "Durability" => 100.0,
                                              "MaxDurability" => 100.0,
                                            })

    assert_equal "Tool Pickaxe Copper", item.to_s
  end

  it "should convert to a hash" do
    data = { "Id" => "Weapon_Sword_Copper", "Quantity" => 1 }
    item = Hytale::Client::Player::Item.new(data)

    assert_equal data, item.to_h
  end
end
