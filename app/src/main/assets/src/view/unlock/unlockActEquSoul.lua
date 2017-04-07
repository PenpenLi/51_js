Unlock.system.actEquSoul = {}
Unlock.system.actEquSoul.unlockType = SYS_ACT_EQUSOUL;
Unlock.system.actEquSoul.Unlockdbid = 31;
local Unlockdbid = Unlock.system.actEquSoul.Unlockdbid;
local unlockType = Unlock.system.actEquSoul.unlockType;

function Unlock.system.actEquSoul.isUnlock(isShowNotice)

    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

end

function Unlock.system.actEquSoul.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end


end

function Unlock.system.actEquSoul.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        -- Unlock.system.actEquSoul.guideEnter();
    end
end

function Unlock.system.actEquSoul.initGuide()
    -- print("Unlock.system.actEquSoul.initGuide");
    local guide={}
    guide.id=GUIDE_ID_ENTER_ACTEQUSOUL
    guide.steps={
    			{paths={"main_bg",0,"fly_build"},storyid=253}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_ACTEQUSOUL1
    guide.steps={
                {paths={"panel",PANEL_ACTIVITY,"scroll:scroll/3/bg"}},
                }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_ACTEQUSOUL2
    guide.steps={
    			{paths={"panel",PANEL_ACTIVITY,"scroll:scroll/3/bg_btn1"}},
				}
	table.insert(GuideData.guides,guide);
end

function Unlock.system.actEquSoul.guide()
    -- print("Unlock.system.actEquSoul.guide");
    Guide.dispatch(GUIDE_ID_ENTER_ACTEQUSOUL);
    Guide.dispatch(GUIDE_ID_ENTER_ACTEQUSOUL1);
	Guide.dispatch(GUIDE_ID_ENTER_ACTEQUSOUL2);
    gMainBgLayer:setRotationPer(100); 
end
-- function Unlock.system.actEquSoul.guideEnter()
--     Guide.dispatch(GUIDE_ID_ENTER_ACTEquSOUL1);
--     Guide.dispatch(GUIDE_ID_ENTER_ACTEquSOUL2);
-- end