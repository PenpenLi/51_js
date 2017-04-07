local TipTouchCountry=class("TipTouchCountry",UILayer)

function TipTouchCountry:ctor(country)
    self:init("ui/tip_country_info.map")
    
    if(gCurLanguage == LANGUAGE_EN)then
        self:getNode("bg"):setContentSize(cc.size(self:getNode("bg"):getContentSize().width+220,self:getNode("bg"):getContentSize().height));
    end
    
    Icon.changeCountryIcon(self:getNode("icon_country"),country)

    self:getNode("icon_activity"):setVisible(country==0)


    for i=1, 3 do
        self:getNode("buff"..i):setVisible(false)
    end
    
    local countryid=country
    if(countryid==0)then
        countryid=13
    end

   
    local buffs=DB.getCountryBuffs(countryid)
    local i=0
    for key, buffid in pairs(buffs) do
        local buff=DB.getBuffById(toint(buffid))
        if(buff)then
            i=i+1
            self:getNode("buff"..i):setVisible(true)
            self:setLabelString("txt_buff"..i, gGetBuffDesc(buff,1))
            if(country==0)then
                self:getNode("txt_buff"..i):setColor(cc.c3b(102,102,102))
            end
        end
    end
end



return TipTouchCountry