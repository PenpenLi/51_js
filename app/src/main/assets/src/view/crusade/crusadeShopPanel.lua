local CrusadeShopPanel=class("CrusadeShopPanel",UILayer)

function CrusadeShopPanel:ctor()
    -- self.appearType = 1;
    self.isMainLayerGoldShow=false
    self.isMainLayerCrusadeShow=true
    self.isMainLayerMenuShow = false
    self.isWindow = true;

    self:init("ui/ui_shop2.map")
    self.needRefresh = false;
    self.curShopType = SHOP_TYPE_CRUSADE;
    self.scroll = self:getNode("scroll");
    self.scroll.eachLineNum = 2;
    self.scroll:setPaddingXY(18,0); 
    self:setLabelString("shop_title",gGetWords("labelWords.plist","rusade_shop_title"));    

   

    self:getNode("layer_full"):setVisible(true);
    self:getNode("layer_right"):setVisible(false);
    self:getNode("layer_left"):setVisible(false);

    self:getNode("layer_family"):setVisible(false);
    self:getNode("layer_arena"):setVisible(false);
    self:getNode("layer_pet"):setVisible(false);
    self:getNode("layer_tower"):setVisible(false);
    self:getNode("layer_crusade"):setVisible(true);
    self:getNode("layer_emotion"):setVisible(false);
  
    local showItems=exploitshop_db
    for key, var in pairs(showItems) do
        local item=ShopItem.new()
        var.costType=OPEN_BOX_EXPLOIT
        item:setData(var)
        item.selectItemCallback=function (data,idx)
            self:onSelectItem(data,idx)
        end
        self.scroll:addItem(item)
    end

    self.scroll:layout()
    self:setLabelString("txt_exploits",gCrusadeData.exploits)

    
    self:getNode("btn_pre"):setVisible(gGetUnlockShopCount() > 1);
    self:getNode("btn_next"):setVisible(gGetUnlockShopCount() > 1);
end
 
 
function  CrusadeShopPanel:events()
    return {EVENT_ID_CRUSADE_SHOP_BUY}
end



function CrusadeShopPanel:dealEvent(event,param)
     if event==EVENT_ID_CRUSADE_SHOP_BUY then
        self:setLabelString("txt_exploits",gCrusadeData.exploits)
    end
end

function CrusadeShopPanel:onSelectItem(data,idx)
    local temp={}
    temp.itemid=data.itemid 
    temp.id=data.id 
    temp.costType=OPEN_BOX_EXPLOIT
    temp.lefttimes= math.floor(gCrusadeData.exploits/data.price)
    temp.price= data.price 
    temp.rewardNum=data.num
    temp.buyCallback=function(num)
        if(num<=0)then
            return
        end
        if(temp.lefttimes<=0)then 
            gShowNotice(gGetWords("noticeWords.plist","no_enough_exploit" ))
            return
        end
        Net.sendCrusadeShopBuy(temp.id,num,num*temp.price)
    end
    
    
    Panel.popUp(PANEL_SHOP_BUY_ITEM,temp)
end


function CrusadeShopPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_pre" then
        gPreShop(self.curShopType,self:getTag());
    elseif target.touchName == "btn_next" then
        gNextShop(self.curShopType,self:getTag());
    end

end


return CrusadeShopPanel