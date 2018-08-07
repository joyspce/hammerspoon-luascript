
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

qsc_chooser_Obj = nil
hs.shutdownCallback = function()
    local obj = qsc_chooser_Obj
    if obj and obj.isChange then
        obj.save()
        print("save")
    else
        print("不用save")
    end
end

function QSC_Chooser()

    local this = {}
    this._path = hs.configdir.."/Text/chooser_datasourse"

    this.isChange = false

    this.dataSourse = qsl_arrayRead(this._path)

    table.sort(this.dataSourse, function(a, b)
        local arr1 = arrayWithStringAndSplit(a, "|")
        local arr2 = arrayWithStringAndSplit(b, "|")
        return tonumber(arr1[1]) > tonumber(arr2[1])
    end)

    this._replaceEnter = function(str) return string.gsub(str, '\n', '___') end
    this.replaceUnderline = function(str) return string.gsub(str, '___', '\n') end

    this.add = function(str)
        local text = this._replaceEnter(str)
        local arr = arrayWithStringAndSplit(text, "|")
        if #arr == 3 then
            this.dataSourse[#this.dataSourse+1] = text
            qsl_readOrSaveOrAdd(this._path,'a',text.."\n")
            print("add ok", text)
        else
            show("Error 加入词条")
            assert(nil, "Error 加入词条")
        end
    end
    this.save = function()
        for i,v in ipairs(this.dataSourse) do
            if i == 1 then
                qsl_readOrSaveOrAdd(this._path,'w',v.."\n")
            else
                qsl_readOrSaveOrAdd(this._path,'a',v.."\n")
            end
        end
    end
    this.pop = function()
        table.remove(this.dataSourse, #this.dataSourse)
        this.isChange = true
        -- this.save()
    end

    return this
end

function qsc_pasteWithString(subText, obj)
    qslPasteWithString(obj.replaceUnderline(subText))
    -- 加法
    for i , v in ipairs(obj.dataSourse) do
        local arr = arrayWithStringAndSplit(v, "|")
        if subText == arr[3] then
            local temp = obj.dataSourse[i]
            obj.dataSourse[i] = (arr[1] + 1).."|"..arr[2].."|"..arr[3]
            break
        end
    end
    obj.isChange = true
    -- obj.save()
end

function qsc_chooer()
    if not qsc_chooser_Obj then qsc_chooser_Obj = QSC_Chooser() end

    local obj = qsc_chooser_Obj
    table.sort(obj.dataSourse, function(a, b)
        local arr1 = arrayWithStringAndSplit(a, "|")
        local arr2 = arrayWithStringAndSplit(b, "|")
        return tonumber(arr1[1]) > tonumber(arr2[1])
    end)
    local choices = {}

    for i, v in ipairs(obj.dataSourse) do
        local arr = arrayWithStringAndSplit(obj.dataSourse[i], "|")
        choices[#choices+1] = {text = arr[2], subText = arr[3]}
        -- choices[#choices+1] = {text = arr[1].."|"..arr[2], subText = arr[3]}
    end

    qsl_chooser(choices,
    function(chosen)
        if chosen then
            local subText = chosen["subText"]
            if subText then qsc_pasteWithString(subText, obj)end
        end
    end)
end

-- "⇪ + A    加入词条"
function qac_add_text()
    if not qsc_chooser_Obj then qsc_chooser_Obj = QSC_Chooser() end

    local window = hs.window.focusedWindow()
    hs.application.launchOrFocus("hammerspoon")
    local ok, deleteLast = "OK", "delete last"
    local title = [[x class
                    f func & method
                    b block
                    @ property
                    m comment
                    # pragma
                    c syntax
                    g gcd
                    s string
                    n NS
                    u UI
                    k mac static NS_ENUM NS_OPTIONS]]
    local ret, text = hs.dialog.textPrompt("message", title," | ",
     ok, deleteLast)

    if ret == ok then
        qsc_chooser_Obj.add("0|"..text)
        -- if window then window:focus() end
    elseif ret == deleteLast then
        -- 提示 是否 删除
        local w = 200
        local deleteStr = "删除"
        local blockAlert = hs.dialog.blockAlert("提示", "是否删除最后一条snippets", "取消", deleteStr, "NSCriticalAlertStyle")
        if deleteStr == blockAlert then
            print("删除了最后一条snippets")
            qsc_chooser_Obj.pop()
        else
            print("取消 删除了最后一条snippets")
        end
    end
    if window then window:focus() end
end

-- //———————————————————————————— net search split line ————————————————————————————
-- Anycomplete
function qsc_anycomplete()
    local URL = "http://api.bing.com/qsonhs.aspx?type=cb&q=%s&cb=window.bing.sug"
    local current = hs.application.frontmostApplication()
    local tab = nil
    local copy = nil
    local choices = nil

    local chooser = hs.chooser.new(function(choosen)
        if copy then copy:delete() end
        if tab then tab:delete() end
        current:activate()
        if choosen then hs.eventtap.keyStrokes(choosen.text) end
    end)

    -- Removes all items in list
    function reset() chooser:choices({}) end

    tab = hs.hotkey.bind('', 'tab', function()
        local id = chooser:selectedRow()
        local item = choices[id]
        -- If no row is selected, but tab was pressed
        if not item then return end
        chooser:query(item.text)
        reset()
        updateChooser()
    end)

    copy = hs.hotkey.bind('cmd', 'c', function()
        local id = chooser:selectedRow()
        local item = choices[id]
        if item then
            chooser:hide()
            hs.pasteboard.setContents(item.text)
            hs.alert.show("Copied to clipboard", 1)
        else
            hs.alert.show("No search result to copy", 1)
        end
    end)

    function updateChooser()
        local string = chooser:query()
        local query = hs.http.encodeForQuery(string)
        -- Reset list when no query is given
        if string:len() == 0 then return reset() end

        hs.http.asyncGet(string.format(URL, query), nil, function(status, data)
            if not data then
                show("NOdata")
                return
            end

            local from, to = string.find(data, "window.bing.sug%(")
            local str = string.sub(data, to+1, #data)

            from, to = string.find(str, "pageview_candidate")
            str = string.sub(str, 1, from - 4 )
            -- print(str)
            local ok, results = pcall(function() return hs.json.decode(str) end)
            if not ok then return end

            local json = results["AS"]["Results"][1]["Suggests"]
            -- printTab(json)
            choices = hs.fnutils.imap(json, function(result)
                return { ["text"] = result["Txt"], }
            end)

            chooser:choices(choices)
        end)
    end

    chooser:queryChangedCallback(updateChooser)
    chooser:searchSubText(false)
    chooser:show()
end

function qsc_v2exRequest()
    local chooser = hs.chooser.new(function(choosen)
        local http = choosen['arg']
        if http and string.find(http, "http") then
            hs.osascript.applescript([[tell application "Safari"
                        activate
                        delay 0.2
                        open location "]]..http..[["
                    end tell ]])
        end
    end)
    --   https://www.v2ex.com/api/topics/latest.json
    hs.http.asyncGet('https://www.v2ex.com/api/topics/hot.json', nil, function(status, data)
        if status ~= 200 then return end
        local decoded_data = nil
        pcall(function() decoded_data = hs.json.decode(data) end)

        if decoded_data and #decoded_data > 0 then
            local chooser_data = hs.fnutils.imap(decoded_data, function(item)
                local sub_content = string.gsub(item.content, "\r\n", " ")
                if utf8.len(sub_content) > 40 then
                    sub_content = string.sub(sub_content, 1, utf8.offset(sub_content, 40)-1)
                end
                return {text=item.title, subText=sub_content, arg=item.url}
            end)

            chooser:choices(chooser_data)
            chooser:refreshChoicesCallback()
            chooser:show()
        end
    end)
end

function qsc_youdaoInstantTrans()

    local youdao_keyfrom = 'hsearch'
    local youdao_apikey = '1199732752'
    local URL = 'http://fanyi.youdao.com/openapi.do?keyfrom='..youdao_keyfrom..'&key='..youdao_apikey..
        '&type=data&doctype=json&version=1.1&q=%s'

    local current = hs.application.frontmostApplication()
    local tab = nil
    local copy = nil
    local choices = {}

    local chooser = hs.chooser.new(function(choosen)
        if copy then copy:delete() end
        if tab then tab:delete() end
        current:activate()
        if choosen then hs.eventtap.keyStrokes(choosen.text) end
    end)

    -- Removes all items in list
    function reset() chooser:choices({}) end

    tab = hs.hotkey.bind('', 'tab', function()
        local id = chooser:selectedRow()
        print("id ", id)
        local item = choices[id]
        -- If no row is selected, but tab was pressed
        if not item then return end
        chooser:query(item.text)
        reset()
        updateChooser()
    end)

    copy = hs.hotkey.bind('cmd', 'c', function()
        local id = chooser:selectedRow()
        local item = choices[id]
        if item then
            chooser:hide()
            hs.pasteboard.setContents(item.text)
            hs.alert.show("Copied to clipboard", 1)
        else
            hs.alert.show("No search result to copy", 1)
        end
    end)

    function basic_extract(arg) if arg then return arg.explains else return {} end end
    function web_extract(arg)
        if arg then return hs.fnutils.imap(arg, function(item) return item.key .. table.concat(item.value, ",") end) end
        return {}
    end

    function updateChooser()
        local string = chooser:query()
        local query = hs.http.encodeForQuery(string)
        -- Reset list when no query is given
        if string:len() == 0 then return reset() end

        hs.http.asyncGet(string.format(URL, query), nil, function(status, data)
            if not data then show("NOdata") return end
            if status ~= 200 then return end
            -- print(str)
            local ok, results = pcall(function() return hs.json.decode(data) end)
            if not ok then return end

            if results.errorCode == 0 then
                local basictrans = basic_extract(results.basic)
                local webtrans = web_extract(results.web)
                local dictpool = hs.fnutils.concat(basictrans, webtrans)
                if #dictpool > 0 then
                    choices = hs.fnutils.imap(dictpool, function(item)
                        return {text=item}
                    end)
                    chooser:choices(choices)
                end
            end
        end)
    end

    chooser:queryChangedCallback(updateChooser)
    chooser:searchSubText(false)
    chooser:show()
end

--
-- function catcher(event)
--
--     local dict = {
--         k = function() show("press K") end,
--         h = function() show("press H") end,
--         j = function() show("press J") end,
--     }
--     for k,v in pairs(dict) do
--         if event:getFlags()['fn'] and event:getCharacters() == k then v() end
--     end
-- end
-- fn_tapper = hs.eventtap.new({hs.eventtap.event.types.keyDown}, catcher):start()
--
--

--
