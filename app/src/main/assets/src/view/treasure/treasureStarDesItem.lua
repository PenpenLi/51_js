local TreasureStarDesItem=class("TreasureStarDesItem",UILayer)

function TreasureStarDesItem:ctor(attrArray,starlv)
    self.attrArray = attrArray
    self.starlv=starlv
    self.inited = false
end


function TreasureStarDesItem:setData(curStarLv)
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


    for index,item in pairs(self.attrArray) do
        self:setLabelString("txt_attr"..index,item.attrName)
        self:setLabelString("txt_num"..index,item.attrValue)
        self:getNode("txt_num"..index):setColor(color)
    end

    self:resetLayOut()
end

function TreasureStarDesItem:setLazyData()
    Scene.addLazyFunc(self,self.setDataLazyCalled,"TreasureStarDesItem")
end

function  TreasureStarDesItem:setDataLazyCalled()
    self:setData()
end



return TreasureStarDesItem
