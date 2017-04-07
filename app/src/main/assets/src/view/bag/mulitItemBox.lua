local MulitItemBox=class("MulitItemBox",UILayer)

function MulitItemBox:ctor()
    loadFlaXml("ui_kuang_texiao");
    
    self:init("ui/ui_tool_buytimes_item.map")
    self:setCascadeOpacityEnabled(false);
    self.selectCallBack = nil
end


function MulitItemBox:onTouchBegan(target,touch)

end

function MulitItemBox:onTouchMoved(target,touch)

end


function MulitItemBox:onTouchEnded(target)
    if(target.touchName == "btn_select")then
        if self.selectCallBack~=nil then
            self.selectCallBack(self.index)
        end
    end
end

function  MulitItemBox:changeBtnSelectTexture(sel)
    if sel == true then
        self:changeTexture("btn_select","images/ui_public1/n-di-gou2.png")
    else
        self:changeTexture("btn_select","images/ui_public1/n-di-gou1.png")
    end
end

function  MulitItemBox:setNum(num)
    num = num or 0;
    self:getNode("txt_num"):setVisible(num>0)
    if(self.result==nil)then
        self:setLabelString("txt_num",self.curData)
    else
        local num1,needShort = gGetNumForShort(num,1000000,false);
        if needShort then
            self:setLabelString("txt_num",num1.."w")
        else
            self:setLabelString("txt_num",num1)
        end
    end
end
function   MulitItemBox:setData(itemid,quality,hideLight,awakeLv)
    itemid = DB.checkReplaceItem(itemid);

    self.curData=itemid
    if(quality == nil) then
        quality = DB.getItemQuality(itemid);
    end
    if(self:getNode("txt_name"))then
        self:setLabelString("txt_name",DB.getItemName(itemid))
    end
    self.result= Icon.setIcon(toint(itemid),self:getNode("icon"),quality,awakeLv)
    
    local sum = Data.getItemNum(itemid)
    local num,needShort = gGetNumForShort(sum,1000000,false);
    if needShort then
        self:replaceLabelString("txt_itemnum",num.."w")
    else
        self:replaceLabelString("txt_itemnum",sum)
    end

    -- print("itemid = "..itemid);
    if(DB.getSoulNeedLight(itemid) and hideLight==nil)then
        self:addSpeEffectForSoul();
    end
end

function MulitItemBox:addSpeEffectForSoul()
    local fla=gCreateFla("ui_kuang_guang",1);
    fla:setTag(100);
    fla:setLocalZOrder(100);
    --gAddChildByAnchorPos(self:getNode("icon"),fla,cc.p(0.5,-0.5));
    gAddChildInCenterPos(self:getNode("icon"),fla);
end


return MulitItemBox