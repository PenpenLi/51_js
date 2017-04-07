local SoulListPanel=class("SoulListPanel",UILayer)

function SoulListPanel:ctor()
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_soullist.map");

    self:getNode("scroll").eachLineNum = 5;
    local showCard = {};
    for key,var in pairs(card_db) do
        if(var.show == true and toint(var.soulbox) == 1) then
            table.insert(showCard,var);
            -- local item = DropItem.new();
            -- -- if(var.iflight == 1) then
            -- --     item:addSpeEffectForSoul();
            -- -- end
            -- item:setData(toint("1"..var.cardid));
            -- item:setNum(0);
            -- self:getNode("scroll"):addItem(item);
        end
    end

    local sortFun = function(card1,card2)
        return toint(card1.supercard) > toint(card2.supercard);
    end
    table.sort(showCard,sortFun);

    for key,var in pairs(showCard) do
        local item = DropItem.new();
        item:setData(toint("1"..var.cardid));
        item:setNum(0);
        self:getNode("scroll"):addItem(item);
    end

    self:getNode("scroll"):layout();

end

function SoulListPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end

end


return SoulListPanel