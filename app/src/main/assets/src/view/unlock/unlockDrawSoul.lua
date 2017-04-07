Unlock.system.drawsoul = {}
Unlock.system.drawsoul.unlockType = SYS_DRAWSOUL

function Unlock.system.drawsoul.isUnlock(isShowNotice)
    if isBanshuUser() then
        return false
    end
    local needVip = Data.getCanBuyTimesVip(VIP_DRAWCARD_SOUL);
    -- needVip = 20;
    -- print("needVip = "..needVip);
    if Data.getCurVip() >= needVip then
        return true;
    end

    if isShowNotice then
        local enterPay = function ()
            Panel.popUp(PANEL_PAY);
        end
        local word = gGetWords("unlockWords.plist","unlock_vip",needVip);
        gConfirmCancel(word,enterPay);
    end

    return false;
end

