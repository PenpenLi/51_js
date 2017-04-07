gAdvanceColor={ 
    "r10013_attack_b" ,
    "s023-a",
    "s023-b",
    "s024-b", 
    "s024-washit-1",
    "s024-a", 
    "ps002-b",
    "ui_draw_card_panel2",
    "r10013_video",
    "r10003_1_c_attacked",
    "xian_npc1_3",
    "xian_npc2_3",
    "xian_npc3_3",
    "xian_npc4_3",
    "xian_npc5_3",
    "ui_wabao_shitouzha_lv",
    "ui_wabao_shitouzha_zijin",
    "card_raise_effect1",
    "card_raise_effect2",
    "card_raise_effect3",
    "card_raise_effect4",
}

gAttackSkillNeedWeapon={
    "r10100_a",
    "s023-a" ,
    "r10103_1_chunli" 
}
gAttackSkillNeedAwake={
    "r10102_attack_x" 
}
gAttackSkillNeedWeaponRole={
    1,
    1,
    2,
}

function gIsAttackSkillNeedAwake(name)
    for key, var in pairs(gAttackSkillNeedAwake) do
        if(var==name)then
            return true,gAttackSkillNeedAwake[key]
        end
    end
    return false,1
end
function gIsAttackSkillNeedWeapon(name)
    for key, var in pairs(gAttackSkillNeedWeapon) do
        if(var==name)then
            return true,gAttackSkillNeedWeaponRole[key]
        end
    end
    return false,1
end

function gIsAdvancedColor(name)
    for key, var in pairs(gAdvanceColor) do
    	if(var==name)then
    	   return true
    	end
    end
    return false
end