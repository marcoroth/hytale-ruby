# frozen_string_literal: true

require "test_helper"

class PlayerRightAfterSpawnTest < Minitest::Spec
  before do
    @player = load_player_fixture("right-after-spawn")
  end

  it "should load player from fixture" do
    assert_instance_of Hytale::Client::Player, @player
  end

  it "should have correct name" do
    assert_equal "Player right after spawn", @player.name
  end

  it "should have adventure game mode" do
    assert_equal "Adventure", @player.game_mode
  end

  it "should have default world" do
    assert_equal "default", @player.current_world
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

  it "should not be flying" do
    refute @player.flying?
  end

  it "should not be first spawn" do
    refute @player.first_spawn?
  end

  it "should have only spawn zone discovered" do
    zones = @player.discovered_zones

    assert_equal 1, zones.count
    assert_includes zones, "Zone1_Spawn"
  end

  it "should have spawn zone from Emerald Wilds" do
    zone = @player.discovered_zones.first

    assert_equal "Emerald_Wilds", zone.zone&.id
  end

  it "should have no backpack equipped" do
    refute @player.inventory.backpack?
  end

  it "should have empty backpack" do
    backpack = @player.inventory.backpack

    assert backpack.empty?
    refute backpack.simple?
  end

  it "should have inventory with correct version" do
    inventory = @player.inventory

    assert_instance_of Hytale::Client::Player::Inventory, inventory
    assert_equal 4, inventory.version
    assert_equal 0, inventory.active_hotbar_slot
    assert_equal "Name", inventory.sort_type
  end

  it "should have hotbar with one item" do
    hotbar = @player.inventory.hotbar

    assert_equal 9, hotbar.capacity
    assert_equal 1, hotbar.items.count
    assert_equal "Rubble_Stone", hotbar[0].id
    assert_equal 3, hotbar[0].quantity
  end

  it "should have storage with items" do
    storage = @player.inventory.storage

    assert_equal 36, storage.capacity
    assert storage.simple?
    refute storage.empty?
    assert_equal 3, storage.items.count
  end

  it "should access specific storage items by slot" do
    fibre = @player.inventory.storage[3]

    assert_instance_of Hytale::Client::Player::Item, fibre
    assert_equal "Ingredient_Fibre", fibre.id
    assert_equal 2, fibre.quantity
    assert_equal 3, fibre.slot
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

  it "should have correct storage items" do
    storage = @player.inventory.storage
    item_ids = storage.items.map(&:id).sort

    assert_includes item_ids, "Plant_Moss_Green"
    assert_includes item_ids, "Ingredient_Fibre"
    assert_includes item_ids, "Ingredient_Stick"
  end

  it "should have no armor equipped" do
    armor = @player.inventory.armor

    assert_equal 4, armor.capacity
    assert_empty armor.items
  end

  it "should have empty utility slots" do
    utility = @player.inventory.utility

    assert_equal 4, utility.capacity
    assert_empty utility.items
  end

  it "should have editor tools" do
    tools = @player.inventory.tools

    assert_equal 23, tools.capacity
    assert_equal 6, tools.items.count

    tool_ids = tools.items.map(&:id)

    assert_includes tool_ids, "EditorTool_Paint"
    assert_includes tool_ids, "EditorTool_Sculpt"
    assert_includes tool_ids, "EditorTool_Selection"
  end

  it "should have full health" do
    stats = @player.stats

    assert_equal 100.0, stats.health
  end

  it "should have full stamina" do
    stats = @player.stats

    assert_equal 10.0, stats.stamina
  end

  it "should have full oxygen" do
    stats = @player.stats

    assert_equal 100.0, stats.oxygen
  end

  it "should have no discovered instances" do
    assert_empty @player.discovered_instances
  end

  it "should have no death positions" do
    assert_empty @player.death_positions
  end

  it "should have no respawn points" do
    assert_empty @player.respawn_points
  end

  it "should have no memories" do
    assert_empty @player.memories
  end

  it "should have no known recipes" do
    assert_empty @player.known_recipes
  end

  it "should have no unique item usages" do
    assert_empty @player.unique_item_usages
  end

  it "should have no saved hotbars" do
    assert_empty @player.saved_hotbars
  end

  it "should have empty reputation data" do
    assert_empty @player.reputation_data
  end

  it "should have empty active objectives" do
    assert_empty @player.active_objectives
  end

  it "should have head rotation" do
    rotation = @player.head_rotation

    assert_instance_of Hytale::Client::Player::Rotation, rotation
    assert_in_delta(-0.028, rotation.pitch, 0.01)
    assert_in_delta(-1.58, rotation.yaw, 0.01)
  end
end
