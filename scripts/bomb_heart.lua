Chapil.RegisterSoulHealth(
	"BOMB_HEART",
	{
		AddPriority = 200,
		AnimationFilename = "gfx/ui/bomb_hearts.anm2",
		AnimationName = {
			"BombHeart"
		},
		CanHaveHalfCapacity = false,
		HealFlashRO = 80/255,
		HealFlashGO = 80/255,
		HealFlashBO = 0,
		MaxHP = 1,
		PickupEntities = {
			{
				ID = EntityType.ENTITY_PICKUP,
				Var = WorldWrath.PICKUPS.BOMB_HEART,
				Sub = 48
			}
		},
		PrioritizeHealing = false,
		SortOrder = 150,
		SumptoriumCollectSoundSettings = {
			ID = 900,
			Volume = 1.0,
			FrameDelay = 0,
			Loop = false,
			Pitch = 1.0,
			Pan = 0
		},
		SumptoriumSplatColor = Color(1.0, 1.0, 1.0, 1.0),
		SumptoriumSubType = 920,
		SumptoriumTrailColor = Color(0.1, 0.1, 0.5, 0.4)
	}
)

---Removes the player's health from a provided slot.
---@param player EntityPlayer
---@param index_slot integer
local function RemoveBombedHearts(player, index_slot)
	local hearts = Chapil.GetHealthInOrder(player)
	local damaged_slot = hearts[index_slot]
	
	local damages = {}
	for _, heart in pairs(damaged_slot) do
		if heart.Key ~= "" then
			local hits = heart.HP
			if hits == 0 then
				hits = 1
			elseif heart.Key == "BOMB_HEART" then
				hits = 2
			end
			damages[heart.Key] = hits
		end
	end
	if (
		player:GetEternalHearts() ~= 0 and
		(
			player:GetEffectiveMaxHearts() == 2 * index_slot or
			(player:GetEffectiveMaxHearts() == 0 and index_slot == 2)
		)
 	) then
		damages = {
			ETERNAL_HEART = 1
		}
	end
	local str = ""
	for heart_key, hits in pairs(damages) do
		str = str .. heart_key .. ": " .. hits .. "; "
	end
	print(str)

	DecreaseHealth(player, damages)
	Isaac.RunCallback("POST_HEART_BOMBED", player, damages)
end


---@param pickup EntityPickup
---@param variant integer
---@param subtype integer
local function OnPickupSelection(pickup, variant, subtype)
	local subtypes = {
		[HeartSubType.HEART_FULL] = "stupid lua",
		[HeartSubType.HEART_HALF] = "stupid lua",
		[HeartSubType.HEART_SOUL] = "stupid lua",
		[HeartSubType.HEART_HALF_SOUL] = "stupid lua",
		[HeartSubType.HEART_BLACK] = "stupid lua"
	}
	if variant == PickupVariant.PICKUP_HEART and subtypes[subtype] then
		local rng = pickup:GetDropRNG():Next()
		if (
			rng % math.floor(WorldWrath.PICKUPS.BOMB_HEART.spawn_chance ^ -1) == 1
	 	) then
			return {
				WorldWrath.PICKUPS.BOMB_HEART.VARIANT,
				WorldWrath.PICKUPS.BOMB_HEART.SUBTYPE
			}
		end
	end
	return nil
end
WorldWrath:AddCallback(
	ModCallbacks.MC_POST_PICKUP_SELECTION,
	OnPickupSelection,
	EntityType.ENTITY_PICKUP
)

---@param pickup EntityPickup
local function OnBombHeartSpawn(_, pickup)
	if pickup.SubType ~= WorldWrath.PICKUPS.BOMB_HEART.SUBTYPE then
		return
	end

	local sprite = pickup:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", false)
	end
	if sprite:IsPlaying("Collect") and sprite:GetFrame() == 5 then
		pickup:Remove()
	end
	if sprite:IsEventTriggered("DropSound") then
		SFXManager():Play(Isaac.GetSoundIdByName(
			"Bomb Heart Drop"
		), 0.8, 0, false, 0.4)
	end
end
WorldWrath:AddCallback(
	ModCallbacks.MC_POST_PICKUP_UPDATE,
	OnBombHeartSpawn,
	WorldWrath.PICKUPS.BOMB_HEART.VARIANT
)

---@param pickup EntityPickup
---@param collider Entity
---@return boolean | nil
local function OnBombHeartCollision(_, pickup, collider)
	local player = collider:ToPlayer()
	if (
		not player or
		pickup.SubType ~= WorldWrath.PICKUPS.BOMB_HEART.SUBTYPE
	) then
		return nil
	end
	local pickup_sprite = pickup:GetSprite()
	
	if pickup_sprite:IsPlaying("Collect") or (
		pickup:IsShopItem() and pickup.Price > player:GetNumCoins()
	) then
		return true
	elseif pickup.Wait > 0 then
		return not pickup_sprite:IsPlaying("Idle")
	elseif (
		pickup_sprite:WasEventTriggered("DropSound") or
		pickup_sprite:IsPlaying("Idle")
	) then
		if Chapil.CanPickKey(player, "BOMB_HEART") then
			Chapil.AddHealth(player, "BOMB_HEART", 2)
			SFXManager():Play(Isaac.GetSoundIdByName(
				"Bomb Fuse Fizzle"
			), 1, 0, false, 1)
		else
			return pickup:IsShopItem()
		end

		if pickup.OptionsPickupIndex ~= 0 then
			local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
			for _, p in ipairs(pickups) do
				if p:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and (
					p.Index ~= pickup.Index or p.InitSeed ~= pickup.InitSeed
				)	then
					Isaac.Spawn(
						EntityType.ENTITY_EFFECT,
						EffectVariant.POOF01,
						0,
						p.Position,
						Vector.Zero,
						nil
					)
					p:Remove()
				end
			end
		end

		if pickup:IsShopItem() then
			local hold_sprite = Sprite()
			
			hold_sprite:Load(pickup_sprite:GetFilename(), true)
			hold_sprite:Play(pickup_sprite:GetAnimation(), true)
			hold_sprite:SetFrame(pickup_sprite:GetFrame())
			player:AnimatePickup(hold_sprite)
			
			if pickup.Price > 0 then
				player:AddCoins(-pickup.Price)
			end
			
			Chapil.TriggerRestock(pickup)
			CustomHealthAPI.Helper.TryRemoveStoreCredit(player)
			
			pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			pickup:Remove()
		else
			pickup_sprite:Play("Collect", true)
			pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			pickup:Die()
		end

		Game():GetLevel():SetHeartPicked()
		Game():ClearStagesWithoutHeartsPicked()
		Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)

		return true
	else
		return false
	end
end
WorldWrath:AddPriorityCallback(
	ModCallbacks.MC_PRE_PICKUP_COLLISION,
	CallbackPriority.LATE,
	OnBombHeartCollision,
	WorldWrath.PICKUPS.BOMB_HEART.VARIANT
)

---@param player EntityPlayer
---@param heart_key string
local function OnBombHeartLoss(
	player,
	dmg_flags,
	heart_key,
	hp,
	was_depleted,
	was_last_damaged
)
	if heart_key == "BOMB_HEART" then
		local rng = player:GetDropRNG():Next()
		if (
			rng % math.floor(WorldWrath.PICKUPS.BOMB_HEART.EXPLODE_CHANCE ^ -1) == 1
		) then
			local hearts = Chapil.GetHealthInOrder(player)
			local num_broken_hearts = player:GetBrokenHearts()
			local index = #hearts - num_broken_hearts
	
			if index ~= 6 then
				local index_left = index
				RemoveBombedHearts(player, index_left)
				print("Left")
			end
			if index >= 6 then
				local index_above = (index % 6) + 1
				RemoveBombedHearts(player, index_above)
				print("Up")
			end
			if index ~= 5 and num_broken_hearts ~= 0 then
				local index_right = #hearts + 2
				RemoveBombedHearts(player, index_right)
				print("Right")
			end
			if num_broken_hearts >= 6 then
				local index_below = index + 6
				RemoveBombedHearts(player, index_below)
				print("Down")
			end
	
			WorldWrath.GAME:BombExplosionEffects(
				player.Position,
				100,
				TearFlags.TEAR_NORMAL,
				Color.Default,
				player
			)
		end
	end
end
Chapil.AddCallback(
	"World Wrath",
	CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED,
	0,
	OnBombHeartLoss
)