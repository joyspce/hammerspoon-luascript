-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/26 22:23
-- Use    : init 入口
-- Change :
--
-- 1136548


-- https://github.com/superzcj/ZCJTemplateTool

-- 最后更新日期
local qsK_upDateLastDate = '2018/12/27'

hs.hotkey.alertDuration=0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0
hs.brightness.set(85)


-- hello i'm joys, welcome you to wacth my vedio,
-- today i'm showing what's on my deck,  This's my first vedio, look

--
-- popup_close_on_escape = true
-- popup_style = hs.webview.windowMasks.utility|hs.webview.windowMasks.HUD|hs.webview.windowMasks.titled|hs.webview.windowMasks.closable
-- webview=hs.webview.new({x = 100, y = 100, w = 300, h = 300})
--    :allowTextEntry(true)
--    :windowStyle(popup_style)
--    :closeOnEscape(popup_close_on_escape)
--
-- webview:url('https://www.sohu.com')
--       :bringToFront()
--       :show()
-- webview:hswindow():focus()


-- AClock.spoon show time in screen center(11:30)
-- BingDaily.spoon wallpaper in bing
-- ClipboardTool.spoon/ 有点用

require "QSController"

ctrl = QSController()

ctrl.addTitle({'Window Manager', '窗 口 管 理'}) --- WindowManager
-- param (keys, detail, func)
ctrl.add("a",          'Next moniter full size',    wmMoveToNextMoniterFullSize)
ctrl.add('w',          'Next moniter same size',    wmMoveToNextMoniterSameSize)

ctrl.add({0x31,  "□"}, {'APP Full or Fit', '窗口最大化or合适大小'}, wmScreenFullOrMiddle)

ctrl.add({'Left',  '⇠'}, 'Move APP To Left',   wmMovetoLeft)
ctrl.add({'Right', '⇢'}, 'Move APP To Right',  wmMovetoRight)

ctrl.add({'1', '1-4'}, {'Move App to desktop 1-4','移动当前APP到桌面 1-4'},
                            function() wmMoveToWhichWindow(1) end)
ctrl.add('2',          nil, function() wmMoveToWhichWindow(2) end)
ctrl.add('3',          nil, function() wmMoveToWhichWindow(3) end)
ctrl.add('4',          nil, function() wmMoveToWhichWindow(4) end)

ctrl.add('q',   {'1.show Mission Control 2.Cheatsheet','1.显示空间栏 2.Cheatsheet'},
    {wmShowSpaceBar, function() wmShowSpaceBar(true) end})

ctrl.add('r',   '1.Window Edit Cheatsheet', wmWindowEditMode)
ctrl.add({'tab', 'tab'}, {'show 1.currentApp 2.App name', 'show 1.当前APP 2.App name'},
    {hs.hints.windowHints, wmShowCurrentAppName})

ctrl.add('m',   '1.Mouse 2.FocusNextMoniter', {wmMouseHighlight, wmFouseNextMoniter})

ctrl.addTitle()
ctrl.addTitle({'Pasteboard', '粘 贴 板'})

ctrl.add('c',  'ClipShow Cheatsheet',        nil, ClipShow)
ctrl.add('x',  'Language syntax Cheatsheet', nil, LanguageSyntax)
ctrl.add('z',  'Regular Expression',         nil, RegularExpression)

ctrl.add('v',  'Snippets Code Cheatsheet',   nil, Snippets)
-- TempSnippet.lua
ctrl.add('t',  '1.TempSnippet 2.Cheatsheet', {tempSnippetOutput, tempSnippetOutputCheatsheet})

ctrl.addTitle()

-- OCCode.lua
-- set get
ctrl.add('s',  '1.Set 2.@Property', {occXcodeSet, occCustomProperty})
-- get
ctrl.add('g',  '1.Get',  occXcodeGet)
-- Pasteboard.lua
ctrl.add('e',   {'1.Align= @method', '对齐= @method'}, pbAlignString)


-- Comment.lua
ctrl.add(      {0x2c, '/' }, {'Comment 1./2. 2.Cheatsheet','注释 1./2./3 2.Cheatsheet'},
    {comment123,  commentShow})
ctrl.addShift( {0x2c, '/'}, {'Comment function','注释 function'}, functionCommentDiscription)

ctrl.addTitle()
ctrl.addTitle({'Key Operation','键 盘 操 作'})
ctrl.add('h',  {'key H← J↓ K↑ L→','键盘 H左← J下↓ K上↑ L右→'},
                    nil, function() koStrokeDown('Left')  end)
ctrl.add('j',  nil, nil, function() koStrokeDown('Down')  end)
ctrl.add('k',  nil, nil, function() koStrokeDown('Up')    end)
ctrl.add('l',  nil, nil, function() koStrokeDown('Right') end)
-- next word
ctrl.add('f',  'select next ', nil, function()
    hsInAppNameAndFunc({['Atom'] = function()
         koKeyStroke({'alt'}, 'f')
    end})
end)
-- before word
ctrl.add('b',  'before word', nil, function()
    hsInAppNameAndFunc({['Atom'] = function()
         koKeyStroke({'alt'}, 'b')
    end})
end)

-- cut one line
ctrl.add('y',  'Cut one line', nil, function()
    hsInAppNameAndFunc({['Atom'] = function()
         koKeyStroke({'cmd'}, 'x')
    end})
end)
-- cut before in line
ctrl.add('u',  'cut before', nil, function()
    hsInAppNameAndFunc({['Atom'] = function()
        koKeyStroke({'ctrl', 'shift'}, 'a')
        koKeyStroke({'cmd'}, 'x')
    end})
end)
ctrl.add('i',  'after in line', nil, function()
    hsInAppNameAndFunc({['Atom'] = function()
        koKeyStroke({'ctrl'}, 'k')
    end})
end)
-- Cut word
ctrl.add('o',  'Cut word', nil, function()
    hsInAppNameAndFunc({['Atom'] = function()
         koKeyStroke({'ctrl', 'shift'}, 'w')
         koKeyStroke({'cmd'}, 'x')
    end})
end)
-- delete before char
ctrl.add('p',  'delete before [ after char', nil, function()
    hsInAppNameAndFunc({['Atom'] = function()
         koKeyStroke({'ctrl'}, 'h')
    end})
end)
-- delete after char
ctrl.add('[',  nil, nil, function()
    hsInAppNameAndFunc({['Atom'] = function()
         koKeyStroke({'ctrl'}, 'd')
    end})
end)
ctrl.add({51,  '⌫'}, {'Delete line','删除一行 或块'},     nil,
    function ()
        koKeyStroke({'cmd'}, 51)
    end)
-- QSController.lua
ctrl.add('⇪ + ⇪  Tap ⇪ = Esc Atom&iTerm2')
ctrl.add('⇪ + ⇪  Tri click ⇪ trun on')
-- KeyOperation.lua
ctrl.add('d', {'mouse Tap','鼠标左键点下'}, koMouseDown, koMouseUp)

ctrl.addTitle()
ctrl.add('6',  {'keyStrokes string','输入粘贴板内String'}, nil,
    function()
        local text = hs.pasteboard.getContents()
        if text and #text > 0 then
            hsDelayedFn(0.5, function() hs.eventtap.keyStrokes(text) end)
        end
    end)
-- 重复自动操作键盘  -- time时间 times次数 ...键盘Keys
ctrl.add('7',  {'AutoKeys s t key1 2...', 'AutoKeys 秒 次数 key1 2...'},
koStrokeInEditByPasteboard)

ctrl.add('8',  'tmux 1.o 2.n 3.new window',
    {koTmux_o_next, koTmux_n_next, koTmux_n_createWindow})
ctrl.add('9',  'tmux 1.vertic 2.horizon',
    {koTmux_split_vertical, koTmux_split_horizontally})

ctrl.addTitle()
ctrl.addTitle({'Widgets & Chooser','插 件 & Chooser'})
-- Widgets
ctrl.add('n',  '1.chooserSnippet 2.add text', {qac_chooserSnippet, qac_add_text})
ctrl.add({0x24, '↩'}, '1.youdao 2.anycomplete', {qsc_youdaoInstantTrans, qsc_anycompleteChooser})
ctrl.add(';',  'V2EX Hot New', qsc_v2exChooser)
ctrl.add('\\', {'1.Countdown 2.Countdown', '2.番茄时间 1.倒计时 '}, {runTomatoTime, qst_timer})

ctrl.addTitle()
ctrl.addTitle({'frequent software' ,'常用 软件'})

ctrl.addAlt('x',  '1.Xcode 2.XMind ZEN', {'Xcode', 'XMind ZEN'})
ctrl.addAlt('a',  '1.Atom 2.AppCleaner', {'Atom', 'AppCleaner'})
ctrl.addAlt('u',  'Arduino', 'Arduino')
ctrl.addAlt('i',  '1.Quiver 2.Dash', {'Quiver','Dash'})
ctrl.addAlt('f',  {'1.PP Helper 2.iToolsPro','1.PP助手 2.iToolsPro'}, {'PP助手', 'iTools Pro'})
ctrl.addAlt('j',  {'Notes', '备忘录'}, 'Notes')
ctrl.addAlt('s',  '1.Safari 2.Cheatsheet', {'Safari', qsoSafariCheatsheet})
ctrl.addAlt('r',  'Recents', 'RecentsF')
ctrl.addAlt('e',  '1.PyCharm 2.010 Editor', {'PyCharm', '010 Editor'} )
ctrl.addAlt('w',  {'1.WeChat, 2.QQ','1.微信 2.QQ'}, {'WeChat', 'QQ'})
ctrl.addAlt('v',  '1.VMware Fusion 2.VNC', {'VMware Fusion', 'VNC Viewer'})
ctrl.addAlt({',',   '<'}, {'1.Preferences 2.Activity Monitor','1.系统设置 2.Activity Monitor'},
    {'System Preferences', 'Activity Monitor'})
ctrl.addAlt({ 0x2f, '>'}, '1.system Console 2.HS Console', {'Console', hs.toggleConsole})
ctrl.addTitle()
ctrl.addAlt({ 0x24, '↩'}, {'Open otherSoft Cheatsheet','Open 其他 软件 Cheatsheet'},
    qsoOpenOtherSoftWare)
ctrl.addAlt({ ';',  ':'}, 'Open 1.Shell 2.Cheatsheet',
    {function() hs.application.launchOrFocus('Terminal') end, qsoOpenShellCheatsheet})

ctrl.addTitle()
ctrl.addTitle({'File Operation','文件操作'})

ctrl.addAlt('d',  'Floder Downloads',
    function() hsOpenFolder(os.getenv("HOME")..'/Downloads/') end)
ctrl.addAlt('l',  'Floder 1.Learn 2.Work', {
    function()  hsOpenFolder('/Volumes/WorkDisk/Learn学习/') end,
    function() hsOpenFolder('/Volumes/WorkDisk/Work工作/') end
})

local iterFn, dirObj = hs.fs.dir("/Volumes")
local diskPaths = {}
if iterFn then
    for file in iterFn, dirObj do
        if file ~= '.' and file ~= '..' then diskPaths[#diskPaths + 1] = file end
    end
    table.sort(diskPaths, function(a, b) return a > b end)
end
for i, disk in ipairs(diskPaths) do
    ctrl.addAlt(tostring(i), 'Disk : '..disk, function() hsOpenFolder('/Volumes/'..disk) end)
end

ctrl.addAlt({51, '⌫'}, {'Trash can 1.Open 2.Clear','垃圾筒 1.打开 2.清空'},
    {qsaOpenTrash, qsaDumpTrash})

ctrl.addAlt('n', 'New 1.Floder2.txt3.shell', {qsaNewFloder, qsaNewFile, qsa_NewShellTemplate})
ctrl.addAlt('p', {'Copy current path', '复制当前路径'}, qsaCopyCourrentPath)
--
ctrl.addTitle()
ctrl.addTitle({'Other Operation','其他操作'})

function showMenuTips()
    if _MenuView then
        _MenuView.remove()
        _MenuView= nil
        return
    end
    MenuView(ctrl.titles)
end
ctrl.addAlt({'\\', '\\'}, {'QS hotkey hint','QS快捷键提示'}, showMenuTips) --0x2a

ctrl.addAlt({0x31,  "□"}, 'Keyboard Sheet',
    function()
        if _keyboard then
            _keyboard:hide()
            _keyboard.escKey:delete()
            _keyboard = nil
        else
            _keyboard = require "QSCode/widgets/KSheet"
            _keyboard:init()
            _keyboard:show()
            _keyboard.escKey = hs.hotkey.bind('', 'escape', "exit menus", function()
                _keyboard:hide()
                _keyboard.escKey:delete()
                _keyboard = nil
            end)
        end
    end)
ctrl.addAlt('c', 'ColorPicker Sheet',
    function()
        if not _ColorPicker then
            _ColorPicker = require "QSCode/widgets/ColorPicker"
            _ColorPicker:start()
        end
        _ColorPicker.choosermenu:popupMenu(hs.mouse.getAbsolutePosition())
    end)

ctrl.addAlt({ 'Left', '←'}, 'Safari back  →Safari next',
    function()
        hsIsWindowWithAppNamesFn({'Safari 浏览器', 'Safari'}, 'Error : 我不在 Safari 下',
            function() hs.eventtap.keyStroke({'cmd'}, '[') end)
    end)
ctrl.addAlt('Right', nil,
    function()
        hsIsWindowWithAppNamesFn({'Safari 浏览器', 'Safari'}, 'Error : 我不在 Safari 下',
            function() hs.eventtap.keyStroke({'cmd'}, ']')
    end)
end)
g_isOpenKeyMoniter = false
ctrl.addShift('k', 'is Open KeyMoniter', function()
    if g_isOpenKeyMoniter then
        g_isOpenKeyMoniter = false
        show('Key Moniter is close')
    else
        g_isOpenKeyMoniter = true
        show('Key Moniter is open')
    end
end)
ctrl.addShift('l', 'Lua Header Class Make', QSLuaLuanageTemplate)
ctrl.addShift('m', {'SystemSleep','系统休眠'}, hs.caffeinate.systemSleep)
ctrl.addShift('r', {'DoubleClickRestartSystem', '双击 系统重机'},
    {function() show(qscLang('Double click restartSystem','双击 系统重机')) end,  hs.caffeinate.restartSystem})
ctrl.addShift('s', {'DoubleClickShutdownSystem', '双击 系统关机'},
    {function() show(qscLang('Double click shutdownSystem', '双击 系统关机')) end,  hs.caffeinate.shutdownSystem})
ctrl.addShift('q', {'DoubleClickLogOut', '双击 退出登录'},
    {function() show(qscLang('Double click logOut','双击 退出登录')) end,  hs.caffeinate.logOut})

ctrl.addShift('c', '1.reload2.Code3.Language',
    {
    hs.reload,
    function()
        local cfg = QSConfig()
        cfg.changeprograms()
        ctrl.titles[#ctrl.titles] =
            qscLang('current Programe : ','当前编程语言 : ')..cfg.programs[cfg.config.programsIndex]
    end,
    function() QSConfig().changeLocal() end })

ctrl.addShift('l', 'Lua Header Class Make', QSLuaLuanageTemplate)

ctrl.addTitle()

ctrl.titles[#ctrl.titles + 1] = 'host :'.. hs.host.localizedName()
qsK_upDateLastDate = qscLang('Last update :' ,'最后更新日期 :').. qsK_upDateLastDate
ctrl.titles[#ctrl.titles + 1] = qsK_upDateLastDate
-- 支持语言
local cfg = QSConfig()
ctrl.titles[#ctrl.titles + 1] =
    qscLang('current Programe:','当前编程语言 :')..cfg.programs[cfg.config.programsIndex]

-- autoRun

require "QSCode/widgets/Weather"
require "QSCode/widgets/ShowBoard"
require "QSCode/QSWatch"

local g_char = ""
local function catcher(event)
    local char = event:getCharacters()

    if g_isOpenKeyMoniter and #char == 1 and g_char ~= char then
        g_char = char
        -- hs.execute('curl http://192.168.88.103/'..string.byte(char))
        hs.http.asyncGet('http://192.168.88.103/'..string.byte(char), nil, function() end)
    end

    if event:getFlags()['fn'] and char == "h" then
        return true, {hs.eventtap.event.newKeyEvent({}, "left", true)}
    elseif event:getFlags()['fn'] and char == "l" then
        return true, {hs.eventtap.event.newKeyEvent({}, "right", true)}
    elseif event:getFlags()['fn'] and char == "j" then
        return true, {hs.eventtap.event.newKeyEvent({}, "down", true)}
    elseif event:getFlags()['fn'] and char == "k" then
        return true, {hs.eventtap.event.newKeyEvent({}, "up", true)}
    elseif event:getFlags()['fn'] and char == "y" then
        return true, {hs.eventtap.event.newScrollEvent({3, 0}, {}, "line")}
    elseif event:getFlags()['fn'] and char == "o" then
        return true, {hs.eventtap.event.newScrollEvent({-3, 0}, {}, "line")}
    elseif event:getFlags()['fn'] and char == "u" then
        return true, {hs.eventtap.event.newScrollEvent({0, -3}, {}, "line")}
    elseif event:getFlags()['fn'] and char == "i" then
        return true, {hs.eventtap.event.newScrollEvent({0, 3}, {}, "line")}
    elseif event:getFlags()['fn'] and char == "," then
        local currentpos = hs.mouse.getAbsolutePosition()
        return true, {hs.eventtap.leftClick(currentpos)}
    elseif event:getFlags()['fn'] and char == "." then
        local currentpos = hs.mouse.getAbsolutePosition()
        return true, {hs.eventtap.rightClick(currentpos)}
    end
end
fn_tapper = hs.eventtap.new({hs.eventtap.event.types.keyDown}, catcher):start()

show('Reloaded successful update :'..qsK_upDateLastDate)




--
