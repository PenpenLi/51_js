Unlock.system.skill = {}
Unlock.system.skill.unlockType = SYS_SKILL;
Unlock.system.skill.Unlockdbid = 12;
local Unlockdbid = Unlock.system.skill.Unlockdbid;
local unlockType = Unlock.system.skill.unlockType;
function Unlock.system.skill.isUnlock(isShowNotice)
    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);
end
function Unlock.system.skill.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.skill.unlockType] 
	-- 	and not Data.getSysIsUnlock(Unlock.system.skill.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.skill.unlockType);
	-- end

end

function Unlock.system.skill.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType) and Unlock.isUnlock(SYS_SKILL,false))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.skill.guideEnter();
    end
end

function Unlock.system.skill.initGuide()
    local guide={}
    guide={}
    guide.id=GUIDE_ID_ENTER_SKILL
    guide.steps={
        {paths={"panel",PANEL_UNLOCK,"bg"}}, 
    }
    table.insert(GuideData.guides,guide);
    

    guide={}
    guide.id=GUIDE_ID_ENTER_SKILL1
    guide.steps={
                {paths={"main",0,"btn_menu"}},
    			{paths={"main",0,"btn_hero"},storyid=60}, 
                {paths={"panel",PANEL_CARD,"0_1"}}, 
                {paths={"panel",PANEL_CARD_INFO,"btn_skill"},storyid=165}, 
    			-- {paths={"panel",PANEL_CARD_INFO,"var:skillPanel/scroll:scroll/0/btn_upgrade"}}, 
    			-- {paths={"panel",PANEL_CARD_INFO,"var:skillPanel/btn_buy"}}, 
				}
	table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_SKILL2
    guide.steps={
        {paths={"panel",PANEL_CARD_INFO,"var:skillPanel/scroll:scroll/0/btn_upgrade"},exitEvent=EVENT_ID_GUIDE_FINISH_SKILL_UPGRADE,storyid=166}, 
				}
	table.insert(GuideData.guides,guide);
	

    GuideData.initStoryGuide(GUIDE_ID_ENTER_SKILL3,167)

end
-- function Unlock.system.skill.preGuide() 
--     Guide.changeStack()
--     Guide.dispatch(GUIDE_ID_ENTER_SKILL);
--     Guide.dispatch(GUIDE_ID_ENTER_SKILL1); 
--     Guide.dispatch(GUIDE_ID_ENTER_SKILL2);
--     Guide.dispatch(GUIDE_ID_ENTER_SKILL3);
--     Guide.dispatch(GUIDE_ID_EQUIP_EXIT);
--     Guide.dispatch(GUIDE_ID_CARD_LIST_EXIT);
--     Guide.resetStack()
-- end

function Unlock.system.skill.guide()
    if(gMainMoneyLayer)then
        gMainMoneyLayer:downBtns(); 
    end
    Guide.dispatch(GUIDE_ID_ENTER_SKILL1);
end
function Unlock.system.skill.guideEnter()
    Guide.dispatch(GUIDE_ID_ENTER_SKILL2);
    Guide.dispatch(GUIDE_ID_ENTER_SKILL3);
end
