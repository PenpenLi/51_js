local LanguageSetPanel=class("LanguageSetPanel",UILayer)

LanguageSetPanelData = {};

function LanguageSetPanel:ctor(enter)
    self:init("ui/ui_language_set.map")
    self._panelTop = true
    self.enter = enter;

    if(gDebug==false and gIsMultiLanguage())then
        self:getNode("bg").forceAdapt = true;
        local children = self:getNode("layout"):getChildren();
        for key,child in pairs(children) do
            child:setVisible(false);
        end
        
        self:getNode("lan_zh-hans"):setVisible(true);
        self:getNode("lan_en"):setVisible(true);
    end
    self:resetAdaptNode();
    self:setContentSize(self:getNode("bg"):getContentSize());
end

function LanguageSetPanel:changeLanguage(lan)
    if(gCurLanguage == lan)then
        return;
    end
    
    gLogEvent("language_set",{enter=self.enter,language=lan})
    local callback = function()
        -- Net.sendSystemLanguage(lan);
        Data.saveLanguageSet(lan);
        print("xxxxx");
        if GlobalEvent~=nil and GlobalEvent:sharedGlobalEvent().restartGame then
            print("restartGame");
            GlobalEvent:sharedGlobalEvent():restartGame();
        end
    end
    gConfirmCancel(gGetWords("noticeWords.plist","change_lan"),callback);
end

function LanguageSetPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "lan_zh-hans" then
        self:changeLanguage(LANGUAGE_ZHS);
    elseif target.touchName == "lan_zh-hant" then
        self:changeLanguage(LANGUAGE_ZHT);
    elseif target.touchName == "lan_en" then
        self:changeLanguage(LANGUAGE_EN);
    elseif target.touchName == "lan_vn" then
        self:changeLanguage(LANGUAGE_VN);
    elseif target.touchName == "lan_th" then
        self:changeLanguage(LANGUAGE_TH);
    end
end

return LanguageSetPanel