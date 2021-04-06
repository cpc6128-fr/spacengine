--***************************
--*** recherche controler ***
--***************************
spacengine.search_controler=function(pos,range)

  if range==nil then range="x15y15z15" end

  local rangex=tonumber(string.sub(range,2,3))
  local rangey=tonumber(string.sub(range,5,6))
  local rangez=tonumber(string.sub(range,8,9))

  local pos1={x=pos.x-rangex,y=pos.y-rangey,z=pos.z-rangez}
  local pos2={x=pos.x+rangex,y=pos.y+rangey,z=pos.z+rangez}

  local list=minetest.find_nodes_in_area(pos1,pos2,"spacengine:controler")
  local nb=#list
  local idx=0
  local cpos

  for i=1,nb do
    cpos=list[i]
    idx=idx+1
  end

  if idx==0 then --pas de controler
    return false
  elseif idx>1 then --plusieurs controler
    return false
  end

  local nod_met = minetest.get_meta(cpos)
  local channel=nod_met:get_string("channel")
  
  if string.find(channel,"No channel:") then return false end

  return true,cpos
end

--******************
--*** MaJ module ***
--******************
spacengine.maj_pos_node=function(pos,plname,new_channel,repar)

  --recuperation data node
  local node=minetest.get_node(pos)
  local group=minetest.get_item_group(node.name,"spacengine")
  local nod_met = minetest.get_meta(pos)
  local channel=nod_met:get_string("channel")
  local new_pos=minetest.string_to_pos(nod_met:get_string("pos_cont"))
  local cpos

  --si c'est le controler
  if group==1 then
    new_pos={x=pos.x,y=pos.y,z=pos.z}
    cpos={x=pos.x,y=pos.y,z=pos.z}
    --ancien channel non initialiser
    if string.find(channel,"No channel:") then
      if not spacengine.check_free_place(new_pos,plname,"x15y15z15v29791",{"espace:bedrock","espace:invisible_bedrock"}) then
        minetest.chat_send_player(plname,"Near BedRock !")
        return false
      end
    end

  else
    --sinon si autre module, verifie si channel controler valide
    if string.find(channel,"No channel:") then
      local found
      found,new_pos=spacengine.search_controler(pos,"x15y15z15v29791")

      if not found then
        minetest.chat_send_player(plname,"Controler Invalid")
        return false
      end

      cpos={x=new_pos.x,y=new_pos.y,z=new_pos.z}
      new_pos.x=pos.x-new_pos.x
      new_pos.y=pos.y-new_pos.y
      new_pos.z=pos.z-new_pos.z

    else
      cpos={x=pos.x-new_pos.x,y=pos.y-new_pos.y,z=pos.z-new_pos.z}
    end

    --verifie si toujours dans l'area du controler
    if not spacengine.test_area_ship(pos,0,channel) then
      --reset node
      nod_met:set_string("channel","No channel:noplayer")
      nod_met:set_string("pos_cont",minetest.pos_to_string({x=33333,y=0,z=0}))
      minetest.chat_send_player(plname,"node out of area")
      return false
    end

  end

  nod_met:set_string("channel",new_channel)
  nod_met:set_string("pos_cont",minetest.pos_to_string(new_pos))

  --MaJ area
  spacengine.test_area_ship(cpos,1,new_channel)

  spacengine.maj_channel(cpos,new_channel,repar)
  return true
end

--***************************
--*** Mise A Jour channel ***
--***************************

local function stockmax(src,calcul,smax)
if calcul+src>smax then
  src=smax-calcul
else
  calcul=calcul+src
end
return src,calcul
end

--
spacengine.maj_channel=function(cpos,channel,repar) --repar 0 normal 1 reset 2 reparation
  local controler=minetest.get_meta(cpos)

  local cont_spac=spacengine.decompact(controler:get_string("spacengine"))

  local rangex=tonumber(string.sub(cont_spac[4],2,3))
  local rangey=tonumber(string.sub(cont_spac[4],5,6))
  local rangez=tonumber(string.sub(cont_spac[4],8,9))

  --controler center
  local list=minetest.find_nodes_in_area({x=cpos.x-rangex,y=cpos.y-rangey,z=cpos.z-rangez},{x=cpos.x+rangex,y=cpos.y+rangey,z=cpos.z+rangez},"group:spacengine")
  local nb=#list

  if repar==1 then
    for i=1,nb do
      local dst=minetest.get_node(list[i])
      local dst_met=minetest.get_meta(list[i])
      local dst_group=minetest.get_item_group(dst.name,"spacengine")

      dst_met:set_string("channel",channel)

      --calcul position relative
      if dst_group==1 then
        dst_met:set_string("pos_cont",minetest.pos_to_string({x=cpos.x,y=cpos.y,z=cpos.z}))
      else
        dst_met:set_string("pos_cont",minetest.pos_to_string({x=33333,y=0,z=0}))
        dst_met:set_string("channel","No channel:noplayer")
      end
    end

    return
  end

  local config=spacengine.area[channel].config

  --reset compteur
  local idx4,idx5,idx6=0,0,0
  local idx7,idx8,idx11,idx13=0,0,0,0
  --controler
  config[1][2]=math.floor(((rangex*2+1)*(rangey*2+1)*(rangez*2+1))/10) --poids
  --config[1][3]=0 --damage
  local stock_pos={{33333,0,0}}
  local id_stock_pos=1
  --battery
  config[2][1]=0
  --power
  config[3][2]=0
  local cont1,cont2
  if type(config[3][4])=="table" then
    cont1=config[3][4]
    cont2=config[3][5]
    if cont2[1]==1 then --reset list
      cont1={0}
      cont2={0}
    end
  else
    cont1={0}
    cont2={0}
  end
  --engine
  local p_max=0
  local p_min=10000
  config[4][1]=0
  config[4][3]=0
  config[4][5]=0
  config[4][7]=0
if config[4][8]==nil then config[4][8]=0 end
  --shield
  config[5][1]=0
  config[5][3]=0
  --weapons
  config[6][1]=0
  config[6][3]=0
  config[6][5]=0
  config[6][8]=0
  --radar
  config[7][1]=0
  config[7][3]=0
  local cont7={"none:none"}
  local cont77={0}
  --gravitation
  config[8][1]=0
  --storage
  config[9][1]=0
  --passenger
  config[10][1]=0
  --oxygene
  config[11][1]=0
  config[11][3]=0
  --screen

  --manutention
  local cont11={"none:none:0:n:0"}
  config[13][7]=""
  config[13][1]=0
  config[13][3]=0
  config[13][12]=0
  if config[13][9]=="" then config[13][9]="0;***;***" end
  --radio
  local radio={}
  local idx_radio=0
  if config[15]==nil then
    config[15]={}
  end

  if repar==2 then config[1][3]=0 end

  for i=1,nb do
    local dst=minetest.get_node(list[i])
    local dst_met=minetest.get_meta(list[i])
    local dst_group=minetest.get_item_group(dst.name,"spacengine")

    dst_met:set_string("channel",channel)

    --if dst_channel==channel then --ifchannel ok
      local sauvegarde=false
      local dst_group=minetest.get_item_group(dst.name,"spacengine")
      local dst_space=spacengine.decompact(dst_met:get_string("spacengine"))

      if dst_group~=20 then --20=module switch
        config[1][2]=config[1][2]+dst_space[2] --weight
      end

    --controler
    if dst_group==1 then
      config[1][4]=dst_space[4] --volume
      --config[1][7]=dst_space[5] --stock

    --battery
    elseif dst_group==2 then
      config[2][1]=config[2][1]+dst_space[4]

    --power      
    elseif dst_group==3 then
      id_stock_pos=id_stock_pos+1
      stock_pos[id_stock_pos]={list[i].x-cpos.x,list[i].y-cpos.y,list[i].z-cpos.z}
      local err=false
      for j=1,#cont1 do
        if dst_space[1]==cont1[j] then --present ?
          dst_space[8]=cont2[j]
          err=true
        end
      end

      if err==false then
        local j=#cont1+1 
        cont1[j]=dst_space[1]
        cont2[j]=dst_space[8] --on/off
      end

      config[3][2]=config[3][2]+dst_space[10]
      sauvegarde=true

    --engine
    elseif dst_group==4 then
      idx4=idx4+1
      p_max=math.max(p_max,dst_space[4])
      p_min=math.min(p_min,dst_space[4])
      config[4][1]=config[4][1]+dst_space[4]
      config[4][3]=math.max(config[4][3],dst_space[5])
      config[4][5]=config[4][5]+dst_space[6]
      config[4][7]=config[4][7]+dst_space[7]
    
    --shield
    elseif dst_group==5 then
      idx5=idx5+1
      config[5][1]=config[5][1]+dst_space[4]
      config[5][3]=config[5][3]+dst_space[5]

    --weapons
    elseif dst_group==6 then
      idx6=idx6+1
      config[6][1]=math.max(10000,config[6][1]+dst_space[4])
      config[6][3]=math.max(100,config[6][3]+dst_space[5])
      config[6][5]=config[6][5]+dst_space[6]
      config[6][8]=config[6][8]+dst_space[7]

    --radar
    elseif dst_group==7 then
      idx7=idx7+1
      config[7][1]=config[7][1]+dst_space[4]
      config[7][3]=config[7][3]+dst_space[5]
      local err=false
      if type(dst_space[6])=="table" then

        for chk=1,#dst_space[6] do
          err=false
          for j=1,#cont7 do
            if dst_space[6][chk]==cont7[j] then --present ?
            err=true
            end
          end
          if err==false then
            local j=#cont7+1 
            cont7[j]=dst_space[6][chk]
            cont77[j]=0
          end
        end

      else
        for j=1,#cont7 do
          if dst_space[6]==cont7[j] then --present ?
            err=true
          end
        end
        if err==false then
          local j=#cont7+1 
          cont7[j]=dst_space[6]
          cont77[j]=0
        end
      end

    --gravitation
    elseif dst_group==8 then
      idx8=idx8+1
      config[8][1]=config[8][1]+dst_space[4]

    --storage
    elseif dst_group==9 then
      config[9][1]=config[9][1]+dst_space[4]

    --passenger
    elseif dst_group==10 then
      config[10][1]=config[10][1]+1

    --oxygene
    elseif dst_group==11 then
      idx11=idx11+1
      config[11][1]=config[11][1]+dst_space[4]
      config[11][3]=config[11][3]+dst_space[5]

    --screen
    elseif dst_group==12 then
      id_stock_pos=id_stock_pos+1
      stock_pos[id_stock_pos]={list[i].x-cpos.x,list[i].y-cpos.y,list[i].z-cpos.z}

    --manutention
    elseif dst_group==13 then
      idx13=idx13+1
      config[13][1]=config[13][1]+dst_space[4]
      config[13][3]=config[13][3]+dst_space[5]
      config[13][12]=config[13][12]+dst_space[7]

      local err=false
      if type(dst_space[6])=="table" then

        for chk=1,#dst_space[6] do
          err=false
          for j=1,#cont11 do
            if dst_space[6][chk]==cont11[j] then --present ?
            err=true
            end
          end
          if err==false then
            local j=#cont11+1 
            cont11[j]=dst_space[6][chk]
          end
        end

      else
        for j=1,#cont11 do
          if dst_space[6]==cont11[j] then --present ?
            err=true
          end
        end
        if err==false then
          local j=#cont11+1 
          cont11[j]=dst_space[6]
        end
      end

      if string.find(config[13][7],string.sub(dst_space[1],1,1)) then --present ?
      else
        config[13][7]=config[13][7] .. string.sub(dst_space[1],1,1)
      end

    --radio
    elseif dst_group==17 then
      radio=list[i]
      idx_radio=idx_radio+1
    end

    local prelativ
    --calcul position relative
    if dst_group~=1 then
      if repar==1 then
        prelativ={x=33333,y=0,z=0}
      else
        prelativ={x=list[i].x-cpos.x,y=list[i].y-cpos.y,z=list[i].z-cpos.z}
      end
    else
      prelativ={x=cpos.x,y=cpos.y,z=cpos.z}
    end

    dst_met:set_string("pos_cont",minetest.pos_to_string(prelativ))
    
    if sauvegarde then --sauvegarde nouvelle donnée du module
      dst_met:set_string("spacengine",spacengine.compact(dst_space))
    end

  --end --ifchannel

  end --for

  config[1][3]=math.ceil(config[1][3]/nb) --damage

    if config[2][2]>config[2][1] then config[2][2]=config[2][1] end --limitation battery

    if idx4>1 then --engine
      config[4][1]=math.ceil(config[4][1]/idx4)+((p_max-p_min)/2)+idx4
      --config[4][3]=math.ceil(config[4][3]/idx4)
      config[4][5]=math.floor(config[4][5]/idx4)
    end

    --shield
    if config[5][1]<1 then
      config[5][1]=math.max(0.1,config[5][1])
    else
      config[5][1]=math.min(10000,config[5][1])
    end

    if config[5][4]>config[5][1] then config[5][4]=config[5][1] end

    if repar>1 then
      config[5][4]=config[5][1]
    end

    if idx5>1 then --shield
      config[5][3]=math.ceil(config[5][3]/idx5)
      --config[5][1]=math.min(150,math.floor((config[5][1]/idx5)+(idx5*5)))
    end

    if idx6>1 then --weapons
      config[6][1]=math.min(10000,math.floor(config[6][1]/idx6))
      config[6][3]=math.min(100,math.floor(config[6][3]/idx6))
      config[6][5]=math.max(0,math.floor(config[6][5]/idx6))
      config[6][8]=math.floor(config[6][8]/idx6)
    end

    if idx7>1 then --radar
      config[7][1]=math.floor(config[7][1]/idx7)+(idx7*2)
      config[7][3]=math.min(120,math.floor(config[7][3]/idx7)+idx7)
    end

    --gravitation
    if idx8>1 then
      config[8][1]=math.ceil(config[8][1]/idx8)
    end

    config[8][1]=math.min(999,config[8][1])+(idx8*1000)

    --oxygene
    if idx11>1 then
      config[11][1]=math.min(100,math.floor(config[11][1]/idx11))
      config[11][3]=math.floor(config[11][3]/idx11)
    end

    config[11][3]=math.min(9999,config[11][3])+(idx11*10000)

    --manutention
    if idx13>1 then
      config[13][1]=math.floor(config[13][1]/idx13)
      config[13][3]=math.floor(config[13][3]/idx13)
      config[13][12]=math.ceil(config[13][12]/idx13)
    end

    --
    --lecture mission
    local tmp=spacengine.area[channel].mission
    if tmp~="" then
      local mission=string.split(tmp,"/")
      for idx_m=1,#mission do
        local destination=string.split(mission[idx_m],":")
        local idx=tonumber(destination[2])
        if destination[1]=="3" then
          local j=#cont11+1 
          cont11[j]=commerce.dig_node[idx][2]..destination[2]..destination[7]
        elseif string.sub(mission[idx_m],1,1)=="4" then
          local j=#cont11+1 
          cont11[j]=commerce.build_node[idx][2]..destination[2]..destination[7]
        elseif string.sub(mission[idx_m],1,1)=="5" then
          local j=#cont7+1 
          cont7[j]=commerce.spy_type[idx][2]..":none:R"..destination[2]..destination[7]
          cont77[j]=0
        end
      end
    end
    --]]

    config[3][4]=cont1
    config[3][5]=cont2
    config[6][7]=idx6
    config[7][4]=cont7
    config[7][5]=cont77
    config[13][5]=cont11

    if config[13][7]=="" then config[13][7]="n" end

    local calcul=0
    config[9][3][7],calcul=stockmax(config[9][3][7],calcul,config[9][1])
    config[9][3][6],calcul=stockmax(config[9][3][6],calcul,config[9][1])
    config[9][3][5],calcul=stockmax(config[9][3][5],calcul,config[9][1])
    config[9][3][4],calcul=stockmax(config[9][3][4],calcul,config[9][1])
    config[9][3][3],calcul=stockmax(config[9][3][3],calcul,config[9][1])
    config[9][3][2],calcul=stockmax(config[9][3][2],calcul,config[9][1])
    config[9][3][1],calcul=stockmax(config[9][3][1],calcul,config[9][1])
    config[1][2]=config[1][2]+calcul
    config[9][2]=calcul

    calcul=0
    config[10][3][1],calcul=stockmax(config[10][3][1],calcul,config[10][1])
    config[10][3][2],calcul=stockmax(config[10][3][2],calcul,config[10][1])
    config[10][3][3],calcul=stockmax(config[10][3][3],calcul,config[10][1])
    config[10][3][4],calcul=stockmax(config[10][3][4],calcul,config[10][1])
    config[10][3][5],calcul=stockmax(config[10][3][5],calcul,config[10][1])
    config[1][2]=config[1][2]+calcul
    config[10][2]=calcul

    if idx_radio==1 then
      config[15][1]=radio.x
      config[15][2]=radio.y
      config[15][3]=radio.z
      config[15][4]="0000"
    else
      config[15][1]=33333
      config[15][2]=0
      config[15][3]=0
      config[15][4]="0000"

    end

    if id_stock_pos>1 then
      controler:set_string("stock_pos",spacengine.compact(stock_pos))
    else
      controler:set_string("stock_pos","")
    end

    spacengine.test_area_ship(cpos,1,channel)
end
