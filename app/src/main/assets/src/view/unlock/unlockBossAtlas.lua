Unlock.system.bossAtlas = {}
Unlock.system.bossAtlas.unlockType = SYS_BOSS_ATLAS;
Unlock.system.bossAtlas.Unlockdbid = 30;
local Unlockdbid = Unlock.system.bossAtlas.Unlockdbid;
local unlockType = Unlock.system.bossAtlas.unlockType;
function Unlock.system.bossAtlas.isUnlock(isShowNotice)
    if(Data.getSysIsUnlock(unlockType))then
        return true;
    end
    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

    -- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.bossAtlas.unlockType] then
    --     return true;
    -- end

    -- if isShowNotice then
    --     local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.bossAtlas.unlockType]
    --         ,gGetWords("unlockWords.plist","name"..Unlock.system.bossAtlas.unlockType));
    --     gShowNotice(word);
    -- end

    -- return false;
end

function Unlock.system.bossAtlas.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end
    
    -- if Data.getCurLevel() == gUnlockLevel[Unlock.system.bossAtlas.unlockType] and not Data.getSysIsUnlock(Unlock.system.bossAtlas.unlockType) then
    --     table.insert(Unlock.stack,Unlock.system.bossAtlas.unlockType);
    -- end

end

function Unlock.system.bossAtlas.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_BOSSATLAS
    guide.steps={
        {paths={"main_bg",0,"atlas"},storyid=177}, --主界面副本icon
        {paths={"panel",PANEL_ATLAS,"btn_type7"}},
    }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_BOSSATLAS1
    guide.steps={
        {paths={"panel",PANEL_ATLAS,"scroll:scroll/0/pos1"}},
        {paths={"panel",PANEL_ATLAS_ENTER,"btn_enter"}},
    }
    table.insert(GuideData.guides,guide);


    guide={}
    guide.id=GUIDE_ID_ENTER_BOSSATLAS2 --开始副本
    step1={paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"}}
    guide.steps={step1}
    table.insert(GuideData.guides,guide)
end

function Unlock.system.bossAtlas.guide()

    Guide.dispatch(GUIDE_ID_ENTER_BOSSATLAS);
    Guide.dispatch(GUIDE_ID_ENTER_BOSSATLAS1);
    Guide.dispatch(GUIDE_ID_ENTER_BOSSATLAS2);
    gMainBgLayer:setRotationPer(100);

end

function Unlock.system.bossAtlas.show()
    local panel = Panel.getPanelByType(PANEL_ATLAS);
    if panel then
        local isUnlock = Unlock.system.bossAtlas.isUnlock();
        if not isUnlock then
            panel:getNode("btn_type7"):setVisible(false);
        else
            panel:getNode("btn_type7"):setVisible(true);
        end
        panel:resetLayOut()
    end
end

function Unlock.system.bossAtlas.needUnlockByLevUp(lev)
    if lev == gUnlockLevel[Unlock.system.bossAtlas.unlockType]
        and not Data.getSysIsUnlock(Unlock.system.bossAtlas.unlockType) then
        return true
    end
    return false
end
