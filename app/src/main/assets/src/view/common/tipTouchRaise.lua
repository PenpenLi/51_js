local TipTouchRaise=class("TipTouchRaise",UILayer)

function TipTouchRaise:ctor(cardid)
    self:init("ui/tip_touch_raise.map")
    local card=Data.getUserCardById(cardid)

    local power=  CardPro.countWeaponPower(card)
    local powerData=DB.getCardRaisePower(power)
    local totalPower=0
    local nextLevel=1
    if(powerData)then
        self:replaceLabelString("txt_cur_level",powerData.level)
        nextLevel=powerData.level+1

        if(powerData.attr_value0==0)then
            self:setLabelString("txt_info1", "")
        else
            self:replaceLabelString("txt_info1", powerData.attr_value0)
        end


        if(powerData.attr_value1==0)then
            self:setLabelString("txt_info2", "")
        else
            self:replaceLabelString("txt_info2", powerData.attr_value1) 
        end
    else
        self:replaceLabelString("txt_cur_level",0)
        self:setLabelString("txt_info1",gGetWords("weaponWords.plist","empty"))
        self:setLabelString("txt_info2","")
    end

    self:replaceLabelString("txt_next_level",nextLevel)

    local nextPowerData=DB.getCardRaisePowerByLevel(nextLevel)
    if(nextPowerData==nil)then
        self:getNode("next_level_panel"):setVisible(false)
        self:setLabelString("txt_limit",gGetWords("weaponWords.plist","max_power_level"))
    else
        if(nextPowerData.attr_value0==0)then
            self:setLabelString("txt_next_info1", "")
        else
            self:replaceLabelString("txt_next_info1", nextPowerData.attr_value0)
        end
        if(nextPowerData.attr_value1==0)then
            self:setLabelString("txt_next_info2", "")
        else
            self:replaceLabelString("txt_next_info2", nextPowerData.attr_value1)
        end
        totalPower=nextPowerData.power
        self:replaceLabelString("txt_limit",totalPower)
    end
    self:resetLayOut()

    local size=self:getNode("layout"):getContentSize()
    size.width= self:getNode("tip_bg"):getContentSize().width
    size.height=size.height+30
    self:getNode("tip_bg"):setContentSize(size)
end



return TipTouchRaise