local PetRelationItem=class("PetRelationItem",UILayer)

function PetRelationItem:ctor(pos)
    self:init("ui/ui_lingshou_tujian_item.map")
    self.sort=0
end

function  PetRelationItem:createStar(container,star)
    for i=1, star do
        local icon=cc.Sprite:create("images/ui_public1/star1.png")
        container:addNode(icon)
    end
end

function PetRelationItem:refreshData(param)
    if(self.curData.relationid == param.id)then
        self:setData(self.curData);
    end
end

function  PetRelationItem:setData(data)
    self.curData = data;

    local title = DB.getRelationTitleById(data.relationid) 

    self:setLabelString("txt_name","【"..title.desc.."】"); 
 

    local cards=string.split(data.cardlist,";")
    self.relationData={}
    self.relationData.id=data.relationid
    self.relationData.level=Data.getRelationLevelById(data.relationid)

    local maxLevel=DB.getMaxRelationLevel(data.relationid)
    local curIconIdx=1
    for i=1, 4 do
        self:getNode("icon"..i):setVisible(false)
    end
    for i=1, 5 do
        self:getNode("star"..i):setVisible(false)
    end
    for i=1, maxLevel do
        self:getNode("star"..i):setVisible(true)
    end
    
    local activateEnable=false
    local hasAll=true
    local totalStar=0
    for key, cardid in pairs(cards) do
        cardid=toint(cardid)
        local node=self:getNode("icon"..curIconIdx)
        node:setVisible(true)
        node.cardid=cardid
        local card=Data.getUserPetById(cardid)
        if(card==nil)then
            DisplayUtil.setGray(node,true)
            hasAll=false
            Icon.setIcon(cardid,node,nil,nil,nil,false)
        else 
            -- Icon.setIcon(cardid,node,card.quality,card.awakeLv,nil,false)
            Icon.setIcon(cardid,node,DB.getItemQuality(cardid),card.awakeLv,nil,false)
            totalStar=totalStar+math.min(card.grade,5);  
            local bgStar=self:getNode("star_container"..curIconIdx)
            bgStar:removeAllChildren();
            CardPro:showNewStar(bgStar,card.grade, card.awakeLv,-10); 
        end
        curIconIdx=curIconIdx+1
    end
    
    if(self.relationData.level>maxLevel)then
        self.relationData.level=maxLevel
    end

    -- self:getNode("txt_info1"):setColor(cc.c3b(43,154,3))
    if(self.relationData.level==0)then
        activateEnable=hasAll
        local levelData=DB.getRelationById(data.relationid,1)
        self:getNode("panel_info2"):setVisible(false) 
        local txt=gGetWords("labelWords.plist","pet_relation_info1")
        self:setLabelString("txt_info1",txt)
        self:setLabelString("txt_info1_attr1",CardPro.getAttrAddDesc(levelData.attr,levelData.attr_value));
        if(levelData.attr_value2 > 0) then
            self:setLabelString("txt_info1_attr2",CardPro.getAttrAddDesc(levelData.attr2,levelData.attr_value2));
            self:getNode("txt_info1_attr2"):setVisible(true)
        else
            self:getNode("txt_info1_attr2"):setVisible(false)
        end
        if(levelData.attr_value3 > 0) then
            self:setLabelString("txt_info1_attr3",CardPro.getAttrAddDesc(levelData.attr3,levelData.attr_value3));
            self:getNode("txt_info1_attr3"):setVisible(true)
        else
            self:getNode("txt_info1_attr3"):setVisible(false)
        end
        if(levelData.attr_value4 > 0) then
            self:setLabelString("txt_info1_attr4",CardPro.getAttrAddDesc(levelData.attr4,levelData.attr_value4));
            self:getNode("txt_info1_attr4"):setVisible(true)
        else
            self:getNode("txt_info1_attr4"):setVisible(false)
        end
        
        if(hasAll==false)then
            -- self:getNode("txt_info1"):setColor(cc.c3b(113,62,51))
        end
    else 
        local levelData=DB.getRelationById(data.relationid,self.relationData.level)
        if(levelData)then
            local txt=gGetWords("labelWords.plist","pet_relation_info2")
            self:setLabelString("txt_info1",txt);
            self:setLabelString("txt_info1_attr1",CardPro.getAttrAddDesc(levelData.attr,levelData.attr_value));
            if(levelData.attr_value2 > 0) then
                self:setLabelString("txt_info1_attr2",CardPro.getAttrAddDesc(levelData.attr2,levelData.attr_value2));
            else
                self:getNode("txt_info1_attr2"):setVisible(false)
            end
            if(levelData.attr_value3 > 0) then
                self:setLabelString("txt_info1_attr3",CardPro.getAttrAddDesc(levelData.attr3,levelData.attr_value3));
            else
                self:getNode("txt_info1_attr3"):setVisible(false)
            end
            if(levelData.attr_value4 > 0) then
                self:setLabelString("txt_info1_attr4",CardPro.getAttrAddDesc(levelData.attr4,levelData.attr_value4));
            else
                self:getNode("txt_info1_attr4"):setVisible(false)
            end
        end
        
         for i=1, self.relationData.level do
            self:changeTexture("star"..i,"images/ui_public1/yuan_1.png") --   
        end 
        
    end
    if(self.relationData.level>=maxLevel)then
        self:getNode("panel_info2"):setVisible(false)
        self:getNode("btn_activate"):setVisible(false)
    else
        self:getNode("panel_info2"):setVisible(true)
        local levelData=DB.getRelationById(data.relationid,self.relationData.level+1)
        if(self.relationData.level==0)then
            levelData=DB.getRelationById(data.relationid,2)
        end
        local txt = ""
        txt=gGetWords("labelWords.plist","pet_relation_info3",levelData.param,totalStar)
        -- if gCurLanguage == LANGUAGE_EN then
        --     txt=gGetWords("labelWords.plist","pet_relation_info3",totalStar,levelData.param)
        -- else
        --     txt=gGetWords("labelWords.plist","pet_relation_info3",levelData.param,totalStar)
        -- end
        self:setRTFString("txt_info2",txt)
            self:setLabelString("txt_info2_attr1",CardPro.getAttrAddDesc(levelData.attr,levelData.attr_value));
            if(levelData.attr_value2 > 0) then
                self:setLabelString("txt_info2_attr2",CardPro.getAttrAddDesc(levelData.attr2,levelData.attr_value2));
                self:getNode("txt_info2_attr2"):setVisible(true)
            else
                self:getNode("txt_info2_attr2"):setVisible(false)
            end
            if(levelData.attr_value3 > 0) then
                self:setLabelString("txt_info2_attr3",CardPro.getAttrAddDesc(levelData.attr3,levelData.attr_value3));
                self:getNode("txt_info2_attr3"):setVisible(true)
            else
                self:getNode("txt_info2_attr3"):setVisible(false)
            end
            if(levelData.attr_value4 > 0) then
                self:setLabelString("txt_info2_attr4",CardPro.getAttrAddDesc(levelData.attr4,levelData.attr_value4));
                self:getNode("txt_info2_attr4"):setVisible(true)
            else
                self:getNode("txt_info2_attr4"):setVisible(false)
            end
         
        activateEnable=totalStar>=levelData.param and hasAll
        if(self.relationData.level==0)then
            activateEnable=hasAll
        end
    end
    
    self.activateEnable=activateEnable
    self:setTouchEnable("btn_activate",activateEnable,not activateEnable)
    self:resetLayOut() 

    self:setOpacityEnabled(true);
end


function PetRelationItem:onTouchEnded(target) 
    if target.touchName=="btn_activate" then
        Net.sendCardActivateRelation(self.relationData.id,self.relationData.level+1) 
    elseif string.find(target.touchName,"icon") then
        local data={}
        data.itemid=target.cardid
        data.ignoreReplace = true
        Panel.popUpVisible(PANEL_ATLAS_DROP,data) 
    end
end

    
return PetRelationItem