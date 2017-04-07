local ActivityTuanPanel=class("ActivityTuanPanel",UILayer)

function ActivityTuanPanel:ctor(data)
    self:init("ui/ui_hd_tuan.map") 
    self.curData=data
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    Net.sendActivityTuan(data)
    self:getNode("layer_bg"):setVisible(false)

    loadFlaXml("ui_tuangou")
end

function ActivityTuanPanel:onPopup()
    -- self:setBtnReward()
    if (Data.redpos.bolTuanRewardRec==false) then
        Net.moveActRedpos(Data.activityTuanData.idx)
    end
    self:setCurMenu(self:getNode("scroll").items[self.key].curData,self.key)
end

function ActivityTuanPanel:onTouchEnded(target)
    if(target.touchName=="btn_buy")then
        if (Data.getItemNum(ITEM_TICKET_GROUPBUY)>=self.needticket) then
            Net.sendActivityTuanBuy(Data.activityTuanData.idx,self.detid)
        else
            if NetErr.isDiamondEnough(self.new_price) then
               Net.sendActivityTuanBuy(Data.activityTuanData.idx,self.detid)
            end
        end
    elseif(target.touchName=="btn_reward") then
        -- Panel.popUp(PANEL_ACTIVITY_TUAN_REWARD)
        Net.sendActivityTuanReward(Data.activityTuanData.idx)
    end
end

function ActivityTuanPanel:setData(param)
    self:getNode("layer_bg"):setVisible(true)
    self:getNode("scroll"):clear()
    -- print_lua_table(Data.activityTuanData.list)
    for key, value in pairs( Data.activityTuanData.list) do
        local item=ActivityTuanItem.new(self.curData.type)
        item.curActData= self.curData
        item:setData(key,value)
        -- item:setScale(0.4)
        item.onSelectCallback=function (data,key)
            self:setCurMenu(data,key)
        end
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
    if(table.getn(self:getNode("scroll").items)~=0)then
        self:setCurMenu(self:getNode("scroll").items[1].curData,self:getNode("scroll").items[1].key)
    end

    self:setRTFString("lab_help",Data.activityTuanData.desc)
    -- self:replaceRtfString("lab_score",Data.activityTuanData.score)
    self:getNode("scroll_contain_item"):layout()
    self:getNode("help_bg"):layout()
end

function  ActivityTuanPanel:setCurMenu(data,key)
   
    for k, v in pairs(self:getNode("scroll").items) do
        -- print(k,v.key)
        v:setSelect(v.key==key)
    end

    self.detid = data.idx
    self.key = key
    -- print("---------------")
    -- local type=data.type
    -- print("key="..key)
    -- data.allnum = 100
    -- data.plist = {
    -- {num=0,sale=80},
    -- {num=15,sale=70},
    -- {num=20,sale=60},
    -- {num=50,sale=50},
    -- {num=1100,sale=40},
    -- }

    local sale = 100
    local maxnum = 0
    local index = 1
    local oneList1 = nil
    local oneList2 = nil
    for k,v in pairs(data.plist) do
        self:replaceLabelString("lab_z"..k,gGetDiscount(v.sale/10))
        self:replaceLabelString("lab_j"..k,v.num)
        if (data.allnum>=v.num) then
            sale = v.sale
            index = k
        end
        maxnum = v.num
    end

    local size = #data.plist
    if (index<=size) then
        oneList1 = data.plist[index]
    end
    if (index+1<=size) then
        oneList2 = data.plist[index+1]
    end

    -- print_lua_table(oneList1)
    -- print("---------"..index)
    -- print_lua_table(oneList2)

    local tmp_allnum = 0
    local tmp_maxnum = 0
    if (index+1<=size) then
        local new_allnum = data.allnum
        local bili = (new_allnum - oneList1.num)/(oneList2.num-oneList1.num) -- 比例
        -- print("bili="..bili)
        tmp_allnum = bili*(oneList2.num * index - oneList2.num * (index-1)) + oneList2.num * (index-1)
        tmp_maxnum = oneList2.num * (size-1)
    else
        tmp_allnum = 1
        tmp_maxnum = 1
    end
    -- print(tmp_allnum,tmp_maxnum)

    Icon.setDropItem(self:getNode("icon_bg"), (data.itemid),data.itemnum,DB.getItemQuality(data.itemid))

    self:setLabelString("lab_name",DB.getItemName(data.itemid))

    self:replaceRtfString("lab_word",data.allnum,gGetDiscount(sale/10))

    self:setLabelString("txt_price1",data.diamond)
    self.new_price = math.floor(data.diamond*sale/100);
    self.needticket = data.needticket
    self:setLabelString("txt_price2",self.new_price)

    self:setLabelString("lab_t_num",Data.getItemNum(ITEM_TICKET_GROUPBUY))
    self:setLabelString("lab_t_num2",data.needticket)

    self:getNode("lay_t_bg"):layout()
    self:getNode("lay_t_bg2"):layout()
    -- self:replaceLabelString("lab_t_num",Data.getItemNum(ITEM_TICKET_GROUPBUY),data.needticket)--购物券
    -- self:replaceLabelString("lab_t_num2",data.needticket)--购物券
    self:replaceLabelString("lab_buy_num",data.leftnum,data.maxnum)--限量

    -- self:setBarPer2("bar",data.allnum,maxnum)
    self:setBarPer2("bar",tmp_allnum,tmp_maxnum)

    self:setTouchEnable("btn_buy",true,data.leftnum<=0)

    self:replaceRtfString("lab_score",Data.activityTuanData.score)

    for i=1,4 do
        local bg = self:getNode("jt"..i)
        bg:removeChildByTag(100)
        if (index>=i) then
            if (index==i) then
                local fla = gCreateFla("ui_tuangou_jiantou",1);
                fla:setTag(100)
                gAddChildInCenterPos(bg,fla)
                -- self:getNode("jt"..i):setVisible(true)
            else
                -- self:changeTexture("jt"..i,"images/ui_public1/jiantou_green1.png")
                local ret=cc.Sprite:create("images/ui_public1/jiantou_green1.png")
                ret:setTag(100)
                gAddChildInCenterPos(bg,ret)
            end
        end
    end
    for i=1,5 do
        --发光效果
        local bg = self:getNode("zhe"..i)
        self:changeTexture("zhe"..i,"images/ui_huodong/tuan_di2.png")
        bg:removeChildByTag(100)
        if (index>=i) then
            if (index==i) then
                local fla = gCreateFla("ui_tuangou_ka",1);
                fla:setTag(100)
                gAddChildInCenterPos(bg,fla)
            else
                self:changeTexture("zhe"..i,"images/ui_huodong/tuan_di1.png")
            end 
        end
    end

    self:setBtnReward()
end

function ActivityTuanPanel:setBtnReward()
    local reward = self:getNode("btn_reward")
    reward:removeAllChildren();
    reward:setOpacity(255);
    if (Data.redpos.bolTuanRewardRec) then
        reward:setOpacity(0);
        local fla = gCreateFla("ui_tuangou_jiang",1);
        gAddChildInCenterPos(reward,fla)
    end
end

function ActivityTuanPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_TUAN )then
        self:setData(param)
    elseif(event==EVENT_ID_GET_ACTIVITY_TUAN_GET)then
        -- print("self.key============"..self.key)
        self:setCurMenu(self:getNode("scroll").items[self.key].curData,self.key)
        self:refreshData(param)
    end
end

function ActivityTuanPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)
    end
end       

return ActivityTuanPanel