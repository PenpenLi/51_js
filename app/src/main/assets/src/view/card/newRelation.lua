local NewRelationPanel=class("NewRelationPanel",UILayer)


function NewRelationPanel:ctor(data)
    loadFlaXml("ui_effect");
    self:init("ui/ui_card_relation_jihuo.map")
    self.hideMainLayerInfo=true
    self.isWindow = true;
    self:getNode("center_panel"):setScale(0)
    local maxLevel=DB.getMaxRelationLevel(data.id)
    if(data.level>maxLevel)then
        data.level=maxLevel
    end
    local relation=DB.getRelationById(data.id,data.level)
    local cards=string.split(relation.cardlist,";")

    self.relationData={}
    self.relationData.id=data.id
    self.relationData.level=Data.getRelationLevelById(data.id)

    for i=1, 5 do
        self:getNode("star"..i):setVisible(false)
        self:getNode("icon"..i):setVisible(false)
    end
    
    for i=1, maxLevel do

        self:getNode("star"..i):setVisible(true)
    end

    self:getNode("fla"):playAction("ui_yuanfen_effect",nil,nil,0)

    local curIconIdx=1
    local delay = cc.DelayTime:create(1.5)


    if(data.id >= 1000)then
        self:getNode("txt_attr"..curIconIdx):setVisible(false)
        self:getNode("pet_attr"):setVisible(false)
        self:getNode("txt_info1_attr1"):setVisible(false)
        self:getNode("txt_info1_attr2"):setVisible(false)
        self:getNode("txt_info1_attr3"):setVisible(false)
        self:getNode("txt_info1_attr4"):setVisible(false)
        self:getNode("txt_info2_attr1"):setVisible(false)
        self:getNode("txt_info2_attr2"):setVisible(false)
        self:getNode("txt_info2_attr3"):setVisible(false)
        self:getNode("txt_info2_attr4"):setVisible(false)

        local txt_attr = CardPro.getAttrAddDesc(relation.attr,relation.attr_value)
        self:getNode("txt_info2_attr1"):setVisible(true)
        self:setLabelString("txt_info2_attr1",txt_attr) 
        if(relation.attr_value2 > 0) then
            txt_attr = CardPro.getAttrAddDesc(relation.attr2,relation.attr_value2)
            self:setLabelString("txt_info2_attr2",txt_attr) 
            self:getNode("txt_info2_attr2"):setVisible(true)
        end
        if(relation.attr_value3 > 0) then
            txt_attr = CardPro.getAttrAddDesc(relation.attr3,relation.attr_value3)
            self:setLabelString("txt_info2_attr3",txt_attr) 
            self:getNode("txt_info2_attr3"):setVisible(true)
        end
        if(relation.attr_value4 > 0) then
            txt_attr = CardPro.getAttrAddDesc(relation.attr4,relation.attr_value4)
            self:setLabelString("txt_info2_attr4",txt_attr) 
            self:getNode("txt_info2_attr4"):setVisible(true)
        end
        if(data.level == 1)then
            self:getNode("spr_arrow"):setVisible(false)
        else
            local oldrelation=DB.getRelationById(data.id,data.level-1)
            local txt_attr = CardPro.getAttrAddDesc(oldrelation.attr,oldrelation.attr_value)
            self:getNode("txt_info1_attr1"):setVisible(true)
            self:setLabelString("txt_info1_attr1",txt_attr) 
            if(relation.attr_value2 > 0) then
                txt_attr = CardPro.getAttrAddDesc(oldrelation.attr2,oldrelation.attr_value2)
                self:setLabelString("txt_info1_attr2",txt_attr) 
                self:getNode("txt_info1_attr2"):setVisible(true)
            end
            if(relation.attr_value3 > 0) then
                txt_attr = CardPro.getAttrAddDesc(oldrelation.attr3,oldrelation.attr_value3)
                self:setLabelString("txt_info1_attr3",txt_attr) 
                self:getNode("txt_info1_attr3"):setVisible(true)
            end
            if(relation.attr_value4 > 0) then
                txt_attr = CardPro.getAttrAddDesc(oldrelation.attr4,oldrelation.attr_value4)
                self:setLabelString("txt_info1_attr4",txt_attr) 
                self:getNode("txt_info1_attr4"):setVisible(true)
            end
        end
    else
        for key, cardid in pairs(cards) do
            cardid=toint(cardid)
            local node=self:getNode("icon"..curIconIdx)
            node:setVisible(true)
            
            
            local function onShowed(item,data)  
                local idx=data.idx
                local fla = gCreateFla("ui_jingyan_quan");
                node:addChild(fla,-1)
                fla:setPosition(self:getNode("txt_attr"..idx):getPosition())
     
                self:getNode("txt_attr"..idx):setVisible(true) 
            end
            local card = nil;
            if(data.id >= 1000)then
                card=Data.getUserPetById(cardid)
            else
                card=Data.getUserCardById(cardid)
            end
            gCreateRoleFla(cardid, self:getNode("container"..curIconIdx),1,false,"r"..cardid.."_wait",card.weaponLv,card.awakeLv);
            self:getNode("icon"..curIconIdx):setCascadeOpacityEnabled(true);
            self:getNode("icon"..curIconIdx):setOpacity(0)
            self:getNode("icon"..curIconIdx):runAction( cc.Sequence:create(delay,cc.FadeIn:create(0.7),cc.CallFunc:create(onShowed,{idx=curIconIdx})))

            local attrType= CardPro.cardPros["attr"..relation.attr]
            attrType=string.gsub(attrType,"Percent","")
            local value= math.floor( card[attrType.."_base"]*relation.attr_value/100)
            self:setLabelString("txt_attr"..curIconIdx,"+"..value) 
            self:getNode("txt_attr"..curIconIdx):setVisible(false)
            self:getNode("pet_attr"):setVisible(false)

            
            curIconIdx=curIconIdx+1
        end
    end

    local function shake()


        local pAct_move_left = cc.MoveBy:create(0.03, cc.p(10,0))
        local pAct_reverse_move_left = pAct_move_left:reverse()
        local actions={}
        table.insert(actions,pAct_move_left)
        table.insert(actions,pAct_reverse_move_left) 
        local pAct_repeat =cc.Repeat:create(cc.Sequence:create(actions), 2) 
        self:getNode("shake_panel"):runAction(pAct_repeat)

        if(data.id >= 1000)then
            self:getNode("pet_attr"):setOpacity(0)
            self:getNode("pet_attr"):runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.Show:create(),cc.FadeTo:create(0.3,255)));
        end

    end

    local function createStar()
        self:getNode("star"..data.level):setLocalZOrder(100)
        gAddCenter(gCreateFla("ui_yuanfen_xin",-1), self:getNode("star"..data.level))
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(createStar) ,cc.DelayTime:create(0.45),cc.CallFunc:create(shake) ))



    for i=1, data.level-1 do
        self:changeTexture("star"..i,"images/ui_public1/yuan_1.png")
    end

    if(data.id >= 1000)then
        self:getNode("txt_info"):setVisible(false)
    else
        self:getNode("txt_info"):setOpacity(0)
        local txt=gGetWords("labelWords.plist","relation_info5", CardPro.getAttrName(relation.attr) )
        self:setLabelString("txt_info",txt)
        self:getNode("txt_info"):runAction( cc.Sequence:create(delay,cc.FadeIn:create(0.7)))
    end

    self:resetLayOut()
    
    local function callback()
        self:getNode("btn_close"):setVisible(true)
    end
    
    performWithDelay(self:getNode("btn_close"),callback,2.5)
end

function NewRelationPanel:onTouchEnded(target)
    if(target.touchName=="btn_close" )then
        Panel.popBack(self:getTag())
    end
end

return NewRelationPanel