local WeaponRaisePanel=class("WeaponRaisePanel",UILayer)



function WeaponRaisePanel:ctor(cards,tag)

    self:init("ui/ui_weapon_raise.map")
    self.curAddRage=0
    self.curRaiseData=cards
    self.particles={}
    self:getNode("btn_add").__touchend=true
    self:getNode("btn_sub").__touchend=true 
    self:getNode("panel_power_raise").__touchend=true

    local winSize=cc.Director:getInstance():getWinSize()
    winSize.height= self:getNode("scroll").viewSize.height
    winSize.width=winSize.width-200
    self:getNode("scroll"):resize(winSize)
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self:showCards()
    
    if(tag and tag==2)then
        self:selectBtn("btn_raise")
    else
        self:selectBtn("btn_strong")
    end 
  
    self:initUpdate() 
    Unlock.checkFirstEnter(SYS_WEAPON);

    if isBanshuUser() then
        self:getNode("raise_dan_panel3"):setVisible(false);
    end
end


function  WeaponRaisePanel:events()
    return {
        EVENT_ID_REFRESH_CARD_RAISE,
        EVENT_ID_WEAPON_UPGRADE,
        EVENT_ID_CONFIRM_CARD_RAISE}
end

function WeaponRaisePanel:onPopup()
    self:showSelectCard(gCurRaiseCardid)

end
function WeaponRaisePanel:showWeaponEffect()

    if(self:getNode("effect"):isVisible()==false)then 
        self:getNode("effect"):setVisible(true)
        local function playEnd()
            self:getNode("effect"):setVisible(false)
        end
        self:getNode("effect").curAction=""
        self:getNode("effect"):playAction("ui_weapon_cuilian",playEnd)
    
    end

end

function WeaponRaisePanel:dealEvent(event,data)
    if(event==EVENT_ID_REFRESH_CARD_RAISE)then 
        self.curRaiseData[data.cardid]=data
        self:showRaideAttrPanel(data,data.cancel)
        self:showWeaponEffect()
    elseif(event==EVENT_ID_WEAPON_UPGRADE)then
        self:dealUpgradeEvent(event,data)
    elseif(event==EVENT_ID_CONFIRM_CARD_RAISE)then 
        self.curCard=Data.getUserCardById(self.curCardid)
        self.curRaiseData[data.cardid]=data
        self:showRaideAttrPanel(data,data.cancel,true)
    end
end

function WeaponRaisePanel:onPopback()
    Scene.clearLazyFunc("raise")
end

function WeaponRaisePanel:showCards()
    local weapons={} 
    Data.sortUserCard()
    for key, card in pairs(gUserCards) do
        local db=DB.getCardById(card.cardid)
        if(db and db.weaponid>0)then
            table.insert(weapons,card)
        end

        if(gCurRaiseCardid==nil)then
            gCurRaiseCardid=card.cardid
        end
    end

    local drawNum=10
    local curKey=-1
    local totalCount=table.getn(weapons)
    local startIdx=1
    for key, card in pairs(weapons) do
        if(card.cardid==gCurRaiseCardid)then
            startIdx=key
        end
    end
    
    
    if(totalCount-startIdx<drawNum)then
        startIdx=totalCount-drawNum
    end
    print(startIdx)
    for key, card in pairs(weapons) do 
        local needSetData=false
        if(drawNum>0 and key>=startIdx)then
            drawNum=drawNum-1
            needSetData=true
        end
        local item=WeaponRaiseItem.new()
        item.selectItemCallback=function (data,item)
            self:showSelectCard(data.cardid,false)
        end
        
        if(needSetData)then 
            item:setData(card)
        else
            item:setLazyData(card)
        end 
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
    self:getNode("scroll"):moveItemByIndex(startIdx)
    if(table.getn(self:getNode("scroll").items)~=0) then
        self:getNode("choose_icon"):setVisible(true)
        self:getNode("left_panel"):setVisible(true)
    else
        self:getNode("choose_icon"):setVisible(false)
        self:getNode("left_panel"):setVisible(false)
    end
end

 



function WeaponRaisePanel:showSelectCard(cardid,showChange)
    self.curCardid=cardid
    self.curAddRage=0
    local node=nil
    for key, var in pairs( self:getNode("scroll").items) do
        if(var.curData.cardid==cardid)then
            node=var
            break
        end
    end
    if(node==nil)then
        return
    end
    gCurRaiseCardid=cardid
    local posx,posy=node:getPosition()
    posx=posx+self:getNode("scroll").itemWidth/2
    posy=posy-self:getNode("scroll").itemHeight/2
    self:getNode("choose_icon"):setVisible(true)
    self:getNode("choose_icon"):setPosition(cc.p(posx,posy)) 
    local card=Data.getUserCardById(cardid) 
    self.curCard=card
    

    local db=DB.getCardById(cardid)
    self.cardDb=db
    self:setLabelString("txt_role_name",db.name)

    local maxWeaponId=nil
    local maxAwakeId=nil
    maxWeaponId,maxAwakeId= gGetMaxWeaponAwakeId(cardid)
    local weaponid=gParseWeaponId( card.weaponLv ,maxWeaponId)
    if(weaponid and weaponid>=2)then
        weaponid= db.weaponid.."_"..weaponid
    else
        weaponid= db.weaponid
    end
    
    Icon.setWeaponIcon(weaponid,self:getNode("icon"))

    local weaponDB=DB.getWeaponById(db.weaponid)
    if(weaponDB)then
        self:setLabelString("txt_name",weaponDB.name )
        self:replaceLabelString("txt_lv", gParseWeaponLv( card.weaponLv))
    end

    if(self:getNode("btn_raise_panel"):isVisible())then 
        self:showRaideAttrPanel(self.curRaiseData[gCurRaiseCardid])
    else
        self:showRaideUpgradePanel(gCurRaiseCardid,false) 
    end  
    RedPoint.bolCardViewDirty=true
end

function WeaponRaisePanel:getAttrFlag(attr)
    return CardPro.cardPros["attr"..attr]
end

function WeaponRaisePanel:resetBtnTexture()
    local btns={
        "btn_raise",
        "btn_strong", 
    }

    for key, btn in pairs(btns) do
        self:getNode(btn.."_panel"):setVisible(false)
        self:changeTexture(btn,"images/ui_public1/button_s2.png")
    end

end



function WeaponRaisePanel:selectBtn(name) 
    self:resetBtnTexture() 
    self:getNode(name.."_panel"):setVisible(true)
    self:changeTexture( name,"images/ui_public1/button_s2-1.png")
  
end



function WeaponRaisePanel:onTouchEnded(target)

    Panel.clearTouchTip()
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_equip_soul"then
        Panel.popUp( PANEL_CARD_WEAPON_EQUIP_SOUL)
    elseif  target.touchName=="btn_transmit"then
        Panel.popUp( PANEL_TRANSMIT)

    elseif  target.touchName=="btn_add2"then
        self:changeAddNum(10)
    elseif  target.touchName=="btn_sub2"then
        self:changeAddNum(-10)

    elseif  target.touchName=="btn_rule"then
        gShowRulePanel(SYS_WEAPON)
    elseif  target.touchName=="btn_view"then
        Panel.popUp( PANEL_CARD_WEAPON_PREVIEW,self.curCardid)
    elseif  target.touchName=="btn_diamond"then
        self:selectBtn(target.touchName)
    elseif  target.touchName=="btn_strong"then
        self:selectBtn(target.touchName)  
        self:showRaideUpgradePanel(gCurRaiseCardid,false) 
    elseif  target.touchName=="btn_raise"then
        self:selectBtn(target.touchName)
        self:showRaideAttrPanel(self.curRaiseData[gCurRaiseCardid])
    elseif target.touchName=="btn_save"then
        self:clearParticle()
        Net.sendCardRaiseConfirm(self.curCardid,true)

    elseif target.touchName=="btn_cancel"then
        Net.sendCardRaiseConfirm(self.curCardid,false)

    elseif  target.touchName=="btn_do_raise"then
        self:doRaise(target)
    elseif  target.touchName=="raise_dan_panel3"then
        self:selectRaiseDan(3)
    elseif  target.touchName=="raise_dan_panel2"then
        self:selectRaiseDan(2)
    elseif  target.touchName=="raise_dan_panel1"then
        self:selectRaiseDan(1)

    elseif  target.touchName=="btn_do_strong" or target.touchName=="btn_do_strong2" then
        self:doUpgrade(target)
    elseif  target.touchName=="btn_raise_time"then
        local function callback(time)
            self:initBatchTime()
        end
        Panel.popUp( PANEL_CARD_WEAPON_RAISE_VIP,callback)
    elseif(target.itemid)then
        local data={}
        data.itemid=target.itemid
        Panel.popUpVisible(PANEL_ATLAS_DROP,data)

    end 
end

return WeaponRaisePanel