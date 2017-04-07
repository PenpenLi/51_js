local FlashAniGroup=class("FlashAniGroup", function()
    return cc.Node:create()
end)

function FlashAniGroup:ctor()
    self.flashAni = {};
    local function onNodeEvent(event)
        if event == "exit" then
          self:onExist();
        end
    end
    self:registerScriptHandler(onNodeEvent);      
end

function FlashAniGroup:onExist()
    print("FlashAniGroup:onExist");
    if self.flashAni ~= nil then
        for key,var in pairs(self.flashAni) do
            if var.repaceBoneData ~= nil then
                for k,v in pairs(var.repaceBoneData) do
                    if v.node ~= nil then
                        v.node:release();
                        print("node:release");
                    end
                end
            end   
        end 
    end
end

--repaceBoneData={boneTable={层1,层2},nodePath=图片路径 or node = 生成node}
function FlashAniGroup:addFlashAni(name,endDel,loop,repaceBoneData,finishCallback)
    if repaceBoneData ~= nil then

        for k,v in pairs(repaceBoneData) do
            if v.node ~= nil then
                v.node:retain();
            end
        end
    end
    table.insert(self.flashAni,{name=name,loop=loop,endDel=endDel,repaceBoneData=repaceBoneData,finishCallback=finishCallback});
end

function FlashAniGroup:setPlayEndCallBack(callback)
    self.endCallBack = callback;
end

function FlashAniGroup:play()
    local count = table.getn(self.flashAni);
    if count > 0 then
        local data = self.flashAni[1];
        local fla = FlashAni.new();
        fla.endDel = data.endDel;
        local palyEnd = function()
            if data.finishCallback then
                data.finishCallback();
            end
            self:play();
        end

        if data.endDel == true or data.loop == 1 then
            data.loop = 1;
            print("play ani "..data.name);
            fla:playAction(data.name,palyEnd,nil,data.loop);
        else
            --不删除或者不循环播放,执行不了播放结束的回调
            local durTime = fla:playAction(data.name,nil,nil,data.loop);
            gCallFuncDelay(durTime,self,self.play);
        end

        if data.repaceBoneData then
            print_lua_table(data.repaceBoneData);
            -- print("start");
            for key,var in pairs(data.repaceBoneData) do
                -- print("111111111");
                if var.nodePath then
                    -- print("22222");
                    fla:replaceBone(var.boneTable,var.nodePath);
                elseif var.node then
                    -- print("33333");
                    -- print("var.node replaceBoneWithNode");
                    fla:replaceBoneWithNode(var.boneTable,var.node);
                end
            end
            -- print("end");
        end
        
        self:addChild(fla);
        table.remove(self.flashAni,1);
    else
        if self.endCallBack then
            self.endCallBack();
        end    
    end
end

function FlashAniGroup:playDelay(delay)
    gCallFuncDelay(delay,self,self.play);
end


return FlashAniGroup;