LocalNotify = {}

function LocalNotify.setHpFull()
    print ("setHpFull")
    LocalNotification:shared():clearListById(Pushset_HpFull_Open)
    if (gSysSet[Pushset_HpFull_Open] == false) then
        return
    end
    local iCurEng = gUserInfo.energy
    local iMaxEng = Data.getMaxEnergy()

    if iCurEng >= iMaxEng then
        return
    end
    
    print ("calc hp-dis~")
    local energy_recovery_time = DB.getEnergyCheckTime()
    print ("energy_recovery_time:" .. energy_recovery_time)
    local dis = Data.energyTime + energy_recovery_time - gGetCurServerTime()
    dis =  dis + (iMaxEng - iCurEng -1) * energy_recovery_time
    --dis = 10
    print ("dis:" .. dis)
    if (gSysSet[Pushset_Undisturb_open] == true) then
        local wakeTime = dis + gGetCurServerTime()
        print ("wakeTime" .. wakeTime)
        local wakeHour = gGetDate("%H", wakeTime)
        print ("wakeHour:" .. wakeHour)
        if (tonumber(wakeHour) < 8) then
            return
        end
    end

    if (dis <= 0) then
        return
    end

    print ("hp-dis:" .. dis)

    --local sWord = "主公，您的体力已满了，快去挥霍吧！"
    local sWord = gGetWords("notifyWords.plist","hpfull");
    LocalNotification:shared():createNotification("", sWord, dis, false, Pushset_HpFull_Open, true)
end

function LocalNotify.setSkillFull()
    print ("setSkillFull")
    LocalNotification:shared():clearListById(Pushset_SkillFull_Open)
    if (gSysSet[Pushset_SkillFull_Open] == false) then
        return
    end
    --gUserInfo.skillPoint>=Data.vip.skillpot.maxSkillPoint()
    local iCurPoint = gUserInfo.skillPoint
    local iMaxPoint = Data.vip.skillpot.maxSkillPoint()

    if iCurPoint >= iMaxPoint then
        return
    end
    
    print ("calc skill-dis~")
    local skill_recovery_time = DB.getSkillPointTime()
    local dis = Data.skillPointTime + skill_recovery_time - gGetCurServerTime()
    print ("dis:" .. dis)
    dis =  dis + (iMaxPoint - iCurPoint -1) * skill_recovery_time
    --dis = 10
    

    if (gSysSet[Pushset_Undisturb_open] == true) then
        local wakeTime = dis + gGetCurServerTime()
        print ("wakeTime" .. wakeTime)
        local wakeHour = gGetDate("%H", wakeTime)
        print ("wakeHour:" .. wakeHour)
        if (tonumber(wakeHour) < 8) then
            return
        end
    end
    
    if (dis <= 0) then
        return
    end

    print ("skill-dis:" .. dis)

    --local sWord = "主公，您的体力已满了，快去挥霍吧！"
    local sWord = gGetWords("notifyWords.plist","skillfull");
    LocalNotification:shared():createNotification("", sWord, dis, false, Pushset_SkillFull_Open, true)
end

function LocalNotify.getDisTimeFrom(iSecond, nextDay)
    local hour = gGetDate("%H", gGetCurServerTime())
    local min = gGetDate("%M", gGetCurServerTime())
    local sec = gGetDate("%S", gGetCurServerTime())
    local serverTime = hour*60*60 + min*60 + sec

    local dis = iSecond - serverTime    
    dis = dis + 24*60*60 * nextDay
    
    if (dis < 0) then 
        dis = dis + 24*60*60
    end
    return dis
end

function LocalNotify.setEatTime(value, idx)
    print ("setEatTime:" .. tostring(idx))
    LocalNotification:shared():clearListById(idx)
    if (gSysSet[idx] == false) then
        return
    end
    --local sWord = "开饭啦！热腾腾的包子已为您备好了，快去领取吧！"

    local sWord = gGetWords("notifyWords.plist","eat12")
    if (idx == Pushset_HpGet18_Open) then
        sWord = gGetWords("notifyWords.plist","eat18")
    end
    if (idx == Pushset_HpGet21_Open) then
        sWord = gGetWords("notifyWords.plist","eat21")
    end
    local dis = LocalNotify.getDisTimeFrom(value*60*60, 0)
    print ("dis:" .. dis)
    LocalNotification:shared():createNotification("", sWord, dis, false, idx)
end

function LocalNotify.setWorldBossTime(value, idx)
    print ("setWorldBossTime>>>")
    print ("unlock level:" .. tostring(gUnlockLevel[Unlock.system.worldboss.unlockType]))
    if gUserInfo.level < gUnlockLevel[Unlock.system.worldboss.unlockType] then
        return
    end

    LocalNotification:shared():clearListById(idx)
    if (gSysSet[idx] == false) then
        return
    end

    local weekday = gGetDate("%w",gGetCurServerTime())
    print ("===weekday:" .. weekday)
    
    weekday = toint(weekday)
    local dis = LocalNotify.getDisTimeFrom(value, 0) 
    if (weekday == 2) then
        dis = LocalNotify.getDisTimeFrom(value, 3)
    elseif (weekday == 3) then
        dis = LocalNotify.getDisTimeFrom(value, 2)
    elseif (weekday == 4) then
        dis = LocalNotify.getDisTimeFrom(value, 1)
    elseif (weekday == 6) then
        dis = LocalNotify.getDisTimeFrom(value, 2)
    elseif (weekday == 0) then
        dis = LocalNotify.getDisTimeFrom(value, 1)
    end
    print ("dis:" .. tostring(dis))

    local sWord = gGetWords("notifyWords.plist","worldboss1")
    if (idx == Pushset_WorldBoss_Open_2) then
        sWord = gGetWords("notifyWords.plist","worldboss2")
    elseif (idx == Pushset_WorldBoss_Open_3) then
        sWord = gGetWords("notifyWords.plist","worldboss3")
    end  
    print (sWord)

    LocalNotification:shared():createNotification("", sWord, dis, false, idx, true)
end



function LocalNotify.setWishTime(value)
    -- local sWord = "亲爱的玩家，你忘记昨天许下的愿望了吗？等你来领哦！"
    local sWord = gGetWords("notifyWords.plist","wish");
    local dis = LocalNotify.getDisTimeFrom(value*60*60,1)
    print ("dis:" .. dis)
    LocalNotification:shared():createNotification("", sWord, dis, false, Pushset_WishGet_Open, true)
end

function LocalNotify.setGameWish()
    LocalNotification:shared():clearListById(Pushset_WishGet_Open)
    LocalNotify.setWishTime(10)
    LocalNotify.setWishTime(14)
    LocalNotify.setWishTime(19)
end

function LocalNotify.clearGameWish()
    LocalNotification:shared():clearListById(Pushset_WishGet_Open)
end

--gUnlockLevel[Unlock.system.worldboss.unlockType]

function LocalNotify.setGameEnter()
end

function LocalNotify.setupNotify()
    --未登录
    if (gUserInfo.energy == nil) then
        return
    end

    LocalNotify.setEatTime(9, Pushset_HpGet12_Open)
    LocalNotify.setEatTime(12, Pushset_HpGet18_Open)
    LocalNotify.setEatTime(18, Pushset_HpGet21_Open)
    --LocalNotify.setWorldBossTime(20*60*60 - 10*60, Pushset_WorldBoss_Open_1)
    LocalNotify.setWorldBossTime(20*60*60 - 5*60, Pushset_WorldBoss_Open_2)
    --LocalNotify.setWorldBossTime(20*60*60, Pushset_WorldBoss_Open_3)
    LocalNotify.setHpFull()
    LocalNotify.setSkillFull()

end 
