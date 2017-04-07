Unlock.system.chat = {}
Unlock.system.chat.unlockType = SYS_CHAT;

function Unlock.system.chat.isUnlock(isShowNotice)

    if Data.getCurLevel() >= gUnlockLevel[Unlock.system.chat.unlockType] then
        return true;
    end

    if isShowNotice then
        local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.chat.unlockType]
            ,gGetWords("unlockWords.plist","name"..Unlock.system.chat.unlockType));
        gShowNotice(word);
    end

    return false;
end
