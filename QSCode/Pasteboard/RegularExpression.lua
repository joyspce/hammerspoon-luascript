-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2019/01/05 17:51
-- Use    : RegularExpression
-- Change :

local function stringRegularEx(text, regularEx)
    if not text or text == '' or #text == 0 then return show('current Text is empty!!!') end
    local array = regular.array(text, regularEx)
    local str = ''
    if array and #array > 0 then
        for i,v in ipairs(array) do str = str ..v.." " end
    end
    return str
end

function RegularExpression()
    if _OperationMgr then
        _OperationMgr.remove()
        _OperationMgr = nil
        return
    end

    local path = hs.configdir.."/QSCode/Pasteboard/RegularExpression.txt"
    _OperationMgr = OperationMgr(path, true)

    local s = _OperationMgr

    s.setOperationTitle = function(text)
        s.histoyTitle("Regular Expression is: "..text, 'left')
    end
    s.setOperationTitle('')

    s.operationTitle('Regular Expression Operation')

    s.addKey('escape', "Exit Edit Mode", mmExit)
    s.addKey('q',      "Exit Edit Mode",  mmExit)
    s.addKey()

    s.addKey('c', "Translate to Pasteboard", s.copyTranslateToPasteboard)

    s.undoArray = {}
    s.addKey('u', 'Undo', function()
        if #s.undoArray > 1 then
            table.remove(s.undoArray, #s.undoArray)
            local str = s.undoArray[#s.undoArray]
            s.pasteboard(str)
            s.currentText = str
            -- 翻译 一下
            s.translation(str)
        end
    end)
    local SaveToRegularExpression = "Save to Regular Expression"
    s.addKey('s', SaveToRegularExpression, function()
        if s.currentText then
            s.saveWithStr(s.currentText)
            s.setOperationTitle('')
            s.reloadData(reloadDataFn)
        else
            show("nil")
        end
    end)
    s.addKey('r', "remove key 1", function()
        if #s.dataSoruce.dataSoruce > 0 then
            s.dataSoruce.removeAtIndex(1)
            s.dataSoruce.save()
            s.setOperationTitle('')
            s.reloadData(reloadDataFn)
        end
    end)

    s.addKey()
    s.addKey('p', "Pasteboard to current Edit", function()
        if s.currentText then hsPasteWithString(s.currentText) end
        mmExit()
    end)

    s.addKey('f', "copy key 1", function()
        if #s.dataSoruce.dataSoruce > 0 then
            hsPasteWithString(s.dataSoruce.dataSoruce[1])
        end
        mmExit()
    end)

    s.addKey()
    s.addKey('n', "nummbers [0-9]+", function()
        local str = stringRegularEx(s.currentText, '[0-9]+')
        setCurrentText(str)
    end)
    s.addKey('a', "chars [a-zA-Z]+", function()
        local str = stringRegularEx(s.currentText, '[a-zA-Z]+')
        setCurrentText(str)
    end)
    s.addKey('z', "chinese [\\u4e00-\\u9fa5]+", function()
        local str = stringRegularEx(s.currentText, '[\\u4e00-\\u9fa5]+')
        setCurrentText(str)
    end)
    s.addKey('w', "all char \\w+", function()
        local str = stringRegularEx(s.currentText, '[0-9a-zA-Z\\u4e00-\\u9fa5]+')
        setCurrentText(str)
    end)
    s.addKey('x', "to oc words @\"string\"", function()
        if s.currentText then
            local str = lsFormatTextWithBeginAndEnd(s.currentText , '@"',  '", ')
            setCurrentText(str)
        end
    end)
    s.addKey('l', "to lua words \"string\"", function()
        if s.currentText then
            local str = lsFormatTextWithBeginAndEnd(s.currentText , '"',  '", ')
            setCurrentText(str)
        end
    end)
    s.addKey('o', "open https://regexr.com", function()
        local defaultbrowser = hs.urlevent.getDefaultHandler("http")
        hs.urlevent.openURLWithBundle('https://regexr.com', defaultbrowser)
        mmExit()
    end)


    function reloadDataFn(regEx)
        -- 设置 histoty Title
        s.setOperationTitle(regEx)
        s.saveWithStr(regEx)
        s.reloadData(reloadDataFn)

        local text = ''
        if s.currentText then
            if string.find(regEx, "_replace_") then
                local split = qsSplit(regEx, "_replace_")
                if #split == 2 then
                    text =regular.replace(s.currentText, split[1], split[2])
                end
            elseif string.find(regEx, "_begin_") and string.find(regEx, "_end_") then
                local split = qsSplit(regEx, "_begin_")
                local array = regular.array(s.currentText, split[1])
                split = qsSplit(split[2], "_end_")
                if array and #array>0 then
                    for i,v in ipairs(array) do
                        text = text..split[1]..v..split[2]
                    end
                end
            else
                text = stringRegularEx(s.currentText, regEx)
            end
        end
        setCurrentText(text)
    end

    s.reloadData(reloadDataFn)

    function setCurrentText(str)
        local str = str or ''
        s.currentText = str
        if #s.undoArray == 0 or s.undoArray[#s.undoArray] ~= str then
            s.undoArray[#s.undoArray +1] = str
        end
        s.setCurrentText(str, true)
    end

    --- * ⑤ 从粘贴板读取
    local paste = Pasteboard()
    paste._callBackFn = function(str)
        setCurrentText(str)
    end
    paste.setPasteboard(true)
end



--
