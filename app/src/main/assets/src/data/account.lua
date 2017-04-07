local Account=class("Account")



function Account:ctor()
    self.serverlist={
        --["def"]   "0"
        --["id"]  "77001"
        --["ip"]  "103.244.235.145"
        --["name"]    "1-良辰美景"
        --["port"]    "23100"
        --["status"]  "0"
        --["zone"]    "dgr_77001"

        }

    self.rolelist=nil

    --[{\"serverid\":\"577001\",\"userid\":\"577001000373\",\"rolename\":\"\",\"level\":\"1\"}]


    self.accountid=0
    self.phone=0
    self.account=0
    self.psw=0
    self.session=0
    self.accountName=""
    self.motuAccount = true
    self.isMinor = false --是否为未成年
    self.channeluserid = ""
    self.loginParams = nil;
    self.isChangeAccout = false;
    if ChannelPro~=nil and not ChannelPro:sharedChannelPro():isMotuAccout() then
        self.motuAccount = false
    end

end
function Account:lastRoleid()
    return  cc.UserDefault:getInstance():getStringForKey("roleid",0)
end

function Account:lastServer()
    return  cc.UserDefault:getInstance():getIntegerForKey("server",0)
end
function Account:getServerById(id)
    for key, server in pairs(self.serverlist) do
        if(server.id==id)then
            return server
        end
    end
    return nil
end

function Account:getRandServer()
    local defaultServers={}
    for key, server in pairs(self.serverlist) do
        if(toint(server.def)==1)then
            table.insert( defaultServers,server)
        end
    end
    local count=table.getn(defaultServers)
    if(count>0)then
        local time=toint(socket.gettime())
        local idx= time% count +1

        if(defaultServers[idx])then
            return defaultServers[idx]
        end
    end
    return nil
end
function Account:getCurServer()
    local serverId= self:lastServer()
    
    
    if(serverId==0)then 
        if(gAccount.rolelist and table.count(self.rolelist)~=0)then
            function sortFunc(role1,role2)
                return toint(role1.updatetime)>toint(role2.updatetime)
            end
            table.sort(self.rolelist,sortFunc)
            serverId=toint(self.rolelist[1].serverid)
        end
    end


    if(serverId==0)then 


        local randServer=self:getRandServer()
        if(randServer)then
            return randServer
        end
    end

    for key, server in pairs(self.serverlist) do
        if(toint(server.id)== toint(serverId))then
            return server
        end
    end
    return self.serverlist[1];

end

--分渠道
function Account:doLogOut()
    if gAccount.motuAccount == false then
        gAccount:logOut()
        return
    end

    local function callback()
        gAccount:delAccount()
        Scene.reEnter()
    end
    Net.disConnect(callback)

    youmeLeaveChatRoom(DataEDCode:encode(gAccount:getCurServer().name));
    if (gFamilyInfo ~= nil and gFamilyInfo.familyId ~= nil and gFamilyInfo.familyId ~= 0) then
        youmeLeaveChatRoom(tostring(gFamilyInfo.familyId));
    end
    youmeLogout()
end


function Account:logOut()
    ChannelPro:sharedChannelPro():logout()
end

function Account:lastAccount()
    return  cc.UserDefault:getInstance():getStringForKey("account", "")
end

function Account:lastPassword()
    return  cc.UserDefault:getInstance():getStringForKey("psw", "")
end

function Account:isLogin()
    return  cc.UserDefault:getInstance():getBoolForKey("isLogin", false)
end

function Account:saveServer(server)
    cc.UserDefault:getInstance():setIntegerForKey("server",toint(server))
    cc.UserDefault:getInstance():flush()

end


function Account:saveRoleid(roleid)
    cc.UserDefault:getInstance():setStringForKey("roleid", (roleid))
    cc.UserDefault:getInstance():flush() 
end


function Account:isGm()
    if( gAccount:getCurRole() and
        gAccount:getCurRole().sp and
        toint(gAccount:getCurRole().sp)==1) then
        return true
    end
    return false
end


function Account:roleLogin()
    local data={}
    data.serveridName= gAccount:getCurServer().name
    data.arenaRank = Data.getCurArenaRank()
    data.vip = Data.getCurVip()
    data.account = self.accountid
    data.diamond = Data.getCurDia()
    data.udid = gAccount.accountid
    data.roleId = Data.getCurUserId()
    data.serverId = gAccount:getCurRole().serverid
    data.roleLevel = Data.getCurLevel()
    data.roleName = Data.getCurName()
    local extra=gAccount:tableToString(data)
    if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
        ChannelPro:sharedChannelPro():extenInter("roleLogin",extra)
    end
end

function Account:roleUpdate()
    local data={}
    data.serveridName= gAccount:getCurServer().name
    data.arenaRank = Data.getCurArenaRank()
    data.vip = Data.getCurVip()
    data.account = self.accountid
    data.diamond = Data.getCurDia()
    data.udid = gAccount.accountid
    data.roleId = Data.getCurUserId()
    data.serverId = gAccount:getCurRole().serverid
    data.roleLevel = Data.getCurLevel()
    data.roleName = Data.getCurName()
    local extra=gAccount:tableToString(data)
    if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
        ChannelPro:sharedChannelPro():extenInter("roleUpdate",extra)
    end
end


function Account:createRoleExtenInter()
    local data={}
    data.serveridName= gAccount:getCurServer().name
    data.arenaRank = Data.getCurArenaRank()
    data.vip = Data.getCurVip()
    data.account = self.accountid
    data.diamond = Data.getCurDia()
    data.udid = gAccount.accountid
    data.roleId = Data.getCurUserId()
    data.serverId = gAccount:getCurRole().serverid
    data.roleLevel = Data.getCurLevel()
    data.roleName = Data.getCurName()
    local extra=gAccount:tableToString(data)
    if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
        ChannelPro:sharedChannelPro():extenInter("createRole",extra)
    end
end


function Account:roleInitFinish()

    local data={}
    data.serveridName= gAccount:getCurServer().name
    data.arenaRank = Data.getCurArenaRank()
    data.vip = Data.getCurVip()
    data.account = self.accountid
    data.diamond = Data.getCurDia()
    data.udid = gAccount.accountid
    local extra=gAccount:tableToString(data)
    local roleId = Data.getCurUserId()
    local serverId = gAccount:getCurRole().serverid
    local roleLevel = Data.getCurLevel()
    local roleName = Data.getCurName()
    if ChannelPro and ChannelPro:sharedChannelPro().roleInitFinish then
        ChannelPro:sharedChannelPro():roleInitFinish(roleId,serverId,roleLevel,roleName,extra)
    end

end

function Account:enterGame()
    local data={}
    data.serveridName= gAccount:getCurServer().name
    data.arenaRank = Data.getCurArenaRank()
    data.vip = Data.getCurVip()
    data.account = self.accountid
    data.diamond = Data.getCurDia()
    data.udid = gAccount.accountid
    local extra=gAccount:tableToString(data)
    local roleId = Data.getCurUserId()
    local serverId = gAccount:getCurRole().serverid
    local roleLevel = Data.getCurLevel()
    local roleName = Data.getCurName()
    if ChannelPro and ChannelPro:sharedChannelPro().enterGame then
        ChannelPro:sharedChannelPro():enterGame(roleId,serverId,roleLevel,roleName,"",extra)
    end
end

function Account:finishNewGuid()
    local data={}
    data.serveridName= gAccount:getCurServer().name
    data.arenaRank = Data.getCurArenaRank()
    data.vip = Data.getCurVip()
    data.account = self.accountid
    data.diamond = Data.getCurDia()
    data.udid = gAccount.accountid
    data.roleId = Data.getCurUserId()
    data.serverId = gAccount:getCurRole().serverid
    data.roleLevel = Data.getCurLevel()
    data.roleName = Data.getCurName()
    local extra=gAccount:tableToString(data)
    if ChannelPro and ChannelPro:sharedChannelPro().finishNewGuid then
        ChannelPro:sharedChannelPro():finishNewGuid(extra)
    end
end


function Account:getAccountName()
    local  accountName = cc.UserDefault:getInstance():getStringForKey("accountName", "")
    if accountName == "" then
        accountName = self.accountName
        if accountName == "" then
            accountName = self:lastAccount()
        end
    end
    return accountName
end

function Account:saveAppstoreAccount(account,psw)
    cc.UserDefault:getInstance():setStringForKey("appAccount",account)
    cc.UserDefault:getInstance():setStringForKey("appPsw",psw)
end

function Account:getAppstoreAccount()
    local appAccount = cc.UserDefault:getInstance():getStringForKey("appAccount","")
    local appPsw = cc.UserDefault:getInstance():getStringForKey("appPsw","")
    return appAccount,appPsw
end

function Account:saveAccount(account,psw)
    if gAccount.motuAccount == false then
        accountName =  ChannelPro:sharedChannelPro():getName()

        cc.UserDefault:getInstance():setStringForKey("accountName",accountName)
    end
    cc.UserDefault:getInstance():setStringForKey("account",account)
    cc.UserDefault:getInstance():setStringForKey("psw",psw)
    cc.UserDefault:getInstance():setBoolForKey("isLogin",true)
    cc.UserDefault:getInstance():flush()

end

function Account:delAccount()
    cc.UserDefault:getInstance():setStringForKey("accountName","")
    cc.UserDefault:getInstance():setStringForKey("account","")
    cc.UserDefault:getInstance():setStringForKey("psw","")
    cc.UserDefault:getInstance():setBoolForKey("isLogin",false)
    cc.UserDefault:getInstance():flush()
end

function Account:resetIsLogin()
    cc.UserDefault:getInstance():setBoolForKey("isLogin",false)
    cc.UserDefault:getInstance():flush()
end 

function Account:loginEnter(callback)
    if(self:getCurRole()==nil)then
        self:createRole(callback)
        return
    end

    if(self:getCurRole().rolename==nil or
        string.len(self:getCurRole().rolename)==0)then
        gIsFirstEnter=true
    else
        gIsFirstEnter=false
    end
    callback()
end

function Account:loginLastAccount(callback)
    print ("loginLastAccount------")
    --[[if(self.curServerVer and self.curServerVer>2)then
    gConfirm("安装包已过期，请联发商")
    else
    self:loginAccount(self:lastAccount(),self:lastPassword(),callback)
    end]]

    --TDGAAccount:setAccountType(kAccountRegistered)

    self:loginAccount(self:lastAccount(),self:lastPassword(),callback)
end


function Account:registerAccount(account,psw,repsw,callback)
    if(string.len(string.trim(account))==0)then
        gShowNotice( gGetHttpCode("http_get_err",101))
        return
    end

    if(string.len(string.trim(psw))==0)then
        gShowNotice( gGetHttpCode("http_get_err",102))
        return
    end
    if(psw ~= repsw)then
        gShowNotice( gGetHttpCode("http_get_err",103))
        return
    end
    local function registerRespone(data)
        if(data.ret==0) then
            Account:saveAccount(account,psw)
            self.accountid = data.accountid
            self.account=data.account
            self.session=data.session
            self.psw=data.psw
            self.rolelist= self:parseRoleList(data)
            gDispatchEvt(EVENT_ID_CHANGE_SERVER)
            if(callback)then
                callback()
            end
        else
            gShowNotice( gGetHttpCode("http_get_err",data.ret))
            Scene.hideWaiting()
        end
    end
    Scene.showWaiting()
    gAccount:register(account,psw,registerRespone)
end


function Account:getHttp(url,method,data,callback)
    if(url==nil) then
        return
    end
    local xhr = cc.XMLHttpRequest:new()-- 新建一个XMLHttpRequest对象
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --返回数据为字节流
    -- 状态改变时调用
    local function onReadyStateChange()
        callback(xhr.responseText)
    end
    -- 注册脚本方法回调
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:open(method, url) -- 打开Socket
    print(url)

    if(data~=nil) then
        xhr:send(data)-- 发送
    else
        xhr:send()-- 发送
    end
end

function Account:getServerList(url,callback)
    local serverListPath=getWritePath().."/serverlist.xml"
    local function serverListCallBack(responseText)
        local content= removeBom(responseText)
        if( content==nil or string.len(content)==0 ) then
            serContent = io.readfile(serverListPath)
            content= removeBom(serContent)
            if( content==nil or string.len(content)==0 ) then
                callback(false) --获取服务器列表失败
                return
            end
        end
        io.writefile(serverListPath,content)
        local data = xml.load(serverListPath)
        local codeVersion = 1
        local serverVersion = 100000
        local serverlist = nil
        local test_serverlist = nil
        local test_getaccount = nil
        local masterserver = nil
        local test_masterserver = nil
        local getaccountUrl = nil;
        local installUrl = nil;
        local iaporderUrl = nil;
        for key, var in pairs(data) do
            if type(var)=="table" and table.getn(var)~=0 then
                if(var[0]=="serverlist") then
                    serverlist = var
                elseif(var[0]=="test_serverlist") then
                    test_serverlist = var
                elseif(var[0]=="test_getaccount") then
                    test_getaccount = var[1].url
                elseif (var[0]=="test_masterserver") then
                    test_masterserver = var[1].url
                elseif (var[0]=="masterserver") then
                    masterserver = var[1].url
                elseif (var[0]=="getaccount") then
                    getaccountUrl = var[1].url;
                elseif (var[0]=="installserver") then
                    installUrl = var[1].url;
                elseif (var[0]=="iaporderserver") then
                    iaporderUrl = var[1].url;
                end
            else
                if (var[0]=="version") then
                    self.curServerVer =toint(var.ver)
                elseif (var[0]=="serverlist_version") then
                    serverVersion=toint(var.ver)
                end
            end
        end
        if AssetsUpdate and  AssetsUpdate:sharedAssetsUpdate().getCodeVersion then
            codeVersion = AssetsUpdate:sharedAssetsUpdate():getCodeVersion()
        end
        if codeVersion>serverVersion then
            if test_serverlist ~=nil then
                serverlist = test_serverlist
            end
            if test_getaccount ~=nil then
                getaccountUrl = test_getaccount
            end
            if test_masterserver ~=nil then
                masterserver = test_masterserver
            end
        end
        self:setServerList(serverlist)
        self.masterserver=masterserver
        self.installUrl=installUrl
        self.iaporderUrl = iaporderUrl;
        self.getaccountUrl = getaccountUrl;
        print("self.masterserver = "..self.masterserver);
        callback(true) --获取服务器列表成功
    end

    self:getHttp(url,"GET",nil,serverListCallBack)
end


function  Account:setServerList(data)
    self.serverlist={}
    for i=1, table.getn(data) do
        table.insert(self.serverlist,data[i])
    end

end

function Account:getPackageName()
   local packageName=""
    if(PlatformFunc:sharedPlatformFunc().getPackageName)then
        packageName= PlatformFunc:sharedPlatformFunc():getPackageName()
    end
    return packageName
end

function Account:getPlatformId() 
    if ChannelPro == nil then
        return 1
    else
        return ChannelPro:sharedChannelPro():getPlatformId()
    end
end

function Account:getAdId()
    local adid="0"
    if ChannelPro  and ChannelPro:sharedChannelPro().getAdId then
        adid = ChannelPro:sharedChannelPro():getAdId()
    end
    return toint(adid)
end

function Account:tableToString(table)
    local ret="{"
    for key,value in pairs(table) do
        ret=ret.." \""..key.."\":\""..value.."\","
    end
    ret=ret.." \"t\":1}"
    return ret
end

function Account:register(account ,psw,callback)
    local pswDecode=   DataEDCode:encode(psw)
    local data={}
    data.type=HttpCmd_Register
    data.platform=self:getPlatformId()
    data.account=account
    data.pwd=pswDecode
    data.accountid=0

    local function registerRespone(responseText)
        local ret= cjson.decode(responseText)
        print("registerRespone"..responseText )
        if callback~=nil then
            callback(ret)
        end
    end

    local str=self:tableToString(data)
    self:getHttp(self.masterserver ,"POST",str,registerRespone)
end



function Account:getCurRole()
    if(self.rolelist==nil)then
        return nil
    end
    
    local rolelist={}
    for key, var in pairs(self.rolelist) do
        if(toint(var.serverid)==toint(self:getCurServer().id))then
            table.insert(rolelist,var)
        end
    end

    local newKey=1
    local lastRole=self:lastRoleid()
    for key, var in pairs(rolelist) do
    	if( var.userid ==lastRole)then
    	   newKey=key
    	end
    end
    return rolelist[newKey]
end




function Account:getDeviceOs()
    local deviceOs = ""
    if PlatformFunc  and PlatformFunc:sharedPlatformFunc().getDeviceOSVer then
        deviceOs = PlatformFunc:sharedPlatformFunc():getDeviceOSVer()
    end
    return deviceOs    
end
function Account:getMacAddress()
    local macAdress = ""
    if PlatformFunc  and PlatformFunc:sharedPlatformFunc().getMacAddress then
        macAdress = PlatformFunc:sharedPlatformFunc():getMacAddress()
    end
    return macAdress
end

function Account:getDeviceId()
    local deviceId = ""
    if PlatformFunc and PlatformFunc:sharedPlatformFunc().getDeviceId then
        deviceId = PlatformFunc:sharedPlatformFunc():getDeviceId()
    end
    return deviceId
end
function Account:getSession(callback)
    local pswDecode=   DataEDCode:encode(self.psw)
    if gAccount.motuAccount == false then
        pswDecode = self.psw
    end
    local data={}
    data.type=HttpCmd_GetAccountRoleList
    data.platform=self:getPlatformId()
    data.param1=self.account --account
    data.param2=pswDecode --psw
    local timestamp = ""
    if ChannelPro and ChannelPro:sharedChannelPro().getExt then
        timestamp = ChannelPro:sharedChannelPro():getExt()
        if timestamp and timestamp~="" then
            local rootTable = json.decode(timestamp)
            if rootTable and rootTable.timestamp then
                timestamp = rootTable.timestamp
            end
        end
    end
    data.param4=timestamp
    data.param3=1
    data.udid=self:getDeviceId()
    data.mac=self:getMacAddress()
    local function sessionRespone(responseText)
        print(responseText)
        local ret= cjson.decode(responseText)
        if callback~=nil then
            self.rolelist= Account:parseRoleList(ret)
            gDispatchEvt(EVENT_ID_CHANGE_SERVER)

            self.accountid=ret.accountid
            self.account=ret.account
            self.session=ret.session
            self.phone=ret.phone
            self.psw=ret.psw
            callback(ret)
        end
    end


    local str=self:tableToString(data)
    --{\"type\":2,\"platform\":1,\"ver\":1,\"param2\":\"NDU2MTIz\",\"param1\":\"cctv4\",\"param4\":\"614\",\"param3\":1}"
    print("getSession"..str)
    self:getHttp(self.masterserver,"POST",str,sessionRespone)
end


function Account:bindRole(account,psw,callback)
    if(string.len(string.trim(account))==0)then
        gShowNotice( gGetHttpCode("http_get_err",101))
        return
    end

    if(string.len(string.trim(psw))==0)then
        gShowNotice( gGetHttpCode("http_get_err",102))
        return
    end
    Scene.showWaiting()
    local pswDecode=   DataEDCode:encode(psw)
    local data={}
    data.type=HttpCmd_BoundVisitor
    data.platform=self:getPlatformId()
    data.sid=self:getCurServer().id
    data.accountid=self.accountid
    data.param1=account --account
    data.param2=pswDecode --psw
    data.userid = Data.getCurUserId()
    data.ischange=1
    local function bindRespone(responseText)
        print("HttpCmd_BoundVisitor"..responseText)
        local ret= cjson.decode(responseText)
        if ret.ret==0 then
            gAccount:saveAppstoreAccount(account,psw)
            callback(ret)
        else
            gShowNotice( gGetHttpCode("http_get_err",ret.ret))
        end
        Scene.hideWaiting()
    end
    local str=self:tableToString(data)
    print(str)

    self:getHttp(self.masterserver,"POST",str,bindRespone)
end


function Account:bindPhone(phone,callback)
    if(string.len(string.trim(phone))==0)then
        gShowNotice(gGetWords("noticeWords.plist","phone_number_empty"))
        return
    end
    if(string.len(string.trim(phone))~=11)then
        gShowNotice(gGetWords("noticeWords.plist","phone_number_error"))
        return
    end
    if(gGetCurServerTime() - gSendSMSTime < 60)then
        gShowNotice(gGetWords("noticeWords.plist","send_sms_time_interval"))
        return
    end

    gSendSMSTime = gGetCurServerTime()
    Scene.showWaiting()
    local data={}
    data.type=HttpCmd_BoundPhone
    data.platform=self:getPlatformId()
    data.sid=self:getCurServer().id
    data.phone=phone --手机号码
    data.userid = Data.getCurUserId()
    local function bindRespone(responseText)
        print("HttpCmd_BoundVisitor"..responseText)
        local ret= cjson.decode(responseText)
        if ret.ret==0 then
            gShowNotice(gGetWords("noticeWords.plist","code_sent"))
            callback(ret)
        else
            gSendSMSTime=0
            gShowNotice( gGetHttpCode("http_get_err",ret.ret))
        end
        Scene.hideWaiting()
    end
    local str=self:tableToString(data)
    print(str)

    self:getHttp(self.masterserver,"POST",str,bindRespone)
end

function Account:registerBindAccount(account,psw,repsw,callback)
    if(string.len(string.trim(account))==0)then
        gShowNotice( gGetHttpCode("http_get_err",101))
        return
    end

    if(string.len(string.trim(psw))==0)then
        gShowNotice( gGetHttpCode("http_get_err",102))
        return
    end

    if(psw ~= repsw)then
        gShowNotice( gGetHttpCode("http_get_err",103))
        return
    end

    Scene.showWaiting()

    local pswDecode= DataEDCode:encode(psw)
    local data={}
    data.type=HttpCmd_Register
    data.platform=self:getPlatformId()
    data.account=account
    data.pwd=pswDecode
    data.accountid=0

    local function registerRespone(responseText)
        print("HttpCmd_Register"..responseText)
        local ret= cjson.decode(responseText)
        if(ret.ret==0) then
            callback(ret)
        else
            gShowNotice(gGetHttpCode("http_get_err",ret.ret))
        end
        Scene.hideWaiting()
    end

    local str=self:tableToString(data)
    print("self.masterserver"..self.masterserver.."----ssss"..str)
    self:getHttp(self.masterserver ,"POST",str,registerRespone)

end


function Account:createRole(callback)
    gIsFirstEnter=true
    local data={}
    data.type=HttpCmd_CreateNewRole
    data.platform=self:getPlatformId()
    data.sid=self:getCurServer().id
    data.accountid=self.accountid
    data.channel=gAccount:getAdId()
    data.udid=self:getDeviceId()
    data.mac=self:getMacAddress()
    data.os=self:getDeviceOs();
    data.device=gGetDeviceModel()
    local function createRespone(responseText)
        print("HttpCmd_CreateNewRole"..responseText)
        local ret= cjson.decode(responseText)
        if(ret.ret==0) then
            if(self.rolelist==nil)then
                self.rolelist={}
            end
            table.insert(self.rolelist,ret.rolelist[1])

            if ret.session then
                self.session = ret.session
            end
        end
        if(ret.ret==8) then
            gShowNotice( gGetHttpCode("http_get_err",ret.ret))
            Scene.hideWaiting()
        else
            callback(ret)
        end
    end
    local str=self:tableToString(data)
    print(str)
    self:getHttp(self.masterserver,"POST",str,createRespone)
end


function Account:guestLogin(callback)

    self.accountid = cc.UserDefault:getInstance():getStringForKey("guestAccount","")
    self.session = cc.UserDefault:getInstance():getStringForKey("guestSession","")
    local function createRoleRespone(ret)
        if(ret.ret==0) then
            if ret.accountid  then
                self.accountid = ret.accountid
                cc.UserDefault:getInstance():setStringForKey("guestAccount",ret.accountid)
            end
            if ret.session then
                cc.UserDefault:getInstance():setStringForKey("guestSession",ret.session)
            end
            Account:saveAccount(self.accountid,"")
            callback()
        else
            gShowNotice( gGetHttpCode("http_get_err",ret.ret))
        end
    end
    local function guestRespone(responseText)
        print("HttpCmd_GetVisitorRoleList response"..responseText)
        local ret= cjson.decode(responseText)
        if(ret.ret==0) then
            self.rolelist=ret.rolelist
            self.accountid=ret.accountid
            --self.session=ret.session
            if(self:getCurRole()==nil)then
                self:createRole(createRoleRespone)
                return
            end
            print("GetVisitorRoleList"..responseText)
            Account:saveAccount(self.accountid,"")

            if(self:getCurRole()==nil or self:getCurRole().rolename==nil or string.len(self:getCurRole().rolename)==0)then
                gIsFirstEnter=true
            else
                gIsFirstEnter=false
            end
            callback()
        else
            gShowNotice( gGetHttpCode("http_get_err",ret.ret))
        end
    end

    local data={}
    data.type=HttpCmd_GetVisitorRoleList
    data.platform=self:getPlatformId()
    data.param1=self.accountid
    data.param3=self.session
    local str=self:tableToString(data)
    print("HttpCmd_GetVisitorRoleList"..str)
    self:getHttp(self.masterserver,"POST",str,guestRespone)

end

function Account:parseRoleList(ret)
    local list= {}
    if(ret.userlist)then
        for key, var in pairs(ret.userlist) do
            var.gm=true
            var.rolename="[托管]"..var.rolename
            table.insert(list,var)
        end
    end


    if(ret.rolelist)then
        for key, var in pairs(ret.rolelist) do
            table.insert(list,var)
        end
    end
    return list
end

function Account:login(account ,psw,callback)
    local pswDecode=   DataEDCode:encode(psw)
    if gAccount.motuAccount == false then
        pswDecode = psw
    end
    local data={}
    data.type=HttpCmd_GetAccountRoleList
    data.platform=self:getPlatformId()
    data.param1=account --account
    data.param2=pswDecode --psw
    local timestamp = ""
    if ChannelPro and ChannelPro:sharedChannelPro().getExt then
        timestamp = ChannelPro:sharedChannelPro():getExt()
        if timestamp and timestamp~="" then
            local rootTable = json.decode(timestamp)
            if rootTable and rootTable.timestamp then
                timestamp = rootTable.timestamp
            end
        end
    end
    data.param4=timestamp
    data.param3=1
    if APPSTOREMODE == WXMODE then
        data.acctype=1
    end

    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
        if(self.loginParams.atype ~= nil and self.loginParams.atype == "wx")then
            data.acctype=1
        end
    elseif(gGetCurPlatform() == CHANNEL_ANDROID_LINGJING)then
        if ChannelPro and ChannelPro:sharedChannelPro().getExt then
            local ext = ChannelPro:sharedChannelPro():getExt()
            local rootTable = json.decode(ext)
            if rootTable and  rootTable.channeluserid then
                self.channeluserid = rootTable.channeluserid
                data.channeluserid = rootTable.channeluserid
                data.userid = account
            end
        end
    elseif(gGetCurPlatform() == CHANNEL_ANDROID_ZHANGYUE)then
        if ChannelPro and ChannelPro:sharedChannelPro().getExt then
            local ext = ChannelPro:sharedChannelPro():getExt()
            local rootTable = json.decode(ext)
            if rootTable and  rootTable.channeluserid then
                self.channeluserid = rootTable.channeluserid
                data.channeluserid = rootTable.channeluserid
                data.userid = account
            end
        end
    elseif(gGetCurPlatform() == CHANNEL_ANDROID_LEWAN)then
        if ChannelPro and ChannelPro:sharedChannelPro().getExt then
            local ext = ChannelPro:sharedChannelPro():getExt()
            local rootTable = json.decode(ext)
            data.param4 = rootTable.password
            data.param5 = rootTable.channelId
        end
    elseif(gGetCurPlatform() == CHANNEL_ANDROID_PPTV)then
        if ChannelPro and ChannelPro:sharedChannelPro().getExt then
            local ext = ChannelPro:sharedChannelPro():getExt()
            local rootTable = json.decode(ext)
            data.param4 = rootTable.username
        end
    elseif(gGetCurPlatform() == CHANNEL_ANDROID_QUICK)then
        if ChannelPro and ChannelPro:sharedChannelPro().getExt then
            local ext = ChannelPro:sharedChannelPro():getExt()
            local rootTable = json.decode(ext)
            data.param4 = rootTable.channelId
        end
    elseif(gGetCurPlatform() == CHANNEL_ANDROID_SHUOWAN)then
        if ChannelPro and ChannelPro:sharedChannelPro().getExt then
            local ext = ChannelPro:sharedChannelPro():getExt()
            local rootTable = json.decode(ext)
            data.param4 = rootTable.logintime
        end
    elseif(gGetCurPlatform() == CHANNEL_ANDROID_HANFENG)then
        if ChannelPro and ChannelPro:sharedChannelPro().getExt then
            local ext = ChannelPro:sharedChannelPro():getExt()
            local rootTable = json.decode(ext)
            data.param4 = rootTable.channel
            data.param5 = rootTable.sdkVersion
        end
    -- HWGameSDK_v7.1.1.301 登录参数变化
    elseif(gGetCurPlatform() == CHANNEL_ANDROID_HUAWEI)then
        if ChannelPro and ChannelPro:sharedChannelPro().getExt then
            local ext = ChannelPro:sharedChannelPro():getExt()
            if(ext ~= "" )then
                local rootTable = json.decode(ext)
                data.param4 = rootTable.ts
                data.param5 = rootTable.displayName
            end
        end
    elseif(gGetCurPlatform() == CHANNEL_ANDROID_YOUXIFAN)then
        if ChannelPro and ChannelPro:sharedChannelPro().getExt then
            local ext = ChannelPro:sharedChannelPro():getExt()
            local rootTable = json.decode(ext)
            data.param4 = rootTable.username
            data.param5 = rootTable.logintime
        end
    elseif(gGetCurPlatform() == CHANNEL_ANDROID_JINSHI)then
        if ChannelPro and ChannelPro:sharedChannelPro().getExt then
            local ext = ChannelPro:sharedChannelPro():getExt()
            local rootTable = json.decode(ext)
            data.param4 = rootTable.token
            data.param5 = rootTable.sdk
            data.param6 = rootTable.username
        end
    end

    data.udid=self:getDeviceId()
    data.mac=self:getMacAddress()
    data.channel = gAccount:getAdId()
    local function loginRespone(responseText)
        self.account=account
        self.psw=psw
        local ret= cjson.decode(responseText)
        print(responseText)
        if callback~=nil  then
            if(ret.ret==0)then
                self.rolelist=self:parseRoleList(ret)
                gDispatchEvt(EVENT_ID_CHANGE_SERVER)
                self.accountid=ret.accountid
                self.account=ret.account
                self.session=ret.session
                self.phone=ret.phone
                self.accountName = ret.username
                if(self:getCurRole()==nil)then
                    self:createRole(callback)
                    return
                end


                if(self:getCurRole().rolename==nil or
                    string.len(self:getCurRole().rolename)==0)then
                    gIsFirstEnter=true
                else
                    gIsFirstEnter=false
                end
                callback(ret)
            else
                callback(ret)
            end

        end
    end

    --{"type":2,"platform":1,"ver":1,"param2":"NDU2MTIz","param1":"cctv4","param4":"0","param3":0}

    local str=self:tableToString(data)
    print("login"..str)
    self:getHttp(self.masterserver,"POST",str,loginRespone)

end

local g_loginFinish = false
function Account:loginAccount(account,psw,callback)

    if gAccount.motuAccount == true then
        if(string.len(string.trim(account))==0)then
            gShowNotice( gGetHttpCode("http_get_err",101))
            return
        end

        if(string.len(string.trim(psw))==0)then
            gShowNotice( gGetHttpCode("http_get_err",102))
            return
        end
    end

    local function sessionRespone(data)
        Account:saveAccount(self.account,self.psw)
        if(data.ret==0) then
            if(callback)then
                if ChannelPro and ChannelPro:sharedChannelPro().loginFinish then
                    if g_loginFinish == false then
                        ChannelPro:sharedChannelPro():loginFinish("")
                    end
                    g_loginFinish = true
                end
                callback()
            end
            -- gShowNotice("session 获取成功")
            gShowNotice(gGetWords("noticeWords.plist","session_success"));
        else
            Scene.hideWaiting()
            gShowNotice(gGetWords("noticeWords.plist","session_fail"));
            -- gShowNotice("session 获取失败")

        end
    end

    local function loginRespone(data)
        if(data.ret==0) then
            print("000000000000")
            -- gShowNotice("登录成功，连接服务器")
            gShowNotice(gGetWords("noticeWords.plist","login_success1"));
            sessionRespone(data)
            --gAccount:getSession(sessionRespone)
        else
            gShowNotice( gGetHttpCode("http_get_err",data.ret))
            callback(data.ret)
            if gAccount.motuAccount == false then
                --if data.ret==997 or data.ret==42001 or data.ret==40001 then
                gAccount:delAccount()
                gEnterLayer:updateAccount()
                gAccount:logOut()
                gEnterLayer:showLayer()
                --end
            end
            Scene.hideWaiting()
        end
    end
    Scene.showWaiting()
    gAccount:login(account,psw,loginRespone)
end


function Account:getNoticeList(callback,serverid)
    local data = {};
    data.type = 98;
    data.platform = self:getPlatformId();
    data.sid = serverid;
    if(gIsMultiLanguage())then
        data.lan = ConvertToSeverLanguageIndex()
    end
    local str=self:tableToString(data)
    local function getNoticeListCallBack(responseText)
        -- print("999999999999")
        -- print(responseText)
        local ret= cjson.decode(responseText)
        callback(ret);
        Scene.hideWaiting();
    end
    print("send str = "..str);
    Scene.showWaiting();
    self:getHttp(self.masterserver,"POST",str,getNoticeListCallBack)
end

--获取反馈内容
-- HttpCmd_SendFeedbackInfo = 100  ---发送反馈信息
-- HttpCmd_ReadFeedbackInfo = 101  ---读取反馈信息
function Account:getFeedbackList(callback)
    local data = {};
    data.type = HttpCmd_ReadFeedbackInfo;
    data.platform = self:getPlatformId();
    data.time = 0;
    data.serverid = self:getCurServer().id
    data.userid = Data.getCurUserId()--self:getCurRole().userid
    data.accountid=self.accountid
    data.username = Data.getCurName()--self:getCurRole().rolename;

    local str=self:tableToString(data)
    local function getFeedbackListCallBack(responseText)
        local ret= cjson.decode(responseText)
        callback(ret);
    end
    Scene.showWaiting()
    print("send str = "..str);
    self:getHttp(self.masterserver,"POST",str,getFeedbackListCallBack)
end

function Account:sendFeedback(content,callback)
    if(string.len(string.trim(content))==0)then
        local sWord = gGetWords("noticeWords.plist","intput_empty");
        gShowNotice(sWord);
        return
    end

    local data = {};
    data.type = HttpCmd_SendFeedbackInfo;
    data.platform = self:getPlatformId();
    data.time = 0;
    data.serverid = self:getCurServer().id
    data.userid = Data.getCurUserId()--self:getCurRole().userid
    data.accountid=self.accountid
    data.account=self.account
    data.username = Data.getCurName()--self:getCurRole().rolename;
    data.content = content;

    local str=self:tableToString(data)
    local function getFeedbackListCallBack(responseText)
        local ret= cjson.decode(responseText)
        callback(ret);
    end
    Scene.showWaiting()
    print("send str = "..str);
    self:getHttp(self.masterserver,"POST",str,getFeedbackListCallBack)
end



function Account:sendLuaError(content,callback)
    if(string.len(string.trim(content))==0)then
        local sWord = gGetWords("noticeWords.plist","intput_empty");
        gShowNotice(sWord);
        return
    end

    local data = {};
    data.type = 200;
    data.platform = self:getPlatformId();
    data.time = 0;
    data.serverid = self:getCurServer().id
    data.userid = Data.getCurUserId()--self:getCurRole().userid
    data.accountid=self.accountid
    data.account=self.account
    data.username = Data.getCurName()--self:getCurRole().rolename;
    data.content = content;

    local str=self:tableToString(data)
    local function getFeedbackListCallBack(responseText)
        print(responseText)
        local ret= cjson.decode(responseText)
        callback(ret);
    end
    Scene.showWaiting()
    print("send str = "..str);
    self:getHttp(self.masterserver,"POST",str,getFeedbackListCallBack)
end

function Account:pwdModify(account ,oldpsw,newpsw,renewpsw,callback)
    if(string.len(string.trim(account))==0)then
        gShowNotice( gGetHttpCode("http_get_err",101))
        return
    end

    if(string.len(string.trim(oldpsw))==0)then
        gShowNotice( gGetHttpCode("http_get_err",102))
        return
    end

    if(newpsw ~= renewpsw)then
        gShowNotice( gGetHttpCode("http_get_err",103))
        return
    end

    Scene.showWaiting()

    local oldpwdDecode= DataEDCode:encode(oldpsw)
    local newpswDecode= DataEDCode:encode(newpsw)
    local data={}
    data.type=HttpCmd_ModifyPwd
    data.platform=self:getPlatformId()
    data.param1=account
    data.param2=oldpwdDecode
    data.param3=newpswDecode
    
    local function modifyRespone(responseText)
        -- print("HttpCmd_ModifyPwd"..responseText)
        local ret= cjson.decode(responseText)
        if(ret.ret==0) then
            local oldAccount = gAccount:getAppstoreAccount()
            if oldAccount == account then
                gAccount:saveAppstoreAccount(account,newpsw)
            end
            gShowNotice(gGetWords("noticeWords.plist","psw_change_suc"))
            callback(ret)
        else
            if ret.ret == 5 or ret.ret == 10 then
                gShowNotice(gGetHttpCode("http_chg_psw",ret.ret))
            else
                gShowNotice(gGetHttpCode("http_get_err",ret.ret))
            end
        end
        Scene.hideWaiting()
    end

    local str=self:tableToString(data)
    -- print("ModifyPwd"..str)
    self:getHttp(self.masterserver ,"POST",str,modifyRespone)
end  


function Account:getIapOrder(data,callback)
    if(self.iaporderUrl == nil or self.iaporderUrl == "")then
        gShowNotice(gGetWords("noticeWords.plist","iap_order_null"))
        Scene.hideWaiting()
        return;
    end
    local str=self:tableToString(data)
    local function getIapOrderCallBack(responseText)
        print(responseText)
        local ret= cjson.decode(responseText)
        if(ret.ret==0) then
            callback(ret)
        else
            gShowNotice(gGetWords("noticeWords.plist","iap_order_null"))
        end
        Scene.hideWaiting()
    end
    Scene.showWaiting()
    -- print("send str = "..str);
    self:getHttp(self.iaporderUrl,"POST",str,getIapOrderCallBack)
end

return Account;