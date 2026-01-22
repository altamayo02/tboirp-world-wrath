---@param player EntityPlayer
local function OnTickHeartUse(mod, item_id, rng, player, use_flags, slot, data)
	print("-----------------------")
	Chapil.AddHealth(player, "BOMB_HEART", 2)
	return {
		Discharge = true,
		Remove = false,
		ShowAnim = true
	}
end
WorldWrath:AddCallback(
	ModCallbacks.MC_USE_ITEM,
	OnTickHeartUse,
	WorldWrath.ACTIVES.TICK_HEART
)