Unlock.system.turnGold = {}
Unlock.system.turnGold.unlockType = SYS_TURN_GOLD;

-- function Unlock.system.turnGold.checkUnlock()

-- 	if Data.getCurLevel() == gUnlockLevel[Unlock.system.turnGold.unlockType] 
-- 		and not Data.getSysIsUnlock(Unlock.system.turnGold.unlockType) then
-- 		table.insert(Unlock.stack,Unlock.system.turnGold.unlockType);
-- 	end

-- end

function Unlock.system.turnGold.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_TURNGOLD
    guide.steps={
    			{paths={"main",0,"btn_get_gold"},storyid=58}, 
    			{paths={"panel",PANEL_BUY_GOLD,"btn_buy_one"}}, 
				}
	table.insert(GuideData.guides,guide);
end

function Unlock.system.turnGold.guide()
	-- print("Unlock.system.turnGold.guide");
	-- Guide.dispatch(GUIDE_ID_ENTER_TURNGOLD);

end