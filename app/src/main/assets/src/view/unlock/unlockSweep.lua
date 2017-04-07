Unlock.system.sweep = {}
Unlock.system.sweep.unlockType = SYS_SWEEP;

function Unlock.system.sweep.isUnlock(isShowNotice)

	if (Module.isClose(SWITCH_VIP)) then
		return false;
	end
	
	local needVip = Data.getCanBuyTimesVip(VIP_SWEEP);
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

function Unlock.system.sweep.show()
	-- Unlock.showMainBgEnter(Unlock.system.act.unlockType,Unlock.system.act.isUnlock());
end
