spacengine.central_msg=function(msg,config,n_msg)
  local msg_hr,msg_mn=espace.horloge()
  local lng=string.len(msg)
  local s1,s2,s3="","",""

  if lng>26 then
    s3=string.sub(msg,27,42) 
  end
  if lng>10 then
    s2=string.sub(msg,11,26)
  end
  s1=string.sub(msg,1,10)

  local nb_msg=string.split(config[13][9],";")

  if n_msg==true then --pirate_team target
    config[13][9]=s1..s2..s3
  else
    config[13][9]=nb_msg[1] ..";".. nb_msg[2] ..";"..string.sub((msg_hr+100),2)..":"..string.sub((msg_mn+100),2).." "..s1..s2..s3
  end

  for i=3,#nb_msg do
    if i<9 then
      config[13][9]=config[13][9]..";"..nb_msg[i]
    end
  end

end



local function manutention_idx(config)
--100100100 x y z
local zone=math.floor((config[13][3]*config[4][4][4])/100)*2+1

if config[13][11]<100100 then config[13][11]=101101101 end

local id_z=(config[13][11] % 1000)-100
local id_y=(math.floor(config[13][11]/1000) % 1000)-100
local id_x=(math.floor(config[13][11]/1000000) % 1000)-100

id_x=id_x-1

if id_x<1 then
  id_x=zone
  id_z=id_z-1
end

if id_z<1 then
  id_z=zone
  id_y=id_y-1
end

if id_y<1 then
  id_y=zone
end

config[13][11]=id_z+100+((id_y+100)*1000)+((id_x+100)*1000000)

  return true,id_x,id_y,id_z
end

--************
--** pirate **
--************
--
local function new_name()
  local name=""
  local split_pirate={}

  if spacengine.pirate~=nil then
    split_pirate=string.split(spacengine.pirate,":")
  end

  local err=false
  local idx=0
  local deadlock=0

  repeat
    err=false
    deadlock=deadlock+1
    for i=1,10 do
      name=name..string.char(math.random(65,90))
    end

    idx=#split_pirate
    if idx>0 then
      for i=1,idx do
        if name==split_pirate[i] then
          err=true
        end
      end
    end

    if deadlock>3 then
      err=false
      name=name..tonumber(math.random(1,100))
    end
  until err==false

  return name
end


--list tout les vaisseaux pirate a proximiter
local function list_vaisseaux(pos,data)
  --recherche position
  local d
  local nb=0

  for k, v in pairs (spacengine.area) do
    --si c'est un vaisseaux pirate
    if string.find(k,":pirate_team") then
      d={x=math.abs(pos.x-v.p0.x),y=math.abs(pos.y-v.p0.y),z=math.abs(pos.z-v.p0.z)}
      d.max=math.max(d.x,d.y,d.z)
      --et qu'il est situé a moins de 100 bloc
      if d.max<100 then
        nb=nb+1
      end
    end
  end

  -- si plus de 2 vaisseaux pirate
  if nb>1 then return 2 end

  --verifie si free space
  if spacengine.check_free_place(pos,"pirate_team",data) then return 0 end

  return 1
end

--***********************
--** apparition pirate **
--***********************
local function pirate_add(pos,config,channel)
  --choix d'un nom de vaisseaux
  local shipname=new_name()

  --choix coordo d'apparition
  local coordox=math.random(1,81)-41
  local coordoy=math.random(1,81)-41
  local coordoz=math.random(1,81)-41

  local new_pos={x=pos.x+coordox,y=pos.y+coordoy,z=pos.z+coordoz}

  --choix type vaisseaux
  local idx=math.random(1,#spacengine.vaisseaux_pirate)

  --test area protect
  local secteur,bloc=espace.secteur(pos)
  local sect_protect=false
  local tmp=secteur_dat[bloc.nb+1]

  if tmp==8 then --8=jail
    sect_protect=true
  elseif tmp==7 then --atelier
    sect_protect=true
  elseif tmp==9 then --relache
    sect_protect=true
  elseif tmp==19 then --relache earth
    sect_protect=true
  elseif tmp==4 then --4=earth
    sect_protect=true
  elseif tmp==1 then --1=astroport
    sect_protect=true
  end

  --si bloc proteger reset compteur / arret des attaques
  if sect_protect then
    config[1][7]=0
    return
  end

  --test nb vaisseaux pirate present
  local result=list_vaisseaux(new_pos,spacengine.vaisseaux_pirate[idx][2])
  if result==1 then
    config[1][7]=math.random(100,500)
    spacengine.central_msg("ATTACK RISK",config)
    spacengine.make_sound("alarm",config[15])
    return
  elseif result==2 then
    config[1][7]=0
    spacengine.central_msg("Une patrouille arrive",config)
    spacengine.make_sound("notification",config[15])
    return
  end

  spacengine.central_msg("PIRATE ATTACK",config)
  spacengine.make_sound("alarm2",config[15])
  config[1][7]=math.random(50,1000)
  spacengine.pirate=spacengine.pirate .. shipname ..":"

  --spawn vaisseaux_pirate
  local filename=minetest.get_modpath("spacengine").."/schems/"..spacengine.vaisseaux_pirate[idx][1]
  local rangex=tonumber(string.sub(spacengine.vaisseaux_pirate[idx][2],2,3))
  local rangey=tonumber(string.sub(spacengine.vaisseaux_pirate[idx][2],5,6))
  local rangez=tonumber(string.sub(spacengine.vaisseaux_pirate[idx][2],8,9))

  --controler center
  local pos1={x=new_pos.x-rangex,y=new_pos.y-rangey,z=new_pos.z-rangez}

  local file = io.open(filename)
  local value = file:read("*a")
  file:close()
  worldedit.deserialize(pos1, value)

  local new_channel=shipname..":pirate_team"
  local pirate_met=minetest.get_meta(new_pos)
  pirate_met:set_string("channel",new_channel)
  pirate_met:set_string("captain","pirate_team")
  spacengine.test_area_ship(new_pos,1,new_channel,"pirate_team")
  spacengine.maj_pos_node(new_pos,"pirate_team",new_channel,0)

  spacengine.area[new_channel].config[1][1]=2
  spacengine.area[new_channel].config[1][7]=10
  --taille
  spacengine.area[new_channel].config[1][4]=spacengine.vaisseaux_pirate[idx][2]
  --sauvegarde target pos
  spacengine.area[new_channel].config[1][5][1]=pos.x
  spacengine.area[new_channel].config[1][5][2]=pos.y
  spacengine.area[new_channel].config[1][5][3]=pos.z
  --sauvegarde nom de la cible
  spacengine.central_msg(channel,spacengine.area[new_channel].config,true)

  --cpt cible ratage
  spacengine.area[new_channel].config[13][11]=0
  spacengine.area[new_channel].config[12]="y"
  local timer=minetest.get_node_timer(new_pos)
  timer:set(10,0)

end

local function pirate_remov(pos,channel,cont_met,config,action)
  --stop timer
  local timer=minetest.get_node_timer(pos)
  if timer:is_started() then
    timer:stop()
  end

  --enleve vaisseaux de la liste area
  spacengine.test_area_ship(pos,-1,channel)

  local spl_cha=string.split(channel,":")
  spacengine.pirate=string.gsub(spacengine.pirate,spl_cha[1] ..":" ,"")

  --si action=1 remov
  if action==1 then
    --son au decollage
    minetest.sound_play("spacengine_jump_start", {
      pos = cpos,
      gain = 1.5,
      max_hear_distance = 80
    })
    --recupere data taille
    local rangex=tonumber(string.sub(config[1][4],2,3))
    local rangey=tonumber(string.sub(config[1][4],5,6))
    local rangez=tonumber(string.sub(config[1][4],8,9))
    local range=math.max(math.abs(rangex),math.abs(rangey),math.abs(rangez))
    local pos1={x=pos.x-rangex,y=pos.y-rangey,z=pos.z-rangez}
    local pos2={x=pos.x+rangex,y=pos.y+rangey,z=pos.z+rangez}
    --efface vaisseaux
    worldedit.set(pos1, pos2, "vacuum:vacuum")
    --efface tout objet sauf player
    local all_objects = minetest.get_objects_inside_radius(pos, range+1)

    for _,obj in ipairs(all_objects) do
      local objPos = obj:get_pos()
      local isPlayer = obj:is_player()
      local xMatch = objPos.x >= pos1.x and objPos.x <= pos2.x
      local yMatch = objPos.y >= pos1.y and objPos.y <= pos2.y
      local zMatch = objPos.z >= pos1.z and objPos.z <= pos2.z

      if xMatch and yMatch and zMatch and not isPlayer then
        obj:remove()
      end
    end

  --si action=2 abandon
  else
    --modifie config vaisseaux off + vente
    channel=string.gsub(channel,"pirate_team","") .. "ship_dealer"

    spacengine.sell_ship(pos,channel,"ship_dealer")
    config[1][1]=0
    cont_met:set_string("vente","500")
  end

  spacengine.save_area()
end

--** pirate new target **
local function pirate_new_target(pos,config)
  channel=string.split(config[13][9],";")
  local err=false
  local new_pos
  if spacengine.area[channel[1]] then
    new_pos=spacengine.area[channel[1]].p0

    if math.abs(pos.x-new_pos.x)>80 then err=true end
    if math.abs(pos.y-new_pos.y)>80 then err=true end
    if math.abs(pos.z-new_pos.z)>80 then err=true end

  else
    err=true
  end

  if err==true then
    config[13][11]=80
  else
    --sauvegarde target pos
    config[1][5][1]=new_pos.x
    config[1][5][2]=new_pos.y
    config[1][5][3]=new_pos.z
  end
end

--** pirate_fire **
local function pirate_fire(pos,channel,cont_met,config)
  --test degat shield
  if (config[5][4]/config[5][1])>95 or math.random(1500)==750 or config[13][11]>75 then
    --remove pirate
    pirate_remov(pos,channel,cont_met,config,1)
    return 1
  end
  --si grave degat abandon
  if config[1][3]>95 then
    --abandon vaisseaux
    pirate_remov(pos,channel,cont_met,config,2)
    return 1
  end

  --verification si toujours vaisseaux
  local controler=minetest.get_node({x=config[1][5][1],y=config[1][5][2],z=config[1][5][3]})

  if controler.name~="spacengine:controler" then pirate_new_target(pos,config) end

  --calcul range
  local rangex=config[1][5][1]-pos.x
  local rangey=config[1][5][2]-pos.y
  local rangez=config[1][5][3]-pos.z
  local range=math.max(math.abs(rangex),math.abs(rangey),math.abs(rangez))

  --calcul aim
  local coef=100/(config[6][3]*2)
  config[4][4][1]=math.floor((config[6][3]+rangex)*coef)
  config[4][4][2]=math.floor((config[6][3]+rangey)*coef)
  config[4][4][3]=math.floor((config[6][3]+rangez)*coef)
  config[4][4][4]=math.floor(50,100)
  --reglage range
  config[6][4]=100
  --puissance weapons shield
  config[6][2]=100
  config[5][2]=100
  --timer prochain tir
  config[1][7]=math.random(10,20)

  msg=spacengine.weapons(pos,channel,cont_met,config,nil)

  return 0
end
--]]

--*****************
--*** controler ***
--*****************
spacengine.controler=function(pos,scr)
  local cont_met = minetest.get_meta(pos)
  local pos_cont=minetest.string_to_pos(cont_met:get_string("pos_cont"))
  local channel=cont_met:get_string("channel")

  if pos_cont.x>31000 then return end

  if spacengine.area[channel].config == nil then return end --erreur config absent

  local config=spacengine.area[channel].config

  if type(config[12])=="table" then config[12]=nil end --en cas d'erreur

  if config[1][1]==0 and config[12]=="n" then return end

  --temps ecouler entre 2 appels
  local t1 = minetest.get_us_time()

  local new_screen=""
  config[3][2]=0
  local new_pos

  --position power et screen
  local id_stock_pos=0
  local stock_pos=spacengine.decompact(cont_met:get_string("stock_pos"))

  if stock_pos then id_stock_pos=#stock_pos end

  if id_stock_pos>1 then
    
    for idx=2,id_stock_pos do
      new_pos={x=stock_pos[idx][1]+pos.x,y=stock_pos[idx][2]+pos.y,z=stock_pos[idx][3]+pos.z}
      dst=minetest.get_node(new_pos) 
      nod_met=minetest.get_meta(new_pos)
      local cha_dst=nod_met:get_string("channel")

      if cha_dst==channel then --ifchannel ok
        local dst_group=minetest.get_item_group(dst.name,"spacengine")

        if dst_group==3 and t1>config[14] and scr==nil then
          local rs=spacengine.power(new_pos,nod_met,cont_met,config)
          if rs==true then new_screen=new_screen.."e" end

        elseif dst_group==12 then

          if dst.name=="monitor:screen_led" then new_screen=new_screen.."m" end

          if config[12] and config[12]~="n" then
            spacengine.screen_display(new_pos,nod_met,pos,cont_met,config)
          end
        end

      end
    end
  end

  if t1>config[14] and config[1][1]>0 and scr==nil then --minimum 5 sec.

    --attaque de pirate
    if config[1][7]==nil then config[1][7]=10 end

    if config[1][7]>0 then
      config[1][7]=config[1][7]-1

      if config[1][1]==2 and config[1][7]==1 then
        local action=pirate_fire(pos,channel,cont_met,config)
        if action==1 then return end
        new_screen=new_screen.."y"
      end

      if config[1][1]==1 and config[1][7]==1 then
        pirate_add(pos_cont,config,channel)
      end
    
    end

    t1=math.ceil((t1-config[14])/4500000)

    --** temperature moteur **
    if config[4][6]>0 then
      --refroidi meme si vaisseaux arreter depuis longtemps
      config[4][6]=math.max(0,config[4][6]-(t1*config[4][5]))
        --config[4][6]=math.max(0,config[4][6]-config[4][5])
      
      new_screen=new_screen.."E"
    end

    --** reload weapons **
    if config[6][6]>0 then
      config[6][6]=math.max(0,config[6][6]-t1)
      new_screen=new_screen.."W"
    end

    --** regeneration shield **
    if config[5][4]<config[5][1] then
      config[5][4]=math.floor(math.min(config[5][1],config[5][4]+config[5][3]))
      new_screen=new_screen.."S"
    end

    if config[5][2]>0 then
      local sh=math.ceil(config[5][4]*config[5][2]*0.01)
      config[3][2]=config[3][2]-sh

      if config[1][1]==1 then --only player spacengine
        config[2][2]=math.max(0,config[2][2]-sh)
        if config[2][2]==0 then
          config[5][2]=0
          spacengine.central_msg("SHIELD OFF LOW BAT",config)
          spacengine.make_sound("alert",config[15])
        end
      end

    end

    --** gravitation **
    if config[8][2]>0 then
      local g=config[8][2]*(config[8][1] % 1000)*math.floor(config[8][1]/1000)
      config[3][2]=config[3][2]-math.ceil(g)

      if config[1][1]==1 then --only player spacengine
        config[2][2]=math.max(0,math.floor(config[2][2]-g))

        if config[2][2]==0 then
          config[8][2]=0
          spacengine.central_msg("MODULE GRAVITON STOP LOW BAT",config)
          spacengine.make_sound("alarm2",config[15])
        end

        new_screen=new_screen.."G"
      end
      

    end

    --** oxygene **
    if config[11][2]>0 or config[11][4]>0 then
      config[11][4]=config[11][4]-1
      new_screen=new_screen.."O"

        if config[11][4]<2 then
          if config[11][2]==0 then
            config[11][4]=0
          else
            config[11][4]=1
          end
          spacengine.oxygene(pos,config)
        end

    end

    --** manutention **
    if config[13][10]>-1 then
      config[13][10]=math.max(0,config[13][10]-1)
      if config[13][10]==0 then
        local msg=spacengine.manutention(pos,cont_met,config,channel)
        if msg then
          spacengine.make_sound("notification",config[15])
          spacengine.central_msg(msg,config)
          new_screen=new_screen.."M"
        end
      end
    end

    -- consommation vaisseaux base
    if config[1][1]==1 then --only player spacengine
      local volume=tonumber(string.sub(config[1][4],8,9))+config[1][3]
      config[3][2]=config[3][2]-volume-config[4][2]
      config[2][2]=math.max(0,math.floor(config[2][2]-volume))
      if config[2][2]<(config[2][1]*0.1) then
        if string.sub(config[13][9],1,1)=="0" then
          config[13][9]="1".. string.sub(config[13][9],2)
          spacengine.central_msg("LOW BAT.",config)
          spacengine.make_sound("alarm",config[15])
        end
      end
    end

    -- puissance moyenne
    config[3][3]=config[3][2]

    -- timer
    config[14]=minetest.get_us_time()+4500000
  end

  if new_screen=="" then
    config[12]="n"
  else
    config[12]=new_screen
  end

end

--*************
--*** power ***
--*************
spacengine.power=function(pos,nod_met,cont_met,config)
  local spac_eng=spacengine.decompact(nod_met:get_string("spacengine"))
  local pos_cont=minetest.string_to_pos(nod_met:get_string("pos_cont"))
  local refresh_screen=false

  if pos_cont.x==33333 then return end --controler invalid

  if spac_eng[8]==1 and config[1][1]>0 then --power activer

    local time_release=spac_eng[9] --timer

    local cont_inv = cont_met:get_inventory()
    local capa,charg=config[2][1],config[2][2]

    --mode safe state
    if time_release<0 then
      if charg<capa*0.75 and spac_eng[4]>0 then
        time_release=-time_release
          spacengine.make_sound("sonnerie_porte",config[15])
      else
        return
      end
    end

    local damage=(100-config[1][3])*0.01
    local src=spac_eng[5]

    if time_release>0 then --timer on
      local p=spac_eng[4]
      local coef=0
      refresh_screen=true

      if src=="solar" then
        local light=minetest.get_node_light({x=pos.x,y=pos.y+1,z=pos.z})
        if light==nil then light=0 end
        if light>10 then coef=(light-10)*0.14 end

      elseif src=="water" then
        local water=minetest.find_nodes_in_area({x=pos.x-1,y=pos.y-1,z=pos.z-1},{x=pos.x+1,y=pos.y+1,z=pos.z+1},{"default:water_flowing","default:river_water_flowing"})
        if #water > 7 then coef=(#water-7)*0.05 end

      elseif src=="battery" then
        if charg-p>0 then
          charg=math.max(0,charg-p)
        end
        if charg==0 then --stop si battery decharger
          time_release=0
          spac_eng[9]=0
          spacengine.central_msg("POWER OFF - LOW "..src,config)
          spacengine.make_sound("detector",config[15])
        end

      else --node
        coef=1
      end

      local dst=spac_eng[6]
      if dst=="battery" then --destination
        charg=math.min(capa,charg+(p*coef*damage))
        config[2][2]=math.floor(charg)
        if charg==capa and spac_eng[4]>0 then
          config[13][9]="0".. string.sub(config[13][9],2)
          spacengine.make_sound("sonnerie_porte",config[15])
          time_release=-time_release
          
        end
      end

      if p<0 then --utilisation de la battery
        coef=1
        charg=math.max(0,charg+p)
        config[2][2]=math.floor(charg)
        if charg==0 then --stop si battery decharger
          time_release=0
          spac_eng[8]=0
          refresh_screen=false
          spacengine.central_msg("POWER OFF LOW BATT",config)
          spacengine.make_sound("notification",config[15])
        end
      end

      if time_release==1 and dst~="battery" and coef>0 then --quand transformation terminer add to l'inventaire
        if cont_inv:room_for_item("stock",spac_eng[6]) then
          if config[1][1]==1 then --only player spacengine
            cont_inv:add_item("stock",spac_eng[6])
          end
        else
          time_release=0
          spac_eng[8]=0
          spacengine.central_msg("POWER STOCK FULL",config)
          spacengine.make_sound("notification",config[15])
        end
      end

      spac_eng[10]=math.ceil(p*coef)
      config[3][2]=config[3][2]+spac_eng[10]

      if coef>0 and time_release>0 then  --bloque timer si pas d'energy sinon decompte
        time_release=time_release-1
      else
        refresh_screen=false
      end
      
    else
      if src=="solar" or src=="water" or src=="battery" then
        time_release=spac_eng[7]
      else
        if cont_inv:contains_item("stock",src) then
          if config[1][1]==1 then --only player spacengine
            cont_inv:remove_item("stock",src)
          end
          time_release=spac_eng[7]
        else
          spacengine.central_msg("POWER STOCK EMPTY "..src,config)
          spacengine.make_sound("notification",config[15])
        end
      end

    end

    spac_eng[9]=time_release
    
    nod_met:set_string("spacengine",spacengine.compact(spac_eng))
  end

  return refresh_screen
end

--***************
--*** Weapons ***
--***************

spacengine.weapons=function(cpos,channel,cont_met,config,puncher)
  local toucher=false
  if config[6][6]>0 then return "WAIT HOT" end

  local damage=(100-config[1][3])*0.01
  local puissance=math.floor(config[6][1]*config[6][2]*0.01)
  local range=math.floor(config[6][3]*config[6][4]*0.01)
  local zone=math.ceil(config[6][8]*config[4][4][4]*0.01)
  local xrng=math.ceil((-1+(0.02*config[4][4][1]))*range)
  local yrng=math.ceil((-1+(0.02*config[4][4][2]))*range)
  local zrng=math.ceil((-1+(0.02*config[4][4][3]))*range)
  local rmax=math.max(math.abs(xrng),math.abs(yrng),math.abs(zrng))
  local conso=(puissance*2)+(rmax*10)+(zone^3)

  if config[2][2]-conso<0 then return "BATTERY TOO LOW" end

  local nb_weapons=math.ceil(config[6][7]*damage)
  local chance=rmax*zone^3
  local trigger=math.ceil(chance*0.1)
  chance=math.ceil(chance/nb_weapons)
  if rmax<31 then
    rmax=1
  else
    rmax=1-(math.min(70,rmax-30)/70)
  end

  local degat=math.ceil(puissance*damage*rmax*0.1)

  --taille du vaisseaux
  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))
--direction
  local aleax=math.floor((math.random(100)*zone*0.02)-(zone/2))
  local aleay=math.floor((math.random(100)*zone*0.02)-(zone/2))
  local aleaz=math.floor((math.random(100)*zone*0.02)-(zone/2))

local err=0
if xrng>-rangex and xrng<rangex then err=err+1 end
if yrng>-rangey and yrng<rangey then err=err+1 end
if zrng>-rangez and zrng<rangez then err=err+1 end

if err==3 then return "SUICIDE" end

  local impact=math.random(1,chance)

  local pos3={x=cpos.x+xrng,y=cpos.y+yrng,z=cpos.z+zrng}
  local cible_destroy={x=pos3.x+aleax,y=pos3.y+aleay,z=pos3.z+aleaz}

  if cible_destroy.y<1008 or cible_destroy.y>10207 then return "OUT SPACE" end
  if cible_destroy.x<-30500 or cible_destroy.x>30500 then return "OUT SPACE" end
  if cible_destroy.z<-30500 or cible_destroy.z>30500 then return "OUT SPACE" end

  spacengine.make_sound("laser",config[15])

  if config[1][1]<2 then
    config[6][6]=config[6][5] --timer on
    config[2][2]=config[2][2]-conso --consommation
  end

  --search and destroy entity mob
  if puissance>2500 then
    local list=minetest.get_objects_inside_radius(cible_destroy,zone)

    if #list>0 then

      local obj_pos, dist
      
      for _,obj in ipairs(list) do
        obj_pos = obj:get_pos()
        local ent = obj:get_luaentity()

        if obj:is_player() or string.find(ent.name,"mobs") and impact<trigger then
          -- protect area shield
          local found,pos_shield=spacengine.test_area_ship(obj_pos,0)

          if found then
            local target,new_degat=spacengine.check_shield(pos_shield,degat,config)
            if target==true then
              new_degat=math.ceil(new_degat/100)
              toucher=true
              spacengine.explosion(obj_pos)
              obj:punch(list[1], 1.0, {
                full_punch_interval = 1.0,
                damage_groups = {fleshy = new_degat},
              })
              degat=0
              break
            end
          end
        end
      end
    end
  end

  if toucher==false then
    local node,group

      for i=1,nb_weapons do

        impact=math.random(1,chance)
        aleax=math.floor((math.random(100)*zone*0.02)-(zone/2))
        aleay=math.floor((math.random(100)*zone*0.02)-(zone/2))
        aleaz=math.floor((math.random(100)*zone*0.02)-(zone/2))

        cible_destroy={x=pos3.x+aleax,y=pos3.y+aleay,z=pos3.z+aleaz}
        node=minetest.get_node(cible_destroy)

        if minetest.get_item_group(node.name,"spacengine")>0 then
          if spacengine.destroy_target(cpos,cible_destroy,node,degat,config) then
            toucher=true
          end
        end

        -- protection
        if not minetest.is_protected(cible_destroy,"") then

          group=0

          if minetest.get_item_group(node.name,"crumbly")==3 then
            group=10
          elseif minetest.get_item_group(node.name,"cracky")==3 and puissance>2000 then
            group=20
          elseif minetest.get_item_group(node.name,"cracky")==2 and puissance>4000 then
            group=40
          elseif minetest.get_item_group(node.name,"cracky")==1 and puissance>6000 then
            group=50
          elseif minetest.get_item_group(node.name,"wall")>0 then
            group=60
          end

          if group>0 and impact<trigger then
            local found,pos_shield=spacengine.test_area_ship(cible_destroy,0)
            if found then
              if spacengine.check_shield(pos_shield,degat,config) then
                minetest.remove_node(cible_destroy)
                toucher=true
              end
            else
              minetest.remove_node(cible_destroy)
              toucher=true
            end
          end

        end

        spacengine.explosion(cible_destroy)
      end
  end

  if toucher then
    spacengine.make_sound("bip",config[15])
  else

    if config[1][1]==2 then --comptabilise les rater
      config[13][11]=config[13][11]+1
    end

  end

  return
end

--*************
--*** RADAR ***
--*************
local function scan_entity(cpos,zone,cible)
  local nb=0
  local name
  local scan=0
  if cible[2]=="all" then
    scan=2
    name=""
  elseif cible[2]=="group" then
    scan=1
    name=cible[3]
  else
    name=cible[2]..":"..cible[3]
  end

  for _,obj in pairs(minetest.get_objects_inside_radius(cpos, zone)) do

		if obj:get_player_name() ~= "" and cible_spl[1]=="player" then
			nb=nb+1
    end

		if not obj:is_player() and cible_spl[1]=="mob" then
			local luaentity = obj:get_luaentity()
			local isname = luaentity.name
			if isname and scan<2 then

        if scan==1 then
          if string.find(isname,name) or (isname == "__builtin:item" and string.find(luaentity.itemstring,name)) then
            nb=nb+1
          end
        else
          if isname == name or (isname == "__builtin:item" and luaentity.itemstring == name) then
            nb=nb+1
          end
        end

      else
        nb=nb+1
			end
		end
	end

  return nb
end

spacengine.radar=function(cpos,channel,cont_met,config)
  local puissance=math.ceil(config[7][1]*config[7][2]/100)
  if config[2][2]-puissance<0 then return end
  
  local pos1,pos2
  local id=math.max(1,config[7][6])

  if type(config[7][4])~="table" then return end

  local cible=string.split(config[7][4][id],":")

  if cible[1]=="none" then return end

  local damage=(100-config[1][3])*0.01
  --direction
  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))
  local pos1,pos2
  local zone=math.ceil(config[7][3]*config[4][4][4]/100)
  local xrng=math.ceil((-1+(0.02*config[4][4][1]))*config[7][3])
  local yrng=math.ceil((-1+(0.02*config[4][4][2]))*config[7][3])
  local zrng=math.ceil((-1+(0.02*config[4][4][3]))*config[7][3])

  local err=0
  if xrng>-rangex and xrng<rangex then err=err+1 end
  if yrng>-rangey and yrng<rangey then err=err+1 end
  if zrng>-rangez and zrng<rangez then err=err+1 end

  if err==3 then return "HELLO" end --prevent narcissisme ;-D

  if cpos.y<1008 or cpos.y>10207 then return end
  if cpos.x<-30500 or cpos.x>30500 then return end
  if cpos.z<-30500 or cpos.z>30500 then return end

  spacengine.make_sound("sonar",config[15])
  config[2][2]=config[2][2]-puissance

  pos1={x=cpos.x+xrng-zone,y=cpos.y+yrng-zone,z=cpos.z+zrng-zone}
  pos2={x=cpos.x+xrng+zone,y=cpos.y+yrng+zone,z=cpos.z+zrng+zone}

  local nb=0

  -- mob et player
  if cible[1]=="player" or cible[1]=="mobs" then
    nb=scan_entity(cpos,zone,cible)
  else
    local list=minetest.find_nodes_in_area(pos1,pos2,cible[1]..":"..cible[2])
    if list~=nil then
      nb=#list
    end
  end

  nb=math.floor(nb*config[7][2]*0.01*damage)

  --research mission
  if cible[4] then
    if nb>0 then
    local tmp=spacengine.area[channel].mission
    if tmp=="" then return 1 end
    local mission=string.split(tmp,"/")
    --recherche ref
    local mission_spl
    local idx=0

    for i=1,#mission do
      if string.find(mission[i],cible[4]) then
        mission_spl=string.split(mission[i],":")
        idx=i
        break
      end
    end

    if mission_spl==nil or idx==0 then return nb end

    --compare secteur
    local this_sector=espace.secteur(pos)
    if this_sector.nb~=tonumber(mission_spl[7]) then return 1 end
    --recupere date
    local new_dat=tonumber(mission_spl[5])-(((espace.year-1)*168)+((espace.month-1)*14)+espace.day)
    local captain=spacengine.area[channel].captain
    --add monney suivant date(bonus ou penaliter)
    atm.balance[captain]=math.max(0,atm.balance[captain]+(mission_spl[4]*new_dat))
    atm.saveaccounts()
    --remove mission
    tmp=""
    for i=1,#mission do
      if i~=idx then tmp=tmp..mission[i] end
      if i<#mission then tmp=tmp.."/" end
    end
    
    spacengine.area[channel].mission=tmp
  end

  end

  config[7][5][id]=nb
  
end

--*******************
--*** MANUTENTION ***
--*******************

--
local function test_mission(pos,channel,ref)
  local tmp=spacengine.area[channel].mission
  if ref==nil then ref="" end --en cas de bug
  if tmp=="" then return 1 end
  local mission=string.split(tmp,"/")
  --recherche ref
  local mission_spl
  local calcul=0
  local idx=0
--
  for i=1,#mission do
    if string.find(mission[i],ref) then
      mission_spl=string.split(mission[i],":")
      idx=i
      break
    end
  end

  if mission_spl==nil or idx==0 then return 1 end

  --compare secteur
  local this_sector=espace.secteur(pos)
  if mission_spl[7]~=nil then --en cas de bug

  if this_sector.nb~=tonumber(mission_spl[7]) then return 1 end
  --recupere date
  local new_dat=tonumber(mission_spl[5])-(((espace.year-1)*168)+((espace.month-1)*14)+espace.day)
  --add monney suivant date(bonus ou penaliter)
  local captain=spacengine.area[channel].captain
  atm.balance[captain]=math.max(0,atm.balance[captain]+(mission_spl[6]*new_dat))
  atm.saveaccounts()
  --dec compteur
  calcul=tonumber(mission_spl[3])-1
  else
    calcul=0
  end
--]]
  tmp=""
  for i=1,#mission do
    if i~=idx then tmp=tmp..mission[i] end
    if i<#mission then tmp=tmp.."/" end
  end

  --si compteur a 0, remove mission
  if calcul<1 then
    spacengine.area[channel].mission=tmp
    return 2
  else
    tmp=tmp.."/"
    mission_spl[3]=tostring(calcul)
    for i=1,#mission_spl do
      tmp=tmp..mission_spl[i]
      if i<#mission_spl then tmp=tmp..":" end
    end
    spacengine.area[channel].mission=tmp
  end

  return -1
end

spacengine.manutention=function(pos,cont_met,config,channel)

  if config[13][10]>0 then return end

  local damage=(100-config[1][3])*0.01
  local puissance=math.floor(config[13][1]*config[13][2]*0.01*damage)
  local data_cible
  local zone=math.floor(config[13][3]*config[4][4][4]*0.01*damage)
  local xrng=math.ceil((-1+(0.02*config[4][4][1]))*puissance)
  local yrng=math.ceil((-1+(0.02*config[4][4][2]))*puissance)
  local zrng=math.ceil((-1+(0.02*config[4][4][3]))*puissance)
  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))
  local pos1

  if pos.y<1008 or pos.y>10207 then return "OUT SPACE" end
  if pos.x<-30500 or pos.x>30500 then return "OUT SPACE" end
  if pos.z<-30500 or pos.z>30500 then return "OUT SPACE" end

  local err=0
  if xrng>-rangex and xrng<rangex then err=err+1 end
  if yrng>-rangey and yrng<rangey then err=err+1 end
  if zrng>-rangez and zrng<rangez then err=err+1 end

  if err==3 then return "ON SHIP" end --prevent dig your ship

  if config[13][11]==nil then config[13][11]=0 end

  local active,id_x,id_y,id_z=manutention_idx(config)

  if not active then
    return "TERMINATED"
  end

  pos1={x=pos.x+xrng-zone+id_x,y=pos.y+yrng-zone+id_y,z=pos.z+zrng-zone+id_z}

  if type(config[13][5])=="table" then
    data_cible=string.split(config[13][5][config[13][6]],":")
  else
    data_cible=string.split(config[13][5],":")
  end

  if data_cible[1]=="none" then
    config[13][10]=-1
    return
  end

  local cible=data_cible[1] ..":".. data_cible[2]

  if config[2][2]-tonumber(data_cible[5])<0 then
    config[13][10]=-1
    return "LOW BATTERY"
  end

  local sav_conf=false
  local cont_inv = cont_met:get_inventory()
  --***********
  --** BUILD **
  --***********
  if string.find(config[13][7],"B") and string.find(data_cible[4],"B") then
    if config[13][8]==1 then
      --protect
      if minetest.is_protected(pos1,"") then
        config[13][10]=-1
        return "! PROTECTED !"
      end

      local node=minetest.get_node(pos1)

      if node.name=="ignore" then
        config[13][10]=-1
        return "MAP ERROR"
      end

      if node.name=="air" or node.name=="vacuum:vacuum" then --build only si de la place

        err=0
        if data_cible[6]~="0" then
          err=test_mission(pos,channel,data_cible[6])
          if err==2 then
            data_cible[6]="0"
            data_cible[1]="none"
          end
        end

        if err>0 then
          config[13][10]=-1
          return "ERROR"
        elseif err>-1 then

          if not cont_inv:contains_item("stock",cible) then
            config[13][10]=-1
            return "STOCK EMPTY"
          end

          cont_inv:remove_item("stock",cible)
        end

        minetest.set_node(pos1,{name=cible})
        spacengine.mark_target(pos1,"spacengine_dig.png")

        config[13][10]=math.ceil(tonumber(data_cible[3])*config[13][12]*0.01)
        config[2][2]=config[2][2]-tonumber(data_cible[5])
      end
      sav_conf=true
    end
  end

  --*********
  --** DIG **
  --*********
  if string.find(config[13][7],"D") and string.find(data_cible[4],"D") then
    if config[13][8]==2 then
      local node=minetest.get_node(pos1)
      local group_cracky=minetest.get_item_group(node.name,"cracky")
      err=0

      if data_cible[1]=="star" then
        if group_cracky==335 then
          cible="default:mese_crystal_fragment"
        else
          err=1
        end
      elseif data_cible[1]=="nebuleuse" then
        if group_cracky==334 then
          cible="espace:star_dust"
        else
          err=1
        end
      else
        if node.name~=cible then err=1 end
      end

      if minetest.get_item_group(node.name,"unbreakable")~=0 then
        config[13][10]=-1
        return "! PROTECTED !"
      end

      if err==0 then
        --protect
        if minetest.is_protected(pos1,"") then
          config[13][10]=-1
          return "! PROTECTED !"
        end

        err=0
        if data_cible[6]~=nil then
          err=test_mission(pos,channel,data_cible[6])

          if err==2 then
            data_cible[6]="0"
            data_cible[1]="none"
          end
        end

        if err>0 then
          config[13][10]=-1
          return "ERROR"
        elseif err>-1 then
          --add to controler
          if cont_inv:room_for_item("stock",cible) then
            cont_inv:add_item("stock",cible)
          else
            config[13][10]=-1
            return "STOCK FULL"
          end
        end

        --digg 1 by 1
        minetest.remove_node(pos1)
        spacengine.mark_target(pos1,"spacengine_blast02.png")
        config[2][2]=config[2][2]-tonumber(data_cible[5])
      else
        spacengine.mark_target(pos1,"spacengine_dig.png")
      end
      config[13][10]=math.ceil(tonumber(data_cible[3])*config[13][12]*0.01)
      sav_conf=true
    end
  end

  --**********
  --** PUMP **
  --**********
  if string.find(config[13][7],"P") and string.find(data_cible[4],"P") then
    if config[13][8]==3 then
      local node=minetest.get_node(pos1)
      if node.name==cible then
        --protect
        if minetest.is_protected(pos1,"") then
          config[13][10]=-1
          return "! PROTECTED !"
        end
        --add to controler
        local cont_inv = cont_met:get_inventory()
        if cont_inv:room_for_item("stock",cible) then
          cont_inv:add_item("stock",cible)
        else
          config[13][10]=-1
          return "STOCK FULL"
        end

        config[13][10]=tonumber(data_cible[3])
        --pump not remove node ?
        minetest.remove_node(pos1)
        config[2][2]=config[2][2]-tonumber(data_cible[5])
      end
      sav_conf=true
    end
  end

  if sav_conf then
    return
  end

  config[13][10]=-1
  return "BAD COMMAND"
end

--************
--*** jump ***
--************
-- from spacejump to execute jump with my conditions
spacengine.jump = function(cpos, player,channel)
	local cont_met = minetest.get_meta(cpos)
  local cha_cnt=cont_met:get_string("channel")
  local plname=player:get_player_name()

  if channel~=cha_cnt then return false end --invalid channel

  if spacengine.area[channel].crew[plname]~=true then return false,"PLAYER NO CAPTAIN PRIV" end

  if spacengine.test_area_ship(cpos,0,channel)==false then return false end

  local config=spacengine.area[channel].config

  if config[4][6]>999 then return false,"WAIT ENGINE TOO HOT" end

  if cpos.y<1028 or cpos.y>10188 then return false,"OUT SPACE" end
  if cpos.x<-30500 or cpos.x>30500 then return false,"OUT SPACE" end
  if cpos.z<-30500 or cpos.z>30500 then return false,"OUT SPACE" end

  if config[1][2]>config[4][7] then return false,"WEIGHT OVERLOAD" end

  local conso,rmax,temperature,check=spacengine.conso_engine(cpos,config)

  if not check then return false,"! OUT of RANGE !" end --destination trop loin

  if config[2][2]-conso<0 then return false,"LOW BAT" end

  --recherche jumpdrive
  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))

  --SWITCH OFF all
  local list=minetest.find_nodes_in_area({x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez},{x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez},{"bloc4builder:keypad_on","bloc4builder:hub_on"})
  if list then
  local cha_spl=string.split(channel,":") 

  for i=1,#list do
    dst=minetest.get_node(list[i])
    if dst.name=="bloc4builder:hub_on" then
      minetest.set_node(list[i],"bloc4builder:hub")
    else
    dst_met=minetest.get_meta(list[i])
    local cha_dst=dst_met:get_string("channel")
          
    if cha_dst==cha_spl[1] then
        bloc4builder.switch_on(list[i],true,3,0)
    end
    end
  end
  end

  local jumpdrive_pos=minetest.find_nodes_in_area({x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez},{x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez},"jumpdrive:engine")

  if #jumpdrive_pos~=1 then return false,"JumpDrive Error" end

	local targetPos = {x=config[1][6][1],y=config[1][6][2],z=config[1][6][3]}

  if jumpdrive.check_mapgen(cpos) then
		return false, "Error: mapgen was active in this area, please try again later for your own safety!"
	end

	--local distance = vector.distance(cpos, targetPos)

	local radius_vector = {x=rangex, y=rangey, z=rangez}
	local source_pos1 = {x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez}
	local source_pos2 = {x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez}
	local target_pos1 = {x=targetPos.x-rangex,y=targetPos.y-rangey,z=targetPos.z-rangez}
	local target_pos2 = {x=targetPos.x+rangex,y=targetPos.y+rangey,z=targetPos.z+rangez}

  local x_overlap = (target_pos1.x <= source_pos2.x and target_pos1.x >= source_pos1.x) or
		(target_pos2.x <= source_pos2.x and target_pos2.x >= source_pos1.x)
	local y_overlap = (target_pos1.y <= source_pos2.y and target_pos1.y >= source_pos1.y) or
		(target_pos2.y <= source_pos2.y and target_pos2.y >= source_pos1.y)
	local z_overlap = (target_pos1.z <= source_pos2.z and target_pos1.z >= source_pos1.z) or
		(target_pos2.z <= source_pos2.z and target_pos2.z >= source_pos1.z)

	if x_overlap and y_overlap and z_overlap then
		return false, "Error: jump into itself! extend your jump target"
	end

	-- load chunk
	minetest.get_voxel_manip():read_from_map(target_pos1, target_pos2)

local blacklisted_pos_list = minetest.find_nodes_in_area(source_pos1, source_pos2, jumpdrive.blacklist)
	for _, nodepos in ipairs(blacklisted_pos_list) do
		return false, "Can't jump node @ " .. minetest.pos_to_string(nodepos)
	end

	local air_found=minetest.find_nodes_in_area(target_pos1, target_pos2, "air")

  local ignore_nb=minetest.find_nodes_in_area(target_pos1, target_pos2, "ignore")
  if #ignore_nb>1 then
    return false, "Warning: Jump-target is in uncharted area "..#ignore_nb
  end

	if jumpdrive.is_area_protected(source_pos1, source_pos2, plname) then
		return false, "Jump-source is protected!"
	end

	if jumpdrive.is_area_protected(target_pos1, target_pos2, plname) then
		return false, "Jump-target is protected!"
	end

	local is_empty, empty_msg = jumpdrive.is_area_empty(target_pos1, target_pos2)

	if not is_empty then
		return false,"Jump-target is obstructed " .. empty_msg
	end

  --en cas d'abordage par un autre player, faire disparaitre le résidu de passerelle
  list=minetest.find_nodes_in_area({x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez},{x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez},"bloc4builder:passerelle")
  if list then
    for i=1,#list do
      minetest.remove_node(list[i])
    end
  end

  --son au decollage
  minetest.sound_play("spacengine_jump_start", {
		pos = cpos,
		gain = 1.5,
    max_hear_distance = 80
	})

-- show animation in source
	minetest.add_particlespawner({
		amount = 200,
		time = 2,
		minpos = source_pos1,
		maxpos = source_pos2,
		minvel = {x = -2, y = -2, z = -2},
		maxvel = {x = 2, y = 2, z = 2},
		minacc = {x = -3, y = -3, z = -3},
		maxacc = {x = 3, y = 3, z = 3},
		minexptime = 0.1,
		maxexptime = 5,
		minsize = 1,
		maxsize = 1,
		texture = "spark.png",
		glow = 5,
	})

  --modif consommation, température
  config[2][2]=config[2][2]-conso
  config[4][6]=temperature+config[4][6]
  --arret manutention
  config[13][10]=-1
  --sauvegarde old pos controler
  config[1][5][1]=cpos.x
  config[1][5][2]=cpos.y
  config[1][5][3]=cpos.z

  config[12]="y"
  config[1][7]=math.random(50,1500)
  --sauvegarde data
  cont_met:set_string("pos_cont",minetest.pos_to_string(targetPos))

  --spacengine.test_area_ship(cpos,1,channel)

	--local t0 = minetest.get_us_time()

  --before jump change gravity to prevent falling
  fxadd(player,"jumpdrive",4,0,0,10)
  espace.vacuum=false
	-- actual move
	jumpdrive.move(source_pos1, source_pos2, target_pos1, target_pos2)

  --son a l'arriver
  minetest.sound_play("spacengine_jump_stop", {
		pos = targetPos,
		gain = 1,
    max_hear_distance = 50
	})

  --replace vacuum --> air (si saut dans un atelier ou hangar)
  local _,bloc=espace.secteur(targetPos)
  if bloc.nb==283 or bloc.nb==17 or #air_found>1 then
    worldedit.replace(target_pos1, target_pos2, "vacuum:vacuum", "air", false)
  end
  espace.vacuum=true

	-- show animation in target
	minetest.add_particlespawner({
		amount = 200,
		time = 2,
		minpos = target_pos1,
		maxpos = target_pos2,
		minvel = {x = -2, y = -2, z = -2},
		maxvel = {x = 2, y = 2, z = 2},
		minacc = {x = -3, y = -3, z = -3},
		maxacc = {x = 3, y = 3, z = 3},
		minexptime = 0.1,
		maxexptime = 5,
		minsize = 1,
		maxsize = 1,
		texture = "spark.png",
		glow = 5,
	})

--maj nouvelle position dans la liste
spacengine.maj_channel(targetPos,channel,0)

	--local t1 = minetest.get_us_time()
	--local time_micros = t1 - t0

	return true
end
