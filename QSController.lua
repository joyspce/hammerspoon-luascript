-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/12/24 17:58
-- Use    :
-- Change :


inspect = require("QSCode/QSLib/inspect")
-- /*
--  []             表示一个字符 [12345] 表示这一个位置上可以是1,2,3,4,5  一位
--  {}             表示一个范围 {1,9}   表示1到9这么一段
--  [a-z]          表示a~z
--  [0-9]          表示0~9 或者 \d ,为了防止转义 \\d
--  ^[a-z]         表示首字母必须是a~z
--  \d{2,10}       表示数字有2到10个
--  [a-z]$         表示必须以a-z的字母结尾
--  [^0-9]         表示不能是0-9
--  .              表示任意字符/数字/符号
--  *              表示个数不定
--  ?              表示就近匹配
--  */
-- function array(string, pattern)
-- inspect(regular.array("asd11avasvadv231414as", "\\d\\d\\d"))
-- function replace(str, pattern, replace) <- string
-- regular.replace("<xml encoding=\"abc\"></xml><xml encoding=\"def\"></xml>",
-- "(encoding=\")[^\"]+(\")", "$1utf-8$2")

-- function evaluateWithString(str, format, predicate)
-- regular.evaluateWithString("是否包含中文开始", "SELF MATCHES %@", [[.+[\u4e00-\u9fa5].+]])

regular = require('QSRegular')

for i, _require in ipairs({
    "QSCode/QSLib/QSLib",    --我的库
    "QSCode/QSLib/QSHSLib",  -- HS Library
    "QSCode/QSLib/QSAlgorithm", -- 算法 list steak queue

    "QSCode/QSConfig",
    "QSCode/ModalMgr",
    "QSCode/WindowManager", -- window

    "QSCode/Pasteboard/Pasteboard",
    "QSCode/Pasteboard/OCCode",
    "QSCode/Pasteboard/Comment",
    "QSCode/Pasteboard/TempSnippet",
    "QSCode/Pasteboard/ClipShow",
    "QSCode/Pasteboard/LanguageSyntax",
    "QSCode/Pasteboard/Snippets",
    "QSCode/Pasteboard/RegularExpression",

    "QSCode/KeyOperation",

    -- widgets
    "QSCode/widgets/Analogclock",          --analogclock插件
    "QSCode/widgets/TomatoTime",
    "QSCode/widgets/StockChinese",

    "QSCode/widgets/Other",
    "QSCode/widgets/QSTimer",
    "QSCode/widgets/QSChooser",

    "QSCode/QSOpenSoftAndShell",

    "QSCode/QSStringEdit",

    -- "QSCode/Test/QSTest",

    "QSCode/Language/QSOCLuanageTemplate",
    "QSCode/Language/QSSwiftLuanageTemplate",
    "QSCode/Language/QSLuaLuanageTemplate",
    "QSCode/Language/QSPythonLuanageTemplate",

     }) do
    require(_require)
end

-- ctrl.add("⇪ + ⇪  Tap capslock is Esc in iTerm2 终端 Atom")
-- ctrl.add("⇪ + ⇪  Tri click capslock trun on or off")
local doubleClickCapslockCount = 0
local function doubleClickCapslockEqualEsckey()
    doubleClickCapslockCount = doubleClickCapslockCount + 1
    hsDelayedFn(0.22, function()
        if not hyperyKey.triggered then
            if doubleClickCapslockCount == 1 then
                doubleClickCapslockCount = 0
                hsIsWindowWithAppNamesFn({"iTerm2", "终端", 'Terminal', "Atom", "hammerspoon"}, nil,
                    function()
                        koKeyStroke({}, 'escape')
                    end)
            elseif doubleClickCapslockCount > 2 then
                doubleClickCapslockCount = 0
                -- 大小写
                hs.hid.capslock.set(not hs.hid.capslock.get())
            end
        end
        hsDelayedFn(0.22, function() doubleClickCapslockCount = 0 end)
    end)
end

-- // ———————————————————————————— change keys ————————————————————————————
hyperyKey = hs.hotkey.modal.new({}, "F17")
hs.hotkey.bind({}, 'F18',
    function()
        hyperyKey.triggered = true
        hyperyKey:enter()
        doubleClickCapslockEqualEsckey()
    end,
    function()
        hyperyKey.triggered = false
        hyperyKey:exit()
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

local onceMultClick = 0
local delay = nil
local lastTime = 0
local function multClick(funcs)
    local funcs = funcs
    if not funcs then show("double click Error") return end

    onceMultClick = onceMultClick + 1;
    local waitTime = 0.4
    if (onceMultClick == 1) then
        lastTime = hs.timer.secondsSinceEpoch()

        delay = hsDelayedFn(waitTime, function()

            if onceMultClick >#funcs then onceMultClick = #funcs end
            print("onceMultClick :", onceMultClick)
            local run = funcs[onceMultClick]

            onceMultClick = 0
            delay = nil
            if (type(run) == "string") then
                hs.application.launchOrFocus(run)
            else
                run()
            end
        end)
    end
    delay:setDelay(waitTime + (hs.timer.secondsSinceEpoch() - lastTime))
end

function QSController()

    local s = {}

    -- property
    s.titles = {}

    local languageIndex  = QSConfig().config.localIndex
    -- method
    s.addTitle = function(title)
        if title then
            if type(title) == 'table' then title = title[languageIndex] end
            s.titles[#s.titles + 1] = "   *****  "..title.."  *****"
        else
            s.titles[#s.titles + 1] = ""
        end
    end

    -- ctrl.add("a",         "Next moniter full size", wmMoveToNextMoniterFullSize)
    -- ctrl.add({'Right',"→"}, "MoveToRight",  wmMovetoRight)
    -- ctrl.add('q',   "1.显示空间栏 2.Cheatsheet", {wmShowSpaceBar, function() wmShowSpaceBar(true) end})

    s.addLabel = function(key, keys, detail)

        if not detail then return end

        if type(detail) == 'table' then detail = detail[languageIndex] end

        if type(keys) == "table" then
            s.titles[#s.titles + 1] = key.. keys[2].."|" .. detail
        elseif #keys == 1 then
            s.titles[#s.titles + 1] = key.. string.upper(keys) .."|".. detail
        end
    end

    s.addKeys = function(hypery, mods, keys, func, func2)

        local run = nil

        if func then

            local action = func
            local actionType = type(func)

            if actionType == "table" then
                action = function() multClick(func) end
            elseif actionType == "string" then
                action = function() hs.application.launchOrFocus(func) end
            end

            run = function()
                if _MenuView and action ~= showMenuTips then
                    _MenuView.remove()
                    _MenuView = nil
                end

                action()
            end
        end

        if type(keys) == "table" then
            hypery:bind(mods, keys[1], run, func2)
        else
            hypery:bind(mods, keys,    run, func2)
        end
    end

    -- ⇪ hyperyKey:bind({}, keys[1], func1, func2)
    s.add = function(keys, detail, func, func2)
        -- ctrl.add("⇪ + ⇪   Tri click capslock trun on or off")
        if detail or func or func2 then
            ---- * 01
            s.addLabel("⇪ + ", keys, detail)
            --- * 02
            s.addKeys(hyperyKey, {}, keys, func, func2)
        else
            s.titles[#s.titles + 1] = keys
        end
    end
    -- ⌥ hyperyKeyAlt:bind({}, key, func1, func2)
    s.addAlt = function(keys, detail, func, func2)
        if detail or func or func2 then
            ---- * 01
            s.addLabel("⌥ + ", keys, detail)
            --- * 02
            s.addKeys(hyperyKeyAlt, {}, keys, func, func2)
        else
            s.titles[#s.titles + 1] = keys
        end
    end
    -- ⇧ hyperyKey:bind({'shift'}, key, func, func2)
    s.addShift = function(keys, detail, func, func2)
        if detail or func or func2 then
            ---- * 01
            s.addLabel("⇪+⇧+", keys, detail)
            --- * 02
            s.addKeys(hyperyKey, {'shift'}, keys, func, func2)
        else
            s.titles[#s.titles + 1] = keys
        end
    end

    return s
end


--
