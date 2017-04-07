Unlock.system.serverBattle = {}
Unlock.system.serverBattle.unlockType = SYS_SERVER_BATTLE
Unlock.system.serverBattle.Unlockdbid = 29;
local Unlockdbid = Unlock.system.serverBattle.Unlockdbid;
local unlockType = Unlock.system.serverBattle.unlockType;
function Unlock.system.serverBattle.isUnlock(isShowNotice)

	if(Module.isClose(SWITCH_SERVER_BATTLE) or Data.bolOpenServerBattle == false)then
		if(isShowNotice)then
			gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"));
		end
		return false;
	end
	
	return Unlock._isUnlockSysCommon(Unlockdbid,unlockType,isShowNotice);
	
	-- if gUnlockLevel[Unlock.system.serverBattle.unlockType] and Data.getCurLevel() >= gUnlockLevel[Unlock.system.serverBattle.unlockType] 
	-- 	and not Module.isClose(SWITCH_SERVER_BATTLE) then
	-- 	return true
	-- end

	-- if isShowNotice then
	-- 	local word = "";
	-- 	if gUnlockLevel[Unlock.system.serverBattle.unlockType] == nil or Module.isClose(SWITCH_SERVER_BATTLE) then
	-- 		word = gGetWords("unlockWords.plist","unlock_tip2")
	-- 	else
	-- 		word = gGetWords("unlockWords.plist","unlock_tip",gUnlockLevel[Unlock.system.serverBattle.unlockType]
	-- 			,gGetWords("unlockWords.plist","name"..Unlock.system.serverBattle.unlockType))
	-- 	end
	-- 	gShowNotice(word)
	-- end

	-- return false
end

function Unlock.system.serverBattle.show()
	Unlock.showMainBgEnter(Unlock.system.serverBattle.unlockType,Unlock.system.serverBattle.isUnlock())
	--TODO
	-- if nil ~= gMainLayer then
	-- 	local node = gMainLayer:getNode("btn_serverbattle")
	-- 	if nil ~= node then
	-- 		local isUnlock = Unlock.system.serverBattle.isUnlock()
	-- 		if isUnlock then
	-- 			node:removeChildByTag(100)
	-- 			DisplayUtil.removeGray(node)
	-- 		else
	-- 			DisplayUtil.setGray(node)
	-- 			local lock = cc.Sprite:create("images/ui_atlas/ui/lock.png")
	-- 			lock:setScale(0.8)
	-- 			gRefreshNode(node,lock,cc.p(0.75,0.45),cc.p(0,0),100)
	-- 		end
	-- 	end
	-- end
end
