local DropItem=class("DropItem",UILayer)

function DropItem:ctor(name,map)
    loadFlaXml("ui_kuang_texiao");
    
    if(map)then
        self:init(map)
    elseif(name)then

        self:init("ui/ui_drop_item_name.map")
    else

        self:init("ui/ui_drop_item.map")
    end
    self:getNode("touch_node").__touchend=true
    self:setCascadeOpacityEnabled(true);
    self.tipType=TIP_TOUCH_EQUIP_ITEM 
end


function DropItem:onTouchBegan(target,touch)
    if(self.touch==false)then
        return
    end
    if(self.preSelectItemCallback)then
        self.preSelectItemCallback(self.curData,self.idx)
    else
        self.beganPos = touch:getLocation()
        local node=self
        if(self.touchNode)then
            node=self.touchNode
        end
        if( self.tipTypeData)then
            local tip= Panel.popTouchTip(node,self.tipType,self.tipTypeData,nil,cc.p(0.5,0.5),cc.p(0.5,-0.5)) 
        else
            local tip= Panel.popTouchTip(node,self.tipType,self.curData) 
        end

        -- tip:setPositionY(tip:getPositionY()+tip:getContentSize().height)

    end
end

function DropItem:onTouchMoved(target,touch)
    if self.touch==false or  self.beganPos == nil then
        return
    end
    self.endPos = touch:getLocation();
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
    if dis > gMovedDis then
        Panel.clearTouchTip();
    end
end


function DropItem:onTouchEnded(target)
    if(self.selectItemCallback)then
        self.selectItemCallback(self.curData,self.idx)
        -- else
        --      Panel.clearTouchTip()
    end
    Panel.clearTouchTip()
end

function   DropItem:setNum(num)
    num = num or 0;
    self:getNode("txt_num"):setVisible(num>0)
    if(self.result==nil)then
        self:setLabelString("txt_num",self.curData)
    else
        self:setLabelString("txt_num",num)
    end
end
function   DropItem:setData(itemid,quality,hideLight,awakeLv)
    itemid = DB.checkReplaceItem(itemid);

    self.curData=itemid
    if(quality == nil) then
        quality = DB.getItemQuality(itemid);
    end
    if(self:getNode("txt_name"))then
        self:setLabelString("txt_name",DB.getItemName(itemid))
    end
    self.result= Icon.setIcon(toint(itemid),self:getNode("icon"),quality,awakeLv)

    -- print("itemid = "..itemid);
    if(DB.getSoulNeedLight(itemid) and hideLight==nil)then
        self:addSpeEffectForSoul();
    end

    self:showEmergencyFlag(itemid)
end

function DropItem:addSpeEffectForSoul()
    local fla=gCreateFla("ui_kuang_guang",1);
    fla:setTag(100);
    fla:setLocalZOrder(100);
    gAddChildByAnchorPos(self,fla,cc.p(0.5,-0.5));
    -- gAddChildInCenterPos(self,fla);
end

function DropItem:showEmergencyFlag(itemid)
    local itemType = DB.getItemType(itemid)
    if ITEMTYPE_CONSTELLATION == itemType then
        local itemNeedType = gConstellation.getItemNeedType(itemid)
        if  itemNeedType == 2 then
            self:changeTexture("flag_emergency", "images/ui_word/need.png")
            self:getNode("flag_emergency"):setVisible(true)
        elseif itemNeedType == 1 then
            self:changeTexture("flag_emergency", "images/ui_word/need1.png")
            self:getNode("flag_emergency"):setVisible(true)
         elseif itemNeedType == 3 then
            self:changeTexture("flag_emergency", "images/ui_word/shengxingzi.png")
            self:getNode("flag_emergency"):setVisible(true)
        else
            self:getNode("flag_emergency"):setVisible(false)
        end
    end
end



return DropItem