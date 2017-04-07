local ActivitySign7Panel=class("ActivitySign7Panel",UILayer)

local boxIcons={
    "ui-box-tong",
    "ui-ssq-yin-box",
    "ui-ssq-jin-box"
}

function ActivitySign7Panel:ctor(type)
    self:init("ui/ui_hd_sign7.map")
    self.curType=type
    for i=1, 4 do
        if(type==ACT_TYPE_97)then
            Data.redpos.act97.pt=false
            self:changeTexture("icon_hand","images/ui_huodong/pop_8_3.png")
            self:changeIconType("icon"..i,OPEN_BOX_GOLD)
        else
            self:changeTexture("icon_hand","images/ui_huodong/pop_8_2.png")
            Data.redpos.act98.pt=false
            self:changeIconType("icon"..i,OPEN_BOX_DIAMOND)
        end
    end
    Net.sendActivityGetInfo97(self.curType)
end


function ActivitySign7Panel:onPopup()

    Net.sendActivityGetInfo97(self.curType)

end

function ActivitySign7Panel:resetBtnTexture()
    local btns={
        "arrow1",
        "arrow2",
        "arrow3",
    }

    for key, btn in pairs(btns) do
        self:changeTexture( btn,"images/ui_huodong/hd_song_di2.png")
        DisplayUtil.setGray(self:getNode(btn),self:getNode(btn).rec)
    end

end
function ActivitySign7Panel:selectBtn(name)
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_huodong/hd_song_di1.png")
    DisplayUtil.setGray(self:getNode(name),self:getNode(name).rec)
end



function ActivitySign7Panel:showTime(data)
    self.curTimeData=data


    local beginTime = gGetDate("*t",data.begintime)
    local curTime = gGetDate("*t", gGetCurServerTime())
    local maxDay=getGetCurMonthDayNum(beginTime)

    self.days={}
    self.curDay=curTime.day

    local function getRealDay(day)
        if(day>maxDay)then
            return (day)%maxDay
        else
            return day
        end
    end
    local find=false
    for i=0, 6 do
        local obj={}
        obj.day= getRealDay(beginTime.day+i)
        obj.reach=true
        obj.today=false
        if(find==true)then
            obj.reach=false
        end
        if(getRealDay(curTime.day)==obj.day)then
            obj.today=true
            find=true
        end
        table.insert(self.days,obj)
    end

end

function ActivitySign7Panel:setData(data)


    if(self.curType==ACT_TYPE_97)then
        Data.redpos.act97.pt=false
    else
        Data.redpos.act98.pt=false
    end
    self:getNode("scroll"):clear()
    local curConsume=0
    self.curData=data
    self.curReachDay=0
    for key, var in pairs(self.days) do
        if(data.listArr[key])then
            local consume=data.listArr[key].consume
            if( consume>=data.dayneed)then
                self.curReachDay= self.curReachDay+1
            end
            if(var.today==true )then
                curConsume= data.listArr[key].consume
            end
        end

        local item=ActivitySign7Item.new(self.curType)
        table.merge(var,data)
        item.key=key
        item:setData(var,data.listArr[key])
        item.callback=function()
            data.listArr[key].rec=true
            self:setData(self.curData)
        end
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()

    self:setLabelString("txt_cur_consume",curConsume)
    local descs=string.split(data.desc,"\\n")
    self:setLabelString("txt_desc1",descs[1])
    self:setLabelString("txt_desc2",descs[2])
    local per=0
    local curStep=0
    for i=1, 3 do
        gShowShortNum(self,"txt_consume"..i,data.consumeArr[i],100000);
        self:replaceLabelString("txt_return"..i,data.returnArr[i])
        self:replaceLabelString("txt_need_day"..i,data.boxArr[i].day)
        if(curConsume>=data.consumeArr[i] )then
            curStep=i
        end
    end

    if(curStep==3)then
        per=100
    elseif(curStep==2)then
        per=50+ ((curConsume-data.consumeArr[2])/(data.consumeArr[3]-data.consumeArr[2]))*50
    elseif(curStep==1)then
        per= (curConsume /data.consumeArr[2])*50
    end


    self:setBarPer("bar",per/100)
    for i=1, 3 do
        gShowShortNum(self,"txt_need_num"..i,data.dayneed,100000);

        local boxData=self.curData.boxArr[i]
        self:getNode("arrow"..i).rec=boxData.rec
        if(boxData.rec==false and self.curReachDay>=boxData.day)then

            if(self.curType==ACT_TYPE_97)then
                Data.redpos.act97.pt=true
            else
                Data.redpos.act98.pt=true
            end
        end
    end

    if(self.curSelectBoxid==nil)then
        self.curSelectBoxid=1
        for i=1, 3 do
            local boxData=self.curData.boxArr[i]
            if(boxData.rec==false)then
                self.curSelectBoxid=i
                break
            end
        end
    end
    self:onSelectBoxid(self.curSelectBoxid)
    self:selectBtn("arrow"..self.curSelectBoxid)
    self:resetLayOut()

end


function ActivitySign7Panel:dealEvent(event,data)
    if(event==EVENT_ID_GET_ACTIVITY_97_GETINFO)then

        self:setData(data)
    end
end

function ActivitySign7Panel:onTouchEnded(target)
    if(target.touchName=="arrow1")then
        self:selectBtn(target.touchName)
        self:onSelectBoxid(1)
    elseif(target.touchName=="arrow2")then

        self:selectBtn(target.touchName)
        self:onSelectBoxid(2)
    elseif(target.touchName=="arrow3")then
        self:selectBtn(target.touchName)
        self:onSelectBoxid(3)

    elseif(target.touchName=="box_icon")then

        local function onGot()
            target.boxDay.rec=true
            self:setData(self.curData)
        end

        local function onGet()
            Net.sendActivityRec97Box(self.curType,target.boxDay.day,onGot)
        end

        local function callback(ret)
            local data={}
            if(self.curType==ACT_TYPE_97)then
                data.title=gGetWords("activityNameWords.plist","sign7_box_info97",target.boxDay.day,self.curData.dayneed)
            else
                data.title=gGetWords("activityNameWords.plist","sign7_box_info98",target.boxDay.day,self.curData.dayneed)
            end
            if(target.boxDay.rec==true)then
                data.status=2
            else
                if(self.curReachDay>=target.boxDay.day)then
                    data.status=1
                else
                    data.status=0
                end
            end
            data.callback=onGet
            Panel.popUp(PANEL_BOX_INFO,ret,data)
        end

        Net.sendActivityBoxInfo(target.boxDay.boxid,callback)
    end
end

function ActivitySign7Panel:onSelectBoxid(index)
    self.curSelectBoxid=index
    local boxData=self.curData.boxArr[index]
    self:getNode("box_icon").boxDay=boxData
    self:getNode("box_icon_fla"):playAction(boxIcons[index])

    self:getNode("box_icon"):removeChildByTag(100)
    if(boxData.rec==false and self.curReachDay>=boxData.day)then

        loadFlaXml("ui_kuang_texiao")
        local fla=gCreateFla("ui_kuang_xiaoguo",1);
        fla:setTag(100);
        self:getNode("box_icon"):setVisible(true)
        gAddChildInCenterPos(self:getNode("box_icon"),fla);
    end
end


function ActivitySign7Panel:canGetReward(index)
    local var = Data.signInfo.reward[index];
    if Data.signInfo.count >= var.day and not var.bolGet then
        return true;
    end
    return false;
end



return ActivitySign7Panel