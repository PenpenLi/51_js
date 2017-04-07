local ActivityPayPanel=class("ActivityPayPanel",UILayer)

function ActivityPayPanel:ctor(data)

    self:init("ui/ui_hd_shenjiang_new.map") 
    self.curData=data
    Net.sendActivityPay(self.curData) 
    Data.activityActid = self.curData.actId
    for i=1,3 do
        self:getNode("layer"..i):setVisible(false);
    end
end

function ActivityPayPanel:onPopup()
    Net.sendActivityPay(self.curData) 
end

function ActivityPayPanel:onTouchEnded(target)
    if(target.touchName=="btn_pay")then
        Panel.popUp(PANEL_PAY)

    -- Panel.popUpVisible(PANEL_ACTIVITY_PAY_BOX3,
    --         Data.activityPayData.list[3]) 
    elseif(target.touchName=="btn_box1")then
        Panel.popUpVisible(PANEL_ACTIVITY_PAY_BOX,
            Data.activityPayData.list[1],1) 
    elseif(target.touchName=="btn_box2")then
        Panel.popUpVisible(PANEL_ACTIVITY_PAY_BOX,
            Data.activityPayData.list[2],2) 
    elseif(target.touchName=="btn_box3")then
        Panel.popUpVisible(PANEL_ACTIVITY_PAY_BOX3,
            Data.activityPayData.list[3],3) 
    end 
end

function ActivityPayPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_PAY)then
        self:setData(param)

    elseif(event==EVENT_ID_USER_DATA_UPDATE or event==EVENT_ID_GET_ACTIVITY_PAY_GET )then
        self:refreshData(param)

    end
end
  
 
 
function ActivityPayPanel:refreshCard(idx,card)
    local uilayer = self:getNode("layer"..idx);
    if uilayer == nil then
        return;
    end
    uilayer:setVisible(true);
    -- uilayer:setLabelString("txt_name",card.name);
    local name = gCreateVerticalWord(card.name,gCustomFont,20,cc.c3b(255,255,255),-2);
    uilayer:replaceNode("txt_name",name);
    -- uilayer:changeTexture("icon_type"..idx,"images/ui_public1/card_type_"..card.type..".png")
    if(idx == 1)then
        if(uilayer:getNode("icon"):getScaleX()>0)then
            uilayer:getNode("icon"):setScaleX(-uilayer:getNode("icon"):getScaleX());
        end
    end
    
    local actions={ }
    table.insert(actions,"wait") 
    table.insert(actions,"attack_s")
    table.insert(actions,"win")
   
    local role=FlashAni.new()
    loadFlaXml("r"..card.cardid)
    local function  playEnd() 
        if(getRand(0,100)<50)then 
            role:playAction("r"..card.cardid.."_wait",playEnd)
            return
        end
        role.actIdx=role.actIdx+1
        if(role.actIdx>table.getn(actions))then
            role.actIdx=1
        end
        role:playAction("r"..card.cardid.."_"..actions[role.actIdx],playEnd)
    end 
    role.actIdx=1
    role:playAction("r"..card.cardid.."_"..actions[role.actIdx],playEnd)
    uilayer:getNode("icon"):removeAllChildren()
    gAddCenter(role,uilayer:getNode("icon")) 
    
    Icon.setCardCountry(uilayer:getNode("country"),card.country);

end

function ActivityPayPanel:setData(param)
   
    for i=2, 4 do
        local item= Data.activityPayData.list[3].items[i] 
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
    
    self:refreshData()
  
end



function ActivityPayPanel:refreshData(param)

    local item=Data.activityPayData.list[3].items[1] 
    self:replaceRtfString("txt_content",item.num); 
    -- self:setLabelString("txt_need_pay",item.num)
    self:setLabelString("txt_pay_per",Data.activityPayData.var.."/"..item.num) 
    local per=Data.activityPayData.var/item.num
    self:setBarPer("bar",per)

    for i=1, 3 do    
        if(Data.activityPayData.list[i].rec==true)then 
            self:getNode("btn_box"..i):playAction("ui_atlas_box_2")
            self:setTouchEnable("btn_box"..i,true)  
        else 
            if( Data.activityPayData.var>=Data.activityPayData.list[i].items[1].num )then
                self:getNode("btn_box"..i):playAction("ui_atlas_box_3")
                self:setTouchEnable("btn_box"..i,true)   
            else
                self:getNode("btn_box"..i):playAction("ui_atlas_box_1")
                self:setTouchEnable("btn_box"..i,true)   
            end
        end   
        self:getNode("btn_box"..i):setPositionX( self:getNode("bar").oldWidth*(Data.activityPayData.list[i].items[1].num/item.num))
    end

end       



return ActivityPayPanel