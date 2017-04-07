
--@% 效果 or @% + @
local type1 = {40001, 40002, 40003, 40004, 40005, 40007, 40008, 40009, 40010, 40011, 40012, 40013, 40014, 40015,40016, 
    40017, 40018, 40019, 40020, 40021, 40022, 40023, 40024, 40025, 40026, 40027, 40029, 40030, 40031,
    40033, 40035, 40036, 40037, 40038, 40039, 40040, 40041, 40043, 40044, 40045, 40046, 40047,
	40049, 40050, 40051, 40052, 40053, 40054, 40055, 40056, 40057, 40058, 40059, 40060, 40061, 40062, 40065, 40067, 40068, 40069, 40070, 40071, 40072, 40073, 40074, 40075, 40076, 40077, 40079, 40080, 40085, 40086, 40087, 40088, 40089, 40090,40091, 40092, 40093,40094,40100, 40101,41001, 41002, 41003,
    41004, 41005, 41006, 43001, 43005, 43006}

--@% + @ + @几率
local type2 = {40032}

--@% + @ + 固定数值buff
local type3 = {40042, 40034, 40048, 43003, 43004}

--很奇怪的
local type4 = {40054, 42000, 42001, 40078}

---全体攻击略微削弱输出，但是显示不改
local type5 = {40028, 40066, 43002, 40006}

local type_pet = {42002, 42003, 42005, 42006, 42007, 42008}

--buff类， @%几率 + 固定数值buff
local buff_type1 = {60011,  60021, 60062, 60073,  60111}

--@%几率
local buff_type2 = {60100, 60107, 60137, 60143, 60166, 60379, 62015, 62016, 62047}

--@%几率 + @% + @
local buff_type3 = {60033, 60082, 60144,60397, 62007,62008, 62011, 62018, 62033, 62041}

--@ 效果 or @ + @
local buff_type4 = {60009, 60012, 60013, 60021, 60022, 60023, 60031, 60032, 60041, 60042, 60043,            60051,  60052, 60053, 60061, 60062, 60063, 60071, 
			60072, 60078, 60079, 60080, 60082, 60083, 60084, 60085, 60086, 60087, 60089, 60090, 60091, 60092, 60093, 60094, 60095, 
			60096, 60097, 60098, 60099, 60101, 60102, 60103, 60105, 60106, 60108, 60109, 60110, 60111, 60112, 60113, 60114, 60115, 60116, 
			60117, 60118, 60119, 60120, 60121, 60122, 60123, 60124, 60125, 60126, 60127, 60128, 60129, 60130, 60131, 60132, 60133, 60134, 60135, 60136, 
			60138, 60139, 60140, 60141, 60142, 60144, 60145, 60146, 60147, 60148, 60149, 60160, 60167, 60168, 60169, 60170,60171, 60172, 60173, 60174, 60175, 60176, 60177, 60178, 60179, 60180, 60181, 60182, 60183, 60184, 60185, 60186, 60187, 60188, 60189, 60190, 60191, 60192, 60193, 61001, 61009, 61014, 61079,  61080, 61081, 61084,61085, 61086, 61090, 61091, 62000, 62001, 62002,62003, 62004, 62005, 62006, 62009,
            62010, 62012, 62013, 62014, 62016, 62017,  62019, 62021, 62022, 62023, 62024, 62025, 62026, 62027, 62028, 62029, 62030, 62031,62032, 62036, 62037, 62038, 62039, 62040,  62042,62044, 62045, 62046, 62048, 62049, 62050, 60393,60394, 60395, 60396, 60401, 60402, 60403, 60404, 60405, 64001, 64002, 64003, 64004, 64005, 64006, 64007, 64008, 64009, 64010, 64011, 64012, 64013, 64014, 60165, 65001, 65002, 65003, 65004, 65005, 65006, 60381, 60387, 60382}
local buff_family = {65007, 65008, 65009, 65010, 65011}
--多buff组合显示
local buff_type5 = {62002, 62012, 62017, 62019, 62022, 62025, 62030, 62032, 62037, 62040, 62041,62044, 62048, 62050}
local buff_cbt = {{62002, 62004},{62012, 62013}, {62017,62018}, {62019, 62016}, {62022, 62023}, {62025, 62026, 62027}, {62030,62029}, { 62032, 62033}, {62037, 62038}, {62040, 62039}, {62041, 62042},{62044,62045}, {62048, 62049},{62050, 62047}}
--军团副本buff组合
local buff_family_stage_fight = {60194,60195,60196,60197}
            
local function isInArray(a, arr)
    if not arr then
        return false
    else
        for k, v in pairs(arr) do
            if v == a then
                return true
            end
        end
    end

    return false
end

local function getCbtBuff(buffid)
    for k, v in pairs(buff_cbt) do
        if v[1] == buffid then
            return v
        end
    end
        
    return 
end

function gGetSkillDesc(db,level,attackParam)
    local ret=""
    local add_level = math.max(0, (level - 1));
    
    --@% + @
    if isInArray(db.skillid, type1) then
        ret=gReplaceParam(db.des, db.percent_value + db.percent_add_value * add_level,
            math.floor(db.attr_value + db.attr_add_value * add_level))
    elseif isInArray(db.skillid, type2) then
        local buffInfo  = DB.getBuffById(db.buff_id0)
        ret=gReplaceParam(db.des, db.percent_value + db.percent_add_value * add_level,
            math.floor(db.attr_value + db.attr_add_value * add_level),
            buffInfo.rate + buffInfo.rate_add * add_level)
    elseif isInArray(db.skillid, type3) then
        local buffInfo  = DB.getBuffById(db.buff_id0)
        if (db.skillid == 40034) then
            ret=gReplaceParam(db.des, db.percent_value + db.percent_add_value * add_level, math.floor(db.attr_value + db.attr_add_value * add_level), 50+add_level*50)
        else
            ret=gReplaceParam(db.des, db.percent_value + db.percent_add_value * add_level,
            math.floor(db.attr_value + db.attr_add_value * add_level),
            math.floor(buffInfo.attr_value0 + buffInfo.attr_add_value0 * add_level))
       end
	elseif isInArray(db.skillid, type4) then
		ret=gReplaceParam(db.des, math.floor(db.attr_value + db.attr_add_value * add_level))
    elseif isInArray(db.skillid, type5) then
        ret = gReplaceParam(db.des, math.floor(db.attr_value + db.attr_add_value * add_level))
    elseif isInArray(db.skillid, type_pet) then
        local base_value = db.percent_value
        if db.skillid == 42005 then
            base_value = db.percent_value + 1
        elseif db.skillid == 42007 then
            base_value = db.percent_value + 2
        end
        ret = gReplaceParam(db.des,(base_value * ((attackParam or 10000) / 10000) + db.percent_add_value * add_level),  math.floor(db.attr_value + db.attr_add_value * add_level))
    else
        local temp_db
        if (db.skillid == 40054) then
            ret=gReplaceParam(db.des, db.attr_value + db.attr_add_value * add_level)
        elseif (db.skillid == 40083) then
            temp_db =  DB.getSkillById(40081)
            ret = gReplaceParam(db.des, temp_db.percent_value + temp_db.percent_add_value * add_level, 
                                math.floor(temp_db.attr_value + temp_db.attr_add_value * add_level), 
                                db.percent_value + db.percent_add_value * add_level,
                                math.floor(db.attr_value + db.attr_add_value * add_level))
        elseif (db.skillid == 40084) then
            temp_db =  DB.getSkillById(40082)
            ret = gReplaceParam(db.des, temp_db.percent_value + temp_db.percent_add_value * add_level, 
                                math.floor(temp_db.attr_value + temp_db.attr_add_value * add_level), 
                                db.percent_value + db.percent_add_value * add_level,
                                math.floor(db.attr_value + db.attr_add_value * add_level))
        else
            ret=db.des
        end
    end

    return ret;
end

-----这个没什么用
function gGetBuffDesc2(db, level)
    local ret = db.des
    local buffid = db.buffid
    local add_level = math.max(0, (level - 1))
	
    if (buffid == 60186) then   
        --吕蒙的buff效果暗改了，但是界面数值不改
        ret = gReplaceParam(db.des, 30 + 30 * add_level, 30 +  30 * add_level);
    elseif (buffid == 61088) then
        ret = gReplaceParam(db.des, db.attr_value0 + db.attr_add_value0 * add_level, db.attr_value1 +  db.attr_add_value1 * add_level);
    elseif (buffid == 62031) then
        ret = gReplaceParam(db.des, db.attr_add_value0 * (level or 1) / 10);
    elseif db.type == 0 and db.skill_range == 0 then
		-- 提升1条自身属性的
		ret = gReplaceParam(db.des, db.attr_value0 + db.attr_add_value0 * add_level, db.attr_value1 +  db.attr_add_value1 * add_level);
	elseif isInArray(buffid, buff_type1) then
		ret = gReplaceParam(db.des, db.rate + db.rate_add * add_level,
            db.attr_value0 +  db.attr_add_value0 * add_level)
	elseif isInArray(buffid, buff_type2) then
		ret = gReplaceParam(db.des, db.rate + db.rate_add * add_level)
	elseif isInArray(buffid, buff_type3) then
		ret = gReplaceParam(db.des, db.rate + db.rate_add * add_level, 
            db.attr_value0 +  db.attr_add_value0 * add_level,
            db.attr_value1 +  db.attr_add_value1 * add_level)
	elseif isInArray(buffid, buff_type4) then
        if (buffid == 62037) then
            ret = gReplaceParam(db.des, 8 +  0.4 * add_level,
            db.attr_value1 +  db.attr_add_value1 * add_level)
        elseif (buffid == 62038) then
            ret = gReplaceParam(db.des, 8 +  0.4 * add_level,
            db.attr_value1 +  db.attr_add_value1 * add_level)
        elseif (buffid == 61090) then
            ret = gReplaceParam(db.des, 5 +  0.08 * add_level,
            db.attr_value1 +  db.attr_add_value1 * add_level)
        else
            ret = gReplaceParam(db.des, db.attr_value0 +  db.attr_add_value0 * add_level,
            db.attr_value1 +  db.attr_add_value1 * add_level)
        end
    end
    
	return ret;
end

function gGetBuffDesc(db,level, level2)

    local ret 
    ret = gGetBuffDesc2(db, level)
    
    if isInArray(db.buffid, buff_family) then
        ret = gReplaceParam(db.des, db.attr_value0 +  db.attr_add_value0 * math.max((level -1), 0),
            db.attr_value1 +  db.attr_add_value1 * math.max(((level2 or 0) - 1),0))
    elseif isInArray(db.buffid, buff_type5) then
        local cbtarray  = getCbtBuff(db.buffid)
        
        if cbtarray then
            ret = "" 
            for k, v in pairs(cbtarray) do
                local cbtInfo  = DB.getBuffById(v)
                local ret1 = gGetBuffDesc2(cbtInfo, level)
                ret = ret..ret1
            end
        end
    elseif isInArray(db.buffid, buff_family_stage_fight) then
        ret = gReplaceParam(db.des, db.attr_value0)
	end
	
	return ret;
end 


	
---------------------------------- 效果文字描述   -----------------------------
-- @%  + @点 or @%
local buff_effect_type1 = {60033, 60073, 60100, 60137, 60143, 60166, 60107, 60379, 60397,62007, 62008, 62011, 62015, 62016, 62018, 62033, 62041, 62047}

function gGetSkillLevelUpDesc(db,level)
    if(db==nil)then
        return  ""
    end
	
    local ret=db.levelup_des or ""
	ret = gReplaceParam(db.levelup_des, math.ceil(db.attr_add_value))
	
    return ret;
end

function gGetBuffLevelUpDesc(db,level) 
    if(db==nil)then
        return  ""
    end
	
    if not db.levelup_des then
		return ""
	end
    

	local ret = db.levelup_des

	if isInArray(db.buffid, buff_effect_type1) then
		ret = gReplaceParam(db.levelup_des, db.rate_add, db.attr_add_value0, db.attr_add_value0, db.attr_add_value1)
	else
		ret = gReplaceParam(db.levelup_des, db.attr_add_value0, db.attr_add_value1)
	end
    
    if db.buffid == 60186 then
        ret = gReplaceParam(db.levelup_des, 30, 30)
    elseif db.buffid == 62031 then
        ret = gReplaceParam(db.levelup_des, db.attr_add_value0 / 10)
    elseif db.buffid == 61088 then
        ret = gReplaceParam(db.levelup_des, db.attr_add_value1 )
    elseif db.buffid == 62037 then
        ret = gReplaceParam(db.levelup_des, 0.4)
    elseif db.buffid == 62038 then
        ret = gReplaceParam(db.levelup_des, 0.4)
    elseif db.buffid == 61090 then
        ret = gReplaceParam(db.levelup_des, 0.08)
    end
	
	if(ret=="0")then
	   ret=""
	end
	
    return ret;
end 