
IFrame={};
IFrame.data = {};

function IFrame.readGameConfig()
	IFrame.readLabelAtlasConfig();
	IFrame.readLabelOutLineConfig();
end

function IFrame.readLabelAtlasConfig()
	local filePath=cc.FileUtils:getInstance():fullPathForFilename("fightScript/atlas_config.csv")
    local content = cc.FileUtils:getInstance():getStringFromFile(filePath);
	local lines = string.split(content,"\n");
	IFrame.data.labelAtlasConfig = {};
	for key,var in pairs(lines) do
		local datas = string.split(var,",");
		if table.getn(datas) > 4 then
			table.insert(IFrame.data.labelAtlasConfig,{image = datas[1],w = datas[2],h = datas[3], offw = datas[4], start = datas[5]});
		end
	end
	-- print_lua_table(IFrame.data.labelAtlasConfig);
	-- print("content = "..content);
end

function IFrame.readLabelOutLineConfig()
	local filePath=cc.FileUtils:getInstance():fullPathForFilename("fightScript/outline_config.csv")
    local content = cc.FileUtils:getInstance():getStringFromFile(filePath);
	local lines = string.split(content,"\n");
	IFrame.data.labelOutLineConfig = {};
	for key,var in pairs(lines) do
		local datas = string.split(var,",");
		if table.getn(datas) > 4 then
			table.insert(IFrame.data.labelOutLineConfig,{r = datas[1],g = datas[2],b = datas[3], o = datas[4], offset = datas[5]});
		end
	end
	-- print_lua_table(IFrame.data.labelAtlasConfig);
	-- print("content = "..content);
end
