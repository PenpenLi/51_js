local SpiritIntroPanel=class("SpiritIntroPanel",UILayer)

function SpiritIntroPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_ysjs.map")
    if Module.isClose(SWITCH_DOUBLE_ATTR_SPIRIT) then
        self:getNode("btn_double_attr"):setVisible(false)
    end

    self.scrollLayer = self:getNode("scroll_ys_items")
    self.scrollLayer.eachLineNum=4
    self.scrollLayer.offsetX=26
    self.scrollLayer.offsetY=5
    self.scrollLayer:setPaddingXY(20,20)
    self.scrollLayer:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.detailIntroScroll = self:getNode("scroll_soullife_intro")
    self.detailIntroScroll.eachLineNum=1
    self.detailIntroScroll.offsetX=30
    self.detailIntroScroll.offsetY=10
    self.detailIntroScroll:setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self:selectBtn( "btn_gui")
    self.vSpiritList = {}
    self.selectedIdx = 1
    self:setScrollDisplay()
    self:setSoulLifeDetailIntro(self.vSpiritList[1])

    for i=1,6 do
        if(self:getNode("txt_title"..i))then
            self:getNode("txt_title"..i):setVisible(gIsZhLanguage());
        end
    end
    self:resetLayOut();
end

function SpiritIntroPanel:setScrollDisplay()

    self.vSpiritList = {}
    self.scrollLayer:clear()
    local idx = 1
    local attrTable = DB.getSpiritAttrTable(self.selectedIdx - 1, 1)
    for i = 1, #attrTable do
        local spirit = gCreateSpirit(0, self.selectedIdx - 1, attrTable[i].attr, 1, 0, 0, 0,0)
        local spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, idx, false)
        spiritItem.onChoosed = function(item)
            self:handleSpiritIntro(item._idx)
        end
        spiritItem:setItem()
        self.vSpiritList[#self.vSpiritList + 1] = spirit
        self.scrollLayer:addItem(spiritItem)
        idx = idx + 1
    end

    -- if self.selectedIdx ~= 9 then
    --     for i=1,10 do
    --         if i ~= Attr_AGILITY and i ~= Attr_MAGIC_ATTACK then
    --             local spirit = gCreateSpirit(0, self.selectedIdx - 1, i, 1, 0, 0, 0,0)
    --             local spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, idx, false)
    --             spiritItem.onChoosed = function(item)
    --                 self:handleSpiritIntro(item._idx)
    --             end
    --             spiritItem:setItem()
    --             self.vSpiritList[#self.vSpiritList + 1] = spirit
    --             self.scrollLayer:addItem(spiritItem)
    --             idx = idx + 1
    --         end
    --     end
    -- else
    --     local attrTable = DB.getSpiritAttrTable(SPIRIT_TYPE.DOUBLE_ATTR, 1)
    --     for i = 1, #attrTable do
    --         local spirit = gCreateSpirit(0, SPIRIT_TYPE.DOUBLE_ATTR, attrTable[i].attr, 1, 0, 0, 0,0)
    --         local spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, idx, false)
    --         spiritItem.onChoosed = function(item)
    --             self:handleSpiritIntro(item._idx)
    --         end
    --         spiritItem:setItem()
    --         self.vSpiritList[#self.vSpiritList + 1] = spirit
    --         self.scrollLayer:addItem(spiritItem)
    --         idx = idx + 1
    --     end
    -- end
    self.scrollLayer:layout()
    self:detailSelectDisplay(1)
end

function SpiritIntroPanel:onTouchEnded(target,touch, event)

    if target.touchName=="btn_close"then
        self:onClose()
    elseif target.touchName=="btn_gui" then
        self.selectedIdx = 1
        self:selectBtn("btn_gui")
        self:setScrollDisplay()
        self:setSoulLifeDetailIntro(self.vSpiritList[1])
    elseif target.touchName=="btn_ren" then
        self.selectedIdx = 2
        self:selectBtn("btn_ren")
        self:setScrollDisplay()
        self:setSoulLifeDetailIntro(self.vSpiritList[1])
    elseif target.touchName=="btn_di" then
        self.selectedIdx = 3
        self:selectBtn("btn_di")
        self:setScrollDisplay()
        self:setSoulLifeDetailIntro(self.vSpiritList[1])
    elseif target.touchName=="btn_shen" then
        self.selectedIdx = 4
        self:selectBtn("btn_shen")
        self:setScrollDisplay()
        self:setSoulLifeDetailIntro(self.vSpiritList[1])
    elseif target.touchName=="btn_tian" then
        self.selectedIdx = 5
        self:selectBtn("btn_tian")
        self:setScrollDisplay()
        self:setSoulLifeDetailIntro(self.vSpiritList[1])
    elseif target.touchName=="btn_double_attr" then
        self.selectedIdx = 9
        self:selectBtn("btn_double_attr")
        self:setScrollDisplay()
        self:setSoulLifeDetailIntro(self.vSpiritList[1])
    end
end

function SpiritIntroPanel:handleSpiritIntro(idx)
    if nil == idx then
        return
    end

    assert(idx <= #self.vSpiritList, "the idx  off normal upper")
    local spirit = self.vSpiritList[idx]
    if nil ~= spirit then
        self:setSoulLifeDetailIntro(spirit)
        self:detailSelectDisplay(idx)
    end
end

function SpiritIntroPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian1-1.png")
end

function SpiritIntroPanel:resetBtnTexture()
    local btns={
        "btn_gui",
        "btn_ren",
        "btn_di",
        "btn_shen",
        "btn_tian",
        "btn_double_attr",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian1.png")
    end
end

function SpiritIntroPanel:setSoulLifeDetailIntro(spirit)
    self.detailIntroScroll:clear()
    local lab_title = self:getNode("txt_soullife_title")
    lab_title:setString(gGetSpiritAttrNameByType(spirit.iType, spirit.iAttr))
    lab_title:setColor(gCreateSpiritNameColor(spirit.iType))
    local width = self:getNode("scroll_soullife_intro"):getContentSize().width
    local attrValue = ""
    for i = 1, DB.getSpiritMaxLev() do
        local spiritAttr  = DB.getSpiritAttr(spirit.iType, i, spirit.iAttr)
        if nil ~= spiritAttr then
            local lev = string.format("%s%d",getLvReviewName("LV."),i)
            if i < 10 then
                lev = lev .. "  "
            end
            if CardPro.isFloatAttr(spiritAttr.attr) then
                attrValue = spiritAttr.value .. "%"
            else
                attrValue = spiritAttr.value
            end
            local attr = "   " .. CardPro.getAttrName(spirit.iAttr) .. "+" .. attrValue
            local contentInfo = string.format("\\w{c=ff0000;s=18}%s\\w{c=000000;s=18}%s",lev, attr)

            local rtf = RTFLayer.new(width)
            rtf:setString(contentInfo)
            rtf:setAnchorPoint(cc.p(0,1))
            rtf:layout()
            self:getNode("scroll_soullife_intro"):addItem(rtf)
            if (spiritAttr.attr2 ~= 0) then
                if CardPro.isFloatAttr(spiritAttr.attr2) then
                    attrValue = spiritAttr.value2 .. "%"
                else
                    attrValue = spiritAttr.value2
                end
                rtf = RTFLayer.new(width)
                lev = "        "
                attr = "   " .. CardPro.getAttrName(spiritAttr.attr2) .. "+" .. attrValue
                contentInfo = string.format("%s\\w{c=000000;s=18}%s",lev,attr)
                rtf:setString(contentInfo)
                rtf:setAnchorPoint(cc.p(0,1))
                rtf:layout()
                self:getNode("scroll_soullife_intro"):addItem(rtf)
            end
            
        end
    end

    self.detailIntroScroll:layout()
end

function SpiritIntroPanel:detailSelectDisplay(idx)
    local detailSelectItem = self.scrollLayer:getItem(idx - 1)
    if nil ~= detailSelectItem then
        local posX,posY = detailSelectItem:getPosition()
        posX = posX + self.scrollLayer.itemWidth * 0.52
        posY = posY - self.scrollLayer.itemHeight * 0.44
        self:getNode("icon_choose"):setPosition(cc.p(posX,posY))
    end
end


return SpiritIntroPanel