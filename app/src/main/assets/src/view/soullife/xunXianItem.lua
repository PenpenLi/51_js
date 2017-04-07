local XunXianItem=class("XunXianItem",UILayer)

function XunXianItem:ctor(spirit, operType, idx,isShowLv)
    self:setCascadeOpacityEnabled(true)
    self._isChoose = false
    self._spirit = spirit
    self._ID = spirit.iID
    self._iOperType = operType
    self._idx = idx
    self._isShowLv = (isShowLv and true) or false
    self._isSetItem = false
end

function XunXianItem:initLayer()
    if self._spirit.iType == SPIRIT_TYPE.EXP then
        Icon.setSpiritExpIcon(self:getNode("icon_bg"),0.6)
        self:updateExpLab()
        self:getNode("icon_choose"):setVisible(false)
    else
        Icon.setSpiritIcon(self._spirit.iType, self:getNode("icon_bg"))
        self:updateLab()
        self:getNode("icon_choose"):setVisible(false)
    end
end

function XunXianItem:updateLab()
    local name = gGetSpiritAttrNameByType(self._spirit.iType, self._spirit.iAttr)    
    local lab_name = self:getNode("lab_name")
    lab_name:setString(name)
    local color3b = gCreateSpiritNameColor(self._spirit.iType)
    lab_name:setColor(color3b)
    local lab_lv   = self:getNode("lab_lv")
    if self._isShowLv then
        lab_lv:setString(tostring(self._spirit.iLV))
        lab_lv:setVisible(true)
    else
        lab_lv:setVisible(false)
    end
end

function XunXianItem:setChoose()
    self._isChoose = not self._isChoose
    if self._isChoose then
        self:getNode("icon_choose"):setVisible(true)
    else
        self:getNode("icon_choose"):setVisible(false)
    end
end


function XunXianItem:onTouchEnded(target,touch, event)
    if target.touchName=="icon_bg"then
        if nil ~= self.onChoosed then
            self._isChoose = not self._isChoose
            self:onChoosed()
        end
    end
end

function XunXianItem:updateItem(spirit)
    if nil == spirit then
        return
    end

    self._spirit = spirit
    self._ID = spirit.iID
    self:setItem()
    self:getNode("lab_lv"):setString(tostring(self._spirit.iLV))
end

function XunXianItem:setLazyFunc(name)
    Scene.addLazyFunc(self,self.setItem, name)
end

function XunXianItem:setItem()
    if not self._isSetItem then
        self:init("ui/ui_xunxian_item.map")
        self:setAllChildCascadeOpacityEnabled(true)
        self:initLayer()
        self._isSetItem = true
    end
end

function XunXianItem:updateExpLab()    
    self:setLabelString("lab_name", SpiritInfo.exp)
    self:getNode("lab_lv"):setVisible(false)
end

function XunXianItem:setNameTxt(value)
    self:setLabelString("lab_name", value)
end

function XunXianItem:setLvTxt(value)
    self:setLabelString("lab_lv", value)
end


return XunXianItem