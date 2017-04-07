Data=Data or {}
function Data.diffInit()
	gIsHorizontal = false;
	gMaxShortNum = 10000;
	gCurLanguage = LANGUAGE_ZHS;
	if(gIsMultiLanguage())then
		gMaxShortNum = 1000;
	end
end