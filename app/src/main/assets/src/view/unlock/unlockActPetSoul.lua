Unlock.system.actPetSoul = {}
Unlock.system.actPetSoul.unlockType = SYS_ACT_PETSOUL;
Unlock.system.actPetSoul.Unlockdbid = 23;
local Unlockdbid = Unlock.system.actPetSoul.Unlockdbid;
local unlockType = Unlock.system.actPetSoul.unlockType;

function Unlock.system.actPetSoul.isUnlock(isShowNotice)

    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

    -- if gUnlockLevel[Unlock.system.actPetSoul.unlockType] and Data.getCurLevel() >= gUnlockLevel[Unlock.system.actPetSoul.unlockType] then
    --     return true;
    -- end

    -- return false;
end

function Unlock.system.actPetSoul.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.actPetSoul.unlockType] and not Data.getSysIsUnlock(Unlock.system.actPetSoul.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.actPetSoul.unlockType);
	-- end

end

function Unlock.system.actPetSoul.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.actPetSoul.guideEnter();
    end
end

function Unlock.system.actPetSoul.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_ACTPETSOUL
    guide.steps={
    			{paths={"main_bg",0,"fly_build"},storyid=64}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_ACTPETSOUL1
    guide.steps={
                {paths={"panel",PANEL_ACTIVITY,"scroll:scroll/2/bg"}},
                }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_ACTPETSOUL2
    guide.steps={
    			{paths={"panel",PANEL_ACTIVITY,"scroll:scroll/2/bg_btn1"}},
    			-- {paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"}},
				}
	table.insert(GuideData.guides,guide);
end

function Unlock.system.actPetSoul.guide()
	Guide.dispatch(GUIDE_ID_ENTER_ACTPETSOUL);
    gMainBgLayer:setRotationPer(100); 
end
function Unlock.system.actPetSoul.guideEnter()
    Guide.dispatch(GUIDE_ID_ENTER_ACTPETSOUL1);
    Guide.dispatch(GUIDE_ID_ENTER_ACTPETSOUL2);
end