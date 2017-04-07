Unlock.system.constellation = {}
Unlock.system.constellation.unlockType = SYS_CONSTELLATION

function Unlock.system.constellation.isUnlock(isShowNotice)
	if(Module.isClose(SWITCH_CONSTELLATION))then
		if(isShowNotice)then
			gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"))
		end
		return false
	end
	
	local unlockLv = DB.getConstellationUnlockLv()
	if Data.getCurLevel() < unlockLv then
		if isShowNotice then
	        gShowNotice(gGetWords("unlockWords.plist","unlock_tip_pos",unlockLv))
	    end
	    return false
	end

	return true
end

function Unlock.system.constellation.show()
    Unlock.showMenuEnter(Unlock.system.constellation.unlockType,Unlock.system.constellation.isUnlock());
end

function Unlock.system.constellation.needUnlockByLevUp(lev)
	return true
end
