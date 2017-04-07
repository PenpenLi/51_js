Unlock.system.risestar = {}
Unlock.system.risestar.unlockType = SYS_TREASURE_RISESTAR;

function Unlock.system.risestar.isUnlock(isShowNotice)

    if Data.getCurLevel() >= gUnlockLevel[Unlock.system.risestar.unlockType] then
        return true;
    end

    if isShowNotice then
        local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.risestar.unlockType]
            ,gGetWords("unlockWords.plist","name"..Unlock.system.risestar.unlockType));
        gShowNotice(word);
    end

    return false;
end
