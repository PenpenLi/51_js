local TreasureTransmitPanel=class("TreasureTransmitPanel",UILayer)


function TreasureTransmitPanel:ctor()

    self:init("ui/ui_weapon_transmit.map")
    self:initTransmit()
end

function TreasureTransmitPanel:initTransmit()
    self:getNode("panel_card1"):setVisible(false)
    self:getNode("panel_card2"):setVisible(false)
    self:getNode("empty_panel1"):setVisible(true)
    self:getNode("empty_panel2"):setVisible(true)
    self:getNode("btn_add2"):setVisible(false)
    self:getNode("treasure_layer"):setVisible(false)
    self:getNode("panel_get"):setVisible(false)
    self:getNode("arrow_layer1"):setVisible(true)
    self:getNode("arrow_layer2"):setVisible(false)
    self.isMainLayerMenuShow = false;
    self.treasure=nil
    self.selTreasureData = nil

    self:setLabelString("txt_transmit_name1",gGetWords("weaponWords.plist","26"))
    self:setLabelString("txt_transmit_name2",gGetWords("weaponWords.plist","27"))
end


function TreasureTransmitPanel:dealEvent(event,data)
    if EVENT_TREASURE_EXCHANGE ==event  then
        gShowNotice(gGetWords("weaponWords.plist","28"))
        self:initTransmit()
    end
end


function TreasureTransmitPanel:setTreasure(data)
    self.treasure = data
    self:getNode("panel_get"):setVisible(true)
    self:getNode("treasure_layer"):setVisible(true)
    self:getNode("empty_panel1"):setVisible(false)
    self:getNode("empty_panel2"):setVisible(false)
    self:setLabelString("txt_transmit_name1","")
    self:setLabelString("txt_transmit_name2","")

    if self.treasure.db.quality>=QUALITY11 then
        self:setLabelString("txt_dia",Data.treasureExchangeDias[2])
    elseif self.treasure.db.quality>=QUALITY8 then
        self:setLabelString("txt_dia",Data.treasureExchangeDias[1])
    end
    Icon.setIcon(data.itemid,self:getNode("treasure_icon"))
    local treasureDB = DB.getTreasureById(data.itemid)
    self:setLabelString("treasure_name",treasureDB.name)
    self:setLabelString("treasure_lv",data.upgradeLevel)
    self:setLabelString("treasure_quellv",data.quenchLevel)
    CardPro:showStar(self,data.starlv)

    local country = {}
    local campids = string.split(treasureDB.campid,";")
    for k,v in pairs(campids) do
        table.insert(country,gGetWords("cardAttrWords.plist","country_"..v))
    end
    country = table.concat(country, "、")
    self:setLabelString("treasure_country",country)

    self:getNode("treasure_scroll"):clear()

    local treasures=DB.getTreasureByQuaAndType(self.treasure.db.quality,self.treasure.db.type)
    for k,treasure in pairs(treasures) do
        if treasure.id ~= data.itemid then
            local item = TreasureTransmitItem.new()
            item:setData(treasure)
            local function callBack (data)
                self:itemCallBack(data)
            end
            item.selectCallBack=callBack
            self:getNode("treasure_scroll"):addItem(item)
        end
    end
    if table.count(self:getNode("treasure_scroll").items)==1 then
        local item = self:getNode("treasure_scroll").items[1]
        self:itemCallBack(item.curData)
    end
    self:getNode("treasure_scroll"):layout()
end

function TreasureTransmitPanel:itemCallBack(data)
    for k,item in pairs(self:getNode("treasure_scroll").items) do
        if data.id == item.curData.id then
            self.selTreasureData=data
            item:setCheck(true)
        else
            item:setCheck(false)
        end
    end
end

function TreasureTransmitPanel:getCurPrice()
    return self:getNode("txt_dia"):getString()
end

function TreasureTransmitPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_rule"then
        gShowRulePanel(SYS_TREASURE_TRANSFORM)

    elseif  target.touchName=="btn_exchange4" or target.touchName=="btn_add1" then
        local function callback(data)
             self:setTreasure(data)
             return true
        end
        Panel.popUp(PANEL_TREASURE_TRANSMIT_SEL,callback)

    elseif  target.touchName=="btn_transmit"then
        if(NetErr.transmitTreasure(self.treasure,self.selTreasureData) )then
            local function callback()
                Net.sendTreasureExchange(self.treasure.id,self.selTreasureData.id)
            end
            gConfirmCancel(gGetWords("noticeWords.plist","confirm_treasure_transmit",self:getCurPrice()),callback)
        end
    end
end

return TreasureTransmitPanel