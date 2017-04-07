local DragonUI=class("DragonUI",UILayer)

function DragonUI:ctor()

    self:init("ui/dragon.map")

    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height )


    local nodes={}
    table.insert(nodes,"1_1")
    for i=1, 10 do
        table.insert(nodes,"2_"..i)
    end
    for i=1, 6 do
        table.insert(nodes,"3_"..i)
    end

    for key, var in pairs(nodes) do
        local node=cc.Node:create()
        local type=toint( string.split(var,"_")[1])
        node:setContentSize(cc.size(100,100))
        if(type==1)then
            self:getNode("panel_one"):addChild(node)
        elseif(type==2)then
            self:getNode("panel_ten"):addChild(node)
        elseif(type==3)then
            self:getNode("panel_six"):addChild(node)
        end
        local posx,posy=self:getNode("item_"..var):getPosition()
        node:setPosition(posx-50,posy+30)
        self:getNode("item_"..var).touchNode=node
        node:setLocalZOrder(self:getNode("item_"..var):getLocalZOrder())
        self:addTouchNode(node,"item_"..var,0)
    end


end

function DragonUI:events()
    return {EVENT_ID_DRAW_GET_LUCKBOX};
end


function DragonUI:dealEvent(event,param)
    -- print("DragonUI:dealEvent")
    if(event == EVENT_ID_DRAW_GET_LUCKBOX)then
        self:refreshSoulLuck();
    end
end


function DragonUI:onTouchEnded(target)
    if(target.touchName=="buy_ten")then
        if(self.isShowing==true)then
            return
        end

        if(self.type==nil)then
            self.dragon3D:playBuyTen()
        else
            if self.type == 2 and gIsVipExperTimeOver(VIP_DRAWCARD_SOUL) then
                return
            end
            self:getNode("panel_ten"):setVisible(false)
            self:getNode("panel_one"):setVisible(false)
            self:getNode("panel_six"):setVisible(false)

            if(self.type==2)then
                Net.sendDrawSoulBuy()
            else
                if NetErr.isDrawCardEnough(self.type,1) then
                    Net.sendDrawCard(self.type,1)
                end
            end
        end
    elseif(target.touchName=="buy_one")then
        if(self.isShowing==true)then
            return
        end
        if(self.type==nil)then
            self.dragon3D:playBuyOne()
        else
            -- if self.type == 1 and isBanshuReview() then
            --     if Data.getItemNum(ITEM_ID_DRAW_CARD_ONE) > 0 or Data.drawCard.freeDia == true then
            --     else
            --         gShowNotice(gGetWords("noticeWords.plist","no_draw_senior_item"))
            --         return
            --     end
            -- end
            if NetErr.isDrawCardEnough(self.type,0) then
                self:getNode("panel_ten"):setVisible(false)
                self:getNode("panel_one"):setVisible(false)
                Net.sendDrawCard(self.type,0)
            end
        end
    elseif target.touchName=="btn_close"then
        if(self.isShowing==true)then
            return
        end
        Scene.hideDragonScene()
    elseif target.touchName == "soul_luckbox" then
        Panel.popUpVisible(PANEL_DRAWCARDBOX);
    else
        local node=self:getNode(target.touchName)
        if(node and node.item)then
            node.item.touchNode=node.touchNode
            node.item:onTouchEnded(target)
        end
    end
end


function DragonUI:onTouchBegan(target,touch)
    local node=self:getNode(target.touchName)
    if(node and node.item)then
        node.touchNode.__touchend=true
        node.item.touchNode=node.touchNode
        node.item:onTouchBegan(target,touch) 
    end
end
function  DragonUI:setItems(items,type,cidArray)

    self.type=type
    self.isShowing=true
    Guide.pause=true
    self.cidArray=cidArray
    self:getNode("panel_ten"):setVisible(false)
    self:getNode("panel_one"):setVisible(false)
    self:getNode("panel_six"):setVisible(false)
    self:getNode("soul_panel"):setVisible(false)
    self:getNode("panel_lucky"):setVisible(false)
    
    
 
    
    if(table.getn(items)==1)then
        self:initOnePanel(items)
    elseif(table.getn(items)==10)then
        self:initTenPanel(items)
    else
        self:initSixPanel(items)
    end

    local passTime=gGetCurServerTime()-Data.drawCard.time
    self.dragon3D:changeSkin(type)
    self:getNode("panel_buy1"):setVisible(true)
    self:getNode("layer_luck"):setVisible(false)
    if(type==0)then
        --金币抽卡
        local num = Data.getItemNum(ITEM_DRAW_GOLD_BUY)
        local passTime=gGetCurServerTime()-Data.drawCard.time
        self:setLabelString("txt_1",num.."/1")
        self:setLabelString("txt_2",num.."/10")
        self:changeIconType("icon1",ITEM_DRAW_GOLD_BUY)
        self:changeIconType("icon2",ITEM_DRAW_GOLD_BUY)
        if(passTime>=Data.drawCard.gold.ftime)then
            if(Data.drawCard.gold.fnum>0)then
                self:setLabelString("txt_1","lab_free","labelWords.plist")
            end
        end
    elseif(type==1)then
    
        self:getNode("panel_lucky"):setVisible(true) 
        if(10-Data.drawCard.lucky==1)then 
            self:setRTFString("txt_lucky", gGetWords("labelWords.plist","draw_card_lucky_just"))
        else 
            self:replaceRtfString("txt_lucky",10-Data.drawCard.lucky)
        end


        --元宝抽卡
        self:setLabelString("txt_1",DB.getDrawDiamondOne())
        self:setLabelString("txt_2",DB.getDrawDiamondTen())
        self:changeIconType("icon1",OPEN_BOX_DIAMOND)
        self:changeIconType("icon2",OPEN_BOX_DIAMOND)
        Data.drawCard.freeDia = false
        if(passTime>=Data.drawCard.diamond.ftime)then
            self:setLabelString("txt_1","lab_free","labelWords.plist")
            Data.drawCard.freeDia = true
        else
            local num=Data.getItemNum(ITEM_ID_DRAW_CARD_ONE)
            if(num>0 or isBanshuReview())then
                self:getNode("icon1"):setTexture("images/icon/item/"..ITEM_ID_DRAW_CARD_ONE..".png")
                self:setLabelString("txt_1","x"..num)
            end
        end
        if isBanshuReview() then
            local num=Data.getItemNum(ITEM_ID_DRAW_CARD_ONE)
            self:getNode("icon1"):setTexture("images/icon/item/"..ITEM_ID_DRAW_CARD_ONE..".png")
            self:setLabelString("txt_1",num.."/1")
        end

        local num=Data.getItemNum(ITEM_ID_DRAW_CARD_TEN)
        if(num>0 or isBanshuReview())then
            if num>0 then
                self:getNode("icon2"):setTexture("images/icon/item/"..ITEM_ID_DRAW_CARD_TEN..".png")
                self:setLabelString("txt_2",num.."/1")
            else
                local num=Data.getItemNum(ITEM_ID_DRAW_CARD_ONE)
                self:getNode("icon2"):setTexture("images/icon/item/"..ITEM_ID_DRAW_CARD_ONE..".png")
                self:setLabelString("txt_2",num.."/10")
            end
            
        end

    elseif(type==2)then
        --魂匣抽卡
        self:getNode("panel_buy1"):setVisible(false)
        self:getNode("layer_luck"):setVisible(true)
        self:setLabelString("txt_2",Data.drawCardParams.price_soul_buy)
        self:setLabelString("txt_ten",gGetWords("drawCardWords.plist","5"))
        self:refreshSoulLuck();
    end

end

function DragonUI:refreshSoulLuck()

    self:setLabelString("txt_soulluck",Data.drawCard.soulluck);
    self:setBarPer("fexp_bar",Data.drawCard.soulluck/Data.drawCardParams.maxLuck);
    
    if(Data.drawCard.soulluck >= Data.drawCardParams.maxLuck)then
        self:getNode("soul_luckbox"):playAction("ui_atlas_box_2");
    else
        self:getNode("soul_luckbox"):playAction("ui_atlas_box_1");
    end    
end


function DragonUI:initOnePanel(items)
    self:getNode("panel_one"):setVisible(true)
    local container=self:getNode("item_1_1")
    local item=items[1]
    self.actions={}
    local delay=1.4
    self:playReward(container,item,delay,1)

    local function onDrawEnd()
        Guide.pause=false
        self.isShowing=false
        Guide.updateGame()

    end
    delay=delay+1.0
    table.insert(self.actions, cc.Sequence:create(cc.DelayTime:create(delay),cc.CallFunc:create(onDrawEnd)))
    self:runAction(cc.Spawn:create(self.actions))
end

function DragonUI:initSixPanel(items)
    self:getNode("panel_six"):setVisible(true)
    self:getNode("soul_panel"):setVisible(true)
    self.actions={}
    self:getNode("panel_six_effect"):removeAllChildren()

    local animationData= ccs.ArmatureDataManager:getInstance():getAnimationData("ui_dragon_six_out")
    local movementData=  animationData:getMovement("stand")
    local movementBoneData=  movementData:getMovementBoneData("action")


    local predelay=1.5
    local function onCreateEffect()
        local fla=gCreateFla("ui_dragon_six_out",-1)
        gAddCenter(fla, self:getNode("panel_six_effect") )

    end

    local newItems,newIdxs = math.disruptTable(items)
    local delays={}
    local passTime=0
    for i=0, movementData.duration do
        local frameData= movementBoneData:getFrameData(i)
        if(frameData)then
            passTime=passTime+frameData.duration
            if(string.find(frameData.strEvent,"disapper"))then
                delays[ toint( string.gsub(frameData.strEvent,"disapper_",""))]=passTime
            end
        end
    end

    for key, item in pairs(newItems) do
        local container=self:getNode("item_3_"..key)
        self:playReward(container,item,delays[key]/30+predelay,newIdxs[key])
    end

    if(Data.drawCard.soul)then
        for i=1,4 do
            local itemid = Data.drawCard.soul["soul"..i]
            if(self:getNode("soul"..i).itemid~=itemid)then
                self:getNode("soul"..i).itemid=itemid
                self:getNode("soul"..i):setCascadeOpacityEnabled(false ); 
                local item = Icon.setDropItem(self:getNode("soul"..i),toint("1"..itemid),0); 
            end
        end
    end    

    local function onDrawEnd()
        Guide.pause=false
        self.isShowing=false
    end
    table.insert(self.actions,
        cc.Sequence:create(
            cc.DelayTime:create(predelay),
            cc.CallFunc:create(onCreateEffect),
            cc.DelayTime:create(movementData.duration/30),
            cc.CallFunc:create(onDrawEnd)
        )
    )

    self:runAction(cc.Spawn:create(self.actions))
end


function DragonUI:initTenPanel(items)
    self:getNode("panel_ten"):setVisible(true)
    self.actions={}
    local delay=0
    local newItems,newIdxs = math.disruptTable(items)
    for key, item in pairs(newItems) do
        local container=self:getNode("item_2_"..key)
        delay=1.4+0.2*key
        self:playReward(container,item,delay,newIdxs[key])
    end
    delay=delay+1.0

    local function onDrawEnd()
        Guide.pause=false
        self.isShowing=false
    end
    table.insert(self.actions, cc.Sequence:create(cc.DelayTime:create(delay),fadeIn,cc.CallFunc:create(onDrawEnd)))
    self:runAction(cc.Spawn:create(self.actions))

end

function DragonUI:playReward(container,item,delay,idx)

    container:removeAllChildren(true)
    container:setOpacity(0)


    local function onAppear()

        local fla=FlashAni.new()


        local function onPlayerEnd()
            fla:playAction("ui_dragon_card_stand")
            local node=  self:changeBoneIcon(fla,item)
            container.item=node
        end

        local function newCardCallback()
            self:resume()
            fla:playAction("r"..item.id.."_wait")
            local shadow=cc.Sprite:create("images/battle/shade.png")
            shadow:setScaleY(0.5)
            fla:addChild(shadow,-1)
        end

        local function newCardSoulCallback()
            self:resume()
            fla:playAction("ui_dragon_card_out",onPlayerEnd)
            local node=  self:changeBoneIcon(fla,item)
            container.item=node
        end

        container:addChild(fla)
        fla:setPositionX(container:getContentSize().width/2)
        fla:setPositionY(container:getContentSize().height/2)

        if(ITEMTYPE_CARD== DB.getItemType(item.id))then
            Panel.popUp(PANEL_NEW_CARD,item,newCardCallback)
            self:pause()
        elseif(ITEMTYPE_CARD_SOUL == DB.getItemType(item.id)) and self:isCardToSoul(idx) then
            Panel.popUp(PANEL_NEW_CARD, item,newCardSoulCallback)
            self:pause()
        else
            fla:playAction("ui_dragon_card_out",onPlayerEnd)
            local node=  self:changeBoneIcon(fla,item)
            container.item=node
        end



    end
    table.insert(self.actions, cc.Sequence:create(cc.DelayTime:create(delay),fadeIn,cc.CallFunc:create(onAppear)))
end


function DragonUI:changeBoneIcon(fla,item)
    local bone= fla:getBone("icon")
    local node=nil

    local armature=bone:getChildArmature()
    bone=armature:getBone("icon")
    if(bone)then
        node=DragonUI:createIcon(item)
        bone:addDisplay(node,1)
        bone:changeDisplayWithIndex(1, true)
        bone:setIgnoreMovementBoneData(true)
        bone:setLocalZOrder(100) 
    end
    if(DB.getSoulNeedLight(item.id))then
        fla:replaceBoneWithNode({"icon","effect"},gCreateFlaDislpay("ui_kuang_guang",1))
    end
    
    return node

end

function DragonUI:createIcon(item)

    local node=DropItem.new()
    node:setAnchorPoint(cc.p(0.5,-0.5))
    node:setData(item.id,nil,true)
    node:setNum(item.num )
    return node
end

function DragonUI:isCardToSoul(idx)
    if idx < 1 or idx > 10 or self.cidArray == nil or self.cidArray:size() == 0 then
        return false
    end

    for i = 0,  self.cidArray:size() - 1 do
        if idx == self.cidArray[i] then
            return true
        end
    end

    return false
end




return DragonUI