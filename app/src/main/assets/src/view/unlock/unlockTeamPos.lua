Unlock.teamPos = {}

function Unlock.teamPos.isUnlock(pos,isShowNotice)

	pos = pos - 2;
	if pos < 0 or pos > table.getn(gUnlockLevel.posLevel) then
		return true;
	end
	local unlockLevel = toint(gUnlockLevel.posLevel[pos]);
	if Data.getCurLevel() >= unlockLevel then
		return true;
	end

	if isShowNotice then
		local word = gGetWords("unlockWords.plist","unlock_tip",unlockLevel
			,"");
		gShowNotice(word);
	end

	return false;
end