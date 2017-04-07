Unlock.system.quickupgrade = {}
Unlock.system.quickupgrade.unlockType = SYS_QUICKUPGRADE;

function Unlock.system.quickupgrade.isUnlock(isShowNotice)

	local needVip = Data.getCanBuyTimesVip(VIP_QUICKUPGRADE);
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

function Unlock.system.quickupgrade.show()
	-- Unlock.showMainBgEnter(Unlock.system.act.unlockType,Unlock.system.act.isUnlock());
end
