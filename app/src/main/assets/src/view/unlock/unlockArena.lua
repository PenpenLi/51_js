Unlock.system.arena = {}
Unlock.system.arena.unlockType = SYS_ARENA;
Unlock.system.arena.Unlockdbid = 14;
local Unlockdbid = Unlock.system.arena.Unlockdbid;
local unlockType = Unlock.system.arena.unlockType;
function Unlock.system.arena.isUnlock(isShowNotice)

    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

	-- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.arena.unlockType] then
	-- 	return true;
	-- end

	-- if isShowNotice then
	-- 	local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.arena.unlockType]
	-- 		,gGetWords("unlockWords.plist","name"..Unlock.system.arena.unlockType));
	-- 	gShowNotice(word);
	-- end

	-- return false;
end

function Unlock.system.arena.show()
	Unlock.showMainBgEnter(unlockType,Unlock.system.arena.isUnlock());
end

function Unlock.system.arena.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.arena.unlockType] and not Data.getSysIsUnlock(Unlock.system.arena.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.arena.unlockType);
	-- end

end

function Unlock.system.arena.checkFirstEnter()
	if(not Data.getSysIsEnter(unlockType))then
		Unlock.setSysEnter(unlockType)
		Unlock.system.arena.guideEnter();
	end
end

function Unlock.system.arena.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_ARENA --进入竞技场
    guide.steps={
    			{paths={"main_bg",0,"arena"},storyid=65}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);

	guide={}
    guide.id=GUIDE_ID_ENTER_ARENA1 --进入竞技场
    guide.steps={
    			{paths={"panel",PANEL_ARENA,"touch_role0"}},
    			{paths={"panel",PANEL_FORMATION,"btn_fight"}},
    			 
    			-- {paths={"panel",PANEL_ATLAS_FINAL,"btn_exit"}}, 
				}
	table.insert(GuideData.guides,guide);

	guide={}
    guide.id=GUIDE_ID_ENTER_ARENA4 --出战斗 一键最强
    guide.steps={
    			{paths={"panel",PANEL_ATLAS_FORMATION,"btn_one"},storyid=274},
				}
	table.insert(GuideData.guides,guide);

	guide={}
    guide.id=GUIDE_ID_ENTER_ARENA2 --出战斗 竞技场调整整容
    guide.steps={
    			{paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"}},
				}
	table.insert(GuideData.guides,guide);

	guide={}
    guide.id=GUIDE_ID_ENTER_ARENA3 --出战斗 竞技场调整整容
    guide.steps={
                {paths={"main_bg",0,"arena"},storyid=65}, --主界面副本icon
    			{paths={"panel",PANEL_ARENA,"btn_edit"},storyid=66}
				}
	table.insert(GuideData.guides,guide);

end

function Unlock.system.arena.guide()
	Guide.dispatch(GUIDE_ID_ENTER_ARENA);
	-- Guide.dispatch(GUIDE_ID_ENTER_ARENA1);
	-- Guide.dispatch(GUIDE_ID_ENTER_ARENA2);
	-- Guide.dispatch(GUIDE_ID_ENTER_ARENA3);
	gMainBgLayer:setRotationPer(80); 
end
function Unlock.system.arena.guideEnter()
	Guide.dispatch(GUIDE_ID_ENTER_ARENA1);
	Guide.dispatch(GUIDE_ID_ENTER_ARENA4);
	Guide.dispatch(GUIDE_ID_ENTER_ARENA2);
	Guide.dispatch(GUIDE_ID_ENTER_ARENA3);
end


