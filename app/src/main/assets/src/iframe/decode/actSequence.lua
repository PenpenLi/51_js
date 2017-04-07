--Sequence(Item 0)
Decode.act.sequence = {};
function Decode.act.sequence.checkType(str)
	-- print("sequence checkType = "..str);
	if Decode.getActType(str) == "Sequence" then
		return true;
	end
	return false;
end

function Decode.act.sequence.create(str)
	local content = Decode.getActContent(str);
	local itemActs = {};
	local items = string.split(content,",");
	-- print_lua_table(items);
	local totaltime = 0;
	for key,var in pairs(items) do
		local act,time = Decode.getActByItemName(var);
		if time == nil then
			time = 0;
		end
		totaltime = totaltime + time;
		table.insert(itemActs,act);
	end
	return cc.Sequence:create(itemActs),totaltime;
end

--Spawn(Item n,Item n)
Decode.act.spawn = {};
function Decode.act.spawn.checkType(str)
	if Decode.getActType(str) == "Spawn" then
		return true;
	end
	return false;
end

function Decode.act.spawn.create(str)
	local content = Decode.getActContent(str);
	local itemActs = {};
	local items = string.split(content,",");
	-- print_lua_table(items);
	local totaltime = 0;
	for key,var in pairs(items) do
		local act,time = Decode.getActByItemName(var);
		if time == nil then
			time = 0;
		end
		if tonum(time) > totaltime then
			totaltime = tonum(time);
		end
		table.insert(itemActs,act);
	end
	return cc.Spawn:create(itemActs),totaltime;
end

-- Speed(Item n,speed)
Decode.act.speed = {};
function Decode.act.speed.checkType(str)
	if Decode.getActType(str) == "Speed" then
		return true;
	end
	return false;
end

function Decode.act.speed.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		local act,time = Decode.getActByItemName(params[1]);
		return cc.Speed:create(act,params[2]),time;
	end
end
