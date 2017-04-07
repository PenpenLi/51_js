local WeaponTransmitBuffItem=class("WeaponTransmitBuffItem",UILayer)
 

function WeaponTransmitBuffItem:ctor(type)

    self:init("ui/ui_weapon_transmit_buff_item.map")
 
end
 
function WeaponTransmitBuffItem:setData(db,var,lv1,lv2)
    if(db==nil)then 
        self:setRTFString("txt_info","")
        return
    end
    local str=gGetBuffDesc(db,1)
    local isLost=true
    local maxLv=lv1
    local word="\\w{c=ff0000,s=22}"..gGetWords("labelWords.plist","tranform_lost").."\\"
    if(lv2>=maxLv)then
        maxLv=lv2
        isLost=false 
        word="\\w{c=96ff00,s=22}"..gGetWords("labelWords.plist","tranform_activity").."\\"
    end
     
    
    if(lv2>=var.level)then 
        self:changeTexture("icon","images/ui_public1/n-di-kong2.png") 
        str="\\w{c=96ff00,s=22}"..str.."\\" 
        self:setRTFString("txt_num","\\w{c=96ff00,s=22}"..toint(var.level/6).."\\")
    else
        str="\\w{c=7c7c7c,s=22}"..str.."\\"
        self:setRTFString("txt_num","\\w{c=76594a,s=22}"..toint(var.level/6).."\\")
    end
    
    
    if lv2>lv1 then
        if(var.level>lv1 and var.level <=lv2 )then
            local word="\\w{c=96ff00,s=22}"..gGetWords("labelWords.plist","tranform_activity").."\\"
            str=str..word
        end
    elseif lv2<lv1 then
        local word="\\w{c=ff0000,s=22}"..gGetWords("labelWords.plist","tranform_lost").."\\"
        if var.level>lv2 and var.level <=lv1 then
            str=str..word
        end
    end

    local orgin_height = self:getNode("txt_info"):getContentSize().height;
    self:setRTFString("txt_info",str)
    local new_height = self:getNode("txt_info"):getContentSize().height;
    local offH = new_height - orgin_height;
    if(offH > 0)then
        self:setContentSize(cc.size(self:getContentSize().width,self:getContentSize().height+offH));
    end
    -- self:resetLayOut();
    -- self:setContentSize(cc.size(self:getContentSize().width,self:getNode("layout_bg"):getContentSize().height+8));
end


function WeaponTransmitBuffItem:onTouchEnded(target)
 
end
return WeaponTransmitBuffItem