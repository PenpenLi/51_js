-- OrbitCamera(time,radius,deltaRadius,angleZ,deltaAngleZ,angleX,deltaAngleX)
Decode.act.orbitCamera = {}
function Decode.act.orbitCamera.checkType(str)
	if Decode.getActType(str) == "OrbitCamera" then
		return true;
	end
	return false;
end

function Decode.act.orbitCamera.create(str)
	local content = Decode.getActContent(str);
	local params = string.split(content,",");
	local count = table.getn(params);
	if count == 7 then
		return cc.OrbitCamera:create(params[1],params[2],params[3],params[4],params[5],params[6],params[7]),params[1];
	end
end



