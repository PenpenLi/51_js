local CardInfoProPanel=class("CardInfoProPanel",UILayer)

function CardInfoProPanel:ctor()
    self:init("ui/ui_card_pro.map")

    -- self.upPanelOldY=self:getNode("bg_scale9"):getPositionY()
    -- self.upPanelOldHeight=self:getNode("bg_scale9"):getContentSize().height
    -- self.downPanelOldY=self:getNode("down_panel"):getPositionY()
end


function CardInfoProPanel:setCard(card)
    self.curCard=card
    self.cardDb = DB.getCardById(self.curCard.cardid);

    if(self.introPanel==nil)then
        self.introPanel = self:createIntro(self.cardDb);
    else
        self:refreshIntro(self.introPanel,self.cardDb);
    end
    if(self.proDetailPanel==nil)then
        self.proDetailPanel = self:createProDetail(self.curCard);
    else
        self:refreshProDetail(self.proDetailPanel,self.curCard);
    end
    if(#self:getNode("scroll"):getAllItem()<=0)then
        self:getNode("scroll"):clear();
        self:getNode("scroll"):addItem(self.introPanel);
        self:getNode("scroll"):addItem(self.proDetailPanel);
    end
    self:getNode("scroll"):layout();
end

function CardInfoProPanel:onTouchEnded(target)



end

function CardInfoProPanel:createIntro(cardDb)
    local uilayer = UILayer.new();
    uilayer:init("ui/ui_card_pro_intro.map");
    self:refreshIntro(uilayer,cardDb);
    -- uilayer:setRTFString("txt_info",cardDb.des)
    -- --  uilayer:getNode("txt_info"):setAnchorPoint(cc.p(0,-0.5))
    -- local minHeight = 70;
    -- local height = uilayer:getNode("txt_info"):getContentSize().height;
    -- if height > minHeight then
    --     local extendH = height - minHeight;
    --     local size = uilayer:getNode("bg_scale9"):getContentSize();
    --     uilayer:getNode("bg_scale9"):setContentSize(cc.size(size.width,size.height+extendH));
    --     local uilayerSize = uilayer:getContentSize();
    --     uilayer:setContentSize(cc.size(uilayerSize.width,uilayerSize.height+extendH));
    -- end

    return uilayer;
end

function CardInfoProPanel:refreshIntro(uilayer,cardDb)
    local preHeight = uilayer:getNode("txt_info"):getContentSize().height;
    uilayer:setRTFString("txt_info",cardDb.des)
    --  uilayer:getNode("txt_info"):setAnchorPoint(cc.p(0,-0.5))
    local minHeight = 70;
    if(preHeight < minHeight)then
        preHeight = minHeight;
    end
    local height = uilayer:getNode("txt_info"):getContentSize().height;
    if(height < minHeight)then
        height = minHeight;
    end
    -- if height > minHeight then
        local extendH = height - preHeight;
        local size = uilayer:getNode("bg_scale9"):getContentSize();
        uilayer:getNode("bg_scale9"):setContentSize(cc.size(size.width,size.height+extendH));
        local uilayerSize = uilayer:getContentSize();
        uilayer:setContentSize(cc.size(uilayerSize.width,uilayerSize.height+extendH));
    -- end
    uilayer:setOpacityEnabled(true);
end

function CardInfoProPanel:createProDetail(card)
    local uilayer = UILayer.new();
    uilayer:init("ui/ui_card_pro_detail.map");

    self:refreshProDetail(uilayer,card);
    -- for key, pro in pairs( CardPro.cardPros) do
    --     if(uilayer:getNode("txt_"..pro))then
    --         local param2=""
    --         local param1=card[pro]
    --         if(card[pro.."_add"]~=0)then
    --             param2=" + "..card[pro.."_add"]
    --             param1=param1-card[pro.."_add"]
    --         end
            
    --         uilayer:setRTFString("txt_"..pro,gGetWords("labelWords.plist","card_pro_add",param1,param2))

    --     end
    -- end

    return uilayer;
end

function CardInfoProPanel:refreshProDetail(uilayer,card)

    for key, pro in pairs( CardPro.cardPros) do
        if(uilayer:getNode("txt_"..pro))then
            local param2=""
            local param1=math.rint(card[pro])
            if(card[pro.."_add"]~=0)then
                param2=" + "..card[pro.."_add"]
                param1=param1-card[pro.."_add"]
            end
            local attrIntValue = toint(string.gsub(key,"attr",""))
            local circleAdd = gConstellation.getGroupAndAchieveValue(attrIntValue)
            param1 = param1 + circleAdd
            
            uilayer:setRTFString("txt_"..pro,gGetWords("labelWords.plist","card_pro_add",param1,param2))

        end
    end    
    uilayer:setOpacityEnabled(true);
end

return CardInfoProPanel