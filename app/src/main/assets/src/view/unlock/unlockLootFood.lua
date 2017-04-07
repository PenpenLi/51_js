Unlock.system.lootfood = {}
Unlock.system.lootfood.unlockType = SYS_LOOT_FOOD

function Unlock.system.lootfood.isUnlock(isShowNotice)
    if(Module.isClose(SWITCH_LOOT_FOOD))then
        if(isShowNotice)then
            gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"))
        end
        return false
    end

    if Data.getCurLevel() < gLootfoodOpenLv then
    	if(isShowNotice)then
    		gShowNotice(gGetWords("unlockWords.plist","unlock_tip_pos",gLootfoodOpenLv))
    	end
        return false;
    end
    --if isBanshuReview() then return false end
    return true
end
