local ActivityWishPanel=class("ActivityWishPanel",UILayer)

function ActivityWishPanel:ctor(data)
    self:init("ui/ui_hd_wish.map")

    self.curData=data
    self.bolUpdate = false;
    self.bolAction = false;
    Data.activityWish.iSelectIndex = 0;

    loadFlaXml("ui_xuyuan")
    self.actionBg = self:getNode("act_bg")

    -- print("Data.activity.wish_retime="..Data.activity.wish_retime)

    Net.sendWishGetInfo()

    local function _update()
        self:update()
    end

    -- local scheduler=cc.Director:getInstance():getScheduler();
    -- self.update_time = scheduler:scheduleScriptFunc(_update,1,false);

    self:scheduleUpdate(_update,1)
end

function ActivityWishPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end
-- function ActivityWishPanel:onExit()
--     print("--------------onExit")
--     -- self.super:onUILayerExit();
--     if self.update_time then
--         cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.update_time)
--     end
-- end

function ActivityWishPanel:dealEvent(event,param)
	-- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_WISH)then
    	self.bolUpdate = true;
    	self:refreshUI()
        self:update();
    elseif (event==EVENT_ID_GET_ACTIVITY_WISH_ADD_REWARD) then
    	self:setPoint()
    	-- self:setReward()
    	self:playAction()
    elseif (event==EVENT_ID_GET_ACTIVITY_WISH_REC_REWARD) then
    	self:setReward()
    elseif (event==EVENT_ID_GET_ACTIVITY_WISH_REFRESH) then
        self:setPoint()
    end
end

function ActivityWishPanel:onTouchEnded(target)
    if  target.touchName=="btn_get"then
    	Net.sendWishRecReward()
    elseif target.touchName=="btn_help"then
        gShowRulePanel(SYS_ACT_WISH); 
    else
    	if (self.bolAction) then return end
    	if (self.bolUpdate==false) then return end
    	for i=1,10 do
    		if target.touchName==("wish"..i) then
    			Data.activityWish.iSelectIndex = i-1;
    			local data = self.tenData[i]
    			Panel.popUpVisible(PANEL_ACTIVITY_WISH_ITEM,data.id,nil,true);
    		end
    	end
    	-- self:playAction()
    end
end

function ActivityWishPanel:playAction()
	self.bolAction = true;
	self.actionBg:removeAllChildren();
	local upStarBg = gCreateFla("ui_xuyuan_effect",2);
    gAddChildInCenterPos(self.actionBg,upStarBg)

    -- Data.activityWish.add_id = 110100--obj:getInt("id")
    -- Data.activityWish.add_num = 3--obj:getInt("num")
    -- Data.activityWish.add_cri = 3--obj:getInt("cri")

    local node = DropItem.new();
    node:setData(Data.activityWish.add_id);
    node:setNum(0);
    node:setAnchorPoint(cc.p(0.5,-0.5));
    node:setOpacityEnabled(true);

    local icon = cc.Node:create();
    icon:setCascadeOpacityEnabled(true);
    icon:setContentSize(node:getContentSize());
    icon:setScale(0.5);

    local gxzBg = gCreateFla("ui_xuyuan_juhuazhuan",1);
    gxzBg:setScale(2)
    gxzBg:setVisible(false)
    gAddChildByAnchorPos(icon,gxzBg,cc.p(0,0.5),cc.p(0,-20));

    gAddChildByAnchorPos(icon,node,cc.p(0,0.5),cc.p(0,-20));

    local labWord = gCreateWordLabelTTF("+"..Data.activityWish.add_num,gFont,30,cc.c3b(255,255,255));
    labWord:setScale(1.5)
    gAddChildByAnchorPos(icon,labWord,cc.p(0,0),cc.p(0,-36));
    
    gAddChildInCenterPos(self.actionBg,icon)

    icon:setScale(0);
    icon:setOpacity(0);
    icon:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),
	            cc.Spawn:create(
	                cc.FadeTo:create(0.1,255),
	                cc.ScaleTo:create(0.2,0.5))
	            ));
    
    if (Data.activityWish.add_cri>1) then
        local baoji = gCreateBaojiWord(Data.activityWish.add_cri);
        gAddChildByAnchorPos(self.actionBg,baoji,cc.p(0.5,1),cc.p(0,30));

        baoji:setAllChildCascadeOpacityEnabled(true);
	    local time1 = 0.5;
	    local time2 = 0.5;
	    baoji:setScale(0);
	    baoji:setOpacity(0);
	    baoji:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),
	            cc.Spawn:create(
	                cc.MoveBy:create(time1,cc.p(0,50)),
	                cc.FadeTo:create(0.1,255),
	                cc.EaseBackOut:create(cc.ScaleTo:create(0.2,0.7))
	                ),
	            cc.Spawn:create(
	                cc.MoveBy:create(time2,cc.p(0,50)),
	                cc.FadeTo:create(time2,0))
	        ));
    end

    local function callback()
    	self.actionBg:removeAllChildren();
    	self:setReward()
    	self.bolAction = false;
    end
    --移动
    --获取终点位置
    local size = #Data.activityWish.reward
    local newPoint = gGetPositionByAnchorInDesNode(self.actionBg,self:getNode("get_item"..size),cc.p(0.18,-0.13))
    
    labWord:runAction(cc.Sequence:create(
    	        cc.DelayTime:create(1.8),
    	        cc.Hide:create()
	            ));
    gxzBg:runAction(cc.Sequence:create(
    	        cc.DelayTime:create(1.8),
    	        cc.Show:create()
	            ));
    icon:runAction(cc.Sequence:create(
    	        cc.DelayTime:create(1.8),
	            cc.Spawn:create(
	            	cc.MoveBy:create(0.4,newPoint),
	            	cc.Sequence:create(cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.2,0.6))
	                ),
	            cc.DelayTime:create(0.2),
	            cc.CallFunc:create(callback)
	            ));
end

function ActivityWishPanel:setPoint()
	self:setLabelString("lab_point",Data.activityWish.point.."/"..Data.activityWish.maxPoint);
end

function ActivityWishPanel:setReward()
	for key=1,10 do
		if(self:getNode("get_item_c"..key))then
		    self:getNode("get_item_c"..key):setVisible(false)
		end
		if(self:getNode("get_item"..key))then
			self:getNode("get_item"..key):removeChildByTag(100)
		end
	end
	for key,var in pairs(Data.activityWish.reward) do
		if(self:getNode("get_item"..key))then
            local node=DropItem.new() 
            node:setData(var.id)
            node:setNum(var.num)
            node:setScale(0.6)
            node:setTag(100)

            local itemNode = self:getNode("get_item"..key)
            itemNode:addChild(node)
            node:setPositionY(itemNode:getContentSize().height/2+node:getContentSize().height*0.6/2)
            node:setPositionX(itemNode:getContentSize().width/2-node:getContentSize().width*0.6/2)

        end

        if(self:getNode("get_item_c"..key) and var.cri>1) then
        	self:getNode("get_item_c"..key):setVisible(true)
        	self:setLabelString("get_item_c"..key,"X"..var.cri)
        end
	end

    --设置按钮
	local size = #Data.activityWish.reward
    -- print("Data.activityWish.point="..Data.activityWish.point)
    -- print("Data.activityWish.maxPoint="..Data.activityWish.maxPoint)
    if (size>0 and Data.activityWish.point==Data.activityWish.maxPoint) then
    	self:getNode("btn_get"):setVisible(true)
    else
    	self:getNode("btn_get"):setVisible(false)
    end
end

function ActivityWishPanel:setShowRewardBg(show)
	for key=1,10 do
		if(self:getNode("wish"..key))then
			self:getNode("wish"..key):setVisible(show)
		end
	end
end

function ActivityWishPanel:refreshUI()
	--读取数据
    self.tenData = nil;
    local reward = Data.activityWish.strReward;
    -- local count = Data.activityWish.loginCount
    -- -- print("count="..count)
    -- for k,v in pairs(wishreward_db) do
    -- 	if (v.id == count) then
    -- 		reward = v.reward;
    -- 		break;
    -- 	end
    -- end
    self:setShowRewardBg(false)
    if (reward ~= "") then
    	self:setShowRewardBg(true)
	    self.tenData= cjson.decode(reward)
	    for key,var in pairs(self.tenData) do
	    	-- print_lua_table(var)
	    	if(self:getNode("wish"..key))then
	            Icon.setIcon(var.id,self:getNode("wish"..key),DB.getItemQuality(var.id))
	            -- self:setLabelString("txt_num"..key,var.num)
	        end
	    end
    else
        --没有了
        -- self:getNode("layer_items"):setOpacity(125)
        self:getNode("layer_over"):setVisible(true);
        self:getNode("layer_point"):setVisible(false);
        self:getNode("layer_word"):setVisible(false);
        self.curData.begintime=nil
        self.curData.endtime=nil
    end

	self:setPoint()
	self:setReward()
	
end

function ActivityWishPanel:update()
	if (self.bolUpdate==false) then return end
	if (Data.activityWish.maxPoint>=Data.activity.wish_max) then 
		self:getNode("lab_time"):setVisible(false)
		return
	end
    -- self:setPoint();
	-- local passTime=gGetCurServerTime()-Data.activityWish.rTime
	-- local newTime = Data.activityWish.iTime-passTime
    -- if(newTime<0)then
    if(Data.activityWish.newTime<0)then
        --加诚意点
        -- Data.activityWish.maxPoint = Data.activityWish.maxPoint + 1;
        -- Data.activityWish.point = Data.activityWish.point + 1;
        -- Data.activityWish.iTime = Data.activity.wish_retime;
        -- Data.activityWish.rTime = gGetCurServerTime();
        -- self:setPoint();
    else
    	if (self:getNode("lab_time"):isVisible()==false) then
    		self:getNode("lab_time"):setVisible(true)
    	end
    	--倒计时
	    local word=gParserHourTime(Data.activityWish.newTime);
	    self:replaceLabelString("lab_time",word);
    end
end

return ActivityWishPanel