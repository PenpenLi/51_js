Unlock.system.mineProj2 = {}
Unlock.system.mineProj2.unlockType = SYS_MINE_PROJ2

function Unlock.system.mineProj2.isUnlock(isShowNotice)

	local needVip = Data.vip.mineProj2.getMaxUseTimes()
	if Data.getCurVip() >= needVip then
		return true;
	end

	if isShowNotice then
		local enterPay = function ()
			Panel.popUp(PANEL_PAY)
		end
		local word = gGetWords("unlockWords.plist","unlock_vip",needVip)
		gConfirmCancel(word,enterPay)
	end

	return false
end


Unlock.system.mineProj3 = {}
Unlock.system.mineProj3.unlockType = SYS_MINE_PROJ3

function Unlock.system.mineProj3.isUnlock(isShowNotice)

	local needVip = Data.vip.mineProj3.getMaxUseTimes()
	if Data.getCurVip() >= needVip then
		return true;
	end

	if isShowNotice then
		local enterPay = function ()
			Panel.popUp(PANEL_PAY)
		end
		local word = gGetWords("unlockWords.plist","unlock_vip",needVip)
		gConfirmCancel(word,enterPay)
	end

	return false
end

Unlock.system.mineProj4 = {}
Unlock.system.mineProj4.unlockType = SYS_MINE_PROJ4

function Unlock.system.mineProj4.isUnlock(isShowNotice)

	local needVip = Data.vip.mineProj4.getMaxUseTimes()
	if Data.getCurVip() >= needVip then
		return true;
	end

	if isShowNotice then
		local enterPay = function ()
			Panel.popUp(PANEL_PAY)
		end
		local word = gGetWords("unlockWords.plist","unlock_vip",needVip)
		gConfirmCancel(word,enterPay)
	end

	return false
end

Unlock.system.mineProj5 = {}
Unlock.system.mineProj5.unlockType = SYS_MINE_PROJ5

function Unlock.system.mineProj5.isUnlock(isShowNotice)

	local needVip = Data.vip.mineProj5.getMaxUseTimes()
	if Data.getCurVip() >= needVip then
		return true;
	end

	if isShowNotice then
		local enterPay = function ()
			Panel.popUp(PANEL_PAY)
		end
		local word = gGetWords("unlockWords.plist","unlock_vip",needVip)
		gConfirmCancel(word,enterPay)
	end

	return false
end

