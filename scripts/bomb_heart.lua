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
		local hits = heart.HP
		if hits == 0 then
			hits = 1
		elseif heart.Key == "BOMB_HEART" or heart.Key == "ROTTEN_HEART" then
			hits = 2
		end
		damages[heart.Key] = hits
	end
	if (
		player:GetEternalHearts() ~= 0 and
		(
			-- Eternal heart is on a heart container
			player:GetEffectiveMaxHearts() == 2 * index_slot or
			-- Eternal heart is on another kind of heart
			(player:GetEffectiveMaxHearts() == 0 and index_slot == 2)
		)
 	) then
		damages = {
			ETERNAL_HEART = 1
		}
	end

	if DEBUG then
		local str = ""
		for heart_key, hits in pairs(damages) do
			str = str .. heart_key .. ": " .. hits .. "; "
		end
		print(str)
	end

	DecreaseHealth(player, damages)
	Isaac.RunCallback("POST_HEART_BOMBED", player, damages)
end


---@param pickup EntityPickup
---@param variant integer
---@param subtype integer
local function OnPickupSelect(pickup, variant, subtype)
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
	OnPickupSelect,
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
local function OnBombHeartCollide(_, pickup, collider)
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
	OnBombHeartCollide,
	WorldWrath.PICKUPS.BOMB_HEART.VARIANT
)

---@param player EntityPlayer
---@param heart_key string
local function OnBombHeartLose(
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
			
			local indices = {
				Left = {
					[index ~= 6] = index
				},
				Up = {
					[index >= 6] = (index % 6) + 1
				},
				Right = {
					[index ~= 5 and num_broken_hearts ~= 0] = #hearts + 2
				},
				Down = {
					[num_broken_hearts >= 6] = index + 6
				}
			}
			for direction, slot_index in pairs(indices) do
				if slot_index[true] then
					RemoveBombedHearts(player, slot_index[true])
					if DEBUG then
						print(direction)
					end
				end
			end

			WorldWrath.GAME:BombExplosionEffects(
				player.Position,
				100,
				player:GetBombFlags(),
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
	OnBombHeartLose
)