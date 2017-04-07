local FamilyStageJoinItem=class("FamilyStageJoinItem",UILayer)

function FamilyStageJoinItem:ctor(memberInfo)
    self:init("ui/ui_family_stage_join_item.map")
    self:setData(memberInfo)
end


function FamilyStageJoinItem:onTouchEnded(target, touch, event)
    if target.touchName=="btn_remind" then
        if self.isSelf then
            gShowNotice(gGetWords("noticeWords.plist","no_family_stage_tip_to_self"))
            return
        end

        if gFamilyInfo.iType > 3 then
            gShowNotice(gGetWords("noticeWords.plist","family_type_lim"))
        end
        Data.addFamilyStageTipInfo(self.curData.uid)
        Net.sendFamilyStageTip(self.curData.sName)
        self:setTouchEnable("btn_remind", false, true)
    end
end

function FamilyStageJoinItem:setData(memberInfo)
    Icon.setHeadIcon(self:getNode("icon"), memberInfo.iCoat)
    self.isSelf = memberInfo.uid == Data.getCurUserId()
    self.curData = memberInfo
    self:getNode("icon_me"):setVisible(self.isSelf)
    self:setLabelString("txt_name", memberInfo.sName)
    self:setLabelString("txt_post", gGetWords("familyMenuWord.plist", "title"..memberInfo.iType))
    self:setLabelString("txt_power", memberInfo.iPower)
    local maxNum = DB.getFamilyStageFightNum()
    local leftNum = maxNum - memberInfo.iStageFightNum
    self:setLabelString("txt_fight_num", string.format("%d/%d", leftNum, maxNum))

    if leftNum == 0 then
        self:setLabelString("txt_remind", gGetWords("btnWords.plist", "btn_have_fighted"))
    end

    if leftNum == 0 or
       gFamilyStageInfo.tipInfo[memberInfo.uid] or
       gFamilyInfo.iType > 3 then
        self:setTouchEnable("btn_remind", false, true)
    end
end


return FamilyStageJoinItem