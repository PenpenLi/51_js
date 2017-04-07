local CardInfoRelationItem=class("CardInfoRelationItem",UILayer)

function CardInfoRelationItem:ctor(pos)
    self:init("ui/ui_card_relation_item.map")
    self.sort=0
end

function  CardInfoRelationItem:createStar(container,star)
    for i=1, star do
        local icon=cc.Sprite:create("images/ui_public1/star1.png")
        container:addNode(icon)
    end
end

function  CardInfoRelationItem:setData(data)

    local title = DB.getRelationTitleById(data.relationid) 

    self:setLabelString("txt_name","【"..title.desc.."】"); 
 

    local cards=string.split(data.cardlist,";")
    self.relationData={}
    self.relationData.id=data.relationid
    self.relationData.level=Data.getRelationLevelById(data.relationid)

    local maxLevel=DB.getMaxRelationLevel(data.relationid)


    local curIconIdx=1
    for i=1, 5 do
        self:getNode("icon"..i):setVisible(false)
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
        local card=Data.getUserCardById(cardid)
        if(card==nil)then
            DisplayUtil.setGray(node,true)
            hasAll=false
            Icon.setIcon(cardid,node,nil,nil,nil,false)
        else 
            Icon.setIcon(cardid,node,card.quality,card.awakeLv,nil,false)
            totalStar=totalStar+card.grade  
            local bgStar=self:getNode("star_container"..curIconIdx)
            bgStar:removeAllChildren();
            CardPro:showNewStar(bgStar,card.grade,card.awakeLv,-10); 
        end
        curIconIdx=curIconIdx+1
    end
    
    
    
    if(self.relationData.level>maxLevel)then
        self.relationData.level=maxLevel
    end

    if(self.relationData.level==0)then
        activateEnable=hasAll
        local levelData=DB.getRelationById(data.relationid,1)
        self:getNode("panel_info2"):setVisible(false) 
        local txt=gGetWords("labelWords.plist","relation_info1",CardPro.getAttrName(levelData.attr),levelData.attr_value)
        self:setLabelString("txt_info1",txt);
        
        if(hasAll==false)then
            self:getNode("txt_info1"):setColor(cc.c3b(113,62,51))
        end
    else 
        local levelData=DB.getRelationById(data.relationid,self.relationData.level)
        if(levelData)then
            local txt=gGetWords("labelWords.plist","relation_info2",CardPro.getAttrName(levelData.attr),levelData.attr_value)
            self:setLabelString("txt_info1",txt);
        end
        
         for i=1, self.relationData.level do
            self:changeTexture("star"..i,"images/ui_public1/yuan_1.png") --   
        end 
        
    end
    if(self.relationData.level>=maxLevel)then
        self:getNode("panel_info2"):setVisible(false)
        self:getNode("btn_activate"):setVisible(false)
    else
        local levelData=DB.getRelationById(data.relationid,self.relationData.level+1)
        local txt = ""
        if gCurLanguage == LANGUAGE_EN then
            txt=gGetWords("labelWords.plist","relation_info3",totalStar,levelData.param,CardPro.getAttrName(levelData.attr),levelData.attr_value)
        else
            txt=gGetWords("labelWords.plist","relation_info3",levelData.param,totalStar,CardPro.getAttrName(levelData.attr),levelData.attr_value)
        end
        self:setRTFString("txt_info2",txt);
         
        activateEnable=totalStar>=levelData.param and hasAll
    end
    
    self.activateEnable=activateEnable
    self:setTouchEnable("btn_activate",activateEnable,not activateEnable)
    self:resetLayOut() 

    self:setOpacityEnabled(true);
end


function CardInfoRelationItem:onTouchEnded(target) 
    if target.touchName=="btn_activate" then
        Net.sendCardActivateRelation(self.relationData.id,self.relationData.level+1) 
    elseif string.find(target.touchName,"icon") then
        local data={}
        data.itemid=target.cardid
        data.ignoreReplace = true
        Panel.popUpVisible(PANEL_ATLAS_DROP,data) 
    end
end

    
return CardInfoRelationItem