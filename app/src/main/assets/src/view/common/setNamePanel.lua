local SetNamePanel=class("SetNamePanel",UILayer)

function SetNamePanel:ctor(isFree)
    self:init("ui/ui_set_name.map")
    self:initName()
    self._panelTop=true
    if(isFree == nil)then
        isFree = false;
    end
    self.isFree = isFree;
    if(self.isFree)then
        self:getNode("btn_close"):setVisible(false);
    end
end

function SetNamePanel:initName(rand)
    local name=gUserInfo.name
    self.freeName = name
    if(gUserInfo.name==nil or string.len(gUserInfo.name)==0 or rand)then
        local names1=cc.FileUtils:getInstance():getValueMapFromFile("word/name1.plist")
        local names2=cc.FileUtils:getInstance():getValueMapFromFile("word/name2.plist")
        local names3=cc.FileUtils:getInstance():getValueMapFromFile("word/name3.plist")

        local key1=tostring(getRand(0,table.count(names1)-1))
        local key2=tostring(getRand(0,table.count(names2)-1))
        local key3=tostring(getRand(0,table.count(names3)-1))

        local name1=""
        if(names1[key1]~=nil)then
            name1=names1[key1]
        end
        local name2=""
        if(names2[key2]~=nil)then
            name2=names2[key2]
        end

        local name3=""
        if(names3[key3]~=nil)then
            name3=names3[key3]
        end

        name=name1..name2..name3
    end

    self:setLabelString("input_name",name)

    if(gUserInfo.name==nil or string.len(gUserInfo.name)==0)then
        self:getNode("btn_close"):setVisible(false)
    end
end

function  SetNamePanel:events()
    return {EVENT_ID_SET_NAME}
end


function SetNamePanel:dealEvent(event,param)
    if(event==EVENT_ID_SET_NAME)then
        if(self.closeCallback)then
            self.closeCallback()
        end
        Panel.popBack(self:getTag())
        gUserInfo.needChangeName = false;
        if(self.freeName==nil or string.len(self.freeName)==0)then
            self.freeName =  gUserInfo.name
            gAccount:createRoleExtenInter()
        end
    end
end
function SetNamePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        if(self.closeCallback)then
            self.closeCallback()
        else
            Panel.popBack(self:getTag())
        end
    elseif  target.touchName=="btn_random"then
        self:initName(1)

    elseif  target.touchName=="btn_set"then
        local function sendChangeName()
            Net.sendChangeName(string.filter(self:getNode("input_name"):getText()))
        end

        if(self.isFree)then
            sendChangeName();
        elseif(gUserInfo.name~="" and self.isFree==false)then
            gConfirmCancel(gGetWords("noticeWords.plist","rename_notice",DB.getRenameDia()),sendChangeName)
        else
            Net.sendSetName(string.filter(self:getNode("input_name"):getText()))
        end
    end

end

return SetNamePanel