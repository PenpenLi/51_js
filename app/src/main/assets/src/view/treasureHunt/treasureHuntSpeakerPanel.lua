local TreasureHuntSpeakerPanel=class("TreasureHuntSpeakerPanel",UILayer)
function TreasureHuntSpeakerPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_treasure_hunt_speaker.map")
    self.input = self:getNode("txt_input")
    self.input:setText("")
    self.input:setMaxLength(30)
    self.input:setPlaceHolder(gGetWords("noticeWords.plist","talk_input",30))
    local function onEditCallback(name, sender)
        if(name=="changed")then
            -- self:textChanged()
        end
    end
    self.input:registerScriptEditBoxHandler(onEditCallback)

    self:setLabelString("txt_dia", DB.getTreasureHuntChatDia())
    self:getNode("layout_dia"):layout()
end

function TreasureHuntSpeakerPanel:textChanged()
    -- gRefreshLeftCount(self:getNode("lab_limit"),Data.feedback.maxFbCount,string.filter(self.input:getText()))
end

function TreasureHuntSpeakerPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif(target.touchName=="btn_send")then
        if Data.getCurDia() < DB.getTreasureHuntChatDia() then
            NetErr.noEnoughDia()
            return
        end

        local strInfo = self.input:getText()
        if strInfo == "" then
            gShowNotice(gGetCmdCodeWord(CMD_CROSS_TREASURE_CHAT,7))
            return
        end
        -- print("TreasureHuntSpeakerPanel:onTouchEnded:strInfo is:",strInfo)
        Net.sendCrotreChat(strInfo)
        self:onClose()
    end
     
end

return TreasureHuntSpeakerPanel