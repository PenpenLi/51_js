Unlock.system.act = {}
Unlock.system.act.unlockType = SYS_ACT;
local Unlockdbid = 21;
local unlockType = Unlock.system.act.unlockType;
function Unlock.system.act.isUnlock(isShowNotice)

	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

	-- if gUnlockLevel[SYS_ACT_GOLD] and Data.getCurLevel() >= gUnlockLevel[SYS_ACT_GOLD] then
	-- 	return true;
	-- end

	-- if isShowNotice then
	-- 	local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[SYS_ACT_GOLD]
	-- 		,gGetWords("unlockWords.plist","name"..Unlock.system.act.unlockType));
	-- 	gShowNotice(word);
	-- end

	-- return false;
end

function Unlock.system.act.show()
	Unlock.showMainBgEnter(Unlock.system.act.unlockType,Unlock.system.act.isUnlock());
end
