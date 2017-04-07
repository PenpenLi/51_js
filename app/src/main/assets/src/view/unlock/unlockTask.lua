Unlock.system.task = {}
Unlock.system.task.unlockType = SYS_TASK;
Unlock.system.task.Unlockdbid = 11;
local Unlockdbid = Unlock.system.task.Unlockdbid;
local unlockType = Unlock.system.task.unlockType;
function Unlock.system.task.isUnlock(isShowNotice)

    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

    -- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.task.unlockType] then
    --     return true;
    -- end

    -- if isShowNotice then
    --     local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.task.unlockType]
    --         ,gGetWords("unlockWords.plist","name"..Unlock.system.task.unlockType));
    --     gShowNotice(word);
    -- end

    -- return false;
end

function Unlock.system.task.show()
    Unlock.showMenuEnter(unlockType,Unlock.system.task.isUnlock());
end

function Unlock.system.task.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.task.unlockType] 
	-- 	and not Data.getSysIsUnlock(Unlock.system.task.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.task.unlockType);
	-- end

end

function Unlock.system.task.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_TASK
    guide.steps={
    			{paths={"main",0,"btn_task"},storyid=59}, 
				}
	table.insert(GuideData.guides,guide);

    GuideData.initStoryGuide(GUIDE_ID_ENTER_TASK1,254)  
    guide={}
    guide.id=GUIDE_ID_ENTER_TASK2
    guide.steps={
                {paths={"panel",PANEL_TASK,"scroll:scroll_task/0/btn_goto"}},
                }
    table.insert(GuideData.guides,guide);
    
end

function Unlock.system.task.guide()
	print("Unlock.system.task.guide");
    Guide.dispatch(GUIDE_ID_ENTER_TASK);
    Guide.dispatch(GUIDE_ID_ENTER_TASK1);
    Guide.dispatch(GUIDE_ID_ENTER_TASK2);
    gMainMoneyLayer:downBtns(); 

end
