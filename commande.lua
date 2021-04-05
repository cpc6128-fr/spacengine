local function switch_analog(dst,value)
  local calcul=0
  if value<1 then
    dst=math.abs(value)
  else
    calcul=math.ceil(dst/(100/value))+1
    if calcul>value then calcul=0 end
    dst=math.floor(calcul*(100/value))
  end
  return dst
end

local function dec_index(src,vmax,dec)
  src=src-dec
  if src<0 then src=vmax end
  return src
end

local function inc_index(src,vmax,inc,inv)
  src=src+inc
  if src>vmax then
    if inv==true then
      src=-vmax
    else
      src=0
    end
  end

  return src
end

local function manutention_id(config,dx,dy,dz)
--xxxyyyzzz
local zone=math.floor((config[13][3]*config[4][4][4])/100)*2+1

local idz=(config[13][11] % 1000)-100
local idy=(math.floor(config[13][11]/1000) % 1000)-100
local idx=(math.floor(config[13][11]/1000000) % 1000)-100

if dx>0 then
  idx=idx+dx
elseif dy>0 then
  idy=idy+dy
elseif dz>0 then
  idz=idz+dz
end

if idx>zone then
  idx=1
end

if idz>zone then
  idz=1
end

if idy>zone then
  idy=1
end

config[13][11]=idz+100+((idy+100)*1000)+((idx+100)*1000000)

end
--** GIROPHARE **
spacengine.warning=function(cpos,config,value)
  --taille du vaisseaux
  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))
  local pos1={x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez}
  local pos2={x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez}
      
  if value>0 then
    local list=minetest.find_nodes_in_area(pos1,pos2,"bloc4builder:girophare")
    for i=1,#list do
      dst=minetest.get_node(list[i]) 
      minetest.swap_node(list[i],{name="bloc4builder:girophare_on",param2=dst.param2})
    end

  else
    local list=minetest.find_nodes_in_area(pos1,pos2,"bloc4builder:girophare_on")
    for i=1,#list do
      dst=minetest.get_node(list[i]) 
      minetest.swap_node(list[i],{name="bloc4builder:girophare",param2=dst.param2})
    end

  end
end

--********************
--*** PUNCH MODULE ***
--********************

--********************
--** choix commande **
--********************
spacengine.punch_module=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code,nod_met)
  local nb_param
  local switch
  local command

  if value>100 then
    nb_param=(value-100)*3
    switch=string.sub(spac_eng[4],nb_param-2,nb_param-2)
    command=string.sub(spac_eng[4],nb_param-1,nb_param-1)

  else
    nb_param=spac_eng[5]*3
    switch=string.sub(spac_eng[4],nb_param-2,nb_param-2)
    command=string.sub(spac_eng[4],nb_param-1,nb_param-1)
  end

  if config[1][1]==0 and group==12 then
    local timer=minetest.get_node_timer(cpos)
    timer:set(5,0)
    config[1][1]=1
    local t1=math.ceil((minetest.get_us_time()-config[14])/4500000)
    --refroidi engine si vaisseaux arreter depuis longtemps
    if config[4][6]>0 then
      config[4][6]=math.max(0,config[4][6]-(t1*config[4][5]))
    end
    --reload weapons
    if config[6][6]>0 then
      config[6][6]=math.max(0,config[6][6]-t1)
    end

    config[14]=minetest.get_us_time()+4500000
    config[12]="y"
    return spacengine.controler(cpos)
  end

  
  return spacengine[switch..command](cpos,cont_met,config,spac_eng,channel,group,puncher,value,code,nod_met)

end

--***************
--** switch BP **
--***************

--controler on/off

spacengine.bC=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  local timer=minetest.get_node_timer(cpos)
  if timer:is_started() then
    timer:stop()
    config[1][1]=0
    config[12]="y"
    return
  else
    timer:set(5,0)
    config[1][1]=1
    local t1=math.ceil((minetest.get_us_time()-config[14])/4500000)
    --refroidi engine si vaisseaux arreter depuis longtemps
    if config[4][6]>0 then
      config[4][6]=math.max(0,config[4][6]-(t1*config[4][5]))
    end
    --reload weapons
    if config[6][6]>0 then
      config[6][6]=math.max(0,config[6][6]-t1)
    end

    config[14]=minetest.get_us_time()+4500000

    config[12]="y"
    return
  end
end

--engine jump
spacengine.bJ=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  return "menu#1#+3-"
end

--acces menu
spacengine.bM=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  return "menu#1#-"
end

--power change src
spacengine.bP=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if type(config[3][4])=="table" then
    if config[3][1]<2 then config[3][1]=2 end
    config[3][1]=config[3][1]+1
    if config[3][1]>#config[3][4] then config[3][1]=2 end
  end
  config[12]="e"
  return
end

--weapons fire
spacengine.bF=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  local msg=spacengine.weapons(cpos,channel,cont_met,config,puncher)
  if msg then
    spacengine.central_msg(msg,config)
    spacengine.make_sound("notification",config[15])
  end
  config[12]="We"
  return
end

--radar cible
spacengine.br=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  local n=1
  if config[7][6]<1 then config[7][6]=1 end
  config[7][6]=config[7][6]+1
  if type(config[7][4])=="table" then
    n=#config[7][4]
  end
  if config[7][6]>n then config[7][6]=1 end
  config[12]="R"
  return
end

--radar scan
spacengine.bS=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  spacengine.radar(cpos,channel,cont_met,config)
  config[12]="R"
  return
end

--manutention source
spacengine.bs=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  local n=1
  if config[13][10]>-1 then return end
  config[13][6]=config[13][6]+1
  if type(config[13][5])=="table" then
    n=#config[13][5]
  end
  if config[13][6]>n then config[13][6]=1 end
  config[12]="M"
  return
end

--manutention command
spacengine.bc=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if config[13][10]>-1 then return end
  config[13][8]=config[13][8]+1
  if config[13][8]>3 then config[13][8]=1 end
  config[12]="M"
  return
end

--manutention execute /on off
spacengine.bE=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  
  if config[13][10]==0 then
    config[13][10]=-1
  else
    config[13][10]=config[13][10]*-1
  end
  
  config[12]="M"
  return
end

--on off src power
spacengine.bD=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if type(config[3][4])=="table" then
    id=config[3][1]
    if id<2 then id=2 end
    if config[3][5][id]<1 then
      config[3][5][id]=1
    else
      config[3][5][id]=0
    end
  end
  config[12]="e"

  spacengine.maj_channel(cpos,channel,0)
  return
end

--Gouvernail
spacengine.bG=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if config[13][10]>-1 then
    config[13][10]=-1
    spacengine.central_msg("STOP",config)
    spacengine.make_sound("notification",config[15])
  end

  local xrng=config[4][4][1]
  local zrng=config[4][4][3]

  config[4][4][1]=zrng
  config[4][4][3]=100-xrng
      
  config[12]="WRMcD"
  return
end

--force oxygene
spacengine.bf=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  config[11][4]=1
  spacengine.oxygene(cpos,config)
  config[12]="O"
  return
end

--manutention idx
spacengine.bg=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if config[13][10]>-1 then return end
  manutention_id(config,1,0,0)
  config[12]="M"
  return
end

--manutention idz
spacengine.bh=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if config[13][10]>-1 then return end
  manutention_id(config,0,0,1)
  config[12]="M"
  return
end
--manutention idy
spacengine.bp=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if config[13][10]>-1 then return end
  manutention_id(config,0,1,0)
  config[12]="M"
  return
end

--clear central message
spacengine.bi=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  local nb_msg=string.split(config[13][9],";")
  config[13][9]="0;".. nb_msg[1] ..";---"

  config[12]="mC"
  return
end

--QUICK jump
spacengine.bj=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  local _,rmax=spacengine.conso_engine(cpos,config,2)
  --local vl=tonumber(string.sub(spac_eng[4],12,12))+1
  local vl=0
  if config[4][8]~=nil then vl=config[4][8] end

  if vl==0 then
    config[1][6][1]=cpos.x
    config[1][6][2]=cpos.y
    config[1][6][3]=cpos.z+rmax
  end
  if vl==1 then
    config[1][6][1]=cpos.x+rmax
    config[1][6][2]=cpos.y
    config[1][6][3]=cpos.z
  end
  if vl==2 then
    config[1][6][1]=cpos.x
    config[1][6][2]=cpos.y
    config[1][6][3]=cpos.z-rmax
  end
  if vl==3 then
    config[1][6][1]=cpos.x-rmax
    config[1][6][2]=cpos.y
    config[1][6][3]=cpos.z
  end
  if vl==4 then
    config[1][6][1]=cpos.x
    config[1][6][2]=cpos.y+rmax
    config[1][6][3]=cpos.z
  end
  if vl==5 then
    config[1][6][1]=cpos.x
    config[1][6][2]=cpos.y-rmax
    config[1][6][3]=cpos.z
  end

  return "menu#1#+3-"
end

--quick jump direction
spacengine.bk=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  config[4][8]=inc_index(config[4][8],5,1)
  config[12]="E"
  return
end

--quick jump range
spacengine.bl=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  config[4][2]=inc_index(config[4][2],100,1)
  config[12]="E"
  return
end

--reglage fin
spacengine.bn=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  config[6][4]=inc_index(config[6][4],100,1)
  config[12]="W"
  return
end

--reglage special
spacengine.bm=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code,nod_met)
  local scr_opt=string.sub(spac_eng[1],1,1)
  --si present extention de commande
  if spac_eng[6] then
    local pg=spac_eng[5]*12
    local pmax=tonumber(string.sub(spac_eng[6],pg-7,pg-7))
    local pidx=tonumber(string.sub(spac_eng[6],pg-6,pg-6))

    --si shift enfoncer
    if code then
      pidx=pidx+1
      if pidx>pmax then pidx=1 end
      lng=#spac_eng[6]
      spac_eng[6]=string.sub(spac_eng[6],1,pg-7) .. pidx .. string.sub(spac_eng[6],pg-5,lng)
      nod_met:set_string("spacengine",spacengine.compact(spac_eng))

    else
  
      if pidx>1 then
        pidx=10^(pidx-1)
      end

      local inv=false

      local aa=string.sub(spac_eng[6],pg-11,pg-11)
      local b=tonumber(string.sub(spac_eng[6],pg-10,pg-9))
      local c=tonumber(string.sub(spac_eng[6],pg-8,pg-8))
      local vmax=tonumber(string.sub(spac_eng[6],pg-5,pg))

      if vmax<0 then
        vmax=math.abs(vmax)
        inv=true
      end

      local a=string.byte(aa)-96
      --si caractere d'echappement pas present
      if aa~=":" then
        --si option pour node
        if a<0 then
          a=string.byte(aa)-58

          if c>0 then
            spac_eng[a][b][c]=inc_index(spac_eng[a][b][c],vmax,pidx,inv)
          elseif b>0 then
            spac_eng[a][b]=inc_index(spac_eng[a][b],vmax,pidx,inv)
          else
            spac_eng[a]=inc_index(spac_eng[a],vmax,pidx,inv)
          end

          nod_met:set_string("spacengine",spacengine.compact(spac_eng))
        --option config
        else

          if c>0 then
            config[a][b][c]=inc_index(config[a][b][c],vmax,pidx,inv)
          elseif b>0 then
            config[a][b]=inc_index(config[a][b],vmax,pidx,inv)
          else
            config[a]=inc_index(config[a],vmax,pidx,inv)
          end

        end
      end
    end
    
  end
  
  config[12]=scr_opt
  return
end

--cheat mod
spacengine.bH=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  config[2][2]=config[2][1]
  config[5][4]=config[5][1]
  config[4][6]=0
  config[6][6]=0
  config[1][3]=0
  config[1][7]=5
  if atm.balance[puncher:get_player_name()]~= nil then
    atm.balance[puncher:get_player_name()] = 3000000
    atm.saveaccounts()
  end
  config[12]="e"
  return
end

--target mark
spacengine.bo=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  local pos1,zone,new_texture
  local xrng=-1+(0.02*config[4][4][1])
  local yrng=-1+(0.02*config[4][4][2])
  local zrng=-1+(0.02*config[4][4][3])


if spac_eng[5]==6 then
  local puissance=math.floor((config[13][1]*config[13][2])/100)
  zone=math.floor((config[13][3]*config[4][4][4])/100)
  xrng=math.ceil(xrng*puissance)
  yrng=math.ceil(yrng*puissance)
  zrng=math.ceil(zrng*puissance)
  
  pos1={x=cpos.x+xrng,y=cpos.y+yrng,z=cpos.z+zrng}
  new_texture="spacengine_sphere_manutention.png"

  elseif spac_eng[5]==7 then

  zone=math.ceil(config[7][3]*config[4][4][4]/100)
  xrng=math.ceil(xrng*config[7][3])
  yrng=math.ceil(yrng*config[7][3])
  zrng=math.ceil(zrng*config[7][3])
  pos1={x=cpos.x+xrng,y=cpos.y+yrng,z=cpos.z+zrng}
  new_texture="spacengine_sphere_radar.png"

  elseif spac_eng[5]==8 then
    zone=math.ceil(config[6][8]*config[4][4][4]*0.01)
    local range=math.floor(config[6][3]*config[6][4]*0.01)
    xrng=math.ceil(xrng*range)
    yrng=math.ceil(yrng*range)
    zrng=math.ceil(zrng*range)
    pos1={x=cpos.x+xrng,y=cpos.y+yrng,z=cpos.z+zrng}
    new_texture="spacengine_sphere_weapons.png"

  end

  if pos1.y<1008 or pos1.y>10207 then return end
  if pos1.x<-30500 or pos1.x>30500 then return end
  if pos1.z<-30500 or pos1.z>30500 then return end

  spacengine.mark_target({x=cpos.x+xrng-zone,y=cpos.y+yrng+zone,z=cpos.z+zrng-zone},new_texture)
  spacengine.mark_target({x=cpos.x+xrng-zone,y=cpos.y+yrng+zone,z=cpos.z+zrng+zone},new_texture)
  spacengine.mark_target({x=cpos.x+xrng+zone,y=cpos.y+yrng+zone,z=cpos.z+zrng-zone},new_texture)
  spacengine.mark_target({x=cpos.x+xrng+zone,y=cpos.y+yrng+zone,z=cpos.z+zrng+zone},new_texture)
  spacengine.mark_target({x=cpos.x+xrng-zone,y=cpos.y+yrng-zone,z=cpos.z+zrng-zone},new_texture)
  spacengine.mark_target({x=cpos.x+xrng-zone,y=cpos.y+yrng-zone,z=cpos.z+zrng+zone},new_texture)
  spacengine.mark_target({x=cpos.x+xrng+zone,y=cpos.y+yrng-zone,z=cpos.z+zrng-zone},new_texture)
  spacengine.mark_target({x=cpos.x+xrng+zone,y=cpos.y+yrng-zone,z=cpos.z+zrng+zone},new_texture)

  config[12]="e"
  return
end

--Call patrol
spacengine.bW=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  
  return "menu#1#+2-patrol"
end

--Chg msg
spacengine.bN=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  
  return "menu#1#+8-"
end

--on_switch
spacengine.bw=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code) 
  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))
  local pos1={x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez}
  local pos2={x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez}
  local spl_channel=string.split(channel,":")

  if not code then
    if string.find(spac_eng[6],"\n") then
      local tmp=string.split(spac_eng[6],"\n")
      code=tmp[spac_eng[5]]
    else
      code=spac_eng[6]
    end
  end

  if value>100 then
    local tmp=string.split(spac_eng[6],"\n")
    value=value-100
    code=tmp[value]
  end

  bloc4builder.change_switch(cpos,code,nil,6,{x=rangex,y=rangey,z=rangez})

  return
end
--******************
--** switch Inter **
--******************

--on off power
spacengine.iA=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  --code=cible

  if string.find(spac_eng[6],"\n") then
    local tmp=string.split(spac_eng[6],"\n")
    code=tmp[spac_eng[5]]
  else
    code=spac_eng[6]
  end

  if type(config[3][4])=="table" then
    for i=2,#config[3][4] do
      idx=config[3][4][i]
      if code==spacengine.upgrade[3][idx][3] then
        config[3][5][i]=value
      end
    end
  end

  config[12]="e"

  spacengine.maj_channel(cpos,channel,0)
  return
end

--active switch
spacengine.iB=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code) 
  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))
  local pos1={x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez}
  local pos2={x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez}
  local spl_channel=string.split(channel,":")

  if not code then
    if string.find(spac_eng[6],"\n") then
      local tmp=string.split(spac_eng[6],"\n")
      code=tmp[spac_eng[5]]
    else
      code=spac_eng[6]
    end
  end

  if value>0 then
    local list=minetest.find_nodes_in_area(pos1,pos2,"bloc4builder:keypad")
    for i=1,#list do
      dst=minetest.get_node(list[i]) 
      dst_met=minetest.get_meta(list[i])
      local cha_dst=dst_met:get_string("channel")
          
      if spl_channel[1]==cha_dst then
        if dst_met:get_string("code")==code then
          bloc4builder.switch_on(list[i],true,2,1)
        end
      end
    end

  else
    local list=minetest.find_nodes_in_area(pos1,pos2,"bloc4builder:keypad_on")
    for i=1,#list do
      dst=minetest.get_node(list[i]) 
      dst_met=minetest.get_meta(list[i])
      local cha_dst=dst_met:get_string("channel")
          
      if spl_channel[1]==cha_dst then
        if dst_met:get_string("code")==code then
          bloc4builder.switch_on(list[i],true,2,0)
        end
      end
    end

  end

  return
end

--light on/off
spacengine.iC=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))
  local pos1={x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez}
  local pos2={x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez}
      
  if value>0 then
    local list=minetest.find_nodes_in_area(pos1,pos2,"bloc4builder:light")
    for i=1,#list do
      dst=minetest.get_node(list[i]) 
      minetest.swap_node(list[i],{name="bloc4builder:light_on",param2=dst.param2})
    end

  else
    local list=minetest.find_nodes_in_area(pos1,pos2,"bloc4builder:light_on")
    for i=1,#list do
      dst=minetest.get_node(list[i]) 
      minetest.swap_node(list[i],{name="bloc4builder:light",param2=dst.param2})
    end

  end

  return
end

--manutention on off
spacengine.iD=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if value==1 then
    if config[13][10]<0 then
      config[13][10]=-config[13][10]
    end
  else
    if config[13][10]>0 then
      config[13][10]=-config[13][10]
    elseif config[13][10]==0 then
      config[13][10]=-1
    end
  end

  config[12]="M"
  return
end

--warning on off
spacengine.iE=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  spacengine.warning(cpos,config,value)

  return
end

-- atc on off
spacengine.iT=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if value>0 then
    config[15][5]=math.abs(config[15][5])
  else
    config[15][5]=-math.abs(config[15][5])
  end
  
  return
end

--on_switch
spacengine.iw=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code) 
  local rangex=tonumber(string.sub(config[1][4],2,3))
  local rangey=tonumber(string.sub(config[1][4],5,6))
  local rangez=tonumber(string.sub(config[1][4],8,9))
  local pos1={x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez}
  local pos2={x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez}

  if not code then
    if string.find(spac_eng[6],"\n") then
      local tmp=string.split(spac_eng[6],"\n")
      code=tmp[spac_eng[5]]
      value=string.sub(spac_eng[4],spac_eng[5]*3,spac_eng[5]*3)
    else
      code=spac_eng[6]
    end
  end

  bloc4builder.change_switch(cpos,code,nil,tonumber(value),{x=rangex,y=rangey,z=rangez})

  return
end
--*******************
--** switch Analog ** -- group=14 pour lecture switch
--*******************

--engine
spacengine.aA=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[4][2] end
  config[4][2]=switch_analog(config[4][2],value)
  config[12]="eD"
  return
end

--shield
spacengine.aB=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[5][2] end
  config[5][2]=switch_analog(config[5][2],value)
  config[12]="SCD"
  return
end

--weapons puissance
spacengine.aC=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[6][2] end
  config[6][2]=switch_analog(config[6][2],value)
  config[12]="WCD"
  return
end

--weapons range
spacengine.aD=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[6][4] end
  config[6][4]=switch_analog(config[6][4],value)
  config[12]="WD"
  return
end

--gravitation
spacengine.aF=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[8][2] end
  config[8][2]=switch_analog(config[8][2],value)
  config[12]="GD"
  return
end

--oxygene
spacengine.aG=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[11][2] end
  config[11][2]=switch_analog(config[11][2],value)
  config[12]="OD"
  return
end

--radar
spacengine.aE=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[7][2] end
  config[7][2]=switch_analog(config[7][2],value)
  config[12]="RD"
  return
end
--manutention
spacengine.aH=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[13][2] end
  if config[13][10]>-1 then return end
  config[13][2]=switch_analog(config[13][2],value)
  config[12]="M"
  return
end

--manutention
spacengine.aJ=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[13][4] end
  if config[13][10]>-1 then return end
  config[13][4]=switch_analog(config[13][4],value)
  config[12]="M"
  return
end

--xpos
spacengine.ax=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[4][4][1] end
  if config[13][10]>-1 then
  config[13][10]=-1
  spacengine.central_msg("STOP",config)
  spacengine.make_sound("notification",config[15])
  end
  config[4][4][1]=switch_analog(config[4][4][1],value)
  config[12]="WRMcDF"
  return
end

--ypos
spacengine.ay=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[4][4][2] end
  if config[13][10]>-1 then
    config[13][10]=-1
    spacengine.central_msg("STOP",config)
    spacengine.make_sound("notification",config[15])
  end
  config[4][4][2]=switch_analog(config[4][4][2],value)
  config[12]="WRMcDF"
  return
end

--zpos
spacengine.az=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[4][4][3] end
  if config[13][10]>-1 then
    config[13][10]=-1
    spacengine.central_msg("STOP",config)
    spacengine.make_sound("notification",config[15])
  end
  config[4][4][3]=switch_analog(config[4][4][3],value)
  config[12]="WRMcDF"
  return
end

--zone
spacengine.aI=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  if group==14 then return config[4][4][4] end
  if config[13][10]>-1 then
    config[13][10]=-1
    spacengine.central_msg("STOP",config)
    spacengine.make_sound("notification",config[15])
  end
  config[4][4][4]=switch_analog(config[4][4][4],value)
  config[12]="WRMcDF"
  return
end

--page down
spacengine.aa=function(cpos,cont_met,config,spac_eng,channel,group,puncher,value,code)
  config[12]="spmCE"
  return
end
