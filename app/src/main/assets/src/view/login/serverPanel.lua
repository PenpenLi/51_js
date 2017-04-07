local ServerPanel=class("ServerPanel",UILayer)

function ServerPanel:ctor()
    self:init("ui/ui_serverlist.map")

    self:addTouchNode(self:getNode("txt_ver"),"txt_ver",nil,nil,0.2)

    self:getNode("scroll").eachLineNum=2
    self:getNode("scroll").offsetY=0
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)



    self:getNode("scroll2").eachLineNum=1
    self:getNode("scroll2").offsetY=0
    self:getNode("scroll2"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)



    self:getNode("scroll_area"):setDir( cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    local servers={}
    local server2={}
    for key, var in pairs(gAccount.serverlist) do
        if(var.pub)then
            table.insert(server2,var)
        else
            table.insert(servers,var)
        end
    end

    local serverCount=table.getn(servers)
    local areaCount=math.ceil( serverCount/20) 
    local offset=1;
    for i=1, areaCount do
        local item=ServerArea.new()
        self:getNode("scroll_area"):addItem(item)
        item.offset=i-1 
        print("offset "..item.offset)
        item.startIdx=offset
        item.startOffset=0
        item.endIdx=offset+19 
        item:setData(false)
        if(item.endIdx>=serverCount)then
            item.endIdx=serverCount
        end 
        offset=offset+20
        item.onSelectCallback=function()
            self:setSelectServerArea( item)
        end
    end
    local preareaCount=areaCount

    local serverPubsCount=table.getn(server2)
    local areaCount=math.ceil( serverPubsCount/20)
    offset=serverCount+1
    for i=1, areaCount do
        local item=ServerArea.new()
        item.offset=i+preareaCount  
        print("offset "..item.offset)

        item.startIdx=offset
        item.endIdx=offset+19
        item.startOffset=serverCount
 
        item:setData(true)
        if(item.endIdx>=serverCount+serverPubsCount)then
            item.endIdx=serverCount+serverPubsCount
        end
        offset=offset+20
        self:getNode("scroll_area"):addItem(item)
        item.onSelectCallback=function()
            self:setSelectServerArea( item)
        end
    end

    function sortFunc(item1,item2)
        return toint(item1.startIdx)>toint(item2.startIdx)
    end
    table.sort(self:getNode("scroll_area").items,sortFunc)

    self:getNode("scroll_area"):layout()

    self:setLabelString("txt_ver",gGetCurVersion())
    if(self:getNode("scroll_area").items[1])then
        self:setSelectServerArea(
            self:getNode("scroll_area").items[1] 
        )
    end
    self:getServerData()
end

function ServerPanel:setSelectServerArea(item) 
    local offset=item.offset
    local startIdx=item.startIdx
    local endIdx=item.endIdx 
    
    self:getNode("scroll"):clear()
    local servers={}
    for i= startIdx, endIdx do
        local var=gAccount.serverlist[i]
        table.insert( servers,var)
    end




    function sortFunc(item1,item2)
        return toint(item1.id)>toint(item2.id)
    end
    table.sort(servers,sortFunc)

    for key, var in pairs(servers) do
        local item=ServerItem.new()
        item.idx=key
        item:setData(var)
        item.onSelectCallback=function()
            gAccount:saveServer( item.curData.id)
            gDispatchEvt(EVENT_ID_CHANGE_SERVER)
            Panel.popBack(self:getTag())
        end
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()


    for key, item in pairs(self:getNode("scroll_area").items) do
        if(item.offset==offset)then
            item:select()
        else
            item:resetSelect()
        end
    end
end
function ServerPanel:getServerData()

    local recentServer={}
    table.insert(recentServer,gAccount:getRandServer())
    for key, var in pairs(recentServer) do
        if(toint(var.status)~=6)then
            local item=ServerItem.new()
            item.idx=key
            item:setData(var)
            item.onSelectCallback=function()
                gAccount:saveServer( item.curData.id)
                gDispatchEvt(EVENT_ID_CHANGE_SERVER)
                Panel.popBack(self:getTag())
            end
            self:getNode("scroll_recent"):addItem(item)
        end
    end

    self:getNode("scroll_recent"):layout()

    function sortFunc(role1,role2)
        return toint(role1.updatetime)>toint(role2.updatetime)
    end
    table.sort(gAccount.rolelist,sortFunc)
    for key, role in pairs(gAccount.rolelist) do
        local item=ServerRole.new()
        item.idx=key
        item:setData(role)
        item.onSelectCallback=function()
            gAccount:saveServer( item.curData.id)
            gAccount:saveRoleid( item.curRoleData.userid)
            gDispatchEvt(EVENT_ID_CHANGE_SERVER)
            Panel.popBack(self:getTag())
        end
        self:getNode("scroll2"):addItem(item)
    end
    self:getNode("scroll2"):layout()

end

function switchServerlist(serverxml)
    local confURL =  Conf:shared():getString("g_serverlist_url")
    if confURL and confURL~="" then
        Conf:shared():setString("g_serverlist_url","")
        Conf:shared():save()
        gConfirm("0")
    else
        Conf:shared():setString("g_serverlist_url",serverxml)
        Conf:shared():save()
        gConfirm("1")
    end
end

local  touchNum = 0
function ServerPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="txt_ver" then
    -- touchNum =  touchNum +1
    -- if touchNum > 10 then
    --     touchNum = 0
    --     local lplatform = gGetCurPlatform()
    --     if lplatform == CHANNEL_IOS_EFUNTW or  lplatform == CHANNEL_ANDROID_EFUNTWGP or lplatform == CHANNEL_ANDROID_EFUNTWGW then
    --         switchServerlist("http://117.29.168.218:8801/master/ldt2_tw/serverlist.xml")
    --     elseif lplatform == CHANNEL_IOS_EFUNHK or  lplatform == CHANNEL_ANDROID_EFUNHK then
    --         switchServerlist("http://117.29.168.218:8801/master/ldt2_hk/serverlist.xml")
    --     end
    -- end
    end
end

return ServerPanel