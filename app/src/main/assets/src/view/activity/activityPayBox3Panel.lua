local ActivityPayBox3Panel=class("ActivityPayBox3Panel",UILayer)

function ActivityPayBox3Panel:ctor( item,curIdx)
    self.appearType = 1;
    self.isMainLayerMenuShow = false;
    self:init("ui/ui_hd_shengjiang_box.map") 
    
    self.curData=item
    local item1=item.items[1]
    local item2=item.items[2] 

    for i=2, 4 do
        local item= item.items[i] 
        local itemid=item.itemid
        if(DB.getItemType(itemid)==ITEMTYPE_CARD_SOUL)then
            itemid=itemid-ITEM_TYPE_SHARED_PRE
        end
        
        local card=DB.getCardById(itemid)
        local idx=i-1
        if(card)then
            self:refreshCard(idx,card);
            -- gCreateRoleFla(itemid, self:getNode("role_container"..idx),1) 
            -- self:setLabelString("txt_name"..idx,card.name)  
            -- self:setLabelString("txt_top"..idx.."_name1",string.utf8sub(card.name,1,1))  
            -- self:setLabelString("txt_top"..idx.."_name2",string.utf8sub(card.name,2,5))  
            -- self:changeTexture("icon_type"..idx,"images/ui_public1/card_type_"..card.type..".png")
        end
    end 
    
    if(Data.activityPayData.list[curIdx].rec==true)then 
        self:setTouchEnable("btn_get",true,false)
    else 
        if( Data.activityPayData.var>=Data.activityPayData.list[curIdx].items[1].num )then
            self:setTouchEnable("btn_get",false,true)
        else
            self:setTouchEnable("btn_get",false,true)
        end
    end   


    self:clearSelect()
    
end

 
function ActivityPayBox3Panel:refreshCard(idx,card)
    local uilayer = self:getNode("layer"..idx);
    if uilayer == nil then
        return;
    end
    uilayer:setLabelString("txt_name",card.name);
    uilayer:changeTexture("icon_type"..idx,"images/ui_public1/card_type_"..card.type..".png")
    gCreateRoleFla(card.cardid, uilayer:getNode("icon"),1) 
    uilayer.starContainerX= uilayer:getNode("star_container"):getPositionX()
    CardPro:showStarLeftToRight(uilayer,card.evolve);
    uilayer:getNode("layer_chip_num"):setVisible(false);
    uilayer:getNode("layer_bar"):setVisible(false);
    uilayer:getNode("layer_comp_card"):setVisible(false);
    uilayer:getNode("txt_lv"):setVisible(false);
    Icon.setCardCountry(uilayer:getNode("country"),card.country);
    

end

function  ActivityPayBox3Panel:getCurSelected()
    for i=1, 3 do
        if(self:getNode("icon_select"..i):isVisible())then 
            return i
        end
    end
    
    return -1
end

function  ActivityPayBox3Panel:clearSelect()
    for i=1, 3 do
        self:getNode("icon_select"..i):setVisible(false)
    end

end

function ActivityPayBox3Panel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="touch1"then
        self:clearSelect()
        self:getNode("icon_select1"):setVisible(true)
    elseif  target.touchName=="touch2"then
        self:clearSelect()
        self:getNode("icon_select2"):setVisible(true)
    elseif  target.touchName=="touch3"then
        self:clearSelect()
        self:getNode("icon_select3"):setVisible(true)
    
    elseif  target.touchName=="btn_get"then
        local select=self:getCurSelected()
        if(select==-1)then
            gShowNotice(gGetWords("noticeWords.plist","need_select_card"))
            return
        end 
        Net.sendActivityPayGet(Data.activityPayData.idx,self.curData.idx,self.curData.items[select+1].itemid)
        Panel.popBack(self:getTag())
     
    end
end


return ActivityPayBox3Panel

 