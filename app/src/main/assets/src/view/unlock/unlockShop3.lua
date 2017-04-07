Unlock.system.shop3 = {}
Unlock.system.shop3.unlockType = SYS_SHOP3;
Unlock.system.shop3.isOpen = false;

function Unlock.system.shop3.isUnlock(isShowNotice)

	if (Module.isClose(SWITCH_VIP)) then
		return false;
	end
	
	local needVip = Data.getCanBuyTimesVip(VIP_SHOP3);
	if Data.getCurVip() >= needVip then

		if Unlock.system.shop3.isOpen == false then
			if isShowNotice then
				local unlockCallback = function ()
					if gIsVipExperTimeOver(VIP_SHOP3) then
						return
					end
					Net.sendShopUnlock(SHOP_TYPE_3);
				end
				local word = gGetWords("unlockWords.plist","unlock_shop3",DB.getClientParam("SHOP3_UNLOCK_PRICE"));
				gConfirmCancel(word,unlockCallback);
			end
			return false;
		end

		return true;
	end

	if isShowNotice then
		local enterPay = function ()
			Panel.popUp(PANEL_PAY);
		end
		local word = gGetWords("unlockWords.plist","unlock_vip3",needVip);
		-- gConfirmCancel(word,enterPay);
		gShowNotice(word);
	end

	return false;
end

function Unlock.system.shop3.show()
	-- Unlock.showMainBgEnter(Unlock.system.act.unlockType,Unlock.system.act.isUnlock());
end
