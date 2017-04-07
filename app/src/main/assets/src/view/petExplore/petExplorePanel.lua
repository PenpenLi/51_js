local PetExplorePanel=class("PetTalentBookPanel",UILayer)

-- EVENT_TYPE_CARD = 1 --事件1 翻牌 
-- EVENT_TYPE_SHOP = 2--事件2 哥布林商人
-- EVENT_TYPE_BEAST = 3--事件3 远古兽骸
-- EVENT_TYPE_BOX = 4--事件4 神奇宝箱
-- EVENT_TYPE_CHALLENGE = 5--事件5 挑战守卫
-- EVENT_TYPE_DIAMOND = 6--事件6 元宝事件
-- EVENT_TYPE_NONE = 7--事件7 无事
-- EVENT_TYPE_GOLD = 8--事件8 金币
-- EVENT_TYPE_SPIRIT = 9--事件9 精灵
function PetExplorePanel:ctor(parma1,param2)
    self:init("ui/ui_lingshouhuodong_zhuye.map")
    Net.sendCaveInfo() 

    if isBanshuUser() then
    	self:getNode("btn_event"):setVisible(false);
    	self:getNode("btn_event"):getParent():layout();
    end
end

function PetExplorePanel:initExplorePanel()
    loadFlaXml("ui_lshd")
    loadFlaXml("ui_lingshoudongku")

    self.exploreEvens={"ls_kpds","ls_sr","ls_ygsh","ls_sqbx","ls_sw","ls_yb","ls_wsj","ls_jb","ls_xjl"}

    self:getNode("txt_alladd"):setVisible(false)
    self.CellLines={}
    self.allRate=0
    self.eachExplorTime=1.5
    self.isExploring=false
    self.exploreData=nil
    self.isOneKeyExplor=false
    --self:getNode("scroll").offsetY=-10
    if(self.role==nil)then
        self.role=gCreateRoleFla(Data.getCurIcon(), self:getNode("role_container") ,1,nil,nil,Data.getCurWeapon(),Data.getCurAwake())
        --self.role:setScale(0.6)
        local shadow=cc.Sprite:create("images/battle/shade.png")
        shadow:setScaleY(0.5)
        self.role:addChild(shadow)
    end
    
    self.selIndex=1
    self.explorTime=self.eachExplorTime
    self:autoSelectLabel()
  
  	self.oldEffectPos = cc.p(self:getNode("effect_container"):getPosition())

    self.frontBgWidth = self:getNode("bg_f1"):getContentSize().width;
    self.frontBgSpeed = self.frontBgWidth;
    self.leftEgePosX = self:getNode("bg_f1"):getPositionX() - self.frontBgWidth;

    local function updateExplor(dt)
    	if self.isExploring then
    		self:updateBgPos(dt)
    		if self.explorTime<=0 and self.exploreData~=nil then
    			self.isExploring= false
    			self:exploreFinishShow()
    		end
    		
    	end
	     
	end
	self:scheduleUpdateWithPriorityLua(updateExplor,1)


	local function updateTime() 
        if self.showFlahLine then
            self:showFlahLine()
        end
    end
    self.lineIndex=1
    self:scheduleUpdate(updateTime,0.7)
end



function PetExplorePanel:updateBgPos(dt)

		local deltaX = self.frontBgSpeed * dt
		local f1PosX = self:getNode("bg_f1"):getPositionX();
        local f2PosX = self:getNode("bg_f2"):getPositionX();
        local f3PosX = self:getNode("bg_f3"):getPositionX();
        local f4PosX = self:getNode("bg_f4"):getPositionX();

        f1PosX = f1PosX -deltaX;
        f2PosX = f2PosX -deltaX;
        f3PosX = f3PosX -deltaX;
        f4PosX = f4PosX -deltaX;
        if (f1PosX <= self.leftEgePosX)  then
            f1PosX = f4PosX + self.frontBgWidth;
        end

        if (f2PosX <= self.leftEgePosX) then
            f2PosX = f1PosX + self.frontBgWidth;
        end

        if (f3PosX <= self.leftEgePosX)then
            f3PosX = f2PosX + self.frontBgWidth;
        end
        if (f4PosX <= self.leftEgePosX)then
            f4PosX = f3PosX + self.frontBgWidth;
       	end

        self:getNode("bg_f1"):setPositionX(f1PosX);
        self:getNode("bg_f2"):setPositionX(f2PosX);
        self:getNode("bg_f3"):setPositionX(f3PosX);
        self:getNode("bg_f4"):setPositionX(f4PosX);

        if self.exploreData~=nil then
    		self.explorTime = self.explorTime-dt
    		local effectPosX = self:getNode("effect_container"):getPositionX();
    		 effectPosX = effectPosX -deltaX;
    		 self:getNode("effect_container"):setPositionX(effectPosX);
    	end
end

function PetExplorePanel:showCoinFlyAction(pos,etype,finishCallBack)

	local coin = gCreateFla("ui_lsdk_jinbi",1)
	coin:setScale(0.8,0.8)
	local offsetY = 110
    local startPos = gGetPositionByAnchorInDesNode(self,self:getNode("effect_container"),cc.p(0.5,0.5));
    coin:setPosition(startPos.x, startPos.y+offsetY)
    self:addChild(coin,100);

    local duringTime = 30/FLASH_FRAME
    local desPos = gGetPositionByAnchorInDesNode(self,self:getNode("gold_icon"..pos),cc.p(0.5,0.5));
    local bezier = {
        cc.p(startPos.x, startPos.y+offsetY),
        cc.p(startPos.x, desPos.y),
        cc.p(desPos.x, desPos.y),
        
    }
     local callback = function()
     	self:selectEvent(self.exploreData.selIndex)

     	local hitEffect = gCreateFla("ui_lsdk_huode",nil,nil)
    	local action1=cc.Sequence:create(cc.DelayTime:create(20/FLASH_FRAME),cc.CallFunc:create(finishCallBack))
		hitEffect:runAction(action1)
		gAddCenter(hitEffect,self:getNode("gold_icon"..pos))
    end
    coin:runAction(cc.Sequence:create(
            cc.EaseSineInOut:create(cc.Spawn:create(cc.BezierTo:create(duringTime, bezier),cc.ScaleTo:create(duringTime,1,1))),
            cc.CallFunc:create(callback),
            cc.RemoveSelf:create()
        ));
end

function PetExplorePanel:showEventFlyAction(etype)
	if etype==EVENT_TYPE_CARD or etype==EVENT_TYPE_SHOP or etype==EVENT_TYPE_BEAST or etype==EVENT_TYPE_BOX or etype==EVENT_TYPE_CHALLENGE then
    	local coin = gCreateFla("ui_lsdk_jinbi",1)
	    local startPos = gGetPositionByAnchorInDesNode(self,self:getNode("effect_container"),cc.p(0.5,0.5));
	    local offsetY = 50
	    coin:setPosition(startPos.x, startPos.y+offsetY)
	    self:addChild(coin,101);
	     local desPos = gGetPositionByAnchorInDesNode(self,self:getNode("btn_event"),cc.p(0.5,0.5));
	    local bezier = {
	        cc.p(startPos.x, startPos.y+offsetY),
	        cc.p(startPos.x, desPos.y-10),
	        cc.p(desPos.x, desPos.y),
	        
	    }
	    local duringTime = 5/FLASH_FRAME
	     local callback = function()
			local hitEffect = gCreateFla("ui_lsdk_huode",nil)
			local lsdkZiEffect = gCreateFla("ui_lsdk_zi",nil)
			gAddCenter(hitEffect,self:getNode("btn_event"))
			gAddCenter(lsdkZiEffect,self:getNode("btn_event"))
	    end
	    coin:runAction(cc.Sequence:create(
	            cc.EaseSineInOut:create(cc.Spawn:create(cc.BezierTo:create(duringTime, bezier),cc.ScaleTo:create(duringTime,1,1))),
	            cc.CallFunc:create(callback),
	            cc.RemoveSelf:create()
	        ));
    end
end

function PetExplorePanel:exploreFinishShow()
	local etype = self.exploreData.etype
	local effectContainer= self:getNode("effect_container")
	effectContainer:setVisible(true)
	local function playEnd()
    	--gShowNotice("探索一次完成")
    	self.exploreData=nil
		self:setTouchEnableGray("btn_explore", Data.CaveInfo.enum<Data.petCave.dayNum)
		if self.isOneKeyExplor==true and Data.CaveInfo.enum<Data.petCave.dayNum then
			self:startExplore()
		end
	end
	self.role:playAction("r"..self.role.cardid.."_wait")

    if etype == EVENT_TYPE_SPIRIT  then
		gAddCenter(gCreateFla("ui_lsdk_lsgx"), self:getNode("role_container"))
	end

	local function effectShow ()
		local function coinCallBack()
			self:showCoinFlyAction(self.exploreData.pos,etype,playEnd)
		end
		local function EventCallBack()
			self:showEventFlyAction(etype)
		end
		local yanfla = gCreateFla("ui_lsdk_yan")
		local cointype = cc.Sprite:create("images/ui_lingshou/jb_"..etype..".png")
        cointype:setCascadeOpacityEnabled(true)
        yanfla:replaceBoneWithNode({"icon"}, cointype)
		yanfla:setCascadeOpacityEnabled(true)

		gRefreshNode(effectContainer,yanfla,cc.p(0.5,0.5),nil,99)
		local action1=cc.Sequence:create(cc.DelayTime:create(10/FLASH_FRAME),cc.CallFunc:create(EventCallBack))
		local action2=cc.Sequence:create(cc.DelayTime:create(35/FLASH_FRAME),cc.CallFunc:create(coinCallBack))
		effectContainer:runAction(cc.Spawn:create(action1,action2))
	end
	local delayTime = 0.3
	if etype==EVENT_TYPE_NONE then
		gRefreshNode(effectContainer,gCreateFla(self.exploreEvens[EVENT_TYPE_NONE]),cc.p(0.5,0.5),nil,99)
		delayTime = 25/FLASH_FRAME
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(effectShow)))
end

function PetExplorePanel:autoSelectLabel()
	for i=1,27 do
		local etype = Data.CaveInfo.chessinfo[i]
		etype= etype or 0
		if etype==0 then
			local selIndex=math.floor((i-1)/9+1)
        	self:selectEvent(selIndex)
        	return
		end
	end
	for i=1,3 do
		if Data.CaveInfo["box"..i]==false then
			self:selectEvent(i)
			return
		end	
	end
    self:selectEvent(1)
end


function PetExplorePanel:selectEvent(selIndex)

	local lastIndex = self.selIndex
	self.CellLines={}
	local buffindex = 1
	for buffid,num in pairs(Data.CaveInfo.buffers) do
		self:getNode("buff_id"..buffindex):setVisible(true)
		self:getNode("buff_id"..buffindex).buffid=buffid
		self:changeTexture("buff_id"..buffindex, "images/icon/skill/"..buffid..".png")
		self:setLabelString("buff_num"..buffindex,num)
		buffindex=buffindex+1
	end
	for i=buffindex,8 do
		self:getNode("buff_id"..i):setVisible(false)
	end

	self:setTouchEnableGray("btn_explore", Data.CaveInfo.enum<Data.petCave.dayNum)
	local btns = {"btn_gold1","btn_gold2","btn_gold3"}
	for k,btn in pairs(btns) do
		self:changeTexture(btn, "images/ui_public1/b_biaoqian1.png")
	end
	self.selIndex=selIndex
	self:changeTexture("btn_gold"..selIndex,"images/ui_public1/b_biaoqian1-1.png")
	self:replaceLabelString("txt_dayNum",Data.CaveInfo.enum.."/"..Data.petCave.dayNum)


	local fillTypeNums = {}
	self.fillNum = 0
	local  curCellTypeTable={}
	local eachGoldNum = 9
	for i=1,eachGoldNum do
		self:getNode("gold_icon"..i):removeChildByTag(2)
		local index=(self.selIndex-1)*eachGoldNum+i
		local etype =Data.CaveInfo.chessinfo[index]
		etype= etype or 0
		table.insert(curCellTypeTable,etype)
		if etype>0 then
			self.fillNum= self.fillNum+1
			fillTypeNums[etype]=1
			local ret=cc.Sprite:create("images/ui_lingshou/jb_"..etype..".png")
			ret:setLocalZOrder(2)
			ret:setTag(100);
			gRefreshNode(self:getNode("gold_icon"..i),ret,cc.p(0.5,0.5),nil,2)
		end
	end

	if Data.CaveInfo["box"..selIndex] == true then
		 self:getNode("btn_box"):playAction("ui_atlas_box_3")
	else
		if self.fillNum==eachGoldNum then
			self:getNode("btn_box"):playAction("ui_atlas_box_2")
		else
			self:getNode("btn_box"):playAction("ui_atlas_box_1")
		end
	end

	if self.fillNum==0 then
		self:getNode("scroll"):clear()
		self:getNode("scroll"):layout()
		self:setLabelString("txt_alladd","+0")
		return
	end

	local horizonRate = {}
	local verticalRate = {}
	local lineRate = {}
	for i=1,3 do
		local x1 = curCellTypeTable[(i-1)*3+1]
		local x2 = curCellTypeTable[(i-1)*3+2]
		local x3 = curCellTypeTable[(i-1)*3+3]
		if  x1==x2 and x1==x3 and x1~=0  then
			if horizonRate[x1]==nil then
				horizonRate[x1]=0
			end
			table.insert(self.CellLines,{(i-1)*3+1,(i-1)*3+2,(i-1)*3+3})
			horizonRate[x1]=horizonRate[x1]+1
		end
		local y1 = curCellTypeTable[i]
		local y2 = curCellTypeTable[3+i]
		local y3 = curCellTypeTable[6+i]
		if  y1==y2 and y1==y3 and y1~=0  then
			if verticalRate[y1]==nil then
				verticalRate[y1]=0
			end
			table.insert(self.CellLines,{i,i+3,i+6})
			verticalRate[y1]=verticalRate[y1]+1
		end
	end



	local x1 = curCellTypeTable[1]
	local x3 = curCellTypeTable[3]
	local x5 = curCellTypeTable[5]
	local x7 = curCellTypeTable[7]
	local x9 = curCellTypeTable[9]
	if x1==x5 and x5==x9 and x1~=0 then
		if lineRate[x1]==nil then
			lineRate[x1]=0
		end
		lineRate[x1]=lineRate[x1]+1
		table.insert(self.CellLines,{1,5,9})
	end
	if x3==x5 and x5==x7 and x3~=0 then
		if lineRate[x3]==nil then
			lineRate[x3]=0
		end
		lineRate[x3]=lineRate[x3]+1
		table.insert(self.CellLines,{3,5,7})
	end
	local allAddRate = 0
	self:getNode("scroll"):clear()
	for etype,num in pairs(lineRate) do
		local rate = Data.petCave.chessMuls[1]
		for i=1,num do
			local item = PetGoldRewardItem.new()
			item:setData({etype=etype,dir=1,rate=rate})
			self:getNode("scroll"):addItem(item)
		end
		allAddRate = allAddRate + rate*num
	end

	for etype,num in pairs(horizonRate) do
		local rate = Data.petCave.chessMuls[2]
		for i=1,num do
			local item = PetGoldRewardItem.new()
			item:setData({etype=etype,dir=2,rate=rate})
			self:getNode("scroll"):addItem(item)
		end
		allAddRate = allAddRate + rate*num
	end
	for etype,num in pairs(verticalRate) do
		local rate = Data.petCave.chessMuls[3]
		for i=1,num do
			local item = PetGoldRewardItem.new()
			item:setData({etype=etype,dir=3,rate=rate})
			self:getNode("scroll"):addItem(item)
		end
		allAddRate = allAddRate + rate*num
	end
	if allAddRate==0 and table.count(fillTypeNums)==eachGoldNum then
		allAddRate = allAddRate + Data.petCave.chessMuls[4]
		table.insert(self.CellLines,{1,2,3,4,5,6,7,8,9})
		local item = PetGoldRewardItem.new()
		item:setData({etype=0,dir=4,rate=allAddRate})
		self:getNode("scroll"):addItem(item)
	end
	if allAddRate~=0 and self.allRate ~= allAddRate and lastIndex==selIndex then
		gAddCenter(gCreateFla("ui_lsdk_jianglibeilv"),self:getNode("allrate_layout"))
	end
	self.allRate = allAddRate
	self:getNode("scroll"):layout()

	self:setLabelString("txt_alladd","+"..(allAddRate/100))
	if self.allRate==0 then
		self:getNode("txt_alladd"):setVisible(false)
	else
		self:getNode("txt_alladd"):setVisible(true)
	end
end


function PetExplorePanel:showFlahLine()

	if self.lineIndex>table.count(self.CellLines) then
		self.lineIndex=1
	end
	if self.CellLines[self.lineIndex] then
		for k,pos in pairs(self.CellLines[self.lineIndex]) do
			local wupinEffect = gCreateFla("ui_lsdk_wupinkuang")
			-- if k==1 then
			-- 	wupinEffect = gCreateFla("ui_lsdk_wupinkuang",nil,showFlahLight)
			-- else
			-- 	wupinEffect = gCreateFla("ui_lsdk_wupinkuang")
			-- end
			gRefreshNode(self:getNode("gold_icon"..pos),wupinEffect,cc.p(0.5,0.5),nil,99)
		end
		self.lineIndex=self.lineIndex+1
	end
end



function PetExplorePanel:events()
    return {EVENT_ID_PET_EXPLORE_INFO,EVENT_ID_PET_EXPLORE,EVENT_ID_CAVE_BOX_REWARD,EVENT_ID_CAVE_REPLACE_COIN,EVENT_ID_PET_EXPLORE_ERROR}
end

function PetExplorePanel:dealEvent(event,param)
	if (event ==EVENT_ID_PET_EXPLORE_INFO) then
		self:initExplorePanel()
    elseif(event == EVENT_ID_PET_EXPLORE)then
    	self.role:playAction("r"..self.role.cardid.."_run")
		self.isExploring = true

    	local function showItemReward()
    		 gShowItemPoolLayer:pushItems(param.items);
    	end
    	self.param2=param2
    	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(showItemReward)))

    	local selIndex=math.floor((param.pos-1)/9)+1
    	local pos=param.pos-math.floor((param.pos-1)/9)*9
    	local etype = param.etype
    	local effectNode = gCreateFla(self.exploreEvens[etype],1)
    	local effectContainer = self:getNode("effect_container")
    	gRefreshNode(effectContainer,effectNode,cc.p(0.5,0.5),nil,99)
    	self.explorTime=self.eachExplorTime
    	effectContainer:setPositionX(self.oldEffectPos.x+self.explorTime*self.frontBgSpeed);
    	if etype == EVENT_TYPE_NONE  then
    		effectContainer:setVisible(false)
    	end
    	self.exploreData={selIndex=selIndex,pos=pos,etype=etype}
    	if selIndex ~= self.selIndex then
    		self:selectEvent(selIndex)
    		self:getNode("gold_icon"..pos):removeChildByTag(2)
    	end
     elseif  event== EVENT_ID_CAVE_BOX_REWARD then
     	self:autoSelectLabel()
     elseif event == EVENT_ID_CAVE_REPLACE_COIN  then
     	local selIndex=math.floor((param.pos-1)/9)+1
    	local pos=param.pos-math.floor((param.pos-1)/9)*9
    	local function replaceCallBack()
    		self:selectEvent(selIndex)
    	end
    	local action1=cc.Sequence:create(cc.DelayTime:create(15/FLASH_FRAME),cc.CallFunc:create(replaceCallBack))
		self:getNode("gold_icon"..pos):runAction(action1)
    	local hitEffect = gCreateFla("ui_lsdk_huode",nil,nil)
    	hitEffect:setLocalZOrder(100)
		gAddCenter(hitEffect,self:getNode("gold_icon"..pos))
    elseif event == EVENT_ID_PET_EXPLORE_ERROR then
    		self:stopExplore()
    end
end


function PetExplorePanel:startExplore()
	if self.isExploring==true or self.exploreData ~= nil then
		return
	end
	Net.sendCaveExplore()
end

function PetExplorePanel:stopExplore()
	self.role:playAction("r"..self.role.cardid.."_wait")
	self.isExploring = false
	self.exploreData=nil
end

function PetExplorePanel:canExplore()
	local  canExplore = false
	for i=1,27 do
		local etype = Data.CaveInfo.chessinfo[i]
		etype= etype or 0
		if etype==0 then
			canExplore =true
			break
		end
	end
	if canExplore == false then
		gShowNotice(gGetWords("petWords.plist","full_explore_coin",Data.petCave.oneKeyOpenLv))
	end
	return canExplore
end

function PetExplorePanel:onTouchBegan(target,touch, event)
    self.beganPos = touch:getLocation()
	if (string.find(target.touchName,"buff_id")) then
        local idx=toint(string.gsub(target.touchName,"buff_id",""))
        local buffDB = DB.getBuffById(target.buffid)
        Panel.popTouchTip(target,TIP_TOUCH_SKILL,buffDB,-1)
        --Panel.popTouchTip(self,TIP_TOUCH_EQUIP_ITEM,target.buffid) 
    end
end

function PetExplorePanel:onTouchMoved(target,touch)
    local offsetX=touch:getDelta().x;
    local offsetY=touch:getDelta().y;
    if(math.sqrt(offsetX*offsetX+offsetY*offsetY)>5)then
        self.isMoved=true
    end
    self.endPos = touch:getLocation();
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
    if dis > gMovedDis then
        Panel.clearTouchTip();
    end
end

function PetExplorePanel:onTouchEnded(target)
	 Panel.clearTouchTip();
	if  target.touchName=="btn_close"then
		Panel.popBack(self:getTag())
	elseif target.touchName=="btn_onekey" then
		if Data.getCurLevel()<Data.petCave.oneKeyOpenLv then
			gShowNotice(gGetWords("unlockWords.plist","unlock_tip_pos",Data.petCave.oneKeyOpenLv));
			return
		end
		self.isOneKeyExplor=not self.isOneKeyExplor
		if self.isOneKeyExplor then
			self:changeTexture("check_onecave", "images/ui_public1/gou_1.png")
		else
			self:changeTexture("check_onecave", "images/ui_public1/gou_2.png")
		end
	elseif target.touchName=="btn_event" then
		Net.sendCaveEvenList()
	elseif target.touchName=="btn_rank" then
		Panel.popUp(PANEL_ARENA_RANK,RANK_TYPE_PETCAVE)
	elseif target.touchName=="btn_book" then
		Panel.popUpVisible(PANNEL_PET_CAVE_RATE_BOOK)
	elseif target.touchName=="btn_archive" then
		Panel.popUpVisible(PANNEL_PET_CAVE_ARCHIVE)
	elseif target.touchName=="btn_explore" then
		if self:canExplore() then
			self:startExplore()
		end
	elseif target.touchName=="btn_box" then
		Panel.popUpVisible(PANNEL_PET_EXPLORE_BOX_REWARD,{id=self.selIndex,fillNum=self.fillNum,hasGeted=Data.CaveInfo["box"..self.selIndex],rate=self.allRate})
	elseif target.touchName=="btn_rule" then
		gShowRulePanel(SYS_PET_CAVE)
	elseif string.find(target.touchName,"gold_icon")~=nil then
		local idx=toint(string.gsub(target.touchName,"gold_icon",""))
		local pos = (self.selIndex-1)*9+idx
		local etype = Data.CaveInfo.chessinfo[pos]
		if etype~=nil and etype~=0 and Data.CaveInfo["box"..self.selIndex]~=true then
			Panel.popUpVisible(PANNEL_PET_REPLACE_COIN,{pos=pos,etype=etype})
		end
		
	elseif string.find(target.touchName,"btn_gold")~=nil then
		local idx=toint(string.gsub(target.touchName,"btn_gold",""))
		for i=1,9 do
			self:getNode("gold_icon"..i):removeChildByTag(99)
		end
		self:selectEvent(idx)
	end

end

return PetExplorePanel