Unlock.system.treasureHunt = {}
Unlock.system.treasureHunt.unlockType = SYS_TREASURE_HUNT

function Unlock.system.treasureHunt.isUnlock(isShowNotice)
    
    if(Module.isClose(SWITCH_TREASURE_HUNT))then
        if(isShowNotice)then
            gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"))
        end
        return false
    end

    return true
end
