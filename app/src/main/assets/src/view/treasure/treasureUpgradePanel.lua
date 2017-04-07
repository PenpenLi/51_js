
function TreasurePanel:initUpgradePanel()
    if(self.upgradePanel~=nil)then
        self.upgradePanel:setVisible(true)
        self:initUpgradeData()
        return
    end
    self.upgradePanel=UILayer.new()
    self.upgradePanel:init("ui/ui_treasure_upgrade.map")
    self.upgradePanel:setPositionY(self:getNode("panels"):getContentSize().height);
    self:getNode("panels"):addChild(self.upgradePanel)
    self:initUpgradeData()

    local attr=DB.getTreasureUpdateMaster(0,10)
    for i=1, 3 do
        self.upgradePanel:setLabelString("txt_pm_attr"..i, CardPro.getAttrName(attr["attr"..i]))
        self.upgradePanel:setLabelString("txt_nm_attr"..i, CardPro.getAttrName(attr["attr"..i]))
    end
    self.upgradePanel.onTouchEnded=function (upgradePanel,target)
        if(target.touchName=="btn_upgrade")then

            if(self.lastTreasure)then

                if(NetErr.isGoldEnough(toint(self:getNode("txt_gold")),true))then
                    Net.sendTreasureUpgrade(self.lastTreasure.id,1)
                end
            end
        elseif  target.touchName=="btn_rule"then
            gShowRulePanel(SYS_TREASURE_UPGRADE) 
        elseif(target.touchName=="btn_upgrade5")then

            if(  self.lastTreasure)then

                if(NetErr.isGoldEnough(toint(self:getNode("txt_gold5")),true))then
                    Net.sendTreasureUpgrade(self.lastTreasure.id,target.num)
                end
            end
        end
    end
end

function TreasurePanel:initUpgradeMaster(card,levelup)
    local minLevel=1000
    local isFull=true 
    for i=1, 4 do
        local treasure=Data.getTreasureById(card["treasure"..i])
        if(treasure)then
            if(minLevel>treasure.upgradeLevel)then
                minLevel=treasure.upgradeLevel
            end 
        else
            isFull=false 
        end
    end
    self:showTreasureInfo()  
    if(isFull==false)then
       minLevel=0
       levelup=false
    end

    for i=1, 3 do
        self.upgradePanel:setLabelString("txt_pm_value"..i, "+0")
        self.upgradePanel:setLabelString("txt_nm_value"..i, "+0")
    end

    local attr=DB.getTreasureUpdateMaster(0,minLevel)
    local curLevel=0

    if(attr)then
        curLevel=attr.level
        for i=1, 3 do
            self.upgradePanel:setLabelString("txt_pm_value"..i, "+"..attr["param"..i]) 
        end
    end
    local oldLevel=self.upgradePanel:getNode("txt_cur_level").level
    if(oldLevel and curLevel>oldLevel and levelup)then 
        self:showMasterEffect(gGetWords("treasureWord.plist","10"),curLevel)
    end
    self.upgradePanel:replaceLabelString("txt_next_level",curLevel+1)
    self.upgradePanel:replaceLabelString("txt_cur_level",curLevel)
    self.upgradePanel:getNode("txt_cur_level").level=curLevel
    self.upgradePanel:replaceLabelString("txt_cur_level2",0)
    attr=DB.getTreasureUpdateMasterByLevel(0,curLevel+1)
    if(attr)then
        self.upgradePanel:replaceLabelString("txt_cur_level2",attr.needlv)
        for i=1, 3 do
            self.upgradePanel:setLabelString("txt_nm_value"..i, "+"..attr["param"..i])
        end
    end
end
function TreasurePanel:initUpgradeData(levelup)

    if(self.upgradePanel==nil or  self.upgradePanel:isVisible()==false)then
        return
    end
    local card=Data.getUserCardById(self.curCardid)
    self.upgradePanel:changeTexture("icon","images/ui_public1/ka_d1.png")
    self.upgradePanel:getNode("icon"):removeAllChildren()

    self:initUpgradeMaster(card,levelup)

    self.upgradePanel:getNode("attr_panel"):setVisible(false)
    self.upgradePanel:setLabelString("txt_name","")
    self.upgradePanel:setLabelString("txt_gold5",0)
    self.upgradePanel:setLabelString("txt_gold",0)
    self.upgradePanel:setTouchEnable("btn_upgrade5",false,true)
    self.upgradePanel:setTouchEnable("btn_upgrade",false,true)
    self.upgradePanel:replaceLabelString("txt_batch_upgrade",0)
    self.upgradePanel:getNode("panel_upgrade_price1"):setVisible(false)
    self.upgradePanel:getNode("panel_upgrade_price2"):setVisible(false)
    if(  self.lastTreasure)then
        local treasure=self.lastTreasure
        local treasureDb=DB.getTreasureById(treasure.itemid)
        self.upgradePanel:setLabelString("txt_name",treasureDb.name)
        Icon.setIcon(treasure.itemid,self.upgradePanel:getNode("icon"),treasureDb.quality)

        self.upgradePanel:getNode("attr_panel"):setVisible(true) 
        self.upgradePanel:changeTexture("quality_bg","images/ui_pic1/zbk-di"..EFFECT_QUALITY_BG[treasureDb.quality+1]..".png")


        local rate=DB.getTreasureUpgradeAttrParam(treasureDb.quality)/100
        self.upgradePanel:setLabelString("txt_attr1",CardPro.getAttrName(treasureDb["attr1"]))
        self.upgradePanel:setLabelString("txt_attr2",CardPro.getAttrName(treasureDb["attr1"]))
        self.upgradePanel:setLabelString("txt_add_attr1","+0")
        self.upgradePanel:setLabelString("txt_add_attr2","+0")

        local levelData=DB.getTreasureUpgrade(treasure.upgradeLevel,treasureDb.type)
        if(levelData)then
            self.upgradePanel:setLabelString("txt_add_attr1","+"..(math.rint(levelData["param1"]*rate)))
        end

        local updateMaxLevel= gUserInfo.level*2-treasure.upgradeLevel
        if(updateMaxLevel>5)then
            updateMaxLevel=5
        end

        if(updateMaxLevel<0)then
            updateMaxLevel=0
        end

        self.upgradePanel:replaceLabelString("txt_batch_upgrade",updateMaxLevel)

        local upgradeGold=0
        local upgradeGolds=0
        for i=treasure.upgradeLevel+1, treasure.upgradeLevel+updateMaxLevel do
            local levelData=DB.getTreasureUpgrade(i,treasureDb.type)
            if(levelData)then
                local needGold=math.floor(levelData.gold* DB.getTreasureUpgradeParam(treasureDb.quality)/100)
                if(upgradeGold==0)then 
                    upgradeGold= needGold
                end
                upgradeGolds=upgradeGolds+needGold
            end
        end
        local levelData=DB.getTreasureUpgrade(treasure.upgradeLevel+1,treasureDb.type)
        if(levelData)then
            self.upgradePanel:setLabelString("txt_add_attr2","+"..(math.rint(levelData["param1"]*rate)))
        end

        
        
        self.upgradePanel:getNode("btn_upgrade5").num=updateMaxLevel
        self.upgradePanel:setLabelString("txt_gold5",upgradeGolds)
        self.upgradePanel:setLabelString("txt_gold",upgradeGold)
        if(upgradeGold>0)then
            self.upgradePanel:setTouchEnable("btn_upgrade5",true,false)
            self.upgradePanel:setTouchEnable("btn_upgrade",true,false) 
            self.upgradePanel:getNode("panel_upgrade_price1"):setVisible(true)
            self.upgradePanel:getNode("panel_upgrade_price2"):setVisible(true)
        end
    else
        self.upgradePanel:changeTexture("quality_bg","images/ui_pic1/zbk-di1.png")
    end
    self.upgradePanel:resetLayOut()
end