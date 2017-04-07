local BagPanel=class("BagPanel",UILayer)

function BagPanel:ctor(type)
    --[[
    1= 背包
    2= 碎片
    ]]
    self:init("ui/ui_bag.map")


    self:getNode("scroll").eachLineNum=5
    self:getNode("scroll").offsetX=3
    self:getNode("scroll").offsetY=0
    self:getNode("scroll").padding=5
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.curPanelType=type
    --[[   if(self.curPanelType==1)then
    self:getNode("btn_piece"):setVisible(false)
    else
    self:getNode("btn_consume"):setVisible(false)
    self:getNode("btn_diamond"):setVisible(false)
    self:getNode("btn_other"):setVisible(false)

    end
    ]]

    self.controlCenterX=self:getNode("btn_use"):getPositionX()
    self.controlLeftX=self:getNode("btn_sell"):getPositionX()
    self.controlRightX=self:getNode("btn_detail"):getPositionX()
    self.curTagType=0 
    self:selectBtn("btn_all")
    self:initBagData( self.curTagType,true)
end

function  BagPanel:events()
    return {EVENT_ID_UPDATE_REWORDS,EVENT_ID_UPDATE_REWORDS_DIRECT}
end


function BagPanel:dealEvent(event,param)

    if(event==EVENT_ID_UPDATE_REWORDS_DIRECT)then
        self:updateBagData( self.curTagType,false)

    elseif(self:isVisible() and event==EVENT_ID_UPDATE_REWORDS)then
        self:updateBagData( self.curTagType,false)
    end
end



function BagPanel:onPopup()
--
end
function BagPanel:onPopback()
    Scene.clearLazyFunc("bag")
end


function gPreSortCardSoul(items)
    for key, item in pairs(items) do 
        item.sort=0
        if(item._db==nil)then
            item._db=DB.getCardById(item.itemid)
        end
        if(item._db)then 
            item.sort= item._db.evolve*10000000+item.itemid
        end
    end

end

function gPreSortEquipItem(items,flag)
    for key, item in pairs(items) do
        if(item)then
            item.flag=flag
        end
        if(item.sort==nil)then
            item.sort=0
            if(item._db==nil)then
                item._db=DB.getItemData(item.itemid)
            end
            local canOpen = false
            if(DB.getItemType(item.itemid)==ITEMTYPE_BOX)then
                if(item._db.limittype==0 or (item._db.limittype==1 and gUserInfo.level>=item._db.openlv))then
                    canOpen= true
                end
            end
            if(item._db)then
                if(item._db.quality==nil)then
                    item._db.quality=5
                end
                item.sort= item._db.quality*10000000+item.itemid
                if canOpen then
                    item.sort=item.sort+10000000000
                end
            end
        end

    end

end

function gSortEquipItem(t1,t2)

    return t1.sort>t2.sort
end


function gSortEquipItem2(t1,t2)

    return t1.sort<t2.sort
end


function BagPanel:getShowItems(type) 
    local ret={}
    if(type==0)then

        gPreSortEquipItem(gUserItems)
        table.sort(gUserItems,gSortEquipItem) --排序
        table.add(ret,gUserItems)

        gPreSortEquipItem(gUserEquipItems)
        table.sort(gUserEquipItems,gSortEquipItem) --排序
        table.add(ret,gUserEquipItems)

    elseif(type==1)then 
        --消耗
        for key, item in pairs(gUserItems) do

            if( DB.getItemType(item.itemid)==ITEMTYPE_BOX)then
                table.insert(ret,item) 
            else
                local db= DB.getItemById(item.itemid)
                if(db and db.type==1)then
                    table.insert(ret,item) 
                end

            end

        end

    elseif(type==2)then
        ret=gUserEquipItems
    elseif(type==3)then
    --其他
    elseif(type==4)then 
        for key, item in pairs(gUserItems) do
            local db= DB.getItemById(item.itemid)
            if(db and db.type~=1)then
                table.insert(ret,item)
            end
        end
    elseif(type==5)then
        gPreSortEquipItem(gUserShared)
        table.sort(gUserShared,gSortEquipItem) --排序
        ret=gUserShared
    end
    
    return ret

end

function BagPanel:getItemByData(data)
    for key, item in pairs(self:getNode("scroll").items) do
        if(item.curData==data)then
            return item
        end
    end
    return nil

end
function BagPanel:updateBagData(type,moveUp) 
    self.curTagType=type 
    self.curShowItems=self:getShowItems(type)
    
    for key, item in pairs(self:getNode("scroll").items) do
    	item.del=true
    end
    
    for key, var in pairs(self.curShowItems) do
        local item=self:getItemByData(var)
        if(item==nil)then  
            local item=BagItem.new()
            item.idx=key
            item:setData(var, self.curTagType) 
            item.selectItemCallback=function (data,item)
                self:onSelectItem(data,item)
            end
            self:getNode("scroll"):addItem(item)
        else
            item:refreshData()
            item.del=false
        end
    end
     
    for key, item in pairs(self:getNode("scroll").items) do
        if(item.del==true)then
            if(self.lastSelectItem==item)then
                self.lastSelectItem=nil
            end
            self:getNode("scroll"):removeItem(item,false)
        end
    end
    self:getNode("scroll"):layout(moveUp) 
    self:updateSelect()
end

function BagPanel:initBagData(type,moveUp)
    --[[
    0 =所有
    1 =消耗
    2 =材料
    3 =宝石
    4 =其他
    5 =碎片 
    ]]
    Scene.clearLazyFunc("bag")
    self.lastSelectItem=nil
    self.curTagType=type 
    self.curShowItems=self:getShowItems(type) 
    self:getNode("scroll"):clear()
 
 
    local drawNum=20
    for key, var in pairs(self.curShowItems) do
        local item=BagItem.new()
        item.idx=key
        if(drawNum>0)then
            drawNum=drawNum-1
            item:setData(var, self.curTagType)
        else
            item:setLazyData(var, self.curTagType)
        end
        item.selectItemCallback=function (data,item)
            self:onSelectItem(data,item)
        end
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout(moveUp) 
    self:updateSelect()
end

function BagPanel:updateSelect() 
    if(table.getn(self:getNode("scroll").items)~=0) then
       if(self.lastSelectItem==nil)then
            self.lastSelectItem=self:getNode("scroll").items[1]
       end 
        self:onSelectItem(self.lastSelectItem.curData,self.lastSelectItem)
        self:getNode("choose_icon"):setVisible(true)
        self:getNode("left_panel"):setVisible(true)
    else
        self:getNode("choose_icon"):setVisible(false)
        self:getNode("left_panel"):setVisible(false)
    end
end

function BagPanel:onSelectItem(data,item)
    self.itemid=data.itemid
    self.lastSelectItem=item

    local node=self.lastSelectItem
    if(node)then
        local posx,posy=node:getPosition()
        posx=posx+self:getNode("scroll").itemWidth/2
        posy=posy-self:getNode("scroll").itemHeight/2
        self:getNode("choose_icon"):setVisible(true)
        self:getNode("choose_icon"):setPosition(cc.p(posx,posy))
    end

    local db,type= DB.getItemData(data.itemid)
    if(db==nil)then
        return
    end

    local itemid=data.itemid
    if(self.curTagType==5)then
        itemid=itemid+ITEM_TYPE_SHARED_PRE
    end
    self:setLabelString("txt_name",db.name)
    self:setLabelString("txt_num",gGetWords( "labelWords.plist","lab_reamin_num",data.num))
    self:setLabelString("txt_info",db.des)

    self.itemNum=data.num
    local item,itemType=  Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(data.itemid))
    self:setLabelString("txt_gold",EquipItem.getSellPrice(itemid))


    self:getNode("btn_use"):setVisible(false)
    self:getNode("btn_detail"):setVisible(false)
    self:getNode("btn_comp"):setVisible(false)
    self:getNode("btn_sell"):setVisible(false)


    if(self.curTagType==5 and EquipItem.canCompound(self.itemid) )then
        self:getNode("btn_comp"):setVisible(true)
        self:getNode("btn_sell"):setVisible(true)
    elseif(itemType==ITEMTYPE_ITEM  )then
        if(db.isuse==1)then
            self:getNode("btn_use"):setVisible(true)
        else
            self:getNode("btn_use"):setVisible(false)
        end

        if(db.sell_money~=0)then
            self:getNode("btn_sell"):setVisible(true)
            self:getNode("btn_use"):setPositionX(self.controlRightX)
        else
            self:getNode("btn_use"):setPositionX(self.controlCenterX)
        end

    elseif(itemType==ITEMTYPE_BOX)then
        self:getNode("btn_use"):setVisible(true)
        self:getNode("btn_use"):setPositionX(self.controlCenterX)
        self:setLabelString("txt_info",db.desc)

    else
        self:getNode("btn_sell"):setVisible(true)
        self:getNode("btn_detail"):setVisible(true)
    end

    self:getNode("sell_panel"):setVisible(self:getNode("btn_sell"):isVisible())

    self:getNode("txt_info_scroll"):layout();

end


function BagPanel:resetBtnTexture()
    local btns={
        "btn_all",
        "btn_consume",
        "btn_material",
        "btn_diamond",
        "btn_piece",
        "btn_other"
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian1.png")
    end
end

function BagPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian1-1.png")
end


function BagPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif  target.touchName=="btn_comp"then
        local data={}
        data.itemid=self.itemid
        Panel.popUp(TIP_PANEL_EQUIP_COMP,data)
    elseif  target.touchName=="btn_use"then
        Data.useItem(self.itemid)

    elseif  target.touchName=="btn_detail"then
        local data={}
        data.itemid=self.itemid
        Panel.popUpVisible(PANEL_ATLAS_DROP,data)
    elseif  target.touchName=="btn_all"then

        self:initBagData(0)
        self:selectBtn(target.touchName)
    elseif  target.touchName=="btn_consume"then
        self:initBagData(1)
        self:selectBtn(target.touchName)
    elseif  target.touchName=="btn_material"then

        self:initBagData(2)
        self:selectBtn(target.touchName)
    elseif  target.touchName=="btn_diamond"then

        self:initBagData(3)
        self:selectBtn(target.touchName)
    elseif  target.touchName=="btn_other"then

        self:initBagData(4)
        self:selectBtn(target.touchName)
    elseif  target.touchName=="btn_piece"then

        self:initBagData(5)
        self:selectBtn(target.touchName)
    elseif  target.touchName=="btn_sell"then
        local itemid=self.itemid

        if(self.curTagType==5)then
            itemid=itemid+ITEM_TYPE_SHARED_PRE
        end
        Panel.popUpVisible(PANEL_ITEMSELL,itemid);
    -- Net.sendSellItem(itemid, self.itemNum)
    end

end

return BagPanel