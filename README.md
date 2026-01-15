<div align="center">
  <h1>Hytale Ruby</h1>
  <h4>Ruby gem for reading Hytale game data.</h4>

  <p>
    <a href="https://rubygems.org/gems/hytale"><img alt="Gem Version" src="https://img.shields.io/gem/v/hytale"></a>
    <a href="https://github.com/marcoroth/hytale-ruby/blob/main/LICENSE.txt"><img alt="License" src="https://img.shields.io/github/license/marcoroth/hytale-ruby"></a>
  </p>

  <p>Read and parse Hytale game data including settings, saves, players, and launcher logs.<br/>Cross-platform support for macOS, Windows, and Linux.</p>
</div>

## Installation

**Add to your Gemfile:**

```ruby
gem "hytale"
```

**Or install directly:**

```bash
gem install hytale
```

## CLI

The gem includes a `hytale` command for quick access to game data.

**Show installation info:**

```bash
hytale info
```

**List all saves:**

```bash
hytale saves
```

**Show save details:**

```bash
hytale save "New World"
```

**Show player details:**

```bash
hytale player "New World" marcoroth
```

**Show game settings:**

```bash
hytale settings
```

**Show launcher log:**

```bash
hytale log
```

**List prefabs:**

```bash
hytale prefabs
hytale prefabs Trees
```

**Available commands:**

| Command | Description |
|---------|-------------|
| `info` | Show Hytale installation info |
| `settings` | Show game settings |
| `saves` | List all saves |
| `save <name>` | Show details for a specific save |
| `player <save> [name]` | Show player details |
| `map <save>` | Show map of explored regions |
| `prefabs [category]` | List prefabs by category |
| `log` | Show launcher log summary |
| `help` | Show help message |

## Usage

### Quick Start

```ruby
require "hytale"
```

**Check if Hytale is installed:**

```ruby
Hytale.client.installed? # => true
```

**Read game settings:**

```ruby
settings = Hytale.settings
settings.window_size       # => [1280, 720]
settings.field_of_view     # => 75
```

**List all saves:**

```ruby
Hytale.saves.each do |save|
  puts "#{save.name}: #{save.world.game_mode}"
end
```

### Object Relationships

Understanding how the main objects relate to each other:

```
Save (a saved game folder)
├── World (configuration for a dimension)
│   └── Map (terrain data)
│       ├── Region (32x32 chunk file)
│       │   └── Chunk (16x16 block column)
│       └── Markers, Time, etc.
├── Players
├── Memories
└── Permissions, Bans, etc.
```

| Object | Description |
|--------|-------------|
| **Save** | A saved game folder (e.g., "New World 1"). Contains worlds, players, permissions. |
| **World** | A dimension's configuration (`config.json`). Settings like seed, game mode, spawn point. |
| **Map** | The actual terrain data for a world. Contains regions with chunk data. |
| **Region** | A 32x32 chunk area stored in a `.region.bin` file. |
| **Chunk** | A 16x16 column of blocks. The smallest unit of terrain. |

**Navigating between objects:**

```ruby
save = Hytale.saves.first
```

**Save -> Worlds**
```ruby
save.world_names  # => ["default", "flat_world", ...]
save.worlds       # => [World, World, ...]
```

**Save -> World (specific)**
```ruby
world = save.world("flat_world")
world.display_name   # => "Flat"
world.game_mode      # => "Creative"
```

**World -> Map**
```ruby
map = world.map
map.regions.count # => 4
```

**Save -> Map (shortcut)**
```ruby
map = save.map("flat_world")
```

**Save -> All Maps**
```ruby
save.maps.each do |map|
  puts "#{map.world_name}: #{map.regions.count} regions"
end
```

**Map -> Regions -> Chunks**
```ruby
region = map.regions.first

region.each_chunk do |chunk|
  puts "#{chunk.local_x}, #{chunk.local_z}: #{chunk.block_types.join(', ')}"
end
```

### Reading Settings

Settings provides access to all game configuration:

**Display:**

```ruby
settings = Hytale.settings

settings.fullscreen?        # => false
settings.window_size        # => [1280, 720]
settings.vsync?             # => true
settings.fps_limit          # => 118
settings.field_of_view      # => 75
```

**Rendering:**

```ruby
settings.rendering.view_distance   # => 384
settings.rendering.anti_aliasing   # => 3
settings.rendering.shadows         # => 2
```

**Audio:**

```ruby
settings.audio.master_volume  # => 0.85
settings.audio.music_volume   # => 0.85
```

**Gameplay:**

```ruby
settings.gameplay.arachnophobia_mode?  # => false
```

**Settings modules:**

| Module | Description |
|--------|-------------|
| `rendering` | Graphics settings (view distance, shadows, AA, bloom) |
| `audio` | Volume levels and output device |
| `mouse_settings` | Sensitivity and inversion |
| `gameplay` | Game behavior options |
| `builder_tools` | Creative mode tool settings |
| `input_bindings` | Key bindings |

### Working with Saves

Access world saves and their contents:

**List all saves:**

```ruby
saves = Hytale.saves
```

**Find a specific save:**

```ruby
save = Hytale.client.save("New World")
```

**World configuration:**

```ruby
world = save.world
world.display_name         # => "New World"
world.seed                 # => 1768313554213
world.game_mode            # => "Adventure"
world.pvp_enabled?         # => false
world.daytime_duration     # => 1728
world.nighttime_duration   # => 1151
```

**Death settings:**

```ruby
world.death_settings.items_loss_percentage      # => 50.0
world.death_settings.durability_loss_percentage # => 10.0
```

**Save contents:**

| Method | Description |
|--------|-------------|
| `world(name)` | World configuration (seed, game mode, day/night cycle) |
| `worlds` | All World objects in the save |
| `world_names` | List of world directory names |
| `map(name)` | Map data for a specific world |
| `maps` | All Map objects for all worlds |
| `players` | All players in this save |
| `memories` | Discovered NPCs/creatures |
| `permissions` | Server permissions and groups |
| `backups` | Automatic backup files |
| `logs` | Server log files |
| `mods` | Installed mods |

### Reading Player Data

Access player inventory, stats, and progress:

**Basic info:**

```ruby
save = Hytale.client.save("New World")
player = save.players.first

player.name                # => "marcoroth"
player.uuid                # => "79816d74-0500-4dad-9767-06af86c17243"
player.position            # => (590.75, 123.0, 374.2)
player.game_mode           # => "Adventure"
player.discovered_zones    # => ["Zone1_Spawn", "Zone1_Tier1", ...]
player.skin                # => PlayerSkin object
player.avatar_preview_path # => "/path/to/CachedAvatarPreviews/uuid.png"
```

**Stats:**

```ruby
player.stats.health        # => 96.0
player.stats.stamina       # => 9.3
player.stats.oxygen        # => 100.0
```

**Inventory:**

```ruby
player.inventory.hotbar.items.each do |item|
  puts "#{item.name} - #{item.durability_percent}%"
end
```

**Armor:**

```ruby
player.inventory.armor.items.each do |item|
  puts item.name
end
```

**Player inventory slots:**

| Slot | Description |
|------|-------------|
| `hotbar` | 9-slot quick access bar |
| `storage` | Main inventory (36 slots) |
| `backpack` | Optional backpack storage (if equipped) |
| `armor` | Head, chest, hands, legs |
| `utility` | Utility items (4 slots) |
| `tools` | Builder/editor tools |

**Check if player has a backpack:**

```ruby
player.inventory.backpack?  # => true/false
```

**ItemStorage type checks:**

```ruby
player.inventory.backpack.empty?   # => true (type is "Empty" - no backpack equipped)
player.inventory.backpack.simple?  # => true (type is "Simple" - backpack equipped)
```

**Item properties:**

```ruby
item.id                 # => "Tool_Pickaxe_Copper"
item.name               # => "Tool Pickaxe Copper"
item.quantity           # => 1
item.durability         # => 29.75
item.max_durability     # => 200.0
item.durability_percent # => 14.9
item.damaged?           # => true
```

### Memories (Discovered Creatures)

Track discovered NPCs and creatures:

**Count and list:**

```ruby
memories = save.memories
memories.count             # => 42
```

**List all discovered roles:**

```ruby
memories.roles
# => ["Bat", "Bear_Grizzly", "Bluebird", "Boar", ...]
```

**List discovery locations:**

```ruby
memories.locations
# => ["ForgottenTemple", "Zone1_Tier1", "Zone1_Tier2", ...]
```

**Find specific creatures:**

```ruby
memories.find_by_role("Wolf_Black")
# => Memory: Wolf Black found at Zone1_Tier1

memories.find_all_by_location("ForgottenTemple")
# => [Memory: Duck, Memory: Kweebec_Rootling, ...]
```

**Iterate:**

```ruby
memories.each do |memory|
  puts "#{memory.friendly_name} at #{memory.location} (#{memory.captured_at})"
end
```

### Permissions

Read server permissions and groups:

**List groups:**

```ruby
permissions = save.permissions

permissions.groups
# => {"Default" => [], "OP" => ["*"]}
```

**Check user permissions:**

```ruby
permissions.user_groups(uuid)
# => ["Adventure"]

permissions.op?(uuid)
# => false
```

### Map Data

Access explored regions and map markers:

**Get map for a save:**

```ruby
map = save.map
```

**Region coverage:**

```ruby
map.regions.count    # => 10
map.total_size_mb    # => 120.56
map.bounds           # => {min_x: -1, max_x: 2, min_z: -1, max_z: 1, ...}
```

**Individual regions:**

```ruby
map.regions.each do |region|
  puts "#{region.x}, #{region.z}: #{region.size_mb} MB"
end
```

**Region details:**

```ruby
region = map.regions.first
region.header        # => {version: 1, chunk_count: 1024, ...}
region.chunk_count   # => 207 (non-empty chunks)
region.block_types   # => ["Rock_Stone", "Soil_Grass", ...]
```

**Block types across all regions:**

```ruby
map.block_types      # => ["Ore_Copper", "Plant_Bush", "Rock_Stone", ...]
```

**Map markers (discovered locations):**

```ruby
map.markers.each do |marker|
  puts "#{marker.name} at #{marker.position}"
end
# => "Forgotten Temple Portal Enter at (832, 113, 367)"
```

**ASCII map of explored regions:**

```ruby
puts map.to_ascii(players: save.players)
```

```
     -1  0  1  2
    --------------
 -1 | o  O  O    |
  0 | O  #  M  . |
  1 | o  O  o    |
    --------------

Legend: . = small, o = medium, O = large, # = huge, Letter = player
```

### Global Coordinates

Access regions, chunks, and blocks using world coordinates:

```ruby
map = save.map
```

**Get region containing world coordinates:**

```ruby
region = map.region_at_world(100, 200)
```

**Get chunk at world coordinates:**

```ruby
chunk = map.chunk_at(100, 200)
```

**Get block at world coordinates:**

```ruby
block = map.block_at(100, 50, 200)
block.id             # => "Rock_Stone"
block.world_position # => [100, 50, 200]
```

**Coordinate conversion helpers:**

```ruby
map.world_to_region_coords(100, 200)       # => [0, 0]
map.world_to_region_coords(-100, -200)     # => [-1, -1]
map.world_to_chunk_local_coords(100, 200)  # => [6, 12]
map.world_to_block_local_coords(100, 200)  # => [4, 8]
```

**Coordinate system:**

| Unit | Size | Description |
|------|------|-------------|
| Block | 1 | Smallest unit |
| Chunk | 16×16 blocks | Vertical column of blocks |
| Region | 32×32 chunks (512×512 blocks) | Stored in `.region.bin` files |

Region 0 covers blocks 0..511, region -1 covers -512..-1, etc.

### Map Rendering

Generate PNG images of maps using colors derived from block textures.

**Render modes:**

| Mode | Description | Speed |
|------|-------------|-------|
| Fast (`detailed: false`) | Colors entire chunk with dominant surface block | ~5s for 10 regions |
| Detailed (`detailed: true`) | Renders each block individually using `surface_at` | ~15s for 10 regions |

**Render a map to PNG:**

```ruby
save = Hytale.saves.first
map = save.map
```

**Fast mode (default):** uniform color per chunk:

```ruby
map.render_to_png("/tmp/map_fast.png")
```

**Detailed mode:** per-block accuracy:

```ruby
map.render_to_png("/tmp/map_detailed.png", detailed: true)
```

**With scale (2x = 2 pixels per block):**

```ruby
map.render_to_png("/tmp/map_2x.png", scale: 2, detailed: true)
```

**Render a single region:**

```ruby
region = map.regions.first
region.render_to_png("/tmp/region.png", scale: 2, detailed: true)
```

**Render a single chunk:**

```ruby
chunk = region.chunks.values.first
chunk.render_to_png("/tmp/chunk.png", scale: 4, detailed: true)
```

**Using the Renderer directly:**

```ruby
renderer = Hytale::Client::Map::Renderer.new
```

**Get average color from a block's texture:**

```ruby
renderer.block_color("Soil_Grass")  # => ChunkyPNG color
```

**Render with custom options:**

```ruby
png = renderer.render_map(map, scale: 2, detailed: true)
png.save("/tmp/map.png")
```

**Check cached colors:**

```ruby
renderer.color_cache
# => {"Soil_Grass" => 7379500, "Rock_Stone" => 7894873, ...}
```

**Color extraction:**

The renderer extracts average colors from block textures:

| Block Type | Color | Source Texture |
|------------|-------|----------------|
| Soil_Grass | `#709C2C` | Soil_Grass_Sunny.png |
| Soil_Dirt | `#8A652C` | Soil_Dirt.png |
| Rock_Stone | `#787759` | Rock_Stone.png |
| Soil_Sand | `#CFA643` | Soil_Sand.png |

Blocks without textures use sensible defaults (e.g., blue for water).

**Chunk analysis:**

```ruby
chunk = region.each_chunk.first

chunk.block_types      # => ["Rock_Stone", "Soil_Dirt", "Soil_Grass", ...]
chunk.terrain_type     # => :grassland
chunk.water?           # => false
chunk.vegetation?      # => true
chunk.local_x          # => 15
chunk.local_z          # => 8
chunk.world_x          # => -272
chunk.world_z          # => -408
```

**ASCII representation:**

```ruby
puts chunk.to_ascii_map
# GGGGGGGGGGGGGGGG
# GGGGGGGGGGGGGGGG
# ...
```

### Backups

Access automatic backup files:

```ruby
save.backups.each do |backup|
  puts "#{backup.filename} - #{backup.size_mb} MB"
  puts "Created: #{backup.created_at}"
end
```

### Launcher Log

Parse the Hytale launcher log:

**Current state:**

```ruby
log = Hytale.launcher_log

log.current_version        # => "2026.01.13-b6c7e88"
log.current_channel        # => "release"
log.current_profile_uuid   # => "79816d74-..."
```

**Game launches:**

```ruby
log.game_launches.count    # => 6
```

**Errors:**

```ruby
log.errors.each do |entry|
  puts "[#{entry.timestamp}] #{entry.message}"
end
```

**Sessions:**

```ruby
log.sessions.each do |session|
  puts "#{session.started_at} - v#{session.version}"
  puts "  Game launched: #{session.game_launched?}"
  puts "  Errors: #{session.errors.count}"
end
```

**Log entry types:**

| Method | Description |
|--------|-------------|
| `entries` | All log entries |
| `errors` | Error-level entries |
| `warnings` | Warning-level entries |
| `info` | Info-level entries |
| `game_launches` | Game start events |
| `updates` | Update events |
| `sessions` | Grouped by launcher start |

### Custom Data Path

Override the default data path:

**Set custom path:**

```ruby
Hytale::Client.data_path = "/path/to/hytale/data"
```

**Reset to platform default:**

```ruby
Hytale::Client::Config.reset!
```

### Platform Support

The gem automatically detects the Hytale data directory:

| Platform | Default Path |
|----------|-------------|
| macOS | `~/Library/Application Support/Hytale` |
| Windows | `%APPDATA%/Hytale` |
| Linux | `~/.local/share/Hytale` |

### Process Detection

Detect if the Hytale client is running:

**Check if game is running:**

```ruby
Hytale.client.running?
# => true
```

**List running client processes:**

```ruby
Hytale::Client::Process.list
# => [#<Hytale::Client::Process pid=12345>]
```

**Check a specific process:**

```ruby
process = Hytale::Client::Process.list.first
process.running? # => true
process.pid      # => 12345
```

## API Reference

### Hytale (Top-level)

| Method | Description |
|--------|-------------|
| `Hytale.client` | Access client module |
| `Hytale.server` | Access server module |
| `Hytale.settings` | Load game settings |
| `Hytale.saves` | List all saves |
| `Hytale.players` | List all players across all saves |
| `Hytale.launcher_log` | Load launcher log |

### Hytale::Client

| Method | Description |
|--------|-------------|
| `installed?` | Check if Hytale is installed |
| `running?` | Check if Hytale client is running |
| `processes` | List running client processes |
| `data_path` | Get/set data directory |
| `settings` | Load Settings |
| `saves` | List all Save objects |
| `save(name)` | Find Save by name |
| `launcher_log` | Load LauncherLog |
| `prefabs` | List all Prefab objects |
| `prefab(name)` | Find Prefab by name |
| `prefab_categories` | List prefab category names |
| `prefabs_in_category(name)` | List prefabs in a category |
| `block_types` | List all BlockType objects |
| `block_type(id)` | Create BlockType by ID |
| `block_type_categories` | List block category names |
| `block_types_in_category(name)` | List block types in a category |
| `players` | List all players across all saves |
| `player(uuid)` | Find Player by UUID |
| `player_skins` | List all cached PlayerSkin objects |
| `player_skin(uuid)` | Find PlayerSkin by UUID |

### Hytale::Client::Map

| Method | Description |
|--------|-------------|
| `regions` | All Region objects |
| `region_at(x, z)` | Find region by region coordinates |
| `region_at_world(x, z)` | Find region by world coordinates |
| `chunk_at(x, z)` | Get chunk at world coordinates |
| `block_at(x, y, z)` | Get Block at world coordinates |
| `world_to_region_coords(x, z)` | Convert world → region coords |
| `world_to_chunk_local_coords(x, z)` | Convert world → chunk-local coords |
| `world_to_block_local_coords(x, z)` | Convert world → block-local coords |
| `bounds` | Map boundaries (min/max x/z) |
| `markers` | Map markers (discovered locations) |
| `block_types` | All block types across regions |
| `total_size_mb` | Total size of all region files |
| `render_to_png(path, scale:, detailed:)` | Render map to PNG image |
| `to_ascii(players:)` | ASCII representation |

### Hytale::Client::Map::Region

| Method | Description |
|--------|-------------|
| `x`, `z` | Region coordinates |
| `chunk_count` | Number of non-empty chunks |
| `chunk_exists?(x, z)` | Check if chunk exists at local coords |
| `chunk_at_index(idx)` | Get chunk by index (0-1023) |
| `each_chunk` | Iterate over all chunks |
| `block_types` | All block types in region |
| `render_to_png(path, scale:, detailed:)` | Render region to PNG image |

### Hytale::Client::Map::Chunk

| Method | Description |
|--------|-------------|
| `index` | Chunk index in region (0-1023) |
| `local_x`, `local_z` | Position within region (0-31) |
| `world_x`, `world_z` | World coordinates |
| `size` | Decompressed data size in bytes |
| `height` | Number of Y layers in chunk |
| `block_at(x, y, z)` | Get Block instance at local coordinates |
| `block_type_at(x, y, z)` | Get block type ID string (faster) |
| `surface_at(x, z)` | Find highest non-empty Block at X, Z |
| `block_types` | Block type IDs found in chunk |
| `block_palette` | Parsed palette (index → block name) |
| `terrain_type` | Detected terrain (`:grassland`, `:water`, etc.) |
| `water?` | Contains water blocks |
| `vegetation?` | Contains plant/grass blocks |
| `to_ascii_map` | 16x16 ASCII representation |

### Hytale::Client::Map::Block

| Method | Description |
|--------|-------------|
| `id` | Block type ID (e.g., "Rock_Stone") |
| `name` | Human-readable name |
| `category` | Block category (e.g., "Rock") |
| `block_type` | Associated BlockType instance |
| `x`, `y`, `z` | Local coordinates within chunk |
| `world_x`, `world_y`, `world_z` | World coordinates |
| `local_position` | `[x, y, z]` array |
| `world_position` | `[world_x, world_y, world_z]` array |
| `chunk` | Parent Chunk reference |
| `empty?` | Is air/empty block? |
| `solid?` | Is solid (not empty, not liquid)? |
| `liquid?` | Is water/lava? |
| `vegetation?` | Is plant/grass? |
| `texture_path` | Path to texture file |
| `texture_exists?` | Does texture exist? |
| `texture_data` | Raw PNG texture data |

### Hytale::Client::BlockType

| Method | Description |
|--------|-------------|
| `id` | Block type ID (e.g., "Rock_Stone") |
| `name` | Human-readable name |
| `category` | Block category (e.g., "Rock") |
| `subcategory` | Block subcategory if available |
| `texture_name` | Texture filename |
| `texture_path` | Path to texture file |
| `texture_exists?` | Does texture exist? |
| `texture_data` | Raw PNG texture data |
| `all_textures` | (class method) List all texture names |

### Hytale::Client::Map::Renderer

| Method | Description |
|--------|-------------|
| `block_color(type)` | Get average color for block type |
| `render_chunk(chunk, scale:, detailed:)` | Render chunk to ChunkyPNG image |
| `render_region(region, scale:, detailed:)` | Render region to ChunkyPNG image |
| `render_map(map, scale:, detailed:)` | Render map to ChunkyPNG image |
| `save_region(region, path, scale:, detailed:)` | Save region PNG to file |
| `save_map(map, path, scale:, detailed:)` | Save map PNG to file |
| `color_cache` | Hash of cached block colors |

## Technical Details

### Region File Format (`.region.bin`)

Region files use the `HytaleIndexedStorage` format:

**Header (32 bytes):**

| Offset | Size | Description |
|--------|------|-------------|
| 0 | 20 | Magic: "HytaleIndexedStorage" |
| 20 | 4 | Version (BE) = 1 |
| 24 | 4 | Chunk count (BE) = 1024 |
| 28 | 4 | Index table size (BE) = 4096 |

**Index Table (4096 bytes):**

- 1024 entries of 4 bytes each (big-endian)
- Non-zero value indicates chunk exists

**Data Section:**

- Chunks stored at 4096-byte aligned positions
- Each chunk: `[decompressed_size 4B BE] [compressed_size 4B BE] [ZSTD data]`
- ZSTD magic: `0x28B52FFD`

**Decompression:**

```ruby
require "zstd-ruby"
region = Hytale::Client::Map::Region.new(path)
region.block_types  # Extracts block palette from chunks
```

### Chunk Data Format

Decompressed chunk data uses a BSON-like structure with numbered sections (0-9) containing block data.

**Block Data Section:**

| Offset | Size | Description |
|--------|------|-------------|
| 0 | 3 | Zeros (padding) |
| 3 | 1 | Type marker (0x0A) |
| 4 | 1 | Version (0x01) |
| 5 | 1 | Zero |
| 6 | 1 | Palette count |
| 7 | 2 | Zeros |
| 9 | N | Palette entries |
| 9+N | M | Block data (4-bit packed) |

**Palette Entry Format:**

| Size | Description |
|------|-------------|
| 1 | String length |
| N | Block name (e.g., "Rock_Stone") |
| 4 | Metadata (palette index at byte 2) |

**Block Data Encoding:**

- 4-bit packed indices (2 blocks per byte)
- 128 bytes per Y layer (16×16 blocks)
- Low nibble = block at even position
- High nibble = block at odd position

**Accessing blocks:**

**Block at (x, y, z) within chunk:**

```ruby
layer_offset = y * 128
block_index = z * 16 + x
byte_offset = layer_offset + (block_index / 2)
```

**Extract 4-bit index:**

```ruby
if block_index.even?
  palette_index = byte & 0x0F   # Low nibble
else
  palette_index = (byte >> 4) & 0x0F  # High nibble
end

block_name = palette[palette_index]
```

### Prefab File Format (`.prefab.json.lpf`)

Prefab files store pre-built structures (trees, buildings, dungeons, etc.) in a custom binary format. Despite the `.json` in the filename, these are binary files, not JSON.

**Header (21 bytes):**

| Offset | Size | Description |
|--------|------|-------------|
| 0 | 2 | Palette offset (BE) = 21 |
| 2 | 2 | Header value (BE) |
| 4 | 10 | Reserved/dimensions |
| 14 | 2 | Palette count (BE) |
| 16 | 5 | Reserved |

**Block Palette:**

Each palette entry:

| Size | Description |
|------|-------------|
| 1 | String length |
| N | Block name (ASCII) |
| 2 | Flags (BE) |
| 2 | Block ID (BE) |
| 1 | Extra data (rotation/state) |

**Placement Data:**

Block placement coordinates follow the palette. Format varies by prefab complexity.

**List all prefabs:**

```ruby
Hytale.client.prefabs.each do |prefab|
  puts "#{prefab.name}: #{prefab.palette.size} block types"
end
```

**Get prefab categories:**

```ruby
Hytale.client.prefab_categories
# => ["Cave", "Dungeon", "Mineshaft", "Monuments", "Npc", "Plants", ...]
```

**Find prefabs by category:**

```ruby
Hytale.client.prefabs_in_category("Trees")
```

**Find specific prefab:**

```ruby
prefab = Hytale.client.prefab("Burnt_dead_Stage2_005")
prefab.name        # => "Burnt_dead_Stage2_005"
prefab.category    # => "Trees"
prefab.block_names # => ["Wood_Burnt_Branch_Long", "Wood_Burnt_Trunk", ...]
```

**Access palette entries:**

```ruby
prefab.palette.each do |entry|
  puts "#{entry.name} (ID: 0x#{format('%04X', entry.block_id)})"
end
```

### Blocks and Block Types

The gem distinguishes between:
- **BlockType** - A block definition (e.g., "Rock_Stone") with texture and category info
- **Block** - A specific block at coordinates in the world, referencing its BlockType

**BlockType - Block definitions:**

```ruby
Hytale.client.block_types.count         # => 1156
Hytale.client.block_type_categories     # => ["Alchemy", "Bench", "Ore", "Plant", "Rock", ...]
```

**Get block types by category:**

```ruby
Hytale.client.block_types_in_category("Ore")
# => [BlockType: Ore_Copper_Stone, BlockType: Ore_Iron_Stone, ...]
```

**Create a block type directly:**

```ruby
block_type = Hytale.client.block_type("Rock_Stone")
block_type.id        # => "Rock_Stone"
block_type.name      # => "Rock Stone"
block_type.category  # => "Rock"
```

**BlockType textures:**

```ruby
block_type.texture_path    # => "/path/to/gem/assets/Common/BlockTextures/Rock_Stone.png"
block_type.texture_exists? # => true
block_type.texture_data    # => PNG binary data
```

**List all available textures:**

```ruby
Hytale::Client::BlockType.all_textures
# => ["Bone_Side", "Bone_Top", "Calcite", ...]
```

**Block - Positioned blocks in the world:**

```ruby
chunk = region.chunks.values.first
```

**Get a block at specific coordinates:**

```ruby
block = chunk.block_at(8, 50, 8)
block.id              # => "Rock_Quartzite"
block.name            # => "Rock Quartzite"
block.category        # => "Rock"
block.block_type      # => BlockType instance
```

**Local position within chunk:**

```ruby
block.x               # => 8
block.y               # => 50
block.z               # => 8
block.local_position  # => [8, 50, 8]
```

**World coordinates:**

```ruby
block.world_x         # => -8
block.world_y         # => 50
block.world_z         # => -280
block.world_position  # => [-8, 50, -280]
```

**Block properties:**

```ruby
block.empty?          # => false
block.solid?          # => true
block.liquid?         # => false
block.vegetation?     # => false
```

**Access texture through block_type:**

```ruby
block.texture_path    # => "/path/to/Rock_Quartzite.png"
block.texture_exists? # => true
```

**Finding surface blocks:**

```ruby
surface = chunk.surface_at(8, 8)
surface.id             # => "Rock_Bedrock"
surface.y              # => 126
surface.world_position # => [-8, 126, -280]
```

**Performance note:** For bulk operations, use `block_type_at(x, y, z)` which returns just the string ID without creating Block instances:

```ruby
type_id = chunk.block_type_at(8, 50, 8)  # => "Rock_Quartzite"
```

### Player Skins

Access cached player skin/cosmetic data:

**List all cached skins:**

```ruby
Hytale.client.player_skins
# => [PlayerSkin: 79816d74-..., ...]
```

**Find a specific skin:**

```ruby
skin = Hytale.client.player_skin("79816d74-0500-4dad-9767-06af86c17243")
skin.uuid  # => "79816d74-0500-4dad-9767-06af86c17243"
```

**Appearance:**

```ruby
skin.body_characteristic  # => "Muscular.06"
skin.face                 # => "Face_Stubble"
skin.eyes                 # => "Medium_Eyes.BrownDark"
skin.haircut              # => "VikinManBun.BrownDark"
skin.facial_hair          # => "Groomed_Large.BrownDark"
skin.eyebrows             # => "Square.BrownDark"
```

**Clothing:**

```ruby
skin.pants      # => "BulkySuede.Brown"
skin.overpants  # => "LongSocks_Bow.Pink"
skin.undertop   # => "VikingShirt.Black"
skin.overtop    # => nil
skin.shoes      # => "HeavyLeather.Black"
skin.gloves     # => "FlowerBracer.Gold_Red"
skin.cape       # => nil
```

**Accessories:**

```ruby
skin.head_accessory  # => nil
skin.face_accessory  # => nil
skin.ear_accessory   # => "SimpleEarring.Gold_Red.Right"
```

**Utility methods:**

```ruby
skin.equipped_items  # => {"bodyCharacteristic" => "Muscular.06", ...}
skin.empty_slots     # => ["overtop", "headAccessory", "cape", ...]
```

**Avatar preview:**

```ruby
skin.avatar_preview_path  # => "/path/to/CachedAvatarPreviews/uuid.png"
skin.avatar_preview_data  # => PNG binary data
```

**Texture paths:**

```ruby
skin.haircut_texture_path  # => "/path/to/assets/Common/Characters/Haircuts/Viking_Topknot_Greyscale.png"
skin.pants_texture_path    # => "/path/to/assets/Common/Cosmetics/Pants/Pants_Brown.png"
skin.shoes_texture_path    # => "/path/to/assets/Common/Cosmetics/Shoes/HeavyLeather_Black.png"
```

**Get all texture paths at once:**

```ruby
skin.texture_paths
# => {haircut: "/path/to/...", pants: "/path/to/...", ...}
```

### Cosmetics

Access the cosmetic item catalog:

**Look up cosmetic items:**

```ruby
Hytale::Client::Cosmetics.find(:haircuts, "VikinManBun")
# => {"Id" => "VikinManBun", "Model" => "...", "GreyscaleTexture" => "..."}

Hytale::Client::Cosmetics.find(:pants, "BulkySuede")
# => {"Id" => "BulkySuede", "Model" => "...", "Textures" => {...}}
```

**Get texture and model paths:**

```ruby
Hytale::Client::Cosmetics.texture_path(:haircuts, "VikinManBun.BrownDark")
# => "/path/to/assets/Common/Characters/Haircuts/Viking_Topknot_Greyscale.png"

Hytale::Client::Cosmetics.model_path(:haircuts, "VikinManBun")
# => "/path/to/assets/Common/Characters/Haircuts/Viking_TopKnot.blockymodel"
```

**Available cosmetic types:**

| Type | Description |
|------|-------------|
| `:haircuts` | Hair styles |
| `:facial_hair` | Beards, mustaches |
| `:eyebrows` | Eyebrow styles |
| `:eyes` | Eye styles |
| `:faces` | Face textures |
| `:pants` | Pants/bottoms |
| `:overpants` | Socks, leg accessories |
| `:undertops` | Shirts, undershirts |
| `:overtops` | Jackets, vests |
| `:shoes` | Footwear |
| `:gloves` | Gloves, bracers |
| `:capes` | Capes |
| `:head_accessories` | Hats, helmets |
| `:face_accessories` | Glasses, masks |
| `:ear_accessories` | Earrings |

### Assets

The gem automatically extracts and caches all game assets from `Assets.zip` on first use.

**Asset cache location:**

```ruby
Hytale::Client::Assets.cache_path  # => "/path/to/gem/assets"
Hytale::Client::Assets.count       # => 57708
```

**List asset directories:**

```ruby
Hytale::Client::Assets.directories
# => ["Common/BlockTextures", "Common/Blocks", "Common/Items", "Server/Prefabs", ...]
```

**Access any asset:**

```ruby
Hytale::Client::Assets.cached?("Common/Icons/Item_Sword_Copper.png")  # => true
Hytale::Client::Assets.read("Common/Icons/Item_Sword_Copper.png")     # => PNG binary data
Hytale::Client::Assets.cached_path("Common/Icons/Item_Sword_Copper.png")
# => "/path/to/gem/assets/Common/Icons/Item_Sword_Copper.png"
```

**List files in a directory:**

```ruby
Hytale::Client::Assets.list("Common/Icons")
# => ["Common/Icons/Item_Sword_Copper.png", ...]
```

**Clear the cache:**

```ruby
Hytale::Client::Assets.clear!
```

## Development

```bash
git clone https://github.com/marcoroth/hytale-ruby
cd hytale
bundle install
bundle exec rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcoroth/hytale-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Disclaimer

This gem is not affiliated with or endorsed by Hypixel Studios.
