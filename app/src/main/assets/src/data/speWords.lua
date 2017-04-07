gSpeWords={
	"郃","惇",
}

function gContainSpeWord(word)
	if(word==nil)then
	   return false
	end
	for k,v in pairs(gSpeWords) do
		if string.find(word,v) then
			-- print("find spe word~");
			return true;
		end
	end
	return false;

end
