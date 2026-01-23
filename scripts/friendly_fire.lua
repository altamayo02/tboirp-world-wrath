local BUFF_PER_HEART_HIT = {
	ETERNAL_HEART = 1,
	GOLDEN_HEART = 0.5,
	RED_HEART = 0.3,
	COIN_HEART = 0.3,
	ROTTEN_HEART = 0.15,
	EMPTY_HEART = 1,
	EMPTY_COIN_HEART = 1,
	BONE_HEART = 1,
	SOUL_HEART = 0.2,
	BLACK_HEART = 0.25,
	BOMB_HEART = 0,
	BROKEN_HEART = 0,
	BROKEN_COIN_HEART = 0
}
local STAT_PER_BUFF = {
	[CacheFlag.CACHE_DAMAGE] = {
		KEY = "Damage",
		VALUE = 0.3
	},
	[CacheFlag.CACHE_FIREDELAY] = {
		KEY = "MaxFireDelay",
		VALUE = -0.9
	},
	[CacheFlag.CACHE_SHOTSPEED] = {
		KEY = "ShotSpeed",
		VALUE = 0.05
	},
	[CacheFlag.CACHE_LUCK] = {
		KEY = "Luck",
		VALUE = 1
	}
}
local STAT_CHANCES = {
	CacheFlag.CACHE_DAMAGE,
	CacheFlag.CACHE_DAMAGE,
	CacheFlag.CACHE_FIREDELAY,
	CacheFlag.CACHE_FIREDELAY,
	CacheFlag.CACHE_SHOTSPEED,
	CacheFlag.CACHE_SHOTSPEED,
	CacheFlag.CACHE_SHOTSPEED,
	CacheFlag.CACHE_LUCK
}
--- @type table<string, table<string, integer>>
local queue_bombed = {}
--- @type table<string, table<CacheFlag, number>>
local added_stats = {}
--- @type CacheFlag
local next_stat = CacheFlag.CACHE_ALL


---@param player EntityPlayer
---@param heart_damages table<string, integer>
local function OnHealthSlotBombed(_, player, heart_damages)
	local player_id = GetPlayerID(player)
	queue_bombed[player_id] = heart_damages

	local rng = player:GetCollectibleRNG(WorldWrath.PASSIVES.FRIENDLY_FIRE):Next()
	next_stat = STAT_CHANCES[(rng % 8) + 1]
	player:AddCacheFlags(next_stat)
	player:EvaluateItems()
end
WorldWrath:AddCallback(
	"POST_HEART_BOMBED",
	OnHealthSlotBombed
)

---Increases one of Isaac's stats based on the slots a bomb heart has damaged
---@param player EntityPlayer
local function OnStatsCacheEvaluation(_, player, flag)
	local player_id = GetPlayerID(player)
	local player_added_stats = added_stats[player_id]
	if player_added_stats and flag == next_stat then
		local total_buff = 0
		if next_stat ~= CacheFlag.CACHE_LUCK then
			for heart_key, hits in pairs(queue_bombed[player_id]) do
				total_buff = total_buff + BUFF_PER_HEART_HIT[heart_key] * hits
			end
		else
			total_buff = 1
		end

		local spb = STAT_PER_BUFF[next_stat]
		player_added_stats[next_stat] = (
			player_added_stats[next_stat] + spb.VALUE * total_buff
		)
		player[spb.KEY] = player[spb.KEY] + player_added_stats[next_stat]

		queue_bombed[player_id] = {}
		next_stat = CacheFlag.CACHE_ALL
	end
end
WorldWrath:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	OnStatsCacheEvaluation,
	CacheFlag.CACHE_DAMAGE
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

---@param player EntityPlayer
local function OnPlayerInit(_, player)
	if player:HasCollectible(WorldWrath.PASSIVES.FRIENDLY_FIRE) then
		local player_id = GetPlayerID(player)
		queue_bombed[player_id] = {}
		added_stats[player_id] = {
			[CacheFlag.CACHE_DAMAGE] = 0,
			[CacheFlag.CACHE_FIREDELAY] = 0,
			[CacheFlag.CACHE_SHOTSPEED] = 0,
			[CacheFlag.CACHE_LUCK] = 0
		}
	end
end
WorldWrath:AddPriorityCallback(
	ModCallbacks.MC_POST_PLAYER_INIT,
	CallbackPriority.LATE,
	OnPlayerInit
)

---@param player EntityPlayer
local function OnFriendlyFireCollect(_, player)
	if player:HasCollectible(WorldWrath.PASSIVES.FRIENDLY_FIRE) then
		WorldWrath.PICKUPS.BOMB_HEART.spawn_chance = 0.1
	end
end
WorldWrath:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	OnFriendlyFireCollect,
	CacheFlag.CACHE_COLOR
)