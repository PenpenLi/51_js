Unlock.system.shop = {}
Unlock.system.shop.unlockType = SYS_SHOP;


function Unlock.system.shop.isUnlock(isShowNotice)
	-- if Data.getCurLevel() >= gUnlockLevel[Unlock.system.shop.unlockType] then
	-- 	return true;
	-- end

	-- if isShowNotice then
	-- 	local word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.shop.unlockType]
	-- 		,gGetWords("unlockWords.plist","name"..Unlock.system.shop.unlockType));
	-- 	gShowNotice(word);
	-- end

	-- return false;
	return true;
end

function Unlock.system.shop.show()
	Unlock.showMainBgEnter(Unlock.system.shop.unlockType,Unlock.system.shop.isUnlock());
end

-- function Unlock.system.shop.checkUnlock()

-- 	if Data.getCurLevel() == gUnlockLevel[Unlock.system.shop.unlockType] and not Data.getSysIsUnlock(Unlock.system.shop.unlockType) then
-- 		table.insert(Unlock.stack,Unlock.system.shop.unlockType);
-- 	end

-- end

function Unlock.system.shop.initGuide()

    local guide={}
    guide.id=GUIDE_ID_ENTER_SHOP
    guide.steps={
                {paths={"main_bg",0,"shop_car"},storyid=55}, --主界面副本icon
				}
	table.insert(GuideData.guides,guide);
end

function Unlock.system.shop.guide()

	Guide.dispatch(GUIDE_ID_ENTER_SHOP);
	gMainBgLayer:setRotationPer(50); 
end

function Unlock.system.shop.needUnlockByLevUp(lev)
    if lev == gUnlockLevel[Unlock.system.shop.unlockType] 
        and not Data.getSysIsUnlock(Unlock.system.shop.unlockType) then
        return true
    end
    return false
end
