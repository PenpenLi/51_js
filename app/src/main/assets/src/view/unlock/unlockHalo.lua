Unlock.system.halo = {}
Unlock.system.halo.unlockType = SYS_HALO;
Unlock.system.halo.Unlockdbid = 34;
local Unlockdbid = Unlock.system.halo.Unlockdbid;
local unlockType = Unlock.system.halo.unlockType;
function Unlock.system.halo.isUnlock(isShowNotice)

	if(Module.isClose(SWITCH_HALO))then
		if(isShowNotice)then
			gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"));
		end
		return false;
	end
	-- return true;
	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);
end

-- function Unlock.system.halo.show()
-- 	Unlock.showMainBgEnter(Unlock.system.halo.unlockType,Unlock.system.halo.isUnlock());
-- end

function Unlock.system.halo.checkUnlock(mapid,stageid)

	if(not Unlock.checkSysSwitch(unlockType))then
		return;
	end

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

end

function Unlock.system.halo.checkFirstEnter()
	if(not Data.getSysIsEnter(unlockType))then
		Unlock.setSysEnter(unlockType)
		Unlock.system.halo.guideEnter();
	end
end

function Unlock.system.halo.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_HALO1 
    guide.steps={
    			{paths={"main",0,"btn_family_skill"},storyid=263}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);

	GuideData.initStoryGuide(GUIDE_ID_ENTER_HALO2,264);

end

function Unlock.system.halo.guide()
	Guide.dispatch(GUIDE_ID_ENTER_HALO1);
	Guide.dispatch(GUIDE_ID_ENTER_HALO2);
end

function Unlock.system.halo.guideEnter()
	Guide.clearGuide()
	Guide.dispatch(GUIDE_ID_ENTER_HALO2);
end