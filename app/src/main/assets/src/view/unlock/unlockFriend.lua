Unlock.system.friend = {}
Unlock.system.friend.unlockType = SYS_FRIEND;
Unlock.system.friend.Unlockdbid = 16;
local Unlockdbid = Unlock.system.friend.Unlockdbid;
local unlockType = Unlock.system.friend.unlockType;
function Unlock.system.friend.isUnlock(isShowNotice)

    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

    -- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.friend.unlockType] then
    --     return true;
    -- end

    -- if isShowNotice then
    --     local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.friend.unlockType]
    --         ,gGetWords("unlockWords.plist","name"..Unlock.system.friend.unlockType));
    --     gShowNotice(word);
    -- end

    -- return false;
end

function Unlock.system.friend.show()
    Unlock.showMenuEnter(unlockType,Unlock.system.friend.isUnlock());
end

function Unlock.system.friend.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.friend.unlockType] 
	-- 	and not Data.getSysIsUnlock(Unlock.system.friend.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.friend.unlockType);
	-- end

end

function Unlock.system.friend.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_FRIEND
    guide.steps={
    			{paths={"main",0,"btn_friend"},storyid=61}, 
				}
	table.insert(GuideData.guides,guide);
end

function Unlock.system.friend.guide()
	print("Unlock.system.friend.guide");
	Guide.dispatch(GUIDE_ID_ENTER_FRIEND);
end
