local FeedbackItemPanel=class("FeedbackItemPanel",UILayer)
function FeedbackItemPanel:ctor(data,index)
    self:init("ui/ui_feedback_item.map")
    self.index = index;

--     //问题反馈
-- class FeedbackInfo{
-- public:
--     string content;
--     string addtime;
--     string dealtime;
--     string response;
-- };
-- data.content = "我是发斯蒂芬第三方撒旦发生的奋斗发生的丰富的费阿萨德法撒旦发生的发到飞洒发生的发斯蒂芬士大夫阿萨德发顺丰ADS发斯蒂芬士大夫撒旦撒旦奋斗我是发斯蒂芬第三方撒旦发生的奋斗发生的丰富的费阿萨德法撒旦发生的发到飞洒发生的发斯蒂芬士大夫阿萨德发顺丰ADS发斯蒂芬士大夫撒旦撒旦奋斗"

    local addtime=gParserDay(data.addtime)
    self:setLabelString("txt_time",addtime)
    self:setLabelString("txt_info","")
    self:setLabelString("txt_info",data.content)
    self:getNode("txt_name"):setString(Data.getCurName())

    self.bgWidth = self:getNode("bg"):getContentSize().width;
    self.bgHeight = self:getNode("bg"):getContentSize().height;
    self.bgGmHeight = self:getNode("bg_gm"):getContentSize().height;
    self.bgGmWidht = self:getNode("bg_gm"):getContentSize().width;
    local offH = 2;

    -- print("bgWidth:" .. self.bgWidth)
    -- print("bgGmHeight:" .. self.bgGmHeight)

    if (data.response ~= nil) then
    	self:getNode("gm_layer"):setVisible(true);
    	local dealtime=gParserDay(data.dealtime)
        self:setLabelString("txt_time_gm",dealtime)

        -- data.response = "thedsdfdfdfdfdfefefdfasdfadsfsadfasdfasdfsdfsdfdfsdfdfdfdfaeeetjjjjjjjjjjjjjjjjjjjjjasdfasdfsdfsafsafsfsafsdfsafsdfasdfsadfasdfasdfsdfdsfsadfdsfsdfsdfdfsfadsfadfasdfasdfasdf"
        
        self:setLabelString("txt_info_gm","")
        self:setLabelString("txt_info_gm",data.response)

        local height = self:getNode("txt_info"):getContentSize().height;
        local addHeight = 0;
        if (height>25) then
        	addHeight = height - 22;
        end

        local gmTxtH = self:getNode("txt_info_gm"):getContentSize().height;
        print("gmTxtH="..gmTxtH)
        local addHeightGm = 0;
        if (gmTxtH>25) then
        	addHeightGm = (gmTxtH-22);
        	addHeight = addHeight + addHeightGm;
        end

        self:getNode("bg_gm"):setContentSize(cc.size(self.bgGmWidht, self.bgGmHeight+addHeightGm));
        
        self:getNode("gm_layer"):setPositionY(self:getNode("gm_layer"):getPositionY() - (addHeight - addHeightGm));
        
        self:getNode("bg"):setContentSize(cc.size(self.bgWidth, self.bgHeight + addHeight));
        self:setContentSize(cc.size(self:getContentSize().width,self:getContentSize().height+addHeight+offH));
    else --未回复
    	self:getNode("gm_layer"):setVisible(false);
    	--计算高度
    	local height = self:getNode("txt_info"):getContentSize().height + self.bgGmHeight - 22;
    	-- print("height="..height)
    	local width = self.bgWidth;
    	self:getNode("bg"):setContentSize(cc.size(width, height));

    	self:setContentSize(cc.size(self:getContentSize().width,height+offH));
    end

    -- self:setRTFString("txt_info", msgs)
    -- local width = self:getNode("txt_info"):getContentSize().width
    -- local height = self:getNode("txt_info"):getContentSize().height + self.bgHeight - 22
    -- -- self.lines = math.floor(height/20) - 1
    -- if height > self.bgHeight --[[and width >= orginWidth]] then
    --     print ("adjust item size>>>>")
    --     local offH = (height) - self.bgHeight;
    --     self:setContentSize(cc.size(self:getContentSize().width,self:getContentSize().height+offH));
    --     self:getNode("bg"):setContentSize(cc.size(self.bgWidth, height));
    -- end

    -- if () then
    -- end
end


return FeedbackItemPanel