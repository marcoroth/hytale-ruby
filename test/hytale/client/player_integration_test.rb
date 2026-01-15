# frozen_string_literal: true

require "test_helper"

class PlayerIntegrationTest < Minitest::Spec
  before do
    @player = fixture_player
  end

  it "should load player from fixture" do
    assert_instance_of Hytale::Client::Player, @player
  end

  it "should have uuid" do
    assert_equal "00000000-0000-0000-0000-000000000000", @player.uuid
  end

  it "should have correct name" do
    assert_equal "marcoroth", @player.name
  end

  it "should have position" do
    position = @player.position

    assert_instance_of Hytale::Client::Player::Position, position
    assert_in_delta(-897.02, position.x, 0.1)
    assert_in_delta 125.0, position.y, 0.1
    assert_in_delta 138.26, position.z, 0.1
  end

  it "should have rotation" do
    rotation = @player.rotation

    assert_instance_of Hytale::Client::Player::Rotation, rotation
    assert_in_delta 0.0, rotation.pitch, 0.1
    assert_in_delta(-8.36, rotation.yaw, 0.1)
    assert_in_delta 0.0, rotation.roll, 0.1
  end

  it "should have game mode" do
    assert_equal "Adventure", @player.game_mode
  end

  it "should have current world" do
    assert_equal "default", @player.current_world
  end

  it "should have discovered zones" do
    zones = @player.discovered_zones

    assert_instance_of Array, zones
    assert(zones.all? { |z| z.is_a?(Hytale::Client::Zone::Region) })
    assert_includes zones, "Zone1_Spawn"

    region = zones.first

    assert_equal "Zone1_Spawn", region.id
  end

  it "should have stats" do
    stats = @player.stats

    assert_instance_of Hytale::Client::Player::EntityStats, stats
    assert_equal 100.0, stats.health
    assert_equal 10.0, stats.stamina
    assert_equal 100.0, stats.oxygen
  end

  it "should have inventory" do
    inventory = @player.inventory

    assert_instance_of Hytale::Client::Player::Inventory, inventory
    assert_equal 4, inventory.version
    assert_equal 0, inventory.active_hotbar_slot
    assert_equal "Name", inventory.sort_type
  end

  it "should have storage with items" do
    storage = @player.inventory.storage

    assert_instance_of Hytale::Client::Player::ItemStorage, storage
    assert_equal 36, storage.capacity
    assert storage.simple?
    refute storage.empty?
    assert_equal 3, storage.items.count
  end

  it "should have hotbar with items" do
    hotbar = @player.inventory.hotbar

    assert_instance_of Hytale::Client::Player::ItemStorage, hotbar
    assert_equal 9, hotbar.capacity
    assert_equal 1, hotbar.items.count

    item = hotbar[0]

    assert_equal "Rubble_Stone", item.id
    assert_equal 3, item.quantity
  end

  it "should have empty backpack" do
    backpack = @player.inventory.backpack

    assert_instance_of Hytale::Client::Player::ItemStorage, backpack
    assert backpack.empty?
    refute backpack.simple?
    refute @player.inventory.backpack?
  end

  it "should have empty armor" do
    armor = @player.inventory.armor

    assert_instance_of Hytale::Client::Player::ItemStorage, armor
    assert_equal 4, armor.capacity
    assert_empty armor.items
  end

  it "should have tools with editor tools" do
    tools = @player.inventory.tools

    assert_instance_of Hytale::Client::Player::ItemStorage, tools
    assert_equal 23, tools.capacity
    assert_equal 6, tools.items.count

    tool_ids = tools.items.map(&:id)

    assert_includes tool_ids, "EditorTool_Paint"
    assert_includes tool_ids, "EditorTool_Sculpt"
    assert_includes tool_ids, "EditorTool_Selection"
  end

  it "should return all items across storages" do
    all_items = @player.inventory.all_items

    assert_instance_of Array, all_items
    assert_equal 10, all_items.count

    ids = all_items.map(&:id)

    assert_includes ids, "Rubble_Stone"
    assert_includes ids, "Plant_Moss_Green"
    assert_includes ids, "Ingredient_Fibre"
    assert_includes ids, "EditorTool_Paint"
  end

  it "should access specific storage items" do
    fibre = @player.inventory.storage[3]

    assert_instance_of Hytale::Client::Player::Item, fibre
    assert_equal "Ingredient_Fibre", fibre.id
    assert_equal 2, fibre.quantity
    assert_equal 3, fibre.slot
  end
end
