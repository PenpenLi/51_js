local LuckWheelLogPanel=class("LuckWheelLogPanel",UILayer)

function LuckWheelLogPanel:ctor(data)
    self.appearType = 1;
    self.isWindow = true; 
    self:init("ui/ui_luck_wheel_log.map")
 
    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)  
    self:showLog(self:getLog())
end
 
 

function LuckWheelLogPanel:onPopback()
    Scene.clearLazyFunc("wheellog")
end

function LuckWheelLogPanel:getLog()

    local items=  string.split( cc.UserDefault:getInstance():getStringForKey("luckreward"..gUserInfo.id ),"|")
    local ret={}
    for key, var in pairs(items) do
        local temp= string.split(var,",")
        if(toint(temp[1])~=0)then
            table.insert(ret,{id=toint(temp[1]),num=toint(temp[2])})
        end
    end 
    return ret
end

function LuckWheelLogPanel:showLog(rewards)
    Scene.clearLazyFunc("wheellog");
    self:getNode("scroll"):clear()
  
    for key, var in pairs(rewards) do
        local item=LuckWheelLogItem.new()
        item.key=key
        if(key<8)then
            item:setData(var)
        else
            item:setLazyData(var)
        end
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
    if(table.getn(self:getNode("scroll").items)>0)then
        self:getNode("icon_empty"):setVisible(false)
    end

    local containerSize=self:getNode("scroll").container:getContentSize()
    local viewSize=self:getNode("scroll").viewSize 
    if(viewSize.height<containerSize.height)then
        self:getNode("scroll").container:setPositionY(0)

    end
end




function LuckWheelLogPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end


return LuckWheelLogPanel