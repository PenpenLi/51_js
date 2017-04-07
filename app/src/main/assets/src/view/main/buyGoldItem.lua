local BuyGoldItem=class("BuyGoldItem",UILayer)
function BuyGoldItem:ctor(data,data1,index)
    self:init("ui/ui_buy_gold_item.map")
    self.index = index;
    
    -- txt_name
    -- txt_time
    -- txt_info
    -- local txt=gParserDay(data.addtime)
    -- self:setLabelString("txt_time",txt)
    -- self:setLabelString("txt_info","")
    -- self:setLabelString("txt_info",data.content)
    if (data<=1) then
        data = "";
    else
        data = "X"..data;
    end
    self:replaceRtfString("txt_content",data1.needDia,data1.gold,data);
end


return BuyGoldItem