local MailPanel=class("MailPanel",UILayer)

function MailPanel:ctor()
    self:init("ui/ui_mail.map")

    self.scroll_mail = self:getNode("scroll1")
    self.scroll_friend_mail = self:getNode("scroll2")

    self.scroll_content1 = self:getNode("scroll_content1")
    self.scroll_content2 = self:getNode("scroll_content2")
    self.scroll_content1:setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.scroll_content2:setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.scroll_content1_y = self.scroll_content1:getPositionY()
    self.layer_content1 = self:getNode("layer_content1")
    self.layer_content2 = self:getNode("layer_content2")

    self.curData = nil
    self.index = 0

    self.mailType = 0
    if(table.getn(Data.mail.list) > 0 or (not Unlock.system.friend.isUnlock())) then
        self:setMailType(1)
    else
        self:setMailType(2)
    end

    if(not Unlock.system.friend.isUnlock()) then
        local btn = self:getNode("btn2")
        DisplayUtil.setGray(btn);
        local lock = cc.Sprite:create("images/ui_atlas/ui/lock.png");
        lock:setScale(0.6);
        gRefreshNode(btn,lock,cc.p(0.2,0.5),cc.p(0,0),100);
    end

    if(not Unlock.system.family.isUnlock()) then
        local btn = self:getNode("btn3")
        DisplayUtil.setGray(btn);
        local lock = cc.Sprite:create("images/ui_atlas/ui/lock.png");
        lock:setScale(0.6);
        gRefreshNode(btn,lock,cc.p(0.2,0.5),cc.p(0,0),100);
    end

   gCreateBtnBack(self);

end


function MailPanel:onPopup()
end

function MailPanel:events()
    return {
      EVENT_ID_MAIL_LIST,
      EVENT_ID_MAIL_GET,
      EVENT_ID_MAIL_DEL,
      EVENT_ID_MAIL_READ,
      EVENT_ID_FRIEND_MAIL_LIST,
      EVENT_ID_FRIEND_MAIL_READ,
      EVENT_ID_FRIEND_MAIL_DEL,
      EVENT_ID_FRIEND_MAIL_SEND,
      EVENT_ID_FAMILY_MAIL_LIST,
      EVENT_ID_FAMILY_MAIL_READ,
      EVENT_ID_FAMILY_MAIL_DEL
    }
end


function MailPanel:dealEvent(event,param)
    if(event == EVENT_ID_MAIL_LIST)then
        self:createMailList(1)
    elseif(event == EVENT_ID_MAIL_GET)then
        if(table.getn(Data.mail.list) > 0) then
            self:showMail(self.index)
        else
            self:createMailList(1)
        end
    elseif(event == EVENT_ID_MAIL_DEL)then
        self.scroll_mail:removeItemByIndex(self.index-1)
        local items = self.scroll_mail:getAllItem()
        for key,var in pairs(items) do
            var:setIndex(toint(key))
        end
        if(table.getn(Data.mail.list) > 0) then
            self:showMail(self.index)
        else
            self:createMailList(1)
        end
    elseif(event == EVENT_ID_MAIL_READ)then
    elseif(event == EVENT_ID_FRIEND_MAIL_LIST)then
        self:enterFriendMailList()
        -- self:createFriendMailList(1)
    elseif(event == EVENT_ID_FRIEND_MAIL_READ)then
    elseif(event == EVENT_ID_FRIEND_MAIL_DEL)then
        self.scroll_friend_mail:removeItemByIndex(self.index-1)
        local items = self.scroll_friend_mail:getAllItem()
        for key,var in pairs(items) do
            var:setIndex(toint(key))
        end
        if(table.getn(Data.friend.maillist) > 0) then
            self:showFriendMail(self.index)
        else
            self:createFriendMailList(1)
        end
    elseif(event == EVENT_ID_FRIEND_MAIL_SEND)then
    elseif(event == EVENT_ID_FAMILY_MAIL_LIST)then
        self:enterFamilyMailList();    
    elseif(event == EVENT_ID_FAMILY_MAIL_READ)then
    elseif(event == EVENT_ID_FAMILY_MAIL_DEL)then
        self:getNode("family_mail_scroll"):removeItemByIndex(self.index-1)
        local items = self:getNode("family_mail_scroll"):getAllItem()
        for key,var in pairs(items) do
            var:setIndex(toint(key))
        end
        if(table.getn(Data.mail.familymaillist) > 0) then
            self:showFamilyMail(self.index)
        else
            self:createFamilyMailList(1)
        end        
    end
end

function MailPanel:resetBtnTexture()
    local btns={
        "btn1",
        "btn2",
        "btn3",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function MailPanel:selectBtn(name)
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
end

function MailPanel:createMailList(openIndex)
    self.scroll_mail:clear()
    for key,var in pairs(Data.mail.list) do
        local item=MailItem.new()
        item:setData(var,toint(key),1)
        self.scroll_mail:addItem(item)
        item.selectItemCallback = function (data,index)
          self:showMail(index)
        end
    end
    self.scroll_mail:layout()

    local listLen = table.getn(Data.mail.list)
    if(listLen > 0) then
        self:showMail(openIndex)
    else
        self.layer_content1:setVisible(false)
    end
    self:getNode("layer_mail"):setVisible(listLen > 0)
    self:getNode("layer_null"):setVisible(listLen == 0)
    self:getNode("layer_null2"):setVisible(false)
end

function MailPanel:createFriendMailList(openIndex)
    self.scroll_friend_mail:clear()
    for key,var in pairs(Data.friend.maillist) do
        local item=MailItem.new()
        item:setData(var,toint(key),2)
        self.scroll_friend_mail:addItem(item)
        item.selectItemCallback=function (data,index)
          self:showFriendMail(index)
        end
    end
    self.scroll_friend_mail:layout()

    local listLen = table.getn(Data.friend.maillist)
    if(listLen > 0) then
        self:showFriendMail(openIndex)
    else
        self.layer_content2:setVisible(false)
    end

    self:getNode("layer_friend_mail"):setVisible(listLen > 0)
    self:getNode("layer_null"):setVisible(listLen == 0)
    self:getNode("layer_null2"):setVisible(listLen == 0)
end

function MailPanel:createFamilyMailList(openIndex)
    -- print("createFamilyMailList");
    self:getNode("family_mail_scroll"):clear()
    for key,var in pairs(Data.mail.familymaillist) do
        local item=MailItem.new()
        item:setData(var,toint(key),3)
        self:getNode("family_mail_scroll"):addItem(item)
        item.selectItemCallback=function (data,index)
          self:showFamilyMail(index)
        end
    end
    self:getNode("family_mail_scroll"):layout()

    local listLen = table.getn(Data.mail.familymaillist)
    if(listLen > 0) then
        self:showFamilyMail(openIndex)
    end

    self:getNode("layer_family"):setVisible(listLen > 0)
    self:getNode("layer_null"):setVisible(listLen == 0)
    -- self:getNode("layer_null2"):setVisible(listLen == 0)    
end

function MailPanel:unselectAllItem()
    local items1 = self.scroll_mail:getAllItem();
    for key,var in pairs(items1) do
        var:unselectItem()
    end    

    local items2 = self.scroll_friend_mail:getAllItem();
    for key,var in pairs(items2) do
        var:unselectItem()
    end

    local items3 = self:getNode("family_mail_scroll"):getAllItem();
    for key,var in pairs(items3) do
        var:unselectItem();
    end
end

function MailPanel:setMailType(type)
  if(self.mailType == type) then
    return;
  end

  if type == 1 then
      self.mailType = type;
      self.layer_content1:setVisible(false)
      self.layer_content2:setVisible(false)
      self:getNode("layer_friend_mail"):setVisible(false)
      self:getNode("layer_family"):setVisible(false)
      self:selectBtn("btn1");    
      self:createMailList(1);
  elseif type == 2 then
      self.layer_content1:setVisible(false)
      self.layer_content2:setVisible(false)
      self:getNode("layer_mail"):setVisible(false)
      self:getNode("layer_friend_mail"):setVisible(false)
      self:getNode("layer_family"):setVisible(false)
      self:selectBtn("btn2");

      Net.sendBuddyMailList(Data.friend.gettime)
  elseif type == 3 then

      self.layer_content1:setVisible(false)
      self.layer_content2:setVisible(false)
      self:getNode("layer_mail"):setVisible(false)
      self:getNode("layer_friend_mail"):setVisible(false)
      self:getNode("layer_null2"):setVisible(false)
        self:selectBtn("btn3");
        Net.sendGetFamilyMailList();   
  end
end

function MailPanel:enterFriendMailList()
    self.mailType = 2;
    self.layer_content1:setVisible(false)
    self.layer_content2:setVisible(false)
    self:getNode("layer_mail"):setVisible(false)
    self:selectBtn("btn2");
    self:createFriendMailList(1); 
end

function MailPanel:enterFamilyMailList()
    self.mailType = 3;
    self:getNode("layer_family"):setVisible(true)
    self:selectBtn("btn3");
    self:createFamilyMailList(1);
end

function MailPanel:setDel(isDel)
    gSysDeleteMail = isDel
    if(gSysDeleteMail)then
        self:changeTexture("btn_choose","images/ui_public1/gou_1.png")
    else
        self:changeTexture("btn_choose","images/ui_public1/gou_2.png")
    end
end

function MailPanel:showMail(index)
    local listLen = table.getn(Data.mail.list)
    if(listLen > 0)then
        while(index > listLen)do
            index = index - 1
        end
    end
    self.layer_content1:setVisible(true)

    self.curData = Data.mail.list[index]
    self.index = index
    self:unselectAllItem()
    local mailItem = self.scroll_mail:getItem(index - 1)
    mailItem:selectItem()
    if(self.curData.bolRead) then
        mailItem:setRead()
    else
        if(table.getn(self.curData.items) == 0)then
            Net.sendMailRead(self.curData.eId)
            mailItem:setRead()
        end
    end

    self:setLabelString("lab_title1",self.curData.title,nil,true)
    self:setLabelString("lab_time1",gParserDay(self.curData.time))

    self.scroll_content1:clear()
    local viewSize1=self.scroll_content1.viewSize
    local viewSize2=self.scroll_content2.viewSize
    if(table.getn(self.curData.items) > 0) then
        viewSize1.height=viewSize2.height-80
        self.scroll_content1:resize(viewSize1)
        self.scroll_content1:setPositionY(self.scroll_content1_y)
    else
        viewSize1.height=viewSize2.height
        self.scroll_content1:resize(viewSize1) 
        self.scroll_content1:setPositionY(self.scroll_content1_y-40)
    end
    if(table.getn(self.curData.items) > 0 and self.curData.bolRead == false) then
        self:getNode("layer_choose"):setVisible(true)
        self:setDel(gSysDeleteMail)
        local strGet = gGetWords("btnWords.plist", "btn_get_reward")
        self:setLabelString("lab_get",strGet)
        self:changeTexture("btn_get","images/ui_public1/button_blue_1.png");
    else
        self:getNode("layer_choose"):setVisible(false)
        local strDel = gGetWords("mailWords.plist", "delete")
        self:setLabelString("lab_get",strDel)
        self:changeTexture("btn_get","images/ui_public1/button_red_1.png");
    end
    -- local lab_content = gCreateWordLabelTTF(self.curData.content,gFont,20,cc.c3b(225,220,113),cc.size(viewSize1.width,0),cc.TEXT_ALIGNMENT_LEFT)
    -- lab_content:setAnchorPoint(cc.p(0,1));
    -- self.scroll_content1:addItem(lab_content)
    local rtf = RTFLayer.new(viewSize1.width);
    local content = "\\w{c=e1dc71}"..self.curData.content;
    rtf:setDefaultConfig(gFont,20,cc.c3b(225,220,113));
    rtf:setString(content)
    rtf:setAnchorPoint(cc.p(0,1))
    rtf:layout()
    self.scroll_content1:addItem(rtf)
    self.scroll_content1:layout()

    local count = 0
    for key, var in pairs(self.curData.items) do
        local iconBg = self:getNode("icon"..(key))
        Icon.setIcon(var.itemid,iconBg, DB.getItemQuality(var.itemid))
        Icon.setGetFlag(iconBg,self.curData.bolRead);
        iconBg:setVisible(true)
        self:getNode("num"..key):setVisible(true);
        self:setLabelString("num"..(key),var.num);

        -- local iconNum = tolua.cast(self:getNode("num"..(key)),"cc.Label")
        -- iconNum:setString(""..var.num)
        -- iconNum:setVisible(true)
        count = count + 1;
    end

    for i = count + 1,4 do
        local iconBg = self:getNode("icon"..(i))
        iconBg:setVisible(false)
        self:getNode("num"..(i)):setVisible(false)
    end
end

function MailPanel:showFriendMail(index)
    self.layer_content2:setVisible(true)

    local listLen = table.getn(Data.friend.maillist)
    if(listLen > 0)then
        while(index > listLen)do
            index = index - 1
        end
    end

    self.curData = Data.friend.maillist[index]
    self.index = index
    self:unselectAllItem()
    local mailItem = self.scroll_friend_mail:getItem(index - 1)
    mailItem:selectItem()
    mailItem:setRead()
    if(not self.curData.bolRead) then
        Net.sendBuddyReadMail(self.curData.eId)
    end

    self:setLabelString("lab_title2",self.curData.title)
    self:setLabelString("lab_time2",gParserDay(self.curData.time))

    self.scroll_content2:clear()
    local viewSize2=self.scroll_content2.viewSize
    local lab_content = gCreateWordLabelTTF(self.curData.content,gFont,20,cc.c3b(225,220,113),cc.size(viewSize2.width,0),cc.TEXT_ALIGNMENT_LEFT)
    lab_content:setAnchorPoint(cc.p(0,1));
    self.scroll_content2:addItem(lab_content)
    self.scroll_content2:layout()
end

function MailPanel:showFamilyMail(index)
    -- print("MailPanel:showFamilyMail(index) = "..index);
    self:getNode("family_scroll_content"):setVisible(true)

    local listLen = table.getn(Data.mail.familymaillist)
    if(listLen > 0)then
        while(index > listLen)do
            index = index - 1
        end
    end

    self.curData = Data.mail.familymaillist[index]
    self.index = index
    self:unselectAllItem()
    local mailItem = self:getNode("family_mail_scroll"):getItem(index - 1)
    mailItem:selectItem()
    mailItem:setRead()
    if(not self.curData.bolRead) then
        Net.sendFamilyMailRead(self.curData.eId)
    end

    self:setLabelString("family_title",self.curData.title)
    self:setLabelString("family_time",gParserDay(self.curData.time))
    self:setLabelString("family_content",self.curData.content)
    self:getNode("family_scroll_content"):layout();
end

function MailPanel:onTouchBegan(target,touch)
    if target.touchName == "icon1" or target.touchName == "icon2" or target.touchName == "icon3"  or target.touchName == "icon4"  then
        local itemid = 0
        if target.touchName == "icon1" then
            itemid = self.curData.items[1].itemid
        elseif target.touchName == "icon2" then
            itemid = self.curData.items[2].itemid
        elseif target.touchName == "icon3" then
            itemid = self.curData.items[3].itemid
        elseif target.touchName == "icon4" then
            itemid = self.curData.items[4].itemid
        end
        local tip= Panel.popTouchTip(self:getNode(target.touchName),TIP_TOUCH_EQUIP_ITEM,itemid)
        -- tip:setPositionY(tip:getPositionY()+tip:getContentSize().height)  
    end 
end

function MailPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn1" then
        self:setMailType(1);
    elseif target.touchName == "btn2" then
        if Unlock.isUnlock(SYS_FRIEND) then
            self:setMailType(2);
        end
    elseif target.touchName == "btn3" then
        if Unlock.isUnlock(SYS_FAMILY) then
            self:setMailType(3);   
        end
    elseif target.touchName == "btn_write1" or target.touchName == "btn_write2" then
        Panel.popUp(PANEL_MAIL_WRITE)
    elseif target.touchName == "btn_rec" then
        FriendListPanel.data.friend.uid = self.curData.userId;
        FriendListPanel.data.friend.name = self.curData.name;
        Panel.popUp(PANEL_MAIL_WRITE)
    elseif target.touchName == "btn_del" then
        Net.sendBuddyDelMsg(self.curData.eId)
    elseif target.touchName == "btn_choose" then
        self:setDel(not gSysDeleteMail)
        Data.saveDeleteMail(gSysDeleteMail)
    elseif target.touchName == "btn_get" then
      if(table.getn(self.curData.items) > 0 and self.curData.bolRead == false) then
          Net.sendMailGet(self.curData.eId,gSysDeleteMail)
      else
          Net.sendMailDel(self.curData.eId)
      end
    elseif target.touchName == "family_btn_del" then
        Net.sendFamilyMailDel(self.curData.eId)
    end
    Panel.clearTouchTip();
end

return MailPanel