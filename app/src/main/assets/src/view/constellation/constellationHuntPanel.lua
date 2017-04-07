local ConstellationHuntPanel=class("ConstellationHuntPanel",UILayer)

function ConstellationHuntPanel:ctor()
    self:init("ui/ui_constellation_hunt.map")
    self.isHunting = false
    self:getNode("panel_one"):setVisible(false)
    self:getNode("panel_five"):setVisible(false)
    self:initContainer()
    self:initBasicInfo()
end

function ConstellationHuntPanel:events()
    return {
            EVENT_ID_CONSTELLATION_REDPOS_REFRESH
        }
end

function ConstellationHuntPanel:dealEvent(event, param)
    if event == EVENT_ID_CONSTELLATION_REDPOS_REFRESH then
        self:initBasicInfo()
        self:playHuntingFla()
        self:setItems(param.items,param.type)
    end
end

function ConstellationHuntPanel:onTouchBegan(target,touch)
    local node=self:getNode(target.touchName)
    if(node and node.item)then
        node.touchNode.__touchend=true
        node.item.touchNode=node.touchNode
        node.item:onTouchBegan(target,touch) 
    end
end

function ConstellationHuntPanel:onTouchEnded(target, touch, event)
    if self.isHunting then
        return
    end

    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_hunt_one" then
        if gConstellation.getHuntFreeNum() ~= 0 then
            Net.sendCircleHunt(1)
        else
            if isBanshuUser() then return end
            if Data.getCurDia() < self.huntOnePrice then
                NetErr.noEnoughDia()
                return
            end
            Net.sendCircleHunt(1)
        end
    elseif target.touchName=="btn_hunt_five" then
        if Data.getCurDia() < self.huntFivePrice then
            NetErr.noEnoughDia()
            return
        end
        Net.sendCircleHunt(5)
    elseif target.touchName=="btn_exchange" then
        Panel.popUpVisible(PANEL_SHOP, SHOP_TYPE_CONSTELLATION)
    elseif target.touchName=="btn_bag" then
        Panel.popUp(PANEL_CONSTELLATION_BAG)
    else
        local node=self:getNode(target.touchName)
        if(node and node.item)then
            node.item.touchNode=node.touchNode
            node.item:onTouchEnded(target)
        end
    end
end

function ConstellationHuntPanel:initBasicInfo()
    if gConstellation.getHuntFreeNum() ~= 0 then
        self:getNode("txt_free"):setVisible(true)
        self:getNode("layout_hunt_one"):setVisible(false)
    else
        self:getNode("txt_free"):setVisible(false)
        self:getNode("layout_hunt_one"):setVisible(true)
    end
    local huntPrices = DB.getConstellationHuntPrices()
    self.huntOnePrice = huntPrices[1]
    self.huntFivePrice = huntPrices[2]
    self:setLabelString("txt_hunt_one", self.huntOnePrice)
    self:getNode("layout_hunt_one"):layout()
    self:setLabelString("txt_hunt_five", self.huntFivePrice)
    self:getNode("layout_hunt_five"):layout()

    local huntTip = gGetMapWords("ui_constellation_hunt.plist","5",gConstellation.getHuntBingo())
    self:setRTFString("txt_hunt_tip", huntTip)

    if isBanshuUser() then
        self:getNode("btn_hunt_five"):setVisible(false);
        self:getNode("layout_hunt_five"):setVisible(false);

        local btnFive = self:getNode("btn_hunt_five");
        local btnOne = self:getNode("btn_hunt_one");
        local layoutOne = self:getNode("layout_hunt_one");
        local labFree = self:getNode("txt_free");
        local offset = btnFive:getPositionX() - btnOne:getPositionX();
        btnOne:setPositionX(btnOne:getPositionX()+offset*0.5);
        layoutOne:setPositionX(layoutOne:getPositionX()+offset*0.5);
        labFree:setPositionX(labFree:getPositionX()+offset*0.5);
        labFree:setVisible(true);
        layoutOne:setVisible(false);

        if gConstellation.getHuntFreeNum() == 0 then
            labFree:setString("次数已用完");
        end
    end
end

function ConstellationHuntPanel:initContainer()
    loadFlaXml("ui_dragon")
    local containers = {}
    table.insert(containers,"1_1")
    for i=1, 5 do
        table.insert(containers,"2_"..i)
    end

    for key,var in pairs(containers) do
        local node=cc.Node:create()
        local type=toint(string.split(var,"_")[1])
        node:setContentSize(cc.size(100,100))

        if(type==1)then
            self:getNode("panel_one"):addChild(node)
        elseif(type==2)then
            self:getNode("panel_five"):addChild(node)
        end


        local posx,posy=self:getNode("item_"..var):getPosition()
        node:setPosition(posx-50,posy+30)
        self:getNode("item_"..var).touchNode=node
        node:setLocalZOrder(self:getNode("item_"..var):getLocalZOrder())
        self:addTouchNode(node,"item_"..var,0)
    end
end

function  ConstellationHuntPanel:setItems(items,type)
    self.type = type
    self.isHunting = true
    self:getNode("panel_one"):setVisible(false)
    self:getNode("panel_five"):setVisible(false)

    if(table.getn(items)==1)then
        self:initOnePanel(items)
    elseif(table.getn(items)==5)then
        self:initFivePanel(items)
    end
end

function ConstellationHuntPanel:initOnePanel(items)
    self:getNode("panel_one"):setVisible(true)
    local container = self:getNode("item_1_1")
    local item = items[1]
    self.actions = {}
    local delay = 0.3

    self:playHunting(container, item, delay, 1)

    local function onDrawEnd()
        self.isHunting =false
    end
    delay = delay + 1.0
    table.insert(self.actions, cc.Sequence:create(cc.DelayTime:create(delay),cc.CallFunc:create(onDrawEnd)))
    self:runAction(cc.Spawn:create(self.actions))
end

function ConstellationHuntPanel:initFivePanel(items)
    self:getNode("panel_five"):setVisible(true)
    self.actions={}
    local delay=0
    local newItems,newIdxs = math.disruptTable(items)
    for key, item in pairs(newItems) do
        local container=self:getNode("item_2_"..key)
        delay=0.3 + 0.2*key
        self:playHunting(container,item,delay,newIdxs[key])
    end
    delay=delay+1.0

    local function onDrawEnd()
        self.isHunting=false
    end
    table.insert(self.actions, cc.Sequence:create(cc.DelayTime:create(delay),fadeIn,cc.CallFunc:create(onDrawEnd)))
    self:runAction(cc.Spawn:create(self.actions))
end

function ConstellationHuntPanel:playHunting(container, item, delay, idx)
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


        fla:playAction("ui_dragon_card_out",onPlayerEnd)
        local node=  self:changeBoneIcon(fla,item)
        container.item=node
    end
    table.insert(self.actions, cc.Sequence:create(cc.DelayTime:create(delay),fadeIn,cc.CallFunc:create(onAppear))) 
end

function ConstellationHuntPanel:changeBoneIcon(fla,item)
    local bone= fla:getBone("icon")
    local node=nil

    local armature=bone:getChildArmature()
    bone=armature:getBone("icon")
    if(bone)then
        node=ConstellationHuntPanel:createIcon(item)
        bone:addDisplay(node,1)
        bone:changeDisplayWithIndex(1, true)
        bone:setIgnoreMovementBoneData(true)
        bone:setLocalZOrder(100) 
    end
    
    return node
end

function ConstellationHuntPanel:createIcon(item)
    local node=DropItem.new()
    node:setAnchorPoint(cc.p(0.5,-0.5))
    node:setData(item.id,nil,true)
    node:setNum(item.num )
    return node
end

function ConstellationHuntPanel:playHuntingFla()
    loadFlaXml("ui_liexing")
    local huntingFla = FlashAni.new()
    huntingFla:playAction("ui_liexing_b", function()
                            huntingFla:removeFromParent()
                        end, nil, 1)
    gAddCenter(huntingFla, self:getNode("container_hunt_fla"))
end

return ConstellationHuntPanel
