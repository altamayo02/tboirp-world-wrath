local game_is_continued = false
local STAT_DIFFS = {
	[CacheFlag.CACHE_SPEED] = {
		KEY = "MoveSpeed",
		VALUE = -0.2
	},
	[CacheFlag.CACHE_FIREDELAY] = {
		KEY = "MaxFireDelay",
		VALUE = 3
	},
	[CacheFlag.CACHE_SHOTSPEED] = {
		KEY = "ShotSpeed",
		VALUE = 0.2
	},
	[CacheFlag.CACHE_LUCK] = {
		KEY = "Luck",
		VALUE = -1
	}
}
local STAT_DIFFS_B = {
	[CacheFlag.CACHE_LUCK] = {
		KEY = "Luck",
		VALUE = -4
	}
}
local ball_and_chain = {}


---@param player EntityPlayer
local function OnBomberBInit(_, player)
	local bomber_b_id =Isaac.GetPlayerTypeByName("The Bomber", true)
	if player:GetPlayerType() == bomber_b_id then
		player:AddNullCostume(
			Isaac.GetCostumeIdByPath("gfx/characters/character_bomber_balaclava.anm2")
		)
    ball_and_chain = Isaac.Spawn(
			WorldWrath.ENTITIES.BALL_AND_CHAIN.ID,
			WorldWrath.ENTITIES.BALL_AND_CHAIN.VARIANT,
			WorldWrath.ENTITIES.BALL_AND_CHAIN.SUBTYPE,
			Vector(player.Position.X - 40, player.Position.Y),
			Vector(0,0),
			player
    )
		print(ball_and_chain.Position)
		
		-- TODO - Only execute when a run is starting
		player:AddHearts(-2)
		Chapil.AddHealth(player, "BOMB_HEART", 2)
	end
end
WorldWrath:AddCallback(
	ModCallbacks.MC_POST_PLAYER_INIT,
	OnBomberBInit
)

---@param player EntityPlayer
local function OnBomberInit(_, player)
	if player:GetPlayerType() == Isaac.GetPlayerTypeByName("The Bomber") then
		WorldWrath.GAME:GetItemPool():RemoveCollectible(
			WorldWrath.ACTIVES.TICK_HEART
		)
		player:AddCollectible(WorldWrath.ACTIVES.TICK_HEART, 4)
		player:AddCollectible(WorldWrath.PASSIVES.FRIENDLY_FIRE)
		player:AddNullCostume(
			Isaac.GetCostumeIdByPath("gfx/characters/character_bomber_balaclava.anm2")
		)
		player:AddNullCostume(
			Isaac.GetCostumeIdByPath("gfx/characters/gabriel_stoles.anm2")
		)
		
		-- TODO - Only execute when a run is starting
		player:AddHearts(-2)
		Chapil.AddHealth(player, "BOMB_HEART", 2)
	end
end
WorldWrath:AddCallback(
	ModCallbacks.MC_POST_PLAYER_INIT,
	OnBomberInit
)

local function OnStatsCacheEvaluation(_, player, flag)
	local stat = STAT_DIFFS[flag]
	player[stat.KEY] = player[stat.KEY] + stat.VALUE
end
WorldWrath:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	OnStatsCacheEvaluation,
	CacheFlag.CACHE_SPEED
)
WorldWrath:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	OnStatsCacheEvaluation,
	CacheFlag.CACHE_FIREDELAY
)
WorldWrath:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	OnStatsCacheEvaluation,
	CacheFlag.CACHE_SHOTSPEED
)
WorldWrath:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	OnStatsCacheEvaluation,
	CacheFlag.CACHE_LUCK
)

local function OnGameStarted(is_continued)
	game_is_continued = is_continued
end
WorldWrath:AddCallback(
	ModCallbacks.MC_POST_GAME_STARTED,
	OnGameStarted
)

---@param player EntityPlayer
local function OnBomberBUpdate(player)
	local entities = Isaac.GetRoomEntities()
	for _, entity in pairs(entities) do
		if entity.Type == WorldWrath.ENTITIES.BALL_AND_CHAIN.ID then
			
		end
	end
end
WorldWrath:AddCallback(
	ModCallbacks.MC_POST_PLAYER_UPDATE,
	OnBomberBUpdate
)