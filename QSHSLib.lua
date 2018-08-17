
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com


function show(str) hs.alert.show(str) end
function printHex(str) hs.utf8.hexDump(str) end
function clear() hs.console.clearConsole() end

function qsl_delayedFn(time, fn)
    local ret = hs.timer.delayed.new(time, fn)
    ret:start()
    return ret
end

function qshs_asyncGet(url, fu_body, fn_else)
    hs.http.asyncGet(url, nil, function(status, body, headers)
        if fu_body and status == 200 and body then
            fu_body(body)
        else
            if fn_else then fn_else() end
        end
    end)
end

-- hs.fnutils.contains(table, element) -> bool
-- Determine if a table contains a given object
function contains(tab, element) return hs.fnutils.contains(tab, element) end

-- // ———————————————————————————— change keys ————————————————————————————
hyperyKey = hs.hotkey.modal.new({}, "F17")
hs.hotkey.bind({}, 'F18',
    function()
        hyperyKey.triggered = true
        hyperyKey:enter()
    end,
    function()
        hyperyKey.triggered = false
        hyperyKey:exit()
        if qsk_double_click_capslock_equal_esckey then
            qsk_double_click_capslock_equal_esckey()
        end
    end
)
hyperyKeyAlt = hs.hotkey.modal.new({}, "F19")
hs.hotkey.bind({}, 'F20',
    function()
        hyperyKeyAlt.triggered = true
        hyperyKeyAlt:enter() end,
    function()
        hyperyKeyAlt.triggered = false
        hyperyKeyAlt:exit()
    end
)
-- ⇪
function hyperyKeyBind(key, func1, func2) hyperyKey:bind({}, key, func1, func2) end
-- ⇪ + ⇧
function hyperyKeyShiftBind(key,func) hyperyKey:bind({'shift'}, key, func, nil) end
-- ⌥
function hyperyKeyAltBind(key, func1, func2) hyperyKeyAlt:bind({}, key, func1, func2) end

-- stroke Key
function qsl_keyStroke(mods, key)
    hs.eventtap.event.newKeyEvent(mods, key, true):post()
    hs.eventtap.event.newKeyEvent(mods, key, false):post()
end

-- //———————————————————————————— mouse action ————————————————————————————
function qshs_leftMouseDown(point)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, point):post()
end
function qshs_leftMouseDragged(point)
    hs.eventtap.event.newMouseEvent( hs.eventtap.event.types.leftMouseDragged, point):post()
end
function qshs_leftMouseUp(point)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, point):post()
end

function qshs_mouseTap(point)
    qshs_leftMouseDown(point)
    qsl_delayedFn(0.1, function() qshs_leftMouseUp(point) end)
end

-- // ———————————————————————————— pasteboard 粘贴板 ————————————————————————————
function qshs_isSavePasteboard(str)
    if str and #str ~= 0 and hs.pasteboard.writeObjects(str) then return true end
    show("savePasteboard 没保存")
    return false
end
function qshlPasteAndWriteBackWithString(str)
    qsl_delayedFn(0.15, qs_fn(qsl_keyStroke,{'cmd'}, 'v')) -- 粘贴
    qsl_delayedFn(0.20, function() qshs_isSavePasteboard(str) end) -- 写回内存
end
-- qshs_savePasteboardFn(function(paste) end)
function qshs_savePasteboardFn(fn)
    local paste = hs.pasteboard.getContents() or ""
    qsl_delayedFn(0.1, qs_fn(qsl_keyStroke,{'cmd'}, 'x'))
    qsl_delayedFn(0.2, function()
        local paste2 = hs.pasteboard.getContents() or ""

        if 2 > #paste2 then paste2 = paste end
        if paste2 and #paste2 > 0 then
            local text = fn(paste2)
            if qshs_isSavePasteboard(text) then qshlPasteAndWriteBackWithString(paste) end
        else
            show("Error: 粘贴板中 没数据 qshs_savePasteboardFn")
        end
    end)
end

function qshslReadPasteboard()
    local str = hs.pasteboard.getContents()
    if str and #str > 0 then
        return str
    else
        print("pasteboard empty")
        return ""
    end
end
function qslPasteWithString(str)
    local pasteboard = qshslReadPasteboard()
    if str then qshs_isSavePasteboard(str) end
    if pasteboard then qshlPasteAndWriteBackWithString(pasteboard) end
end

-- // ———————————————————————————— function ————————————————————————————
function _qshsRunApp(obj)
    local typeObj = type(obj)
    if (typeObj == "string") then
        hs.application.launchOrFocus(obj)
    elseif (typeObj == "function") then
        obj()
    else
        print("Error : function qshs_multClick(array) type :"..type(obj))
    end
end

qshsOnceMultClick = 0
local hsDelay = nil
local lastTime = 0
function qshs_multClick(array)
    qshsOnceMultClick = qshsOnceMultClick + 1;
    local waitTime = 0.4
    if (qshsOnceMultClick == 1) then
        lastTime = hs.timer.secondsSinceEpoch()
        hsDelay = qsl_delayedFn(waitTime, function()
            print("qshsOnceMultClick :", qshsOnceMultClick)
            _qshsRunApp(array[ qshsOnceMultClick % (#array + 1) ])
            qshsOnceMultClick = 0
            hsDelay = nil
        end)
    end
    hsDelay:setDelay(waitTime + (hs.timer.secondsSinceEpoch()-lastTime))
end

-- qshslTerminalRunInShell
function qshslTerminalRunIn(shell)
     hs.osascript.applescript([[tell application "Terminal"
        do script "]]..shell..[["
        activate
     end tell]])
end

-- // ———————————————————————————— window ————————————————————————————
-- 获取主屏幕高度
qsl_mainScreenX = 0
qsl_mainScreenY = 0
qsl_mainScreenW = 0
qsl_mainScreenH = 0

if (qsl_mainScreenH == 0) then
    local qsl_mainScreen = hs.screen.mainScreen()
    local frame = qsl_mainScreen:frame()

    if frame.x > 0 then
        qsl_mainScreen = hs.screen.primaryScreen()
        frame = qsl_mainScreen:frame()
    end
    qsl_mainScreenX, qsl_mainScreenY = frame.x, frame.y
    qsl_mainScreenW, qsl_mainScreenH = frame.w, frame.h
end

function qshs_getFocusedWindow()
    local window = hs.window.focusedWindow();
    if not window then show("没有找到主窗口"); end
    return window;
end
-- qshs_getFocusedWindowFn(function(win) end)
function qshs_getFocusedWindowFn(fn)
    local win = qshs_getFocusedWindow()
    if win and fn then fn(win) end
end

function qshs_isWindowWithAppNamesFn(apps, showError, fn)
    local app = qshs_getFocusedWindow():application()
    for i,v in ipairs(apps) do
        if (app and app:name() == v) then
            if fn then fn() end
            return true
        end
    end
    if (showError) then show(showError..apps[1]) end
    return false
end

local qshs_count_launchOrFocus = 0
function qshs_isLaunchOrFocus(app, appNames)
    local win = qshs_getFocusedWindow()
    if win then
        local app = win:application()
        for i,v in ipairs(appNames) do if (v == app:name()) then return true end end
    else
        hs.application.launchOrFocus(app)
    end
    qshs_count_launchOrFocus = qshs_count_launchOrFocus + 1
    if qshs_count_launchOrFocus > 5 then return false end
    qsl_delayedFn(0.3, function() qshs_isLaunchOrFocus(app, appNames) end)
end

-- //——————————————————— dialog ———————————————————
function qsl_textPrompt(message, informativeText, defaultText, actionWithText)
    local window = hs.window.focusedWindow()
    hs.application.launchOrFocus("hammerspoon")
    local _, text = hs.dialog.textPrompt(message, informativeText, defaultText)
    window:focus()
    if actionWithText then
        actionWithText(text)
    end
end
function qsl_chooser(choices, fn)
    local chooser = hs.chooser.new(fn)
    chooser:choices(choices)
    chooser:subTextColor({green = 0.1, red = 1, blue = 0.1, alpha = 1})
    chooser:width(500)
    chooser:show()
    return chooser
end

-- //——————————————————— shell & script ———————————————————
applescript = hs.osascript.applescript

function qssh_openFolder(str)
    applescript([[
    tell application "Finder"
        activate
        do shell script "open ]]..str..[["
    end tell
   ]])
end

-- //——————————————————— file ———————————————————
function doesDirectoryExist(path)
    if path then
        local attr = hs.fs.attributes(path)
        return attr and attr.mode == 'directory'
    else
        return false
    end
end
function doesFileExist(path)
    if path == nil then return nil end
    local attr = hs.fs.attributes(path)
    if type(attr) == "table" then
        return true
    else
        return false
    end
end

function printWindowsInScreen()
  hs.fnutils.each(hs.window.allWindows(), function(win)
    print(inspect({
      title   = win:title(),
      app     = win:application():name(),
      role    = win:role(),
      subrole = win:subrole()
    }))
  end)
end




--
