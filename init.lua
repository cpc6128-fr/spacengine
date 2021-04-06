--************************************
--*** SPACENGINE 202007 by CPC6128 ***
--************************************

spacengine = {}
spacengine.area = {}
spacengine.pirate = ""
spacengine.creative_enable = 1
local mp=minetest.get_modpath("spacengine")
dofile( mp .. "/routine.lua")
dofile(mp .. "/data.lua")
dofile(mp .. "/commande.lua")
dofile(mp .. "/operation.lua")
dofile(mp .. "/mise_a_jour.lua")
dofile(mp .. "/machine.lua")
dofile(mp .. "/oxygene.lua")
dofile(mp .. "/gui.lua")
dofile(mp .. "/fields.lua")
dofile(mp .. "/switch.lua")
dofile(mp .. "/screen.lua")
dofile(mp .. "/environnement.lua")

minetest.register_tool("spacengine:tool", {
	description = "spacengine tool",
	inventory_image = "spacengine_clef.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[333]=1}, uses = 50, maxlevel=1},
		},
		damage_groups = {fleshy=1},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "spacengine:tool",
    recipe = {
        {"default:mese_crystal", "", ""},
        {"", "default:steel_ingot", ""},
        {"", "", "default:steel_ingot"}
    }
})
--[[
minetest.register_tool("spacengine:tool_admin", {
	description = "spacengine admin tool",
	inventory_image = "spacengine_clef_admin.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[333]=1}, uses = 50, maxlevel=1},
		},
		damage_groups = {fleshy=1},
	},
	sound = {breaks = "default_tool_breaks"},
})
--]]
local items={
{"spacengine","controler",2500},
{"spacengine","battery",2500},
{"spacengine","power",3500},
{"spacengine","engine",5000},
{"spacengine","shield",4500},
{"spacengine","weapons",6000},
{"spacengine","radar",7500},
{"spacengine","gravitation",7000},
{"spacengine","container",1500},
{"spacengine","container2",1500},
{"spacengine","container3",1500},
{"spacengine","passenger",1000},
{"spacengine","oxygene",2500},
{"spacengine","manutention",8000},
{"spacengine","radio",1000},
{"monitor","screen_up",850},
{"monitor","screen_wall",750},
{"monitor","screen_console",600},
{"monitor","screen_down",800},
{"monitor","console_base",500},
{"monitor","screen_led",500},
{"monitor","screen_aim",10000},
{"monitor","screen_transparent",800},
{"spacengine","switch_bp",1000},
{"spacengine","switch_emergency",1200},
{"spacengine","switch_4bp1",3000},
{"spacengine","switch_4bp2",3000},
{"spacengine","switch_4bp3",3000},
{"spacengine","switch_4bp4",3000},
{"spacengine","switch_4bp5",3000},
{"spacengine","inter_0",1500},
{"spacengine","i0",2500},
{"spacengine","levier0",2000},
{"spacengine","analog00",1500},
{"spacengine","analog10",1750},
{"spacengine","rotator00",1500},
{"spacengine","gouvernail",1500},
{"spacengine","info",1500},
{"spacengine","command1",1500},
{"spacengine","command2",1500},
{"spacengine","spaceship",50}
}

local spc_formspec = 
	"size[8,9]" ..
  "button_exit[0,3;2,1;exit;exit]"..
	"list[current_player;main;0,4.85;8,1;]" ..
	"list[current_player;main;0,6.08;8,3;8]"..
  "textlist[2,1;4,3;spc;"
local spc_showitem="item_image_button[6,1;2,2;"..items[1][1]..":".. items[1][2] ..";buy;"..items[1][3].."]"

for i=1,#items do
  spc_formspec=spc_formspec..items[i][2].." : ".. items[i][3]
  if i<#items then
    spc_formspec = spc_formspec..","
  else
    spc_formspec = spc_formspec.."]"
  end
end

minetest.register_node("spacengine:builder", {
	description = "spacengine Node Dealer",
	tiles = {
		"spacengine_shop_node.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {unbreakable = 1, not_in_creative_inventory = 1},--{cracky=1, oddly_breakable_by_hand=1},
  on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", spc_formspec)
		meta:set_string("infotext", "spacengine Dealer")
	end,
--[[
  on_punch=function(pos,node,player)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", spc_formspec)
  end,
--]]
  on_receive_fields=function(pos,formname,fields,sender)

    if fields.spc then --choix item
      local showitem=string.split(fields.spc,":")
      local nb=tonumber(showitem[2])
      local meta = minetest.get_meta(pos)
      spc_showitem="item_image_button[6,1;2,2;".. items[nb][1] ..":".. items[nb][2] ..";buy;".. nb .."]"
      meta:set_string("formspec", spc_formspec..spc_showitem)
    end

    if fields.buy~=nil then --achat bloc
      local nb=tonumber(fields.buy)
      local stack=items[nb][1]..":"..items[nb][2]
      local inv = sender:get_inventory()
      local name=sender:get_player_name()

      if spacengine.transaction(sender,nil,items[nb][3]) then --si card presente
        inv:add_item("main",stack)
      end
    end
  end
})

--save list spaceship
function spacengine.save_area()

	local f, err = io.open(minetest.get_worldpath() .. "/spacengine_area", "w")
	f:write(minetest.serialize(spacengine.area))
	f:close()

  f, err = io.open(minetest.get_worldpath() .. "/spacengine_pirate", "w")
	f:write(minetest.serialize(spacengine.pirate))
	f:close()

end

-- load list spaceship
function spacengine.read_area()

	local f, err = io.open(minetest.get_worldpath() .. "/spacengine_area", "r")
  if f then
    spacengine.area = minetest.deserialize(f:read("*a"))
    f:close()
  end

  f, err = io.open(minetest.get_worldpath() .. "/spacengine_pirate", "r")
  if f then
    spacengine.pirate = minetest.deserialize(f:read("*a"))
    f:close()
  end

end

minetest.register_on_shutdown(function()
		spacengine.save_area()
end)

spacengine.read_area()
--
--*** init position ***
--[[
minetest.register_lbm({
name="spacengine:change_area_controler",
nodenames = {"spacengine:controler"},
run_at_every_load = true,
action = function(pos,node)
  local cont_met = minetest.get_meta(pos)
  local channel=cont_met:get_string("channel")

  if channel=="" then return end --en cas d'erreur
  
  if string.find(channel,"No channel:") then return end

  if spacengine.area[channel]==nil then return end
    --local spl_cha=string.split(channel,":")
   -- spacengine.test_area_ship(pos,1,channel,spl_cha[2])
 -- end
  --reset temps ecouler
  spacengine.area[channel].config[14]=minetest.get_us_time()+4500000

  if spacengine.area[channel].config[1][1]>0 then
    local timer=minetest.get_node_timer(pos)
    if not timer:is_started() then timer:set(5,0) end
  end
end
})
--]]

local function spaceship_dealer(channel,idx)
local formspec= "size[9,5]button_exit[0,4;2,1;cancel;cancel]field[0.25,0;3,1;channel;;".. channel .."]label[2,1;Spaceship list]textlist[2,1.5;6,1.3;achat;"
      for i=1,#spacengine.vaisseaux do
        formspec=formspec.. spacengine.vaisseaux[i][5] .." : ".. spacengine.vaisseaux[i][4] .." Mg "
        if i<#spacengine.vaisseaux then formspec=formspec.."," end
      end
      formspec=formspec..";".. idx ..";]"
  return formspec
end

minetest.register_node("spacengine:spaceship", {
	description = "Spaceship Dealer",
	tiles = {
		"spacengine_achat.png"
	},
	paramtype = "light",
	groups = {cracky = 1, not_in_creative_inventory = 1},
  on_construct = function(pos)
    local formspec=spaceship_dealer("No channel",1)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "spaceship Dealer")
    meta:set_string("formspec",formspec)
	end,
  on_receive_fields=function(pos,formname,fields,sender)

    if fields.quit then return end

    local choice=1
    local plname=sender:get_player_name()
    local new_form=true

    if fields.channel=="" then
      fields.channel="No channel"
    end

    if fields.achat then
    if string.find(fields.achat,"CHG:") then
      fields.achat=string.gsub(fields.achat,"CHG:","")
      choice=tonumber(fields.achat)
    end

    if string.find(fields.achat,"DCL") then
      fields.achat=string.gsub(fields.achat,"DCL:","")
      choice=tonumber(fields.achat)
      local tmp=tonumber(string.sub(spacengine.vaisseaux[choice][2],5,6))+2
      local newpos={x=pos.x,y=pos.y+tmp,z=pos.z}

      local vaisseaux=sender:get_attribute("vaisseaux")
      if vaisseaux==nil then vaisseaux="" end

      if string.find(vaisseaux,fields.channel) or fields.channel=="No channel" then return end

      if spacengine.check_free_place(newpos,plname,spacengine.vaisseaux[choice][2])~=true then return end

      if spacengine.transaction(sender,nil,spacengine.vaisseaux[choice][4]) then
        sender:set_attribute("vaisseaux",vaisseaux..fields.channel..":")
        minetest.remove_node(pos)
        spacengine.place_ship(newpos, plname, fields.channel..":"..plname, spacengine.vaisseaux[choice])
        spacengine.test_area_ship(newpos,1,fields.channel..":"..plname,plname)
        spacengine.area[fields.channel..":"..plname].config[1][1]=0
        spacengine.area[fields.channel..":"..plname].config[1][7]=0
        spacengine.maj_pos_node(newpos,plname,fields.channel..":"..plname,0)

        new_form=false
      end
    end
    end

    if new_form then
      local meta = minetest.get_meta(pos)
      meta:set_string("formspec",spaceship_dealer(fields.channel,choice))
    end

  end,
})

