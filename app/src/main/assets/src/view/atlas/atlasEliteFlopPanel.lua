--精英副本翻牌奖励 - 视图端
local AtlasEliteFlopPanel=class("AtlasEliteFlopPanel",UILayer)

function AtlasEliteFlopPanel:ctor()
	self:init("ui/ui_atlas_fanpai.map")
	self.isMainLayerGoldShow = false;
	self.isMainLayerMenuShow = false;
	self.mid = CoreAtlas.EliteFlop.mid
	self.sid = CoreAtlas.EliteFlop.sid
	--print("副本: "..self.mid.."-"..self.sid)

	self.tabCards = {}
	self.tabGold = {}
	self.showItemsTime = 1.5
   
  self.cardBg = self:getNode("card_bg")
  self.labtime = self:getNode("txt_time")

  self.db_items = CoreAtlas.EliteFlop.getDataItems(self.mid,self.sid)
	self.rec_data = CoreAtlas.EliteFlop.getFlopInfo(self.mid,self.sid)
	self.db_golds = DB.getClientParamToTable("STAGE_FLOP_DIAMOND",true)
	self.clickIdx = 0
	self.endtime = EliteFlop.getFlopEndTime(self.mid,self.sid)
	self.curgold = 0
	self.shakeidx = 0
	self.bActFinish = false
	self.shakeTime = 0 

  self:beginAction()
  self:refreshTime()

  local function onNodeEvent(event)
      if event == "exit" then
          self:unscheduleUpdateEx()
      end
  end
  self:registerScriptHandler(onNodeEvent); 
   	
end

function AtlasEliteFlopPanel:flopCard(node,playtime,rotation,delaytime,halffunc,endfunc)
	-- 翻牌动画
	playtime = playtime or 0
	delaytime = delaytime or 0
	rotation = rotation or 0

	local actions = {}
	if delaytime > 0 then
		table.insert(actions,cc.DelayTime:create(delaytime))
	end
        
    table.insert(actions,cc.RotateTo:create(playtime,  cc.vec3(0,rotation,0)))
    if halffunc then
    	table.insert(actions,cc.CallFunc:create(halffunc))
    end
    
    table.insert(actions,cc.RotateTo:create(playtime,  cc.vec3(0,0,0)))

    if endfunc then
    	table.insert(actions,cc.CallFunc:create(endfunc))
	end

	node:runAction(
		cc.Sequence:create(actions)
	)
end

function AtlasEliteFlopPanel:refreshTime()
	if self.endtime > 0 then
        local function updateTime() 
        	local time = self.endtime - gGetCurServerTime()
           	if time < 0 then
                time = 0

                self:unscheduleUpdateEx()
            end
            self.labtime:setString(gParserHourTime(time))

            self:shakeCard()
        end

        self:scheduleUpdate(updateTime,1)
    end
end

function AtlasEliteFlopPanel:shakeCard()
	if self.bActFinish == false then
		return
	end

	self.shakeTime = self.shakeTime + 1

	if self.shakeTime < 2 then
		return
	else 
		self.shakeTime = 0
	end

	local pre_idx = 0
	local next_idx = 0 

	for i = 1,5 do
		local node = self.tabCards[i]
		if node.bHadFlop == false then
			if self.shakeidx < i then
				next_idx = i
				break
			elseif pre_idx == 0 then
				pre_idx = i
			end
		end
	end

	local idx = 0
	if next_idx > 0 then
		idx = next_idx
	elseif pre_idx > 0 then
		idx = pre_idx
	end

	if idx > 0 then
		self.shakeidx = idx

		local card = self.tabCards[idx]
		local actions = {}
		local scaleBy = cc.ScaleBy:create(0.2,1.2)
		table.insert(actions,scaleBy)
		table.insert(actions,scaleBy:reverse())
		card:runAction(cc.Sequence:create(actions))
	end
end

function AtlasEliteFlopPanel:beginAction()
	-- body
	local cardBg = self.cardBg
  local cx,cy = cardBg:getPosition()
  cx = cx - cardBg:getContentSize().width*2

  for i = 1,5 do
   		local cardItem = nil
   		if i ~= 3 then
   			cardItem = cc.Sprite:create("images/ui_public1/pai_1.png")
   			local p = cc.p(cx+cardItem:getContentSize().width*(i-1),cy)
   			cardItem:setPosition(p)
   			cardBg:getParent():addChild(cardItem)
   		else
   			cardItem = cardBg
   		end

   		cardItem.bHadFlop = false
   		table.insert(self.tabCards,cardItem)
  end

	self:showItemsAction()
end

function AtlasEliteFlopPanel:showItemsAction()
	-- 显示所有物品动画
	local items = self.db_items
	for i = 1,5 do
		local cardItem = self.tabCards[i]
		local wordBg = cc.Sprite:create("images/ui_word/pai_2.png")
  		gAddCenter(wordBg,cardItem)

  		local itemdata = nil
		if items then
			itemdata = items[i]
		end

   		local changeRotation=90
   		local offsetRotation = 45
   		cardItem:setRotation3D(cc.vec3(0,offsetRotation,0))

   		local function onMoveFinish()
   			self:handleCardsAction()
   		end

   		local function onMoveHalf()
      
            if wordBg then
            	wordBg:removeFromParent(true)
            	wordBg = nil
            	cardItem:setRotation3D(cc.vec3(0,-180+changeRotation,0))
            	if itemdata then
           			local icon=DropItem.new()
    				icon:setData(itemdata.itemid,DB.getItemQuality(itemdata.itemid))
    				icon:setNum(itemdata.num)
    				icon:setAnchorPoint(cc.p(0.5,0.5))
    				icon.touch = false
    				gAddChildByAnchorPos(cardItem,icon,cc.p(0.5,0.5),cc.p(0,icon:getContentSize().height));
        		end
            else
          		cardItem:removeAllChildren()
            	wordBg = cc.Sprite:create("images/ui_word/pai_2.png")
  				gAddCenter(wordBg,cardItem)
  				cardItem:setRotation3D(cc.vec3(0,-180+changeRotation,0))
            end
            
        end

        local function onMoveEnd()
			local callback = nil
			if i == 5 then
				callback = onMoveFinish
			end 
			
			self:flopCard(cardItem,0.3,changeRotation,self.showItemsTime,onMoveHalf,callback)
   		end
   		local playtime = 0.3*(changeRotation-offsetRotation)/changeRotation
       	self:flopCard(cardItem,playtime,changeRotation-offsetRotation,0,onMoveHalf,onMoveEnd)
	end
end

function AtlasEliteFlopPanel:handleCardsAction()
	-- 洗牌、发牌动画
	for k,v in pairs(self.tabCards) do
    	v:removeAllChildren()
    	v:setOpacity(0)
    end

   	local cardBg = self.cardBg
   	loadFlaXml("ui_fanpai")
   	local handleCardsAction=gCreateFla("ui_fanpaidonghua",-1)
   	gAddCenter(handleCardsAction,cardBg)

    --print("动画时间:"..gGetActionTime("ui_fanpaidonghua"))
   	local actback= cc.Sequence:create(cc.DelayTime:create(gGetActionTime("ui_fanpaidonghua")),cc.CallFunc:create(self.finishAction))
    self:runAction(actback)
end

function AtlasEliteFlopPanel:refreshGold()
	local curgold = 0
	if self.rec_data.num < 5 then
		curgold = self.db_golds[self.rec_data.num+1]
	end 
	self.curgold = curgold

	for k,v in pairs(self.tabCards) do
		v:getParent():removeChildByTag(200+k)
		if v.bHadFlop == false and curgold > 0 then
			  local txt = gGetWords("eliteFlopWord.plist","gold_need",curgold)
  			local rtf = RTFLayer.new(0)
  			rtf:setString(txt)
  			rtf:setAnchorPoint(cc.p(0.5,1))
  			rtf:layout()
  			v:getParent():addChild(rtf)
  			local cx,cy = v:getPosition()
  			cy = cy - v:getContentSize().height*0.5
  			rtf:setPosition(cc.p(cx,cy))
  			rtf:setTag(200+k)
		end
	end
end

function AtlasEliteFlopPanel:finishAction()
	self.bActFinish = true

	for k,v in pairs(self.tabCards) do
		v:removeAllChildren()
		v:setOpacity(255)
		self:addTouchNode(v,"pos"..k,"1")
		local wordBg = cc.Sprite:create("images/ui_word/pai_2.png")
  		gAddCenter(wordBg,v)
	end

	local db_items = self.db_items
	local rec_data = self.rec_data
	
	if rec_data and db_items then
		local size = rec_data.list:size()
		for i = 1,size do
			local cardItem = self.tabCards[i]
			local idx = rec_data.list[i-1]
			local itemdata = db_items[idx]
			self:clickCard(cardItem,itemdata)
		end
	end

	self:refreshGold()
	
end

function AtlasEliteFlopPanel:clickCard(node,data)
	-- 翻开卡牌,显示道具
	local changeRotation = 90
	node.bHadFlop = true
	local icon = nil		
	local function onMoveHalf()
        node:removeAllChildren()
  		node:setRotation3D(cc.vec3(0,-180+changeRotation,0))
  		if data then
           	icon=DropItem.new()
    		icon:setData(data.itemid,DB.getItemQuality(data.itemid))
    		icon:setNum(data.num)
    		icon:setAnchorPoint(cc.p(0.5,0.5))
    		icon.touch = false
    		gAddChildByAnchorPos(node,icon,cc.p(0.5,0.5),cc.p(0,icon:getContentSize().height));
       	end
    end

    local function onMoveEnd()
        if icon then
        	icon.touch = true
        end
    end
            
    self:flopCard(node,0.3,changeRotation,0,onMoveHalf,onMoveEnd)
end

function AtlasEliteFlopPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
    	self:stopAllActions()
        Panel.popBack(self:getTag())
        CoreAtlas.EliteFlop.closeFlopPanel()
    elseif string.find(target.touchName,"pos") then
    	if self.endtime <= gGetCurServerTime() then
    		gShowNotice(gGetCmdCodeWord(CMD_ATLAS_FLOP,5))
    		return
    	end

        local pos = string.find(target.touchName,"pos");
        local index = string.sub(target.touchName,pos+3);
        self.clickIdx = toint(index)
        --print("index = "..index);
        -- print_lua_table(self.roles);
        local node = self.tabCards[self.clickIdx]
        if node.bHadFlop == false
        	and NetErr.isDiamondEnough(self.curgold)
        	then
        	Net.sendAtlasFlop(self.mid,self.sid)
          gLogPurchase("atlas.flop", 1, self.curgold)
        end

        --Panel.clearTouchTip()
    end
end 

function  AtlasEliteFlopPanel:events()
    return {EVENT_ID_REC_ELITE_FLOP}
end


function AtlasEliteFlopPanel:dealEvent(event,param)
    if(event==EVENT_ID_REC_ELITE_FLOP )then
    	local rec_data = CoreAtlas.EliteFlop.getFlopInfo(self.mid,self.sid)
    	if rec_data == nil or self.clickIdx <= 0 then
    		return
    	end
    	self.rec_data = rec_data

    	local cardItem = self.tabCards[self.clickIdx]
    	local idx = rec_data.num

		  idx = rec_data.list[idx-1]
		  local itemdata = self.db_items[idx]
		  self:clickCard(cardItem,itemdata)
		  self:refreshGold()

      -- 翻牌完成
      if rec_data.num == 5 then
        self:unscheduleUpdateEx()
        local txt = gGetWords("eliteFlopWord.plist","finish_leave")
        self:getNode("btn_word"):setString(txt)
        self.labtime:getParent():setVisible(false)
      end

    end
end

return AtlasEliteFlopPanel