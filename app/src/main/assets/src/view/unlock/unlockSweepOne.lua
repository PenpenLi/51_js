Unlock.system.sweepone = {}
Unlock.system.sweepone.unlockType = SYS_SWEEP_ONE;
Unlock.system.sweepone.Unlockdbid = 26;
local Unlockdbid = Unlock.system.sweepone.Unlockdbid;
local unlockType = Unlock.system.sweepone.unlockType;

function Unlock.system.sweepone.isUnlock(isShowNotice)
	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);
end

function Unlock.system.sweepone.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end
end

function Unlock.system.sweepone.show()
	local panel = Panel.getPanelByType(PANEL_ATLAS_ENTER);
	if panel then
		local isUnlock = Unlock.system.sweepone.isUnlock();
		if not isUnlock then 
			panel:getNode("panel_auto"):setVisible(false);
		else 
			panel:getNode("panel_auto"):setVisible(true);
        end 
	end
end


function Unlock.system.sweepone.initGuide()
    local guide={}
    guide={}
    guide.id=GUIDE_ID_ENTER_SWEEP
    guide.steps={
        {paths={"panel",PANEL_ATLAS,"scroll:scroll/0/pos1"},storyid=178},
        {paths={"panel",PANEL_ATLAS_ENTER,"btn_auto"}},
        {paths={"panel",PANEL_ATLAS_AUTO,"btn_close"}},
        
    }
    table.insert(GuideData.guides,guide);
    

    guide={}
    guide.id=GUIDE_ID_ENTER_SWEEP1
    guide.steps={
                {paths={"panel",PANEL_ATLAS_ENTER,"btn_close"},exitEvent=EVENT_ID_GUIDE_EXIT_SWEEP},
				}
	table.insert(GuideData.guides,guide);

end
function Unlock.system.sweepone.guide()
	gDispatchEvt(EVENT_ID_GUIDE_ENTER_SWEEP)
    Guide.dispatch(GUIDE_ID_ENTER_SWEEP);
    Guide.dispatch(GUIDE_ID_ENTER_SWEEP1);
end