local TipEquipItemGet=class("TipEquipItemGet",UILayer)

function TipEquipItemGet:ctor(data)
    self.appearType = 1
    self:init("ui/tip_equip_get.map")
    loadFlaXml( "ui_icon_atlas")
    self.curData=data
    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
end


function TipEquipItemGet:onPopup() 
    self:dealEvent(EVENT_ID_EQUIP_MERGE,1)
    
    if(self.isInstack==true and self.isCanComp==false)then 
        if(EquipItem.canCompound(self.itemid))then
            self:getNode("icon_top2"):setVisible(true)
        end
        self:getNode("panel_com"):setVisible(false)
        self:getNode("panel_get"):setVisible(true)
    end
end

function TipEquipItemGet:onPushStack()
    -- body
    self.isInstack = true;
end


function TipEquipItemGet:events()
    return {EVENT_ID_EQUIP_MERGE}
end


function TipEquipItemGet:dealEvent(event,param)
    if(event==EVENT_ID_EQUIP_MERGE)then
        self:setItemId(self.curData.itemid)
        local num= Data.getEquipItemNum(self.curData.itemid)
        if(num>0)then
            self:setTouchEnable("btn_equip",true,false)
        else
            self:setTouchEnable("btn_equip",false,true)
        end
        
        
        if(param~=1)then


            loadFlaXml("ui_hecheng_effect") 
            local fla=gCreateFla("ui_hecheng_xingxing1") 
            fla:setPosition(self:getNode("icon_com2"):getPosition())
            self:getNode("icon_com2"):getParent():addChild(fla)

            local fla2=gCreateFla("ui_hecheng_b")
            self:getNode("icon_com2"):getParent():addChild(fla2)
            fla2:setLocalZOrder(100)
            fla2:setPosition(self:getNode("icon_com2"):getPosition())
        end
    end
end

function TipEquipItemGet:setItemId(itemid)
    self.itemid=itemid
    local db,type= DB.getItemData(itemid)
    if(db==nil)then
        return
    end







    local num=Data.getEquipItemNum(itemid)

    self:setLabelString("txt_name",db.name)
    self:setLabelString("txt_name2",db.name)
    self:setLabelString("txt_name3",db.name)
    self:setLabelString("txt_info",CardPro.getEquipAtivateAttrAddDesc(self.curData))
    self:setLabelString("txt_num",gGetWords( "labelWords.plist","lab_reamin_num",num))



    Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(itemid))
    Icon.setIcon(itemid,self:getNode("icon_top1"),DB.getItemQuality(itemid))



    self:getNode("icon_top2"):setVisible(false)
    self.isCanComp=false
    if(EquipItem.canCompound(itemid))then
        Icon.setIcon(itemid,self:getNode("icon_com1"),DB.getItemQuality(itemid))
        Icon.setIcon(itemid+ITEM_TYPE_SHARED_PRE,self:getNode("icon_top2"),DB.getItemQuality(itemid))
        Icon.setIcon(itemid+ITEM_TYPE_SHARED_PRE,self:getNode("icon_com2"),DB.getItemQuality(itemid))
        local num=Data.getSharedNum(itemid)
        self:setLabelString("txt_num2",num.."/"..db.com_num)
        self:setLabelString("txt_gold",db.com_money)
        self:getNode("panel_com"):setVisible(true)
        self:getNode("panel_get"):setVisible(false)

        if(num>=db.com_num)then
            self:setTouchEnable("btn_comp",true,false)
            self.isCanComp=true
        else
            self:setTouchEnable("btn_comp",false,true)
        end
        self.needNum=db.com_num

    else
        self:getNode("panel_com"):setVisible(false)
        self:getNode("panel_get"):setVisible(true)
        self.needNum=0
    end
    local atlas=DB.getStageByItemId(self.itemid)
    self:showRewards(atlas)
end

function TipEquipItemGet:getGuideItem(idx) 
    if(self:getNode("scroll").items[toint(idx)])then
        return self:getNode("scroll").items[toint(idx)]:getNode("touch_node")
    end
end

function TipEquipItemGet:showRewards(atlas)
    self:getNode("scroll"):clear()
    for key, var in pairs(atlas) do
        local item=AtlasDropItem.new(1)
        if(EquipItem.canCompound(self.itemid))then
            item.itemid=self.itemid+ITEM_TYPE_SHARED_PRE
        else
            item.itemid=self.itemid
        end
        item.needNum=self.needNum
        print(self.needNum)
        item:setData(var)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
end




function TipEquipItemGet:onTouchEnded(target)

    if(target.touchName=="icon_com2" or target.touchName=="btn_get")then
        if(EquipItem.canCompound(self.itemid))then
            self:getNode("icon_top2"):setVisible(true)
        end
        self:getNode("panel_com"):setVisible(false)
        self:getNode("panel_get"):setVisible(true)

    elseif( target.touchName=="icon_top1")then
        if(EquipItem.canCompound(self.itemid))then
            self:getNode("icon_top2"):setVisible(false)
            self:getNode("panel_com"):setVisible(true)
            self:getNode("panel_get"):setVisible(false)
        else
            Panel.popBack(self:getTag())
        end
    elseif( target.touchName=="btn_return")then
        if( self:getNode("icon_top2"):isVisible())then
            self:getNode("icon_top2"):setVisible(false)
            self:getNode("panel_com"):setVisible(true)
            self:getNode("panel_get"):setVisible(false)
        else
            Panel.popBack(self:getTag())
        end

    elseif(target.touchName=="btn_comp")then
        Net.sendEquipItemMerge(self.itemid)
        -- Panel.popBack(self:getTag())

    elseif(target.touchName=="btn_equip")then
        Net.sendEquipActivate(self.curData.cardid,self.curData.equipIdx,self.curData.activatePos)
        Panel.popBack(self:getTag())
    end


end



return TipEquipItemGet