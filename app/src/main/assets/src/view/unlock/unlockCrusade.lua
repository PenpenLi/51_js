Unlock.system.crusade = {}
Unlock.system.crusade.unlockType = SYS_CRUSADE;
Unlock.system.crusade.Unlockdbid = 27;
local Unlockdbid = Unlock.system.crusade.Unlockdbid;
local unlockType = Unlock.system.crusade.unlockType;
function Unlock.system.crusade.isUnlock(isShowNotice)

    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

    -- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.crusade.unlockType] then
    --     return true;
    -- end

    -- if isShowNotice then
    --     local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.crusade.unlockType]
    --         ,gGetWords("unlockWords.plist","name"..Unlock.system.crusade.unlockType));
    --     gShowNotice(word);
    -- end

    -- return false;
end

function Unlock.system.crusade.show()
    --Unlock.showMainBgEnter(Unlock.system.crusade.unlockType,Unlock.system.crusade.isUnlock());
end

function Unlock.system.crusade.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

    -- if Data.getCurLevel() == gUnlockLevel[Unlock.system.crusade.unlockType] and not Data.getSysIsUnlock(Unlock.system.crusade.unlockType) then
    --     table.insert(Unlock.stack,Unlock.system.crusade.unlockType);
    -- end

end

function Unlock.system.crusade.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.crusade.guideEnter();
    end
end

function Unlock.system.crusade.initGuide()

    print("Unlock.system.crusade.initGuide");
    local guide={}
    guide.id=GUIDE_ID_ENTER_CRUSADE1 --进入叛军
    guide.steps={
        {paths={"main_bg",0,"panjun"},storyid=169}, --主界面副本icon 
    }
    table.insert(GuideData.guides,guide);
 
    guide={}
    guide.id=GUIDE_ID_ENTER_CRUSADE2
    guide.steps={
                {paths={"panel",PANEL_CRUSADE,"scroll:scroll/0/btn_show"},storyid=215},
                }
    table.insert(GuideData.guides,guide);
end

function Unlock.system.crusade.guide() 
    Guide.dispatch(GUIDE_ID_ENTER_CRUSADE1); 
    gMainBgLayer:setRotationPer(90); 
    Data.redpos.bolCrusadeNum=true
end

function Unlock.system.crusade.guideEnter()
    Guide.dispatch(GUIDE_ID_ENTER_CRUSADE2);
end
