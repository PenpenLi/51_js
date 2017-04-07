Unlock.system.shopsoul = {}
Unlock.system.shopsoul.unlockType = SYS_SHOP_SOUL;

function Unlock.system.shopsoul.isUnlock(isShowNotice)

	if(Module.isClose(SWITCH_SHOP_SOUL))then
		if(isShowNotice)then
			gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"));
		end
		return false;
	end

	return true;
	-- return Unlock.isUnlock(SYS_BOSS_ATLAS,isShowNotice);
	-- return Unlock._isUnlockSysCommon(Unlock.system.bossAtlas.Unlockdbid,SYS_BOSS_ATLAS,isShowNotice);
	-- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.shopsoul.unlockType] then
	-- 	return true;
	-- end

	-- if isShowNotice then
	-- 	local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.shopsoul.unlockType]
	-- 		,gGetWords("unlockWords.plist","name"..Unlock.system.shopsoul.unlockType));
	-- 	gShowNotice(word);
	-- end

	-- return false;

end
