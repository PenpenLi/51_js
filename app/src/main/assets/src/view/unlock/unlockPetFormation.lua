Unlock.system.petFormation = {}
Unlock.system.petFormation.unlockType = SYS_PET_FORMATION;

function Unlock.system.petFormation.checkFirstEnter()
    if Unlock.system.petFormation.isUnlock() and not Data.getSysIsUnlock(Unlock.system.petFormation.unlockType) then
        Unlock.showOtherUnlock(Unlock.system.petFormation.unlockType);
    end
end

function Unlock.system.petFormation.isUnlock()
    if Data.getCurLevel() >= gUnlockLevel[SYS_PET] and #gUserPets > 0 then
        return true;
    end

    return false;
end

function Unlock.system.petFormation.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_PET_FORMATION
    guide.steps={
        {paths={"panel",PANEL_ATLAS_FORMATION,"btn_pet"},storyid=78},
    -- {paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"}},
    }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_PET_FORMATION1
    guide.steps={
        {
            paths={"panel",PANEL_ATLAS_FORMATION,"0_1"},
            hideBlackBg=1,
            enterEvent=GUIDE_EVENT_ID_START_FORMATION,
            exitEvent=GUIDE_EVENT_ID_END_FORMATION,
            dragTarget={"panel",PANEL_ATLAS_FORMATION,"1_6" },
        }
    }
    table.insert(GuideData.guides,guide);


    -- guide={}
    -- guide.id=GUIDE_ID_ENTER_PET_FORMATION2
    -- guide.steps={
    --     {paths={"panel",PANEL_ATLAS_FORMATION,"btn_enter"}}
    -- }
    -- table.insert(GuideData.guides,guide);
end

function Unlock.system.petFormation.guide()
    Guide.dispatch(GUIDE_ID_ENTER_PET_FORMATION);
    Guide.dispatch(GUIDE_ID_ENTER_PET_FORMATION1);
    -- Guide.dispatch(GUIDE_ID_ENTER_PET_FORMATION2);
end