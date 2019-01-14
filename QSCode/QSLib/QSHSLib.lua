-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/26 22:22
-- Use    : QSHSLib

function printWindowsInScreen()
    hs.fnutils.each(hs.window.allWindows(), function(win)
    qsPrintTable({
        title   = win:title(),
        app     = win:application():name(),
        role    = win:role(),
        subrole = win:subrole()
    })end)
end
function show(str) hs.alert.show(str) end
function clear() hs.console.clearConsole() end
clear()
function hsPrintHex(str) hs.utf8.hexDump(str) end

-- hs.fnutils.contains(table, element) -> bool
-- Determine if a table contains a given object
-- function isContains(tab, element) return hs.fnutils.contains(tab, element) end

function hsDelayedFn(time, fn)
    local delayed = hs.timer.delayed.new(time, fn)
    delayed:start()
    return delayed
end

--- Table containing the modifiers to be used together with a double-click when `BrewInfo.select_text_if_needed` is true. Defaults to `{cmd = true, shift = true}` to issue a Cmd-Shift-double-click, which will select a continuous non-space string in Terminal and iTerm2.
-- modifiers = {cmd = true, shift = true}
-- Internal function to issue a double click with given modifiers
function leftDoubleClick(modifiers)
   local pos=hs.mouse.getAbsolutePosition()
   hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, pos, modifiers)
      :setProperty(hs.eventtap.event.properties.mouseEventClickState, 2)
      :post()
   hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, pos, modifiers)
      :post()
end
function urlDecode(url)
	return url:gsub('%%(%x%x)', function(x)
		return string.char(tonumber(x, 16))
	end)
end
function hsHttpAsyncGet(url, fu_success, fn_fail)
    hs.http.asyncGet(url, nil, function(status, body, headers)
        if status == 200 then
            fu_success(body)
        elseif fn_fail then
            fn_fail()
        end
    end)
end


-- //——————————————————— file ———————————————————
function hsIsDirectoryExist(path)
    if path then
        local attr = hs.fs.attributes(path)
        return attr and attr.mode == 'directory'
    else
        return false
    end
end
function hsIsFileExist(path)
    if path == nil then return nil end
    local attr = hs.fs.attributes(path)
    if type(attr) == "table" then
        return true
    else
        return false
    end
end

function HSDataSoruce(path)
    local s = {}

    s.path = path
    if not hsIsFileExist(path) then qsSaveOrAddWithStr(path, 'w', '') end

    local jsons = qsReadFile(s.path)

    s.dataSoruce = {}
    for i, str in ipairs(jsons) do
        local tab = hs.json.decode(str)
        s.dataSoruce[i] = tab[1]
    end

    s.length = function() return #s.dataSoruce end

    s.insertStrAtIndex = function(str, index)
        table.insert(s.dataSoruce, index, str)
    end
    s.removeAtIndex = function(index)
        if #s.dataSoruce >= index then
            table.remove(s.dataSoruce, index)
            -- show(#s.dataSoruce)
        end
    end

    s.save = function()
        if #s.dataSoruce == 0 then
            qsSaveOrAddWithStr(s.path, 'w', '')
        else
            for i, str in ipairs(s.dataSoruce) do
                local tab = {str}
                if i == 1 then
                    qsSaveOrAddWithStr(s.path, 'w', hs.json.encode(tab).."\n")
                else
                    qsSaveOrAddWithStr(s.path, 'a', hs.json.encode(tab).."\n")
                end
            end
        end
    end

    s.saveInFristWithStrAndMax = function(str, max)

        s.insertStrAtIndex(str, 1)
        local temp = {str}

        local len = #s.dataSoruce
        for i=1, len do
            local text = s.dataSoruce[i]
            if text ~= str then
                temp[#temp + 1] = text
            end
        end
        s.dataSoruce = temp

        if max then
            while true do
                if s.length() > max then
                    s.removeAtIndex(s.length())
                else
                    break
                end
            end
        end
        s.save()
    end

    return s
end

function hsKeymessageData(text, key)
    local key = key or 'key'
    if text then
        local tab = { key = key, message = 'message', data = text}
        local json = hs.json.encode(tab)
        hsPasteWithString(json)
    end
end

-- // ———————————————————————————— pasteboard 粘贴板 ————————————————————————————

function hsCurrentSelection()
    local elem=hs.uielement.focusedElement()
    local sel=nil
    if elem then
        sel=elem:selectedText()
    end
    if (not sel) or (sel == "") then
        hs.eventtap.keyStroke({"cmd"}, "c")
        hs.timer.usleep(20000)
        sel=hs.pasteboard.getContents()
    end
    return (sel or "")
end

function hsIsSavePasteboard(str)
    if str and #str ~= 0 and hs.pasteboard.writeObjects(str) then return true end
    show("savePasteboard 没保存")
    return false
end
function hsPasteAndWriteBackWithString(str)
    hsDelayedFn(0.15, qsFunction(koKeyStroke,{'cmd'}, 'v')) -- 粘贴
    hsDelayedFn(0.20, function() hsIsSavePasteboard(str) end) -- 写回内存
end
function hsReadPasteboard()
    local str = hs.pasteboard.getContents()
    if str and #str > 0 then return str end
    print("pasteboard empty")
    return ""
end
function hsPasteWithString(str)
    local pasteboard = hsReadPasteboard()
    if str then hsIsSavePasteboard(str) end
    if pasteboard then hsPasteAndWriteBackWithString(pasteboard) end
end

-- // ———————————————————————————— window ————————————————————————————
-- 获取主屏幕高度
qs_mainScreenX = 0
qs_mainScreenY = 0
qs_mainScreenW = 0
qs_mainScreenH = 0

if (qs_mainScreenH == 0) then
    local qs_mainScreen = hs.screen.mainScreen()
    local frame = qs_mainScreen:frame()

    if frame.x > 0 then
        qs_mainScreen = hs.screen.primaryScreen()
        frame = qs_mainScreen:frame()
    end
    qs_mainScreenX, qs_mainScreenY = frame.x, frame.y
    qs_mainScreenW, qs_mainScreenH = frame.w, frame.h
end

function hsInAppNameAndFunc(nameAndfunc)
    local win = hs.window.focusedWindow()
    if not win then return end
    local app = win:application()
    if not app then return end
    for name, func in pairs(nameAndfunc) do
        if app:name() == name then
            func()
            break
        else
            print('hsInAppNameAndFunc :' .. app:name())
        end
    end
end

function hsIsWindowWithAppNamesFn(apps, fn_error, fn)
    local win = hs.window.focusedWindow()
    if win then
        local app = win:application()
        for i,v in ipairs(apps) do
            if (app and app:name() == v) then
                if fn then fn() end
                return true
            end
        end
        if (fn_error) then
            if type(fn_error) == "string" then
                show(fn_error..apps[1])
            else
                fn_error()
            end
        end
    else
        show("没有找到主窗口")
    end
    return false
end

-- //——————————————————— dialog ———————————————————
function hsTextPrompt(message, informativeText, defaultText, actionWithText)
    local window = hs.window.focusedWindow()
    hs.application.launchOrFocus("hammerspoon")
    local _, text = hs.dialog.textPrompt(message, informativeText, defaultText)
    window:focus()
    if actionWithText then
        actionWithText(text)
    end
end

function hsChooser(choices, fn)
    local chooser = hs.chooser.new(fn)
    chooser:choices(choices)
    chooser:subTextColor({green = 0.1, red = 1, blue = 0.1, alpha = 1})
    chooser:width(500)
    chooser:show()
    return chooser
end

-- //——————————————————— shell & script ———————————————————
function hsOpenFolder(str)
    hs.osascript.applescript([[
    tell application "Finder"
        activate
        do shell script "open ]]..str..[["
    end tell
   ]])
end
-- hsTerminalRunInShell
function hsTerminalRunIn(shell)
     hs.osascript.applescript([[tell application "Terminal"
        do script "]]..shell..[["
        activate
     end tell]])
end






--
