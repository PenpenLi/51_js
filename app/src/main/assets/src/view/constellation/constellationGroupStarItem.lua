local ConstellationGroupStarItem=class("ConstellationGroupStarItem",UILayer)

function ConstellationGroupStarItem:ctor(data,starlv)
    self.showGroupInfo = data
    self.starlv=starlv
    self.inited = false
end


function ConstellationGroupStarItem:setData(curStarLv)
    if self.inited then
        return
    end
    local color = cc.c3b(255,255, 255)
    if curStarLv>=self.starlv then
        color= cc.c3b(0,255, 0)
    end
    self.inited = true
    self:init("ui/ui_constellation_group_xingjijiacheng_item.map")
    self:replaceLabelString("txt_starnum",self.starlv)
    local index=1
    for i=1,3 do
        local attrtype = self.showGroupInfo["attr"..i]
        if attrtype>0 then
            local attrName = CardPro.getAttrName(attrtype)
            local attrValue = CardPro.getAttrValue(attrtype,self.showGroupInfo["param"..i])
            self:setLabelString("txt_attr"..index,attrName)
            self:setLabelString("txt_num"..index,"+"..attrValue)
            self:getNode("txt_num"..index):setColor(color)
            index=index+1
        end
    end
    for i=index,4 do
        self:getNode("attr_layer"..i):setVisible(false)
    end

end

function ConstellationGroupStarItem:setLazyData()
    Scene.addLazyFunc(self,self.setDataLazyCalled,"ConstellationGroupStarItem")
end

function  ConstellationGroupStarItem:setDataLazyCalled()
    self:setData()
end



return ConstellationGroupStarItem
