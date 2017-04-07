
function TreasurePanel:initRiseStarPanel()
    if(self.riseStarPanel~=nil)then
        self.riseStarPanel:setVisible(true)
        self:initRiseStarData()
        return
    end

    self.lastStoneNum=0
    self.riseStarPanel=UILayer.new()
    self.riseStarPanel:init("ui/ui_treasure_shengxing.map")
    self.riseStarPanel:setPositionY(self:getNode("panels"):getContentSize().height);
    self:getNode("panels"):addChild(self.riseStarPanel)

    self:initRiseStarData()

    self.riseStarPanel.onTouchBegan=function (quench,target)
        if  target.touchName=="btn_rule"then
            gShowRulePanel(SYS_TREASURE_RISESTAR)
        end
    end

    self.riseStarPanel.onTouchEnded=function (quench,target)
        if (string.find(target.touchName,"check_sel")) then
            self:checkSelectBtn(target.touchName)
        elseif target.touchName=="btn_wenxian" then
           local function rereshWenYaoAttrCallBack()
                CardPro.setCardAttr( Data.getUserCardById(self.lastTreasure.cardid),nil,nil)
                self:initRiseStarData()
            end
            Panel.popUp(PANEL_TREASURE_WENYAO,self.lastTreasure,rereshWenYaoAttrCallBack)
        elseif target.touchName=="btn_shengxin" then
            Net.sendTreasureStarup(self.lastTreasure.id,self.riseStarPanel.selIndex)
        elseif target.touchName=="btn_look" then
            Panel.popUpVisible(PANNEL_TREASURE_STAR_DES,self.lastTreasure)
        end
    end
    self.riseStarPanel:resetLayOut()
end


function TreasurePanel:showStarNum(num,maxStarLv)
    if maxStarLv==nil then
        maxStarLv=5
    end
    for i=1,5 do
        if num>=i then
            self.riseStarPanel:changeTexture("star"..i,"images/ui_public1/star_mid.png")
        else
            self.riseStarPanel:changeTexture("star"..i,"images/ui_public1/star_mid_1.png")
        end
        self.riseStarPanel:getNode("star"..i):setVisible(maxStarLv>=i)
    end
    self.riseStarPanel:getNode("bg_star"):layout()
end


function TreasurePanel:resetCheckBtnTexture()
    local btns={
        "check_sel1",
        "check_sel2",
        "check_sel3"
    }
    for key, btn in pairs(btns) do
        self.riseStarPanel:changeTexture(btn,"images/ui_public1/gou_2.png")
    end
end

function TreasurePanel:checkSelectBtn(name)
    self:resetCheckBtnTexture()
    self.riseStarPanel:changeTexture( name,"images/ui_public1/gou_1.png")
    self.riseStarPanel.selIndex = toint(string.sub(name,-1))
    local starlv = self.lastTreasure.starlv+1
    local maxStarLv = DB.getMaxTreasureStar(self.lastTreasure.itemid)
    if starlv > maxStarLv then
       starlv=maxStarLv
    end
    local nextLevelData=DB.getTreasureStar(self.lastTreasure.itemid,starlv)
    local exp_ = nextLevelData["exp_"..self.riseStarPanel.selIndex]
    self.riseStarPanel:setLabelString("txt_exp1", "+"..exp_)
    for i=1, 2 do 
        local attr=nextLevelData["attr"..i]
        local value=CardPro.getAttrValue(attr,exp_*nextLevelData["value"..i]/nextLevelData["exp"])  

        self.riseStarPanel:setLabelString("txt_star_attr"..i,CardPro.getAttrName(attr) )
        self.riseStarPanel:setLabelString("txt_star_attr_value"..i,"+"..value)
    end
end


function TreasurePanel:initRiseStarMaster(card)
    self.curCard=card
    for i=1,6 do
        local attrvalue=0
        local budffdb = nil
        for j=1, 4 do
            local treasure=Data.getTreasureById(card["treasure"..j])
            if(treasure)then
                local treasureStarBuffDB= DB.getTreasureStarBuff(treasure.buffList[i].sid,treasure.buffList[i].slv)
                budffdb = DB.getBuffById(treasure.buffList[i].sid)
                self.riseStarPanel:setLabelString("txt_pm_attr"..i,CardPro.getAttrName(budffdb.attr_id0)) 
                if budffdb and treasureStarBuffDB then
                    attrvalue =attrvalue + budffdb.attr_value0+budffdb.attr_add_value0*(treasureStarBuffDB.valuelevel-1)
                end
            end
        end
        if budffdb then
            self.riseStarPanel:setLabelString("txt_pm_value"..i,"+"..CardPro.getAttrValue(budffdb.attr_id0,attrvalue))
        end
    end
end

function TreasurePanel:initRiseStarData(hasinit)
    if(self.riseStarPanel==nil or  self.riseStarPanel:isVisible()==false)then
        return
    end


    self.riseStarPanel:getNode("layer_levelup"):setVisible(false)
    --self.riseStarPanel:getNode("bar_exp"):setVisible(false)
    self.riseStarPanel:getNode("attr_panel"):setVisible(false)
    self.riseStarPanel:getNode("star_attr_layer"):setVisible(false)
    self.riseStarPanel:getNode("nextstar_layer"):setVisible(false)
    self.riseStarPanel:getNode("wenyao_panel"):setVisible(false)
    self.riseStarPanel:getNode("btn_wenxian"):setVisible(false)
    self.riseStarPanel:getNode("shengxin_pannel"):setVisible(false)
    self.riseStarPanel:getNode("bg_star"):setVisible(false)
    self.riseStarPanel:getNode("txt_name"):setVisible(false)
    self.riseStarPanel:getNode("panel_fullstar"):setVisible(false) 
    self.riseStarPanel:getNode("panel_emptystar"):setVisible(false)

    self.riseStarPanel:getNode("icon"):removeAllChildren() 
    self.riseStarPanel:changeTexture("icon","images/ui_public1/ka_d1.png")
    if( self.lastTreasure and DB.canTreasureStar(self.lastTreasure.itemid) )then
        
        self.riseStarPanel:getNode("wenyao_panel"):setVisible(true)
        self.riseStarPanel:getNode("txt_name"):setVisible(true)
        self.riseStarPanel:getNode("bg_star"):setVisible(true)
        self.riseStarPanel:getNode("btn_wenxian"):setVisible(true)

        local card=Data.getUserCardById(self.curCardid)
        self:initRiseStarMaster(card)
        if self.riseStarPanel.selIndex==nil then
            self.riseStarPanel.selIndex=1
        end
        
        self:showTreasureInfo()  

        self.riseStarPanel:getNode("icon"):removeAllChildren() 
        self.riseStarPanel:getNode("attr_panel"):setVisible(false)
        self.riseStarPanel:setLabelString("txt_name","")
        self.riseStarPanel:replaceLabelString("txt_cur_level2",self.lastTreasure.starpoint)
        local treasure=self.lastTreasure
        local maxStarLv = DB.getMaxTreasureStar(treasure.itemid)
        self:showStarNum(treasure.starlv,maxStarLv) 
        
        local treasureDb=DB.getTreasureById(treasure.itemid)
        self.riseStarPanel:setLabelString("txt_name",treasureDb.name)
        Icon.setIcon(treasure.itemid,self.riseStarPanel:getNode("icon"),treasureDb.quality)

        self.riseStarPanel:getNode("attr_panel"):setVisible(true)
        self.riseStarPanel:changeTexture("quality_bg","images/ui_pic1/zbk-di"..EFFECT_QUALITY_BG[treasureDb.quality+1]..".png")

        for i=1, 2 do
            self.riseStarPanel:setLabelString("txt_add_attr"..i,"+0")
            self.riseStarPanel:setLabelString("txt_add_new_attr"..i,"+0")
        end

        local nexstarlv = treasure.starlv+1
        
   
        self:setTouchEnableGray("btn_shengxin", nexstarlv <= maxStarLv)

        local starAttrValue= CardPro.getTreasureStarAttr(treasure.itemid,treasure.starlv,treasure.starexp)
        for i=1, 2 do
            local attrName = CardPro.getAttrName(starAttrValue[i].attr)
            local attrValue = CardPro.getAttrValue(starAttrValue[i].attr,starAttrValue[i].value)
            self.riseStarPanel:setLabelString("txt_attr"..i,attrName)
            self.riseStarPanel:setLabelString("txt_add_attr"..i,"+"..attrValue)
        end

        if nexstarlv <= maxStarLv then
            self.riseStarPanel:getNode("layer_levelup"):setVisible(true)
            --self.riseStarPanel:getNode("bar_exp"):setVisible(true)
            self.riseStarPanel:getNode("nextstar_layer"):setVisible(true)
            self.riseStarPanel:getNode("shengxin_pannel"):setVisible(true)
            self.riseStarPanel:getNode("next_starpanel"):setVisible(true) 

            
            --local nextAttrValue= CardPro.getTreasureStarAttr(treasure.itemid,nexstarlv)
            local nextLevelData=DB.getTreasureStar(treasure.itemid,nexstarlv)
            self.riseStarPanel:replaceRtfString("txt_nextstar",nexstarlv)
            if( nextLevelData)then
                local per=  treasure.starexp/ nextLevelData.exp
                self.riseStarPanel:setLabelString("txt_exp",treasure.starexp.."/"..nextLevelData.exp)
                self.riseStarPanel:setBarPer( "bar_exp",per)
                local nextStarAttrValue= CardPro.getTreasureStarAttr(treasure.itemid,nexstarlv)
                for i=1, 2 do
                    local attrName = CardPro.getAttrName(nextStarAttrValue[i].attr)
                    local attrValue = CardPro.getAttrValue(nextStarAttrValue[i].attr,nextStarAttrValue[i].value)
                    if nextLevelData["extra_attr"]==nextStarAttrValue[i].attr then
                        attrValue = attrValue - nextLevelData["extra_value"]
                    end
                    
                    self.riseStarPanel:setLabelString("txt_attr"..i,attrName)
                    self.riseStarPanel:setLabelString("txt_new_attr"..i,attrName)
                    self.riseStarPanel:setLabelString("txt_add_new_attr"..i,"+"..attrValue)
                end
                self.riseStarPanel:replaceLabelString("txt_new_extattr",CardPro.getAttrName(nextLevelData["extra_attr"]))
                self.riseStarPanel:setLabelString("txt_add_new_extattr","+"..CardPro.getAttrValue(nextLevelData["extra_attr"],nextLevelData["extra_value"]))
            
                local constType = {}
                for i=1,3 do
                    local constNum=nextLevelData["cost_num"..i]
                    self.riseStarPanel:setLabelString("txt_const"..i, constNum)
                    local itemid = nextLevelData["cost_id"..i]
                    self.riseStarPanel:getNode("txt_const"..i):setColor(cc.c3b(255,255,255));
                    if itemid==90001 then
                        self.riseStarPanel:replaceLabelString("txt_constname"..i, DB.getItemName(itemid))
                        self.riseStarPanel:changeTexture("icon_gold"..i, "images/ui_public1/gold.png")
                        self.riseStarPanel:getNode("icon_gold"..i):setScale(0.34)
                        self.riseStarPanel:setLabelString("txt_const"..i,constNum)
                    elseif itemid==90002 then
                        self.riseStarPanel:replaceLabelString("txt_constname"..i, DB.getItemName(itemid))
                        self.riseStarPanel:changeTexture("icon_gold"..i, "images/ui_public1/coin.png")
                        self.riseStarPanel:setLabelString("txt_const"..i,constNum)
                        self.riseStarPanel:getNode("icon_gold"..i):setScale(0.39)
                    elseif itemid>ITEM_TYPE_SHARED_PRE and itemid<ITEM_TYPE_CONSTELLATION_PRE then
                        self.riseStarPanel:replaceLabelString("txt_constname"..i,gGetWords("labelWords.plist","star_suipian"))  
                        self.riseStarPanel:changeTexture("icon_gold"..i, "images/ui_public1/suipian_icon.png") 
                         local curNum = Data.getItemNum(itemid)
                        self.riseStarPanel:setLabelString("txt_const"..i,curNum .."/"..constNum)
                        self.riseStarPanel:getNode("txt_const"..i):setColor(cc.c3b(0,255,0));
                        if curNum<constNum then
                            self.riseStarPanel:getNode("txt_const"..i):setColor(cc.c3b(255,0,0));
                        end 
                        self.riseStarPanel:getNode("icon_gold"..i):setScale(0.80)
                    elseif itemid==47 then
                        self.riseStarPanel:replaceLabelString("txt_constname"..i,gGetWords("labelWords.plist","star_longlin")) 
                        self.riseStarPanel:changeTexture("icon_gold"..i, "images/icon/item/47.png")  
                         local curNum = Data.getItemNum(itemid)
                        self.riseStarPanel:setLabelString("txt_const"..i,curNum .."/"..constNum)
                        self.riseStarPanel:getNode("txt_const"..i):setColor(cc.c3b(0,255,0));
                        if curNum<constNum then
                            self.riseStarPanel:getNode("txt_const"..i):setColor(cc.c3b(255,0,0));
                        end
                        self.riseStarPanel:getNode("icon_gold"..i):setScale(0.34)
                    end
                    if constNum>0 then
                        constType[i]=true
                    end
                    self.riseStarPanel:getNode("type_pannel"..i):setVisible(constNum>0)
                end
                if constType[self.riseStarPanel.selIndex] == nil then
                    self.riseStarPanel.selIndex=1
                end
                self.riseStarPanel:getNode("star_attr_layer"):setVisible(true)
                self.riseStarPanel:setTouchEnableGray("btn_shengxin", table.count(constType)>0) 
                self:checkSelectBtn("check_sel"..self.riseStarPanel.selIndex)
                self.riseStarPanel:replaceLabelString("txt_getwenyao", nextLevelData.addpoint)
            end
        else
            ---满星
            self.riseStarPanel:getNode("next_starpanel"):setVisible(false) 
            self.riseStarPanel:getNode("panel_fullstar"):setVisible(true)  
        end
    else
        self.riseStarPanel:getNode("panel_emptystar"):setVisible(true)
        self.riseStarPanel:changeTexture("quality_bg","images/ui_pic1/zbk-di1.png")
    end
    self.riseStarPanel:resetLayOut()

end
