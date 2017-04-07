Unlock.system.shop2 = {}
Unlock.system.shop2.unlockType = SYS_SHOP2;
Unlock.system.shop2.isOpen = false;

function Unlock.system.shop2.isUnlock(isShowNotice)
	
	if (Module.isClose(SWITCH_VIP)) then
		return false;
	end

	local needVip = Data.getCanBuyTimesVip(VIP_SHOP2);
	if Data.getCurVip() >= needVip then

		if Unlock.system.shop2.isOpen == false then
			if isShowNotice then
				local unlockCallback = function ()
					if gIsVipExperTimeOver(VIP_SHOP2) then
						return
					end
					Net.sendShopUnlock(SHOP_TYPE_2);
				end
				local word = gGetWords("unlockWords.plist","unlock_shop2",DB.getClientParam("SHOP2_UNLOCK_PRICE"));
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

function Unlock.system.shop2.show()
	-- Unlock.showMainBgEnter(Unlock.system.act.unlockType,Unlock.system.act.isUnlock());
end
