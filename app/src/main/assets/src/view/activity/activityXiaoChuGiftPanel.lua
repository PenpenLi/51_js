local ActivityXiaoChuGiftPanel=class("ActivityXiaoChuGiftPanel",UILayer)

function ActivityXiaoChuGiftPanel:ctor(data)
    self:init("ui/ui_hd_xiaochu_1.map")
    self.Data = data
    self.curActData= self.Data
    self.curData = nil
    Net.sendActivity26(data)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function ActivityXiaoChuGiftPanel:onExit()
    if (Data.activity26Data.cardid == 10107) then
       gPlayMusic("bg/bgm_home.mp3")
    end
end

function ActivityXiaoChuGiftPanel:onPopup()
    Net.sendActivity26(self.Data)
end

function ActivityXiaoChuGiftPanel:createRoleAction(cardid)
    local fla = nil
    local node = self:getNode("role_bg")
    node:removeAllChildren()
    local icon = Data.convertToIcon(cardid)
    local fla=FlashAni.new()
    fla:setSoundPlay(false)
    local action = "attack_b"
    loadFlaXml("r"..icon)
    local function  playEnd()
        fla:playAction("r"..icon.."_"..action,playEnd)
    end
    fla:playAction("r"..icon.."_"..action,playEnd)
    fla:setScale(0.7)
    gAddCenter(fla,node)
    if fla then
        fla:setScaleX(-0.7);
        --加影子
        local shadow=cc.Sprite:create("images/battle/shade_ui.png")
        shadow:setScaleY(0.7)
        fla:addChild(shadow,-1)
    end
end

function ActivityXiaoChuGiftPanel:setData(param)
    if (Data.activity26Data.cardid == 10107) then
        gPlayMusic("bg/bg_chuyin.mp3")
        self:createRoleAction(Data.activity26Data.cardid)
    else
        gCreateRoleFla(Data.activity26Data.cardid, self:getNode("role_bg"),1) 
    end
    self:setOneItem()
end

function ActivityXiaoChuGiftPanel:setOneItem()
    if(Data.activity26Data.list) then
        local data = Data.activity26Data.list[1]
        self.curData = data

        local cardData = DB.getCardById(Data.activity26Data.cardid)
        local strName = ""
        if (cardData) then
            strName = cardData.name
        end
         
        local sWord = gGetMapWords("ui_hd_xiaochu_1.plist","8",strName,strName,strName)
        self:replaceLabelString("lab_name",strName)
        self:setLabelString("lab_info",sWord)
        self:replaceLabelString("lab_title",strName)
        self:replaceLabelString("lab_buy_word",strName)
        -- self:getNode("lab_name"):setString(strName)
        -- self:getNode("lab_info"):setString(strName)
        -- self:getNode("lab_title"):setString(strName)
        -- self:getNode("lab_buy_word"):setString(strName)
        self:getNode("info_bg"):layout()

        local bolBuy = false
        local card = Data.getUserCardById(Data.activity26Data.cardid)
        if (card) then
           local starnum = card.grade
           if (starnum>=Data.activity26Data.grade) then
              bolBuy = true
           end
        end
        local size = #data.numList
        if (size>1) then
            for i=2,3 do
                self:getNode("icon2_"..(i-1)):setVisible(false)
            end
            for i=2,size do
                self:getNode("icon2_"..(i-1)):setVisible(true)
                Icon.setDropItem(self:getNode("icon2_"..(i-1)), data.itemidList[i],data.numList[i],DB.getItemQuality(data.itemidList[i]))
            end
        end
        self:getNode("item_lay"):layout()

        self:getNode("lab_count"):setVisible(bolBuy)

        self:setLabelString("lab_count",math.max(data.max - data.cur,0).."/"..data.max)
        self:setLabelString("lab_price1", data.numList[1])
        self:setLabelString("lab_price2", data.numList2[1])
        self:getNode("lay_price1"):layout()
        self:getNode("lay_price2"):layout()
     
        if(data.cur>=data.max or bolBuy==false)then
            self:setTouchEnable("btn_buy",false,true)
        else
            self:setTouchEnable("btn_buy",true,false)
        end
    end
end

function ActivityXiaoChuGiftPanel:onTouchEnded(target)  
    if(target.touchName=="btn_buy")then
        if NetErr.isDiamondEnough(self.curData.numList2[1]) then
            Net.sendActivity26Buy(self.curData.idx,self.curActData)
            if (TDGAItem) then
                gLogPurchase("buy_26",1,self.curData.numList2[1])
            end
            if (TalkingDataGA) then
               local param = {}
               -- table.insert(param, {id=tostring(self.curActData)})
               item = Data.get26DataByDetid(self.curData.idx)
               param["name"] = self.itemName
               gLogEvent("activity_26",param)
            end
        end
    end
end

function ActivityXiaoChuGiftPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_26)then
        self:setData(param)
    elseif(event==EVENT_ID_GET_ACTIVITY_26_REC)then
        self:refreshData(param)
    end
end

function ActivityXiaoChuGiftPanel:refreshData(param)
    self:setOneItem()
end       

return ActivityXiaoChuGiftPanel
