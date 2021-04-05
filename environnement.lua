--ATC11="0000" 00=timer alea 00=choix message aleea
local atc={
"0000","0000","02011210","0000","0404031413",
"0602232207","031819","0000","052123","0621",
"000002","05052400","051201241514","05131200","08012200",
"08012200","08012200","0506072019","0000","04191009",
"0000","0819","0809","020201","04060722"
}
--*** TIMER ***
-- son d'ambience, applique la gravitation artificiel, protege dans l'espace des radiation

local mod_espace=minetest.get_modpath("espace")
--[[
if not mod_espace then

local delay=0
local timer=-5

minetest.register_globalstep(function(dtime)

  timer = timer + dtime
  if timer<4 then return end
  timer=0
  delay=delay+1

  for nb, player in ipairs(minetest.get_connected_players()) do
    spacengine.environnement(player,delay)
  end

  if delay>1 then delay=0 end

end)

end
--]]
local function crew_area(pos,plname,channel)
  local out=0

  if spacengine.area[channel].crew[plname] then
    --check si privilege
    if spacengine.area[channel].crew[plname]==true then
      out=3
    else
      out=2
    end

  end
  --check si capitaine
  if spacengine.area[channel].captain==plname then out=4 end

  --local p1,p2=spacengine.area[channel].p1, spacengine.area[channel].p2

  --check si dans le vaisseaux
  --if (pos.x>=p1.x and pos.x<=p2.x) and (pos.y>=p1.y and pos.y<=p2.y) and (pos.z>=p1.z and pos.z<=p2.z) then
    --in ship
  --else
  --  out=0
  --end

  return out
end
--********************************
--*** spacengine environnement ***
--********************************
spacengine.environnement=function(player,delay)
  local pl_pos = player:getpos()
  local plname = player:get_player_name()
  local g=1000
  local bm="e" --biome
  if mod_espace then
      g=map_sky[espace.data[plname].skytype].physic.gravity*1000
      espace.data[plname].radiation=map_sky[espace.data[plname].skytype].radiation
      espace.data[plname].biome=espace.data[plname].old_biome
      espace.data[plname].oxygen=map_sky[espace.data[plname].skytype].oxygen
  end
  --recherche area
  local found,cpos,ship_name=spacengine.test_area_ship(pl_pos,0)
  
  if found then

    local sound_on={}
    local config=spacengine.area[ship_name].config

    --controler is on ?
    if config[1][1]>0 then
      sound_on={"spacengine:power"}

      if config[4][1]>0 and delay==1 then
        if config[4][2]>0 then
          minetest.sound_play("spacengine_engine", {to_player = plname,gain=0.1})
        else
          minetest.sound_play("spacengine_transfo", {to_player = plname,gain=0.2})
        end
      end

      --radio ok ?
      if config[15][1]~=33333 then
        table.insert(sound_on,"spacengine:radio")
      end

      --shield is on ?
      if config[5][2]>0 then
        table.insert(sound_on,"spacengine:shield")
        if mod_espace then
          local shield=math.floor(config[5][4]*config[5][2]/2000)
          espace.data[plname].radiation=math.max(0,espace.data[plname].radiation-shield)
          espace.data[plname].biome="n"
        end
        bm="n"
      end

      --gravitation is on ?
      if config[8][2]>0 then
        -- suivant taille vaisseaux 1 module/2500 bloc
        local volume_vaisseaux=math.ceil(tonumber(string.sub(config[1][4],11,15))/2500)+1
        local volume_module=math.max(1,volume_vaisseaux-math.floor(config[8][1]/1000))
        g=math.ceil((config[8][2]*(config[8][1] % 1000))/volume_module)
      end

      if mod_espace then
        --oxygen ?
        if config[11][2]>0 or config[11][4]>0 then
          espace.data[plname].oxygen=true
        end
      end
      --search sound
      if delay>1 then

        local list,node_tot=minetest.find_nodes_in_area({x=pl_pos.x-5,y=pl_pos.y-5,z=pl_pos.z-5},{x=pl_pos.x+5,y=pl_pos.y+5,z=pl_pos.z+5},sound_on)
    
        if list then
          if node_tot["spacengine:power"] and node_tot["spacengine:power"]>0 then
            minetest.sound_play("spacengine_power", {to_player = plname,gain=0.7})
          end
          if node_tot["spacengine:shield"] and node_tot["spacengine:shield"]>0 then
            minetest.sound_play("spacengine_shield", {to_player = plname})
          end
          if node_tot["spacengine:radio"] and node_tot["spacengine:radio"]>0 then
            local nb_atc=math.random(2,#config[15][4]/2)
            local charac=string.sub(config[15][4],(nb_atc*2)-1,nb_atc*2)

            if config[15][5]==nil then config[15][5]=0 end
            if config[15][5]>-1 then config[15][5]=config[15][5]-1 end

            if config[15][5]>-2 then

              if charac=="00" then
                nb_atc=math.random(99)
              else
                nb_atc=tonumber(charac)
              end

              if nb_atc <= #atc and config[15][5]<1 then
                local lng=tonumber(string.sub(atc[nb_atc],1,2))
                
                if lng==0 then
                  lng=math.random(2,20)
                end

                config[15][5]=lng
                config[15][4]=atc[nb_atc]
                minetest.sound_play("atc"..nb_atc, {pos = {x=config[15][1],y=config[15][2],z=config[15][3]}, max_hear_distance = 8})
              end
            end
          end
        end
      end
    end

  end

  if mod_espace then
    if default.player_attached[plname] then
      fxadd(player,"sit",5,0,0,0,11)
    else
      fxadd(player,"gravitation",5,0,0,g)
    end
    --protect if not crew
    if found then
      if crew_area(pl_pos,plname,ship_name)<2 then
        espace.data[plname].bloc_protect=true
      else
        espace.data[plname].bloc_protect=false
      end
    end
  else
    if pl_pos.y>1007 and pl_pos.y<10208 then --TODO spacengine.ALTMIN ALTMAX ?
      if bm=="e" then
        local hp = player:get_hp()
        player:set_hp(hp - bm)
      end
      if not default.player_attached[plname] then player:set_physics_override({speed=1,jump=1,gravity=g/100}) end
    else
      if not default.player_attached[plname] then player:set_physics_override({speed=1,jump=1,gravity=1}) end
    end
  end

end
