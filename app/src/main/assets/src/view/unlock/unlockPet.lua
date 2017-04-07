Unlock.system.pet = {}
Unlock.system.pet.unlockType = SYS_PET;
Unlock.system.pet.Unlockdbid = 15;
local Unlockdbid = Unlock.system.pet.Unlockdbid;
local unlockType = Unlock.system.pet.unlockType;
function Unlock.system.pet.isUnlock(isShowNotice)

    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

    -- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.pet.unlockType] then
    --     return true;
    -- end

    -- if isShowNotice then
    --     local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.pet.unlockType]
    --         ,gGetWords("unlockWords.plist","name"..Unlock.system.pet.unlockType));
    --     gShowNotice(word);
    -- end

    -- return false;
end

function Unlock.system.pet.show()
    Unlock.showMenuEnter(unlockType,Unlock.system.pet.isUnlock());
end

function Unlock.system.pet.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.pet.unlockType] and not Data.getSysIsUnlock(Unlock.system.pet.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.pet.unlockType);
	-- end

end

function Unlock.system.pet.checkFirstEnter()
    if(not Data.getSysIsEnter(Unlock.system.pet.unlockType))then
        Unlock.setSysEnter(Unlock.system.pet.unlockType)
        Unlock.system.pet.guideEnter();
    end
end

function Unlock.system.pet.initGuide()

    local guide={} 
    guide.id=GUIDE_ID_ENTER_PET_PRE
    guide.steps={
        {paths={"panel",PANEL_UNLOCK,"btn_go"} }
    }
    table.insert(GuideData.guides,guide);
    

    guide={}
    guide.id=GUIDE_ID_ENTER_PET
    guide.steps={
                {paths={"main",0,"btn_menu"}},
    			{paths={"main",0,"btn_pet"},storyid=69},
				}
	table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_PET1
    guide.steps={
                {paths={"panel",PANEL_PET,"btn_unlock"},storyid=70}
                }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_PET2
    guide.steps={
                {paths={"panel",PANEL_PET,"btn_feed1"},storyid=71}
                }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_PET3
    guide.steps={
    			{paths={"panel",PANEL_LEVEL_UP,"varname:layout/3/btn_goto"}},
                {paths={"panel",PANEL_PET,"btn_unlock"}}
				}
	table.insert(GuideData.guides,guide);



end

function Unlock.system.pet.guide()

	Guide.dispatch(GUIDE_ID_ENTER_PET);
    -- Guide.dispatch(GUIDE_ID_ENTER_PET1);
	-- Guide.dispatch(GUIDE_ID_ENTER_PET2);
    gMainMoneyLayer:downBtns(); 
end
function Unlock.system.pet.guideEnter()
    Guide.dispatch(GUIDE_ID_ENTER_PET1);
    Guide.dispatch(GUIDE_ID_ENTER_PET2);
end
function Unlock.system.pet.guideForLevelUp()
    print("Unlock.system.pet.guideForLevelUp");
    Guide.dispatch(GUIDE_ID_ENTER_PET3);
end


Unlock.system.petCave = {}
Unlock.system.petCave.unlockType = SYS_PET_CAVE;
local unlockType = Unlock.system.petCave.unlockType;
function Unlock.system.petCave.isUnlock(isShowNotice)

    if gUnlockLevel[SYS_PET_CAVE] and Data.getCurLevel() >= gUnlockLevel[SYS_PET_CAVE] then
        return true;
    end

    if isShowNotice then
     local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[SYS_PET_CAVE]
         ,gGetWords("unlockWords.plist","name"..Unlock.system.petCave.unlockType));
     gShowNotice(word);
    end

    return false;
end

function Unlock.system.petCave.show()
    Unlock.showMainBgEnter(Unlock.system.petCave.unlockType,Unlock.system.petCave.isUnlock());
end
