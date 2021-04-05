spacengine.chg_form={}
--[[
liste option
group#option#
\< clic droit param
\> clic gauche
ù tech4bp

+ submenu (* captain privilege) (** only captain) (-other player)
+1 upgrade module *
+2 reparation vaisseaux *
+3 jumpdrive *
+4 sell/chg crew **
+5 achat vaisseaux -
+6 transaction
+7 accept achat
+8 new msg (screen)

& desactivation menu ugrade
* parametrage module / acces config
~ paramettrage screen
--]]

--****************
--*** FORMSPEC ***
--****************
spacengine.formspec_update=function(pos,player,value)

  --recuperation data node
  local node=minetest.get_node(pos)
  local nod_met = minetest.get_meta(pos)
  local vente=nod_met:get_string("vente")

  if vente==nil then vente="" end

  local plname=player:get_player_name()

  if spacengine.chg_form[plname]==nil then spacengine.chg_form[plname]={} end

  --** revente du vaisseaux a d'autre player **
  if vente~="" and spacengine.chg_form[plname].check==1 then
      spacengine.chg_form[plname].vente=tonumber(vente)
      spacengine.chg_form[plname].option="+5"
      spacengine.chg_form[plname].position={x=pos.x,y=pos.y,z=pos.z}
      return minetest.show_formspec(plname, "spacengine" , "size[6,4]button_exit[0,0;2,1;accept;accept]button_exit[0,1;2,1;cancel;cancel]label[2,2.5;Sell Price ".. vente .."]field[1,3.5;5,1;newname;New name;]")
  end

  if spacengine.chg_form[plname].check<2 then return end --si pas membre d'equipage

  local option=spacengine.chg_form[plname].option
  --channel : owner
  local channel=nod_met:get_string("channel")
  local spac_eng=spacengine.decompact(nod_met:get_string("spacengine"))
  local cpos=minetest.string_to_pos(nod_met:get_string("pos_cont"))
  --group
  local group=minetest.get_item_group(node.name,"spacengine")
  local err=false --si fichier config absent

  --recuperation position relative ou reel du controler
  local cont_met
  local config

  --controler invalide ou position
  if string.find(channel,"No channel:") or cpos.x==33333 then
    err=true
  else
    --position relative du controler
    if group~=1 then
      cpos.x=pos.x-cpos.x
      cpos.y=pos.y-cpos.y
      cpos.z=pos.z-cpos.z
    end

    cont_met=minetest.get_meta(cpos)

    config=spacengine.area[channel].config

  end

  local is_sneak = player and player:get_player_control().aux1 or false

  --** clic droit param **
  if string.find(option,"<") then

    if string.find(channel,"No channel:") or cpos.x==33333 then return false end

    if config[1][1]==0 then return false end

    spac_eng[5]=spac_eng[5]+1

    if spac_eng[5]>math.floor(string.len(spac_eng[4])/3) then spac_eng[5]=1 end

    nod_met:set_string("spacengine",spacengine.compact(spac_eng))
    config[12]=string.sub(spac_eng[1],1,1)
    minetest.sound_play("spacengine_key", {to_player = plname})
    return spacengine.controler(cpos,true) --maj screen
  end

  --** BP Tech4 **
  if string.find(option,"ù") then
    if string.find(channel,"No channel:") or cpos.x==33333 then return false end

    minetest.sound_play("spacengine_key", {to_player = plname})

    option=spacengine.punch_module(cpos,cont_met,config,spac_eng,channel,group,player,value,is_sneak,nod_met)

    if config[12]~="n" then spacengine.controler(cpos,true) end --maj screen

    if option==nil then return end

     --menu confirmation
    if string.find(option,"menu") then
      spacengine.chg_form[plname].option=option
    else
      return
    end
  end

  --** clic gauche value **
  if string.find(option,">") then

    if string.find(channel,"No channel:") or cpos.x==33333 then return false end

    local nb_param=spac_eng[5]
    if nb_param>math.floor(string.len(spac_eng[4])/3) then
      spac_eng[5]=1
      nb_param=1
    end

    local switch=string.sub(spac_eng[4],nb_param*3-2,nb_param*3-2)
    local vl=string.byte(spac_eng[4],nb_param*3)-48
    local lng=#spac_eng[4]

    --** BP **
    if switch=="b" then
      if value==nil then value=1 end

      minetest.sound_play("spacengine_key", {to_player = plname})

      option=spacengine.punch_module(cpos,cont_met,config,spac_eng,channel,group,player,value,is_sneak,nod_met)

    --** INTERUPTEUR **
    elseif switch=="i" then
      local code

      if value==nil then
        if group==12 then

          if string.sub(spac_eng[1],1,1)=="A" then
            config[12]=config[12].."A"
          end

        end

        --incremente valeur de l'inter
        value=vl+1
        if value>1 then value=0 end
        spac_eng[4]=string.sub(spac_eng[4],1,nb_param*3-1) ..value.. string.sub(spac_eng[4],nb_param*3+1,lng)
        nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      end
      

      minetest.sound_play("inter", {to_player = plname})

      spacengine.punch_module(cpos,cont_met,config,spac_eng,channel,group,player,value,code)

    --** ANALOGIQUE **
    elseif switch=="a" then

      if value==nil then
        value=6
        --incremente valeur du curseur
        vl=vl+1
        if vl>5 then vl=0 end
        spac_eng[4]=string.sub(spac_eng[4],1,nb_param*3-1) ..vl.. string.sub(spac_eng[4],nb_param*3+1,lng)
        nod_met:set_string("spacengine",spacengine.compact(spac_eng))
      end

      minetest.sound_play("analog", {to_player = plname})

      spacengine.punch_module(cpos,cont_met,config,spac_eng,channel,group,player,value)

    end

    if config[12]~="n" then spacengine.controler(cpos,true) end --maj screen

    if option==nil then return end

     --menu confirmation
    if string.find(option,"menu") then
      spacengine.chg_form[plname].option=option
    else
      return
    end

  end

  local formspec

  --***********************
  --**POPuP confirmation **
  --***********************
  if string.find(option,"+") then
    local form_spl=string.split(option,"#")

    --upgrade module
    if string.find(option,"+1") and spacengine.chg_form[plname].check>2 then
      formspec="size[5,3]button_exit[0,0;2,1;accept;accept]button_exit[0,1;2,1;cancel;cancel]label[2.5,0;module "..spacengine.upgrade[group][spacengine.chg_form[plname].idx][3].."]label[2.5,1;Price : "..spacengine.upgrade[group][spacengine.chg_form[plname].idx][2].."]"

    --reparation
    elseif string.find(option,"+2") and spacengine.chg_form[plname].check>2 then
      local calcul=math.ceil(config[1][3]*config[1][3]*tonumber(string.sub(config[1][4],8,11))*0.0002)+(config[5][1]-config[5][4])
      if string.find(option,"patrol") then
        formspec="size[5,3]button_exit[0,0;2,1;accept;accept]button_exit[0,1;2,1;cancel;cancel]label[1,2;Call protection patrol]label[1,2.5;Price : ".. (calcul*100) .."]"
      else
        formspec="size[5,3]button_exit[0,0;2,1;accept;accept]button_exit[0,1;2,1;cancel;cancel]label[1,2;reparation du vaisseaux]label[1,2.5;Price : ".. calcul .."]"
      end

      spacengine.chg_form[plname].damage=config[1][3]
      spacengine.chg_form[plname].volume=tonumber(string.sub(config[1][4],11,15))

    --jumpdrive
    elseif string.find(option,"+3") and spacengine.chg_form[plname].check>2 then

      formspec="size[5,3]button_exit[0,0;2,1;accept;accept]button_exit[0,1;2,1;cancel;cancel]label[2.5,0;! JUMPDRIVE !]label[2.5,1;Start FLY ?]"

    --sell to another player/chg crew
    elseif string.find(option,"+4") and spacengine.chg_form[plname].check==4 and spacengine.area[channel] then
      formspec="size[9,6]button_exit[0,0;2,1;accept;accept]button_exit[0,1;2,1;cancel;cancel]label[5,1.75;Crew list]textlist[5,2.5;4,2.3;crew3;"
      local crew_list="Captain "..spacengine.area[channel].captain
      for crew, v in pairs (spacengine.area[channel].crew) do
        crew_list=crew_list..","..crew
        if v==true then crew_list=crew_list.." *" end
      end
      formspec=formspec..crew_list..";".. spacengine.chg_form[plname].idx ..";]"
      spacengine.chg_form[plname].crew=crew_list
      spacengine.chg_form[plname].vente=vente

      formspec=formspec.."field[0.1,2.5;5,1;data1;Sell Price ;".. vente .."]field[0.1,3.5;5,1;crew1;Remove crew ;]field[0.1,4.5;5,1;crew2;Insert crew ;]field[0.1,5.5;5,1;crew3;Privilege crew ;]"

    --transaction accept ?
    elseif string.find(option,"+6") then
      formspec="size[6,4]button_exit[0,0;2,1;accept;accept]button_exit[0,1;2,1;cancel;cancel]"

    --accept achat nouveau vaisseaux
    elseif string.find(option,"+7") then
      formspec="size[5,3]button_exit[0,0;2,1;accept;accept]button_exit[0,1;2,1;cancel;cancel]label[2.5,0;Spaceship "..spacengine.vaisseaux[tonumber(spacengine.chg_form[plname].idx)][5].."]label[2.5,1;Price : "..spacengine.vaisseaux[tonumber(spacengine.chg_form[plname].idx)][4].."]"

    --New msg
    elseif string.find(option,"+8") then
      local nb_msg=string.split(config[13][9],";")
      formspec="size[6,4]button_exit[4,3;2,1;accept;accept]button_exit[0,3;2,1;cancel;cancel]textarea[0.5,0.5;5.5,3;data1;New message;".. nb_msg[2] .."]"
    end

  else
  --** gui module **
  local module={"controler", "battery", "power", "engine", "shield", "weapons", "radar", "gforce", "storage", "passenger", "oxygene", "screen", "manutention","switch","analog","coordo","radio","info","info"}

  local scr_opt=""
  formspec="size[10,10]"

  --if espace ?
  local secteur,bloc=espace.secteur(pos)
  local commerce="n"
  bloc.nb=bloc.nb+1

  --proximiter d'un commerce
  if  secteur_dat[bloc.nb]==1 or
      secteur_dat[bloc.nb]==7 or
      secteur_dat[bloc.nb]==4 or 
      secteur_dat[bloc.nb]==9 then commerce="y"
  end

  --option screen
  if group==12 and string.find(option,"&")==nil then
    scr_opt=string.sub(spac_eng[1],1,1)
    formspec=formspec.."image_button[0,9.4;1,1;spacengine_screen_icone.png;screen;]"
    commerce="s"
  end

  --nom du module
  local tmp=nod_met:get_string("infotext")
  if tmp=="" then tmp="screen" end

  --only controler change channel
  local spl_cha=string.split(channel,":")
  if group==1 and spacengine.chg_form[plname].check==4 then
    formspec=formspec.."field[0.25,0;3,1;channel;;".. spl_cha[1] .."]"
  else
    formspec=formspec.."label[0.25,0;".. spl_cha[1] .."]"
  end

  --menu indication commune a chaque machine
  formspec=formspec.."button_exit[0,7.5;2,1.25;maj;* update *\nspaceship]button_exit[0,8.5;2,1;exit;exit]" ..
    "label[0,0.5;".. tmp .."]"..
    "label[0,1.5;Damage : ".. spac_eng[3].."]"..
    "label[0,2;Famille : "..module[group].."]label[0,2.5;Upgrade : ".. string.sub(spac_eng[1],1,1) .."]"..
    "label[0,3;weight : ".. spac_eng[2].."]"..
    "list[current_player;main;1,9.4;8,1;]"

  if spacengine.area[channel] then
    formspec=formspec.. "label[0,1;Captain : ".. spacengine.area[channel].captain .."]"
  end

  --menu upgrade seulement si outils parametrage
  if (string.find(option,"~") or string.find(option,"*")) then

    if commerce=="y" then
      formspec=formspec.."image_button[9.15,9.4;1,1;spacengine_repar.png;repar;]"
    end

    if commerce=="s" or commerce=="y" then
      local split_up=spacengine.upgrade[group]
      formspec=formspec.."background[4,0;6,6;spacengine_"..module[group]..".png]"

      --upgrade activer ?
      if string.find(option,"&")==nil then
        formspec=formspec.."textlist[3.5,6.25;5.8,1.3;upgrade;"
        for i=1,#split_up do
          if group~=3 then
            local j=string.sub(split_up[i][1],2)
            if string.find(spac_eng[1],j) then
              formspec=formspec.."ok : "
            else
              formspec=formspec.."--- : "
            end
          else
            if spac_eng[1]==i then
              formspec=formspec.."ok : "
            else
              formspec=formspec.."--- : "
            end
          end
          formspec=formspec..split_up[i][2].." Mg : "..split_up[i][3]
          if i<#split_up then formspec=formspec.."," end
        end
        formspec=formspec..";".. spacengine.chg_form[plname].idx ..";]textarea[3.75,7.75;6.1,1.75;descript;;".. split_up[tonumber(spacengine.chg_form[plname].idx)][5] .."]"
      end
    end

  else

    if scr_opt=="" then
      formspec=formspec.."background[4,0;6,6;spacengine_"..module[group]..".png]"
    else
      local nb_screen=string.find("CBPESWRGspOmMADc_iF",scr_opt)
      formspec=formspec.."background[4,0;6,6;spacengine_"..module[nb_screen]..".png]" --background screen
    end
  end

  --pas de menu specifique quand choix changement screen
  if string.find(option,"~") then err=true end

  --menu specifique--

  --*** controler ***
  if group==1 or scr_opt=="C" then

    if err==false then
      --bouton vente et crew only for captain
      if scr_opt~="C" and spacengine.chg_form[plname].check==4 then
        formspec=formspec.."image_button[2,8;1,1;spacengine_sell.png;vente;]"
      end

      --book
      if scr_opt~="C" then
        formspec=formspec.."background[1,6.5;1,1;spacengine_book.png]list[nodemeta:".. cpos.x..','..cpos.y..','..cpos.z ..";book;1,6.5;1,1]image_button[2,6.5;1,1;spacengine_read.png;read;]image_button[0,6.5;1,1;spacengine_write.png;write;]"
      end

      local cnt_spl=spacengine.decompact(cont_met:get_string("spacengine"))
      local tmp1=cnt_spl[5]/6
      formspec=formspec.."label[0,3.5;Volume : ".. string.sub(config[1][4],11,15) .." Bloc]list[nodemeta:".. cpos.x..','..cpos.y..','..cpos.z ..";stock;4,1;6,".. tmp1 .."]"

    end

  --*** battery ***
  elseif group==2 or scr_opt=="B" then

    if scr_opt~="B" then
      formspec=formspec.."label[0,3.5;Capacitance : ".. spac_eng[4].."]"
    end

    if err==false then
      formspec=formspec.."label[4,0.25;Charge : ".. config[2][2]..
      " / ".. config[2][1] .."]"
    end

  --*** power ***
  elseif group==3 or scr_opt=="P" then

    if scr_opt~="P" then
      local src=spac_eng[5]
      local dst=spac_eng[6]
      formspec=formspec.."label[0,3.5;Power : "..spac_eng[4].."]label[0,4;Speed : ".. spac_eng[7].."]image[6.5,2;1,1;spacengine_arrow.png]label[3.5,1.5;Power instant. module : ".. spac_eng[10].."]label[3.5,2;Timer : ".. spac_eng[9].."]"
      if src=="solar" then
        formspec=formspec.."image[5.5,2;1,1;spacengine_solar.png]"
      elseif src=="battery" then
        formspec=formspec.."item_image_button[5.5,2;1,1;spacengine:battery;dst;]"
      elseif src=="water" then
        formspec=formspec.."image[5.5,2;1,1;spacengine_water.png]"
      elseif string.find(src,"group:") then
        formspec=formspec.."label[5.5,2;".. src .."]"
      else
          formspec=formspec.."item_image_button[5.5,2;1,1;".. src ..";src;]"
      end

      if dst~="battery" then
        formspec=formspec.."item_image_button[7.5,2;1,1;".. dst ..";dst;]"
      else
        formspec=formspec.."item_image_button[7.5,2;1,1;spacengine:battery;dst;]"
      end
    end

    if err==false then
      local tmp1
      if config[2][1]==0 then
        tmp1=0
      else
        tmp1=math.floor((config[2][2]/config[2][1])*100)
      end
      formspec=formspec.."textlist[3.5,4;5.75,2;power#".. minetest.pos_to_string(cpos) ..";"
      local phr="refresh list"
      local length=#config[3][4]
      if type(config[3][4])=="table" then
      for i=1,length do
        local idx=config[3][4][i]

        if config[3][4][i]>0 then
          phr=spacengine.upgrade[3][idx][3]
        end
        --for j=1,length do
          --if string.sub(spacengine.upgrade[3][j][1],2,2)==config[3][4][i] then
            --phr=spacengine.upgrade[3][idx][3]
           -- break
          --end
        --end
        if config[3][5][i]==0 then
          formspec=formspec..phr.." : OFF"
        else
          formspec=formspec..phr.." : ON"
        end
        if i<length then formspec=formspec.."," end
      end
      else
        formspec=formspec.."Refresh list"
      end
      formspec=formspec..";1;]label[3.5,3;Power Moy. : ".. config[3][3].."]label[3.5,2.5;Bat. level ".. tmp1 .." %]"
      
    end

  --*** engine ***
  elseif group==4 or scr_opt=="E" then

    if scr_opt~="E" then
      formspec=formspec.. "label[0,3.5;Teslas : ".. spac_eng[4] .."]label[0,4;Range : ".. spac_eng[5] .."]label[0,4.5;Cooler : ".. spac_eng[6] .."]label[0,5;Charge max: ".. spac_eng[7] .."]"
    end

    if err==false then
      local rmax=spacengine.conso_engine(cpos,config,1)
      local secteur,bloc=espace.secteur(cpos)
      formspec=formspec.."field[7.25,1;3,1;data3;bloc;"..bloc.nb+1 .."]field[4.25,1;3,1;data2;secteur;".. secteur.nb+1 .."]"..
      "label[4,4;Xmin".. cpos.x-rmax .."]label[6,4;X".. cpos.x .."]label[8,4;Xmax".. cpos.x+rmax .."]label[4,5;Ymin".. cpos.y-rmax .."]label[6,5;Y"..cpos.y.."]label[8,5;Ymax".. cpos.y+rmax .."]label[4,6;Zmin".. cpos.z-rmax .."]label[6,6;Z"..cpos.z.."]label[8,6;Zmax".. cpos.z+rmax .."]"
    end

  --**************
  --*** shield ***
  --**************
  elseif group==5 or scr_opt=="S" then
    if scr_opt~="S" then
      formspec=formspec.."label[0,3.5;Protection : ".. spac_eng[4].."]"
    end

    if err==false then
      formspec=formspec.."label[4,1.5;Regeneration : "..config[5][3].."]label[4,2;Shield : "..config[5][4].."]label[4,2.5;Protect total : "..config[5][1].."]"
    end

  --***************
  --*** weapons ***
  --***************
  elseif group==6 or scr_opt=="W" then
    if scr_opt~="W" then
      formspec=formspec.."label[0,3.5;Power : "..spac_eng[4].."]label[0,4;Range : "..spac_eng[5].."]label[0,4.5;Speed : "..spac_eng[6].."]"
    end
    if err==false then
      --formspec=formspec.."field[4.3,1.75;2,1;data1;Puissance;".. config[6][2] .."]field[4.3,3;2,1;data2;Range;".. config[6][4] .."]field[6.5,1.75;3,1;data3;COORDO;".. config[4][4][1] .." ".. config[4][4][2] .." ".. config[4][4][3] .." ".. config[4][4][4] .."]"
      --if config[6][6]==0 then
      --  formspec=formspec.."button_exit[6.5,4.15;3,1;jump;WEAPONS FIRE]"
      --else
      --  formspec=formspec.."label[6.5,4.15;>WAIT<]" 
      --end
    end

  --*************
  --*** radar ***
  --*************
  elseif group==7 or scr_opt=="R" then
    if scr_opt~="R" then
      formspec=formspec.."label[0,3.5;Range : ".. spac_eng[5].."]"
    end  

  --*******************
  --*** gravitation ***
  --*******************
  elseif group==8 or scr_opt=="G" then
    if scr_opt~="G" then
      formspec=formspec.."label[0,3.5;G : ".. spac_eng[4].."]"
    end

  --***************
  --*** oxygene ***
  --***************
  elseif group==11 or scr_opt=="O" then
    if scr_opt~="O" then
      formspec=formspec.."label[0,3.5;Stack AIR : ".. spac_eng[4].."]label[0,4;Speed : ".. spac_eng[5].."]"
    end

  --************
  --*** info ***
  --************
  elseif group==12 and string.find(option,"info") then
    if value==nil then value="0 0 0 0 0 0 - 0" end
    local val_spl=string.split(value," ")
    local sect=tonumber(val_spl[8])+1
    formspec=formspec.."field[4.3,2.75;3,1;data4;Value;0]button[4.3,3.75;1,1;ok;OK]label[4.3,4.75;Sector : "..sect.." Matrice : "..val_spl[1].." "..val_spl[2].." "..val_spl[3].."]label[4.3,5.75;Astroport : "..val_spl[4].." "..val_spl[5].." "..val_spl[6].."]label[4.3,6.75;Planete : "..val_spl[7].."]"

  --****************
  --** LED SCROLL **
  --****************
  elseif group==12 and string.find(option,"led") then

    if spac_eng[6] then
      formspec=formspec.."field[4.3,2.75;3,1;data1;Value;".. spac_eng[6] .."]"
    end

  end

end
  
  spacengine.chg_form[plname].position={x=pos.x,y=pos.y,z=pos.z}
  return minetest.show_formspec(plname, "spacengine" , formspec)
end
