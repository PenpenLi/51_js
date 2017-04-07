local ConstellationGroupItem=class("ConstellationGroupItem",UILayer)

function ConstellationGroupItem:ctor(circleId,groupId)
    self.circleId = circleId
    self.groupId = groupId
    self.inited = false
end

function ConstellationGroupItem:initPanel()

    local groupInfo = self.groupInfo
    local isActive = gConstellation.isGroupActived(self.circleId, self.groupId)
    self.starNum = gConstellation.getStarNumByGroupMap(self.circleId, self.groupId)
    self:showGroupBtnStatus(isActive,self.canStar,self.starNum)

    local showGroupInfo = groupInfo
    if isActive and self.canStar and gConstellation.showStarViewLv() then
        local nextStar = self.starNum+1
        if nextStar>groupInfo.star then
            nextStar=groupInfo.star
        end
        showGroupInfo = DB.getCircleGroupStar(self.groupId,nextStar)
    end
    
    -- 是否满足激活条件
    local isSatisfy = true
    for i = 1, 5 do
        local iconId = showGroupInfo["conid"..i]
        if iconId ~= 0 then
            local iconName = (DB.getConstellationsItemInfo(iconId) or {})["name"]
            local connum = showGroupInfo["connum"..i]
            self:getNode("txt_num"..i):setVisible(false)
            if connum~=nil then
                self:getNode("txt_num"..i):setVisible(true)
                self:setLabelString("txt_num"..i,Data.getItemNum(iconId).."/"..connum)
            end
            self:setLabelString("txt_name"..i,iconName)
            Icon.setIcon(iconId,self:getNode("icon"..i))
            local num = gConstellation.getConstellationItemNum(iconId)
            if isActive and gConstellation.showStarViewLv() then
                if self.canStar and num < connum and self.starNum~=groupInfo.star  then
                    isSatisfy = false
                    DisplayUtil.setGray(self:getNode("icon"..i))
                end
            else
                if num == 0 then
                    isSatisfy = false
                    DisplayUtil.setGray(self:getNode("icon"..i))
                end
            end          
        else
            self:getNode("icon"..i):setVisible(false)
        end
    end

    self:getNode("txt_attr"):setColor(cc.c3b(0, 255, 0))
    if not isActive then
        self:setTouchEnable("btn_active", isSatisfy, not isSatisfy)
        self:getNode("txt_attr"):setColor(cc.c3b(255, 255, 255))
    end

    if isActive and self.canStar and gConstellation.showStarViewLv() and self.starNum~=groupInfo.star then
        self:setTouchEnable("btn_star", isSatisfy, not isSatisfy)
        self:getNode("txt_attr"):setColor(cc.c3b(255, 255, 255))
    end

    if showGroupInfo.attr then
        local attrName = CardPro.getAttrName(showGroupInfo.attr)
        local attrValue = CardPro.getAttrValue(showGroupInfo.attr,showGroupInfo.param)
        self:setLabelString("txt_attr", attrName..":+"..attrValue)
    else
        local formatValue = ""
        for i=1,3 do
            local attrtype = showGroupInfo["attr"..i]
            if attrtype>0 then
                local attrName = CardPro.getAttrName(attrtype)
                local attrValue = CardPro.getAttrValue(attrtype,showGroupInfo["param"..i])
                formatValue = formatValue .. string.format("%s:+%s  ", attrName,attrValue)
            end
        end
         formatValue = string.trim(formatValue)
         self:setLabelString("txt_attr", formatValue)
    end
    self:getNode("layout_bg"):layout()
end

function ConstellationGroupItem:onTouchEnded(target,touch, event)
    if target.touchName == "btn_active" then
        Net.sendConstellationGroupAcitve(self.circleId, self.groupId)
    elseif target.touchName == "btn_star" then
        if Data.getCurLevel()<gConstellation.getStarUnLockLv() then
            gShowNotice(gGetWords("unlockWords.plist","unlock_tip_pos",gConstellation.getStarUnLockLv()))
            return
        end
        Net.sendCircleStarUpgrade(self.groupId)
    elseif target.touchName == "btn_rule" then
        Panel.popUp(PANEL_CONSTEL_GROUP_STAR,self.circleId,self.groupId)
    end
end

function ConstellationGroupItem:showGroupBtnStatus(isActive,isstar,starNum)
    self:getNode("star_layout"):setVisible(false)
    self:getNode("btn_rule"):setVisible(false)
    if isActive==false then
        self:getNode("btn_active"):setVisible(true)
        self:getNode("active_yes"):setVisible(false)
        self:getNode("btn_star"):setVisible(false)
        self:getNode("active_fullstar"):setVisible(false)
    else
        if isstar == true and gConstellation.showStarViewLv() then
            self:getNode("star_layout"):setVisible(true)
            for i=1,5 do
                self:getNode("star"..i):setVisible(self.groupInfo.star>=i)
                if starNum>=i then
                    self:changeTexture("star"..i, "images/ui_public1/star1.png")
                else
                    self:changeTexture("star"..i, "images/ui_public1/star1-1.png")
                end
            end
            self:getNode("star_layout"):layout()
            self:getNode("btn_rule"):setVisible(true)
            if starNum == self.groupInfo.star then
                self:getNode("btn_active"):setVisible(false)
                self:getNode("active_yes"):setVisible(false)
                self:getNode("btn_star"):setVisible(false)
                self:getNode("active_fullstar"):setVisible(true)
            else
                self:getNode("btn_active"):setVisible(false)
                self:getNode("active_yes"):setVisible(false)
                self:getNode("btn_star"):setVisible(true)
                self:getNode("active_fullstar"):setVisible(false)
            end
        else
            self:getNode("btn_active"):setVisible(false)
            self:getNode("active_yes"):setVisible(true)
            self:getNode("btn_star"):setVisible(false)
            self:getNode("active_fullstar"):setVisible(false)
        end
    end
end


function ConstellationGroupItem:activeGroup()
    --self:showGroupBtnStatus(true,self.canStar,self.starNum)
    self:initPanel()
end

function ConstellationGroupItem:RefreshStarUpgrade()
    self:initPanel()
end

function ConstellationGroupItem:setData()
    if self.inited then
        return
    end

    self.inited = true
    self:init("ui/ui_constellation_group_item0.map")

    self.groupInfo = DB.getConstellationGroupInfo(self.groupId)
    self.canStar = self.groupInfo.star>0
    self:setLabelString("txt_name", self.groupInfo.name)

    self:initPanel()
end

function ConstellationGroupItem:setLazyData()
    Scene.addLazyFunc(self,self.setDataLazyCalled,"constellationGroupItem")
end

function  ConstellationGroupItem:setDataLazyCalled()
    self:setData()
end



return ConstellationGroupItem
