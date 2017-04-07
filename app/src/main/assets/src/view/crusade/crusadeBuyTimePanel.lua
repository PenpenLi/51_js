local CrusadeBuyTimePanel=class("CrusadeBuyTimePanel",UILayer)

function CrusadeBuyTimePanel:ctor()
    self.appearType = 1;
    self.isWindow = true;
    self:init("ui/ui_crusade_buy_time.map")
    -- self.isMainLayerCrusadeShow = true;
    self.isMainLayerMenuShow = false;
    -- self.isMainLayerGoldShow=false;

    self:setData()
end

function CrusadeBuyTimePanel:setData()

    local maxNum=DB.getClientParam("CRUSADE_TOKEN_SHOW_MAX")
    self:setLabelString("txt_num", gCrusadeData.crunum.."/"..maxNum)



    self:setRTFString("txt_use",  gGetWords("labelWords.plist","crusade_own_key",Data.getItemNum(CRUSASH_KEY_ID)) )


    local buyNum=DB.getCrusadeBuyNum(Data.getCurVip())

    local buyGold=Data.getBuyTimesPrice(gCrusadeData.buynum+1,"CRUSADE_TOKEN_BUY_PRICE","CRUSADE_TOKEN_BUY_PRICE_NUM")
    self:setRTFString("txt_buy",  gGetWords("labelWords.plist","crusade_buy_time",buyNum-gCrusadeData.buynum) ) 
    self:setLabelString("txt_gold",buyGold)
end


function  CrusadeBuyTimePanel:events()
    return {EVENT_ID_CRUSADE_BUY}
end



function CrusadeBuyTimePanel:dealEvent(event,param)
    if(event==EVENT_ID_CRUSADE_BUY)then
        self:setData()
    end
end


function CrusadeBuyTimePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then 
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_buy"then 

        local buyNum=DB.getCrusadeBuyNum(Data.getCurVip())
        if(buyNum-gCrusadeData.buynum<=0)then
            gShowNotice(gGetWords("noticeWords.plist","crusade_no_buy_time"  ))
            return
        end  

        Data.vip.crusade.setUsedTimes(gCrusadeData.buynum);
        local callback = function(num)
            Net.sendCrusadeBuy(num)
        end
        Data.canBuyTimes(VIP_CRUSADE,true,callback);
    elseif  target.touchName=="btn_use"then  
        local num=Data.getItemNum(  CRUSASH_KEY_ID)
        if(num<=0)then
            gShowNotice(gGetWords("noticeWords.plist","crusade_no_item"  ))
        
            return 
        end
        Panel.popUp(PANEL_MULT_OPEN_BOX,CRUSASH_KEY_ID)
       -- Net.sendUseItem(,1)
    end

end
 

return CrusadeBuyTimePanel