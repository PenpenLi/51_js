Unlock.system.tower = {}
Unlock.system.tower.unlockType = SYS_TOWER;
Unlock.system.tower.Unlockdbid = 32;
local Unlockdbid = Unlock.system.tower.Unlockdbid;
local unlockType = Unlock.system.tower.unlockType;
function Unlock.system.tower.isUnlock(isShowNotice)

	if(Module.isClose(SWITCH_TOWER))then
		if(isShowNotice)then
			gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"));
		end
		return false;
	end
	-- return true;
	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);
end

function Unlock.system.tower.show()
	Unlock.showMainBgEnter(Unlock.system.tower.unlockType,Unlock.system.tower.isUnlock());
end

function Unlock.system.tower.checkUnlock(mapid,stageid)

	if(not Unlock.checkSysSwitch(unlockType))then
		return;
	end

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

end

function Unlock.system.tower.checkFirstEnter()
	if(not Data.getSysIsEnter(SYS_TOWN))then
		Unlock.setSysEnter(SYS_TOWN)
		Unlock.system.tower.guideEnter();
	end
end

function Unlock.system.tower.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_TOWER1 
    guide.steps={
    			{paths={"main_bg",0,"tower"}}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);

	GuideData.initStoryGuide(GUIDE_ID_ENTER_TOWER2,277);
	-- GuideData.initStoryGuide(GUIDE_ID_ENTER_TOWER3,278);
	-- GuideData.initStoryGuide(GUIDE_ID_ENTER_TOWER4,279);
	-- GuideData.initStoryGuide(GUIDE_ID_ENTER_TOWER5,280);

	guide={}
    guide.id=GUIDE_ID_ENTER_TOWER3
    guide.steps={
    			{paths={"panel",PANEL_TOWER,"monster"},storyid=281},
				}
	table.insert(GuideData.guides,guide);

	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER3
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER,"bg_step"},storyid=257},
	-- 			}
	-- table.insert(GuideData.guides,guide);

	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER4
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER,"bg_score"},storyid=258},
	-- 			}
	-- table.insert(GuideData.guides,guide);

	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER5
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER,"btn_right"},storyid=271},
	-- 			}
	-- table.insert(GuideData.guides,guide);

	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER6
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER,"icon_weather"},storyid=260},
	-- 			}
	-- table.insert(GuideData.guides,guide);

	-- GuideData.initStoryGuide(GUIDE_ID_ENTER_TOWER7,261);

	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER8
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER,"btn_right"},storyid=262},
	-- 			}
	-- table.insert(GuideData.guides,guide);
	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER9
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER,"btn_right"}},
	-- 			}
	-- table.insert(GuideData.guides,guide);

	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER15
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER,"btn_right"}},
 --    			{paths={"panel",PANEL_TOWER,"btn_up"}},--不存在的步骤，目的就是为了一直执行上一步
	-- 			}
	-- table.insert(GuideData.guides,guide);

	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER10
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER,"btn_right"},storyid=270},
 --    			{paths={"panel",PANEL_TOWER,"btn_up"},storyid=270},--不存在的步骤，目的就是为了一直执行上一步
	-- 			}
	-- table.insert(GuideData.guides,guide);

	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER12
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER,"btn_right"},storyid=260},
	-- 			}
	-- table.insert(GuideData.guides,guide);

	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER11
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER,"bg_score"},storyid=259},
	-- 			}
	-- table.insert(GuideData.guides,guide);

	-- guide={}
 --    guide.id=GUIDE_ID_ENTER_TOWER13
 --    guide.steps={
 --    			{paths={"panel",PANEL_TOWER_RESULT,"btn_exit"},storyid=272},
	-- 			}
	-- table.insert(GuideData.guides,guide);

	-- --属性面板
	-- GuideData.initStoryGuide(GUIDE_ID_ENTER_TOWER14,273);
end

function Unlock.system.tower.guide()
	Guide.dispatch(GUIDE_ID_ENTER_TOWER1);
	gMainBgLayer:setRotationPer(80); 
end

local function guide1()
	Guide.dispatch(GUIDE_ID_ENTER_TOWER2);
	Guide.dispatch(GUIDE_ID_ENTER_TOWER8);
	Guide.dispatch(GUIDE_ID_ENTER_TOWER3);
	Guide.dispatch(GUIDE_ID_ENTER_TOWER9);
	Guide.dispatch(GUIDE_ID_ENTER_TOWER10);
end

local function guide2()
	Guide.dispatch(GUIDE_ID_ENTER_TOWER4);
	Guide.dispatch(GUIDE_ID_ENTER_TOWER9);
	Guide.dispatch(GUIDE_ID_ENTER_TOWER15);
end

local function guide3()
	Guide.dispatch(GUIDE_ID_ENTER_TOWER11);
	Guide.dispatch(GUIDE_ID_ENTER_TOWER12);
	Guide.dispatch(GUIDE_ID_ENTER_TOWER5);
	Guide.dispatch(GUIDE_ID_ENTER_TOWER13);
end

local function guide4()
	Guide.dispatch(GUIDE_ID_ENTER_TOWER14);
end

function Unlock.system.tower.guideEnter()
	-- Unlock.system.tower.guideByIndex(1);

	Guide.dispatch(GUIDE_ID_ENTER_TOWER2);
	Guide.dispatch(GUIDE_ID_ENTER_TOWER3);
	-- Guide.dispatch(GUIDE_ID_ENTER_TOWER7);
	-- Guide.dispatch(GUIDE_ID_ENTER_TOWER8);
end

function Unlock.system.tower.guideByIndex(index)
	-- print("guide index = "..index);
	if(index == 1)then
		guide1();
	elseif(index == 2)then
		guide2();
	elseif(index == 3)then
		guide3();
	elseif(index == 4)then
		guide4();	
	end
end