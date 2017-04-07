-- RotateTo(time,angle)
Decode.act.rotateTo = {}
function Decode.act.rotateTo.checkType(str)
	if Decode.getActType(str) == "RotateTo" then
		return true;
	end
	return false;
end

function Decode.act.rotateTo.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		return cc.RotateTo:create(params[1],params[2]),params[1];
	end
end


-- RotateBy(time,angle)
Decode.act.rotateBy = {}
function Decode.act.rotateBy.checkType(str)
	if Decode.getActType(str) == "RotateBy" then
		return true;
	end
	return false;
end

function Decode.act.rotateBy.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		return cc.RotateBy:create(params[1],params[2]),params[1];
	end
end

