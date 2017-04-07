local FirstPayPanel=class("FirstPayPanel",UILayer)

function FirstPayPanel:ctor(param)
    self:init("ui/ui_first_pay.map")
    self:refreshUi(param)
end

function FirstPayPanel:refreshUi(param)
    Data.bolFisrtSend = false
    local cardid=10013
    local boxid=20126

    self:getNode("first_5888"):setVisible(false)
    self:getNode("first_4888"):setVisible(true)

    -- print("Data.getCurFirstcg()="..Data.getCurFirstcg())
    if (param and Data.getCurFirstcg()>0) then

        self:getNode("first_5888"):setVisible(true)
        self:getNode("first_4888"):setVisible(false)

        for i=1,3 do
            self:getNode("all_value"..i):setVisible(i==Data.getCurFirstcg())
        end

        self.money = param.money
        self.needmoney = param.needmoney

        local gift = DB.getClientParamToTable("FIRST_CHARGE_GIFT");
        Data.toint(gift)
        local boxIndex = Data.getCurFirstcg()*2
        local valueIndex = Data.getCurFirstcg()*2 - 1
        boxid = gift[boxIndex]

        local word = gGetWords("labelWords.plist","350-1",self.needmoney)
        -- self:replaceRtfString("lab_word1",word)
        self:setRTFString("lab_word1",word)
        word = gGetWords("labelWords.plist","349-1")
        self:setLabelString("lab_word2",word)
    end

    gCreateRoleFla(cardid, self:getNode("role_container"))
    
    local card=DB.getCardById(cardid)
    if(card)then
        self:setLabelString("txt_name",card.name)
    end
    local rewards=DB.getBoxItemById(boxid) 
    for i=1, 4 do
        self:getNode("icon"..i):setVisible(false)
    end 
    local idx=1
    for key, item in pairs(rewards) do
        if(self:getNode("icon"..idx))then

            self:getNode("icon"..idx):setVisible(true) 
            local node=DropItem.new()
            node:setData(item.itemid) 
            node:setNum(item.itemnum)   

            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node,self:getNode("icon"..idx))
            idx=idx+1

        end
    end
end

function FirstPayPanel:onPopup()
    if (Data.getCurFirstcg()<3 and not Module.isClose(SWITCH_PAY2)) then
        Data.bolFisrtSend = true
        Net.sendActivityFirstPay()
    end
end

function  FirstPayPanel:events()
    return {
    EVENT_ID_GET_ACTIVITY_FIRST_PAY_INFO1,EVENT_ID_USER_DATA_UPDATE}
end

function FirstPayPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_FIRST_PAY_INFO1 )then
        self:refreshUi(param)
    elseif (event==EVENT_ID_USER_DATA_UPDATE) then
        -- if not Data.isFirstPay() then
        --     Data.bolFisrtSend = true
        --     Net.sendActivityFirstPay()
        -- end
    end
end


function FirstPayPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_pay"then
       Panel.popUp(PANEL_PAY)
    elseif  target.touchName=="btn_video"then
       Panel.popUp(PANEL_FIRST_PAY_VIDEO)
    end
end

return FirstPayPanel