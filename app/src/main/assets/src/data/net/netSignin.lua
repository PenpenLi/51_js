

--商店购买
function Net.sendSignInit()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_SIG_INIT)
end


function Net.rec_sig_init(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.signInfo.lv = obj:getByte("lv");
    Data.signInfo.totalCount = obj:getInt("tolcou");
    Data.signInfo.count = obj:getByte("cou");
    Data.signInfo.dia = obj:getInt("dia");
    Data.signInfo.bolSign = obj:getBool("sign");
    -- Data.signInfo.bolVip = obj:getBool("vip");
    -- dealRedDot_SignIn();

    --当月每日是否有充值的记录
    local iaprcd=obj:getIntArray("iaprcd") 
    local apos={}
    if(iaprcd)then
        for i=0, iaprcd:size()-1 do 
            table.insert(apos,iaprcd[i]);
        end
        Data.signInfo.iaprcd = apos;
    end 

    --当月每日充值的奖励是否已领取
    local rwdrcd=obj:getIntArray("rwdrcd") 
    apos={}
    if(rwdrcd)then
        for i=0, rwdrcd:size()-1 do 
            table.insert(apos,rwdrcd[i]);
        end
        Data.signInfo.rwdrcd = apos;
    end 
    --累计签到领取奖励
    for i=1,3 do
        Data.signInfo.reward[i].bolGet = obj:getBool("rwd"..i);
    end

    if Panel.isOpenPanel(PANEL_SIGNIN) then
        gDispatchEvt(EVENT_ID_SIGN_REFRESH)
    else
        gDispatchEvt(EVENT_ID_SIGN_INIT);
    end
end

function Net.sendSignSign()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_SIG_SIGN)
    if (TalkingDataGA) then
        gLogEvent("sign_in")
    end
end

function Net.rec_sig_sign(evt)

    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.signInfo.lv = obj:getByte("lv");
    -- Data.signInfo.bolVip = obj:getBool("vip");
    Data.signInfo.dia = obj:getInt("dia");
    Net.updateReward(obj:getObj("reward"),2);
    Data.signInfo.bolSign = true;
    Data.signInfo.count = Data.signInfo.count + 1;
    Data.signInfo.totalCount = Data.signInfo.totalCount + 1;
    gDispatchEvt(EVENT_ID_SIGN_IN);
    Data.redpos.bolDaySign = false;
    print_lua_table(Data.redpos)
    -- dealRedDot_SignIn();
    -- EventListener::sharedEventListener()->handleEvent(c_event_redDot_SignIn);
    -- EventListener::sharedEventListener()->handleEvent(c_event_main_pm_sign_sign);
end

function Net.sendSignVip(index)
    -- body
    local media=MediaObj:create();
    media:setInt("idx",index);
    SigninPanelData.vipIndex = index;
    Net.sendExtensionMessage(media, CMD_SIG_VIP) 
    if (TalkingDataGA) then
        gLogEvent("sign_in_vip")
    end   
end

function Net.rec_sig_vip(evt)

    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2);
    -- Data.signInfo.bolVip = true;
    Data.signInfo.rwdrcd[SigninPanelData.vipIndex+1] = 1;
    gDispatchEvt(EVENT_ID_SIGN_IN);


    print_lua_table(Data.signInfo.iaprcd);
    print_lua_table(Data.signInfo.rwdrcd);
    local bCanGet = false;
    for k,v in pairs(Data.signInfo.iaprcd) do
        if v == 1 and Data.signInfo.rwdrcd[k] ~= 1 then
            print(" k = "..k);
            bCanGet = true;
            break;
        end
    end
    if bCanGet == false then
        Data.redpos.bolVipSign = false;
    end
    -- EventListener::sharedEventListener()->handleEvent(c_event_main_pm_sign_sign);    
end

CMD_SIGN_GETREWARD = "sig.getrwd";
function Net.sendSignGetReward(index)
    local media=MediaObj:create();
    media:setInt("idx",index);
    Net.sendExtensionMessage(media, CMD_SIGN_GETREWARD);      
end

function Net.rec_sig_getrwd(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local rewards = Net.updateReward(obj:getObj("reward"),2);

    --累计签到领取奖励
    local bCanGet = false;
    for i=1,3 do
        Data.signInfo.reward[i].bolGet = obj:getBool("rwd"..i);
        if (Net.sign_canGetReward(i)) then
            bCanGet = true;
        end
        -- if Data.signInfo.reward[i].bolGet then
        --     bCanGet = true;
        -- end
    end
    if bCanGet == false then
        Data.redpos.bolCntSign = false;
    end
    gDispatchEvt(EVENT_ID_SIGN_IN);    
end

function Net.sign_canGetReward(index)
  local var = Data.signInfo.reward[index];
  if Data.signInfo.count >= var.day and not var.bolGet then
    return true;
  end
  return false;
end

-----新签到
function Net.sendSignInitNew()
    local media=MediaObj:create();
    Net.sendExtensionMessage(media, "sig.init1");      
end
function Net.rec_sig_init1(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.signInfo.today = obj:getInt("idx");
    Data.signInfo.resignCount = obj:getInt("renum");
    Data.signInfo.count = 0;
    local list ={}
    local idxArrays=obj:getIntArray("list")
    if(idxArrays)then
        for i=0, idxArrays:size()-1 do
            list[i+1]=idxArrays[i];
            if(idxArrays[i] == 1)then
                Data.signInfo.count = Data.signInfo.count + 1;
            end
        end
    end
    Data.signInfo.list = list;
    -- print_lua_table(list);
    --累计签到领取奖励
    for i=1,3 do
        Data.signInfo.reward[i].bolGet = obj:getBool("rwd"..i);
    end

    -- print("reward1111");
    -- print_lua_table(Data.signInfo);
    -- print("reward22222");
    -- if Panel.isOpenPanel(PANEL_SIGNIN) then
    --     gDispatchEvt(EVENT_ID_SIGN_REFRESH)
    -- else
    --     gDispatchEvt(EVENT_ID_SIGN_INIT);
    -- end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SIGNINFO);           
end

function Net.sendSignSignNew(dayIdx)
    local media=MediaObj:create();
    media:setInt("idx",dayIdx);
    Net.sendExtensionMessage(media, "sig.sign1");    
end

function Net.rec_sig_sign1(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gLogEvent("sign_in")
    local idx = obj:getInt("idx");
    Data.signInfo.list[idx] = 1;
    Net.updateReward(obj:getObj("reward"),2);

    Data.signInfo.count = 0;
    for key,var in pairs(Data.signInfo.list) do
        if(var == 1)then
            Data.signInfo.count = Data.signInfo.count + 1;
        end
    end
    Data.redpos.bolDaySign = false;

    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SIGNREFRESH); 
end

function Net.sendReSignSignNew(dayIdx)
    local media=MediaObj:create();
    media:setInt("idx",dayIdx);
    print("dayIdx = "..dayIdx);
    Net.sendExtensionMessage(media, "sig.resign");    
end

function Net.rec_sig_resign(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local idx = obj:getInt("idx");
    Data.signInfo.list[idx] = 1;
    Net.updateReward(obj:getObj("reward"),2);
    Data.signInfo.resignCount = obj:getInt("renum");

    Data.signInfo.count = 0;
    for key,var in pairs(Data.signInfo.list) do
        if(var == 1)then
            Data.signInfo.count = Data.signInfo.count + 1;
        end
    end

    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SIGNREFRESH);
end

function Net.sendSignGetRewardNew(idx)
    local media=MediaObj:create();
    media:setInt("idx",idx);
    Net.signGetRewardIdx = idx;
    Net.sendExtensionMessage(media, "sig.getrwd1");  
end

function Net.rec_sig_getrwd1(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.signInfo.reward[Net.signGetRewardIdx].bolGet = true;
    Net.updateReward(obj:getObj("reward"),2);  

    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SIGNREFRESH);  
end