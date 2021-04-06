--******************
--*** test owner ***
--******************
--return n : 0 INCONNU ou false  1 ACHETEUR 2 CREW(equipage) 3 officier priv 4 OWNER(capitaine)
--channel-->recherche par channel, si absent, charge channel node
spacengine.owner_check=function(player,pos,channel,vente)

  if vente==nil then vente="" end
  
  local plname
  local nod_met

  if channel==nil then
    nod_met = minetest.get_meta(pos)
    channel=nod_met:get_string("channel")
    --error node
    if channel==nil then
      nod_met:set_string("channel","No channel:noplayer")
      return 4,"nothing:nothing"
    end
  end

  local tool
  local out=0

  if type(player)=="string" then
    plname=player
    tool = minetest.get_player_by_name(plname):get_wielded_item():get_name()
  else
    plname=player:get_player_name()
    tool = player:get_wielded_item():get_name()
  end

  --No area
  if string.find(channel,"No channel:") then
    nod_met = minetest.get_meta(pos)
    local captain=nod_met:get_string("captain")
    --check si controler et capitaine
    if captain and plname==captain then return 4,tool end

    if spacengine.test_area_ship(pos,0) then return 1,tool end
    out=1
  end

  --check si vaisseaux existe
  if spacengine.area[channel]==nil then return 3,tool end

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

  local p1,p2=spacengine.area[channel].p1, spacengine.area[channel].p2

  --check si dans le vaisseaux
  if (pos.x>=p1.x and pos.x<=p2.x) and (pos.y>=p1.y and pos.y<=p2.y) and (pos.z>=p1.z and pos.z<=p2.z) then
    --in ship
  else
    out=0
  end

  if out>1 then return out,tool end

  if vente~="" or string.find(channel,"noplayer") then return 1,tool end

  return 0,tool
end


spacengine.conso_engine=function(cpos,config,option)

  if option==nil then option=0 end

  local coef_r=0

  if config[4][7]>0 then coef_r=config[4][3]/config[4][7] end

  local rmax=math.ceil((((config[4][7]-config[1][2])*coef_r)+config[4][3])*config[4][2]*0.0001*(100-config[1][3]))  

  if rmax<0 then rmax=0 end

  if option==1 then return rmax end

  local distance={x=math.abs(cpos.x-config[1][6][1]),y=math.abs(cpos.y-config[1][6][2]),z=math.abs(cpos.z-config[1][6][3])}
  distance.max=math.max(distance.x,distance.y,distance.z)
  local puissance=math.ceil(config[4][1]*config[4][2]*0.0001*(100-config[1][3]))
  local conso=math.ceil((rmax*config[1][2]*puissance*0.001))
  
  if option==2 then return conso,rmax,distance.max end

  local coef_t=config[4][1]*config[4][3]*config[4][7]

  if coef_t>0 then coef_t=8000/coef_t end
  local temperature=math.ceil(coef_t*(puissance*distance.max*math.min(config[4][7],config[1][2])))+2000

  if distance.max>rmax then return conso,rmax,temperature,false end

  return conso,rmax,temperature,true
end

spacengine.transaction=function(player,stack,card)
  local plname
  local inv
  local havecard

  if type(player)=="string" then
    plname=player
    inv = minetest.get_player_by_name(plname):get_inventory()
    havecard=commerce.found_item_index(minetest.get_player_by_name(plname),"commerce:card")
  else
    plname=player:get_player_name()
    inv = player:get_inventory()
    havecard=commerce.found_item_index(player,"commerce:card")
  end

  if havecard>0 then --si card presente
    if atm.balance[plname]~= nil then
      if atm.balance[plname]-card>0 then
        atm.balance[plname] = atm.balance[plname]-card
        if stack~=nil then inv:add_item("main",stack) end
        atm.saveaccounts()
        --minetest.sound_play("card2",{to_player=name,gain=2})
        minetest.chat_send_player(plname,"Account : ".. atm.balance[plname])
        return true
      end
    end
  end
  return false
end

--********************
--** PLace SpaceShip **
--********************
spacengine.place_ship=function(cpos,plname,channel,data)
--channel,plname="goldo:other_man","other_man"

  local filename = minetest.get_modpath("spacengine").."/schems/".. data[1] ..".mts"

  local rangex=tonumber(string.sub(data[2],2,3))
  local rangey=tonumber(string.sub(data[2],5,6))
  local rangez=tonumber(string.sub(data[2],8,9))

  --controler center
  local pos1={x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez}
  local pos2={x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez}

  minetest.place_schematic(pos1, filename, "0", nil, true)
--TODO group switch  ic switch
  --recherche module, switch
  list=minetest.find_nodes_in_area(pos1,pos2,{"group:spacengine", "bloc4builder:keypad", "bloc4builder:keypad_on", "bloc4builder:sas2"," bloc4builder:sas2_on", "bloc4builder:sas1", "bloc4builder:sas1_on", "bloc4builder:sas4", "bloc4builder:sas4_on", "bloc4builder:mesecons2switch", "bloc4builder:mesecons2switch_all", "bloc4builder:mesecons2switch_all_on", "bloc4builder:door_shop"})
  nb=#list
  local node
  local group
  local prelativ
  local spl_cha=string.split(channel,":")

  for i=1,nb do
    node=minetest.get_node(list[i])
    group=minetest.get_item_group(node.name,"spacengine")
    if group~=0 then
      minetest.set_node(list[i],{name=node.name, param2=node.param2})
      nod_met=minetest.get_meta(list[i])
      nod_met:set_string("channel",channel)
      if group~=1 then
        prelativ={x=list[i].x-cpos.x,y=list[i].y-cpos.y,z=list[i].z-cpos.z}
      else
        prelativ={x=cpos.x,y=cpos.y,z=cpos.z}
        --taille du vaisseaux
        local spac_eng=spacengine.decompact(nod_met:get_string("spacengine"))
        nod_met:set_string("captain",plname)
        spac_eng[4]=data[2]
        spac_eng[1]=data[3]
        nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      end
      nod_met:set_string("pos_cont",minetest.pos_to_string(prelativ))
    else
      minetest.set_node(list[i],{name=node.name, param2=node.param2})

      if  node.name=="bloc4builder:keypad" or
          node.name=="bloc4builder:keypad_on" or
          node.name=="bloc4builder:sas2" or
          node.name=="bloc4builder:sas2_on" then
        nod_met=minetest.get_meta(list[i])
        nod_met:set_string("channel",spl_cha[1])
        nod_met:set_string("owner",spl_cha[2])
        nod_met:set_string("code","")
      end
    end

  end

  --node=minetest.get_node(cpos)
  --nod_met:set_string("vente","500")
end

--******************************
--** sell ship change channel **
--******************************
spacengine.sell_ship=function(cpos,channel,plname,target)
  local config=spacengine.area[channel].config

  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))

  --controler center
  pos1={x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez}
  pos2={x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez}
--TODO group switch  ic switch
  list=minetest.find_nodes_in_area(pos1,pos2,{"group:spacengine", "bloc4builder:keypad", "bloc4builder:keypad_on", "bloc4builder:sas2"," bloc4builder:sas2_on", "bloc4builder:sas1", "bloc4builder:sas1_on", "bloc4builder:sas4", "bloc4builder:sas4_on", "bloc4builder:mesecons2switch", "bloc4builder:mesecons2switch_all", "bloc4builder:mesecons2switch_all_on", "bloc4builder:door_shop"})
  nb=#list
  local node
  local group
  local spl_cha=string.split(channel,":")

  for i=1,nb do
    nod_dst=minetest.get_node(list[i])
    group=minetest.get_item_group(nod_dst.name,"spacengine")
    nod_met=minetest.get_meta(list[i])
    if group~=0 then
      if group==1 then
        nod_met:set_string("captain",plname)
      end
      nod_met:set_string("channel",channel)
    else
      nod_met:set_string("channel",spl_cha[1])

      if  node.name=="bloc4builder:keypad" or
          node.name=="bloc4builder:keypad_on" or
          node.name=="bloc4builder:sas2" or
          node.name=="bloc4builder:sas2_on" then
        nod_met:set_string("owner",spl_cha[2])
        nod_met:set_string("code","")
      end
    end
  end

  local timer=minetest.get_node_timer(cpos)

  config[1][1]=0 --arret du vaisseaux
  config[1][7]=0
  config[12]="y"

  if timer:is_started() then timer:stop() end

end

--***********
--*** sit ***
--***********
--from mod : xdecor

function spacengine.sit(pos, node, clicker)
	local tool = clicker:get_wielded_item():get_name()
  if tool == "spacengine:tool" then return false end
	local player_name = clicker:get_player_name()
	local objs = minetest.get_objects_inside_radius(pos, 0.1)
	local vel = clicker:get_player_velocity()
	local ctrl = clicker:get_player_control()
  local physics=clicker:get_physics_override()

	for _, obj in pairs(objs) do
		if obj:is_player() and obj:get_player_name() ~= player_name then
			return
		end
	end

	if default.player_attached[player_name] then
    physics=minetest.deserialize(clicker:get_attribute("sit"))
		pos.y = pos.y - 0.5
		clicker:setpos(pos)
		clicker:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
		clicker:set_physics_override(physics)
		default.player_attached[player_name] = false
		default.player_set_animation(clicker, "stand", 30)

	elseif not default.player_attached[player_name] and node.param2 <= 3 and
			not ctrl.sneak and vector.equals(vel, {x=0,y=0,z=0}) then
    physics=clicker:set_attribute("sit",minetest.serialize(physics))
		clicker:set_eye_offset({x=0, y=-7, z=2}, {x=0, y=0, z=0})
		clicker:set_physics_override(0, 0, 0)
		clicker:setpos(pos)
		default.player_attached[player_name] = true
		default.player_set_animation(clicker, "sit", 30)

		if     node.param2 == 2 then clicker:set_look_horizontal(3.15)
		elseif node.param2 == 3 then clicker:set_look_horizontal(7.9)
		elseif node.param2 == 0 then clicker:set_look_horizontal(6.28)
		elseif node.param2 == 1 then clicker:set_look_horizontal(4.75) end
	end
  return true
end

function spacengine.sit_dig(pos, digger)
	for _, player in pairs(minetest.get_objects_inside_radius(pos, 0.1)) do
		if player:is_player() and
			    default.player_attached[player:get_player_name()] then
			return false
		end
	end
	return true
end

--################################
local function str(val_in)
  local val_out
  if val_in==nil then val_in="" end
  if type(val_in)=="string" then
   val_out="^".. val_in
  else
    val_out=val_in
  end
  return val_out
end

local function tab(val_in)
  local val_out
if val_in=="*" then val_in="^*" end
if string.sub(val_in,1,1)=="^" then
   val_out=string.sub(val_in,2)
  else
    val_out=tonumber(val_in)
  end
  return val_out
end

--transform src {0},{{0,{0,"none"}} } --> compact "0¨0#0/^none"
spacengine.compact=function(src)
  local dst=""
if type(src)=="table" then
  for idx1=1,#src do
    local cont1=src[idx1]
  
    if type(cont1)=="table" then

      for idx2=1,#cont1 do
        local cont2=cont1[idx2]

        if type(cont2)=="table" then

          for idx3=1,#cont2 do
            dst=dst .. str(cont2[idx3])
            if idx3<#cont2 then dst=dst .."/" end
          end

        else
          dst=dst .. str(cont2)
        end

        if idx2<#cont1 then dst=dst .."#" end
      end
    else
      dst=dst .. str(cont1)
    end

    if idx1<#src then dst=dst .."¨" end

  end
else
  dst=str(src)
end

  return dst
end

--transform src "0¨0#0/^none" --> decompact {{0},{0,{0,"none"}} }
spacengine.decompact=function(src)
local dst={}
local data

if string.find(src,"¨") then
  local family=string.split(src,"¨")
  local idx=1

  for idx1=1,#family do
    local val1={}

    if string.find(family[idx1],"#") then
      local machine=string.split(family[idx1],"#")
      local val2={}

      for idx2=1,#machine do
        if string.find(machine[idx2],"/") then
          data=string.split(machine[idx2],"/")
          val2={}

          for idx3=1,#data do
            val2[idx3]=tab(data[idx3])
          end

          val1[idx2]=val2
        else
          val1[idx2]=tab(machine[idx2])
        end
      end
      dst[idx1]=val1
    else
      dst[idx1]=tab(family[idx1])
    end
  end
else
  dst=tab(src)
end

  return dst
end

--########################################

--****************************
--** weapons destroy target **
--****************************
spacengine.destroy_target=function(cpos,cible_destroy,node,degat,config)

  --recuperation node ennemie
  local nod_met=minetest.get_meta(cible_destroy)

  --recuperation controleur ennemie
  local cpos=minetest.string_to_pos(nod_met:get_string("pos_cont"))
  local group=minetest.get_item_group(node.name,"spacengine")

  --bouton et levier
  if group==20 then return false end

  if group~=1 then
    cpos={x=cible_destroy.x-cpos.x,y=cible_destroy.y-cpos.y,z=cible_destroy.z-cpos.z}
  end

  local cont_dst=minetest.get_meta(cpos)
  local channel=cont_dst:get_string("channel")

  if channel=="" then return false end --en cas d'erreur
  
  if string.find(channel,"No channel:") then return false end

  local config_dst=spacengine.area[channel].config
  --recuperation bouclier ennemie
  local sh_damage=1-(config_dst[5][4]/config_dst[5][1])
  local shield=math.floor(config_dst[5][4]*config_dst[5][2]*0.01)
  local punch=degat-shield

  --degat au bouclier
  if punch<1 then
    config_dst[5][4]=math.max(0,config_dst[5][4]-math.ceil(10*math.max(0.01,sh_damage)))

    if not string.find(config_dst[12],"S") then config_dst[12]=config_dst[12].."S" end
    return false
  else
    config_dst[5][4]=math.max(0,config_dst[5][4]-math.ceil(degat*math.max(0.1,sh_damage)))

    if not string.find(config_dst[12],"S") then config_dst[12]=config_dst[12].."S" end
  end

  --appliquer les degats
  spacengine.central_msg("BREAK",config_dst)
  spacengine.make_sound("warning",config_dst[15]) --warning attack

  --degat au spacengine
  config_dst[1][3]=math.min(100,config_dst[1][3]+(punch*0.05))

  if not string.find(config_dst[12],"C") then config_dst[12]=config_dst[12].."C" end

  --pillage si shield = full damage ou eteind
  if shield<25 then
    --transferer stock
    if (config[9][2]+degat)<config[9][1] then
      local idx=7
      repeat
        if config_dst[9][3][idx]>0 then
          config_dst[9][3][idx]=config_dst[9][3][idx]-degat
          if config_dst[9][3][idx]<0 then
            degat=config_dst[9][3][idx]+degat
            config_dst[9][3][idx]=0
          end

          config[9][3][idx]=config_dst[9][3][idx]+degat
          config_dst[9][2]=config_dst[9][2]+degat
          idx=0
        end
        idx=idx-1
      until idx<1
    end

    if config[1][1]==2 and idx==0 then --comptabilise les rater
      config[13][11]=config[13][11]+10
    end
  end

  return true
end

--************
--** shield **
--************
spacengine.check_shield=function(pos_shield,degat,config)
  local cont_dst=minetest.get_meta(pos_shield)
  
  local channel=cont_dst:get_string("channel")

  if channel=="" then return false,0 end --en cas d'erreur
  
  if string.find(channel,"No channel:") then return false,0 end

  local config_dst=spacengine.area[channel].config

  --recuperation bouclier ennemie
  local sh_damage=1-(config_dst[5][4]/config_dst[5][1])
  local shield=math.floor(config_dst[5][4]*config_dst[5][2]*0.01)
  local punch=degat-shield

  config_dst[5][4]=math.max(0,config_dst[5][4]-math.ceil(degat*math.max(0.1,sh_damage)))

  if not string.find(config_dst[12],"S") then config_dst[12]=config_dst[12].."S" end

  spacengine.central_msg("BREAK",config_dst)
  spacengine.make_sound("warning",config_dst[15])

  --pillage si shield = 0 ou eteind
  if shield<25 then

    local idx=7
    --transferer stock
    if (config[9][2]+degat)<config[9][1] then
      repeat
        if config_dst[9][3][idx]>0 then

          config_dst[9][3][idx]=config_dst[9][3][idx]-degat
          if config_dst[9][3][idx]<0 then
            degat=config_dst[9][3][idx]+degat
            config_dst[9][3][idx]=0
          end

          config[9][3][idx]=config_dst[9][3][idx]+degat
          config_dst[9][2]=config_dst[9][2]+degat
          idx=0
        end
        idx=idx-1
      until idx<1
    else
      idx=0
    end

    if config[1][1]==2 and idx==0 then --comptabilise les rater
      config[13][11]=config[13][11]+10
    end

  end

  if punch<1 then return false,0 end

  config_dst[1][3]=math.min(100,config_dst[1][3]+(punch*0.05))

  if not string.find(config_dst[12],"C") then config_dst[12]=config_dst[12].."C" end
  return true,punch
end

--***************
--** explosion **
--***************
spacengine.explosion=function(cible_destroy)
local delay=math.random(100)*0.01
local text_choice=math.random(20)
if text_choice<10 then
minetest.after(delay,function(cible_destroy)
minetest.sound_play("explosion", {pos = cible_destroy, gain = 1.5,
			max_hear_distance = 25})

minetest.add_particle({
		pos = cible_destroy,
		velocity = vector.new(),
		acceleration = vector.new(),
		expirationtime = 1.5,
		size = 20,
		collisiondetection = false,
		vertical = false,
		texture = "spacengine_blast02.png",
    animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8
			},
		glow = 15,
	})
	minetest.add_particlespawner({
		amount = 32,
		time = 0.5,
		minpos = vector.subtract(cible_destroy, 1),
		maxpos = vector.add(cible_destroy, 1),
		minvel = {x = -10, y = -10, z = -10},
		maxvel = {x = 10, y = 10, z = 10},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 2.5,
		minsize = 3,
		maxsize = 5,
		texture = "spacengine_nuage.png",
	})
end,cible_destroy)

else
minetest.after(delay,function(cible_destroy)
minetest.sound_play("explosion", {pos = cible_destroy, gain = 1.5,
			max_hear_distance = 25})

minetest.add_particle({
		pos = cible_destroy,
		velocity = vector.new(),
		acceleration = vector.new(),
		expirationtime = 0.6,
		size = 20,
		collisiondetection = false,
		vertical = false,
		texture = "spacengine_blast01.png",
    animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3
			},
		glow = 15,
	})
	minetest.add_particlespawner({
		amount = 32,
		time = 0.5,
		minpos = vector.subtract(cible_destroy, 1),
		maxpos = vector.add(cible_destroy, 1),
		minvel = {x = -10, y = -10, z = -10},
		maxvel = {x = 10, y = 10, z = 10},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 2.5,
		minsize = 4,
		maxsize = 6,
		texture = "spacengine_nuage.png",
	})
end,cible_destroy)

end

end

--** MAKE SOUND **
spacengine.make_sound=function(soundname,radio_pos,cpos)
  if cpos then
    minetest.sound_play(soundname, {pos = cpos, gain = 1, max_hear_distance=32})
  else
    if radio_pos[1]~=33333 then
      minetest.sound_play(soundname, {pos = {x=radio_pos[1],y=radio_pos[2],z=radio_pos[3]}, gain = 1, max_hear_distance=32})
    end
  end
end

--*****************
--*** AREA SHIP ***
--*****************

--channel:captain team p0 p1 p2 config
--*** test area ship ***
--action -1 dec / 0 neutre / 1= add si nil pos=controler !
spacengine.test_area_ship=function(pos,action,channel,plname)

  if channel then

    if string.find(channel,"No channel:") then return false end

    --si vaisseaux absent de la liste
    if spacengine.area[channel]==nil then

      --creation
      if action>0 then
        --cpos ?
        local node=minetest.get_node(pos)

        if minetest.get_item_group(node.name,"spacengine")==1 then
          local cont_met=minetest.get_meta(pos)
          local captain=cont_met:get_string("captain")
          local cont_dat=spacengine.decompact(cont_met:get_string("spacengine"))

          local rangex=tonumber(string.sub(cont_dat[4],2,3))
          local rangey=tonumber(string.sub(cont_dat[4],5,6))
          local rangez=tonumber(string.sub(cont_dat[4],8,9))

spacengine.area[channel]={
p0={x=pos.x,y=pos.y,z=pos.z},
p1={x=pos.x-rangex,y=pos.y-rangey,z=pos.z-rangez},
p2={x=pos.x+rangex,y=pos.y+rangey,z=pos.z+rangez},
config={
{0,0,0,"x05y05z05v01331",{0,0,0},{0,0,0},0},
{0,0},
{0,0,0,{0},{0}},
{0,0,0,{0,0,0,0,0},0,0,0,0},
{0,0,0,0},
{0,0,0,0,0,0,0,0},
{0,0,0,"none:none",0,0},
{0,0},
{0,0,{0,0,0,0,0,0,0}},
{0,0,{0,0,0,0,0}},
{0,0,0,0},
{"n"},
{0,0,0,0,"none:none:0:none",1,"n",1,"0;***;***",-1,0,0},
0,
{33333,0,0,"0000",0}
},
crew={},
mission="",
captain=captain
}

          if plname==captain then spacengine.area[channel].crew[plname]=true end

          spacengine.save_area()
          return true
        end
      end

      --pas de vaisseaux
      return false

    else

      --effacement de la liste
      if action==-1 then
        spacengine.area[channel]=nil
        spacengine.save_area()

        return false

      elseif action==1 then
        local node=minetest.get_node(pos)

        --en cas ou pas la position du controler
        if minetest.get_item_group(node.name,"spacengine")==1 then
          local cont_met=minetest.get_meta(pos)
          local cont_dat=spacengine.decompact(cont_met:get_string("spacengine"))

          local rangex=tonumber(string.sub(cont_dat[4],2,3))
          local rangey=tonumber(string.sub(cont_dat[4],5,6))
          local rangez=tonumber(string.sub(cont_dat[4],8,9))

          spacengine.area[channel].p0={x=pos.x,y=pos.y,z=pos.z}
          spacengine.area[channel].p1={x=pos.x-rangex,y=pos.y-rangey,z=pos.z-rangez}
          spacengine.area[channel].p2={x=pos.x+rangex,y=pos.y+rangey,z=pos.z+rangez}
        end

        spacengine.save_area()
        return true

      elseif action==0 then
        --verifie si a l'interieur du vaisseaux
        if type(pos)=="table" then
          if  pos.x<spacengine.area[channel].p1.x or pos.x>spacengine.area[channel].p2.x or
              pos.y<spacengine.area[channel].p1.y or pos.y>spacengine.area[channel].p2.y or
              pos.z<spacengine.area[channel].p1.z or pos.z>spacengine.area[channel].p2.z then
            return false
          end
        end
      end
      --vaisseaux existe
      return true,spacengine.area[channel].p0
    end
  end

  --recherche par position
  local p0={}
  local ship=""

  for k, v in pairs (spacengine.area) do
    local p1,p2=v.p1,v.p2
    if (pos.x>=p1.x and pos.x<=p2.x) and (pos.y>=p1.y and pos.y<=p2.y) and (pos.z>=p1.z and pos.z<=p2.z) then
      p0={x=v.p0.x,y=v.p0.y,z=v.p0.z}
      ship=k
      break
    end
  end

  if ship~="" then
    return true,p0,ship
  end

  return false
end

--******************
--** zone libre ? **
--******************
spacengine.check_free_place=function(cpos,plname,data,forbiden_node)
  if data==nil then data="x15y15z15v29791" end
  local rangex=tonumber(string.sub(data,2,3))
  local rangey=tonumber(string.sub(data,5,6))
  local rangez=tonumber(string.sub(data,8,9))
  local volume=tonumber(string.sub(data,11,15))

  local radius={x=rangex+5,y=rangey+5,z=rangez+5}

  --limit spaceship
  local pos1={x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez}
  local pos2={x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez}

  --only in space
  if pos1.y<1008 or pos2.y>10207 then
    if plname~="pirate_team" then minetest.chat_send_player(plname,"NOT in SPACE") end
    return false
  end 

  --area crossing
  if spacengine.area_cross(cpos,rangex,rangey,rangez) then
    if plname~="pirate_team" then minetest.chat_send_player(plname,"AREA CROSSING") end
    return false
  end

  --test protector
  local protect_list = minetest.find_nodes_in_area(
      {x = cpos.x - radius.x, y = cpos.y - radius.y, z = cpos.z - radius.z},
      {x = cpos.x + radius.x, y = cpos.y + radius.y, z = cpos.z + radius.z},
      {"protector:protect", "protector:protect2"})

  if #protect_list>0 then
    if plname~="pirate_team" then minetest.chat_send_player(plname,"PROTECTOR") end
    return false
  end

  --teste bloc_protect
  local secteur,bloc=espace.secteur(cpos)

  if plname=="pirate_team" then
    bloc.nb=bloc.nb+1
    if secteur_dat[bloc.nb]==1 or secteur_dat[bloc.nb]==4 or secteur_dat[bloc.nb]==7 or secteur_dat[bloc.nb]==8 or secteur_dat[bloc.nb]==9 then
      return false
    end

  else
    -- JAIL proteger
    if bloc.nb==45 then
      minetest.chat_send_player(plname,"PROTECTION")
      return false
    end

    if bloc.nb==283 then
      if secteur.nb~=9999 then
        minetest.chat_send_player(plname,"PROTECTION")
        return false
      end
    end
  end

  --free space
  local node_list={}

  if forbiden_node==nil then
    node_list=minetest.find_nodes_in_area(pos1,pos2,{"air", "vacuum:vacuum"})
    if #node_list < volume then
      if plname~="pirate_team" then minetest.chat_send_player(plname,"NOT ENOUGHT SPACE") end
      return false
    end

  else
    node_list=minetest.find_nodes_in_area(pos1,pos2,forbiden_node)
    if #node_list>0 then
      if plname~="pirate_team" then minetest.chat_send_player(plname,"! Forbiden node !") end
      return false
    end
  end

  return true
end

--** test croisement d'area **
spacengine.area_cross=function(cpos,rangex,rangey,rangez)
  -- -x / -y / -z
  local newpos={x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez}
  if spacengine.test_area_ship(newpos,0)==true then return true end
  -- -x / -y / +z
  newpos={x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z+rangez}
  if spacengine.test_area_ship(newpos,0)==true then return true end
  -- +x / -y / +z
  newpos={x=cpos.x+rangex,y=cpos.y-rangey,z=cpos.z+rangez}
  if spacengine.test_area_ship(newpos,0)==true then return true end
  -- +x / -y / -z
  newpos={x=cpos.x+rangex,y=cpos.y-rangey,z=cpos.z-rangez}
  if spacengine.test_area_ship(newpos,0)==true then return true end
  -- -x / +y / -z
  newpos={x=cpos.x-rangex,y=cpos.y+rangey,z=cpos.z-rangez}
  if spacengine.test_area_ship(newpos,0)==true then return true end
  -- -x / +y / +z
  newpos={x=cpos.x-rangex,y=cpos.y+rangey,z=cpos.z+rangez}
  if spacengine.test_area_ship(newpos,0)==true then return true end
  -- +x / +y / +z
  newpos={x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez}
  if spacengine.test_area_ship(newpos,0)==true then return true end
  -- +x / +y / -z
  newpos={x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z-rangez}
  if spacengine.test_area_ship(newpos,0)==true then return true end

  return false
end

