

-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

QSK_upDateLastDate = "最后更新日期: 2018/07/30"

require "QSConfig"


-- 鼠标左键点下
init_functionWithBack1 = 1
operation_config_kyes = {
    "      ***** pasteboard *****",
    -- set get
    {"s",  "⇪ + S",  "1.Set", qsx_XcodeSet, "2.Get", qsx_XcodeGet, "3.Singleton", qsx_Singleton},
    {'f',  "⇪ + F",  "Mothed 1.obj", qsx_Xcode_ObjMothed, "2.class", qsx_Xcode_classMothed},
    {'e',  "⇪ + E",  "1.Align=property 对齐", qssePasteEditAlignString, "2.JsonModel", qsse_makeObjc_Model},
    {'b',  "⇪ + B",  "1.NSCoding", xcode_NSCoding,  "2.self.xxs", xcode_property_self},
    {'w',  "⇪ + W",  "Hook 1.Tweak",qsseToHookFun, "2.Captain", qsseToHCaptainFunc},

    {0xa,  "⇪ + §",  "1.@property", qsse_customProperty, "2.ChangeStr", qsse_changPasteboardByText},
    {'c',  "⇪ + C",  "1.@\" \"", qssePasteEditStringToNSString, "2.去重复", qssePasteStringRemoveSameString},
    -- comment
    {0x2c, "⇪ + /",  "注释 1.(Time)", qsseComment1, "2.NS", qsseComment2, "3.UI", qsseComment3, "4.C", qsseComment4},
    {0x2a, "⇪ + \\", "注释", qsseComment123, "1./ 2./ 3./", qssClearComment},

    {'i',  "⇪ + I",  "1.OCSnippet", qsc_chooer, "2.加入词条", qac_add_text, "3.InputV", defeating_paste_blocking},
    "",
    "      *****   窗口管理   *****",
    ---- positiont Move
    {0x24,    "⇪ + ↩:", "Next moniter full size", qswMoveScerrnToNextWindow},
    {0x31,    "⇪ + □",  "窗口最大化or合适大小", qswScreenResizeFullOrMiddle},
    {"a",     "⇪ + A",  "提示 1.当前APP", hs.hints.windowHints, "2.MousePoint", qsw_mouseHighlight},
    {'q',     "⇪ + Q",  "显示空间栏", qswShowSpaceBar},
    {'1',     "⇪ + 1-4","移动当前APP到桌面 1-4", moveToWhichWindow(1)},
    {'2',     "⇪", moveToWhichWindow(2)},
    {'3',     "⇪", moveToWhichWindow(3)},
    {'4',     "⇪", moveToWhichWindow(4)},
    {'Up',    "⇪ + ↑",	 "窗口上 ↓窗口下", qswMoveWindowUp},
    {'Down',  "⇪", qswMoveWindowDown},
    {'Left',  "⇪ + ←",  "窗口左 → 窗口右", qswMoveWindowToLeft},
    {'Right', "⇪", qswMoveWindowToRight},
    "",
    "      *****   命 令 行  *****",
    {'d',  "⇪ + D:", "鼠标左键点下", init_functionWithBack1, qsa_leftMouseDownAndDragged, qsa_leftMouseUp},
    {'h',  "⇪ + H",  "显示 1.隐藏文件", qsl_fn_keyStroke({'shift', 'cmd'}, '.'), "2.App name", qsw_showCurrentAppName},
    {'n',  "⇪ + N",  "New 1.Floder", qsaNewFloder, "2.textFile", qsaNewFile, "3.shell", qsa_NewShellTemplate},
    {'p',  "⇪ + P",  "1.复制当前路径", qsaCopyCourrentPath, "2.reloadLua", hs.reload},
    {'g',  "⇪ + G",  "1.v2ex", qsc_v2exRequest, "2.anycomplete", qsc_anycomplete},
    {'m',  "⇪ + M",  "移动COPY文件", qsl_fn_keyStroke({'cmd', 'alt'}, 'v')},
    {'v',  "⇪ + V",  "CopyTo 1.Xcode", qss_copyToXcode, "2.记事本", qss_copyToNotes},
    {'x',  "⇪ + X",  "CopyTo 1.Atom", qss_copyToAtom, "2.Quiver", qss_copyToQuiver},
    {'t',  "⇪ + T",  "1.倒计时", qst_timer, "2.番茄时间", runtomatoTimeManViewager, "3.大小写", qsa_capslock},
    {'y',  "⇪ + Y",  "1.有道词典",qsc_youdaoInstantTrans,"2.多张图片 幻灯片模式", qsl_fn_keyStroke({'cmd', 'alt'}, 'y')},
    "",
    "      *****   编 辑 行  *****",
    -- 重复自动操作键盘  -- time时间 times次数 ...键盘Keys
    {'8',  "⇪ + 8",  "AutoKeys 秒 次数 key1 key2...", qsa_strokeInEditByPasteboard},

    {'j',  "⇪ + J",  "向左 K向右 移动一个单词", qsl_fn_keyStroke({'alt'}, 'Left')},
    {'k',  "⇪", qsl_fn_keyStroke({'alt'}, 'Right')},
    {'l',  "⇪ + L",  "向左 R向右 删除一个单词", qsl_fn_keyStroke({'alt'}, 51)},
    {'r',  "⇪", function() qsl_fn_keyStroke({'alt'},'Right')(); qsl_fn_keyStroke({'alt'}, 51)() end},
    {51,   "⇪ + ⌫",  "删除一行 或块", qsl_fn_keyStroke({'cmd'}, 51)},
    "",
    "      *****  Shift Key   *****",
    {'f', "⇪ + ⇧ + F", "全屏 or 非全屏", qsl_fn_keyStroke({'cmd,ctrl'},'f') },
    {'c', "⇪ + ⇧ + C", "窗口移动到中心", qswMoveWindowToCenter},
    {'/', "⇪ + ⇧ + /", "窗口最小化", qswWindowMinimize},

    {0x1b, "⇪ + ⇧ + -", "窗口缩小 + 窗口放大", qswResizeScreen(10)},
    {0x18, "⇧", qswResizeScreen(11)},
    {'h',  "⇪ + ⇧ + J", "窗口向左移动一格 L右I上K下", qswResizeScreen(5)},
    {'l',  "⇧", qswResizeScreen(6)},
    {'j',  "⇧", qswResizeScreen(7)},
    {'k',  "⇧", qswResizeScreen(8)},

    {"Left",  "⇪ + ⇧ + ←", "窗口减少一格 → 大一格",screenMoveShift(5)},
    {"Right", "⇧", screenMoveShift(6)},
    {"Up",    "⇪ + ⇧ + ↑", "窗口减少一格 ↓ 大一格", screenMoveShift(7)},
    {"Down",  "⇧", screenMoveShift(8)},

    {0x21, "⇪ + ⇧ + [",  "窗口左上移动", screenMoveShift(1)},
    {0x2a, "⇪ + ⇧ + \\", "窗口右下移动", screenMoveShift(2)},
    {0x1e, "⇪ + ⇧ + ]",  "窗口右上移动", screenMoveShift(3)},
    {0x27, "⇪ + ⇧ + '",  "窗口左下移动", screenMoveShift(4)},

    {'m',  "⇪ + ⇧ + M",   "系统休眠", hs.caffeinate.systemSleep},
    {'r',  "⇪ + ⇧ + R",   "双击 系统重机", function() show("双击 系统重机") end, "", hs.caffeinate.restartSystem},
    {'s',  "⇪ + ⇧ + S",   "双击 系统关机", function() show("双击 系统关机") end, "", hs.caffeinate.shutdownSystem},
    {'q',  "⇪ + ⇧ + Q",   "双击 退出登录", function() show("双击 退出登录") end, "", hs.caffeinate.logOut},
    "",
    "      ***** 编辑软件 *****",
    {'x',  "⌥ + X", "1.Xcode", 'Xcode', "2.XMind ZEN", 'XMind ZEN'},
    {'e',  "⌥ + E", "1.Vim", qsihOpenVim,"2.PyCharm", 'PyCharm', "3.010 Editor", '010 Editor'},
    {'a',  "⌥ + A", "1.Atom", 'Atom', "2.AppleScript", 'Script Editor', "3.AppCleaner", 'AppCleaner'},
    {'n',  "⌥ + N", "1.Quiver", 'Quiver', "2.Dash", 'Dash'},
    {'i',  "⌥ + I", "1.Idaq64", 'idaq64', "2.Ida", 'ida', "3.Impactor", 'Impactor'},
    {'h',  "⌥ + H", "Hopper Disassembler v4", 'Hopper Disassembler v4'},
    {'r',  "⌥ + R", "1.Recents", 'RecentsF', "2.Reveal", 'Reveal'},
    {'c',  "⌥ + C", "Charles", 'Charles'},
    {'f',  "⌥ + F", "1.PP助手", 'PP助手', "2.iToolsPro", 'iTools Pro'},
    {'j',  "⌥ + J", "1.备忘录", 'Notes', "2.日历", 'Calendar', "3.提醒事件",'Reminders'},
    {'k',  "⌥ + K", "1.Pages", 'Pages', "2.Keynote", 'Keynote'},
    "",
    "      ***** 其他软件 *****",
    {'s',  "⌥ + S", "1.Safari", 'Safari', "2.Chrome", 'Google Chrome', '3.Sourcetree', 'Sourcetree'},
    {'l',  "⌥ + L", "1.Google镜像", qsih_OpenGoogleImage, "2.Lantern", 'Lantern'},
    {'g',  "⌥ + G", "1.酷狗", 'KugouMusic', "2.mailTemp", sentMailTemplete, "3.sentMail", sendMailWithContentWithEdit },
    {'w',  "⌥ + W", "1.微信", 'WeChat', "2.QQ", 'QQ'},

    {'v',  "⌥ + V", "1.VMware Fusion", 'VMware Fusion', "2.VNC", 'VNC Viewer', "3.ssh pi", function() qshslTerminalRunIn("ssh pi@192.168.31.188") end},
    {'p',  "⌥ + P", "1.Pixelmator", 'Pixelmator', "2.截图", 'Jietu', "3.Enpass", 'Enpass'},

    {'m',  "⌥ + M", "1.MachOView", 'MachOView', "2.IINA Movie", 'IINA'},


    {',',  "⌥ + <", "1.系统设置偏好", 'System Preferences', "2.Activity Monitor",'Activity Monitor'},
    {0x2f, "⌥ + >", "1.系统Console", 'Console', "2.HS Console", hs.toggleConsole},

    "",
    "      *****  shell  *****",
    {'d',  "⌥ + D", "ITerm2", 'iTerm'},
    {'t',  "⌥ + T", "1.ToTerminal", qsaOpenCourrentFinderInTerminal, "2.Term 显示RAM CPU info", qss_showCPU_Info},
    {'o',  "⌥ + O", "1.22:2222 2.Phone 3.1234:1234", qsihSSLOpenPort2222},
    {';',  "⌥ + :", "1.Phone 2.1234:1234", qsihSSLToPhone},
    {'z',  "⌥ + Z", "1.Cycript", qss_cycriptStep1, "2.@import", qss_cycriptStep2, "3.show中文", qss_printChineseWord},
    "",
    "      ***** 文件操作 *****",
    {'1', "⌥ + 1", "MAC系统1.New", qssh_openFolder("/Volumes/MACNew"), "2.High", qssh_openFolder("/Volumes/MACHigh"),
                          "3.Mojave", qssh_openFolder("/Volumes/MACMojave")},

    {'2',   "⌥ + 2", "1.WorkDisk",  qssh_openFolder("/Volumes/WorkDisk"), "2.BackUP", qssh_openFolder("/Volumes/BackUP")                             },
    {'3',   "⌥ + 3", "1.SyncFloder",qssh_openFolder("/Volumes/WorkDisk/SyncFloder/"),
                     "2.WatchFile", qssh_openFolder("/Volumes/WorkDisk/WatchFile")},
    {'4',   "⌥ + 4", "1.WorkFiles", qssh_openFolder("/Volumes/WorkDisk/SyncFloder/WorkFiles/"),
                     "2.Learn",     qssh_openFolder("/Volumes/WorkDisk/SyncFloder/Learn/")},

    {'b',  "⌥ + B", "1.百度网盘", 'BaiduNetdisk_mac', "2.BT", 'Transmission'},
    {'y',   "⌥ + Y", "1.FTP", 'Yummy FTP', "2.BetterZip", 'BetterZip', "3.ZipWithPW", qsaZipFileWithPassWord},
    {51,    "⌥ + ⌫", "1.打开垃圾筒", qsaOpenTrash, "2.清空垃圾筒", qsaDumpTrash},
    "",
    "      ***** 其他操作 *****",
    {0x2a,  "⌥ + \\:", "QS快捷键提示", showShortcutsTips},
    {0x24,  "⌥ + ↩",   "Next moniter same size", qswMoveScerrnToNextWindowSameSize},
    {'Up',  "⌥ + ↑",   "向上翻页 ↓向下翻页", qswScrollWheelUp},
    {'Down',"⌥", qswScrollWheelDown},

    QSK_upDateLastDate,
}

for i,v in ipairs(operation_config_kyes) do
    if type(v) == "table" then
        assert(#v > 2, "Error init_addkey table < 2")
        _init_addkey(v)
    end
end

print('joys config reloaded successful update :', QSK_upDateLastDate)



-- 
-- function drawBoxes()
-- 	print("Drawing red and blue boxes.")
-- 	redFrame = hs.geometry.rect({x=100, y=100, h=100, w=200})
-- 	redBox = hs.drawing.rectangle(redFrame)
-- 		:setFillColor({red=1.0})
-- 		:setFill(true)
-- 		:setClickCallback(function()
-- 			print("Red clicked!")
-- 		end)
-- 		:show()
-- 	blueFrame = hs.geometry.rect({x=350, y=100, h=100, w=200})
-- 	blueBox = hs.drawing.rectangle(blueFrame)
-- 		:setFillColor({red=0, blue=1.0})
-- 		:setFill(true)
-- 		:setClickCallback(function()
-- 			print("Blue clicked!")
-- 		end)
-- 		:show()
-- end