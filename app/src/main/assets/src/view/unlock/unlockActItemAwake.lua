Unlock.system.actItemAwake = {}
Unlock.system.actItemAwake.unlockType = SYS_ACT_ITEM_AWAKE;
local unlockType = Unlock.system.actItemAwake.unlockType;
function Unlock.system.actItemAwake.isUnlock(isShowNotice)

    if(gUserInfo.level>=gUnlockLevel[SYS_ACT_ITEM_AWAKE])then
        isUnlock = true
    end

    if isUnlock ~=true and  isShowNotice == true then
      local word = gGetWords("unlockWords.plist","unlock_tip_pos",gUnlockLevel[SYS_ACT_ITEM_AWAKE]);
      gShowNotice(word);
   end
   return isUnlock
end

function Unlock.system.actItemAwake.checkUnlock(mapid,stageid)

    -- local isUnlock = Unlock.system.actItemAwake.isUnlock();
    -- if(isUnlock and not Data.getSysIsUnlock(unlockType))then
    --     table.insert(Unlock.stack,unlockType);
    --     Unlock.setSysUnlock(unlockType);
    -- end
end

function Unlock.system.actItemAwake.checkFirstEnter()

end
