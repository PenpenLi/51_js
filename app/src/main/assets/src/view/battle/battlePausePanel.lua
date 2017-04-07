local BattlePausePanel=class("BattlePausePanel",UILayer)

function BattlePausePanel:ctor(battleLayer)
    self:init("ui/ui_battle_pause.map")

    self.battleLayer=battleLayer
end




function BattlePausePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        self.battleLayer:setPlay()
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_exit" then


        if(Battle.battleType==BATTLE_TYPE_ARENA or
            Battle.battleType==BATTLE_TYPE_CAVE_CHALLENGE or
            Battle.battleType==BATTLE_TYPE_ARENA_LOG  or
            Battle.battleType==BATTLE_TYPE_BATH or
            Battle.battleType==BATTLE_TYPE_TRAIN or
            Battle.battleType==BATTLE_TYPE_CRUSADE or
            Battle.battleType==BATTLE_TYPE_WORLD_BOSS or
            Battle.battleType==BATTLE_TYPE_SERVER_BATTLE or
            Battle.battleType==BATTLE_TYPE_FAMILY_STAGE)then
            gShowNotice(gGetWords("noticeWords.plist","skip_battle_not"  ))
            return
        end

        if(Guide.isForceGuiding())then
            gShowNotice(gGetWords("noticeWords.plist","guide_no_exist"))
        else
            Scene.enterMainScene()
            if (Battle.battleType == BATTLE_TYPE_ATLAS) then
                local mapid = tostring(Net.sendAtlasEnterParam.mapid)
                local stageid = tostring(Net.sendAtlasEnterParam.stageid)
                local type = tostring(Net.sendAtlasEnterParam.type)
                gLogMissionFailed(mapid.."-"..stageid.."-"..type, "giveup")
                local td_param = {}
                td_param['round'] = tostring(gTDParam.battle_round)
                td_param['missionid'] =  mapid.."-"..stageid.."-"..type
                gLogEvent("mission-giveup",td_param)
            end
        end
    end
end

return BattlePausePanel