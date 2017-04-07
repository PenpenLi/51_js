local UserSetPanel=class("UserSetPanel",UILayer)

function UserSetPanel:ctor(type)
    self:init("ui/ui_user_set.map")
    -- self.isBlackBgVisible=false
    self._panelTop = true
    self.bgVisible = false;
    self.preSysVoiceClose = gSysVoiceClose;

    self:refreshEffect();
    self:refreshSound();
    self:refreshVideo();
    self:refreshVoice();
    self:refreshSet();
    self:hideCloseModule();

    self:replaceLabelString("txt_mem",gGetCurMem(),gGetTotalMem())

    self:initEffectBtn()
end

function UserSetPanel:onPopup()
    print("gCurLanguage = "..gCurLanguage);
    self:setLabelString("txt_lan",gGetWords("languageWord.plist","language"..gCurLanguage));
end

function UserSetPanel:initEffectBtn()
    if(Scene.curSceneEffectLevel==Scene.maxSceneEffectLevel)then
        self:changeTexture("btn8","images/ui_word/set_on.png");
    else
        self:changeTexture("btn8","images/ui_word/set_off.png");
    end
end

function UserSetPanel:hideCloseModule()

    self:getNode("layer_video"):setVisible(not Module.isClose(SWITCH_VIDEO));
    self:getNode("btn_change_lan"):setVisible(gIsMultiLanguage() or not Module.isClose(SWITCH_LANGUAGE));
    self:getNode("layer_voice"):setVisible(youmeIsOpen());
    self:getNode("btn_clean_voice"):setVisible(youmeIsOpen());

    self:resetLayOut();
end

function UserSetPanel:refreshEffect()
    local txtOpen = gGetWords("setWord.plist","open");
    local txtClose = gGetWords("setWord.plist","close");
    if gSysEffectClose then
        self:changeTexture("btn_sound","images/ui_pic1/set_eff2.png");
        self:setLabelString("txt_sound",gGetWords("setWord.plist","5",txtClose));
    else
        self:changeTexture("btn_sound","images/ui_pic1/set_eff1.png");
        self:setLabelString("txt_sound",gGetWords("setWord.plist","5",txtOpen));
    end
end

function UserSetPanel:refreshSound()
    local txtOpen = gGetWords("setWord.plist","open");
    local txtClose = gGetWords("setWord.plist","close");
    if gSysMusicClose then
        self:changeTexture("btn_music","images/ui_pic1/set_music2.png");
        self:setLabelString("txt_music",gGetWords("setWord.plist","4",txtClose));
    else
        self:changeTexture("btn_music","images/ui_pic1/set_music1.png");
        self:setLabelString("txt_music",gGetWords("setWord.plist","4",txtOpen));
    end
end

function UserSetPanel:refreshVideo()
    local txtOpen = gGetWords("setWord.plist","open");
    local txtClose = gGetWords("setWord.plist","close");
    if gSysVideoClose then
        self:changeTexture("btn_video","images/ui_pic1/set_video2.png");
        self:setLabelString("txt_video",gGetWords("setWord.plist","7",txtClose));
    else
        self:changeTexture("btn_video","images/ui_pic1/set_video1.png");
        self:setLabelString("txt_video",gGetWords("setWord.plist","7",txtOpen));
    end

    if(gDebug)then
        gShowMapName = not gSysVideoClose;
        if(gShowMapNamePanel)then
            gShowMapNamePanel:setVisible(gShowMapName);
        end
    end
end

function UserSetPanel:refreshVoice()
    local txtOpen = gGetWords("setWord.plist","open");
    local txtClose = gGetWords("setWord.plist","close");
    if gSysVoiceClose then
        self:changeTexture("btn_voice","images/ui_pic1/set_talk2.png");
        self:setLabelString("txt_voice",gGetWords("setWord.plist","13",txtClose));
    else
        self:changeTexture("btn_voice","images/ui_pic1/set_talk1.png");
        self:setLabelString("txt_voice",gGetWords("setWord.plist","13",txtOpen));
    end
end

function UserSetPanel:refreshSet()
    for key,var in pairs(gSysSet) do
        if var then
            self:changeTexture("btn"..key,"images/ui_word/set_on.png");
        else
            self:changeTexture("btn"..key,"images/ui_word/set_off.png");
        end
    end

    if gMainLayer then
        gMainLayer:refreshBtnChat();
    end
end

function UserSetPanel:onEffect()
    gSysEffectClose = not gSysEffectClose;

    self:refreshEffect();
    Data.saveEffect(gSysEffectClose);
    if( ccs.ArmatureDataManager.setSoundPlay)then
        ccs.ArmatureDataManager:getInstance():setSoundPlay(not  gSysEffectClose)
    end
end

function UserSetPanel:onMusic()
    gSysMusicClose = not gSysMusicClose;
    self:refreshSound();
    Data.saveMusic(gSysMusicClose);

    gSetMusic();

end

function UserSetPanel:onVideo()
    gSysVideoClose = not gSysVideoClose;
    self:refreshVideo();
    Data.saveVideo(gSysVideoClose);
    gSetVideo();
end

function UserSetPanel:onVoice()
    gSysVoiceClose = not gSysVoiceClose;
    self:refreshVoice();
    Data.saveVoice(gSysVoiceClose);
    -- gSetVideo();
end

function UserSetPanel:onCleanVoice()
    youmeCleanData();
end

function UserSetPanel:onSet(index)
    -- body
    gSysSet[index] = not gSysSet[index];
    self:refreshSet();
    Data.saveSet(index,gSysSet[index]);
end

function UserSetPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        if(self.preSysVoiceClose ~= gSysVoiceClose)then
            if(gSysVoiceClose)then --关闭语音
                youmeLogout();
            else -- 打开语音
                youmeLogin(tostring(Data.getCurUserId()),tostring(Data.getCurUserId()),"");
            end
        end
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_music" then
        self:onMusic();
    elseif target.touchName == "btn_sound" then
        self:onEffect();
    elseif target.touchName == "btn_video" then
        self:onVideo();
    elseif target.touchName == "btn_voice" then
        self:onVoice();
    elseif target.touchName == "btn_clean_voice" then
        self:onCleanVoice();
    elseif target.touchName == "btn1" then
        self:onSet(1);
    elseif target.touchName == "btn2" then
        self:onSet(2);
    elseif target.touchName == "btn3" then
        self:onSet(3);
    elseif target.touchName == "btn4" then
        self:onSet(4);
    elseif target.touchName == "btn5" then
        self:onSet(5);
    elseif target.touchName == "btn6" then
        self:onSet(6);
    elseif target.touchName == "btn7" then
        self:onSet(7);
    elseif target.touchName == "btn8" then

        if(Scene.curSceneEffectLevel==Scene.maxSceneEffectLevel)then
            Scene.curSceneEffectLevel=Scene.minSceneEffectLevel
        else
            Scene.curSceneEffectLevel=Scene.maxSceneEffectLevel
        end
        cc.UserDefault:getInstance():setIntegerForKey("sceneEffect",Scene.curSceneEffectLevel)
        cc.UserDefault:getInstance():flush()
        self:initEffectBtn()
        
        gShowNotice(gGetWords("setWord.plist","re_enter"))
    elseif target.touchName == "btn_change_lan" then
        Panel.popUpVisible(PANEL_LANGUAGE_SET,2);
    end
end

return UserSetPanel