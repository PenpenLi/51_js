local FirstEnterLayer=class("FirstEnterLayer",UILayer)

function FirstEnterLayer:ctor(type)
    self:init("ui/ui_first_enter.map")

    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    gStopMusic()
    self.curType=type
    local function callback()
        self:finish()
    end

    local fla=FlashAni.new()
    self:getNode("word_container"):addChild(fla)
    if(self.curType==1)then
        loadFlaXml("CG")
        fla:playAction("CG",callback)
        --fla:setSpeedScale(0.6)

        local fla=FlashAni.new()
        self:getNode("word_container"):addChild(fla)
        fla:playAction("CG_TOP")
        gStopMusic()
        --fla:setSpeedScale(0.6)
        if (TDGAMission) then 
            gLogMissionBegin("firstenter")
        end
    else
        loadFlaXml("ui_guide")
        fla:playAction("ui_guide_words2",callback)
    end

end

function FirstEnterLayer:finish()
    if(self.curType==1)then
        gBattleData=Battle.guideBattle("fightScript/battle0.plist")
        Battle.battleType=BATTLE_TYPE_GUIDE
        if(TDGAMission)then
            gLogMissionCompleted("firstenter")
        end
    else
        Scene.enterMainScene()
    end
end

function FirstEnterLayer:onTouchEnded(target)
    if(target.touchName=="btn_close" and self:getNode("btn_close"):getOpacity()==255)then
        gStopMusic()
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        self:finish()
    end
end



return FirstEnterLayer