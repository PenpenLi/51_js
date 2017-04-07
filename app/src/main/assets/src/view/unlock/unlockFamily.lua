Unlock.system.family = {}
Unlock.system.family.unlockType = SYS_FAMILY;
Unlock.system.family.Unlockdbid = 17;
local Unlockdbid = Unlock.system.family.Unlockdbid;
local unlockType = Unlock.system.family.unlockType;
function Unlock.system.family.isUnlock(isShowNotice)

	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

	-- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.family.unlockType] then
	-- 	return true;
	-- end

	-- if isShowNotice then
	-- 	local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.family.unlockType]
	-- 		,gGetWords("unlockWords.plist","name"..Unlock.system.family.unlockType));
	-- 	gShowNotice(word);
	-- end

	-- return false;
end

function Unlock.system.family.show()
	Unlock.showMainBgEnter(unlockType,Unlock.system.family.isUnlock());
end

function Unlock.system.family.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.family.unlockType] and not Data.getSysIsUnlock(Unlock.system.family.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.family.unlockType);
	-- end

end

function Unlock.system.family.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_FAMILY --进入竞技场
    guide.steps={
    			{paths={"main_bg",0,"family"},storyid=67}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);


end

function Unlock.system.family.guide()
	Guide.dispatch(GUIDE_ID_ENTER_FAMILY);
	gMainBgLayer:setRotationPer(100); 
end
