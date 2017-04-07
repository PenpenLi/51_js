


function TreasurePanel:initQuenchPanel()
    if(self.quenchPanel~=nil)then
        self.quenchPanel:setVisible(true)
        self:initQuenchData()
        return
    end

    self.lastStoneNum=0
    self.quenchPanel=UILayer.new()
    self.quenchPanel:init("ui/ui_treasure_quench.map")
    self.quenchPanel:setPositionY(self:getNode("panels"):getContentSize().height);
    self:getNode("panels"):addChild(self.quenchPanel)

    if(gUserInfo.level<DB.getClientParam("ONEKEY_QUENCH_OPEN_LV",true))then
        self.quenchPanel:getNode("btn_one_key"):setVisible(false) 
    end
    
    self:initQuenchData()
    local attrData=DB.getTreasureUpdateMaster(1,10)
    
    for i=1, 3 do
        local attr=attrData["attr"..i]
        self.quenchPanel:setLabelString("txt_pm_attr"..i, CardPro.getAttrName(attr))
        self.quenchPanel:setLabelString("txt_nm_attr"..i, CardPro.getAttrName(attr)) 
        if(CardPro.getAttrName(attr)=="")then
            self.quenchPanel:getNode("attr_pre_panel"..i):setVisible(false)
            self.quenchPanel:getNode("attr_next_panel"..i):setVisible(false)
        end
        
    end

    for key, var in pairs(QuenchStone) do
        local db=DB.getItemById(var)
        Icon.setIcon(var,self.quenchPanel:getNode("icon"..key),db.quality)
        self.quenchPanel:setLabelString( ("txt_add"..key),"+"..db.param)
        self.quenchPanel:getNode("icon"..key).exp=db.param
        self.quenchPanel:getNode("icon"..key).__touchend=true
    end


    self.quenchPanel.onTouchBegan=function (quench,target)
        if(string.find(target.touchName,"icon"))then
            self.isMoved=false
            self.curDt=0
            self.curPutSpeed=0.5
            local idx=toint( string.gsub(target.touchName,"icon",""))
            local function updatePut(dt)
                self.curDt=self.curDt+dt

                if(self.curDt>self.curPutSpeed)then
                    self.curDt=self.curDt-self.curPutSpeed 
                    self.curPutSpeed=self.curPutSpeed-0.09
                    if(self.curPutSpeed<0.1)then
                        self.curPutSpeed=0.1
                    end
                    self:touchIcon(idx)
                end
            end
 
            self.quenchPanel:scheduleUpdateWithPriorityLua(updatePut,1)
        elseif  target.touchName=="btn_rule"then
            gShowRulePanel(SYS_TREASURE_QUENCH)
        end
    end

    self.quenchPanel.onTouchMoved=function(quench,target,touch)
        local offsetX=touch:getDelta().x;
        local offsetY=touch:getDelta().y;
        if(math.sqrt(offsetX*offsetX+offsetY*offsetY)>5)then
            self.isMoved=true
        end
        if(self.isMoved)then
            self.quenchPanel:unscheduleUpdate()
        end
    end

    self.quenchPanel.onTouchEnded=function (quench,target)
        if(string.find(target.touchName,"icon"))then
            local idx=toint( string.gsub(target.touchName,"icon",""))
            self:touchIcon(idx)
            self.quenchPanel:unscheduleUpdate()
            self:checkSendQuench()
            self.isShowNotice=false
            
        elseif target.touchName=="btn_one_key" then
            Panel.popUp(PANEL_TREASURE_ONE_KEY,self.lastTreasure)
        end
    end
    self.quenchPanel:resetLayOut()
end

function TreasurePanel:checkSendQuench()
    if(self.lastStone and self.lastStoneNum>0 and self.lastTreasure)then 
        Net.sendTreasureQuench(self.lastTreasure.id,self.lastStone,self.lastStoneNum)
        self.lastStone=nil
        self.lastStoneNum=0
        Data.checkNum()
   end

end

function TreasurePanel:touchIcon(idx)
    local stone= QuenchStone[idx]
    local num=Data.getItemNum(stone)
    if(num<=0)then
        return 
    end

    if(self.lastStone~=stone and self.lastStone)then
        self:checkSendQuench()
    end
    if(self:addStoneExp(idx,1))then 
        self.lastStone=stone
        self.lastStoneNum= self.lastStoneNum+1
        Data.reduceItemNum(stone,1)
        self:initQuenchData(true)
    end
   
end

function TreasurePanel:getQuenchNeedExp(level,db)
    local nextLevelData=DB.getTreasureQuench(level,db.type)
    if(nextLevelData)then
        return math.floor(nextLevelData.exp* DB.getTreasureQuanchParam(db.quality)/100),nextLevelData
    end
    return 0
end

function TreasurePanel:addStoneExp(idx,num)
    local exp=self.quenchPanel:getNode("icon"..idx).exp
    local totalExp=exp*num
    local treasure=self.lastTreasure

    if(treasure.quenchLevel>=math.floor(gUserInfo.level/2))then 
        if(self.isShowNotice==true)then
            return
        end 
        self.isShowNotice=true
        gShowNotice(gGetWords("treasureWord.plist","full_quench_level"))
        return false
    end
 
    local preLevel=treasure.quenchLevel 
    local preExp=treasure.quenchExp 
     
    local curLevel=treasure.quenchLevel 
    local curExp=treasure.quenchExp+totalExp
    local treasureDb=DB.getTreasureById(treasure.itemid)
    while(true)do 
        local needExp=self:getQuenchNeedExp(curLevel+1,treasureDb)
        if(needExp==0 or curExp<needExp)then
            break
        end 
        curExp=curExp-needExp
        curLevel=curLevel+1
    end 
   

    self:addParticle(idx)
    treasure.quenchLevel=curLevel
    treasure.quenchExp=curExp
    Net.sortTreasure(treasure) 
  
    local function showAnim()   
        local needExp=self:getQuenchNeedExp(preLevel+1,treasureDb) 
        self.quenchPanel:replaceLabelString("txt_level",preLevel)
        if(needExp~=0)then 
            if(curLevel==preLevel)then 
                self.quenchPanel:setLabelString("txt_exp",curExp.."/"..needExp)
              --  self.quenchPanel:getNode("bar_exp").oldPerValue=-1 
                self.quenchPanel:setBarPer("bar_exp", curExp/needExp)  
                preExp=curExp 
                preLevel=curLevel 
                self:showTreasureInfo()  
            else 
                self.quenchPanel:setLabelString("txt_exp",preExp.."/"..needExp)
                local per=preExp/needExp
               -- self.quenchPanel:getNode("bar_exp").oldPerValue=-1 
                preExp=0
                preLevel=preLevel+1
                self.quenchPanel:setBarPer ("bar_exp", per)   
                self:showTreasureInfo()  
                self:showUpQuench() 
            end
        end  
    end
 
    showAnim() 
    return true
end

function TreasurePanel:addParticle(idx)

    local particle =  cc.ParticleSystemQuad:create("particle/qp_lizi.plist");
    self.quenchPanel:getNode("txt_exp"):getParent():addChild(particle,100);
    local toWordPos= self.quenchPanel:getNode("icon"..idx):convertToWorldSpace(cc.p(0,0))
    local toPos =self.quenchPanel:getNode("txt_exp"):getParent():convertToNodeSpace(toWordPos)
    toPos.x=toPos.x+self.quenchPanel:getNode("icon"..idx):getContentSize().width/2
    toPos.y=toPos.y+self.quenchPanel:getNode("icon"..idx):getContentSize().height/2
    particle:setPosition(toPos)
    local posx,posy=self.quenchPanel:getNode("txt_exp"):getPosition()
    local function moveEnd()
        particle:removeFromParent()

        loadFlaXml("particle")
        self.quenchPanel:getNode("layer_levelup"):removeChildByTag(99)
        local effect=gCreateFla("qp_kapai_lizi_b")
        effect:setTag(99)
        gAddCenter(effect,self.quenchPanel:getNode("layer_levelup"))
    end
    
    local callFunc=cc.CallFunc:create(moveEnd)
    particle:runAction(
        cc.Sequence:create(
            cc.EaseOut:create(cc.MoveTo:create(0.4,cc.p(posx,posy)),2),
            callFunc
        )
    )
end

function TreasurePanel:refreshQuenchData()
    for i=1, 4 do
        local stone= QuenchStone[i]
        local num=Data.getItemNum(stone)  
        self.quenchPanel:setLabelString( "txt_num"..i,num)
        
    end
end


function  TreasurePanel:showUpQuench() 

    local curCard=Data.getUserCardById(self.curCardid)
    local oldCard=clone(curCard )
    CardPro.setCardAttr( curCard,nil,oldCard)
    if(self.cardPanel)then
        self.cardPanel:showUpquality()
    end 

    if(self.quenchPanel)then 
        self:showEffect(self.quenchPanel:getNode("effect_container"))
    end
end
function TreasurePanel:initQuenchMaster(card,levelup)
    self.curCard=card
    local minLevel=1000
    local isFull=true
    for i=1, 4 do
        local treasure=Data.getTreasureById(card["treasure"..i])
        if(treasure)then
            if(minLevel>treasure.quenchLevel)then
                minLevel=treasure.quenchLevel
            end 
        else
            isFull=false
        end
    end
    
    if(isFull==false)then
       minLevel=0
       levelup=false
    end

    for i=1, 3 do
        self.quenchPanel:setLabelString("txt_pm_value"..i, "+0")
        self.quenchPanel:setLabelString("txt_nm_value"..i, "+0")
    end

    local attrData=DB.getTreasureUpdateMaster(1,minLevel)
    local curLevel=0

    if(attrData)then
        curLevel=attrData.level
        for i=1, 3 do
            local attr=attrData["attr"..i]
            local value=attrData["param"..i] 
            self.quenchPanel:setLabelString("txt_pm_value"..i, "+"..CardPro.getAttrValue(attr,value)) 
        end
    end
    local oldLevel=self.quenchPanel:getNode("txt_cur_level").level
    if(oldLevel and curLevel>oldLevel and levelup)then 
        self:showMasterEffect(gGetWords("treasureWord.plist","11"),curLevel)
    end
    
    self.quenchPanel:replaceLabelString("txt_next_level",curLevel+1)
    self.quenchPanel:replaceLabelString("txt_cur_level",curLevel)
    self.quenchPanel:getNode("txt_cur_level").level=curLevel
    self.quenchPanel:replaceLabelString("txt_cur_level2",0)
    attrData=DB.getTreasureUpdateMasterByLevel(1,curLevel+1)
    if(attrData)then
        self.quenchPanel:replaceLabelString("txt_cur_level2",attrData.needlv)
        for i=1, 3 do
            local attr=attrData["attr"..i]
            local value=attrData["param"..i] 
            self.quenchPanel:setLabelString("txt_nm_value"..i, "+"..CardPro.getAttrValue(attr,value)) 
        end
    end
end

function TreasurePanel:initQuenchData(levelup)
    if(self.quenchPanel==nil or  self.quenchPanel:isVisible()==false)then
        return
    end
    local card=Data.getUserCardById(self.curCardid)
   
    self:initQuenchMaster(card,levelup)
    self:refreshQuenchData() 
    self.quenchPanel:changeTexture("icon","images/ui_public1/ka_d1.png")
    self.quenchPanel:getNode("icon"):removeAllChildren() 
    self.quenchPanel:getNode("attr_panel"):setVisible(false)
    self.quenchPanel:setLabelString("txt_name","")
    
    self.quenchPanel:getNode("txt_level"):setVisible(false)
    self.quenchPanel:getNode("txt_exp"):setVisible(false)
    self.quenchPanel:getNode("bar_exp"):setVisible(false)
    
    if( self.lastTreasure)then
        local treasure=self.lastTreasure
        self.quenchPanel:getNode("txt_exp"):setVisible(true)
        self.quenchPanel:getNode("txt_level"):setVisible(true)
        self.quenchPanel:getNode("bar_exp"):setVisible(true)
        local treasureDb=DB.getTreasureById(treasure.itemid)
        self.quenchPanel:setLabelString("txt_name",treasureDb.name)

        self.quenchPanel:replaceLabelString("txt_level",treasure.quenchLevel)
        Icon.setIcon(treasure.itemid,self.quenchPanel:getNode("icon"),treasureDb.quality)

        self.quenchPanel:getNode("attr_panel"):setVisible(true)
        self.quenchPanel:changeTexture("quality_bg","images/ui_pic1/zbk-di"..EFFECT_QUALITY_BG[treasureDb.quality+1]..".png")

        for i=1, 2 do
            self.quenchPanel:setLabelString("txt_add_attr"..i,"+0")
            self.quenchPanel:setLabelString("txt_add_new_attr"..i,"+0")
        end


        local levelData=DB.getTreasureQuench(treasure.quenchLevel,treasureDb.type)
        local needExp,nextLevelData=self:getQuenchNeedExp(treasure.quenchLevel+1,treasureDb)
        local rate=DB.getTreasureQuanchAttrParam(treasureDb.quality)/100
        if(levelData)then
            for i=1, 2 do
                local attr=levelData["attr"..i]
                local value= (levelData["param"..i]*rate)
                self.quenchPanel:setLabelString("txt_add_attr"..i,"+"..CardPro.getAttrValue(attr,value))
            end
        end
        if(  needExp~=0)then
            local per=  treasure.quenchExp/ needExp
            self.quenchPanel:setLabelString("txt_exp",treasure.quenchExp.."/"..needExp)
            self.quenchPanel:setBarPer( "bar_exp",per)
            for i=1, 2 do 
                local attr=nextLevelData["attr"..i]
                local value=(nextLevelData["param"..i]*rate)
                self.quenchPanel:setLabelString("txt_attr"..i,CardPro.getAttrName(attr) )
                self.quenchPanel:setLabelString("txt_new_attr"..i,CardPro.getAttrName(attr) )
                self.quenchPanel:setLabelString("txt_add_new_attr"..i,"+"..CardPro.getAttrValue(attr,value))
            end
        end


    else
        self.quenchPanel:changeTexture("quality_bg","images/ui_pic1/zbk-di1.png")
    end
    self.quenchPanel:resetLayOut()

end
