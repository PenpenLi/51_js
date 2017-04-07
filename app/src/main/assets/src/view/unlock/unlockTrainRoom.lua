Unlock.system.trainroom = {}
Unlock.system.trainroom.unlockType = SYS_TRAINROOM;
Unlock.system.trainroom.Unlockdbid = 20;
local Unlockdbid = Unlock.system.trainroom.Unlockdbid;
local unlockType = Unlock.system.trainroom.unlockType;
function Unlock.system.trainroom.isUnlock(isShowNotice)

	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

	-- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.trainroom.unlockType] then
	-- 	return true;
	-- end

	-- if isShowNotice then
	-- 	local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.trainroom.unlockType]
	-- 		,gGetWords("unlockWords.plist","name"..Unlock.system.trainroom.unlockType));
	-- 	gShowNotice(word);
	-- end

	-- return false;
end

function Unlock.system.trainroom.show()
	Unlock.showMainBgEnter(unlockType,Unlock.system.trainroom.isUnlock());
end

function Unlock.system.trainroom.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.trainroom.unlockType] and not Data.getSysIsUnlock(Unlock.system.trainroom.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.trainroom.unlockType);
	-- end

end

function Unlock.system.trainroom.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.trainroom.guideEnter();
    end
end

function Unlock.system.trainroom.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_TRAINROOM --进入竞技场
    guide.steps={
    			{paths={"main_bg",0,"shuiche"},storyid=99}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);

	guide={}
    guide.id=GUIDE_ID_ENTER_TRAINROOM1 --进入竞技场
    guide.steps={
    			{paths={"panel",PANEL_TRAINROOM,"btn_room1"},storyid=100},
    			{paths={"panel",PANEL_TRAINROOM_SINGLE,"btn_sit"},storyid=101}
				}
	table.insert(GuideData.guides,guide);

	GuideData.initSmallStoryGuide(GUIDE_ID_ENTER_TRAINROOM2,102,2,PANEL_TRAINROOM)
end

function Unlock.system.trainroom.guide()

	Guide.dispatch(GUIDE_ID_ENTER_TRAINROOM);
	-- Guide.dispatch(GUIDE_ID_ENTER_TRAINROOM1);
	
	gMainBgLayer:setRotationPer(50); 
end
function Unlock.system.trainroom.guideEnter()
    Guide.dispatch(GUIDE_ID_ENTER_TRAINROOM1);
    Guide.dispatch(GUIDE_ID_ENTER_TRAINROOM2);
end

