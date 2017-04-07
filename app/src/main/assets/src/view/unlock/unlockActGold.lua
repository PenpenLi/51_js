Unlock.system.actGold = {}
Unlock.system.actGold.unlockType = SYS_ACT_GOLD;
Unlock.system.actGold.Unlockdbid = 21;
local Unlockdbid = Unlock.system.actGold.Unlockdbid;
local unlockType = Unlock.system.actGold.unlockType;
function Unlock.system.actGold.isUnlock(isShowNotice)

    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

    -- if gUnlockLevel[Unlock.system.actGold.unlockType] and Data.getCurLevel() >= gUnlockLevel[Unlock.system.actGold.unlockType] then
    --     return true;
    -- end

    -- if isShowNotice then
    --     local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.actGold.unlockType]);
    --     gShowNotice(word);
    -- end

    -- return false;
end

function Unlock.system.actGold.show()
    Unlock.showMainBgEnter(unlockType,Unlock.system.actGold.isUnlock());
end

function Unlock.system.actGold.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.actGold.unlockType] and not Data.getSysIsUnlock(Unlock.system.actGold.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.actGold.unlockType);
	-- end

end

function Unlock.system.actGold.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.actGold.guideEnter();
    end
end

function Unlock.system.actGold.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_ACTGOLD
    guide.steps={
    			{paths={"main_bg",0,"fly_build"},storyid=62}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_ACTGOLD1
    guide.steps={
                {paths={"panel",PANEL_ACTIVITY,"scroll:scroll/0/bg"}},
                }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_ACTGOLD2
    guide.steps={
    			{paths={"panel",PANEL_ACTIVITY,"scroll:scroll/0/bg_btn1"}},
    			-- {paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"}},
				}
	table.insert(GuideData.guides,guide);
end

function Unlock.system.actGold.guide()
    Guide.dispatch(GUIDE_ID_ENTER_ACTGOLD);
    gMainBgLayer:setRotationPer(100); 
end
function Unlock.system.actGold.guideEnter()
	Guide.dispatch(GUIDE_ID_ENTER_ACTGOLD1);
	Guide.dispatch(GUIDE_ID_ENTER_ACTGOLD2);
end
