Unlock.system.bath = {}
Unlock.system.bath.unlockType = SYS_BATH;
Unlock.system.bath.Unlockdbid = 19;
local Unlockdbid = Unlock.system.bath.Unlockdbid;
local unlockType = Unlock.system.bath.unlockType;
function Unlock.system.bath.isUnlock(isShowNotice)

    if(Module.isClose(SWITCH_BATH))then
        if(isShowNotice)then
            gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"));
        end
        return false;
    end

	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

	-- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.bath.unlockType] then
	-- 	return true;
	-- end

	-- if isShowNotice then
	-- 	local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.bath.unlockType]
	-- 		,gGetWords("unlockWords.plist","name"..Unlock.system.bath.unlockType));
	-- 	gShowNotice(word);
	-- end

	-- return false;
end

function Unlock.system.bath.show()
	Unlock.showMainBgEnter(unlockType,Unlock.system.bath.isUnlock());
end

function Unlock.system.bath.checkUnlock(mapid,stageid)
    if Module.isClose(SWITCH_BATH) then
        return
    end

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.bath.unlockType] and not Data.getSysIsUnlock(Unlock.system.bath.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.bath.unlockType);
	-- end

end

function Unlock.system.bath.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.bath.guideEnter();
    end
end

function Unlock.system.bath.initGuide()

	print("Unlock.system.bath.initGuide");
    local guide={}
    guide.id=GUIDE_ID_ENTER_BATH --进入竞技场
    guide.steps={
    			{paths={"main_bg",0,"feichuan"},storyid=95}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);

	guide={}
    guide.id=GUIDE_ID_ENTER_BATH1 --进入竞技场
    guide.steps={
    			{paths={"panel",PANEL_BATH,"btn_wash"}},
    			{paths={"panel",PANEL_BATH_DETAIL,"btn_refresh"},storyid=96},
				}
	table.insert(GuideData.guides,guide);

	guide={}
    guide.id=GUIDE_ID_ENTER_BATH2
    guide.steps={
    			{paths={"panel",PANEL_BATH_DETAIL,"btn_ok"},storyid=97}
				}
	table.insert(GuideData.guides,guide);


end

function Unlock.system.bath.guide()
	-- print("Unlock.system.bath.guide");
	Guide.dispatch(GUIDE_ID_ENTER_BATH);
	-- Guide.dispatch(GUIDE_ID_ENTER_BATH1);
	gMainBgLayer:setRotationPer(50); 
end
function Unlock.system.bath.guideEnter()
    Guide.dispatch(GUIDE_ID_ENTER_BATH1);
    Guide.dispatch(GUIDE_ID_ENTER_BATH2);
end
