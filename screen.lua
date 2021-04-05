--position display +00000
local function p_dis(p,nz)
if nz==nil then nz=5 end
local a=""
if p<0 then
a="-"..string.sub(tostring(math.abs(p)+10^nz),2)
else
a="+"..string.sub(tostring(p+10^nz),2)
end
return a
end

--battery display 888%
local function battery(config)
  local b1
  local b2="k"
  if config[2][1]==0 then --% battery
    b1=0
  else
    b1=math.ceil(((config[2][2])/config[2][1])*100)
  end
  if b1>74 then --couleur pile
    b2="f"
  elseif b1<26 then
    b2="h"
  end

  return "(1(".. b2 ..string.char(math.floor(b1/25)+112) ..")(q".. string.sub(tostring(b1+1000),2) .."%"
end

--chargement display 888%
local function chargement(config)
  local poid1=config[1][2]
  local poid2=config[4][7]
  local poid=""
if poid1<poid2 then
          if poid2==0 then
            poid1=0
          else
            poid1=math.ceil((poid1/poid2)*100)
          end
          poid=poid.."(l(2`)"..string.sub(tostring(poid1+1000),2).."%"
        else
          poid=poid.."(h(2`)OVER"
        end
  return poid
end

--
local function energy_total(config)
  local u_t=config[2][2]
  local unit=" U"

  if u_t>99999 then
    u_t=math.floor(u_t/1000)
    unit="KU"
  end
  return "(q(1*)"..string.sub(tostring(math.floor(u_t)+100000),2)..unit
end

---- barre graphe horizontal **
local function vumetre(value,value_max,color)
  local coef=100/value_max
  local case=math.min(10,math.floor((value*coef)/10))
  local barre=""
  if case>8 then
    if color then
      barre="(h"..string.char(72+case)
    else
      barre=string.char(72+case)
    end
    case=8
  else
    if color then
      barre="(hP"..barre
    else
      barre="P"..barre
    end
  end

  if case>6 then
    if color then
      barre="(k"..string.char(74+case)..barre
    else
      barre=string.char(74+case)..barre
    end
    case=6
  else
    if color then
      barre="(kP"..barre
    else
      barre="P"..barre
    end
  end

  if case>4 then
    if color then
      barre="(k"..string.char(76+case)..barre
    else
      barre=string.char(76+case)..barre
    end
    case=4
  else
    if color then
      barre="(kP"..barre
    else
      barre="P"..barre
    end
  end

  if case>2 then
    barre=string.char(78+case)..barre
    case=2
  else
    barre="P"..barre
  end
  if case>0 then
    barre=string.char(80+case)..barre
  else
    barre="P"..barre
  end

  if color then
    barre="(f"..barre
  else
    if value<(value_max*0.25) then
      barre="(h"..barre
    elseif value<(value_max*0.5) then
      barre="(K"..barre
    else
      barre="(f"..barre
    end
  end

  return barre
end

--radar mobs or player
local function radar_entity(id,search)
  local phr_entity=""
  if search[1]=="player" then
    phr_entity=phr_entity .."ALL PLAYER"
  elseif search[1]=="mobs" then
    if search[2]=="group" then
      phr_entity=phr_entity .. string.sub(search[3],1,16)
    else
      phr_entity=phr_entity .."ALL MOBS"
    end
  else
    phr_entity=phr_entity .. string.sub(search[2],1,16)
  end
  return phr_entity
end

local function screen_exit(npos,nod_met,phr)
  if phr=="" then return end
  nod_met:set_string("text",phr)
  monitor.update_sign(npos,nil,nil,nil)
end
--**********************
--*** screen display ***
--**********************
spacengine.screen_display=function(npos,nod_met,cpos,cont_met,config)
  local channel_a=nod_met:get_string("channel")

  local pos_cont=minetest.string_to_pos(nod_met:get_string("pos_cont"))
  local split=string.split(channel_a,":")
  local owner=split[2]
  local channel=split[1]

  if string.find(channel,"No channel:") or pos_cont.x>31000 then
    nod_met:set_string("text","ERROR")
    monitor.update_sign(npos,nil,nil,nil)
    return false
  end

  local nod_space=spacengine.decompact(nod_met:get_string("spacengine"))
  local scr_opt=string.sub(nod_space[1],1,1)
  local phr=""
  local page=""

  --spacengine off
  if config[1][1]==0 then
    phr="(u".. string.sub(owner,1,16) .." | (s(2CBBBBBBBBBBBBBBD) | (s(2A)(hSPACENGINE OFF(2(sA) | (s(2EBBBBBBBBBBBBBBF) | (u".. string.sub(channel,1,16)

  else
    local bymodule=config[12]
    local by_all=false

    if string.find(config[12],"y") then
      by_all=true
    end

    --multipage
  if bymodule~="n" then
    local lng=string.len(nod_space[4])/3
    page="(2(b"

    if lng>7 then lng=7 end

    for i=1,lng do
      if i==nod_space[5] then
        page=page.."(c"..i.."(b"
      else
        page=page..i
      end
    end
    page=page.. string.rep("_",9-lng)..")(c"
  end

--*********************
--** central message **
--*********************
if string.find(bymodule,"m") or by_all then
  if scr_opt=="m" then
    local idx_msg=nod_space[5]
    local msg=string.split(config[13][9],";")
    local msg_to_scroll
    if #msg==1 then
      msg_to_scroll=msg[1]
    else
      if nod_space[6] and nod_space[6]=="i" then
        msg_to_scroll=msg[2]
      else
        msg_to_scroll=msg[3]
      end
    end

    local scroll="-----------------" .. msg_to_scroll .. "-----------------"
    local l_msg=#scroll

    --scrolling
    if idx_msg>(l_msg-16) then idx_msg=1 end

    phr=" |  | (h".. string.sub(scroll,idx_msg,idx_msg+16)
    idx_msg=idx_msg+8
    nod_space[5]=idx_msg
    nod_met:set_string("spacengine",spacengine.compact(nod_space))

    return screen_exit(npos,nod_met,phr)
  end
end

  --*****************
  --*** controler ***
  --*****************
  if string.find(bymodule,"C") or string.find(bymodule,"e") or by_all then
    if scr_opt=="C" then
      local vl=tonumber(string.sub(nod_space[4],12,12))+1
      if nod_space[5]==1 then
        page=page.."(1;)ON(1:)OFF"
      elseif nod_space[5]==2 then
        page=page.."(h(1!)JUMP "
        if config[4][6]<250 then
          page=page.."(f(1u)"
        else
          page=page.."(h(1!)"
        end
      elseif nod_space[5]==3 then
        page=page.."(3?MENU=@)"
      elseif nod_space[5]==4 then
        page=page.."MSG "..vl.."(1_6)"        
      elseif nod_space[5]==5 then
        page=page.."CLR MSG"
      end
      
      if nod_space[5]<4 then
      phr=page.." | (P(3?CONTROLER@)".. battery(config) .." | "
      if config[3][3]<0 then
        phr=phr.."(2(df(h".. string.char(math.min(7,math.ceil(config[3][3]*-0.001))+110) .."(df"
      else
        phr=phr.."(2(df(t".. string.char(math.min(7,math.ceil(config[3][3]*0.001))+110) .."(df"
      end

      if config[4][2]>0 then
        phr=phr.."(f(1_'"..string.char(math.floor(config[4][2]/15)+97).."_)"
      else
        phr=phr.."(h(1_'a_)"
      end

      if config[6][2]>0 then
        phr=phr.."(f(1%"..string.char(math.floor(config[6][2]/15)+97).."_)"
      else
        phr=phr.."(h(1%a_)"
      end

      if config[5][2]>0 then
        phr=phr.."(f(1`"..string.char(math.floor(config[5][2]/15)+97).."_)"
      else
        phr=phr.."(h(1`a_)"
      end

      if config[11][2]>0 then 
        phr=phr.."(f (2:(1"..string.char(math.floor(config[11][2]/15)+97)..")"
      else
        phr=phr.."(h (2:(1a)"
      end
      end
      local rmax=spacengine.conso_engine(cpos,config,1)
      
      if nod_space[5]==1 then
        local rangex=1+tonumber(string.sub(config[1][4],2,3))*2
        local rangey=1+tonumber(string.sub(config[1][4],5,6))*2
        local rangez=1+tonumber(string.sub(config[1][4],8,9))*2
        phr=phr.." | (r(1x)"
        if config[1][3]>75 then
          phr=phr.."(h"
        elseif config[1][3]>50 then
          phr=phr.."(j"
        else
          phr=phr.."(f"
        end
        phr=phr .. string.sub(tostring(math.floor(config[1][3])+1000),2) .."%"
        phr=phr .. "(c(1_v)X".. rangex .."Y"..rangey.."Z"..rangez.." | "
        phr=phr.. "(1(kV)"..chargement(config) .."(l(14$)"..string.sub(tostring(config[1][2]+10000000),2)

      elseif nod_space[5]==2 then
        phr=phr.." | (jX"..p_dis(config[1][6][1]) .."(1__)Z"..p_dis(config[1][6][3]) .." | (jY"..p_dis(config[1][6][2]) .."(1__(m+w)".. string.sub(tostring(rmax+100000),2)

      elseif nod_space[5]==3 then
        phr=phr.." | (fX"..p_dis(cpos.x) .."(1__)Z"..p_dis(cpos.z) .." | (fY"..p_dis(cpos.y) .."(1__(m+w)".. string.sub(tostring(rmax+100000),2)
      elseif nod_space[5]>3 then
        phr=page.." | (E"
        local nb_msg=string.split(config[13][9],";")

        vl=vl+2

        if vl<#nb_msg+1 then
          local lng=string.len(nb_msg[vl])
          local s1,s2,s3="","",""
          if lng>32 then
            s3=string.sub(nb_msg[vl],33,48) 
          end
          if lng>16 then
            s2=string.sub(nb_msg[vl],17,32)
          end
          s1=string.sub(nb_msg[vl],1,16)
          phr=phr..s1
          if s2~="" then --2 ligne
            phr=phr.." | ".. s2
          end
          if s3~="" then --3 ligne
            phr=phr.." | ".. s3
          end
        end
      end
    end
  end

  if string.find(bymodule,"B") or string.find(bymodule,"e") or by_all then
    --***************
    --*** battery ***
    --***************
    if scr_opt=="B" then
      page=page.."(3?MENU=@) | "
      phr=page.."(p(3?BATTERY@) ".. battery(config) .." | (qlvl ".. string.sub(tostring(math.floor(config[2][2])+10000000000),2) .." | (emax ".. string.sub(tostring(math.floor(config[2][1])+10000000000),2).." | "

      if config[3][3]<0 then
        phr=phr.."(2(df(h".. string.char(math.min(7,math.ceil(config[3][3]*-0.001))+110) .."(df_)(h".. string.sub(tostring(math.floor(math.abs(config[3][3])+10000000)),2)
      else
        phr=phr.."(2(df(t".. string.char(math.min(7,math.ceil(config[3][3]*0.001))+110) .."(df_)(f".. string.sub(tostring(math.floor(config[3][3])+10000000),2)
      end
    end
  end
  --*************
  --*** power ***
  --*************
  if string.find(bymodule,"P") or string.find(bymodule,"e") or by_all then
    if scr_opt=="P" then

      if nod_space[5]==1 then
        page=page.." ON/OFF"
      elseif nod_space[5]==2 then
        page=page.."- SRC -"
      elseif nod_space[5]==3 then
        page=page.."(3?MENU=@)"
      end

      phr=page.." | (p(3?POWER@)"

        local tmp1=config[3][1]
        
        if type(config[3][4])=="table" then
          if #config[3][4]>1 then
          if tmp1<2 or tmp1>#config[3][4] then tmp1=2 end

          local id=config[3][4][tmp1]
          if config[3][5][tmp1]==0 then
            phr=phr.."(h(3?OFF@) | (g"
          else
            phr=phr.."(f(3?ON=@) | (g"
          end
          phr=phr.. string.sub(spacengine.upgrade[3][id][3],1,16) .." | "
          end
        else
          phr=phr.."(jNONE | (h(3?OFF@) | "
        end

      if config[3][3]<0 then
        phr=phr.."(2(df(h".. string.char(math.min(7,math.ceil(config[3][3]*-0.001))+110) .."(df)(h".. string.sub(tostring(math.floor(math.abs(config[3][3])+10000000)),2)
      else
        phr=phr.."(2(df(t".. string.char(math.min(7,math.ceil(config[3][3]*0.001))+110) .."(df)(f".. string.sub(tostring(math.floor(config[3][3])+10000000),2)
      end

      local tmp1=config[2][1]
      local tmp2=config[2][2]
      local tmp3="U"
      if tmp1>99999 then
        tmp1=math.floor(tmp1/1000)
        tmp2=math.floor(tmp2/1000)
        tmp3="KU"
      end
      phr=phr.." | (1(qt)"..string.sub(tostring(math.floor(tmp2)+100000),2).."(o/(e".. string.sub(tostring(math.floor(tmp1)+100000),2) ..tmp3
    end
  end
  --**************
  --*** engine ***
  --**************
  if string.find(bymodule,"E") or string.find(bymodule,"e") or by_all then
    if scr_opt=="E" then

      local pg=nod_space[5]*12
      local pidx=0

      if nod_space[6]~=nil then
        local tmp=string.sub(nod_space[6],pg-11,pg-11)
        if tmp~=":" then
          pidx=tonumber(string.sub(nod_space[6],pg-6,pg-6))
        end
      end

      if nod_space[5]==1 then
        phr=page.."(kn"..pidx.." XDST"
      elseif nod_space[5]==2 then
        phr=page.."(kn"..pidx.." YDST"
      elseif nod_space[5]==3 then
        phr=page.."(kn"..pidx.." ZDST"
      elseif nod_space[5]==4 then
        phr=page.."-WEIGHT"
      elseif nod_space[5]==5 then
        phr=page.."PUISSAN"
      elseif nod_space[5]==6 then
        phr=page.."(nQUICK(2(k_=)"
      elseif nod_space[5]==7 then
        phr=page.."(nQUICK(1(d_3)"
      --elseif nod_space[5]==8 then
      --  phr=page.."(nQUICK(1(h_u)"
      end

      phr=phr.." | (p(3?ENGINE@)"
      if config[4][6]<250 then
        phr=phr.."(f(1u)"
      else
        phr=phr.."(h(1!)"
      end
      
      if config[4][6]>5000 then
        phr=phr.." (2(h"
      elseif config[4][6]>999 then
        phr=phr.." (2(k"
      else
        phr=phr.." (2(f"
      end

      phr=phr.."m)".. string.sub(tostring(config[4][6]+100000),2).." | "
      local conso,rmax,distance=spacengine.conso_engine(cpos,config,2)

      if nod_space[5]==1 then
        phr=phr.."(jX(3"..p_dis(config[1][6][1]).."(1____)".. battery(config).." | (jY".. p_dis(config[1][6][2]) .."(1____(rx)"..string.sub(tostring(math.floor(config[1][3])+1000),2) .."% | (jZ".. p_dis(config[1][6][3]) .."(1___(du)".. string.sub(tostring(distance+100000),2)

      elseif nod_space[5]==2 then
        phr=phr.."(jX"..p_dis(config[1][6][1]).."(1____)".. battery(config).." | (jY(3".. p_dis(config[1][6][2]) .."(1____(rx)"..string.sub(tostring(math.floor(config[1][3])+1000),2) .."% | (jZ".. p_dis(config[1][6][3]) .."(1___(du)".. string.sub(tostring(distance+100000),2)

      elseif nod_space[5]==3 then
        phr=phr.."(jX"..p_dis(config[1][6][1]).."(1____)".. battery(config).." | (jY".. p_dis(config[1][6][2]) .."(1____(rx)"..string.sub(tostring(math.floor(config[1][3])+1000),2) .."% | (jZ(3".. p_dis(config[1][6][3]) .."(1___(du)".. string.sub(tostring(distance+100000),2)

      elseif nod_space[5]==4 then
        phr=phr.."(1(l$V)".. string.sub(tostring(config[1][2]+10000000),2) .." | (2(k`(1V)".. string.sub(tostring(config[4][7]+10000000),2) .." | (2(dmR__)".. string.sub(tostring(config[4][5]+100000),2)

      elseif nod_space[5]==5 then
        local conso_2
        if config[2][2]>0 then
          conso_2=math.min(200,math.ceil((conso/config[2][2])*100))
        else
          conso_2=200
        end
        local tmp1="f"
        if conso_2>75 then
          tmp1="h"
        elseif conso_2>50 then
          tmp1="k"
        end

        local tmp3=math.floor(config[4][2]/16)+65
        tmp2=math.ceil((config[4][1]*config[4][2])/100)
        phr=phr.."(1(n3)".. string.sub(tostring(rmax+100000),2) .."(k(1R*)".. string.sub(tostring(conso+100000000),2) .." | (1(mw)".. string.sub(tostring(config[4][3]+100000),2) .."(q(1Rt)".. string.sub(tostring(config[2][2]+100000000),2) .." | (g(1".. string.char(tmp3) .."')".. string.sub(tostring(tmp2+1000),2).."T(j(1R)("..tmp1.. string.sub(tostring(conso_2+1000),2) .."%".. chargement(config)

      elseif nod_space[5]>5 then
        local vl=0
        if config[4][8]~=nil then vl=config[4][8] end
        --local vl=tonumber(string.sub(nod_space[4],12,12))+1
        phr=phr.."(d".. string.sub(tostring(rmax+100000),2) .."(1w(e__"

        if vl==0 then
          phr=phr.."(h2(e"
        else
          phr=phr.."2"
        end

        phr=phr.."__"

        if vl==4 then
          phr=phr.."(h2(e"
        else
          phr=phr.."2"
        end

        local conso_2
        if config[2][2]>0 then
          conso_2=math.min(200,math.ceil((conso/config[2][2])*100))
        else
          conso_2=200
        end
        phr=phr.." | (i(1*)".. string.sub(tostring(conso_2+1000),2) .."%(1(e__"

        if vl==3 then
          phr=phr.."(h0(e"
        else
          phr=phr.."0"
        end

        phr=phr.."(g$(e"

        if vl==1 then
          phr=phr.."(h4(e"
        else
          phr=phr.."4"
        end

        phr=phr.."_(g+) | "..battery(config).."(e(1___"

        if vl==2 then
          phr=phr.."(h6(e"
        else
          phr=phr.."6"
        end

        phr=phr.."__"

        if vl==5 then
          phr=phr.."(h6)"
        else
          phr=phr.."6)"
        end

      end
      
    end
  end

--************
--** shield **
--************
if string.find(bymodule,"S") or by_all then
  if scr_opt=="S" then

    if nod_space[5]==1 then
      page=page.."PUISSAN"
    elseif nod_space[5]==2 then
        page=page.."(3?MENU=@)"
    end

    phr=page.." | (p(3?SHIELD@)"
    if config[5][2]>0 then
      phr=phr.."(f (3?ON=@)"
    else
      phr=phr.."(h (3?OFF@)"
    end
    local tmp1=config[5][4]/config[5][1]
    local tmp2=math.floor(tmp1*config[5][2])
    local tmp3=math.floor(config[5][2]/15)+65
    phr=phr.." | (n(1"..string.char(tmp3)..")"
    if tmp1>0.74 then
        phr=phr.."(f"
      elseif tmp1>0.24 then
        phr=phr.."(k"
      else
        phr=phr.."(h"
      end
    phr=phr..string.sub(tostring(tmp2+1000),2).."% | (d(1`)".. string.sub(tostring(config[5][4]+100000),2).." / (c"..string.sub(tostring(config[5][1]+100000),2) .." | (2(eRQ)"..string.sub(tostring(config[5][3]+1000),2)
  end
end

--*************
--** weapons **
--*************
if string.find(bymodule,"W") or by_all then
  if scr_opt=="W" then

    phr=" | (p (3?WEAPONS@) "
    if config[6][6]==0 then
      phr=phr.."(fREADY!"
    else
      phr=phr.."(hRELOAD"
    end
    
    if nod_space[5]==1 then
      page=page.."(h(1!)FIRE (1!)"
    elseif nod_space[5]==2 then
      page=page.."PUISSAN"
    elseif nod_space[5]==3 then
      page=page.."-RANG -"
    elseif nod_space[5]==4 then
      page=page.."-ZONE -"
    elseif nod_space[5]==5 then
      page=page.."(3?MENU=@)"
    end
    
    local puissance=math.floor(config[6][1]*config[6][2]*0.01)
    local range=math.floor(config[6][3]*config[6][4]*0.01)
    local zone=math.ceil(config[6][8]*config[4][4][4]*0.01)
    local xrng=math.ceil((-1+(0.02*config[4][4][1]))*range)
    local yrng=math.ceil((-1+(0.02*config[4][4][2]))*range)
    local zrng=math.ceil((-1+(0.02*config[4][4][3]))*range)
    local rmax=math.max(math.abs(xrng),math.abs(yrng),math.abs(zrng))
    local conso=(puissance*2)+(rmax*10)+(zone^3)

    local tmp2=math.floor(config[6][2]/15)+65

    
    phr=page..phr.." | ".. battery(config) .."(l(1_%)".. string.sub(tostring(config[6][7]+1000),2) .." (d(1v)".. string.sub(tostring(config[6][8]+1000),2) .." | (1(g*".. string.char(tmp2) ..")".. string.sub(tostring(conso+100000),2).."U(1_(mw"
    
    tmp2=math.floor(config[6][4]/15)+65
    phr=phr..string.char(tmp2)..")"..string.sub(tostring(range+1000),2)
    if nod_space[5]<4 then
      phr=phr.." | (e(2_Q)"..string.sub(tostring(config[6][6]+10000),2) .."/".. string.sub(tostring(config[6][5]+10000),2)
    elseif nod_space[5]==4 then
      
      tmp2=math.floor(config[4][4][4]/15)+72
      phr=phr.." | (kZONE (1".. string.char(tmp2) .."_)"..zone
    else
      tmp1=math.floor((config[6][3]*config[6][4])/100)
      local xrng=math.ceil((-1+(0.02*config[4][4][1]))*range)
      local yrng=math.ceil((-1+(0.02*config[4][4][2]))*range)
      local zrng=math.ceil((-1+(0.02*config[4][4][3]))*range)
      phr=phr.." | (pX"..xrng.." Y"..yrng.." Z"..zrng
    end

  end
end

--*****************
--** gravitation **
--*****************
if string.find(bymodule,"G") or by_all then
  if scr_opt=="G" then

    if nod_space[5]==1 then
      page=page.."PUISSAN"
    elseif nod_space[5]==2 then
        page=page.."(3?MENU=@)"
    end

    phr=page.." | (p(3?GFORCE@)"
    if config[8][2]>0 then
      phr=phr.."(f(3?ON=@)"
    else
      phr=phr.."(h(3?OFF@)"
    end
    local tmp1=math.floor((config[8][1] % 1000)*config[8][2])
    local tmp2=math.floor(config[8][2]/14.4)+65
    phr=phr.." | (1(l"..string.char(tmp2)..") | (l"..tmp1.."mG/(o Nb ".. math.floor(config[8][1]/1000)
  end
end

--*************
--** oxygene **
--*************
if string.find(bymodule,"O") or by_all then
  if scr_opt=="O" then --oxygene

    if nod_space[5]==1 then
      page=page.."PUISSAN"
    elseif nod_space[5]==2 then
      page=page.."(h(1!)OXYGEN"
    elseif nod_space[5]==3 then
      page=page.."(3?MENU=@)"
    end

    local tmp1=math.floor((config[11][1]*config[11][2])/100)
    local tmp2=math.floor(config[11][2]/15)+65
    phr=page.." | (p(3?OXYGENE@(1_(i".. string.char(tmp2)
    if config[11][2]>0 then
      phr=phr.."(f(3?ON=@)"
    else
      phr=phr.."(h(3?OFF@)"
    end
    
    local volume=math.ceil((tonumber(string.sub(config[1][4],11,15))*config[11][1]*config[11][2])/3000000)
    phr=phr .." | (2(fR(1".. vumetre(config[11][4],config[11][3] % 1000,false) .."(2_(c:(1".. vumetre(tmp1,100,true) .." | (1(j&".. vumetre(volume,25,true) ..")(d".. volume .." | (oNb ".. math.floor(config[11][3]/10000) .."/(fS ".. (config[11][3] % 1000)

  end
end

--***********
--** radar **
--***********
if string.find(bymodule,"R") or by_all then
  if scr_opt=="R" then

    if nod_space[5]==1 then
      page=page.."(j-SCAN -"
    elseif nod_space[5]==2 then
      page=page.."PUISSAN"
    elseif nod_space[5]==3 then
      page=page.."-CIBLE-"
    elseif nod_space[5]==4 then
      page=page.."-ZONE -"
    elseif nod_space[5]==5 then
      page=page.."(3?MENU=@)"
    end

    phr=page.." | (p(3?RADAR@(1(rU_(lw)"..config[7][3]
    local tmp1=math.floor((config[7][1]*config[7][2])/100)
    local tmp2=math.floor(config[7][2]/15)+65
    local tmp3=math.floor((config[7][3]*config[4][4][4])/100)
    phr=phr.." | "..battery(config).."(1(d_"..string.char(tmp2).."*)"..string.sub(tostring(tmp1+1000),2).."U (p(1v)"..tmp3 .." | "
    if nod_space[5]<4 then
      local id=math.max(1,config[7][6])
      if type(config[7][4])=="table" then
        id=math.min(#config[7][4],id)
        local search=string.split(config[7][4][id],":")
        phr=phr..radar_entity(id,search) .." | "
        if search[4] then
          phr=phr.."(hMISSION "
        else
          phr=phr.."(p"
        end
        phr=phr..config[7][5][id]
        
      else
        local search=string.split(config[7][4],":")
        phr=phr..radar_entity(id,search) .." | "
        if search[4] then
          phr=phr.."(hMISSION "
        else
          phr=phr.."(p"
        end
        phr=phr..config[7][5]
      end
      
    else
      local xrng=math.ceil((-1+(0.02*config[4][4][1]))*config[7][3])
      local yrng=math.ceil((-1+(0.02*config[4][4][2]))*config[7][3])
      local zrng=math.ceil((-1+(0.02*config[4][4][3]))*config[7][3])
      phr=phr.."(pX"..xrng.." Y"..yrng.." Z"..zrng
    end
  end
end

--*****************
--** manutention **
--*****************
if string.find(bymodule,"M") or by_all then
  if scr_opt=="M" then

    if nod_space[5]==1 then
      page=page.."!EXEC !"
    elseif nod_space[5]==2 then
      page=page.."COMMAND"
    elseif nod_space[5]==3 then
      page=page.."-SRCE -"
    elseif nod_space[5]==4 then
      page=page.."-RANGE-"
    elseif nod_space[5]==5 then
      page=page.."-ZONE -"
    elseif nod_space[5]==6 then
      page=page.."(3?MENU=@)"
    elseif nod_space[5]==7 then
      page=page.."(18__)ID X"
    elseif nod_space[5]==8 then
      page=page.."(18__)ID Y"
    elseif nod_space[5]==9 then
      page=page.."(18__)ID Z"
    end

    local tmp1=math.floor((config[13][1]*config[13][2])/100)
    local tmp2=math.floor(config[13][2]/15)+65
    local tmp3
    local tmp4=math.floor((config[13][3]*config[4][4][4])/100)

    if type(config[13][5])=="table" then
      if config[13][6]>#config[13][5] then config[13][6]=1 end
      tmp3=string.split(config[13][5][config[13][6]],":")
    else
      tmp3=string.split(config[13][5],":")
    end

    if config[13][10]<0 then
      phr=page.." | (3(f?MANUTENTION@)"
    else
      phr=page.." | (3(h?MANUTENTION@)"
    end

    local calcul=tonumber(tmp3[3])+100
    phr=phr.."(j(2R)".. string.sub(tostring(calcul),2) .." | (1(mw".. string.char(tmp2) ..")".. string.sub(tostring(tmp1+1000),2)
    
    tmp2=math.floor(config[4][4][4]/15)+65

    calcul=tonumber(tmp3[5])+1000
    phr=phr.."(1(d_v"..string.char(tmp2)..")".. string.sub(tostring(tmp4+1000),2).."(i(1_*)".. string.sub(tostring(calcul),2)

    local mis1,mis2=""

    if tmp3[6] then
      mis1="(hM(1!"
      mis2="(h(1!)M"
    else
      mis1="(1__)"
      mis2="(1__)"
    end

  if nod_space[5]<4 then
    if tmp3[5]=="0" then
      phr=phr.." | (f"
    else
      phr=phr.." | (i"
    end
    phr=phr.. string.sub(tmp3[2],1,16).." | ".. mis1

    if string.find(config[13][7],"B") and string.find(tmp3[4],"B") then
      if config[13][8]==1 then
        phr=phr.."(1(kT)"
      else
        phr=phr.."(1(wT)"
      end
    else
      phr=phr.."(1(w/)"
    end
    if string.find(config[13][7],"D") and string.find(tmp3[4],"D") then
      if config[13][8]==2 then
        phr=phr.."(2(k*)"
      else
        phr=phr.."(2(w*)"
      end
    else
      phr=phr.."(1(w/)"
    end
    if string.find(config[13][7],"P") and string.find(tmp3[4],"P") then
      if config[13][8]==3 then
        phr=phr.."(2(k+)"
      else
        phr=phr.."(2(w+)"
      end
    else
      phr=phr.."(1(w/)"
    end
    phr=phr..mis2
  else
    local xrng=math.ceil((-1+(0.02*config[4][4][1]))*tmp1)
    local yrng=math.ceil((-1+(0.02*config[4][4][2]))*tmp1)
    local zrng=math.ceil((-1+(0.02*config[4][4][3]))*tmp1)
    phr=phr.." | (pX"..xrng.." Y"..yrng.." Z"..zrng .." | "
    if nod_space[5]>6 then
      local idz=(config[13][11] % 1000)-100
      local idy=(math.floor(config[13][11]/1000) % 1000)-100
      local idx=(math.floor(config[13][11]/1000000) % 1000)-100
      if nod_space[5]==7 then
        phr=phr.."(h(3"..idx..")"
      else
        phr=phr.."(c"..idx
      end

      if nod_space[5]==8 then
        phr=phr.."(c-(h(3"..idy..")"
      else
        phr=phr.."(c-"..idy
      end

      if nod_space[5]==9 then
        phr=phr.."(c-(h(3"..idz..")"
      else
        phr=phr.."(c-"..idz
      end

    end
end

  end
end

--*************
--** storage **
--*************
if string.find(bymodule,"s") or by_all then
  if scr_opt=="s" then
    local storage=config[9]

    if nod_space[5]==1 then
      page=page.."STORAGE"
    elseif nod_space[5]==2 then
      page=page.."VOYAGER"
    elseif nod_space[5]==3 then
      page=page.."MISSION"
    elseif nod_space[5]==4 then
        page=page.."(3?MENU=@)"
    end

    local nb_param=nod_space[5]
    if nb_param>math.floor(string.len(nod_space[4])/3) then
      nb_param=1
    end

    local vl=string.sub(nod_space[4],nb_param*3,nb_param*3)
    phr=page.." | (p(3?STORAGE@(2_(w`(1(e_6)"..vl.."(12) | "

    if nod_space[5]==1 then
    phr=phr.."(o".. string.sub(tostring(storage[2]+1000000),2) .."/".. string.sub(tostring(storage[1]+1000000),2)
    if vl=="0" then
      phr=phr.." | (pEat "..storage[3][1].." | (pOres"..storage[3][2]
    elseif vl=="1" then
      phr=phr.." | (pTools "..storage[3][3].." | (pMaterial"..storage[3][4]
    elseif vl=="2" then
      phr=phr.." | (pFurniture "..storage[3][5].." | (pMachine"..storage[3][6]
    elseif vl=="3" then
      phr=phr.." | (pMisc "..storage[3][7]
    elseif vl=="4" then
      phr=phr.." | (pWeight "..config[1][2]
    end
    end

    if nod_space[5]==2 then
    phr=phr.."(o".. string.sub(tostring(config[10][2]+1000000),2) .."/".. string.sub(tostring(config[10][1]+1000000),2)
    if vl=="0" then
      phr=phr.." | (pcrew "..config[10][3][1]
    elseif vl=="1" then
      phr=phr.." | (pworker "..config[10][3][3]
    elseif vl=="2" then
      phr=phr.." | (ptourist "..config[10][3][5]
    elseif vl=="3" then
      phr=phr.." | (pscientist "..config[10][3][3]
    elseif vl=="4" then
      phr=phr.." | (pmilitary "..config[10][3][3]
    elseif vl=="5" then
      phr=phr.." | (pWeight "..config[1][2]
    end
    end

    if nod_space[5]==3 then
      local tmp=spacengine.area[channel_a].mission
      if tmp~="" then
        local mission=string.split(tmp,"/")
        local vl_nb=tonumber(vl)+1
        if vl_nb<#mission+1 then
        local creat_dat=((espace.year-1)*168)+((espace.month-1)*14)+espace.day
        local this_secteur=espace.secteur(cpos)
        local passenger_type={"worker","tourist","scientist","military"}
        local item_type={"eat","ores","tools","material","furniture","machine","misc"}
    
        local destination=string.split(mission[vl_nb],":")
        local nb=tonumber(destination[2])
        local days=""
        local arrival=""
        local tmp1=tonumber(destination[5])-creat_dat

        if tmp1>0 then
          days= " (d".. tmp1 .."D"
        else
          days="(1(h!)"..tmp1
        end
        --test coordo destination
        if tonumber(destination[7])==this_secteur.nb then
          arrival="(fOK"
        else
          arrival="(kS".. tonumber(destination[7])+1
        end

        if destination[1]=="1" then
          phr = phr .."(j".. commerce.item_type[nb].." ".. destination[3] .." U | "..arrival..days.." | (j"..destination[4].."Mg"
        elseif destination[1]=="2" then
          phr = phr .."(n".. destination[3].." ".. commerce.passenger_type[nb].." | "..arrival..days.." | (n"..destination[4].."Mg"
        elseif destination[1]=="3" then
          phr = phr .."(c D (j".. commerce.dig_node[nb][1].." ".. destination[3] .." | "..arrival..days.." | (j"..destination[4].."Mg"
        elseif destination[1]=="4" then
          phr = phr .."(c B (j".. commerce.build_node[nb][1].." ".. destination[3] .." | "..arrival..days.." | (j"..destination[4].."Mg"
        elseif destination[1]=="5" then
          phr = phr .."(c R (j".. commerce.spy_type[nb][1].." | "..arrival..days.." | (j"..destination[4].."Mg"
        end
        end
      else
        phr=phr.."No MISSION"
      end
    end

  end
end

--************
--** SWITCH **
--************
if string.find(bymodule,"A") or by_all then
  if scr_opt=="A" then
    
    if nod_space[5]==1 then
      page=page.."DOOR_IN"
    elseif nod_space[5]==2 then
      page=page.."ATC(1____)"
    elseif nod_space[5]==3 then
      page=page.."SAS_OUT"
    elseif nod_space[5]==4 then
      page=page.."STORAGE"
    elseif nod_space[5]==5 then
      page=page.."HANGAR(1_)"
    elseif nod_space[5]==6 then
      page=page.."AUX(1____)"
    elseif nod_space[5]==7 then
      page=page.."-LIGHT-"
    end

    phr=page.." | (p(3?KEYPAD@) | (1"
    local lign_up,lign_down="",""
    local value
    for nb_param=1, 7 do
      value=tonumber(string.sub(nod_space[4],nb_param*3,nb_param*3))
      if value==0 then
        lign_up=lign_up.."(h_Y"
        lign_down=lign_down.." "..nb_param
      else
        lign_up=lign_up.."(f_Z"
        lign_down=lign_down.." "..nb_param
      end
    end
    phr=phr..lign_up.."_) | (p"..lign_down .."(1_) | (2(sBBBBBBBBBBBBBBBB)"
  end
end

--************
--** analog **
--************
if string.find(bymodule,"D") or by_all then
  if scr_opt=="D" then
    
    if nod_space[5]==1 then
      page=page.."(1'_)"
    elseif nod_space[5]==2 then
      page=page.."(1%_)"
    elseif nod_space[5]==3 then
      page=page.."(1`_)"
    elseif nod_space[5]==4 then
      page=page.."(1U_)"
    elseif nod_space[5]==5 then
      page=page.."G(1_)"
    elseif nod_space[5]==6 then
      page=page.."(2:_)"
    elseif nod_space[5]==7 then
      page=page.."(1%(mw)"
    end

    local lign_up=""
    local lign_down=""
    phr=page.." | (p(3?ANALOG@) | "

    if config[4][2]>0 then
      lign_up=lign_up.."(f(1"..string.char(math.floor(config[4][2]/15)+65)
    else
      lign_up=lign_up.."(h(1A"
    end

    if config[6][2]>0 then
      lign_up=lign_up.."(f_"..string.char(math.floor(config[6][2]/15)+65)
    else
      lign_up=lign_up.."(h_A"
    end

    if config[5][2]>0 then
      lign_up=lign_up.."(f_"..string.char(math.floor(config[5][2]/15)+65)
    else
      lign_up=lign_up.."(h_A"
    end

    if config[7][2]>0 then
      lign_up=lign_up.."(f_"..string.char(math.floor(config[7][2]/15)+65)
    else
      lign_up=lign_up.."(h_A"
    end

    if config[8][2]>0 then 
      lign_up=lign_up.."(f_"..string.char(math.floor(config[8][2]/15)+65)
    else
      lign_up=lign_up.."(h_A"
    end

    if config[11][2]>0 then 
      lign_up=lign_up.."(f_"..string.char(math.floor(config[11][2]/15)+65)
    else
      lign_up=lign_up.."(h_A)"
    end

    phr=phr..lign_up.." | (1(p'_%_`_U_)G(2_:) | (1__"

    if config[6][4]>0 then 
      phr=phr .."(n_"..string.char(math.floor(config[6][4]/15)+65)
    else
      phr=phr .."(m_A"
    end

    phr=phr.."_________)"
  end
end

--COORDO
if string.find(bymodule,"F") or by_all then
  if scr_opt=="F" then
    if nod_space[5]==1 then
      page=page.."X(1______)"
    elseif nod_space[5]==2 then
      page=page.."Y(1______)"
    elseif nod_space[5]==3 then
      page=page.."Z(1______)"
    elseif nod_space[5]==4 then
      page=page.."-ZONE -"
    elseif nod_space[5]==5 then
      page=page.."(3?MENU=@)"
    end

    phr=page.." | (p(3?COORDO@) | "
    local zone=math.floor(config[4][4][4]/15)+65
    phr=page.." | (1(m".. string.char(math.floor(config[4][4][1]/15)+65) .."(e".. string.char(math.floor(config[4][4][2]/15)+65) .."(j".. string.char(math.floor(config[4][4][3]/15)+65) .."(p(3?COORDO@(k(1_"..string.char(zone) ..") | "
    local wpns=math.floor((config[6][3]*config[6][4])/100)
    local radar=config[7][3]
    local manut=math.floor((config[13][1]*config[13][2])/100)
    local xrng=(-1+(0.02*config[4][4][1]))
    local yrng=(-1+(0.02*config[4][4][2]))
    local zrng=(-1+(0.02*config[4][4][3]))
    phr=phr.."(1(h%)(mX".. p_dis(math.floor(xrng*wpns),2).." (eY"..p_dis(math.floor(yrng*wpns),2).." (jZ"..p_dis(math.floor(zrng*wpns),2).." | " --.."(1(d"..string.char(zone)..")"
    phr=phr.."(1(dU)(mX"..p_dis(math.floor(xrng*radar),2).." (eY"..p_dis(math.floor(yrng*radar),2).." (jZ"..p_dis(math.floor(zrng*radar),2).." | "
    phr=phr.."(1(kT)(mX"..p_dis(math.floor(xrng*manut),2).." (eY"..p_dis(math.floor(yrng*manut),2).." (jZ"..p_dis(math.floor(zrng*manut),2)
  
  end
end

--*********
--** AIM **
--*********
if string.find(bymodule,"c") or by_all then
  if scr_opt=="c" then
    local xrng=math.floor(0.069*config[4][4][1])+1
    local yrng=math.floor(0.069*config[4][4][2])+1
    local zrng=math.floor(0.069*config[4][4][3])+1    

    local lgn={}

    for ligne=1,7 do
      local inv_lgn=8-ligne
      lgn[ligne]="(b"

      if zrng==ligne then

        for colone=1,7 do
          if xrng==colone then
            lgn[ligne]=lgn[ligne].."(k/(b"
          else
            lgn[ligne]=lgn[ligne]..","
          end
        end

      else
        lgn[ligne]=lgn[ligne]..",,,,,,,"
      end

      if nod_space[5]+1==inv_lgn and ligne>1 then
        lgn[ligne]=lgn[ligne].."4"
      else
        if ligne==1 or ligne==7 then
          lgn[ligne]=lgn[ligne].."(2(sB"
        else
          lgn[ligne]=lgn[ligne].."_"
        end
      end

      if ligne==7 then
        lgn[ligne]=lgn[ligne].."BB(1(b"
      elseif ligne==6 then
        lgn[ligne]=lgn[ligne].."(m".. string.char(math.floor(config[4][4][1]/15)+65)..")X(1(b"
      elseif ligne==5 then
        lgn[ligne]=lgn[ligne].."(j".. string.char(math.floor(config[4][4][3]/15)+65)..")Z(1(b"
      elseif ligne==4 then
        lgn[ligne]=lgn[ligne].."(e".. string.char(math.floor(config[4][4][2]/15)+65)..")Y(1(b"
      elseif ligne==3 then
        lgn[ligne]=lgn[ligne].."(k".. string.char(math.floor(config[4][4][4]/15)+65).."v(b"
      elseif ligne==2 then
        lgn[ligne]=lgn[ligne].."(2(v=_(1(b"
      elseif ligne==1 then
        if nod_space[5]==6 then
          lgn[ligne]=lgn[ligne].."(1(k9T(b"
        elseif nod_space[5]==7 then
          lgn[ligne]=lgn[ligne].."(1(g9U(b"
        elseif nod_space[5]==8 then
          lgn[ligne]=lgn[ligne].."(1(h9%(b"
        else
        lgn[ligne]=lgn[ligne].."BB(1(b"
        end
      end

    end

    for ligne=1,7 do
      if yrng==ligne then
        for colone=1,7 do
          if zrng==colone then
            lgn[ligne]=lgn[ligne].."(k/(b"
          else
            lgn[ligne]=lgn[ligne]..","
          end
        end
      else
        lgn[ligne]=lgn[ligne]..",,,,,,,"
      end
    end

    phr="(h(1%"..lgn[7]..
    " | (h(1"..string.char(math.floor(config[6][4]/15)+104)..lgn[6]..
    " | (g(1U"..lgn[5]..
    " | (g(1"..string.char(math.floor(config[7][3]/15)+104)..lgn[4]..
    " | (k(1T"..lgn[3]..
    " | (k(1"..string.char(math.floor(config[13][2]/15)+104)..lgn[2]..
    " | (1_"..lgn[1]

  end
end

--
--**********
--** info **
--**********
if string.find(bymodule,"i") or by_all then
  if scr_opt=="i" then

    if nod_space[5]==1 then
      page=page.."-SECTOR"
    elseif nod_space[5]==2 then
      page=page.."X Matrx"
    elseif nod_space[5]==3 then
      page=page.."Y Matrx"
    elseif nod_space[5]==4 then
      page=page.."Z Matrx"
    elseif nod_space[5]==5 then
      page=page.."-BLOC x"
    end

    if nod_space[6]~=nil then

    local pg=nod_space[5]*12
    local pidx=tonumber(string.sub(nod_space[6],pg-6,pg-6))
    
    if pidx>1 then
      pidx=10^(pidx-1)
    end

    phr=page.." | (3(P?INFO@) (k< x".. pidx .." >"

    if nod_space[5]==1 then
      local secteur,astroport=espace.info_secteur(nod_space[7])
      phr=phr.. " | (fX"..p_dis(astroport.x) .." ".. string.sub(tostring(secteur.x+100),2) ..
                " (h(3".. string.sub(tostring(nod_space[7]+1000001),2) ..
                ") | (fY"..p_dis(astroport.y) .." ".. string.sub(tostring(secteur.y+100),2) ..
                "(1_______)"..
                " | (fZ"..p_dis(astroport.z) .." ".. string.sub(tostring(secteur.z+100),2) ..
                " B".. string.sub(tostring(nod_space[11]+1000),2) .."(1__)"

    elseif nod_space[5]>1 and nod_space[5]<5 then
      local secteur=espace.secteur_by_matrice({x=nod_space[8],y=nod_space[9],z=nod_space[10]})
      local astroport=espace.astroport(secteur)
      phr=phr.. " | (fX"..p_dis(astroport.x)

      if nod_space[5]==2 then
        phr=phr.." (h(3"
      else
        phr=phr.." (f"
      end

      phr=phr..string.sub(tostring(nod_space[8]+100),2) ..") (f".. string.sub(tostring(secteur.nb+1000001),2) ..
          " | (fY"..p_dis(astroport.y)

      if nod_space[5]==3 then
        phr=phr.." (h(3"
      else
        phr=phr.." (f"
      end

      phr=phr.. string.sub(tostring(nod_space[9]+100),2) .."(1_______)"..
          " | (fZ"..p_dis(astroport.z) 

      if nod_space[5]==4 then
        phr=phr.." (h(3"
      else
        phr=phr.." (f"
      end

      phr=phr.. string.sub(tostring(nod_space[10]+100),2) ..
                ") (fB".. string.sub(tostring(nod_space[11]+1000),2) .."(1__)"

    else
      local secteur=espace.info_secteur(nod_space[7],nod_space[11])
      phr=phr.. " | (fX"..p_dis(secteur.x) .." ".. string.sub(tostring(nod_space[8]+100),2) ..
                " (e".. string.sub(tostring(secteur.nb+1000001),2) ..
                " | (fY"..p_dis(secteur.y) .." ".. string.sub(tostring(nod_space[9]+100),2) ..
                "(1_______)"..
                " | (fZ"..p_dis(secteur.z) .." ".. string.sub(tostring(nod_space[10]+100),2) ..
                " (hB(3".. string.sub(tostring(nod_space[11]+1000),2) .."(1__)"

    end

    end

  end
end
--]]

end

if phr=="" then return end
nod_met:set_string("text",phr)
monitor.update_sign(npos,nil,nil,nil)
end
