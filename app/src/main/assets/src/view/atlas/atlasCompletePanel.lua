local AtlasCompletePanel=class("AtlasCompletePanel",UILayer)
local moveSpeed = 0.1
local maxAtlasid = 10

function AtlasCompletePanel:ctor(mapid)
    loadFlaXml("ui_atlas_complete")

    -- self.appearType = 1
    self:init("ui/ui_atlas_complete.map")
    Guide.pause=true
    self.isBlackBgVisible=false  
    self._panelTop = true
    self._mapid = mapid
    self._pen   = nil
    self._infoLineBreakIndex = {}
    self._infoLetterPos      = {}

    local panelSize = self:getContentSize()
    --bg animation
    local replaceBoneData = {}
    table.insert(replaceBoneData,{boneTable = {"map","map"},nodePath = self:getMapPathByID(mapid)})
    local aniGroup = FlashAniGroup.new()
    aniGroup:addFlashAni("ui_atlas_complete", false, 0, replaceBoneData)
    aniGroup:play()
    self:replaceNode("atlas_complete",aniGroup)

    --Introduce title and info
    local title,info = self:getTitleAndInfoByMapid(mapid)
    assert(title ~= "" or info ~= info, "get the wrong title and info")
    local pen = gCreateFla("ui_atlas_complete_pen",1)
    pen:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(pen, 2)
    self._pen = pen
    self._pen:setVisible(false)

    local txtTitle = self:getNode("txt_titile")
    txtTitle:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    txtTitle:setWidth(panelSize.width / 2)
    local length = string.utf8len(title)
    txtTitle:setPosition(panelSize.width / 2, -panelSize.height / 3)
    txtTitle:enableOutline(cc.c4b(40, 20, 20, 255), 1)
    txtTitle:enableShadow(cc.c4b(0, 0, 0, 0))
    self:setLabelString("txt_titile", title)

    local infoTxt = self:getNode("txt_info")
    infoTxt:setWidth(panelSize.width / 2)
    infoTxt:setHeight(panelSize.height / 4)
    infoTxt:enableOutline(cc.c4b(40, 20, 20, 255), 1)
    infoTxt:enableShadow(cc.c4b(0, 0, 0, 0))
    self:setLabelString("txt_info", info)
    infoTxt:getStringNumLines()

    local platformid = gAccount:getPlatformId()
    if platformid == CHANNEL_ANDROID_EFUNTWGW or
       platformid == CHANNEL_ANDROID_EFUNTWGP or
       platformid == CHANNEL_ANDROID_EFUNHK or 
       platformid == CHANNEL_IOS_EFUNTW or
       platformid == CHANNEL_IOS_EFUNHK then
       txtTitle:setVisible(false)
       infoTxt:setVisible(false)
       local delayTime = cc.DelayTime:create(0.8)
       local callFunc  = cc.CallFunc:create(function ( ... )
            txtTitle:setVisible(true)
            infoTxt:setVisible(true)
            local iconPass = self:getNode("icon_pass")
            iconPass:runAction(cc.Sequence:create(textDelay,cc.CallFunc:create(function()
                    self._pen:setVisible(false)
                    local pass = gCreateFla("ui_atlas_mark", -1)
                    pass:setAnchorPoint(cc.p(0.5, 0.5))
                    pass:setPosition(panelSize.width * 0.708, -panelSize.height * 0.63)
                    self:addChild(pass, 2)

                    local clickLabelDelay = cc.DelayTime:create(1)
                    local fadeInaction    = cc.FadeOut:create(1)
                    local fadeInactionBack = fadeInaction:reverse()
                    local txtClick = self:getNode("txt_click")
                    txtClick:setString(gGetWords("labelWords.plist" ,"lab_comatlas_next_stage"))
                    txtClick:runAction(cc.Sequence:create(clickLabelDelay, cc.Show:create()))
                    txtClick:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(fadeInaction,cc.EaseBackOut:create(cc.ScaleTo:create(1,0.85))), 
                                             cc.Spawn:create(fadeInactionBack,cc.EaseBackOut:create(cc.ScaleTo:create(1,1))))))
            end)))
       end)
       self:runAction(cc.Sequence:create(delayTime, callFunc))
    else
        local firstTitleLetter = nil
        for i = 1, length do
            local letter = txtTitle:getLetter(i - 1)
            if nil ~= letter then
                letter:setVisible(false)
                if nil == firstTitleLetter then
                    firstTitleLetter = letter
                end
            end
        end
        local infoLength = infoTxt:getStringLength()
        local firstInfoLetter = nil
        for i = 1, infoLength do
            local letter = infoTxt:getLetter(i - 1)
            if letter then
                letter:setVisible(false)
                if nil == firstInfoLetter then
                    firstInfoLetter = letter
                end
            elseif i ~= infoLength then
                self._infoLineBreakIndex[#self._infoLineBreakIndex + 1] = i
            end
        end

        for i = 1, #self._infoLineBreakIndex do
            local letter = infoTxt:getLetter(self._infoLineBreakIndex[i] + 1)
            if nil ~= letter then
                local worldPos = infoTxt:convertToWorldSpace(cc.p(letter:getPosition()))
                local nodePos  = self:convertToNodeSpace(worldPos)
                self._infoLetterPos[#self._infoLetterPos + 1] = cc.p(nodePos.x - letter:getContentSize().width, nodePos.y)
            end
        end

        if #self._infoLineBreakIndex ~= #self._infoLetterPos then
            print("the length should be equal")
        end

        local delay = cc.DelayTime:create(1)
        self:runAction(cc.Sequence:create(delay, cc.CallFunc:create(function()
            local letterContensize = firstTitleLetter:getContentSize()
            local worldPos = txtTitle:convertToWorldSpace(cc.p(firstTitleLetter:getPosition()))
            local nodePos  = self:convertToNodeSpace(worldPos)
            self._pen:setPosition(nodePos.x - letterContensize.width, nodePos.y)
            self._pen:setVisible(true)

            local textAppear = cc.Show:create()
            for i = 1, length do
                local sprite = txtTitle:getLetter(i - 1)
                letterContensize = sprite:getContentSize()
                if sprite then
                    local textDelay = cc.DelayTime:create(moveSpeed * (i - 1))
                    local textActionSeq = cc.Sequence:create(textDelay, cc.CallFunc:create(function ()
                        -- local worldPos = txtTxt:convertToWorldSpace(cc.p(sprite:getPosition()))
                        -- local nodePos  = self:convertToNodeSpace(worldPos)
                        -- self._pen:runAction(cc.MoveTo:create(0.3, cc.p(nodePos.x + sprite:getContentSize().width,nodePos.y)))
                        self._pen:runAction(cc.MoveBy:create(moveSpeed, cc.p(letterContensize.width, 0)))
                        if i == length then
                            local infoLetterContensize = firstInfoLetter:getContentSize()
                            local infoWorldPos = infoTxt:convertToWorldSpace(cc.p(firstInfoLetter:getPosition()))
                            local infoNodePos  = self:convertToNodeSpace(infoWorldPos)
                            self._pen:setPosition(infoNodePos.x - infoLetterContensize.width,infoNodePos.y)
                            self:showInfo(infoLength + 1, infoLetterContensize.width)
                        end
                    end),cc.DelayTime:create(moveSpeed), textAppear)
                    sprite:runAction(textActionSeq)
                end
            end
        end)))
    end
end

function AtlasCompletePanel:onTouchEnded(target)
    Guide.pause=false
    local curMapid=Net.sendAtlasEnterParam.mapid
    Panel.popBack(self:getTag())
    local panel = Panel.getPanelByType(PANEL_ATLAS)
    if nil ~= panel then
        gAtlas.showCharpterOpen = true
    end
    if Data.shouldCommentAppStore(APPSTORE_COMMENT_ATLAS_FINAL,curMapid) then
        Panel.popUpVisible(PANEL_APPSTORE_CONFIRM,APPSTORE_COMMENT_ATLAS_FINAL,nil,true)
    end
end

function AtlasCompletePanel:getMapPathByID(mapid)
    local mapIndex = nil
    for k,v in ipairs(ATLAS_ID_MAP) do
        if ATLAS_ID_MAP[k] == mapid then
            mapIndex = k
        end
    end
    
    if mapIndex == nil then
        return ""
    end

    local mapPath = "images/ui_atlas"
    if mapIndex < 10 then
        mapPath = string.format("images/ui_atlas/0%d/map.png", mapIndex)
    else
        mapPath = string.format("images/ui_atlas/%d/map.png", mapIndex)
    end
    
    return mapPath
end

function AtlasCompletePanel:showInfo(length)
    local panelSize = self:getContentSize()
    local infoTxt = self:getNode("txt_info")
    local textAppear = cc.Show:create()
    local fadeIn     = cc.FadeIn:create(0.3)
    for i = 1, length do
        local sprite = infoTxt:getLetter(i - 1)
        if sprite then
            local contensize = sprite:getContentSize()
            local textDelay = cc.DelayTime:create(moveSpeed * (i-1))
            local textActionSeq = cc.Sequence:create(textDelay, cc.CallFunc:create(function ()
                self._pen:runAction(cc.MoveBy:create(moveSpeed, cc.p(contensize.width, 0)))
            end),cc.DelayTime:create(moveSpeed),textAppear)
            sprite:runAction(textActionSeq)
        else
            -- #self._infoLineBreakIndex ~= #self._infoLetterPos
            local textDelay = cc.DelayTime:create(moveSpeed * (i - 1))
            for k = 1, #self._infoLineBreakIndex do
                if i == self._infoLineBreakIndex[k] then                  
                    self._pen:runAction(cc.Sequence:create(textDelay, cc.MoveTo:create(moveSpeed, self._infoLetterPos[k])))
                end
            end
            
            if i == length then
                local iconPass = self:getNode("icon_pass")
                iconPass:runAction(cc.Sequence:create(textDelay,cc.CallFunc:create(function()
                        self._pen:setVisible(false)
                        local pass = gCreateFla("ui_atlas_mark", -1)
                        pass:setAnchorPoint(cc.p(0.5, 0.5))
                        pass:setPosition(panelSize.width * 0.708, -panelSize.height * 0.63)
                        self:addChild(pass, 2)

                        local clickLabelDelay = cc.DelayTime:create(1)
                        local fadeInaction    = cc.FadeOut:create(1)
                        local fadeInactionBack = fadeInaction:reverse()
                        local txtClick = self:getNode("txt_click")
                        txtClick:setString(gGetWords("labelWords.plist" ,"lab_comatlas_next_stage"))
                        txtClick:runAction(cc.Sequence:create(clickLabelDelay, cc.Show:create()))
                        txtClick:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(fadeInaction,cc.EaseBackOut:create(cc.ScaleTo:create(1,0.85))), 
                                                 cc.Spawn:create(fadeInactionBack,cc.EaseBackOut:create(cc.ScaleTo:create(1,1))))))
                end)))
            end
        end
    end
end

function AtlasCompletePanel:getTitleAndInfoByMapid(mapid)
    if (nil == mapid) or (mapid > Data.getMaxAtlasPassedIntro()) then
        return "",""
    end
    local name="word/atlasPassedWords.plist"
    local atlasPassedWords=Scene.fileCache[name]
    if(atlasPassedWords==nil)then
        atlasPassedWords=cc.FileUtils:getInstance():getValueMapFromFile(name)
        Scene.fileCache[name]=atlasPassedWords
    end 

 
    for k,v in pairs(atlasPassedWords) do
        if toint(k) == mapid then
            return v.title, v.info
        end
    end

    return "",""
end

return AtlasCompletePanel