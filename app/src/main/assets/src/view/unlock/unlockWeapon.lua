Unlock.system.weapon = {}
Unlock.system.weapon.unlockType = SYS_WEAPON;
Unlock.system.weapon.Unlockdbid = 24;
local Unlockdbid = Unlock.system.weapon.Unlockdbid;
local unlockType = Unlock.system.weapon.unlockType;
function Unlock.system.weapon.isUnlock(isShowNotice)
    
    if(Data.getSysIsUnlock(unlockType))then
        return true;
    end
    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

    -- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.weapon.unlockType] then
    --     return true;
    -- end

    -- if isShowNotice then
    --     local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.weapon.unlockType]
    --         ,gGetWords("unlockWords.plist","name"..Unlock.system.weapon.unlockType));
    --     gShowNotice(word);
    -- end

    -- return false;
end
function Unlock.system.weapon.show()
    Unlock.showMenuEnter(unlockType,Unlock.system.weapon.isUnlock());
end
function Unlock.system.weapon.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.weapon.unlockType] 
	-- 	and not Data.getSysIsUnlock(Unlock.system.weapon.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.weapon.unlockType);
	-- end

end

function Unlock.system.weapon.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.weapon.guideEnter();
    end
end

function Unlock.system.weapon.initGuide()
 
 

    guide={}
    guide.id=GUIDE_ID_ENTER_WEAPON1
    guide.steps={
        {paths={"main",0,"btn_menu"},storyid=170},
        {paths={"main",0,"btn_weapon"}},  
    }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_WEAPON2
    guide.steps={
        {paths={"panel",PANEL_CARD_WEAPON_RAISE,"btn_strong"} ,storyid=171}, 
    }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_WEAPON3
    guide.steps={
        {paths={"panel",PANEL_CARD_WEAPON_RAISE,"btn_view"} ,storyid=172}, 
        {paths={"panel",PANEL_CARD_WEAPON_PREVIEW,"btn_close"} ,storyid=173}, 
    }
    table.insert(GuideData.guides,guide);


    guide={}
    guide.id=GUIDE_ID_ENTER_WEAPON4
    guide.steps={
        {paths={"panel",PANEL_CARD_WEAPON_RAISE,"btn_close"} }, 
    }
    table.insert(GuideData.guides,guide);

end

function Unlock.system.weapon.guide()
    Guide.dispatch(GUIDE_ID_ENTER_WEAPON1); 
    -- Guide.dispatch(GUIDE_ID_ENTER_WEAPON2);
    -- Guide.dispatch(GUIDE_ID_ENTER_WEAPON3); 
    -- Guide.dispatch(GUIDE_ID_ENTER_WEAPON4); 
    -- Guide.dispatch(GUIDE_ID_EQUIP_EXIT);
    -- Guide.dispatch(GUIDE_ID_CARD_LIST_EXIT);
    -- Guide.dispatch(GUIDE_ID_ENTER_MINE1);
    -- Guide.dispatch(GUIDE_ID_ENTER_MINE2);
    -- Guide.dispatch(GUIDE_ID_ENTER_MINE3);
    gMainBgLayer:setRotationPer(20)
end
function Unlock.system.weapon.guideEnter() 
    Guide.dispatch(GUIDE_ID_ENTER_WEAPON3); 
    if(not Data.getSysIsEnter(SYS_MINE))then
        Guide.dispatch(GUIDE_ID_ENTER_WEAPON4);  
        Guide.dispatch(GUIDE_ID_ENTER_MINE1);
    end
    gMainBgLayer:setRotationPer(20)
end