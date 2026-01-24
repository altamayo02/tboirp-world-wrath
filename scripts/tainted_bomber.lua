local STAT_DIFFS = {
	[CacheFlag.CACHE_LUCK] = {
		KEY = "Luck",
		VALUE = -4
	},
	[CacheFlag.CACHE_SPEED] = {
		KEY = "MoveSpeed",
		VALUE = -0.75
	}
}
---@type EntityFamiliar[]
local balls_and_chains


---@param player EntityPlayer
local function OnBomberBInit(_, player)
	local bomber_b_id = Isaac.GetPlayerTypeByName("The Bomber", true)
	if player:GetPlayerType() == bomber_b_id then
		player:AddNullCostume(
			Isaac.GetCostumeIdByPath("gfx/characters/character_bomber_balaclava.anm2")
		)
		player:AddCollectible(CollectibleType.COLLECTIBLE_SAMSONS_CHAINS)
		player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
		
		-- TODO - Only execute when a run is starting
		player:AddHearts(-2)
		Chapil.AddHealth(player, "BOMB_HEART", 2)
	end
end
WorldWrath:AddCallback(
	ModCallbacks.MC_POST_PLAYER_INIT,
	OnBomberBInit
)

local function OnStatsCacheEvaluate(_, player, flag)
	local stat = STAT_DIFFS[flag]
	if stat then
		player[stat.KEY] = player[stat.KEY] + stat.VALUE
	end
end
WorldWrath:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	OnStatsCacheEvaluate
)

---@param player EntityPlayer
local function OnFamiliarCacheEvaluate(_, player)
	local player_effects = player:GetEffects()
	local count_bnc = player_effects:GetCollectibleEffectNum(
		CollectibleType.COLLECTIBLE_SAMSONS_CHAINS
	) + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_SAMSONS_CHAINS)

	local rng_bnc = RNG()
	rng_bnc:SetSeed(math.max(Random(), 1), 35)

	local config_bnc = Isaac.GetItemConfig():GetCollectible(
		CollectibleType.COLLECTIBLE_SAMSONS_CHAINS
	)

	player:CheckFamiliar(
		FamiliarVariant.SAMSONS_CHAINS,
		count_bnc,
		rng_bnc,
		config_bnc
	)
	balls_and_chains = Isaac.FindByType(
		EntityType.ENTITY_FAMILIAR,
		FamiliarVariant.SAMSONS_CHAINS
	)

	if DEBUG then
		for i, bnc in pairs(balls_and_chains) do
			print(i .. "------------------")
			print("Position: " .. tostring(bnc.Position))
			print("CollDmg: " .. bnc.CollisionDamage)
			print("EntityColl: " .. bnc.EntityCollisionClass)
			print("GridColl: " .. bnc.GridCollisionClass)
			print("Friction: " .. bnc.Friction)
			print("Mass: " .. bnc.Mass)
			print("Size: " .. bnc.Size)
			print("Visible: " .. tostring(bnc.Visible))
		end
	end
end
WorldWrath:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	OnFamiliarCacheEvaluate,
	CacheFlag.CACHE_FAMILIARS
)

---@param bnc EntityFamiliar
local function OnBallAndChainUpdate(bnc)
	if distance(bnc.Position, bnc.SpawnerEntity.Position) >= 60 then
		bnc.SpawnerEntity.Velocity = Vector.Zero
	end
end
WorldWrath:AddCallback(
	ModCallbacks.MC_FAMILIAR_UPDATE,
	OnBallAndChainUpdate,
	FamiliarVariant.SAMSONS_CHAINS
)