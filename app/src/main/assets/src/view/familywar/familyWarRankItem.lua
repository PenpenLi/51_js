local FamilyWarRankItem=class("FamilyWarRankItem",UILayer)

function FamilyWarRankItem:ctor()
    self:init("ui/ui_family_war_rank_item.map");

end

function FamilyWarRankItem:onTouchEnded(target)
 
    if(target.touchName=="btn_view")then
        if self.clickItemCallback then
            self.clickItemCallback(self.curData,self.idx)
        end
        Net.sendFamilyTeamInfo(self.curData.id)
    end  
end

function FamilyWarRankItem:setData(data,index)  
    self.idx = index;
    self.curData=data;
    local rank=data.iRank
    if (rank>3) then
        self:setLabelAtlas("txt_rank",rank)
        self:getNode("icon_rank"):setVisible(false)
        self:getNode("rank_123"):setVisible(false)
    else
        self:getNode("txt_rank"):setVisible(false)
        self:changeTexture("icon_rank","images/ui_jingji/no."..rank..".png");
    end
    self:setLabelString("txt_name",data.sName);
   -- self:setLabelString("txt_rank",data.iRank);
    -- self:setLabelString("txt_tip",data.sDec);
    self:setLabelAtlas("txt_exp",data.iExp);
    self:replaceLabelString("txt_power",data.iPower);
    self:setLabelString("txt_mas_name",data.sMasName);
    self:setLabelString("txt_level",getLvReviewName("Lv.")..data.iLevel);
    Icon.setFamilyIcon(self:getNode("icon") ,data.icon,data.id);
 
    self:getNode("me_panel"):setVisible(gFamilyInfo.familyId==data.id)
end

 function  FamilyWarRankItem:setDataLazyCalled()
    self:setData(self.lazyData,self.index,self.lazyTagType)
end

 function  FamilyWarRankItem:setLazyData(data,index,tagType)
    self.curData=data
    self.lazyData=data
    self.index=index
    self.lazyTagType=tagType
    Scene.addLazyFunc(self,self.setDataLazyCalled,"FamilyWarRankItem")
end



return FamilyWarRankItem