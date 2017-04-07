local AttackToTop={ 
    "r10103_1_chunli" 

}

function gIsInAttackToTop(name)
    for key, var in pairs(AttackToTop) do
    	if(var==name)then
    	   return true
    	end
    end
    return false
end

CooperateSkill={ 
    r10003_1_attack_b={
        strEvent="rand_shoot",
        effect="r10003_1_attack_b_10",
        cooperate_role=10013,
        move_time=11,
        param1=0, 
        param2=0, 
        param3=9, 
        param4=2, 
        min_frame=70, 
        max_frame=130,
        level1=10,
        level2=15,
        level3=20,
        level4=35,

    },
    r10001_1_attack_b={
        strEvent="rand_shoot",
        effect="ms002_paodan",
        cooperate_role=10024,
        move_time=10,
        param1=0, 
        param2=0, 
        param3=10, 
        param4=2,
        min_frame=50, 
        max_frame=130,
        rotation=1,
        level1=10,
        level2=15,
        level3=20,
        level4=25,

    },
    r10030_1_attack_b={
        strEvent="rand_shoot",
        effect="r10030_1_attack_b_9",
        cooperate_role=10024,
        move_time=7,
        param1=0, 
        param2=0, 
        param3=0, 
        param4=1,
        min_frame=25, 
        max_frame=140,
        level1=10,
        level2=15,
        level3=20,
        level4=35,

    },
    r10015_1_attack_b={
        strEvent="rand_shoot",
        effect="ms006_shanzi",
        cooperate_role=10026,
        move_time=9,
        param1=0, 
        param2=0, 
        param3=0, 
        param4=1,
        min_frame=30, 
        max_frame=175,
        level1=10,
        level2=15,
        level3=20,
        level4=35,

    },
    r10025_1_attack_b={
        strEvent="rand_shoot",
        effect="ms011_b_wuya",
        cooperate_role=10025,
        move_time=45,
        param1=0, 
        param2=0, 
        param3=0, 
        param4=1,
        min_frame=40, 
        max_frame=130,
        level1=7,
        level2=10,
        level3=15,
        level4=20, 
    },
    r10103_1_attack_b={
        strEvent="rand_shoot",
        effect="ms051_qigongbo_a",
        effect4="ms051_qigongbo_b",
        hitEffect="ms051-washit_pao3",
        cooperate_role=10105,
        move_time=14,
        param1=0, 
        param2=0, 
        param3=0, 
        param4=1, 
        rotation=1,
        min_frame=40, 
        max_frame=150,
        level1=10,
        level2=15,
        level3=20,
        level4=35,
    },


}
