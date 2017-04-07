BattleTalk=class("BattleTalk", UILayer)


function BattleTalk:ctor()
    
    loadFlaXml("ui_guide")  
end


function BattleTalk:showWord(word)
    local  layer=UILayer.new()
    layer:init("ui/ui_battletalk.map")  
    layer:setRTFString("txt_words",word)
    
    local size=layer:getNode("txt_words"):getContentSize()
    size.width=size.width+25
    size.height= layer:getNode("bg_scale9"):getContentSize().height
    layer:getNode("bg_scale9"):setContentSize(size)
    
    local effect=gCreateFla("ui_zhenji_qipao")
    effect:replaceBoneWithNode({"talkbg"},layer)
    self:addChild(effect)
end


return BattleTalk