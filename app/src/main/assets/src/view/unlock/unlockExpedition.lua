Unlock.system.expedition = {}
Unlock.system.expedition.unlockType = SYS_EXPEDITION;

function Unlock.system.expedition.isUnlock(isShowNotice)

	if gUnlockLevel[Unlock.system.expedition.unlockType] and Data.getCurLevel() >= gUnlockLevel[Unlock.system.expedition.unlockType] then
		return true;
	end

	if isShowNotice then
		local word = "";
		if gUnlockLevel[Unlock.system.expedition.unlockType] == nil then
			word = gGetWords("unlockWords.plist","unlock_tip2");
		else
			word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.expedition.unlockType]
				,gGetWords("unlockWords.plist","name"..Unlock.system.expedition.unlockType));
			gShowNotice(word);
		end
		gShowNotice(word);
	end

	return false;
end

function Unlock.system.expedition.show()
	Unlock.showMainBgEnter(Unlock.system.expedition.unlockType,Unlock.system.expedition.isUnlock());
end
