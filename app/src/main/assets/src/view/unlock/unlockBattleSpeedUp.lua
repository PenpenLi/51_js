Unlock.system.battleSpeedUp = {}
Unlock.system.battleSpeedUp.unlockType = SYS_BATTLE_SPEEDUP;



function Unlock.system.battleSpeedUp.checkSpeed(speed,isShowNotice)

    if isShowNotice == nil then
        isShowNotice = true;
    end

    local newSpeed = speed;
    if(newSpeed > 3) then
        newSpeed = 1;
    elseif(newSpeed == 2) then
        if(Data.isPassAtlas(1,1,0)==false)then
            newSpeed = 1;
        end
    elseif(newSpeed == 3) then
        if(Data.isPassAtlas(2,1,0)==false)then
            local stage=DB.getStageById(2,1,0)
            if isShowNotice then
                local word = gGetWords("unlockWords.plist","unlock_tip_speed",stage.name,3);
                gShowNotice(word);
            end
            newSpeed = 1;
        end
    end

    return newSpeed;
end

function Unlock.system.battleSpeedUp.initGuide()
 
end

function Unlock.system.battleSpeedUp.guide() 

end