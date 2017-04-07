-- ScaleTo(time,scale)
-- ScaleTo(time,scalex,scaley)
Decode.act.scaleTo = {}
function Decode.act.scaleTo.checkType(str)
	if Decode.getActType(str) == "ScaleTo" then
		return true;
	end
	return false;
end

function Decode.act.scaleTo.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		return cc.ScaleTo:create(params[1],params[2]);
	elseif count == 3 then
		return cc.ScaleTo:create(params[1],params[2],params[3]),params[1];
	end
end

-- ScaleBy(time,scale)
-- ScaleBy(time,scalex,scaley)
Decode.act.scaleBy = {}
function Decode.act.scaleBy.checkType(str)
	if Decode.getActType(str) == "ScaleBy" then
		return true;
	end
	return false;
end

function Decode.act.scaleBy.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 2 then
		return cc.ScaleBy:create(params[1],params[2]);
	elseif count == 3 then
		return cc.ScaleBy:create(params[1],params[2],params[3]),params[1];
	end
end

