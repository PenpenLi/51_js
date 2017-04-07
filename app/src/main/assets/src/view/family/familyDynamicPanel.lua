local FamilyDynamicPanel=class("FamilyDynamicPanel",UILayer)

function FamilyDynamicPanel:ctor(data)
    -- self._panelTop = true;
    self.appearType = 1;
    self:init("ui/ui_family_dynamic.map")
    self.isMainLayerGoldShow = false;
    self.isMainLayerMenuShow = false;
    -- self:createList();
    self.class = {
    	{1,2,3,4,5},--活动类
    	{7},--任命类
    	{11},--升级类
    	{6,7,8,9,10,13,18}--成员变动类
    };

    Net.sendFamilyDynamic();
end

function FamilyDynamicPanel:onPopback()
    Scene.clearLazyFunc("familyDynamicItem");
end

function FamilyDynamicPanel:events()
	return {EVENT_ID_FAMILY_DYNAMIC};
end

function FamilyDynamicPanel:dealEvent(event,param)
	if(event == EVENT_ID_FAMILY_DYNAMIC)then
		self:createList();
	end
end

function FamilyDynamicPanel:createList()

	-- for i=1,10 do
	-- 	local data = {};
	-- 	table.insert(Data.family.dynamic,data);
	-- end
	local bFind = false;
	for key,var in pairs(Data.family.dynamic) do
		bFind = false;
		for index,class in pairs(self.class)do
			for idx,type in pairs(class)do
				if(type == var.iType)then
					bFind = true;
					var.class = toint(index);
					break;
				end
			end
			if(bFind)then
				break;
			end
		end
	end

	print_lua_table(Data.family.dynamic);


	for key,var in pairs(Data.family.dynamic) do
		local item = FamilyDynamicItem.new();
		if(toint(key)<6)then
			item:setData(var);
		else
			item:setLazyData(var);
		end
		self:getNode("scroll"):addItem(item);
	end
	self:getNode("scroll"):layout();

end

function FamilyDynamicPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end

end


return FamilyDynamicPanel