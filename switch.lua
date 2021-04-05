--*** button ***

--
local list1,list2="",""
for i=1,#spacengine.upgrade[14] do
  list1=list1..spacengine.upgrade[14][i][1]
end

for i=1,#spacengine.upgrade[15] do
  list2=list2..spacengine.upgrade[15][i][1]
end

--check si switch dans un vaisseaux
local function check_punch(pos,puncher)
  local plname=puncher:get_player_name()
  local check,tool=spacengine.owner_check(puncher,pos)

  if check<2 then return false end

  if tool=="spacengine:tool" then return false end

  if spacengine.chg_form[plname]==nil then spacengine.chg_form[plname]={} end

  spacengine.chg_form[plname].option=">"
  spacengine.chg_form[plname].idx=1
  spacengine.chg_form[plname].check=check

  return true
end

--** SWITCH SETUP **
spacengine.switch_setup=function(pos,switch)
  local nod_met = minetest.get_meta(pos)
  nod_met:set_string("channel","No channel:noplayer")
  
  if switch=="t" then
    nod_met:set_string("spacengine","^t¨0¨0¨^bC0bC0bC0bC0¨1¨^")
    nod_met:set_string("infotext","CONTROLER on/off -- 1 --\nCONTROLER on/off -- 2 --\nCONTROLER on/off -- 3 --\nCONTROLER on/off -- 4 --" )
  elseif switch=="d" then
    nod_met:set_string("spacengine","^d¨0¨0¨^iB0iB0¨1¨^")
    nod_met:set_string("infotext","Keypad ON/OFF -- 1 --\nKeypad ON/OFF -- 2 --" )
  else
    local group=string.find("bia",switch)+13
    nod_met:set_string("spacengine","^".. switch .."¨0¨0¨^".. switch .. spacengine.upgrade[group][1][1] .."0¨1¨^")
    nod_met:set_string("infotext",spacengine.upgrade[group][1][2])
  end

  nod_met:set_string("pos_cont",minetest.pos_to_string({x=33333,y=0,z=0}))
  
end

--**************************
--**4 BOUTONS TECHNOLOGIE **
--**************************

--
--        punch | right
--          1       3
-- sneak    2       4
local function tech_4(pos,player,value,maj)
  local check,tool=spacengine.owner_check(player,pos)
  if check<2 then return false end

  local plname=player:get_player_name()
  spacengine.chg_form[plname]={}
  spacengine.chg_form[plname].idx=1
  spacengine.chg_form[plname].check=check

  if tool~="spacengine:tool" and maj==nil then
    local is_aux1 = player and player:get_player_control().aux1 or false

    if is_aux1 then value=value+1 end

    spacengine.chg_form[plname].option="ù"

    return spacengine.formspec_update(pos,player,value)

  else

    if value==101 then return end --dig node avec le tool desactive le bouton

    local nod_met = minetest.get_meta(pos)
    --channel : owner
    local channel=nod_met:get_string("channel")

    local spac_eng=spacengine.decompact(nod_met:get_string("spacengine"))

    local tmp=spac_eng[6]

    if tmp==nil or tmp=="" then tmp="1\n2\n3\n4" end

    local code=string.split(tmp,"\n")
    local split_cha=string.split(channel,":")

    local formspec="size[12,10]button_exit[0,8.25;2,1;submit;submit]" ..
      "label[0.25,0;Channel : ".. split_cha[1] .."]"..
      "label[0,1;Captain : ".. split_cha[2] .."]"
    local idx=0.25
    local idy=2
    for j=1,4 do

      if j==2 then
        idy=5
      elseif j==3 then
        idx=6.25
        idy=2
      elseif j==4 then
        idy=5
      end

      formspec=formspec.. "textlist["..idx..","..idy..";5.8,1.3;bp"..j..";"

      for i=1,#spacengine.upgrade[14] do
        if string.sub(spacengine.upgrade[14][i][2],1,1)~="^" then --caractere d'echapement
          if string.sub(spac_eng[4],(j*3)-1,(j*3)-1)==spacengine.upgrade[14][i][1] then
            formspec=formspec.. "X "..spacengine.upgrade[14][i][2]
          else
            formspec=formspec.. "- "..spacengine.upgrade[14][i][2]
          end
        
          if i<#spacengine.upgrade[14] then formspec=formspec.."," end

        end
      end

      formspec=formspec..";1]field[".. (idx+0.5) ..",".. (idy+1.8) ..";5,1;code"..j..";;".. code[j] .."]"

    end

    spacengine.chg_form[plname].position={x=pos.x,y=pos.y,z=pos.z}

    minetest.show_formspec(plname, "spacebutton_4btechbutton" , formspec)
  end

end

--******************
--** Double inter **
--******************

local function double_inter(pos,player,value,maj)
  local check,tool=spacengine.owner_check(player,pos)
  if check<2 then return false end

  local plname=player:get_player_name()
  spacengine.chg_form[plname]={}
  spacengine.chg_form[plname].idx=1
  spacengine.chg_form[plname].check=check

  if tool~="spacengine:tool" and maj==nil then
    
    local nod_met = minetest.get_meta(pos)
    local spac_eng=spacengine.decompact(nod_met:get_string("spacengine"))
    local vl1=string.byte(spac_eng[4],3)-48
    local vl2=string.byte(spac_eng[4],6)-48
    local lng=#spac_eng[4]

    if value==100 then
      spac_eng[5]=1
      value=0
      vl1=0
    elseif value==200 then
      spac_eng[5]=1
      value=1
      vl1=1
    elseif value==10 then
      spac_eng[5]=2
      value=0
      vl2=0
    elseif value==20 then
      spac_eng[5]=2
      value=1
      vl2=1
    end

    spac_eng[4]=string.sub(spac_eng[4],1,2) ..vl1.. string.sub(spac_eng[4],4,5)..vl2
    nod_met:set_string("spacengine",spacengine.compact(spac_eng))

    vl1=(vl1*10)+vl2

    local node=minetest.get_node(pos)
    minetest.swap_node(pos, {name="spacengine:i"..vl1 ,param2=node.param2})

    spacengine.chg_form[plname].option=">"

    return spacengine.formspec_update(pos,player,value)

  else
    if value>99 then return end --dig node avec le tool desactive le bouton

    local nod_met = minetest.get_meta(pos)
    --channel : owner
    local channel=nod_met:get_string("channel")

    local spac_eng=spacengine.decompact(nod_met:get_string("spacengine"))

    local tmp=spac_eng[6]

    if tmp==nil or tmp=="" then tmp="1\n2" end

    local code=string.split(tmp,"\n")
    local split_cha=string.split(channel,":")

    local formspec="size[12,10]button_exit[0,8.25;2,1;submit;submit]" ..
      "label[0.25,0;channel : ".. split_cha[1] .."]"..
      "label[0,1;Captain : ".. split_cha[2] .."]"

    local idx=0.25
    local idy=2
    for j=1,2 do

      if j==2 then
        idx=6.25
      end

      formspec=formspec.. "textlist["..idx..","..idy..";5.8,1.3;bp"..j..";"

      for i=1,#spacengine.upgrade[15] do
        if string.sub(spacengine.upgrade[15][i][2],1,1)~="^" then --caractere d'echapement
          if string.sub(spac_eng[4],(j*3)-1,(j*3)-1)==spacengine.upgrade[15][i][1] then
            formspec=formspec.. "X "..spacengine.upgrade[15][i][2]
          else
            formspec=formspec.. "- "..spacengine.upgrade[15][i][2]
          end
        
          if i<#spacengine.upgrade[15] then formspec=formspec.."," end

        end
      end

      formspec=formspec..";1]field[".. (idx+0.5) ..",".. (idy+1.8) ..";5,1;code"..j..";;".. code[j] .."]"

    end

    spacengine.chg_form[plname].position={x=pos.x,y=pos.y,z=pos.z}

    minetest.show_formspec(plname, "spacebutton_double_inter", formspec)
  end

end

--*******************
--** simple button **
--*******************
spacengine.switch_gui=function(pos,player,maj)
  local check,tool=spacengine.owner_check(player,pos)
  if check<2 then return false end

  local plname=player:get_player_name()
  spacengine.chg_form[plname]={}
  spacengine.chg_form[plname].idx=1
  spacengine.chg_form[plname].check=check

  local nod_met = minetest.get_meta(pos)
  --channel : owner
  local channel=nod_met:get_string("channel")
  local spac_eng=spacengine.decompact(nod_met:get_string("spacengine"))

  if tool~="spacengine:tool" and maj==nil then
    --mise a jour switch analog
    local cpos=minetest.string_to_pos(nod_met:get_string("pos_cont"))

    --recuperation position relative ou reel du controler
    local err=false
    local cont_met

    if string.find(channel,"No channel:") or cpos.x==33333 then return false end

    --position relative du controler
    cpos.x=pos.x-cpos.x
    cpos.y=pos.y-cpos.y
    cpos.z=pos.z-cpos.z
    cont_met=minetest.get_meta(cpos)

    if spacengine.test_area_ship(cpos,0,channel)==false then return false end
    
    local config=spacengine.area[channel].config
    local switch=string.sub(spac_eng[4],1,1)

    if switch=="b" or switch=="i" then return end
    
    local new_value=spacengine.punch_module(cpos,cont_met,config,spac_eng,channel,14,player,0)

    new_value=math.floor(new_value/20)
    local node=minetest.get_node(pos)
    local l_name=string.len(node.name)-1
    local new_name=string.sub(node.name,1,l_name)..new_value

    minetest.swap_node(pos, {name=new_name,param2=node.param2})

  else
  
  local split_cha=string.split(channel,":")
  local formspec="size[10,10]button_exit[0,8.25;2,1;submit;submit]" ..
    "label[0.25,0;channel : ".. split_cha[1] .."]"..
    "field[0.25,3;4,1;code;code;"..spac_eng[6].."]"..
    "label[0,1;Captain : ".. split_cha[2] .."]textlist[3.5,6.25;5.8,1.3;command;"
  local group=string.find("bia",spac_eng[1])+13

  for i=1,#spacengine.upgrade[group] do
    local new_desc=spacengine.upgrade[group][i][2]
    if string.sub(spacengine.upgrade[group][i][2],1,1)=="^" then --caractere d'echapement
      new_desc=string.sub(spacengine.upgrade[group][i][2],2)
    end

    if string.sub(spac_eng[4],2,2)==spacengine.upgrade[group][i][1] then
      formspec=formspec.. "X ".. new_desc
    else
      formspec=formspec.. "- ".. new_desc
    end
    if i<#spacengine.upgrade[group] then
      formspec=formspec..","
    end
  end

  formspec=formspec..";1]"

  local info=nod_met:get_string("infotext")
  if string.find(info,"\n") then
    formspec=formspec.."label[0.25,4.25;Show code]image_button[2,4;1,1;spacengine_croix.png;disable;]"
  else
    formspec=formspec.."label[0.25,4.25;Show code]image_button[2,4;1,1;spacengine_rien.png;enable;]"
  end

  spacengine.chg_form[plname].code=spac_eng[6]
  spacengine.chg_form[plname].position={x=pos.x,y=pos.y,z=pos.z}
  
  minetest.show_formspec(plname, "spacebutton_simplebutton" , formspec)
  end

end

--****************
minetest.register_on_player_receive_fields(function(player, formname, fields)

  if not string.find(formname,"spacebutton") then return end

  local plname=player:get_player_name()
  local newform=false
  --recupere coordo du node, channel et group
  local nod_met = minetest.get_meta(spacengine.chg_form[plname].position)
  local channel=nod_met:get_string("channel")
  local node=minetest.get_node(spacengine.chg_form[plname].position)
  local pos_cont=minetest.string_to_pos(nod_met:get_string("pos_cont"))
  local spac_eng=spacengine.decompact(nod_met:get_string("spacengine"))
  local cpos={x=spacengine.chg_form[plname].position.x-pos_cont.x, y=spacengine.chg_form[plname].position.y-pos_cont.y, z=spacengine.chg_form[plname].position.z-pos_cont.z}

--** normal button **
if string.find(formname,"simplebutton") then

  if fields.enable then
    local info=nod_met:get_string("infotext")
    nod_met:set_string("infotext", info.."\n"..spac_eng[6] )
    newform=true
  end

  if fields.disable then
    local info=nod_met:get_string("infotext")
    local spl=string.split(info,"\n")
    nod_met:set_string("infotext", spl[1] )
    newform=true
  end

  if fields.submit or fields.key_enter_field then

    spac_eng[6]=fields.code
    nod_met:set_string("spacengine",spacengine.compact(spac_eng))
    
    local info=nod_met:get_string("infotext")
    if string.find(info,"\n") then
      local spl=string.split(info,"\n")
      nod_met:set_string("infotext", spl[1] .."\n"..spac_eng[6] )
    end

  end

  if fields.command then
    if string.find(fields.command,"DCL") then
      fields.command=string.gsub(fields.command,"DCL:","")
      local tmp1=tonumber(fields.command)
      local group=string.find("bia",spac_eng[1])+13
      spac_eng[4]=spac_eng[1] .. spacengine.upgrade[group][tmp1][1] .."0"
      spac_eng[5]=1
      nod_met:set_string("infotext",spacengine.upgrade[group][tmp1][2])
      nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      newform=true
    end
  end

  if newform then
    return spacengine.switch_gui(spacengine.chg_form[plname].position,player,true)
  end

--**Tech4**
elseif string.find(formname,"4btechbutton") then

  if fields.code1=="" then fields.code1="1" end
  if fields.code2=="" then fields.code2="2" end
  if fields.code3=="" then fields.code3="3" end
  if fields.code4=="" then fields.code4="4" end

  if fields.submit or fields.key_enter_field then

    spac_eng[6]=fields.code1 .."\n".. fields.code2 .."\n".. fields.code3 .."\n".. fields.code4

    nod_met:set_string("spacengine",spacengine.compact(spac_eng))

    --MaJ infotext en sortant
    local infotext=""
    local tmp,idx
    for i=1,4 do
      tmp=string.sub(spac_eng[4],(3*i)-1,(3*i)-1)
      idx=string.find(list1,tmp)
      local code="code"..i
      infotext=infotext..spacengine.upgrade[14][idx][2].." -- ".. fields[code] .." -- "
      if i<4 then infotext=infotext.."\n" end
    end

    nod_met:set_string("infotext",infotext)
  end

  if fields.bp1 then
    local field_spl=string.split(fields.bp1,":")

    if string.find(field_spl[1],"DCL") then
      local tmp=tonumber(field_spl[2])
      spac_eng[4]="b".. spacengine.upgrade[14][tmp][1] .."0".. string.sub(spac_eng[4],4,12)

      nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      
      newform=true
    end
  end

  if fields.bp2 then
    local field_spl=string.split(fields.bp2,":")

    if string.find(field_spl[1],"DCL") then
      local tmp=tonumber(field_spl[2])
      spac_eng[4]=string.sub(spac_eng[4],1,3) .."b".. spacengine.upgrade[14][tmp][1] .."0".. string.sub(spac_eng[4],7,12)

      nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      
      newform=true
    end
  end

  if fields.bp3 then
    local field_spl=string.split(fields.bp3,":")

    if string.find(field_spl[1],"DCL") then
      local tmp=tonumber(field_spl[2])
      spac_eng[4]=string.sub(spac_eng[4],1,6) .."b".. spacengine.upgrade[14][tmp][1] .."0".. string.sub(spac_eng[4],10,12)

      nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      
      newform=true
    end
  end

  if fields.bp4 then
    local field_spl=string.split(fields.bp4,":")

    if string.find(field_spl[1],"DCL") then
      local tmp=tonumber(field_spl[2])
      spac_eng[4]=string.sub(spac_eng[4],1,9) .."b".. spacengine.upgrade[14][tmp][1] .."0"

      nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      
      newform=true
    end
  end

  if newform then
    return tech_4(spacengine.chg_form[plname].position,player,0,true)
  end

--**2 inter **
elseif string.find(formname,"double_inter") then

  if fields.code1=="" then fields.code1="1" end
  if fields.code2=="" then fields.code2="2" end

  if fields.submit or fields.key_enter_field then

    spac_eng[6]=fields.code1 .."\n".. fields.code2

    nod_met:set_string("spacengine",spacengine.compact(spac_eng))

    --MaJ infotext en sortant
    local infotext=""
    local tmp,idx
    for i=1,2 do
      tmp=string.sub(spac_eng[4],(3*i)-1,(3*i)-1)
      idx=string.find(list2,tmp)
      local code="code"..i
      infotext=infotext..spacengine.upgrade[15][idx][2].." -- ".. fields[code] .." -- "
      if i<2 then infotext=infotext.."\n" end
    end

    nod_met:set_string("infotext",infotext)
  end


  if fields.bp1 then
    local field_spl=string.split(fields.bp1,":")

    if string.find(field_spl[1],"DCL") then
      local tmp=tonumber(field_spl[2])
      spac_eng[4]="i".. spacengine.upgrade[15][tmp][1] .."0".. string.sub(spac_eng[4],4,6)

      nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      
      newform=true
    end
  end

  if fields.bp2 then
    local field_spl=string.split(fields.bp2,":")

    if string.find(field_spl[1],"DCL") then
      local tmp=tonumber(field_spl[2])
      spac_eng[4]=string.sub(spac_eng[4],1,3) .."i".. spacengine.upgrade[15][tmp][1] .."0"

      nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      
      newform=true
    end
  end

  if newform then
    return double_inter(spacengine.chg_form[plname].position,player,0,true)
  end
end

if fields.quit then
  spacengine.chg_form[plname]=nil
end

end)

--*** switch Bouton poussoir ***
minetest.register_node("spacengine:switch_bp", {
  description = "switch bp",
  inventory_image = "spacengine_switch_bp.png",
  tiles = {"spacengine_switch_bp.png"},
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
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"b")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    spacengine.formspec_update(pos,puncher,1)
  end
})


minetest.register_node("spacengine:switch_4bp1", {
  description = "switch 4bp 1",
  inventory_image = "spacengine_switch_4bp1_inv.png",
  tiles ={"spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png",{
			image = "spacengine_switch_4bp1.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.5
			},
		}},
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
  use_texture_alpha=true,
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"t")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    tech_4(pos,player,103)
	end,
  on_punch = function(pos, node, puncher)
    if not tech_4(pos,puncher,101) then return end
  end
})

minetest.register_node("spacengine:switch_4bp2", {
  description = "switch 4 bp 2",
  inventory_image = "spacengine_switch_4bp2_inv.png",
  tiles ={"spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png",{
			image = "spacengine_switch_4bp2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.5
			},
		}},
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
  use_texture_alpha=true,
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"t")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    tech_4(pos,player,103)
	end,
  on_punch = function(pos, node, puncher)
    if not tech_4(pos,puncher,101) then return end
  end
})

minetest.register_node("spacengine:switch_4bp3", {
  description = "switch 4 bp 3",
  inventory_image = "spacengine_switch_4bp3_inv.png",
  tiles ={"spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png",{
			image = "spacengine_switch_4bp3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.5
			},
		}},
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
  use_texture_alpha=true,
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"t")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    tech_4(pos,player,103)
	end,
  on_punch = function(pos, node, puncher)
    if not tech_4(pos,puncher,101) then return end
  end
})

minetest.register_node("spacengine:switch_4bp4", {
  description = "switch 4 bp 4",
  inventory_image = "spacengine_switch_4bp4_inv.png",
  tiles ={"spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png",{
			image = "spacengine_switch_4bp4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.5
			},
		}},
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
  use_texture_alpha=true,
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"t")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    tech_4(pos,player,103)
	end,
  on_punch = function(pos, node, puncher)
    if not tech_4(pos,puncher,101) then return end
  end
})

minetest.register_node("spacengine:switch_4bp5", {
  description = "switch 4 bp 5",
  inventory_image = "spacengine_switch_4bp5_inv.png",
  tiles ={"spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png",{
			image = "spacengine_switch_4bp5.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.5
			},
		}},
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
  use_texture_alpha=true,
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"t")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    tech_4(pos,player,103)
	end,
  on_punch = function(pos, node, puncher)
    if not tech_4(pos,puncher,101) then return end
  end
})
--*** switch Bouton emergency ***
minetest.register_node("spacengine:switch_emergency", {
  description = "switch emergency",
  inventory_image = "spacengine_switch_emergency.png",
  tiles = {"spacengine_switch_emergency.png"},
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
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"b")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    spacengine.formspec_update(pos,puncher,1)
  end
})

--*** switch Gouvernail ***
minetest.register_node("spacengine:gouvernail", {
  description = "gouvernail",
  inventory_image = "spacengine_gouvernail.png",
  tiles = {"spacengine_gouvernail.png"},
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
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"b")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    spacengine.formspec_update(pos,puncher,1)
  end
})

--*** inter on/off ***
minetest.register_node("spacengine:inter_0", {
  description = "interrupteur",
  inventory_image = "spacengine_inter0.png",
  tiles = {"spacengine_inter0.png"},
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
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"i")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:inter_1",param2=node.param2})
    spacengine.formspec_update(pos,puncher,1)
  end
})

minetest.register_node("spacengine:inter_1", {
  description = "button_1",
  tiles = {"spacengine_inter1.png"},
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
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"i")
  end,
  drop="spacengine:inter_0",
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:inter_0",param2=node.param2})
    spacengine.formspec_update(pos,puncher,0)
  end
})

--*** levier 3d ***
minetest.register_node("spacengine:levier0", {
  description = "levier0",
  drawtype = "mesh",
  mesh = "levier0.obj",
  tiles = {"spacengine_levier.png"},
  paramtype2 = "facedir",
  selection_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  collision_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  walkable = false,
  sunlight_propagates = true,
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_place = minetest.rotate_node,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:levier1",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-20)
  end
})

minetest.register_node("spacengine:levier1", {
  description = "levier1",
  drawtype = "mesh",
  mesh = "levier1.obj",
  tiles = {"spacengine_levier.png"},
  paramtype2 = "facedir",
  selection_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  collision_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  walkable = false,
  sunlight_propagates = true,
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:levier0",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:levier2",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-40)
  end
})

minetest.register_node("spacengine:levier2", {
  description = "levier2",
  drawtype = "mesh",
  mesh = "levier2.obj",
  tiles = {"spacengine_levier.png"},
  paramtype2 = "facedir",
  selection_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  collision_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  walkable = false,
  sunlight_propagates = true,
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:levier0",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:levier3",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-60)
  end
})

minetest.register_node("spacengine:levier3", {
  description = "levier3",
  drawtype = "mesh",
  mesh = "levier3.obj",
  tiles = {"spacengine_levier.png"},
  paramtype2 = "facedir",
  selection_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  collision_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  walkable = false,
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:levier0",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:levier4",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-80)
  end
})

minetest.register_node("spacengine:levier4", {
  description = "levier4",
  drawtype = "mesh",
  mesh = "levier4.obj",
  tiles = {"spacengine_levier.png"},
  paramtype2 = "facedir",
  selection_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  collision_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  walkable = false,
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:levier0",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:levier5",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-100)
  end
})

minetest.register_node("spacengine:levier5", {
  description = "levier5",
  drawtype = "mesh",
  mesh = "levier5.obj",
  tiles = {"spacengine_levier.png"},
  paramtype2 = "facedir",
  selection_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  collision_box = { type = "fixed", fixed = { -0.2,-0.5,-0.2,0.2,0,0.2} },
  walkable = false,
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:levier0",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:levier0",param2=node.param2})
    spacengine.formspec_update(pos,puncher,0)
  end
})

--*** curseur analogique ***
minetest.register_node("spacengine:analog00", {
  description = "curseur analogique",
  inventory_image = "spacengine_analog00.png",
  tiles = {"spacengine_analog00.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",

  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog01",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-20)
  end
})

minetest.register_node("spacengine:analog01", {
  tiles = {"spacengine_analog01.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",

  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog02",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-40)
  end
})

minetest.register_node("spacengine:analog02", {
  tiles = {"spacengine_analog02.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",

  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog03",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-60)
  end
})

minetest.register_node("spacengine:analog03", {
  tiles = {"spacengine_analog03.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog04",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-80)
  end
})

minetest.register_node("spacengine:analog04", {
  tiles = {"spacengine_analog04.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",

  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog05",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-100)
  end
})

minetest.register_node("spacengine:analog05", {
  tiles = {"spacengine_analog05.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",

  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog00",param2=node.param2})
    spacengine.formspec_update(pos,puncher,0)
  end
})

--*** levier propulsion ***
minetest.register_node("spacengine:analog10", {
  description = "Gaz trust",
  inventory_image = "spacengine_analog10.png",
  drawtype = "mesh",
  tiles = {"spacengine_analog10.png","spacengine_switch_side.png"},
  drawtype = "mesh",
	mesh = "slope.obj",
		selection_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
		collision_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog11",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-20)
  end
})

minetest.register_node("spacengine:analog11", {
  drawtype = "mesh",
  tiles = {"spacengine_analog11.png","spacengine_switch_side.png"},
  drawtype = "mesh",
	mesh = "slope.obj",
		selection_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
		collision_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog10",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog12",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-40)
  end
})

minetest.register_node("spacengine:analog12", {
  drawtype = "mesh",
  tiles = {"spacengine_analog12.png","spacengine_switch_side.png"},
  drawtype = "mesh",
	mesh = "slope.obj",
		selection_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
		collision_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog10",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog13",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-60)
  end
})

minetest.register_node("spacengine:analog13", {
  drawtype = "mesh",
  tiles = {"spacengine_analog13.png","spacengine_switch_side.png"},
  drawtype = "mesh",
	mesh = "slope.obj",
		selection_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
		collision_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog10",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog14",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-80)
  end
})

minetest.register_node("spacengine:analog14", {
  drawtype = "mesh",
  tiles = {"spacengine_analog14.png","spacengine_switch_side.png"},
  drawtype = "mesh",
	mesh = "slope.obj",
		selection_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
		collision_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog10",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog15",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-100)
  end
})

minetest.register_node("spacengine:analog15", {
  drawtype = "mesh",
  tiles = {"spacengine_analog15.png","spacengine_switch_side.png"},
  drawtype = "mesh",
	mesh = "slope.obj",
		selection_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
		collision_box = {
			type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, 0.4, 0.5,  0.5, 0.5}
	}
		},
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:analog10",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:analog10",param2=node.param2})
    spacengine.formspec_update(pos,puncher,0)
  end
})

--*** rotator analogique ***
minetest.register_node("spacengine:rotator00", {
  description = "Rotator analogique",
  inventory_image = "spacengine_rotator00.png",
  tiles = {"spacengine_rotator00.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:rotator00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:rotator01",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-20)
  end
})

minetest.register_node("spacengine:rotator01", {
  tiles = {"spacengine_rotator01.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:rotator00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:rotator02",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-40)
  end
})

minetest.register_node("spacengine:rotator02", {
  tiles = {"spacengine_rotator02.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:rotator00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:rotator03",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-60)
  end
})

minetest.register_node("spacengine:rotator03", {
  tiles = {"spacengine_rotator03.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",
  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:rotator00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:rotator04",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-80)
  end
})

minetest.register_node("spacengine:rotator04", {
  tiles = {"spacengine_rotator04.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",

  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:rotator00",
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  sunlight_propagates = true,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:rotator05",param2=node.param2})
    spacengine.formspec_update(pos,puncher,-100)
  end
})

minetest.register_node("spacengine:rotator05", {
  tiles = {"spacengine_rotator05.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",

  groups = {cracky=333, not_in_creative_inventory=1,spacengine=20},
  sounds = default.node_sound_stone_defaults(),
  drop="spacengine:rotator00",
  sunlight_propagates = true,
  on_construct=function(pos)
    spacengine.switch_setup(pos,"a")
  end,
  on_rightclick = function(pos, node, player)
    spacengine.switch_gui(pos,player)
	end,
  on_punch = function(pos, node, puncher)
if not check_punch(pos,puncher) then return end

    minetest.swap_node(pos, {name="spacengine:rotator00",param2=node.param2})
    spacengine.formspec_update(pos,puncher,0)
  end
})

--******************
--** DOUBLE INTER **
--******************
minetest.register_node("spacengine:i0", {
  description = "interrupteur double",
  inventory_image = "spacengine_i00.png",
  tiles = {"spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_i00.png"},
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
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"d")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    double_inter(pos,player,20,maj)
	end,
  on_punch = function(pos, node, puncher)
    double_inter(pos,puncher,200,maj)
  end
})

minetest.register_node("spacengine:i1", {
  tiles = {"spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_i01.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",
  drop="spacengine:i0",
  sunlight_propagates = true,
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"d")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    double_inter(pos,player,10,maj)
	end,
  on_punch = function(pos, node, puncher)
    double_inter(pos,puncher,200,maj)
  end
})

minetest.register_node("spacengine:i10", {
  tiles = {"spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_i10.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",
  drop="spacengine:i0",
  sunlight_propagates = true,
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"d")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    double_inter(pos,player,20,maj)
	end,
  on_punch = function(pos, node, puncher)
    double_inter(pos,puncher,100,maj)
  end
})

minetest.register_node("spacengine:i11", {
  tiles = {"spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_rien.png","spacengine_i11.png"},
  drawtype = "nodebox",
  node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.495, 0.5, 0.5, 0.5},
		},
    },
  paramtype = "light",
  paramtype2 = "facedir",
  drop="spacengine:i0",
  sunlight_propagates = true,
  groups = {cracky=333,spacengine=20,not_in_creative_inventory = spacengine.creative_enable},
  sounds = default.node_sound_stone_defaults(),
  on_construct=function(pos)
    spacengine.switch_setup(pos,"d")
  end,
  after_place_node=function(pos,placer)
    spacengine.placer_node(pos,placer)
  end,
  on_rightclick = function(pos, node, player)
    double_inter(pos,player,10,maj)
	end,
  on_punch = function(pos, node, puncher)
    double_inter(pos,puncher,100,maj)
  end
})
