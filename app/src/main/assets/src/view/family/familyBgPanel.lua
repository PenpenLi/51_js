
local FamilyBgPanel=class("FamilyBgPanel",UILayer)

function FamilyBgPanel:ctor(type)
    self:init("ui/ui_family_bg.map")
    self:initPos();
end

function  FamilyBgPanel:events()

    return {EVENT_ID_FAMILY_REFRESH_BGMEM}
end

function FamilyBgPanel:dealEvent(event,param)
	if(event == EVENT_ID_FAMILY_REFRESH_BGMEM) then
		self:createMem();
	end
end

function FamilyBgPanel:initPos()
	self.posNode = {};
	for i=1,20 do
		if(self:getNode("pos"..i)) then
			table.insert(self.posNode,self:getNode("pos"..i));
		end
	end

  local function sortRoleZ(role1,role2)
    local pos1 = cc.p(role1:getPosition());
    local pos2 = cc.p(role2:getPosition());
    if(pos1.y > pos2.y) then
      return true;
    end
    return false;
  end
  
  table.sort(self.posNode,sortRoleZ);
  
  --reorderZ
  local z = 0;
  for key,value in pairs(self.posNode) do
  	value:setLocalZOrder(z);
    z = z + 1;
  end
  
end

function FamilyBgPanel:createMem()


	local memCount = table.getn(gFamilyMemList);
	for i,var in ipairs(self.posNode) do
		-- print("i = "..i .. " memCount = "..memCount);
		if i <= memCount then
			local memData = gFamilyMemList[i];
			local role = gCreateRoleFla(Data.convertToIcon(memData.iCoat), var,0.5);
			if(role) then
				if math.random() < 0.5 then
					role:setScaleX(-0.5);
				end
			end
		end
	end

end


function FamilyBgPanel:onTouchEnded(target)
	print("target.touchName = "..target.touchName);
    if target.touchName=="btn_hd"then
        gDispatchEvt(EVENT_ID_FAMILY_ENTER,FAMILY_ENTER_HD);
    elseif target.touchName == "btn_tuteng"then
        gDispatchEvt(EVENT_ID_FAMILY_ENTER,FAMILY_ENTER_TUTENG);
	elseif target.touchName == "btn_main"then
        gDispatchEvt(EVENT_ID_FAMILY_ENTER,FAMILY_ENTER_MAIN);   
	elseif target.touchName == "btn_battle"then
        gDispatchEvt(EVENT_ID_FAMILY_ENTER,FAMILY_ENTER_BATTLE);   
	elseif target.touchName == "btn_shop"then
        gDispatchEvt(EVENT_ID_FAMILY_ENTER,FAMILY_ENTER_SHOP);   
    end
end

return FamilyBgPanel