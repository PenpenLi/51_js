local AtlasCompleteCgPanel=class("AtlasCompleteCgPanel",UILayer)

function AtlasCompleteCgPanel:ctor(mapId)
    self:init("ui/ui_atlas_complete_cg.map")
    Guide.pause=true
    self.isBlackBgVisible=false
    self._panelTop = true
    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    gStopMusic()
    self.mapId=mapId

    local function callback()
        self:finish()
    end
    if self.mapId == PRE_ATLAS_XIAMAN_MAPID then
        local fla=FlashAni.new()
        self:getNode("word_container"):addChild(fla)
        loadFlaXml("CG_xiamen")
        fla:playAction("cg_xiamen", callback)

        fla=FlashAni.new()
        self:getNode("word_container"):addChild(fla)
        fla:playAction("CG_TOP2")
        gStopMusic()
    end
end

function AtlasCompleteCgPanel:finish()
    if(self.mapId == PRE_ATLAS_XIAMAN_MAPID)then
        Guide.pause=false
        local curMapid=self.mapId
        self:onClose()
        local panel = Panel.getPanelByType(PANEL_ATLAS)
        if nil ~= panel then
            gAtlas.showCharpterOpen = true
        end
    end
end

function AtlasCompleteCgPanel:onTouchEnded(target)
    if(target.touchName=="btn_close" and self:getNode("btn_close"):getOpacity()==255)then
        gStopMusic()
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        self:finish()
    end
end



return AtlasCompleteCgPanel