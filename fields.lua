--*** spacengine 202007 by CPC6128

--**function local**

local function write_book(cpos,nod_met,plname)
	local inv = nod_met:get_inventory()

	if inv:contains_item("stock", {name="default:book", count=1}) then
		local stack = inv:remove_item("stock", {name="default:book", count=1})

		local new_stack = ItemStack("default:book_written")

		local data = {}

		data.owner = plname
		data.title = "SPACENGINE coordinates"
		data.description = "SPACENGINE"
		data.text = minetest.serialize(cpos)
		data.page = 1
		data.page_max = 1

		new_stack:get_meta():from_table({ fields = data })

		if inv:room_for_item("book", new_stack) then
			-- put written book back
			inv:add_item("book", new_stack)
		else
			-- put back old stack
			inv:add_item("stock", stack)
		end

	end

end

local function read_book(nod_met,channel)
	local inv = nod_met:get_inventory()
	local player_name = nod_met:get_string("owner")

	if inv:contains_item("book", {name="default:book_written", count=1}) then
		local stack = inv:remove_item("book", {name="default:book_written", count=1})
		local stackMeta = stack:get_meta()

		local text = stackMeta:get_string("text")
		local data = minetest.deserialize(text)

		if data == nil then
			-- put book back, it may contain other information
			inv:add_item("book", stack)
			-- alert player
			if nil ~= player_name then
				minetest.chat_send_player(player_name, "Invalid data")
			end
			return
		end

		local x = tonumber(data.x)
		local y = tonumber(data.y)
		local z = tonumber(data.z)

		if x == nil or y == nil or z == nil then
			-- put book back, it may contain other information
			inv:add_item("book", stack)
			-- alert player
			if nil ~= player_name then
				minetest.chat_send_player(player_name, "Invalid coordinates")
			end
			return
		end

    spacengine.area[channel].config[1][6][1]=data.x
    spacengine.area[channel].config[1][6][2]=data.y
    spacengine.area[channel].config[1][6][3]=data.z

		-- put book back
		inv:add_item("book", stack)
    spacengine.save_area()
    minetest.chat_send_player(player_name, "New Coordinate OK")
	end
end

local function refresh_screen(cpos,scr_value,channel)
  local cont_met = minetest.get_meta(cpos)

  if channel~=cont_met:get_string("channel") then return end

  if spacengine.area[channel]==nil then return false end

  spacengine.area[channel].config[12]=scr_value

  local pos_cont=minetest.string_to_pos(cont_met:get_string("pos_cont"))
  local channel=cont_met:get_string("channel")

  if pos_cont.x>31000 then return end

  local config=spacengine.area[channel].config
  local new_pos

  --position power et screen
  local id_stock_pos=0
  local stock_pos=spacengine.decompact(cont_met:get_string("stock_pos"))

  if stock_pos then id_stock_pos=#stock_pos end

  if id_stock_pos>1 then
    
    for idx=2,id_stock_pos do
      new_pos={x=stock_pos[idx][1]+cpos.x,y=stock_pos[idx][2]+cpos.y,z=stock_pos[idx][3]+cpos.z}
      dst=minetest.get_node(new_pos) 
      nod_met=minetest.get_meta(new_pos)
      local cha_dst=nod_met:get_string("channel")

      if cha_dst==channel then --ifchannel ok
        local dst_group=minetest.get_item_group(dst.name,"spacengine")

        if dst_group==12 then
          if config[12]~="n" then
            spacengine.screen_display(new_pos,nod_met,cpos,cont_met,config)
          end
        end

      end
    end
  end
  config[12]="n"
end

--***************************

--***************************

local function accept_upgrade(cpos,nod_met,spac_eng,group,idx2)
  --TODO si controler, check_free place avec nouvelle donne dimension

    --si remplacement de l'upgrade
    if string.sub(spacengine.upgrade[group][idx2][1],1,1)=="1" then

      if group==1 then
        local data=spacengine.decompact(spacengine.upgrade[group][idx2][4])
        if spacengine.check_free_place(cpos, "", data[4], {"espace:bedrock", "espace:invisible_bedrock"})~=true then return false end
      end

      if group==3 then
        spac_eng[1]=idx2
      else
        local upg=string.sub(spac_eng[1],2)
        spac_eng[1]=string.sub(spacengine.upgrade[group][idx2][1],2)..upg
      end

      if group~=12 then --screen stockage texte
        nod_met:set_string("infotext",spacengine.upgrade[group][idx2][3])--name
      end

    else --ou rajout d'une option
      if group==3 then
        spac_eng[1]=idx2
      else
        if string.find(spac_eng[1],string.sub(spacengine.upgrade[group][idx2][1],2))==nil then
          spac_eng[1]=spac_eng[1].. string.sub(spacengine.upgrade[group][idx2][1],2)
        end
      end
    end

    local upgrad_spl={}
    --group POWER
    if group==3 then
      upgrad_spl=spacengine.decompact(spacengine.upgrade[group][idx2][4])

      for u=1,#spac_eng do
        if upgrad_spl[u]~="*" then --si "*" ne remplace pas
          if type(upgrad_spl[u])=="number" then --number
            spac_eng[u]=upgrad_spl[u]
          else
            local tmp=string.sub(upgrad_spl[u],1,1)
            if tmp==">" then --option add si >
              spac_eng[u]=spac_eng[u]+tonumber(string.sub(upgrad_spl[u],2))
            elseif tmp=="<" then --option dec si <
              spac_eng[u]=spac_eng[u]-tonumber(string.sub(upgrad_spl[u],2))
            elseif tmp=="$" then --option creation et add table
              local id=#spac_eng[u]
              local out=0
              local name_dst=string.sub(upgrad_spl[u],2)
              if type(spac_eng[u])=="table" then
                local id=#spac_eng[u]
                for chk=1,id do
                  if spac_eng[u][chk]==name_dst then out=1 end
                end
                  
                if out==0 then
                  id=id+1
                  spac_eng[u][id]=name_dst
                end

              else
                local new_dat={spac_eng[u],name_dst}
                spac_eng[u]=new_dat
              end

            else
              spac_eng[u]=upgrad_spl[u]
            end
          end
        end
      end

    --Autre group
    else

      for i=1,#spacengine.upgrade[group] do
        local j=string.sub(spacengine.upgrade[group][i][1],2) --recupere numero d'option
        if string.find(spac_eng[1],j) and spacengine.upgrade[group][i][4]~="" then
          upgrad_spl=spacengine.decompact(spacengine.upgrade[group][i][4])
            
          for u=1,#upgrad_spl do
            if upgrad_spl[u]~="*" then --si "*" ne remplace pas
              if type(upgrad_spl[u])=="number" then --number
                spac_eng[u]=upgrad_spl[u]
              else
                local tmp=string.sub(upgrad_spl[u],1,1)
                if tmp==">" then --option add si >
                  spac_eng[u]=spac_eng[u]+tonumber(string.sub(upgrad_spl[u],2))

                elseif tmp=="<" then --option dec si <
                  spac_eng[u]=spac_eng[u]-tonumber(string.sub(upgrad_spl[u],2))

                elseif tmp=="$" then --option creation et add table
                  local out=0
                  local name_dst=string.sub(upgrad_spl[u],2)
                  if type(spac_eng[u])=="table" then
                    local id=#spac_eng[u]
                    for chk=1,id do
                      if spac_eng[u][chk]==name_dst then out=1 end
                    end
                  
                    if out==0 then
                      id=id+1
                      spac_eng[u][id]=name_dst
                    end

                  else
                    if spac_eng[u]~=name_dst then
                      local new_dat={spac_eng[u],name_dst}
                      spac_eng[u]=new_dat
                    end
                  end

                else
                  spac_eng[u]=upgrad_spl[u]
                end
              end
            end
          end

        end
      end
    end
      
    local inv = nod_met:get_inventory()
    if group==1 and spac_eng[2]~=inv:get_size("stock") then
      inv:set_size("stock",spac_eng[2])
    end
    nod_met:set_string("spacengine",spacengine.compact(spac_eng))

  return true
end

--***************************
--old_channel:old_player player=new_player new_channel
local chg_shipname=function(pos,player,old_channel,new_channel,nod_met)
  local err=false
  local vaisseaux=player:get_attribute("vaisseaux")
  local new_name=player:get_player_name()

  if vaisseaux==nil then vaisseaux="" end

  local spl_cha=string.split(old_channel,":")

  --old name = No channel --> add name
  if string.find(old_channel,"No channel:") then     
    --add new vaisseaux
    player:set_attribute("vaisseaux",vaisseaux .. new_channel ..":")
  else

    --remove vaisseaux du vendeur
    if spl_cha[2]==new_name then
      vaisseaux=string.gsub(vaisseaux,spl_cha[1]..":","")
    else

      if spl_cha[2]~="ship_dealer" then
      local player2=minetest.get_player_by_name(spl_cha[2])
      local vaisseaux2=player2:get_attribute("vaisseaux")
      if vaisseaux2==nil then vaisseaux2="" end
      vaisseaux2=string.gsub(vaisseaux2,spl_cha[1]..":","")
      player2:set_attribute("vaisseaux",vaisseaux2)
      end
    end
    --remove oldship
    spacengine.test_area_ship(pos,-1,old_channel)
    
    --No channel
    if new_channel=="No channel" then
      player:set_attribute("vaisseaux",vaisseaux)
      err=true
    else

      --add vaisseaux acheteur
      player:set_attribute("vaisseaux",vaisseaux .. new_channel ..":")
    end
  end

  nod_met:set_string("channel",new_channel ..":".. new_name)
  nod_met:set_string("captain",new_name)
  --creation ou maj channel
  if err==false then
    spacengine.test_area_ship(pos,1,new_channel ..":".. new_name,new_name)
  end

  return
end

--##########################################################################

--************
--*** MENU ***
--************
minetest.register_on_player_receive_fields(function(player, formname, fields)

  if string.find(formname,"spacengine")==nil then return end
--minetest.log(dump(fields))
  local value=nil
  local new_form=false
  local famille
  local plname=player:get_player_name()

  --recupere coordo du node, channel et group
  local nod_pos=spacengine.chg_form[plname].position
  local nod_met = minetest.get_meta(nod_pos)
  local channel=nod_met:get_string("channel")
  
  local node=minetest.get_node(nod_pos)
  local group=minetest.get_item_group(node.name,"spacengine")

  local cpos=minetest.string_to_pos(nod_met:get_string("pos_cont"))
  local spac_eng=spacengine.decompact(nod_met:get_string("spacengine"))

  --recupere coordo controler
  if group~=1 then
    if cpos.x~=33333 then
      cpos={x=nod_pos.x-cpos.x, y=nod_pos.y-cpos.y, z=nod_pos.z-cpos.z}
    end
  end

  --** nettoyage fields.channel **
  if fields.channel then
    if fields.channel=="" then fields.channel="No channel" end
    local word1=string.match(fields.channel, "([%a%s%d_]+)")
    fields.channel=word1
  end

  --**********************
  --** list menu accept **
  --**********************
  if fields.accept then
    --upgrade module
    if string.find(spacengine.chg_form[plname].option,"+1") then
      local price=spacengine.upgrade[group][spacengine.chg_form[plname].idx][2]

      if accept_upgrade(cpos,nod_met,spac_eng,group,spacengine.chg_form[plname].idx) then

        if spacengine.transaction(spacengine.area[channel].captain,nil,price) then

          spacengine.maj_pos_node(nod_pos,plname,channel,0)
        end
      end

      if string.find(spacengine.chg_form[plname].option,"~") then
        spacengine.chg_form[plname].option="-"
      end

      if group==12 and cpos.x~=33333 then --screen modifie l'affichage
        refresh_screen(cpos,"y",channel)      
      end

    --reparation
    elseif string.find(spacengine.chg_form[plname].option,"+2") then
      local price=math.ceil(spacengine.chg_form[plname].damage^2 * spacengine.chg_form[plname].volume *0.0002)+ (spacengine.area[channel].config[5][1] - spacengine.area[channel].config[5][4])

      if string.find(spacengine.chg_form[plname].option,"patrol") then
        price=price*100
      end

      if spacengine.transaction(spacengine.area[channel].captain,nil,price) then
        spacengine.maj_pos_node(nod_pos,plname,channel,1)
      end

    --jumpdrive
    elseif string.find(spacengine.chg_form[plname].option,"+3") then
      local jump,msg=spacengine.jump(cpos,player,channel)
      if msg then
        spacengine.central_msg(msg,spacengine.area[channel].config)
        spacengine.make_sound("notification",spacengine.area[channel].config[15])
      end

    --sell
    elseif string.find(spacengine.chg_form[plname].option,"+4") then

      if fields.data1=="" then
        nod_met:set_string("vente","")
      else
        nod_met:set_string("vente",fields.data1) -- ! vente en cour
      end

      --remove crew
      if fields.crew1~="" then
        if spacengine.area[channel].crew[fields.crew1]~=nil then
          if fields.crew1~=spacengine.area[channel].captain then
            spacengine.area[channel].crew[fields.crew1]=nil
            spacengine.save_area()
          end
        end
      end

      --add crew
      if fields.crew2~="" then
        if spacengine.area[channel].crew[fields.crew2]==nil then
          spacengine.area[channel].crew[fields.crew2]=false
          spacengine.save_area()
        end
      end

      if fields.crew3~="" then
        if spacengine.area[channel].crew[fields.crew3]~=nil then
          if spacengine.area[channel].crew[fields.crew3]==false then
            spacengine.area[channel].crew[fields.crew3]=true
          else
            spacengine.area[channel].crew[fields.crew3]=false
          end
          spacengine.save_area()
        end
      end
      return

    --buy by other player
    elseif string.find(spacengine.chg_form[plname].option,"+5") then
      local cha_spl=string.split(channel,":")

      if fields.newname=="" then
        --error
        fields.newname="new_ship"
      end

      local vaisseaux=player:get_attribute("vaisseaux")
      if vaisseaux==nil then vaisseaux="" end

      if string.find(vaisseaux,fields.newname) then err=true end

      if err==false then
        if spacengine.transaction(player,nil,spacengine.chg_form[plname].vente) then
          --arret du controler
          local timer=minetest.get_node_timer(nod_pos)

          if timer:is_started() then timer:stop() end

          chg_shipname(nod_pos,player,channel,fields.newname,nod_met)
          spacengine.sell_ship(cpos,fields.newname ..":"..plname,plname)
        end
      end

      spacengine.chg_form[plname]=nil
      return

    --accept new spaceship
    elseif string.find(spacengine.chg_form[plname].option,"+7") then
      local choice=tonumber(form_spl[3])

      local tmp=7+tonumber(string.sub(spacengine.vaisseaux[choice][2],5,6))*2
      local newpos={x=cpos.x,y=cpos.y+tmp,z=cpos.z}

      --if check_protect_sell(cpos,player,spacengine.vaisseaux[choice])==false then return end
      if spacengine.check_free_place(newpos,plname,spacengine.vaisseaux[choice])~=true then return end

      if spacengine.transaction(player,nil,spacengine.vaisseaux[choice][4]) then
        minetest.remove_node(cpos)
        spacengine.place_ship(newpos, plname, cha_spl[1]..":"..plname, spacengine.vaisseaux[choice])
        spacengine.test_area_ship(newpos,1,cha_spl[1]..":"..plname,plname)
--maj
      end

    elseif string.find(spacengine.chg_form[plname].option,"+8") then

      if fields.data1=="" then fields.data1="***" end

      spacengine.central_msg(fields.data1,spacengine.area[channel].config,true)

    end

  end

  --** changement gui pour selection option screen **
  if fields.screen then
    spacengine.chg_form[plname].option="~"
    return spacengine.formspec_update(nod_pos, player)
  end

  --** MaJ en quittant **
  if fields.key_enter_field then
    if fields.key_enter_field=="channel" then
      fields.maj=""
    end
  end

  if fields.maj then

    if group==1 then

      --change channel name
      if string.find(channel,fields.channel) then
        -- si ancien channel existe
        if not string.find(channel,"No channel:") then
          spacengine.maj_pos_node(nod_pos,plname,channel,0)
        end
      else

        local vaisseaux=player:get_attribute("vaisseaux")
        if vaisseaux==nil then vaisseaux="" end

        if not string.find(vaisseaux,fields.channel) then

          if fields.channel~="No channel" and spacengine.check_free_place(nod_pos,plname,spac_eng[4],{"espace:bedrock", "espace:invisible_bedrock"})~=true then return end
          --arret du controler
          local timer=minetest.get_node_timer(nod_pos)

          if timer:is_started() then timer:stop() end

          chg_shipname(nod_pos,player,channel,fields.channel,nod_met)
          spacengine.maj_pos_node(nod_pos,plname,fields.channel..":"..plname,0)
        end
      end

      return
    else
      spacengine.maj_pos_node(nod_pos,plname,channel,0)
      return
    end
  end
 
  --** achat nouveau vaisseaux **
  if fields.achat then
    if string.find(fields.achat,"DCL:") then
      fields.achat=string.gsub(fields.achat,"DCL:","")
      --ligne choisi
      spacengine.chg_form[plname].idx=tonumber(fields.achat)
      spacengine.chg_form[plname].option="+7"

      return spacengine.formspec_update(nod_pos,player)
    end
  end

  --** reparation **
  if fields.repar then
    spacengine.chg_form[plname].option="+2"
    return spacengine.formspec_update(nod_pos, player)
  end

  --** vente **
  if fields.vente then
    spacengine.chg_form[plname].option="+4"
    return spacengine.formspec_update(nod_pos,player)
  end

  --** commerce **
  if fields.commerce then
    spacengine.chg_form[plname].option="+6"
    return spacengine.formspec_update(nod_pos,player)
  end

  --** installation Upgrade **
  if fields.upgrade then
    if string.find(fields.upgrade,"DCL:") then
    --ligne choisi
    fields.upgrade=string.gsub(fields.upgrade,"DCL:","")
    spacengine.chg_form[plname].idx=tonumber(fields.upgrade)
    spacengine.chg_form[plname].option="+1"

    return spacengine.formspec_update(nod_pos,player)
    end
  end

  --** bouton JUMP **
  if fields.jump then
    local scr_opt=tostring(group)
    if group==12 then
      scr_opt=string.sub(spac_eng[1],1,1) --option screen
    end
    
    if scr_opt=="E" or scr_opt=="4" then
      spacengine.chg_form[plname].option="+3"
      return spacengine.formspec_update(nod_pos,player)

    --weapons fire
    elseif scr_opt=="W" or scr_opt=="6" then
      spacengine.weapons(cpos,channel,cont_met,spacengine.area[channel].config)
    end

  end

  if fields.ok then
    local scr_opt=tostring(group)

    if fields.data4 then
      local x,y,z

      local dat_spl = string.split(fields.data4," ")
      if dat_spl[1] then
        local found,_,result=dat_spl[1]:find("(%d+)")
        if found then x=result end
      end
      if dat_spl[2] then
        local found,_,result=dat_spl[2]:find("(%d+)")
        if found then y=result end
      end
      if dat_spl[3] then
        local found,_,result=dat_spl[3]:find("(%d+)")
        if found then z=result end
      end

      if x and y and z then
        local secteur=espace.secteur_by_matrice({x=x,y=y,z=z})
        local _,astroport,stargate,jail,planete=espace.info_secteur(secteur.nb)
        value=secteur.x .." ".. secteur.y .." ".. secteur.z .." ".. astroport.x .." ".. astroport.y .." ".. astroport.z .." ".. planete.name .." ".. secteur.nb
        new_form=true
      elseif x then
        local secteur,astroport,stargate,jail,planete=espace.info_secteur(x-1)
        value=secteur.x .." ".. secteur.y .." ".. secteur.z .." ".. astroport.x .." ".. astroport.y .." ".. astroport.z .." ".. planete.name .." ".. secteur.nb
        spacengine.area[channel].config[1][6][1]=astroport.x
        spacengine.area[channel].config[1][6][2]=astroport.y
        spacengine.area[channel].config[1][6][3]=astroport.z-80
        new_form=true
      end

    end
  end

  if fields.write then
    write_book(cpos,nod_met,plname)
  end

  if fields.read then
    read_book(nod_met,channel)
  end

  --KEY ENTER
  if fields.key_enter_field then
    --** DATA1 **
    if fields.key_enter_field=="data1" then
      local scr_opt=tostring(group)
      if group==12 then
        scr_opt=string.sub(spac_eng[1],1,1) --option screen
      end

      local found, _, reglage = fields.data1:find("(%d+)")
      if found then
        local config=spacengine.area[channel].config

      if scr_opt=="S" or scr_opt=="5" then
        config[5][2]=math.min(100,reglage)
      elseif scr_opt=="E" or scr_opt=="4" then
        config[4][2]=math.min(100,reglage)
      elseif scr_opt=="W" or scr_opt=="6" then
        config[6][2]=math.min(100,reglage)
      elseif scr_opt=="R" or scr_opt=="7" then
        config[7][3]=math.min(100,reglage)
      elseif scr_opt=="G" or scr_opt=="8" then
        config[8][2]=math.min(100,reglage)
      elseif scr_opt=="O" or scr_opt=="11" then
        config[11][2]=math.min(100,reglage)
      elseif scr_opt=="18" then
        --secteur-->matrice
      end
      end

      if scr_opt=="m" then
        if fields.data1~="i" then fields.data1="m" end
        spac_eng[6]=fields.data1
        nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      end

    --DATA2
    elseif fields.key_enter_field=="data2" then
      local scr_opt=tostring(group)
      if group==12 then
        scr_opt=string.sub(spac_eng[1],1,1) --option screen
      end
      local found, _, reglage = fields.data2:find("(%d+)")

      if found then
        local config=spacengine.area[channel].config

      if scr_opt=="W" or scr_opt=="6" then
        config[6][4]=math.min(100,reglage)
      elseif scr_opt=="E" or scr_opt=="4" then
        --secteur
        local _,astroport=espace.info_secteur(reglage-1)
        config[1][6][1]=astroport.x
        config[1][6][2]=astroport.y
        config[1][6][3]=astroport.z-80
        refresh_screen(cpos,"E",channel)
      end
      end

    --DATA3
    elseif fields.key_enter_field=="data3" then
      local scr_opt=tostring(group)
      if group==12 then
        scr_opt=string.sub(spac_eng[1],1,1) --option screen
      end
      local found2, _, reglage2 = fields.data2:find("(%d+)")
      local found3, _, reglage3 = fields.data3:find("(%d+)")

      if found2 and found3 then
      
      if scr_opt=="E" or scr_opt=="4" then
        local config=spacengine.area[channel].config
        --bloc
        local secteur=espace.info_secteur(reglage2-1,reglage3-1)
        config[1][6][1]=secteur.x
        config[1][6][2]=secteur.y
        config[1][6][3]=secteur.z
        refresh_screen(cpos,"E",channel)
      end
      end
    --COORDO
    elseif fields.key_enter_field=="pos_dst" then
      local found, _, x, y, z = fields.pos_dst:find("^(-?%d+)[, ](-?%d+)[, ](-?%d+)$")
      if found then
        local config=spacengine.area[channel].config
        local puissance=math.ceil(config[4][1]*(config[4][2]/100))
        local _,rmax=spacengine.conso_engine(cpos,config)

        local tmp1=math.min(cpos.x+rmax,x)
        tmp1=math.max(cpos.x-rmax+1,tmp1)
        config[1][6][1]=tmp1
        tmp1=math.min(cpos.y+rmax,y)
        tmp1=math.max(cpos.y-rmax,tmp1)
        config[1][6][2]=tmp1
        tmp1=math.min(cpos.z+rmax,z)
        tmp1=math.max(cpos.z-rmax,tmp1)
        config[1][6][3]=tmp1
        refresh_screen(cpos,"E",channel)
      end

    end

  end

  local field_name,field_dat="-","-"
  for k, v in pairs(fields) do
    if string.find(k,"upgrade") then
    field_name = tostring(k)
    field_dat = v
    end

  if string.find(k,"power") then
    field_name = tostring(k)
    field_dat = v
    end
  end

  if string.find(field_name,"upgrade") then
    local field_spl=string.split(field_dat,":")
    spacengine.chg_form[plname].idx=tonumber(field_spl[2])
    new_form=true
  end

  if string.find(field_name,"power") then
    local field_spl=string.split(field_dat,":")
    if string.find(field_spl[1],"DCL") then
      local tmp=string.split(field_name,"#")
      local tmp1=tonumber(field_spl[2])
      local config=spacengine.area[channel].config
      if config[3][5][tmp1]<1 then
        config[3][5][tmp1]=1
      else
        config[3][5][tmp1]=0
      end
      
      spacengine.maj_pos_node(nod_pos,plname,channel,0)

      end
      new_form=true
    end
 -- end

if new_form then
  return spacengine.formspec_update(nod_pos,player,value)
end

end)
