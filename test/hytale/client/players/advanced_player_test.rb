# frozen_string_literal: true

require "test_helper"

class PlayerAdvancedPlayerTest < Minitest::Spec
  before do
    @player = load_player_fixture("advanced")
  end

  it "should load player from fixture" do
    assert_instance_of Hytale::Client::Player, @player
  end

  it "should have correct name" do
    assert_equal "Player", @player.name
  end

  it "should have equipped backpack" do
    assert @player.inventory.backpack?
  end

  it "should have backpack with correct type" do
    backpack = @player.inventory.backpack

    assert backpack.simple?
    refute backpack.empty?
  end

  it "should have backpack with correct capacity" do
    backpack = @player.inventory.backpack

    assert_equal 9, backpack.capacity
  end

  it "should have backpack with items" do
    backpack = @player.inventory.backpack

    assert_equal 3, backpack.items.count
  end

  it "should have correct items in backpack" do
    backpack = @player.inventory.backpack

    item_ids = backpack.items.map(&:id).sort

    assert_includes item_ids, "Tool_Hatchet_Copper"
    assert_includes item_ids, "Tool_Hoe_Copper"
    assert_includes item_ids, "Tool_Pickaxe_Thorium"
  end

  it "should access backpack items by slot" do
    backpack = @player.inventory.backpack

    assert_equal "Tool_Hatchet_Copper", backpack[0].id
    assert_equal "Tool_Hoe_Copper", backpack[1].id
    assert_equal "Tool_Pickaxe_Thorium", backpack[2].id
  end

  it "should have backpack item durability" do
    backpack = @player.inventory.backpack
    hatchet = backpack[0]

    assert_equal 95.75, hatchet.durability
    assert_equal 200.0, hatchet.max_durability
    assert hatchet.damaged?
  end

  it "should have many discovered zones" do
    zones = @player.discovered_zones

    assert_equal 21, zones.count
  end

  it "should have zones from multiple biomes" do
    zones = @player.discovered_zones

    zone_names = zones.map { |z| z.zone&.id }.compact.uniq.sort

    assert_includes zone_names, "Emerald_Wilds"
    assert_includes zone_names, "Howling_Sands"
    assert_includes zone_names, "Whisperfrost_Frontiers"
    assert_includes zone_names, "Devastated_Lands"
    assert_includes zone_names, "Oceans"
  end

  it "should have memories" do
    memories = @player.memories

    assert_equal 2, memories.count
  end

  it "should have discovered instances" do
    instances = @player.discovered_instances

    assert_instance_of Array, instances
    assert_equal 8, instances.count
  end

  it "should decode discovered instance UUIDs" do
    instances = @player.discovered_instances

    assert(instances.all? { |i| i.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/) })
  end

  it "should have correct first discovered instance UUID" do
    instances = @player.discovered_instances

    assert_equal "4781d0dd-5370-4962-a1fc-521ec7ff3e23", instances.first
  end

  it "should have death positions" do
    deaths = @player.death_positions

    assert_instance_of Array, deaths
    assert_equal 1, deaths.count
  end

  it "should have death position with correct data" do
    death = @player.death_positions.first

    assert_instance_of Hytale::Client::Player::DeathPosition, death
    assert_equal 68, death.day
    assert_match(/death-marker-/, death.marker_id)
  end

  it "should have death position with coordinates" do
    death = @player.death_positions.first

    assert_in_delta(-677.67, death.x, 0.1)
    assert_in_delta(27.98, death.y, 0.1)
    assert_in_delta(-153.47, death.z, 0.1)
  end

  it "should have death position with position object" do
    death = @player.death_positions.first

    assert_instance_of Hytale::Client::Player::Position, death.position
  end

  it "should have respawn points" do
    respawns = @player.respawn_points

    assert_instance_of Array, respawns
    assert_equal 2, respawns.count
  end

  it "should have respawn point with correct data" do
    respawn = @player.respawn_points.first

    assert_instance_of Hytale::Client::Player::RespawnPoint, respawn
    assert_equal "Player - Kweebec village", respawn.name
  end

  it "should have respawn point with position" do
    respawn = @player.respawn_points.first

    assert_instance_of Hytale::Client::Player::Position, respawn.position
    assert_in_delta(-2150.5, respawn.x, 0.1)
  end

  it "should have respawn point with block position" do
    respawn = @player.respawn_points.first

    assert_instance_of Hytale::Client::Player::Position, respawn.block_position
    assert_equal(-2151, respawn.block_position.x.to_i)
  end

  it "should have known recipes" do
    recipes = @player.known_recipes

    assert_instance_of Array, recipes
  end

  it "should have unique item usages" do
    usages = @player.unique_item_usages

    assert_instance_of Array, usages
    assert_includes usages, "Upgrade_Backpack_1"
  end

  it "should have head rotation" do
    rotation = @player.head_rotation

    assert_instance_of Hytale::Client::Player::Rotation, rotation
  end

  it "should return flying status" do
    refute @player.flying?
  end

  it "should return first spawn status" do
    refute @player.first_spawn?
  end

  it "should have active objectives" do
    objectives = @player.active_objectives

    assert_instance_of Array, objectives
  end

  it "should have reputation data" do
    reputation = @player.reputation_data

    assert_instance_of Hash, reputation
  end

  it "should have saved hotbars" do
    hotbars = @player.saved_hotbars

    assert_instance_of Array, hotbars
    assert_equal 1, hotbars.count
    assert_instance_of Hytale::Client::Player::ItemStorage, hotbars.first
  end

  it "should have current hotbar index" do
    assert_equal 0, @player.current_hotbar_index
  end
end
