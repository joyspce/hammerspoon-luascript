
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com


function _qsse_changeTo(split, actions)

    local paste = hs.pasteboard.getContents() or ""

    local array
    if string.find(split, "enter") then
        print("split == 回车")
        array = qsSplit(paste, "\n")
    else
        array = qsSplit(paste, split)
    end

    if #array == 0 then return end
    local tempText = ""
    for i, varStr in ipairs(array) do

        for idx, v in ipairs(actions) do
            -- rep=x-b|pre=x|suf=x
            if qsIsPreFix(v, "rep=") then    -- 替换
                local repStr = string.sub(v, #"rep=" + 1, #v)
                print("rep=" .. repStr)
                local replaceArr = qsSplit(repStr, "-")
                qsPrintTable(replaceArr)
                if 2 ~= #replaceArr then
                    varStr = string.gsub(varStr, " ", "")
                else
                    print("replaceArr[1]".. replaceArr[1])
                    varStr = string.gsub(varStr, replaceArr[1], replaceArr[2])
                end

            elseif qsIsPreFix(v, "pre=") then -- 前缀
                print("pre=1 "..v)
                local pre = string.sub(v, #"pre="+1, #v)
                print("pre=2"..pre)
                if string.find(pre, "enter") then
                    varStr = '\n'..varStr
                    print("3 pre enter")
                else
                    varStr = pre..varStr
                end

            elseif qsIsPreFix(v, "suf=") then -- 后缀
                print("suf="..v)
                local suf = string.sub(v, #"suf="+1, #v)

                if string.find(suf, "enter") then
                    varStr = varStr..'\n'
                else
                    varStr = varStr..suf
                end
            end
        end
        tempText = tempText..varStr.." "
        -- print( "varStr =", varStr)
    end
    hsPasteWithString(tempText)
end

-- stati ? sevarStrlf ? superxsuffixx
-- arr ?§§
--  "⇪ + §    paste 1.jsonModel2.changeStr"
function qsse_changPasteboardByText()
    local path = hs.configdir.."/script/changPasteboard.txt"
    -- read
    local repText = qsReadFile(path)
    repText = repText[1]

    hsTextPrompt("替换文字", "spl 分割\nrep替换\npre前缀\nsuf后缀\nenter回车\n spl=x|rep=x-b|pre=x|suf=x",
    repText, function(text)
        -- write
        qsSaveOrAddWithStr(path,'w', text)

        local actions = qsSplit(text, "|")
        local  splits = actions[1]

        table.remove(actions, 1)

        print("splits :"..splits)

        local split = " "
        if string.sub(splits,1,#"spl=") == "spl=" then
            split = string.gsub(splits, "spl=", "")
        end

        print("split :"..split)

        _qsse_changeTo(split, actions)
    end)
end



--

--
