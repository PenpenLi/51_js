local PetTowerBoxItem=class("PetTowerBoxItem",UILayer)

function PetTowerBoxItem:ctor(panel)

    self.appearType = 1;
    self:init("ui/ui_pet_tower_box.map")
    self.isMainLayerMenuShow = false;

    self:hideCloseModule();
    self:replaceLabelString("txt_pet_name",DB.getItemName(DB.getClientParam("PET_GOLD_BOX_ITEMID")))
end

function PetTowerBoxItem:hideCloseModule()
    self:getNode("btn_buy_box3"):setVisible(not Module.isClose(SWITCH_GOLDKEY));
    if(isBanshuUser()) then 
        self:getNode("btn_buy_box3"):setVisible(false); 
    end
end

function PetTowerBoxItem:onPopup()
    self:setLabelString("txt_num1",Data.getUserItemNumById(BOX_KEY_ID1))
    self:setLabelString("txt_num2",Data.getUserItemNumById(BOX_KEY_ID2))
    self:setLabelString("txt_num3",Data.getUserItemNumById(BOX_KEY_ID3))

end
function PetTowerBoxItem:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag()) 
    elseif  target.touchName=="btn_box_info"then
        Panel.popUp(PANEL_PET_TOWER_BOX_INFO)

    elseif  target.touchName=="icon1"then
        local num=Data.getUserItemNumById(BOX_KEY_ID1)
        if(num>10)then
            num=10
        end
        Net.sendUseItem(BOX_KEY_ID1,num) 
    elseif  target.touchName=="icon2"then
        local num=Data.getUserItemNumById(BOX_KEY_ID2)
        if(num>10)then
            num=10
        end
        Net.sendUseItem(BOX_KEY_ID2,num)
    elseif  target.touchName=="icon3"then
        local num=Data.getUserItemNumById(BOX_KEY_ID3)
        if(num<=0 and not Module.isClose(SWITCH_GOLDKEY))then
            local callback = function()
                self:buyGoldKey();
            end
            gConfirmCancel(gGetWords("noticeWords.plist","buy_goldkey"),callback);
            return;
        end
        if(num>10)then
            num=10
        end
        Net.sendUseItem(BOX_KEY_ID3,num)
    elseif target.touchName == "btn_buy_box3"then
        self:buyGoldKey();
        -- Panel.popUpVisible(PANEL_GLOBAL_BUY,VIP_GOLDBOX);    
    end
    
   
end

function PetTowerBoxItem:buyGoldKey()
    local callback = function(num)
        Net.sendBuyPetGoldBox(num);
    end
    Data.canBuyTimes(VIP_GOLDBOX,true,callback);    
end

function  PetTowerBoxItem:events()
    return {EVENT_ID_PET_BOXOPEN,EVENT_ID_BUY_GOLDBOX}
end


function PetTowerBoxItem:dealEvent(event,param)
    if(event == EVENT_ID_PET_BOXOPEN)then
        local boxType = 1;
        if param.id == BOX_KEY_ID1 then
            boxType = 1;
        elseif param.id == BOX_KEY_ID2 then
            boxType = 2;
        elseif param.id == BOX_KEY_ID3 then
            boxType = 3;
        end
        Panel.popUpVisible(PANEL_PET_TOWER_BOXOPEN,param.items,boxType);
    elseif(event == EVENT_ID_BUY_GOLDBOX)then
        self:setLabelString("txt_num3",Data.getUserItemNumById(BOX_KEY_ID3))
    end
end

return PetTowerBoxItem