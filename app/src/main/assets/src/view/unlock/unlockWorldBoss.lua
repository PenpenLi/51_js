Unlock.system.worldboss = {}
Unlock.system.worldboss.unlockType = SYS_WORLD_BOSS;
Unlock.system.worldboss.Unlockdbid = 28;
local Unlockdbid = Unlock.system.worldboss.Unlockdbid;
local unlockType = Unlock.system.worldboss.unlockType;
function Unlock.system.worldboss.isUnlock(isShowNotice)

	if(Module.isClose(SWITCH_WORLD_BOSS))then
		if(isShowNotice)then
			gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"));
		end
		return false;
	end

	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);
	
	-- if gUnlockLevel[Unlock.system.worldboss.unlockType] and Data.getCurLevel() >= gUnlockLevel[Unlock.system.worldboss.unlockType] 
	-- 	and not Module.isClose(SWITCH_WORLD_BOSS) then
	-- 	return true;
	-- end

	-- if isShowNotice then
	-- 	local word = "";
	-- 	if gUnlockLevel[Unlock.system.worldboss.unlockType] == nil or Module.isClose(SWITCH_WORLD_BOSS) then
	-- 		word = gGetWords("unlockWords.plist","unlock_tip2");
	-- 	else
	-- 		word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.worldboss.unlockType]
	-- 			,gGetWords("unlockWords.plist","name"..Unlock.system.worldboss.unlockType));
	-- 		gShowNotice(word);
	-- 	end
	-- 	gShowNotice(word);
	-- end

	-- return false;
end

function Unlock.system.worldboss.show()
	Unlock.showMainBgEnter(Unlock.system.worldboss.unlockType,Unlock.system.worldboss.isUnlock());
end
