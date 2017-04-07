Pet={}

function Pet.isSkillUnlock(petid,idx)
    if(idx==1)then
        return true
    end
    local pet=Data.getUserPetById(petid)
    if(pet==nil)then
        return false
    end
     
    if(pet.grade>=idx)then
        return true
    end
    
    return false

end

function Pet.canSkillUpgrade(petid,idx)
   
    local pet=Data.getUserPetById(petid)
    if(pet==nil)then
        return false
    end
    local skillLevel=pet["skillLevel"..idx]
    local maxLevel = math.max(2,math.floor((Data.getCurLevel() - 2)/3));
    if(maxLevel > 20)then
        maxLevel = 20;
    end

    -- 如果灵兽觉醒
    if pet.grade > 5 then
        local petInfo = DB.getPetById(petid)
        local upLev = petInfo.wakeup_bufflvmax
        if idx == 1 then
            upLev = petInfo.wakeup_sklillvmax
        end
        maxLevel = maxLevel + upLev
    end

    return skillLevel < maxLevel;

    -- local levelStep=Pet.convertToGrade(pet.level);--math.floor(pet.level/10)
    -- local skillLevel=pet["skillLevel"..idx]
    -- if(skillLevel<levelStep*2)then
    --     return true
    -- end

    -- return false


end

-- function Pet.getLevelByNextSkillLevel(petid,idx)
--     local pet=Data.getUserPetById(petid)
--     if(pet==nil)then
--         return false
--     end
--     local skillLevel=pet["skillLevel"..idx]
--     return skillLevel*3+2;
-- end

function Pet.convertToGrade(petLevel)
    local grade = math.floor((petLevel-1)/10)+1;
    grade = math.max(1,grade);
    return grade;
end

function Pet.isSatisfyWakeUp(petid)
    local pet=Data.getUserPetById(petid)
    if(pet==nil)then
        return false
    end

    if pet.grade == 5 then
        local needSoulNum=DB.getPetNeedSoulNum(petid,pet.grade)
        if needSoulNum <= 0 then
            return true
        end
    end

    return false
end

function Pet.getPetAwakeLv(petid)
    local pet=Data.getUserPetById(petid)
    if(pet == nil)then
        return 0
    end

    local awakeLv = pet.grade - 5
    if awakeLv < 0 then
        awakeLv = 0
    end

    return awakeLv
end

function Pet.getPetSkinSuff(grade)
    if(grade==nil)then
        return "" 
    elseif(grade>5)then 
        return "_1" 
    end
    return ""
end

function Pet.getPetAwakeLvByGrade(grade)
    local awakeLv = grade - 5
    if awakeLv <= 0 then
        awakeLv = nil
    end

    return awakeLv  
end

function Pet.isAwakeUp(petid)
    local pet=Data.getUserPetById(petid)
    if(pet == nil)then
        return false
    end

    return pet.grade > 5
end
