--[[
SPACENGINE 2020 by CPC6128

sound : lasonotheque.org

channel=nom du vaisseaux
--]]

--protect en cas de dig si channel~="No channel"-->pas de destruction
spacengine.can_dig=function(pos,player)

  if player and player:is_player() and minetest.is_protected(pos, player:get_player_name()) then
		-- protected
		return false
	end

  local node=minetest.get_node(pos)
  local group=minetest.get_item_group(node.name,"spacengine")
  local check,tool=spacengine.owner_check(player,pos)

  if group==1 then

    --only captain can be destruct
    if check<4 then
      return false
    else
      --only No channel can be destruct
      local channel = minetest.get_meta(pos):get_string("channel")
      if not string.find(channel,"No channel:") then return false end
    end

  else
    if check<3 or tool~="spacengine:tool" then return false end
  end

  return true
end

--option = * tool / & MaJ disable / ~ screen / < param / > value / + submenu 1 accept upgrade, 2 accept repar
spacengine.rightclick=function(pos, node, player, maj)

  local meta = minetest.get_meta(pos)
  local vente = meta:get_string("vente")
  local plname=player:get_player_name()
  local check,tool = spacengine.owner_check(player,pos,nil,vente)

  --local inv = meta:get_inventory()
  --inv:set_size("book", 1)

  if check==1 and tool=="spacengine:tool" then
    spacengine.chg_form[plname]={}
    spacengine.chg_form[plname].option="+5"
    spacengine.chg_form[plname].check=check
    return spacengine.formspec_update(pos,player)
  end
--[[
  if check<2 and tool=="spacengine:tool_admin" then

    if minetest.get_item_group(node.name,"spacengine")==1 then
      local channel=meta:get_string("channel")
      local captain=meta:get_string("captain")

      --remove ship list player
      if captain=="pirate_team" then
        spacengine.pirate=string.gsub(spacengine.pirate,channel ..":" ,"")
      else
        --retire le ship de la liste du vendeur
        local player2=minetest.get_player_by_name(captain)
        local vaisseaux2=player2:get_attribute("vaisseaux")
        vaisseaux2=string.gsub(vaisseaux2,channel..":","")
        player2:set_attribute("vaisseaux",vaisseaux2)
      end

      spacengine.test_area_ship(pos, -1, channel, captain)

      spacengine.sell_ship(pos, channel, player:get_player_name(),player:get_player_name())

      spacengine.save_area()

    end
    return false
  end
--]]
  if check<2 then return false end

  spacengine.chg_form[plname]={}
  spacengine.chg_form[plname].idx=1
  spacengine.chg_form[plname].check=check

  --outils parametrage
  if tool == "spacengine:tool" then

    if minetest.get_item_group(node.name,"spacengine")==12 then
      if maj then
        spacengine.chg_form[plname].option="-&"
        return spacengine.formspec_update(pos,player) -- screen bloque maj
      else
        spacengine.chg_form[plname].option="-"
        return spacengine.formspec_update(pos,player) -- screen
      end
    end

    --acces configuration
    if maj==nil then
      spacengine.chg_form[plname].option="*"
      return spacengine.formspec_update(pos,player) -- tool
    else
      spacengine.chg_form[plname].option="*&"
      return spacengine.formspec_update(pos,player) -- bloque maj
    end
  end

  if minetest.get_item_group(node.name,"spacengine")==12 then
    spacengine.chg_form[plname].option="<"
    return spacengine.formspec_update(pos,player) -- param
  elseif minetest.get_item_group(node.name,"spacengine")==18 then
    return
  end

end

spacengine.construct_node=function(pos,module_name,data,group)

  local meta = minetest.get_meta(pos)
  if group==nil then group=0 end

  if group==1 then
    local inv = meta:get_inventory()
    inv:set_size("stock", 6)
    inv:set_size("book", 1)
    meta:set_string("stock_pos","33333#0#0")
    meta:set_string("pos_cont",minetest.pos_to_string({x=pos.x,y=pos.y,z=pos.z}))
  else
    meta:set_string("pos_cont",minetest.pos_to_string({x=33333,y=0,z=0}))
  end

  meta:set_string("channel","No channel:noplayer")
  meta:set_string("spacengine",data)
  

  if group==12 then --screen stockage texte
    monitor.construct_sign(pos,nil,true)
  else
    meta:set_string("infotext",module_name)--name
  end

end

spacengine.placer_node=function(pos,placer)
  local node=minetest.get_node(pos)
  local group=minetest.get_item_group(node.name,"spacengine")
  local nod_met = minetest.get_meta(pos)
  local plname=placer:get_player_name()
  
  if group==1 then
    nod_met:set_string("channel","No channel:"..plname)
    nod_met:set_string("captain",plname)
  else

    local found,new_pos=spacengine.search_controler(pos,"x15y15z15v29791")

    if not found then return end

    cpos={x=new_pos.x,y=new_pos.y,z=new_pos.z}
    local new_channel=minetest.get_meta(cpos):get_string("channel")

    if new_channel=="No channel:" then return end

    new_pos.x=pos.x-new_pos.x
    new_pos.y=pos.y-new_pos.y
    new_pos.z=pos.z-new_pos.z

    nod_met:set_string("channel",new_channel)
    nod_met:set_string("pos_cont",minetest.pos_to_string(new_pos))

    spacengine.maj_channel(cpos,new_channel,0)
  end
end

--controler
minetest.register_node("spacengine:controler", {
	description = "controler",
	tiles = {"spacengine_compass.png^[transformR90", "spacengine_side.png^[transformR90", "spacengine_side.png", "spacengine_side.png", "spacengine_cnt_front.png", {
			image = "spacengine_cnt_front_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1
			},
		}},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5}, -- NodeBox3
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox5
		}
	},
	groups = {cracky=333, spacengine=1,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
--[[
  on_place = function(itemstack,placer,pointed_thing)
    local pos=pointed_thing.above

    if pos.y<1039 or pos.y>10176 then return end
    if pos.x<-30470 or pos.x>30470 then return end
    if pos.z<-30470 or pos.z>30470 then return end

    --check si d'autre controler
      local other_cnt=minetest.find_nodes_in_area({x=pos.x-5,y=pos.y-5,z=pos.z-5},{x=pos.x+5,y=pos.y+5,z=pos.z+5},"spacengine:controler")

      if other_cnt then return false end
    --check si recouvrement d'area
      if other_cnt then
        for i=1,#other_cnt do
          
        end
      end
  end,
--]]
  on_construct=function(pos)
    spacengine.construct_node(pos,"CONTROLER beta5","^Aa¨250¨0¨^x05y05z05v01331¨6",1)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
  on_timer=function(pos,elapsed)
    local timer=minetest.get_node_timer(pos)
    if timer:is_started() then return false end
    spacengine.controler(pos)
    timer:set(5,0)
  end,
  on_destruct=function(pos)
    minetest.get_node_timer(pos):stop()
  end,
})


--battery
minetest.register_node("spacengine:battery", {
	description = "battery",
	tiles = {"spacengine_side.png^[transformR90", "spacengine_side.png^[transformR90", "spacengine_side.png", "spacengine_side.png", "spacengine_front.png", "spacengine_battery_front.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5}, -- NodeBox3
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox5
		}
	},
  paramtype2 = "facedir",
	groups = {cracky=333,spacengine=2,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"BATTERY 50","^A¨50¨0¨5000",2)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.rotate_simple,
})

--power
minetest.register_node("spacengine:power", {
	description = "Power",
	tiles ={"spacengine_power_uv.png"},
  drawtype = "mesh",
  mesh = "power.obj",
  paramtype2 = "facedir",
  paramtype = "light",
	groups = {cracky=333,spacengine=3,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Generator Charcoal","1¨100¨0¨250¨^default:coal_lump¨^battery¨10¨0¨0¨0",3)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
})

--engine
minetest.register_node("spacengine:engine", {
	description = "engine",
	tiles ={"spacengine_side.png^[transformR90", "spacengine_side.png^[transformR90", "spacengine_side.png", "spacengine_side.png", "spacengine_engine_front.png", "spacengine_engine_front.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5}, -- NodeBox3
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox5
		}
	},
  paramtype2 = "facedir",
  light_source = 7,
	groups = {cracky=333,spacengine=4,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Rocket","^A¨75¨0¨10¨50¨50¨500",4)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
})

--shield
minetest.register_node("spacengine:shield", {
	description = "shield",
  inventory_image = "spacengine_shield_inv.png",
  tiles ={{
			image = "spacengine_shield_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 1
			},
		}},
  drawtype = "plantlike",
  use_texture_alpha = true,
  selection_box = { type = "fixed", fixed = { -0.4,-0.5,-0.4,0.4,0.5,0.4} },
  collision_box = { type = "fixed", fixed = { -0.4,-0.5,-0.4,0.4,0.5,0.4} },
  light_source = 7,
	groups = {cracky=333,spacengine=5,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Shield SB1","^A¨100¨0¨100¨1",5)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
})

--weapons
minetest.register_node("spacengine:weapons", {
	description = "weapons",
	tiles ={"spacengine_radar_uv.png"},
  drawtype = "mesh",
  mesh = "weapons.obj",
  paramtype2 = "facedir",
  paramtype = "light",
	groups = {cracky=333,spacengine=6,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"LASER","^A¨100¨0¨750¨20¨5¨2",6)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
})

--radar
minetest.register_node("spacengine:radar", {
	description = "Radar",
	tiles ={"spacengine_radar_uv.png"},
  drawtype = "mesh",
  mesh = "radar.obj",
  selection_box = { type = "fixed", fixed = { -0.3,-0.5,-0.3,0.3,0.5,0.3} },
  collision_box = { type = "fixed", fixed = { -0.3,-0.5,-0.3,0.3,0.5,0.3} },
  paramtype2 = "facedir",
  paramtype = "light",
	groups = {cracky=333,spacengine=7,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Stone","^A¨50¨0¨300¨30¨^group:stone",7)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
})

--gravitation
minetest.register_node("spacengine:gravitation", {
	description = "Gforce",
	tiles ={"spacengine_side.png^[transformR90", "spacengine_side.png^[transformR90", "spacengine_side.png", "spacengine_side.png", "spacengine_front.png", "spacengine_gforce_front.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5}, -- NodeBox3
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox5
		}
	},
  paramtype2 = "facedir",
	groups = {cracky=333,spacengine=8,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Gforce MOON","^A¨100¨0¨4",8)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.rotate_simple,
})

--container
minetest.register_node("spacengine:container", {
	description = "container",
	tiles ={"spacengine_containera3.png", "spacengine_containera3.png", "spacengine_containera2.png", "spacengine_containera2.png", "spacengine_containera1.png", "spacengine_containera1.png"},
  paramtype2 = "facedir",
	groups = {cracky=333,spacengine=9,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Container 500Kg","^A¨100¨0¨500",9)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.rotate_simple,
})

minetest.register_node("spacengine:container2", {
	description = "container2",
	tiles ={"spacengine_containerb3.png", "spacengine_containerb3.png", "spacengine_containerb2.png", "spacengine_containerb2.png", "spacengine_containerb1.png", "spacengine_containerb1.png"},
  paramtype2 = "facedir",
	groups = {cracky=333,spacengine=9,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Container 500Kg","^A¨100¨0¨500",9)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.rotate_simple,
})

minetest.register_node("spacengine:container3", {
	description = "container3",
	tiles ={"spacengine_containerc3.png", "spacengine_containerc3.png", "spacengine_containerc2.png", "spacengine_containerc2.png", "spacengine_containerc1.png", "spacengine_containerc1.png"},
  paramtype2 = "facedir",
	groups = {cracky=333,spacengine=9,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    local meta = minetest.env:get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 8*4)
		inv:set_size('storage', 2*2)
		meta:set_string('formspec',
			'size [9,10]'..
			'bgcolor[#080808BB;true]'..
			'list[current_name;storage;3,1.5;2,2;]'..
			'list[current_player;main;0.5,6.5;8,4;]')
    spacengine.construct_node(pos,"Container 500Kg","^A¨100¨0¨500",9)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.rotate_simple,
})

--passenger
minetest.register_node("spacengine:passenger", {
	description = "passenger",
	drawtype = "mesh",
  mesh = "passenger_seat.obj",
  tiles = {"spacengine_seat.png"},
  selection_box = { type = "fixed", fixed = { -0.4,-0.5,-0.4,0.4,-0.1,0.4} },
  collision_box = { type = "fixed", fixed = { -0.4,-0.5,-0.4,0.4,-0.1,0.4} },
  paramtype2 = "facedir",
  paramtype = "light",
	groups = {cracky=333,spacengine=10,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Crew","^A¨50¨0¨^c",10)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    if spacengine.sit(pos, node, player)==false then
      spacengine.rightclick(pos,node,player)
    end
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.rotate_simple,
})

--manutention
minetest.register_node("spacengine:manutention", {
	description = "Manutention",
	tiles = {"spacengine_pupitre_warning.png", "spacengine_pupitre_warning.png", "spacengine_pupitre_side.png", "spacengine_pupitre_side.png", "spacengine_manu_rear.png", "spacengine_manu_front.png"},
  drawtype = "nodebox",
--
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox1
			{-0.5, 0, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox2
      --{-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5},
      --{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5},
		}
	},--]]
  paramtype2 = "facedir",
	groups = {cracky=333,spacengine=13,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Crane","^B¨150¨0¨50¨2¨^default:stone:6:BD:50¨100",13)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
})

--radio
minetest.register_node("spacengine:radio", {
	description = "radio",
	tiles ={"spacengine_radio_side.png", "spacengine_radio_side.png", "spacengine_radio_side.png", "spacengine_radio_side.png", "spacengine_radio_side.png", "spacengine_radio_front.png"},
  paramtype2 = "facedir",
  light_source = 4,
	groups = {cracky=333,spacengine=17,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Radio","^A¨50¨0¨500",17)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player,true)
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.rotate_simple,
})

--info
minetest.register_node("spacengine:info", {
	description = "Sector Info",
  sunlight_propagates = true,
	paramtype = "light",
  light_source = 6,
	groups = {cracky=333,spacengine=19,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  paramtype2 = "facedir",
  drawtype = "nodebox",
  tiles ={"spacengine_info_side.png","spacengine_info_side.png","spacengine_info_side.png","spacengine_info_side.png",{
			image = "spacengine_info_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 48,
				aspect_h = 48,
				length = 1.5
			},
		}},
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.46, 0.5, 0.5, 0.5}, -- NodeBox1
		}
	},
  on_construct=function(pos)
    spacengine.construct_node(pos,"Info","^A¨50¨0¨500",19)
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player,true)
	end,
  on_punch = function(pos, node, puncher)
    local check=spacengine.owner_check(puncher,pos)
    if check<2 then return end
    
    local owner=puncher:get_player_name()
    local hud_inf={}
    --recherche position
    local nb,nb_player,nb_pirate=0,0,0

    for k, v in pairs (spacengine.area) do
      spl_k=string.split(k,":")
      d={x=math.abs(pos.x-v.p0.x),y=math.abs(pos.y-v.p0.y),z=math.abs(pos.z-v.p0.z)}
      d.max=math.max(d.x,d.y,d.z)
      --il est situé a moins de 100 bloc ?
      if d.max<100 then
        --si c'est un vaisseaux pirate
        if spl_k[2]=="pirate_team" then
          nb=nb+1
          nb_pirate=nb_pirate+1
          hud_inf[nb] = puncher:hud_add({
            hud_elem_type = "waypoint",
            name = spl_k[2],
            text = "",
            number = 0xff0000,
            world_pos = v.p0
          })

          minetest.after(6, function(nb)
              puncher:hud_remove(hud_inf[nb])
            end,
            nb)
        elseif spl_k[2]~=owner then

          nb=nb+1
          nb_player=nb_player+1
          hud_inf[nb] = puncher:hud_add({
            hud_elem_type = "waypoint",
            name = spl_k[2],
            text = "",
            number = 0x00ff00,
            world_pos = v.p0
          })

          minetest.after(6, function(nb)
              puncher:hud_remove(hud_inf[nb])
            end,
          nb)
        end

      end
    end

nb=nb+1

  hud_inf[nb] = puncher:hud_add({
            hud_elem_type = "image",
            scale = {x = 1, y = 1},
            text = "spacengine_ship.png",
            position = {x=0.05, y=0.75},
          })

minetest.after(6, function(nb)
              puncher:hud_remove(hud_inf[nb])
            end,
          nb)
nb=nb+1
hud_inf[nb] = puncher:hud_add({
            hud_elem_type = "text",
            --scale = {x = 1, y = 1},
            text = nb_pirate,
            number=0xff0000,
            position = {x=0.1, y=0.7},
          })

minetest.after(6, function(nb)
              puncher:hud_remove(hud_inf[nb])
            end,
          nb)
nb=nb+1
hud_inf[nb] = puncher:hud_add({
            hud_elem_type = "text",
            --scale = {x = 1, y = 1},
            text = nb_player,
            number=0x00ff00,
            position = {x=0.1, y=0.8},
          })

minetest.after(6, function(nb)
              puncher:hud_remove(hud_inf[nb])
            end,
          nb)
  end,

  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.rotate_simple,
})

--pour la decoration
minetest.register_node("spacengine:command1", {
    description = "command 1",
  inventory_image = "spacengine_pupitre.png",
  tiles={"spacengine_info_side.png","spacengine_info_side.png","spacengine_info_side.png","spacengine_info_side.png","spacengine_info_side.png","spacengine_pupitre.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.375, 0.495, 0.5, 0.375, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  groups = {cracky=1,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  })

minetest.register_node("spacengine:command2", {
    description = "command 2",
  inventory_image = "spacengine_pupitre2.png",
  tiles={"spacengine_info_side.png","spacengine_info_side.png","spacengine_info_side.png","spacengine_info_side.png","spacengine_info_side.png","spacengine_pupitre2.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  groups = {cracky=1,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  })

--** affichage zone **
function spacengine.mark_target(pos,new_texture)
if new_texture==nil then
  new_texture="spacengine_sphere.png"
end
minetest.add_particle({
		pos = pos,
		velocity = vector.new(),
		acceleration = vector.new(),
		expirationtime = 10,
		size = 10,
		collisiondetection = false,
		vertical = false,
		texture = new_texture,
--
    animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 0.5
			},
--]]
		glow = 15,
	})
end
