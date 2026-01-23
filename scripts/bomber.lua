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