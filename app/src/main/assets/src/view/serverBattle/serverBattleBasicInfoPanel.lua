local ServerBattleBasicInfoPanel=class("ServerBattleBasicInfoPanel",UILayer)

function ServerBattleBasicInfoPanel:ctor(battleLayer)
    self:init("ui/ui_serverbattle_basic_info.map")
    self.battleLayer = battleLayer
    self.__tip=true
end

function ServerBattleBasicInfoPanel:events()
    return {

        }
end

function ServerBattleBasicInfoPanel:dealEvent(event, param)

end

function ServerBattleBasicInfoPanel:onTouchEnded(target, touch, event)
    self.battleLayer:setPlay()
    self:onClose()
end

function ServerBattleBasicInfoPanel:onPopback()
    self.battleLayer:setPlay()
end

return ServerBattleBasicInfoPanel
