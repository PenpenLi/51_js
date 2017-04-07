local ServerBattleLookVideoPanel=class("ServerBattleLookVideoPanel",UILayer)
function ServerBattleLookVideoPanel:ctor(data)
    self.appearType = 1
    self:init("ui/ui_serverbattle_look_video.map")
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self.curData = data
    self:initPanel()
end

function ServerBattleLookVideoPanel:initPanel()
    local result = self.curData.result
    for i, resultDetail in ipairs(result) do
        if resultDetail.win == 1 then
            Icon.setHeadIcon(self:getNode("icon_head"..i),self.curData.icon1)
            self:setLabelString("txt_name"..i, self.curData.name1)
        else
            Icon.setHeadIcon(self:getNode("icon_head"..i),self.curData.icon2)
            self:setLabelString("txt_name"..i, self.curData.name2)
        end
    end
end

function ServerBattleLookVideoPanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif string.find(target.touchName, "icon_play") ~= nil then
        local idx = toint(string.sub(target.touchName, string.len("icon_play") + 1))
        local vid = self.curData.result[idx].vid
        local func = function()
            local serverBattleType = gServerBattle.getServerBattleType()
            if serverBattleType == SERVER_BATTLE_TYPE1 then
                local function  callback()
                    if gMainBgLayer == nil then
                        Scene.enterMainScene()
                    end
                    Net.sendWorldWarMatchRecord(gServerBattle.sendMatchType)                 
                end
                Net.sendWorldWarGetInfo(callback)
            elseif serverBattleType == SERVER_BATTLE_TYPE2 then
                local function callback()
                    if gMainBgLayer == nil then
                        Scene.enterMainScene()
                    end
                end
                Net.sendWorldWarMatchRecord(gServerBattle.sendMatchType,callback)
            -- else
            --     Scene.enterMainScene()
            end
        end
         
        Panel.pushRePopupPre(func)
        Net.sendWorldWarVedio(vid, SERVER_BATTLE_RECORD2)
    end
end

return ServerBattleLookVideoPanel