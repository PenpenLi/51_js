local MineAtlasItem=class("MineAtlasItem",UILayer)

function MineAtlasItem:ctor(idx)
    self:init("ui/ui_mine_atlas_item.map")
    self.mapId=idx
    self.masteryLimit=true
    self:setPanelInfo()
    self:setBoxShow()
    self:setArrowShow()
    self:moveAction(20)
end

function MineAtlasItem:onTouchEnded(target, touch, event)
    if  target.touchName == "icon" then
        if not gDigMine.checkMasteryLimit(self.mapId) and 
            gDigMine.canChallengeCurMap(self.mapId) then
            -- gDigMine.mapId = self.mapId
            Net.sendMiningChapInfo(self.mapId)
        end
    elseif target.touchName == "btn_box" then
        Panel.popUpVisible(PANEL_MINE_ATLAS_BOX,self.mapId,4)
    end
end

function MineAtlasItem:setPanelInfo()
    local chapterInfo = DB.getMineAtlasChapterInfo(self.mapId)
    if nil == chapterInfo then
        return
    end
    self:changeTexture("icon", string.format("images/ui_digmine/%d.png", self.mapId))
    self:setLabelString("txt_name", chapterInfo.name)
    if gDigMine.mastery < chapterInfo.mastery then
        self:getNode("layer_mastery_lim"):setVisible(true)
        self:setLabelString("txt_mastery_lim", gGetWords("mineWords.plist","skill_exp_lock",chapterInfo.mastery))
        self:setTouchEnable("icon", false,true)
    else
        self:getNode("layer_mastery_lim"):setVisible(false)
        self.masteryLimit = false
        self:setTouchEnable("icon", true, false)
    end
end

function MineAtlasItem:setBoxShow()
    if #gDigMine.perfectBoxInfos == 0 or self.masteryLimit then
        self:getNode("btn_box"):setVisible(false)
        return
    end
    local perfectInfo = gDigMine.perfectBoxInfos[self.mapId]
    if nil ~= perfectInfo and perfectInfo.status ~= 2 then
        self:getNode("btn_box"):setVisible(true)
        if perfectInfo.status == 1 then
            loadFlaXml("ui_wakuang")
            local flaBox = gCreateFla("ui_fight_icontan_xiangzi",1)
            self:replaceNode("btn_box", flaBox)
            self:addTouchNode(flaBox,"btn_box")
            local sprite = cc.Sprite:create("images/ui_digmine/pao.png")
            gAddCenter(sprite, self:getNode("btn_box"))
        end
    else
        self:getNode("btn_box"):setVisible(false)
    end
end

function MineAtlasItem:setArrowShow()
    if gDigMine.mapId ~= 0 and gDigMine.mapId == self.mapId then
        self:getNode("fla_arrow"):setVisible(true)
    else
        self:getNode("fla_arrow"):setVisible(false)
    end
end

function MineAtlasItem:moveAction(distance)
    local offset = distance
    local action = nil
    local time = 1.5
    if self.mapId % 2 == 0 then
        self:setPositionY(self:getPositionY() - distance * 2);
        action = cc.Sequence:create( cc.MoveBy:create(time,cc.p(0,offset)),cc.MoveBy:create(time,cc.p(0,-offset)) );
    else
        self:setPositionY(self:getPositionY() + distance * 2);
        action = cc.Sequence:create( cc.MoveBy:create(time,cc.p(0,-offset)),cc.MoveBy:create(time,cc.p(0,offset)) );
    end

    
    local repeatAction = cc.RepeatForever:create(action);
    repeatAction:setTag(1);
    self:runAction(repeatAction);
end

return MineAtlasItem