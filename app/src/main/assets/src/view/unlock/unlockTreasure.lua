Unlock.system.treasure = {}
Unlock.system.treasure.unlockType = SYS_TREASURE;
Unlock.system.treasure.Unlockdbid = 33;
local Unlockdbid = Unlock.system.treasure.Unlockdbid;
local unlockType = Unlock.system.treasure.unlockType;
function Unlock.system.treasure.isUnlock(isShowNotice)
    
    if(Module.isClose(SWITCH_TREASURE))then
        if(isShowNotice)then
            gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"));
        end
        return false;
    end

    return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);
 
end
function Unlock.system.treasure.show()
    Unlock.showMenuEnter(unlockType,Unlock.system.treasure.isUnlock());
end
function Unlock.system.treasure.checkUnlock(mapid,stageid)

    if(not Unlock.checkSysSwitch(unlockType))then
        return;
    end

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end 
end
 
 
function Unlock.system.treasure.initGuide()
 
 

    guide={}
    guide.id=GUIDE_ID_ENTER_TREASURE1 
    guide.steps={
                {paths={"main",0,"btn_menu"}},
                {paths={"main",0,"btn_hero"}}, 
                {paths={"panel",PANEL_CARD,"0_1"},storyid=265}, 
        {paths={"panel",PANEL_CARD_INFO,"btn_treasure"},storyid=266},  
    }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_TREASURE2
    guide.steps={
        {paths={"panel",PANEL_CARD_INFO,"var:treasurePanel/var:bagPanel/scroll:bag_scroll/0/touch_node"},storyid=267  }, 
    }
    table.insert(GuideData.guides,guide);

    guide={}
    guide.id=GUIDE_ID_ENTER_TREASURE3
    guide.steps={
        {paths={"panel",TIP_TREASURE,"btn_equip"},storyid=268  },  
    }
    table.insert(GuideData.guides,guide);


    GuideData.initStoryGuide(GUIDE_ID_ENTER_TREASURE4,269) 

end

function Unlock.system.treasure.guide()
    if(gMainMoneyLayer)then
        gMainMoneyLayer:downBtns(); 
    end
    Guide.dispatch(GUIDE_ID_ENTER_TREASURE1);
    Guide.dispatch(GUIDE_ID_ENTER_TREASURE2);
    Guide.dispatch(GUIDE_ID_ENTER_TREASURE3);
    Guide.dispatch(GUIDE_ID_ENTER_TREASURE4);
    
end