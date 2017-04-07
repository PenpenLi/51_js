Unlock.system.petStar = {}
Unlock.system.petStar.unlockType = SYS_PET_STAR;

function Unlock.system.petStar.checkpetStarUnlock(data)

	local curSoulNum=Data.getPetSoulsNumById(data.petid);
	-- curSoulNum = 10;
	if curSoulNum >= gUnlockLevel[Unlock.system.petStar.unlockType] and not Data.getSysIsUnlock(Unlock.system.petStar.unlockType) then
		-- table.insert(Unlock.stack,Unlock.system.petStar.unlockType);
		-- Unlock.show();
		Unlock.showOtherUnlock(Unlock.system.petStar.unlockType);
	end
end

function Unlock.system.petStar.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_PETSTAR --进入竞技场
    guide.steps={
    			{paths={"panel",PANEL_PET,"btn_evolve"},storyid=74}
				}
	table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_PETSTAR1 --进入竞技场
    guide.steps={
    			{paths={"panel",PANEL_PET,"btn_upgrade"},storyid=75}
				}
	table.insert(GuideData.guides,guide);


end

function Unlock.system.petStar.guide()

	Guide.dispatch(GUIDE_ID_ENTER_PETSTAR);
	Guide.dispatch(GUIDE_ID_ENTER_PETSTAR1);
	
end