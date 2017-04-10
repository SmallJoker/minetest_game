local wield, hud, timer = {}, {}, {}
local timeout = 2

local function add_text(player)
	local player_name = player:get_player_name()
	hud[player_name] = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 1},
		offset = {x = 0, y = -75},
		alignment = {x = 0, y = 0},
		number = 0xFFFFFF,
		text = "",
	})
end

minetest.register_on_joinplayer(function(player)
	minetest.after(0, add_text, player)
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local wielded_item = player:get_wielded_item():get_name()

		if timer[player_name] and timer[player_name] < timeout then
			timer[player_name] = timer[player_name] + dtime
			if timer[player_name] > timeout and hud[player_name] then
				player:hud_change(hud[player_name], "text", "")
			end
		end

		if wielded_item ~= wield[player_name] then
			wield[player_name] = wielded_item
			timer[player_name] = 0

			if hud[player_name] then 
				local def = minetest.registered_items[wielded_item]
				local meta = player:get_wielded_item():get_meta()
				local meta_desc = meta:get_string("description")
				meta_desc = meta_desc:gsub("\27", ""):gsub("%(c@#%w%w%w%w%w%w%)", "")
				local description = meta_desc ~= "" and meta_desc or (def and def.description or "")

				player:hud_change(hud[player_name], "text", description)
			end
		end
	end
end)
