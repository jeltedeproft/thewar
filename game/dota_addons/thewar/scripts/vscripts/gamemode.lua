-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

--require("examples/worldpanelsExample")

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  local item = CreateItem("item_courier", hero, hero)
  hero:AddItem(item)
  hero:HeroLevelUp(false)
  hero:HeroLevelUp(false)
  hero:HeroLevelUp(false)
  hero:HeroLevelUp(false)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  Timers:CreateTimer(0, 
    function()
      SpawnCreeps(Game)
      return 30.0  
    end
  )

  Timers:CreateTimer(0, 
    function()
      SpawnMonster()
      return 1.0  
    end
  )
end

function SpawnMonster()
  local time = GameRules:GetGameTime()

  if (time > 600 and roshanspawned == false) then --[[599 601]]
    print("creating monster")
    local droppoint = Entities:FindByName(nil, "monster_droppoint"):GetAbsOrigin()
    CreateUnitByName("roshan", droppoint, true, nil, nil, DOTA_TEAM_NEUTRALS)
    roshanspawned = true
  end
end

function SpawnCreeps()

  local positions = {}
  for i=1, 8 do
      positions[i] = Entities:FindByName(nil, "radiant_spawner_"..i):GetAbsOrigin()
  end

  for i=1, 8 do
      positions[8 + i] = Entities:FindByName(nil, "dire_spawner_"..i):GetAbsOrigin()
  end

  local waypoint_radiant = Entities:FindByName( nil, "lane_mid_pathcorner_goodguys_4"):GetAbsOrigin()
  local waypoint_dire = Entities:FindByName( nil, "lane_mid_pathcorner_badguys_3"):GetAbsOrigin()



  local unittable = {
  {
    "neutral_kobold",
    "kobold_tunneler",
    "kobold_taskmaster",
    "forest_troll_high_priest",
    "dark_troll_warlord_skeleton_warrior",
    "neutral_gnoll_assassin",
    "neutral_harpy_scout",
    "neutral_harpy_storm",
    "neutral_kobold",
    "kobold_tunneler",
    "kobold_taskmaster",
    "forest_troll_high_priest",
    "dark_troll_warlord_skeleton_warrior",
    "neutral_gnoll_assassin",
    "neutral_harpy_scout",
    "neutral_harpy_storm"
  },

  {
    "npc_dota_creep_goodguys_melee",
    "npc_dota_creep_goodguys_melee",
    "npc_dota_creep_goodguys_melee",
    "npc_dota_creep_goodguys_ranged",
    "npc_dota_creep_goodguys_melee",
    "npc_dota_creep_goodguys_melee",
    "npc_dota_creep_goodguys_melee",
    "npc_dota_creep_goodguys_ranged",
    "npc_dota_creep_badguys_melee",
    "npc_dota_creep_badguys_melee",
    "npc_dota_creep_badguys_melee",
    "npc_dota_creep_badguys_ranged",
    "npc_dota_creep_badguys_melee",
    "npc_dota_creep_badguys_melee",
    "npc_dota_creep_badguys_melee",
    "npc_dota_creep_badguys_ranged"
  },

  {
    "giant_wolf",
    "alpha_wolf",
    "lycan_wolf2",
    "satyr_soulstealer",
    "satyr_trickster",
    "ogre_mauler",
    "ogre_magi",
    "rock_golem",
    "giant_wolf",
    "alpha_wolf",
    "lycan_wolf2",
    "satyr_soulstealer",
    "satyr_trickster",
    "ogre_mauler",
    "ogre_magi",
    "rock_golem"
  },

  {
    "centaur_outrunner",
    "centaur_khan",
    "ursa_clapper",
    "satyr_hellcaller",
    "polar_furbolg_champion",
    "dark_troll_warlord",
    "big_bird",
    "dark_troll",
    "centaur_outrunner",
    "centaur_khan",
    "ursa_clapper",
    "satyr_hellcaller",
    "polar_furbolg_champion",
    "dark_troll_warlord",
    "big_bird",
    "dark_troll"
  }
}

  local units = {}
  local how_many_rows_of_units = 6
  local waves_of_units = 1
  local time = GameRules:GetGameTime()
  if time < 301 then waves_of_units = 1
    elseif time > 300 and time < 601 then waves_of_units = 2
    elseif time > 600 and time < 901 then waves_of_units = 3
    elseif time > 900 then waves_of_units = 4
  end

  for j = 1,how_many_rows_of_units do
    for i = 1,8 do
      units[j*16 + i] = CreateUnitByName(unittable[waves_of_units][i], positions[i], true, nil, nil, DOTA_TEAM_GOODGUYS)

      ExecuteOrderFromTable({UnitIndex  = units[j*16 + i]:GetEntityIndex(),
                             OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                             Position = waypoint_radiant,
                             Queue = true})

      units[j*16 + 8 + i] = CreateUnitByName(unittable[waves_of_units][8 + i], positions[8 + i], true, nil, nil, DOTA_TEAM_BADGUYS)


      ExecuteOrderFromTable({UnitIndex  = units[j*16 + 8 + i]:GetEntityIndex(),
                             OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                             Position = waypoint_dire,
                             Queue = true})
    end
  end
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  roshanspawned = false
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end