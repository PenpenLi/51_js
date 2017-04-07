--MoveBy(0.2,{100,0})
Decode.act.moveBy = {}
function Decode.act.moveBy.checkType(str)
	-- print("moveby checkType = "..str);
	if Decode.getActType(str) == "MoveBy" then
		return true;
	end
	return false;
end

function Decode.act.moveBy.create(str)
	local content = Decode.getActContent(str);
	local index = string.find(content,",");
	if index then
		local time = string.sub(content,1,index-1);
		local posStr = string.sub(content,index+2,-2);
		local pos = string.split(posStr,",");
		-- print("moveby time = "..time);
		return cc.MoveBy:create(time,cc.p(pos[1],pos[2])),time;
	end
end


--MoveTo(0.2,{100,0})
Decode.act.moveTo = {}
function Decode.act.moveTo.checkType(str)
	if Decode.getActType(str) == "MoveTo" then
		return true;
	end
	return false;
end

function Decode.act.moveTo.create(str)
	local content = Decode.getActContent(str);
	local index = string.find(content,",");
	if index then
		local time = string.sub(content,1,index-1);
		local posStr = string.sub(content,index+2,-2);
		local pos = string.split(posStr,",");
		return cc.MoveTo:create(time,cc.p(pos[1],pos[2])),time;
	end
end

