local FamilySearchItem=class("FamilySearchItem",UILayer)

function FamilySearchItem:ctor(type)
   self.type = type;
end

function FamilySearchItem:initPanel() 
    self:init("ui/ui_family_search_item.map");

    print("FamilySearchItem:initPanel");
end

function FamilySearchItem:onTouchEnded(target)

	print("target name = "..target.touchName);

    if(target.touchName == "btn_app")then
       if(self.selectItemCallback)then
            self.selectItemCallback(self.curData,self.idx)
       end
    elseif(target.touchName == "icon")then
        -- if(self.type == FAMILY_SEARCH_TYPE_OTHER)then
            Panel.popUpVisible(PANEL_FAMILY_OTHERFAMILYINFO,self.curData);
        -- end   
    end

end

function FamilySearchItem:setData(data,index) 
    self:initPanel();
    self.idx = index;
    self.curData=data;


    self:setLabelString("txt_name",data.sName);
    -- self:setLabelString("txt_tip",data.sDec);
    self:setLabelString("txt_count","("..data.iMemNum.."/"..Data.getFamilyMaxMem(data.iLevel)..")");
    self:setLabelString("txt_level",getLvReviewName("Lv.")..data.iLevel);
    self:setLabelString("txt_total_fexp",data.totalFExp);
    -- self:changeTexture("icon","images/ui_family/bp_icon_"..data.icon..".png");
    Icon.setFamilyIcon(self:getNode("icon"),data.icon,data.id);

    local word = gGetWords("familySearchWord.plist","btn1")
    if data.bNoNeedApp then
    	word = gGetWords("familySearchWord.plist","btn4")
    elseif data.bApped then
    	word = gGetWords("familySearchWord.plist","btn3");
	end
	self:setLabelString("txt_btn_word",word);
    
    -- Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(data.itemid))
    self:resetLayOut();
end

function FamilySearchItem:setBtnCheck()
    word = gGetWords("familySearchWord.plist","btn5");
    self:setLabelString("txt_btn_word",word);
end

return FamilySearchItem