Story={}
Story.storyWords=nil
Story.storys=nil

Story.storyAtlasWords=nil


function Story.getStoryWord(id)

    if(Story.storyWords==nil)then
        Story.storyWords=cc.FileUtils:getInstance():getValueMapFromFile("word/storyWord.plist")
    end
    return Story.storyWords[id]

end


function Story.getAtlasStoryWord(mapid,stageid,time)

    if(Story.storyAtlasWords==nil)then
        Story.storyAtlasWords=cc.FileUtils:getInstance():getValueMapFromFile("fightScript/atlasStory.plist")
    end
       
      
    return Story.storyAtlasWords["atlas_"..mapid.."_"..stageid.."_"..time]

end

function Story.getStory(id)
    if(Story.storys==nil)then
        Story.storys=cc.FileUtils:getInstance():getValueMapFromFile("fightScript/story.plist")
    end

    for key, var in pairs(Story.storys.story) do
        if(toint(var.storyid)==id)then
            return var
        end
    end

    return nil

end

function Story.finish()
    gStoryLayer:removeAllChildren()

end

function Story.showStory(id,callback)
    gStoryLayer:removeAllChildren()
    local layer=StoryLayer.new()
    gStoryLayer:addChild(layer)
    layer:setStory(id,callback)
end