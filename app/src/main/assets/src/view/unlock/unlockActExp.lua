Unlock.system.actExp = {}
Unlock.system.actExp.unlockType = SYS_ACT_EXP;
Unlock.system.actExp.Unlockdbid = 22;
local Unlockdbid = Unlock.system.actExp.Unlockdbid;
local unlockType = Unlock.system.actExp.unlockType;
function Unlock.system.actExp.isUnlock(isShowNotice)

    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

    -- if gUnlockLevel[Unlock.system.actExp.unlockType] and Data.getCurLevel() >= gUnlockLevel[Unlock.system.actExp.unlockType] then
    --     return true;
    -- end

    -- return false;
end

function Unlock.system.actExp.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.actExp.unlockType] and not Data.getSysIsUnlock(Unlock.system.actExp.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.actExp.unlockType);
	-- end

end

function Unlock.system.actExp.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.actExp.guideEnter();
    end
end

function Unlock.system.actExp.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_ACTEXP
    guide.steps={
    			{paths={"main_bg",0,"fly_build"},storyid=63}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_ACTEXP1
    guide.steps={
                {paths={"panel",PANEL_ACTIVITY,"scroll:scroll/1/bg"}},
                }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_ACTEXP2
    guide.steps={
    			{paths={"panel",PANEL_ACTIVITY,"scroll:scroll/1/bg_btn1"}},
    			-- {paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"}},
				}
	table.insert(GuideData.guides,guide);
end

function Unlock.system.actExp.guide()

	Guide.dispatch(GUIDE_ID_ENTER_ACTEXP);
    gMainBgLayer:setRotationPer(100); 
end
function Unlock.system.actExp.guideEnter()
    Guide.dispatch(GUIDE_ID_ENTER_ACTEXP1);
    Guide.dispatch(GUIDE_ID_ENTER_ACTEXP2);
end
