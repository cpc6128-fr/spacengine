--
-- *** oxygene ***
--
--1 stack d'air rempli 250 blocs

-- remplir d'air
-- from spacestation
spacengine.airstream_on=function(pos,rangex,rangey,rangez,chance)
  --if pos.y<1008 or pos.y>12268 then
  --  return
  --end

  --test si dans atelier
  _,bloc=espace.secteur(pos)
  if bloc.nb==45 or bloc.nb==283 then return end
--minetest.chat_send_all("oxygene on")

  local c_air = minetest.get_content_id("air")
  local c_vacuum = minetest.get_content_id("vacuum:vacuum")

  local vm = minetest.get_voxel_manip()
  local pos1 = {x = pos.x - rangex, y = pos.y - rangey, z = pos.z - rangez}
  local pos2 = {x = pos.x + rangex, y = pos.y + rangey, z = pos.z + rangez}
  local emin, emax = vm:read_from_map(pos1, pos2)
  local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
  local data = vm:get_data()
  local viystride = emax.x - emin.x + 1

  -- replace vaccum with air
  for z = pos1.z, pos2.z do
    for y = pos1.y, pos2.y - 1 do
      local vi = area:index(pos1.x, y, z)
      for x = pos1.x, pos2.x do
        if data[vi] == c_vacuum and math.random(1,chance)<10 then
          data[vi] = c_air
        end
        vi = vi + 1
      end
    end
  end

  vm:set_data(data)
  vm:write_to_map()
  vm:update_map()
end
    
-- remplir de vide

spacengine.airstream_off=function(pos,rangex,rangey,rangez)
  --if pos.y<1008 or pos.y>12268 then
  --  return
  --end

  --test si dans atelier
  _,bloc=espace.secteur(pos)
  if bloc.nb==45 or bloc.nb==283 then return end
--minetest.chat_send_all("oxygene off")

  local c_air = minetest.get_content_id("air")
  local c_vacuum = minetest.get_content_id("vacuum:vacuum")

  local vm = minetest.get_voxel_manip()
  local pos1 = {x = pos.x - rangex, y = pos.y - rangey, z = pos.z - rangez}
  local pos2 = {x = pos.x + rangex, y = pos.y + rangey, z = pos.z + rangez}
  local emin, emax = vm:read_from_map(pos1, pos2)
  local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
  local data = vm:get_data()
  local viystride = emax.x - emin.x + 1

  -- replace air by vaccum

  for z = pos1.z, pos2.z do
    for y = pos1.y, pos2.y - 1 do
      local vi = area:index(pos1.x, y, z)
      for x = pos1.x, pos2.x do
        if data[vi] == c_air and math.random(1,30)==15 then
          data[vi] = c_vacuum
        end
        vi = vi + 1
      end
    end
  end

  vm:set_data(data)
  vm:write_to_map()
  vm:update_map()

end


 --
 -- Node timer
 --
spacengine.oxygene=function(pos,config)
  local cont_met = minetest.get_meta(pos)
	local inv = cont_met:get_inventory()
  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))
  local volume_module=math.floor(config[11][3]/10000)*config[11][1]*config[11][2]*0.01
  local volume_vaisseaux=tonumber(string.sub(config[1][4],11,15))
	local stack="spacengine:oxygene_tank ".. math.ceil(volume_module)

  if config[11][4]==1 then

    if inv:contains_item("stock", stack) then
      local chance=math.max(1,volume_vaisseaux-math.ceil(volume_module*250))
      spacengine.make_sound("air_on",config[15],pos)
      spacengine.airstream_on(pos,rangex,rangey,rangez,chance)

      if config[1][1]==1 then --only player spacengine
        inv:remove_item("stock", stack)
      end

      config[11][4]=config[11][3] % 1000
      return

    else
      config[11][4]=0
      config[11][2]=0
      spacengine.central_msg("OXYGEN EMPTY",config)
      spacengine.make_sound("2_bip",config[15])
      spacengine.airstream_off(pos,rangex,rangey,rangez)
    end

  elseif config[11][4]==0 then
    config[11][4]=0
    config[11][2]=0
    spacengine.central_msg("OXYGEN STOP",config)
    spacengine.make_sound("2_bip",config[15])
    spacengine.airstream_off(pos,rangex,rangey,rangez)
  end
  
end


minetest.register_node("spacengine:oxygene", {
	description = "oxygene",
	tiles ={"spacengine_side.png^[transformR90", "spacengine_side.png^[transformR90", "spacengine_side.png", "spacengine_side.png", "spacengine_front.png", "spacengine_oxygene_front.png"},
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
	groups = {cracky=333,spacengine=11,not_in_creative_inventory = spacengine.creative_enable},
	sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.construct_node(pos,"Oxygene","^A¨150¨0¨1¨50",11)
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    spacengine.rightclick(pos,node,player)
	end,
  can_dig=spacengine.can_dig,
  on_rotate = screwdriver.rotate_simple,
})

-- CRAFTS
minetest.register_craftitem("spacengine:oxygene_tank", {
	description = "Oxygene Tank",
	inventory_image = "spacengine_oxygene_tank.png",
})

minetest.register_craftitem("spacengine:hydrogene_tank", {
	description = "Hydrogene Tank",
	inventory_image = "spacengine_hydrogene_tank.png",
	groups = {flammable = 3},
})

minetest.register_craft({
	type = "fuel",
	recipe = "spacengine:hydrogene_tank",
	burntime = 40,
})

