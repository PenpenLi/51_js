Unlock.system.atlasBox = {}
Unlock.system.atlasBox.unlockType = SYS_ATLAS_BOX;

function Unlock.system.atlasBox.checkatlasBoxUnlock(canGet)

	-- local curSoulNum=Data.getPetSoulsNumById(data.petid);
	-- curSoulNum = 10;
	if canGet and not Data.getSysIsUnlock(Unlock.system.atlasBox.unlockType) then
		-- table.insert(Unlock.stack,Unlock.system.atlasBox.unlockType);
		-- Unlock.show();
		Unlock.showOtherUnlock(Unlock.system.atlasBox.unlockType);
	end
end

function Unlock.system.atlasBox.initGuide()
--[[
    local guide={}
    guide.id=GUIDE_ID_ENTER_ATLASBOX --进入竞技场
    guide.steps={
    			{paths={"panel",PANEL_ATLAS,"btn_box1"},storyid=76},
    			{paths={"panel",PANEL_ATLAS_REWARD_BOX,"btn_get"}}
				}
	table.insert(GuideData.guides,guide);

]]
end

function Unlock.system.atlasBox.guide()

--	Guide.dispatch(GUIDE_ID_ENTER_ATLASBOX);
	
end