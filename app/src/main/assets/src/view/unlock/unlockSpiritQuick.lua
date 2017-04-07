Unlock.system.spiritQuick = {}
Unlock.system.spiritQuick.unlockType = SYS_SPIRIT_QUICK;

function Unlock.system.spiritQuick.isUnlock(isShowNotice)

	local needVip = Data.getCanBuyTimesVip(VIP_SPIRIT_QUICK);
    local needLev = DB.getSpiritOneKeyLev()

	if Data.getCurVip() >= needVip or
       Data.getCurLevel() >= needLev  then
		return true;
	end

    if isShowNotice then
        local enterPay = function ()
            Panel.popUp(PANEL_PAY);
        end
        local word = gGetWords("unlockWords.plist","unlock_tip_quick_spirit",needLev,needVip);
        gConfirmCancel(word,enterPay);
    end

	return false;
end

function Unlock.system.spiritQuick.show()

end
