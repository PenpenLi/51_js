Unlock.system.battleAuto = {}
Unlock.system.battleAuto.unlockType = SYS_BATTLE_AUTO;

function Unlock.system.battleAuto.checkAutoUnlock()
    return false
--[[
	if Guide.isGuiding() then
		return;
	end

	if Data.getCurLevel() >= toint(gUnlockLevel[Unlock.system.battleAuto.unlockType])
		and not Data.getSysIsUnlock(Unlock.system.battleAuto.unlockType) then
		Unlock.showOtherUnlock(Unlock.system.battleAuto.unlockType);
	end
]]
end

function Unlock.system.battleAuto.isUnlock(isShowNotice)
	--[[
	if Data.getCurLevel() >= gUnlockLevel[Unlock.system.battleAuto.unlockType] then
		return true;
	end

	if isShowNotice then
		local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.battleAuto.unlockType]
			,gGetWords("unlockWords.plist","name"..Unlock.system.battleAuto.unlockType));
		gShowNotice(word);
	end

	return false;	
	]]
	return true
end

function Unlock.system.battleAuto.initGuide()
--[[
    local guide={}
    guide.id=GUIDE_ID_ENTER_BATTLEAUTO
    guide.steps={
    			{paths={"battle",0,"btn_auto"},storyid=89}, 
				}
	table.insert(GuideData.guides,guide);
	]]
end

function Unlock.system.battleAuto.guide()
	print("Unlock.system.battleAuto.guide");
	--Guide.dispatch(GUIDE_ID_ENTER_BATTLEAUTO);

end