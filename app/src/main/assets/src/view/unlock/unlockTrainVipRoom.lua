Unlock.system.trainroomvip = {}
Unlock.system.trainroomvip.unlockType = SYS_TRAINVIPROOM;

function Unlock.system.trainroomvip.isUnlock(isShowNotice)

	if (Module.isClose(SWITCH_VIP)) then
		return false;
	end
	
	local needVip = Data.getCanBuyTimesVip(VIP_TRAINROOM);
	print("needVip = "..needVip);
	if Data.getCurVip() >= needVip then
		return true;
	end

	if isShowNotice then
		local enterPay = function ()
			Panel.popUp(PANEL_PAY);
		end
		local word = gGetWords("unlockWords.plist","unlock_vip",needVip);
		gConfirmCancel(word,enterPay);
		-- gShowNotice(word);
	end

	return false;
end

