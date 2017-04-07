gIsBanshuReview = true
function isBanshuReview()
    -- 是否版署评审
    if gIsBanshuReview == true then
        return true
    end

    return false
end

function getLvReviewName(name)
    if isBanshuReview() then
        return gGetWords("labelWords.plist","lab_lv")
    else
        return name
    end
end

function setInputBgTxt(node)
	if isBanshuReview() then
		node:setPlaceHolder("请输入")
	end
end

function isBanshuUser()
    -- 版署玩家账号
    if gUserInfo.banshuClose then
        return true
    end

    return false;
end

function getLvReviewName(word)
    if word then
        if isBanshuReview() then
            local upperWord = word--string.upper(word)
            local ret,_ = string.find(upperWord, "LV.");
            local replaceWord = {}
            table.insert(replaceWord,"LV.")
            table.insert(replaceWord,"LV")
            --table.insert(replaceWord,"Lv.")
            table.insert(replaceWord,"Lv")
            for i=1,#replaceWord do
                local ret,_ = string.find(upperWord, replaceWord[i]);
                if ret then
                    upperWord = (string.gsub(upperWord, replaceWord[i], gGetWords("labelWords.plist","lab_lv_banshu")))
                    break;
                end
            end

            --[[if ret then
                upperWord=(string.gsub(upperWord, "LV.", gGetWords("labelWords.plist","lab_lv_banshu")))
            elseif string.find(upperWord, "LV") then
                upperWord=(string.gsub(upperWord, "LV", gGetWords("labelWords.plist","lab_lv_banshu")))
            elseif string.find(upperWord, "Lv.") then
                upperWord=(string.gsub(upperWord, "Lv.", gGetWords("labelWords.plist","lab_lv_banshu")))
            elseif string.find(upperWord, "Lv") then
                upperWord=(string.gsub(upperWord, "Lv", gGetWords("labelWords.plist","lab_lv_banshu")))
            end]]

            if string.find(upperWord, "MAX") then
                upperWord=(string.gsub(upperWord, "MAX", "最大"))
            end

            return upperWord;
        end
    end
    
    return word
end