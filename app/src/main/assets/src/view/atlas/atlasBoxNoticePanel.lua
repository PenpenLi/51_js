local AtlasBoxNoticePanel=class("AtlasBoxNoticePanel",UILayer)

function AtlasBoxNoticePanel:ctor(mapid,type)
    self.appearType = 1;
    self:init("ui/ui_atlas_box_notice.map")
    self.isMainLayerMenuShow=false


    self.mapid=mapid
    self.type=type
    self:setData() 

end


function  AtlasBoxNoticePanel:events()
    return {
        EVENT_ID_ATLAS_BOX_GOT,
        EVENT_ID_ATLAS_SET_MAPID
    }
end

function AtlasBoxNoticePanel:setData()

    self:getNode("scroll"):clear()
    self.boxMaps={}

    for mapid=1, self.mapid-1 do 
        for i=1, 3 do
            local has=Data.hasAtlasGetBox(mapid,i,self.type)
            if(has==false)then  
                local chapter=DB.getChapterById(mapid,self.type)
             
                if(chapter)then  
                    local curStar=Data.getCurAtlasStar(mapid,self.type)
                    local needNum= chapter["num"..i]
                    if(mapid==self.mapid-1)then 
                        if(curStar>=needNum)then
                            table.insert(self.boxMaps,{chapter=chapter,mapid=mapid,boxid=i,get=1,type=self.type}) 
                        end
                    else 
                        if(curStar>=needNum)then
                            table.insert(self.boxMaps,{chapter=chapter,mapid=mapid,boxid=i,get=1,type=self.type})
                        else
                            table.insert(self.boxMaps,{chapter=chapter,mapid=mapid,boxid=i,get=0,type=self.type})
                        end
                    end
                
                end

            end
        end
    end


    for key, var in pairs(self.boxMaps) do        
        local item=AtlasBoxNoticeItem.new()
        item:setData(var)
        item.panel=self
        item.itemid=self.itemid 
        self:getNode("scroll"):addItem(item)
    end
    
    
    local function sortFunc(a,b)
        return a.sort>b.sort
    end
    --table.sort(self:getNode("scroll").items,sortFunc)
    self:getNode("scroll"):layout()
end

function AtlasBoxNoticePanel:dealEvent(event,param)
    if(event==EVENT_ID_ATLAS_BOX_GOT)then
        self:setData()  
    end
end



function AtlasBoxNoticePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

return AtlasBoxNoticePanel