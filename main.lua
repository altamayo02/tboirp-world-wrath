include("scripts.lib.customhealthapi.core")
Chapil = CustomHealthAPI.Library

DEBUG = false

---@class ModReference
WorldWrath = RegisterMod("World Wrath", 1)
WorldWrath.GAME = Game()
WorldWrath.ACTIVES = {
	TICK_HEART = Isaac.GetItemIdByName("Tick Heart")
}
WorldWrath.PASSIVES = {
	FRIENDLY_FIRE = Isaac.GetItemIdByName("Friendly Fire")
}
WorldWrath.PICKUPS = {
	BOMB_HEART = {
		ID = Isaac.GetEntityTypeByName("Bomb Heart"),
		VARIANT = Isaac.GetEntityVariantByName("Bomb Heart"),
		SUBTYPE = 48,
		EXPLODE_CHANCE = 0.5,
		spawn_chance = 0.01
	}
}
WorldWrath.ENTITIES = {
	BALL_AND_CHAIN = {
		ID = Isaac.GetEntityTypeByName("Ball and Chain"),
		VARIANT = Isaac.GetEntityTypeByName("Ball and Chain"),
		SUBTYPE = 0
	}
}

WorldWrath.save_data = {}
function WorldWrath:OnGameExit()

end
WorldWrath:AddCallback(
	ModCallbacks.MC_PRE_GAME_EXIT,
	WorldWrath.OnGameExit
)

if DEBUG then
	WorldWrath:AddCallback(
		ModCallbacks.MC_POST_GAME_STARTED,
		function()
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE,
				WorldWrath.ACTIVES.TICK_HEART,
				Vector(80, 400),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE,
				WorldWrath.PASSIVES.FRIENDLY_FIRE,
				Vector(560, 400),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_HEART,
				HeartSubType.HEART_BONE,
				Vector(240, 160),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_HEART,
				HeartSubType.HEART_BONE,
				Vector(240, 200),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_HEART,
				HeartSubType.HEART_FULL,
				Vector(280, 160),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_HEART,
				HeartSubType.HEART_FULL,
				Vector(280, 200),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_HEART,
				HeartSubType.HEART_ETERNAL,
				Vector(200, 160),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_HEART,
				HeartSubType.HEART_GOLDEN,
				Vector(440, 160),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_HEART,
				HeartSubType.HEART_ROTTEN,
				Vector(400, 160),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_HEART,
				WorldWrath.PICKUPS.BOMB_HEART.SUBTYPE,
				Vector(360, 160),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE,
				CollectibleType.COLLECTIBLE_HEARTBREAK,
				Vector(560, 160),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_FIREPLACE,
				0,
				0,
				Vector(320, 280),
				Vector.Zero,
				nil
			)
			for _ = 1, 1, 1 do
				Isaac.Spawn(
					EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_HEART,
					HeartSubType.HEART_SOUL,
					Vector(280, 400),
					Vector.Zero,
					nil
				)
			end
			for _ = 1, 1, 1 do
				Isaac.Spawn(
					EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_HEART,
					HeartSubType.HEART_BLACK,
					Vector(360, 400),
					Vector.Zero,
					nil
				)
			end
		end
	)
end

include("scripts.helpers")

include("scripts.bomb_heart")

include("scripts.tick_heart")
include("scripts.friendly_fire")

include("scripts.bomber")
include("scripts.tainted_bomber")