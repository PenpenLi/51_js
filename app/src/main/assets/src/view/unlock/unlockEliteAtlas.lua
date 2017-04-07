Unlock.system.eliteAtlas = {}
Unlock.system.eliteAtlas.unlockType = SYS_ELITE_ATLAS;
Unlock.system.eliteAtlas.Unlockdbid = 13;
local Unlockdbid = Unlock.system.eliteAtlas.Unlockdbid;
local unlockType = Unlock.system.eliteAtlas.unlockType;
function Unlock.system.eliteAtlas.isUnlock(isShowNotice)

	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);

	-- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.eliteAtlas.unlockType] then
	-- 	return true;
	-- end

	-- if isShowNotice then
	-- 	local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.eliteAtlas.unlockType]
	-- 		,gGetWords("unlockWords.plist","name"..Unlock.system.eliteAtlas.unlockType));
	-- 	gShowNotice(word);
	-- end

	-- return false;
end

function Unlock.system.eliteAtlas.checkUnlock(mapid,stageid)

    local isUnlock = Unlock._isUnlockSysByAtlas(Unlockdbid,mapid,stageid);
    if(isUnlock and not Data.getSysIsUnlock(unlockType))then
        table.insert(Unlock.stack,unlockType);
        Unlock.setSysUnlock(unlockType);
    end

	-- if Data.getCurLevel() == gUnlockLevel[Unlock.system.eliteAtlas.unlockType] and not Data.getSysIsUnlock(Unlock.system.eliteAtlas.unlockType) then
	-- 	table.insert(Unlock.stack,Unlock.system.eliteAtlas.unlockType);
	-- end

end

function Unlock.system.eliteAtlas.checkFirstEnter()
    if(not Data.getSysIsEnter(unlockType) and Unlock.isUnlock(SYS_ELITE_ATLAS,false))then
        Unlock.setSysEnter(unlockType)
        Unlock.system.eliteAtlas.guideEnter();
    end
end

function Unlock.system.eliteAtlas.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_ELITEATLAS
    guide.steps={
    			-- {paths={"main_bg",0,"atlas"}}, --主界面副本icon
    			{paths={"panel",PANEL_ATLAS,"btn_type1"},storyid=56},
				}
	table.insert(GuideData.guides,guide);

	guide={}
    guide.id=GUIDE_ID_ENTER_ELITEATLAS1
    guide.steps={
    			{paths={"panel",PANEL_ATLAS,"scroll:scroll/0/pos1"},storyid=57},
    			-- {paths={"panel",PANEL_ATLAS_ENTER,"btn_enter"}},
				}
	table.insert(GuideData.guides,guide);
end

function Unlock.system.eliteAtlas.guide()

	Guide.dispatch(GUIDE_ID_ENTER_ELITEATLAS);
	-- Guide.dispatch(GUIDE_ID_ENTER_ELITEATLAS1);
	gMainBgLayer:setRotationPer(100); 
	
end
function Unlock.system.eliteAtlas.guideEnter()
    Guide.dispatch(GUIDE_ID_ENTER_ELITEATLAS1);
end

function Unlock.system.eliteAtlas.show()
	local panel = Panel.getPanelByType(PANEL_ATLAS);
	if panel then
		local isUnlock = Unlock.system.eliteAtlas.isUnlock();
		if not isUnlock then 
			panel:getNode("btn_type1"):setVisible(false);
		else 
			panel:getNode("btn_type1"):setVisible(true);
        end 
		panel:resetLayOut()
	end
end
