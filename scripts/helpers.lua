function shallowcopy(table)
	local copy = {}
	for k, v in pairs(table) do
			copy[k] = v
	end
	return copy
end

---@param v1 Vector
---@param v2 Vector
function distance(v1, v2)
	return math.sqrt(
		(v2.X - v1.X) ^ 2 +
		(v2.Y - v1.Y) ^ 2
	)
end

---Clears all kinds of vanilla hearts from
---the player, except the ones specified.
---@param player EntityPlayer
---@param except table<string, nil>
function FlushHealth(player, except)
	local vanilla_types_heart = {
		"BlackHearts",
		"BoneHearts",
		"BrokenHearts",
		"EternalHearts",
		"GoldenHearts",
		"Hearts",
		"MaxHearts",
		"RottenHearts",
		"SoulHearts"
	}
	for _, type_heart in pairs(vanilla_types_heart) do
		if not except[type_heart] then
			local get_hearts = player["Get" .. type_heart]
			local add_hearts = player["Add" .. type_heart]
	
			local num_type_hearts = get_hearts(player)
			add_hearts(player, -num_type_hearts)
		end
	end
end

---Decreases all kinds of hearts by the hits specified.
---@param player EntityPlayer
---@param hits table<string, number>
function DecreaseHealth(player, hits)
	local heart_keys = {
		"ETERNAL_HEART",
		"GOLDEN_HEART",
		"RED_HEART",
		"COIN_HEART",
		"ROTTEN_HEART",
		"EMPTY_HEART",
		"EMPTY_COIN_HEART",
		"BONE_HEART",
		"SOUL_HEART",
		"BLACK_HEART",
		"BOMB_HEART",
		"BROKEN_HEART",
		"BROKEN_COIN_HEART"
	}
	for _, heart_key in pairs(heart_keys) do
		if hits[heart_key] then
			if heart_key == "BLACK_HEART" then
				local other_health = {}
				for i, slot in pairs(Chapil.GetHealthInOrder(player)) do
					table.insert(other_health, {})
					for type, heart in pairs(slot) do
						if heart.Key ~= "RED_HEART" and heart.Key ~= "EMPTY_HEART" then
							other_health[i][type] = shallowcopy(heart)
						end
					end
				end
				local black_hearts = Chapil.GetHPOfKey(player, "BLACK_HEART")
				FlushHealth(player, {
					Hearts = "stupid lua",
					MaxHearts = "stupid lua"
				})

				local black_count = 0
				for _, slot in pairs(other_health) do
					for _, heart in pairs(slot) do
						if heart.Key == "BLACK_HEART" then
							-- ISSUE - Sacrifice rooms take two hits
							black_count = black_count + heart.HP
							if black_count <= black_hearts - 2 + (black_hearts % 2) then
								Chapil.AddHealth(player, heart.Key, heart.HP)
							end
						else
							Chapil.AddHealth(player, heart.Key, heart.HP)
						end
					end
				end
			else
				Chapil.AddHealth(player, heart_key, -hits[heart_key])
			end
		end
	end
end

---@param player EntityPlayer
---@return string
function GetPlayerID(player)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NULL)
	return tostring(rng:GetSeed())
end

function LogPrint(text)
	Isaac.DebugString(text)
end