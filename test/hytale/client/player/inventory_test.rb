# frozen_string_literal: true

require "test_helper"

class InventoryTest < Minitest::Spec
  def sample_inventory_data
    {
      "Version" => 2,
      "ActiveHotbarSlot" => 3,
      "SortType" => "Name",
      "HotBar" => {
        "Id" => "HotBar",
        "Capacity" => 10,
        "Items" => {
          "0" => { "Id" => "Tool_Pickaxe_Copper", "Quantity" => 1 },
          "1" => { "Id" => "Weapon_Sword_Copper", "Quantity" => 1 },
          "3" => { "Id" => "Food_Apple", "Quantity" => 5 },
        },
      },
      "Storage" => {
        "Id" => "Storage",
        "Capacity" => 30,
        "Items" => {
          "0" => { "Id" => "Ingredient_Bar_Copper", "Quantity" => 10 },
          "5" => { "Id" => "Rock_Stone", "Quantity" => 64 },
        },
      },
      "Armor" => {
        "Id" => "Armor",
        "Capacity" => 4,
        "Items" => {
          "0" => { "Id" => "Armor_Copper_Head", "Quantity" => 1 },
          "2" => { "Id" => "Armor_Copper_Chest", "Quantity" => 1 },
        },
      },
      "Utility" => {
        "Id" => "Utility",
        "Capacity" => 4,
        "Items" => {},
      },
      "Tool" => {
        "Id" => "Tool",
        "Capacity" => 6,
        "Items" => {
          "0" => { "Id" => "EditorTool_Paint", "Quantity" => 1 },
        },
      },
    }
  end

  before do
    @inventory = Hytale::Client::Player::Inventory.new(sample_inventory_data)
  end

  it "should return the inventory version" do
    assert_equal 2, @inventory.version
  end

  it "should return the active hotbar slot" do
    assert_equal 3, @inventory.active_hotbar_slot
  end

  it "should return the sort type" do
    assert_equal "Name", @inventory.sort_type
  end

  it "should return the hotbar storage" do
    hotbar = @inventory.hotbar

    assert_instance_of Hytale::Client::Player::ItemStorage, hotbar
    assert_equal 10, hotbar.capacity
    assert_equal 3, hotbar.items.count
  end

  it "should return the main storage" do
    storage = @inventory.storage

    assert_instance_of Hytale::Client::Player::ItemStorage, storage
    assert_equal 30, storage.capacity
    assert_equal 2, storage.items.count
  end

  it "should return the armor storage" do
    armor = @inventory.armor

    assert_instance_of Hytale::Client::Player::ItemStorage, armor
    assert_equal 4, armor.capacity
    assert_equal 2, armor.items.count
  end

  it "should return the utility storage" do
    utility = @inventory.utility

    assert_instance_of Hytale::Client::Player::ItemStorage, utility
    assert_equal 4, utility.capacity
    assert_empty utility.items
  end

  it "should return the tools storage" do
    tools = @inventory.tools

    assert_instance_of Hytale::Client::Player::ItemStorage, tools
    assert_equal 6, tools.capacity
    assert_equal 1, tools.items.count
  end

  it "should return all items from all storages" do
    all = @inventory.all_items

    assert_instance_of Array, all
    assert_equal 8, all.count
    assert(all.all? { |i| i.is_a?(Hytale::Client::Player::Item) })
  end

  it "should include items from hotbar, storage, armor and tools" do
    all = @inventory.all_items
    ids = all.map(&:id)

    assert_includes ids, "Tool_Pickaxe_Copper"
    assert_includes ids, "Ingredient_Bar_Copper"
    assert_includes ids, "Armor_Copper_Head"
    assert_includes ids, "EditorTool_Paint"
  end

  it "should convert to a hash" do
    hash = @inventory.to_h

    assert_equal sample_inventory_data, hash
  end

  it "should handle empty inventory data" do
    empty = Hytale::Client::Player::Inventory.new({})

    assert_nil empty.version
    assert_nil empty.active_hotbar_slot
    assert_empty empty.all_items
  end
end
