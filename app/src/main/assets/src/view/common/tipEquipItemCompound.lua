local TipEquipItemCompound=class("TipEquipItemCompound",UILayer)

function TipEquipItemCompound:ctor(data)
    self:init("ui/tip_equip_compound.map") 
    self.curData=data
    self:setItemId(data.itemid)
end

function TipEquipItemCompound:events()
    return {EVENT_ID_EQUIP_MERGE}
end


function TipEquipItemCompound:dealEvent(event,param)
    if(event==EVENT_ID_EQUIP_MERGE)then
        self:setItemId(self.curData.itemid) 
        
        
        loadFlaXml("ui_hecheng_effect")
        local fla=nil
        local function playEnd() 
            self:getNode("icon_arrow"):setVisible(true)  
        end
        
        self:getNode("icon_arrow"):setVisible(false) 
        fla=gCreateFla("ui_hecheng_jiantou",0,playEnd) 
        fla:setPosition(self:getNode("icon_arrow"):getPosition())
        self:getNode("icon_arrow"):getParent():addChild(fla)
        
        local fla2=gCreateFla("ui_hecheng_guangxiao")
        self:getNode("icon2"):getParent():addChild(fla2)
        fla2:setLocalZOrder(100)
        fla2:setPosition(self:getNode("icon2"):getPosition())
    end
end

function TipEquipItemCompound:onTouchEnded(target) 
    
    if(target.touchName=="btn_comp")then
         Net.sendEquipItemMerge(self.itemid) 
    elseif(target.touchName=="btn_close")then
         Panel.popBack(self:getTag()) 
    end 
end

function TipEquipItemCompound:setItemId(itemid)
    self.itemid=itemid
    local db,type= DB.getItemData(itemid)
    if(db==nil)then
        return
    end
    local num=Data.getSharedNum(itemid)

    self:setLabelString("txt_name",db.name) 
    self:setLabelString("txt_name2",db.name) 
    self:setLabelString("txt_num",num) 
    self:setLabelString("txt_num2",num.."/"..db.com_num) 
    self:setLabelString("txt_gold",db.com_money) 

    if(num>=db.com_num)then
        self:setTouchEnable("btn_comp",true,false)
    else
        self:setTouchEnable("btn_comp",false,true)
    end

    Icon.setIcon(itemid+ITEM_TYPE_SHARED_PRE,self:getNode("icon"),DB.getItemQuality(itemid)) 
    Icon.setIcon(itemid,self:getNode("icon2"),DB.getItemQuality(itemid))
     
end

return TipEquipItemCompound