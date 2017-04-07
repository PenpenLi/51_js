Unlock.system.petTower = {}
Unlock.system.petTower.unlockType = SYS_PET_TOWER;
Unlock.system.petTower.Unlockdbid = 18;
local Unlockdbid = Unlock.system.petTower.Unlockdbid;
local unlockType = Unlock.system.petTower.unlockType;
function Unlock.system.petTower.isUnlock(isShowNotice)

	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

	-- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.petTower.unlockType] then
	-- 	return true;
	-- end

	-- if isShowNotice then
	-- 	local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.petTower.unlockType]
	-- 		,gGetWords("unlockWords.plist","name"..Unlock.system.petTower.unlockType));
	-- 	gShowNotice(word);
	-- end

	-- return false;
end

function Unlock.system.petTower.show()
	Unlock.showMainBgEnter(unlockType,Unlock.system.petTower.isUnlock());
end

function Unlock.system.petTower.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.petTower.unlockType] and not Data.getSysIsUnlock(Unlock.system.petTower.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.petTower.unlockType);
	-- end

end

function Unlock.system.petTower.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.petTower.guideEnter();
    end
end

function Unlock.system.petTower.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_PETTOWER --进入竞技场
    guide.steps={
    			{paths={"main_bg",0,"dixue"},storyid=68}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);

	guide={}
    guide.id=GUIDE_ID_ENTER_PETTOWER1 --进入竞技场
    guide.steps={
    			{paths={"panel",PANEL_PET_TOWER,"btn_fight"}}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);


end

function Unlock.system.petTower.guide()
	Guide.dispatch(GUIDE_ID_ENTER_PETTOWER);
	gMainBgLayer:setRotationPer(50); 
end
function Unlock.system.petTower.guideEnter()
    Guide.dispatch(GUIDE_ID_ENTER_PETTOWER1);
end

function Unlock.system.petTower.needUnlockByLevUp(lev)
    if lev == gUnlockLevel[Unlock.system.petTower.unlockType] 
        and not Data.getSysIsUnlock(Unlock.system.petTower.unlockType) then
        return true
    end
    return false
end
