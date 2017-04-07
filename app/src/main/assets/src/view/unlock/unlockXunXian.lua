Unlock.system.xunxian = {}
Unlock.system.xunxian.unlockType = SYS_XUNXIAN
Unlock.system.xunxian.Unlockdbid = 25;
local Unlockdbid = Unlock.system.xunxian.Unlockdbid;
local unlockType = Unlock.system.xunxian.unlockType;
function Unlock.system.xunxian.isUnlock(isShowNotice)

    if(Data.getSysIsUnlock(unlockType))then
        return true;
    end
    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

	-- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.xunxian.unlockType] then
	-- 	return true
	-- end

	-- if isShowNotice then
	-- 	local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.xunxian.unlockType]
	-- 		,gGetWords("unlockWords.plist","name"..Unlock.system.xunxian.unlockType))
	-- 	gShowNotice(word)
	-- end

	-- return false
end

function Unlock.system.xunxian.show()
    Unlock.showMenuEnter(unlockType,Unlock.system.xunxian.isUnlock());
end

function Unlock.system.xunxian.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

    -- if Data.getCurLevel() == gUnlockLevel[Unlock.system.xunxian.unlockType] 
    --     and not Data.getSysIsUnlock(Unlock.system.xunxian.unlockType) then
    --     table.insert(Unlock.stack,Unlock.system.xunxian.unlockType)
    -- end

end

function Unlock.system.xunxian.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.xunxian.guideEnter();
    end
end

function Unlock.system.xunxian.initGuide()
    local guide={}
    guide.id=GUIDE_ID_ENTER_XUNXIAN
    guide.steps={
                {paths={"main",0,"btn_menu"}},
                {paths={"main",0,"btn_xunxian"},storyid=103}, 
                }
    table.insert(GuideData.guides,guide)

    guide={}
    guide.id=GUIDE_ID_ENTER_XUNXIAN1
    guide.steps={
                {paths={"panel",PANEL_SOULLIFE_FORMATION,"btn_xunxian"}, storyid=104},
                -- {paths={"panel",PANEL_SOULLIFE_FORMATION}, storyid=109},
                }
    table.insert(GuideData.guides,guide)

    guide={}
    guide.id=GUIDE_ID_ENTER_XUNXIAN2
    guide.steps={
                    {paths={"panel",PANEL_SOULLIFE_FORMATION,"btn_find_one"}, storyid=105},
                }
    table.insert(GuideData.guides,guide)

    guide={}
    guide.id=GUIDE_ID_ENTER_XUNXIAN3
    guide.steps={
                    {paths={"panel",PANEL_SOULLIFE_FORMATION,"btn_xunxian"}, storyid=106},
                }
    table.insert(GuideData.guides,guide)

    guide={}
    guide.id=GUIDE_ID_ENTER_XUNXIAN4
    guide.steps={
                    {paths={"panel",PANEL_SOULLIFE_FORMATION,"icon_soullife1"}, storyid=107},
                    {paths={"panel",PANEL_SOULLIFE_EQUIP,"scroll:scroll_equip_items/0/btn_equip"}, storyid=108},
                }
    table.insert(GuideData.guides,guide)

    GuideData.initSmallStoryGuide(GUIDE_ID_ENTER_XUNXIAN5,109,2,PANEL_SOULLIFE_FORMATION)
end

function Unlock.system.xunxian.guide()
    -- print(Unlock.system.xunxian.guide))
    if(gMainMoneyLayer)then
        gMainMoneyLayer:downBtns()
    end
    Guide.dispatch(GUIDE_ID_ENTER_XUNXIAN)
end
function Unlock.system.xunxian.guideEnter()

    Guide.dispatch(GUIDE_ID_ENTER_XUNXIAN1)
    Guide.dispatch(GUIDE_ID_ENTER_XUNXIAN2)
    Guide.dispatch(GUIDE_ID_ENTER_XUNXIAN3)
    Guide.dispatch(GUIDE_ID_ENTER_XUNXIAN4)    
end