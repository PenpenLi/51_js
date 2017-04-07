local TreasureQuenchOneKeyPanel=class("TreasureQuenchOneKeyPanel",UILayer)

function TreasureQuenchOneKeyPanel:ctor(treasure)
    self.appearType = 1 
    self:init("ui/ui_treasure_yijian.map") 
    self.curData=treasure
    self.stoneNum={0,0,0,0}
    self.stoneExp={0,0,0,0}
    self:setData(self.curData,self.cardid)
end

function TreasureQuenchOneKeyPanel:setData(data,cardid)
    local db=DB.getTreasureById(data.itemid)
    Icon.setIcon(data.itemid,self:getNode("icon"))
    self:setLabelString("txt_name",db.name)
    
    local maxLevel=math.floor(gUserInfo.level/2)
    local totalExp=0
    for key, var in pairs(QuenchStone) do
        Icon.setIcon(var,self:getNode("stone"..key))
        local num= Data.getItemNum(var)
        local db=DB.getItemById(var)
        self.stoneExp[key]=db.param
        totalExp=totalExp+num*db.param 
    end
    self:resetLayOut()

    local treasureDb=DB.getTreasureById(data.itemid) 
    local curLevel=data.quenchLevel 
    local curExp=data.quenchExp+totalExp
    while(true)do 
        local needExp=self:getQuenchNeedExp(curLevel+1,db)
        if(needExp==0 or curExp<needExp)then
            break
        end 
        curExp=curExp-needExp
        curLevel=curLevel+1
    end 
    
    if(curLevel<maxLevel)then
        maxLevel=curLevel
    end 
    
    if(maxLevel<data.quenchLevel)then
        maxLevel=data.quenchLevel
    end
    
    self.maxLevel=maxLevel
    self:setLabelString("txt_level1",data.quenchLevel) 
    self.itemNum=maxLevel-data.quenchLevel
    self.buyTimes = 0; 
    self:refreshInfo(self.buyTimes);
end

function TreasureQuenchOneKeyPanel:getQuenchNeedExp(level,db)
    local nextLevelData=DB.getTreasureQuench(level,db.type)
    if(nextLevelData)then
        return math.floor(nextLevelData.exp* DB.getTreasureQuanchParam(db.quality)/100),nextLevelData
    end
    return 0
end


function TreasureQuenchOneKeyPanel:needStone(buyTimes)
    local totalExp=0
    local db=DB.getTreasureById(self.curData.itemid)  
    for i=self.curData.quenchLevel, self.curData.quenchLevel+buyTimes-1 do 
        local needExp=self:getQuenchNeedExp(i+1,db)
        totalExp=totalExp+needExp
   end  
    totalExp=totalExp -self.curData.quenchExp
    if(totalExp<=0)then
        totalExp=0
    end
    self.stoneNum={0,0,0,0}
    for key, var in pairs(QuenchStone) do 
        local num= Data.getItemNum(var)
        local exp=self.stoneExp[key] 
        if(totalExp-exp*num<=0)then
            self.stoneNum[key]=math.ceil(totalExp/exp)
            break
        end
        totalExp=totalExp-num*exp
        self.stoneNum[key]=num
    end
   
end


function TreasureQuenchOneKeyPanel:refreshInfo(buyTimes)
    print(buyTimes)
    self:setLabelAtlas("txt_buy_times",buyTimes); 
    self:setLabelString("txt_level2",self.curData.quenchLevel+buyTimes)
    self:setTouchEnable("btn_open",false,true)
    self:needStone(buyTimes)
    local hasStone=false
    for key, var in pairs(QuenchStone) do 
        local num= Data.getItemNum(var)
        self:setLabelString("txt_num"..key,self.stoneNum[key].."/"..num)
        if(self.stoneNum[key]>0)then
            hasStone=true
        end
    end
    if(hasStone)then
        self:setTouchEnable("btn_open",true,false)
    end
    self:resetLayOut();
end

function TreasureQuenchOneKeyPanel:subBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes - offsetTimes;
    if self.buyTimes < 0 then
        self.buyTimes = 0;
    end
    self:refreshInfo(self.buyTimes);
end

function TreasureQuenchOneKeyPanel:addBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes + offsetTimes;
    if self.buyTimes > self.itemNum then
        self.buyTimes = self.itemNum;
    end
    self:refreshInfo(self.buyTimes);
end


function TreasureQuenchOneKeyPanel:onTouchEnded(target)
    if(target.touchName=="btn_open")then
        Net.sendTreasureQuenchOneKey(self.curData.id,QuenchStone,self.stoneNum)
        self:onClose()

    elseif target.touchName == "btn_sub" then
        self:subBuyTimes(1);
    elseif target.touchName == "btn_add" then
        self:addBuyTimes(1);
    elseif target.touchName == "btn_sub1" then
        self:subBuyTimes(10);
    elseif target.touchName == "btn_add1" then
        self:addBuyTimes(10);  
        
    elseif(target.touchName=="btn_close")then
        self:onClose()

    end
end
 
return TreasureQuenchOneKeyPanel