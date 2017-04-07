local AtlasDropItem=class("AtlasDropItem",UILayer)

local unlockMap={
    shoparena=SYS_ARENA,
    shop1=SYS_SHOP,
    shop2=SYS_SHOP2,
    shop3=SYS_SHOP3,
    shopfamily=SYS_FAMILY,
    shopcardstar=SYS_SHOP_SOUL,
    shopcrusade=SYS_CRUSADE,
    shopmine=SYS_MINE

}

function AtlasDropItem:ctor(type)
    self.curType=type
    if(type==1)then
        self:init("ui/tip_equip_get_item.map")
    else
        self:init("ui/ui_bag_xiangqing_item.map")
    end
end


function AtlasDropItem:gotoSource()
    if(self.curSource=="shoparena")then
        Panel.popUp(PANEL_SHOP,SHOP_TYPE_ARENA)
    elseif(self.curSource=="shop1")then
        Panel.popUp(PANEL_SHOP,SHOP_TYPE_1)

    elseif(self.curSource=="shop2")then
        Panel.popUp(PANEL_SHOP,SHOP_TYPE_2)

    elseif(self.curSource=="shop3")then
        Panel.popUp(PANEL_SHOP,SHOP_TYPE_3)
    elseif(self.curSource=="shopcardstar")then
        Panel.popUp(PANEL_SHOP,SHOP_TYPE_SOUL)

    elseif(self.curSource=="draw")then
        Panel.popUp(PANEL_DRAW_CARD)
    elseif self.curSource=="daytask" then
        if Unlock.isUnlock(SYS_TASK) then
            Net.sendDayTaskList();
        end
    elseif(self.curSource=="soulbox")then
        if(Unlock.isUnlock(SYS_DRAWSOUL,true))then
            Panel.popUp(PANEL_DRAW_CARD,true)
        end
    elseif(self.curSource=="mine")then
        if(Unlock.isUnlock(SYS_MINE))then
            gDigMine.processSendInitMsg()
        end

    elseif(self.curSource=="shopworld")then
        if(Unlock.isUnlock(SYS_SERVER_BATTLE))then
            -- Panel.popUp(PANEL_SHOP,SHOP_TYPE_SERVERBATTLE)
            Net.sendWorldWarInfo()
        end

    elseif self.curSource=="shopcrusade"then

        if(Unlock.isUnlock(SYS_CRUSADE))then
            Panel.popUp(PANEL_CRUSADE_SHOP)
        end


    elseif self.curSource=="cardsoulmelt"then
        Panel.popUp(PANEL_CARD_SOUL)


    elseif self.curSource=="atlasdevis"then
        if(Unlock.isUnlock(SYS_BOSS_ATLAS)) then
            Panel.popUp(PANEL_ATLAS,{type=7})
        end
    elseif self.curSource=="equmelt"then
        Panel.popUpVisible(PANEL_CARD_WEAPON_EQUIP_SOUL);

    elseif self.curSource=="equsoulact"then
        Panel.popUp(PANEL_ACTIVITY,4);

    elseif self.curSource=="shoptower"then

        if Unlock.isUnlock(SYS_TOWER) then
            Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_TOWER1);
        end

    elseif self.curSource=="shopdragonball"then
        Panel.popUpVisible(PANEL_SHOP_DRAGON_EXCHANGE)
    elseif self.curSource=="shopmine"then
        if(Unlock.isUnlock(SYS_MINE))then
            Panel.popUpVisible(PANEL_MINE_DEPOT,2,nil,true)
        end
    elseif(self.curSource=="shopfamily")then
        if(Data.hasFamily())then
            if Module.isClose(SWITCH_FAMILY_SHOP4) or gFamilyInfo.iLevel < DB.getFamilyBuildUnlock(11) then
                Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_FAMILY)
            else
                Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_FAMILY_4)
            end
        else
            gShowNotice(gGetWords("noticeWords.plist","no_family"))
        end
    elseif(self.curSource == "petshop") then
        Panel.popUp(PANEL_SHOP,SHOP_TYPE_PET);
    elseif(self.curSource == "goldbox") then
        Panel.popUp(PANEL_PET_TOWER_BOX);
    elseif(self.curSource == "diamondbuy") then
        local buyedNum=Data.getMmBuyItemNumById(self.itemid)
        local canBuyNum=0
        local db=DB.getMinematerialBuy(self.itemid)
        if(db)then
            canBuyNum=db.num+gUserInfo.vip*db.vipadd
            self:buyItem(self.itemid,db.price,canBuyNum-buyedNum)
        end
    end
end


function AtlasDropItem:buyItem(itemid,price,lefttimes)
    local temp={}
    temp.itemid=itemid
    temp.costType=OPEN_BOX_DIAMOND
    temp.price=price
    temp.rewardNum=1
    temp.lefttimes=lefttimes
    temp.buyCallback=function(num)
        Net.sendBuyItem(itemid,num)
    end

    Panel.popUp(PANEL_SHOP_BUY_ITEM,temp)
end

function AtlasDropItem:setSource(source,itemid,var)
    self.curSource=source
    self:getNode("bg"):setVisible(true)
    self.itemid=itemid


    local item=DB.getItemData(var)
    self:setLabelString("txt_name",gGetWords("item.plist","item_source_name_"..source))



    if(  source=="diamondbuy")then
        self:setLabelString("txt_go", gGetWords("btnWords.plist","btn_buy"))
        local buyedNum=Data.getMmBuyItemNumById(itemid)
        local canBuyNum=0
        local db=DB.getMinematerialBuy(itemid)
        if(db)then
            canBuyNum=db.num+gUserInfo.vip*db.vipadd
        end
        local buyNum=canBuyNum-buyedNum
        if(buyNum<=0)then
            buyNum=0
            self:setTouchEnable("touch_node",false,true)
        end

        self:setLabelString("txt_type1",gGetWords("item.plist","item_source_desc_"..source,buyNum))
    elseif(  source=="atlasdevis")then
        self:setLabelString("txt_type1",gGetWords("item.plist","item_source_desc_"..source,gAtlas.bossNum))
    elseif(  source=="mine")then
        local item=DB.getItemData(itemid)
        self:setLabelString("txt_type1",item.detail)
    elseif(itemid==77 and source=="shopmine")then
        self:setLabelString("txt_type1",gGetWords("item.plist","item_source_desc_shopmine2"))
    elseif(item)then
        self:setLabelString("txt_type1",gGetWords("item.plist","item_source_desc_"..source,item.name))
    else
        self:setLabelString("txt_type1",gGetWords("item.plist","item_source_desc_"..source))
    end




    self:setLabelString("txt_num","")

    Icon.setItemSourceIcon(source,self:getNode("icon"))
    self.isOpen=true
    if(unlockMap[source] ) then
        if(  Unlock.isUnlock(unlockMap[source] ,false)==false)then
            self:showUnlock()
        end
    end
    if(self:getNode("txt_type1"))then
        self:getNode("txt_type1"):setVisible(true);
    end
    self:getNode("txt_type"):setVisible(false);
    self:resetLayOut();
end


function AtlasDropItem:showUnlock()
    self:changeTexture("state","images/ui_word/unopen.png")
    self.isOpen=false
    if(self.curType~=1)then
        self:getNode("touch_node"):setVisible(false)
    end
end

function AtlasDropItem:setData(data)
    self.curData=data
    Icon.setAtlasIcon( data.icon,self:getNode("icon"))

    self:setLabelString("txt_name",data.name)
    self:setLabelString("txt_type",gGetWords("labelWords.plist","lab_atlas_type"..data.type))
    self:setLabelString("txt_num","")

    local ret=Data.getAtlasStatus(data.map_id,data.stage_id,data.type)
    if(ret~=false)then
        local temp=Data.canAtlasFight(data.map_id,data.stage_id,data.type)
        if(temp==nil or temp==false )then
            ret=false
        end
    end
    if(ret==false)then
        self:showUnlock()
    else
        self:changeTexture("state","images/ui_word/open.png")
        if(self.curType~=1)then
            self:getNode("state"):setVisible(false)
        end
        self.isOpen=true

        if(data.type==1)then
            if(ret.buyNum==nil)then
                ret.buyNum=0
            end
            if(ret.batNum==nil)then
                ret.batNum=ATLAS_SWEEP_REAMIN_TIME
            end
            self:setLabelString("txt_num","("..ret.batNum.."/"..(ATLAS_SWEEP_REAMIN_TIME*(ret.buyNum+1))..")")
        end
    end
    if(self:getNode("txt_type1"))then
        self:getNode("txt_type1"):setVisible(false);
    end
    self:getNode("txt_type"):setVisible(true);
    self:resetLayOut();
end


function AtlasDropItem:onTouchEnded(target)
    if(self.isOpen)then
        if(self.curSource)then
            self:gotoSource()
            return
        end
        if(self.needNum)then
            Data.wantedItem=self.itemid
            Data.wantedItemNum=self.needNum
        else
            Data.wantedItem=0
        end
        Panel.popUp(PANEL_ATLAS_ENTER,{mapid= self.curData.map_id,stageid= self.curData.stage_id,type= self.curData.type})
    end
end


return AtlasDropItem