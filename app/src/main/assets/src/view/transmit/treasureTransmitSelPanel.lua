local TreasureTransmitSelPanel=class("TreasureTransmitSelPanel",UILayer)
function TreasureTransmitSelPanel:ctor(callback)

    self.appearType = 1;
    self:init("ui/ui_weapon_transmit_card.map")
    self:getNode("treasure_layer"):setVisible(true)
    local weapons={}
    self:getNode("scroll").eachLineNum=2
    self.isWindow = true;
    self.hideMainLayerInfo = true;
    self.callback=callback

    self.types={}
    for i=0,3 do
        self.types[i]=false
    end

    self:setLabelString("txt_title",gGetWords("treasureWord.plist","seltreasure"))
    self:initSelData(self.types)
end

function TreasureTransmitSelPanel:initSelData(types)
    Scene.clearLazyFunc("TreasureTransmitSelItem")
    self:getNode("scroll"):clear()

    local typseNoAllSelStauts = false
    local  tempTypes = clone(types)
    if tempTypes[0]==false and tempTypes[1]==false and tempTypes[2]==false and tempTypes[3]==false then
        typseNoAllSelStauts = true
    end

    if typseNoAllSelStauts==true then
        for key,value in pairs(tempTypes) do
            tempTypes[key] = true 
        end
    end
    local curShowItems = {}
    for key, var in pairs(gUserTreasure) do
        if var.cardid==0 and tempTypes[var.db.type]==true and var.db.quality>=QUALITY8 then
            table.insert(curShowItems,var)
        end
        
    end
    
     for key, var in pairs(curShowItems) do
        local curType=3- var.db.type
        var.tmpSort=curType+var.db.quality*1000+var.starlv*100000
    end

    local function sortFunc(item1,item2)
        return item1.tmpSort>item2.tmpSort
    end
    table.sort(curShowItems,sortFunc)

    local drawNum=20
    for key, var in pairs(curShowItems) do
       local item=TreasureTransmitSelItem.new()
        if(drawNum>0)then
            drawNum=drawNum-1
            item:setData(var)
        else
            item:setLazyData(var)
        end
        item.selectItemCallback=function (data)
             if(self.callback(data)~=false)then
                Scene.clearLazyFunc("TreasureTransmitSelItem")
                Panel.popBack(self:getTag())
            end
        end
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
end

function TreasureTransmitSelPanel:setNodeStatus(name,isSel)
    if isSel then
        self:changeTexture(name,"images/ui_public1/n-di-gou2.png")
    else
        self:changeTexture(name,"images/ui_public1/n-di-gou1.png")
    end    
end

function TreasureTransmitSelPanel:onTouchEnded(target)

    if  target.touchName=="btn_close" then
        Panel.popBack(self:getTag())
    elseif target.touchName and string.find(target.touchName,"check_trea") then
        local index = toint(string.sub(target.touchName,-1))-1
        self.types[index] = not self.types[index]
        self:setNodeStatus("icon_type"..index+1,self.types[index])
        self:initSelData(self.types)
    end
end
return TreasureTransmitSelPanel
