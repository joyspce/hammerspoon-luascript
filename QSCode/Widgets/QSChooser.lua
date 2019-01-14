
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

qsc_ChooserDatasource = nil

-- hs.shutdownCallback = function()
--     local chooser = qsc_ChooserDatasource
--     if chooser then
--         chooser.save()
--         print("save")
--     else
--         print("不用save")
--     end
-- end

function QSC_ChooserDatasource()
    if qsc_ChooserDatasource then return qsc_ChooserDatasource end
    local s = {}
    qsc_ChooserDatasource = s

    s._path = hs.configdir.."/script/chooser_datasourse.txt"

    s.dataSourse = qsReadFile(s._path)

    s._replaceEnter = function(str) return string.gsub(str, '\n', '___') end
    s.replaceUnderline = function(str) return string.gsub(str, '___', '\n') end

    s.add = function(str)
        local text = s._replaceEnter(str)
        local arr = qsSplit(text, "|")
        if #arr == 3 then
            s.dataSourse[#s.dataSourse+1] = text
            qsSaveOrAddWithStr(s._path,'a',text.."\n")
            print("add ok", text)
        else
            show("Error 加入词条")
            assert(nil, "Error 加入词条")
        end
    end
    s.save = function()
        for i,v in ipairs(s.dataSourse) do
            if i == 1 then
                qsSaveOrAddWithStr(s._path,'w',v.."\n")
            else
                qsSaveOrAddWithStr(s._path,'a',v.."\n")
            end
        end
    end

    return s
end

function qac_chooserSnippet()
    local s = QSC_ChooserDatasource()

    table.sort(s.dataSourse, function(a, b)
        local arr1 = qsSplit(a, "|")
        local arr2 = qsSplit(b, "|")
        return tonumber(arr1[1]) > tonumber(arr2[1])
    end)

    local choices = {}
    for i, var in ipairs(s.dataSourse) do
        local arr = qsSplit(var, "|")
        choices[#choices+1] = {text = arr[2], subText = arr[3]}
    end

    -- table.insert(id_history, 1, winf)
    hsChooser(choices, function(chosen)
        if chosen then
            local subText = chosen["subText"]
            if subText then
                hsPasteWithString(s.replaceUnderline(subText))
                -- 加法
                for i , v in ipairs(s.dataSourse) do
                    local arr = qsSplit(v, "|")
                    if subText == arr[3] then
                        s.dataSourse[i] = (arr[1] + 1).."|"..arr[2].."|"..arr[3]
                        s.save()
                        break
                    end
                end
            end
        end
    end)
end
function qac_add_text()
    local s = QSC_ChooserDatasource()
    local window = hs.window.focusedWindow()
    hs.application.launchOrFocus("hammerspoon")
    local ok, deleteLast = "OK", "Cancle"
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

    if ret == ok then s.add("0|"..text) s.save() end
    if window then window:focus() end
end

-- //———————————————————————————— net search split line ————————————————————————————

local function chooserClassWithURL(URL)
    local s = {}
    -- 先取得 frontmostApplication
    local current = hs.application.frontmostApplication()
    local hotkeys = {}
    s.dataSource = nil
    s.chooser = hs.chooser.new(function(choosen)
        for i,v in ipairs(hotkeys) do v:delete() end
        current:activate()
        if choosen then hs.eventtap.keyStrokes(choosen.text) end
    end)

    s.reset = function () s.chooser:choices({}) end
    s.updateChooser = nil
    hotkeys[#hotkeys +1] = hs.hotkey.bind('', 'tab', function()
        local id = s.chooser:selectedRow()
        local item = s.dataSource[id]
        -- If no row is selected, but tab was pressed
        if not item then return end
        s.chooser:query(item.text)
        s.reset()
        s.updateChooser()
    end)
    hotkeys[#hotkeys +1] = hs.hotkey.bind('cmd', 'c', function()
        local id = s.chooser:selectedRow()
        local item = s.dataSource[id]
        if item then
            s.chooser:hide()
            hs.pasteboard.setContents(item.text)
            hs.alert.show("Copied to clipboard", 1)
        else
            hs.alert.show("No search result to copy", 1)
        end
    end)

    s.start = function(updateChooser)
        s.updateChooser = updateChooser
        s.chooser:queryChangedCallback(updateChooser)
        s.chooser:searchSubText(false)
        s.chooser:show()
    end
    return s
end
-- 有道词典
function qsc_youdaoInstantTrans()
    local youdao_keyfrom = 'hsearch'
    local youdao_apikey = '1199732752'
    local URL = 'http://fanyi.youdao.com/openapi.do?keyfrom='..youdao_keyfrom..'&key='..youdao_apikey..
        '&type=data&doctype=json&version=1.1&q=%s'
    local s = chooserClassWithURL(URL)
    s.start( function()
        local input = s.chooser:query()
        -- Reset list when no query is given
        if input:len() == 0 then return s.reset() end

        hsHttpAsyncGet(string.format(URL, hs.http.encodeForQuery(input)), function(data)

            local ok, results = pcall(function() return hs.json.decode(data) end)
            if not ok then return end

            if results.errorCode == 0 then
                local basictrans = {}
                if results.basic then
                    basictrans = results.basic.explains or {}
                end
                local webtrans = {}
                if results.web then
                    webtrans = hs.fnutils.imap(results.web, function(item)
                        return item.key .. table.concat(item.value, ",")
                    end)
                end
                local dictpool = hs.fnutils.concat(basictrans, webtrans)
                if #dictpool > 0 then
                    s.dataSource = hs.fnutils.imap(dictpool, function(item) return {text=item} end)
                    s.chooser:choices(s.dataSource)
                end
            end
        end)
    end)
end
-- Anycomplete
function qsc_anycompleteChooser()
    local URL = "http://api.bing.com/qsonhs.aspx?type=cb&q=%s&cb=window.bing.sug"
    local s = chooserClassWithURL(URL)
    s.start(function()
        local input = s.chooser:query()
        -- Reset list when no query is given
        if input:len() == 0 then return s.reset() end

        hsHttpAsyncGet(string.format(URL, hs.http.encodeForQuery(input)), function(data)
            local from, to = string.find(data, "window.bing.sug%(")
            local str = string.sub(data, to+1, #data)

            from, to = string.find(str, "pageview_candidate")
            str = string.sub(str, 1, from - 4 )
            -- print(str)
            local ok, results = pcall(function() return hs.json.decode(str) end)
            if not ok then return end

            local json = results["AS"]["Results"][1]["Suggests"]
            -- qsPrintTable(json)
            s.dataSource = hs.fnutils.imap(json, function(result) return { ["text"] = result["Txt"], } end)
            s.chooser:choices(s.dataSource)
        end)
    end)
end
-- V2EX
function qsc_v2exChooser()
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
    hsHttpAsyncGet('https://www.v2ex.com/api/topics/hot.json', function(body)
        local ok, results = pcall(function() return hs.json.decode(body) end)
        if ok and results and #results then
            local chooser_data = hs.fnutils.imap(results, function(item)
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




--
