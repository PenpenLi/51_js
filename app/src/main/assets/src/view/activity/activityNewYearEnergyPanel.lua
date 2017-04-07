local ActivityNewYearEnergyPanel=class("ActivityNewYearEnergyPanel",UILayer)

function ActivityNewYearEnergyPanel:ctor(data)
    self:init("ui/ui_hd_tongyong4.map")
    self.curData=data

    self:setMapVisible(false)

    Net.sendActivity96(self.curData)
end

function ActivityNewYearEnergyPanel:setMapVisible(show)
    for i=1,4 do
        self:getNode("txt_"..i):setVisible(show)
    end
    self:getNode("e_bg"):setVisible(show)
end

function ActivityNewYearEnergyPanel:setData(param)
    self:setMapVisible(true)

	local num = param.num
    local per = param.per
    local eng = param.eng
	self:replaceLabelString("txt_4",num)

    local sTime = gParserMonDay(self.curData.begintime)
    local eTime = gParserMonDay(self.curData.endtime)
    local strTime1 = sTime.."~"..eTime
    self:replaceLabelString("txt_1",strTime1,per)
    self:replaceLabelString("txt_2",strTime1)

    local strTime2 = gParserMonDay(self.curData.endtime+24*60*60)
    self:replaceRtfString("txt_3",strTime2,eng)
end

function ActivityNewYearEnergyPanel:dealEvent(event,param)
    -- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_96 )then
        self:setData(param)
    end
end

return ActivityNewYearEnergyPanel