
local FamilyWarSignUpPanel=class("FamilyWarSignUpPanel",UILayer)

function FamilyWarSignUpPanel:ctor(type)
    self:init("ui/ui_family_war_sign.map")
    self.isMainLayerGoldShow = false;

    self:setLabelAtlas("txt_season_num",gFamilyMatchInfo.season)

    if(gFamilyMatchInfo.winName=="")then
        self:getNode("panel_winer"):setVisible(false)
    else
        self:setLabelString("txt_name",gFamilyMatchInfo.winName.."(Lv."..gFamilyMatchInfo.winLevel..")")
        --self:replaceLabelString("txt_level",gFamilyMatchInfo.winLevel)
        self:replaceLabelString("txt_power",gFamilyMatchInfo.winPower)
        Icon.setFamilyIcon(self:getNode("icon") ,gFamilyMatchInfo.winIcon);
    end
    for i=1, 5 do
        self:setLabelString("txt_name"..i,"")
    end

    local sign= cc.UserDefault:getInstance():getIntegerForKey("family.sign"..gUserInfo.id,-1)
   
    local totalNum=table.count(gFamilyMatchInfo.winner)
    if(totalNum==0)then
        loadFlaXml("heiren")
        for key=1, 5 do
            local fla=gCreateFla("heiren_wait",1)
            gAddCenter(fla,self:getNode("role_container"..key) )
        end
        self:setLabelString("txt_last_season","")
    else
        self:replaceLabelString("txt_last_season",gFamilyMatchInfo.season-1)
        for key, winer in pairs(gFamilyMatchInfo.winner) do
            self:setLabelString("txt_name"..key,winer.name)
            gCreateRoleFla(winer.icon%100000, self:getNode("role_container"..key) ,0.8,true,nil,winer.show.wlv,winer.show.wkn,winer.show.halo)
        end

    end

    if(gFamilyInfo.iLevel<UNLCOK_FAMILY_WAR_LEVLE)then
        self:setTouchEnable("btn_family",false,true)
    else
        if(sign~=gFamilyMatchInfo.season)then
            RedPoint.add(self:getNode("btn_family"))
        end

        self:setTouchEnable("btn_family",true,false)
    end


    if(gFamilyMatchInfo.season==1)then
        self:setTouchEnable("btn_last",false,true)
    end
    self:resetLayOut()
    self:getNode("scroll_rule"):layout();
    self:checkSignBtn()
end

function FamilyWarSignUpPanel:checkSignBtn()
    self:getNode("btn_sign"):setVisible(false)
    self:getNode("btn_family"):setVisible(false)
    if(gFamilyMatchInfo.sign)then
        self:getNode("btn_family"):setVisible(true)
    else
        self:getNode("btn_sign"):setVisible(true)
    end
end
function FamilyWarSignUpPanel:dealEvent(event,param)

    if(event==EVENT_ID_FAMILY_WAR_SIGN)then
        self:checkSignBtn()
    end
end
function  FamilyWarSignUpPanel:events()
    return {EVENT_ID_FAMILY_WAR_SIGN }
end


function FamilyWarSignUpPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        self:onClose();
    elseif  target.touchName=="btn_rule"then
        gShowRulePanel(SYS_FAMILY_WAR)
    elseif  target.touchName=="btn_reward"then
        Panel.popUp(PANEL_FAMILY_WAR_REWARD)
    elseif  target.touchName=="btn_rank"then
        Net.sendFamilyWeekExp()
    elseif  target.touchName=="btn_sign"then

        if(Data.getCurFamilyType()==9)then
            gShowNotice(gGetWords("familyWords.plist","family_war_sign_fail2"))
            return
        end
        local level=DB.getFamilyBuildUnlock(8)
        if(gFamilyInfo.iLevel<level)then
            gShowNotice(gGetWords("familyWords.plist","family_war_sign_fail1",level))
            return
        end

        local function onOk()
            Net.sendFamilyMatchSign()
        end
        gConfirmClose(gGetWords("familyWords.plist","family_war_sign_check"),onOk)

    elseif  target.touchName=="btn_last"then
        Net.sendFamilyMatchRecord()

    elseif  target.touchName=="btn_family"then
        cc.UserDefault:getInstance():setIntegerForKey("family.sign"..gUserInfo.id,gFamilyMatchInfo.season)
        cc.UserDefault:getInstance():flush()
        RedPoint.remove(target)
        Net.sendFamilyTeamInfo(gFamilyInfo.familyId)
    end
end


return FamilyWarSignUpPanel