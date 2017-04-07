local UserHaloItem=class("UserHaloItem",UILayer)

function UserHaloItem:ctor(data,index)
    self:init("ui/ui_halo_item_2.map");
    self:setData(index,data);
end

function UserHaloItem:setData(index,data)
	self.curData = data;
	self.index = index
	self:refreshUI();
end

function UserHaloItem:refreshUI()
    print("gUserInfo.halo="..gUserInfo.halo)
    self:getNode("icon_star"):setVisible(Data.getCurHalo()>=self.index)
	self:setLabelString("txt_dec",self.curData.buffattr..self.curData.buffattr2);
end

function UserHaloItem:refreshData()
    self:setData(self.index,self.curData)
end


return UserHaloItem