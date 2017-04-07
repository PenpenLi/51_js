Unlock.system.fund = {}
Unlock.system.fund.unlockType = SYS_FUND;

function Unlock.system.fund.isUnlock(isShowNotice)

	local needVip = Data.getCanBuyTimesVip(VIP_FUND);
	print("needVip = "..needVip);
	if gUserInfo.vip >= needVip then
		return true;
	end

	if isShowNotice then

		if(Module.isClose(SWITCH_VIP) == false)then
			return false;
		end

		local enterPay = function ()
			Panel.popUp(PANEL_PAY);
		end
		local word = gGetWords("unlockWords.plist","unlock_vip2",needVip);
		gConfirmCancel(word,enterPay);
		-- gShowNotice(word);
	end

	return false;
end

function Unlock.system.fund.show()
	-- Unlock.showMainBgEnter(Unlock.system.act.unlockType,Unlock.system.act.isUnlock());
end
