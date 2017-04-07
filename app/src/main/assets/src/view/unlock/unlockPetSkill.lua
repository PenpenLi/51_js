Unlock.system.petSkill = {}
Unlock.system.petSkill.unlockType = SYS_PET_SKILL;

-- function Unlock.system.petSkill.checkUnlock()

-- 	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.petSkill.unlockType] and not Data.getSysIsUnlock(Unlock.system.petSkill.unlockType) then
-- 	-- 	table.insert(Unlock.stack,Unlock.system.petSkill.unlockType);
-- 	-- end

-- end


function Unlock.system.petSkill.checkPetSkillUnlock(data)

	if data.level >= gUnlockLevel[Unlock.system.petSkill.unlockType] and data.level <= gUnlockLevel[Unlock.system.petSkill.unlockType] + 10 and not Data.getSysIsUnlock(Unlock.system.petSkill.unlockType) then
		-- table.insert(Unlock.stack,Unlock.system.petSkill.unlockType);
		-- Unlock.show();
		Unlock.showOtherUnlock(Unlock.system.petSkill.unlockType);
	end
end

function Unlock.system.petSkill.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_PETSKILL --进入竞技场
    guide.steps={
    			{paths={"panel",PANEL_PET,"btn_change"},storyid=72}
				}
	table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_PETSKILL1 --进入竞技场
    guide.steps={
    			{paths={"panel",PANEL_PET,"btn_upgrade"},storyid=73}
				}
	table.insert(GuideData.guides,guide);


end

function Unlock.system.petSkill.guide()

	local panel=Panel.getTopPanel(Panel.popPanels)
	if panel.__panelType == PANEL_PET then
		-- if panel.curPanel==panel:getNode("feed_panel") then
			Guide.dispatch(GUIDE_ID_ENTER_PETSKILL);
		-- end
		Guide.dispatch(GUIDE_ID_ENTER_PETSKILL1);
	end
end