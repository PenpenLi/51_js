local MailItem=class("MailItem",UILayer)

function MailItem:ctor()
    self:init("ui/ui_mail_item.map")
end

function MailItem:onTouchEnded(target)
    if(self.selectItemCallback)then
        self.selectItemCallback(self.curData,self.index)
    end

    -- if(not self.curData.bolRead)then
    -- 	if(self.type == 1 and table.getn(self.curData.items) == 0)then
    -- 		Net.sendMailRead(self.curData.eId)
    --      self:setRead()
    -- 	elseif(self.type == 2)then
    -- 		Net.sendBuddyReadMail(self.curData.eId)
    --      self:setRead()
    -- 	end
    -- end
end

function MailItem:setData(data,index,type)
    self.curData = data
    self.index = index
    self.type = type--type=1 系统邮件  type=2 好友邮件 type=3 军团邮件

    self:setLabelString("lab_title",data.title,nil,true)
    -- data.content = "亲爱的玩家，欢迎来到《乱斗堂2》！独乱斗，不如众乱斗！加入以下互动渠道，与众基友一同探讨游戏、扯淡嗨皮，更有以下互动好礼哦：\\n{}\\《乱斗堂2》官方QQ群: \\w{c=FF0000;s=18}123\\ (小窗联系GM领取加群礼包)\\n{}\\《乱斗堂2》微信公众号: \\w{c=FF0000;s=18}luandoutang2\\(丰富的微信活动福利)\\n{}\\《乱斗堂2》贴吧: 百";
    local content = gRemoveRtf(data.content);
    local str = gGetWordWithWidth(string.utf8sub(content,1,100),gFont,20,140)
    if(str ~= data.content)then
        str = str.."..."
    end
    self:setLabelString("lab_content",str)
    self:setLabelString("lab_time",gParserDay(data.time))

    if(self.type == 1 and table.getn(self.curData.items) > 0) then
        self:getNode("icon_attachment"):setVisible(true)
    else
        self:getNode("icon_attachment"):setVisible(false)
    end

    if(self.curData.bolRead)then
    	self:setRead()
    end
end

function MailItem:setIndex(index)
    self.index = index
end

function MailItem:selectItem()
	self:getNode("layer_sel"):setVisible(true)
end

function MailItem:unselectItem()
	self:getNode("layer_sel"):setVisible(false)
end

function MailItem:setRead()
    self:changeTexture("icon_read","images/ui_pic1/mail_box2.png")
end

return MailItem