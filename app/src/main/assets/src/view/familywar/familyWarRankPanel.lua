
local FamilyWarRankPanel=class("FamilyWarRankPanel",UILayer)

function FamilyWarRankPanel:ctor(param)
    self:init("ui/ui_family_war_rank.map")    
    self.pScrollLayer = self:getNode("scroll"); 
    self.isMainLayerGoldShow = false;
    self:getNode("me_panel"):setVisible(false)
    self:updateList(param.list); 
end
 
function FamilyWarRankPanel:onPopback() 
    self.needRefresh=true
end
function FamilyWarRankPanel:onPopup() 
    if(self.needRefresh)then
        self.needRefresh=false
        Net.sendFamilyWeekExp()
    end
end

function FamilyWarRankPanel:dealEvent(event,param)

    if(event==EVENT_ID_FAMILY_WAR_SIGN_LIST)then 
        self:updateList(param.list); 
        if self.lastidx then
            self.pScrollLayer:moveItemByIndex(self.lastidx-1)
        end
    end
end
function  FamilyWarRankPanel:events() 
    return {EVENT_ID_FAMILY_WAR_SIGN_LIST }
end


function FamilyWarRankPanel:updateList(list) 
    
    Scene.clearLazyFunc("FamilyWarRankItem")
    self.pScrollLayer:clear();
    local myFamily=nil
    local preloadNum = 10
    for key,value in ipairs(list) do
        local item = self:createOneFamily(value,key,preloadNum<=1);
        item.longid=value.id
        self.pScrollLayer:addItem(item);
        if(item.curData.id==gFamilyInfo.familyId)then
            myFamily=item.curData
        end
        preloadNum=preloadNum-1
    end
    self.pScrollLayer:layout(count==0);
    if(myFamily~=nil)then
        self:getNode("me_panel"):setVisible(true)  
        self:replaceRtfString("txt_name",myFamily.sName);
        self:replaceRtfString("txt_rank",myFamily.iRank); 
        self:replaceRtfString("txt_power",myFamily.iPower); 
        self:replaceRtfString("txt_level",myFamily.iLevel);
        
        self:replaceRtfString("txt_exp",myFamily.iExp);
        self:replaceRtfString("txt_power",myFamily.iPower); 
    end
    self:resetLayOut()
end

function FamilyWarRankPanel:createOneFamily(data,index,isLazy)
    local item=FamilyWarRankItem.new();
    if isLazy and isLazy==true then
         item:setLazyData(data, index);
    else
        item:setData(data, index);
    end
    item.clickItemCallback=function (data,idx)
        self.lastidx=idx
    end

    item.selectItemCallback=function (data,idx)
        self:onApp(data,idx);
    end
    return item;
end

function FamilyWarRankPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then 
        self:onClose();
    elseif(target.touchName=="btn_my_team")then 
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_FAMILY_WAR)
    elseif target.touchName=="btn_family" then
        Net.sendFamilyTeamInfo(gFamilyInfo.familyId)
    end
end
 

return FamilyWarRankPanel