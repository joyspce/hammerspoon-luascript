-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/12/16 17:37
-- Use    : xxx
-- Change :


-- ctrl.addAlt('s',  "1.Safari 2.Cheatsheet", {'Safari', qsoSafariCheatsheet})
function qsoSafariCheatsheet()
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr= nil
        return
    end
    _ModalMgr = ModalMgr()

    function exit() _ModalMgr.remove() end

    function openURL(url)
        hs.osascript.applescript([[tell application "Safari"
            activate
            delay 0.1
            open location "]]..url..[["
        end tell ]])
    end

    function run(func)
        return function()
            exit()
            if type(func) == 'string' then
                hs.application.launchOrFocusexit(func)
            else
                func()
            end
        end
    end

    -- key, message, pressedfn
    local bindKeys = {
        {key = 'escape', message ="Exit Window Edit Mode", pressedfn = exit},
        {key = 'q',      message ="Exit Window Edit Mode", pressedfn = exit},
        {key = 'tab',message ="Show Cheatsheet", pressedfn = _ModalMgr.show},

        {key = 'c', message ="Google Chrome", pressedfn = run('Google Chrome')},

        {key = 'l', message ="Lantern", pressedfn = run('Lantern')},

        {key = 'g', message ="Google镜像",
            pressedfn = run(function() openURL("https://init.pw") end)},
        {key = 't', message ="github trending",
            pressedfn = run(function() openURL("https://github.com/trending") end)},
        {key = 'o', message ="github topics",
            pressedfn = run(function() openURL("https://github.com/topics") end)},
    }

    _ModalMgr.run(bindKeys)
    _ModalMgr.show()
end
-- ctrl.addAlt({ 0x24, '↩'}, "Open 其他 软件 Cheatsheet", qsoOpenOtherSoftWare)
function qsoOpenOtherSoftWare()
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr= nil
        return
    end
    _ModalMgr = ModalMgr()

    function exit() _ModalMgr.remove() _ModalMgr = nil end

    function openApp(appName)
        return function()
            hs.application.launchOrFocus(appName)
            exit()
        end
    end

    -- key, message, pressedfn
    local bindKeys = {
        {key = 'escape', message ="Exit Window Edit Mode", pressedfn = exit},
        {key = 'q',      message ="Exit Window Edit Mode", pressedfn = exit},

        {key = 'tab',message ="Show Cheatsheet", pressedfn = _ModalMgr.show},

        {key = 'd', message ="日历", pressedfn = openApp("Calendar")},
        {key = 'r', message ="提醒事件", pressedfn = openApp("Reminders")},
        {key = 'p', message ="Pages", pressedfn = openApp("Pages")},
        {key = 'k', message ="Keynote", pressedfn = openApp("Keynote")},
        {key = 'a', message ="AppleScript", pressedfn = openApp("Script Editor")},


        {key = 'i', message ="Idaq64", pressedfn = openApp("idaq64")},
        {key = '3', message ="Ida", pressedfn = openApp("ida")},
        {key = 's', message ="Impactor", pressedfn = openApp("Impactor")},
        {key = 'h', message ="Hopper Disassembler", pressedfn = openApp("Hopper Disassembler v3")},

        {key = 'v', message ="Reveal", pressedfn = openApp("Reveal")},
        {key = 'c', message ="Charles", pressedfn = openApp("Charles")},
        {key = 'x', message ="Pixelmator", pressedfn = openApp("Pixelmator")},
        {key = 'j', message ="截图", pressedfn = openApp("Jietu")},
        {key = 'e', message ="Enpass", pressedfn = openApp("Enpass")},
        {key = 'm', message ="MachOView", pressedfn = openApp("MachOView")},
        {key = 'v', message ="IINA Movie", pressedfn = openApp("IINA")},
        {key = 'g', message ="酷狗", pressedfn = openApp("KugouMusic")},
        {key = 'b', message ="百度网盘", pressedfn = openApp("BaiduNetdisk_mac")},
        {key = 't', message ="Transmission BT DownLoad", pressedfn = openApp("Transmission")},
        {key = 'f', message ="FTP", pressedfn = openApp("Yummy FTP")},
        {key = 'z', message ="BetterZip", pressedfn = openApp("BetterZip")},

    }
    _ModalMgr.run(bindKeys)
    _ModalMgr.show()
end

-- //  : shell command

-- python 显示文字
function qss_printChineseWord()
    -- 1. 读 粘贴板
    local paste = hsReadPasteboard()
    paste = qsRemoveAllSpace(paste)

    if (string.find(paste,'%%')) then
        paste = string.gsub(paste, '%%', '\\x')
        paste = string.lower(paste);
    end

    if not paste then return end

    -- 2. 查看字符串 生成 python print code 两种中文 1. '\u6a21\u5f0f' 2."\xe7\x99\xbb\xe5\xbd\x95"
    local text = ""
    if string.find( paste, 'x') then
        -- 1.中文 生成python
        text = "print "..paste
    elseif string.find( paste, 'u') then
        -- 2.中文 生成python
        text = "print u"..paste
    else
        show("pasteboards data error"..paste)
        return
    end

    local path = "/Volumes/WorkDisk/Temp/printString.py"
    -- 3. 保存 python print code
    qsSaveOrAddWithStr(path,"w",text)
    -- 4. run
    local shell = "python "..path
    hsDelayedFn(0.1, function() hsTerminalRunIn(shell) end)
end

function qss_showCPU_Info()
    local path = os.getenv("HOME").."/.hammerspoon/script/ShellCPUInfo.sh"
    hs.osascript.applescript( [[tell application "Terminal"
       activate
       do script "]] ..path.. [["
    end tell]] )
end

-- ctrl.addAlt({ ';',  ':'}, "Open 1.Shell 2.Cheatsheet",
    -- {function() hs.application.launchOrFocus('Terminal') end, qsoOpenShellCheatsheet})
function qsoOpenShellCheatsheet()
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr= nil
        return
    end
    _ModalMgr = ModalMgr()

    function exit() _ModalMgr.remove() _ModalMgr = nil end

    function run(func)
        return function()
            if type(func) == 'string' then
                hs.application.launchOrFocusexit(func)
            else
                func()
            end
            exit()
        end
    end

    -- key, message, pressedfn
    local bindKeys = {
        {key = 'escape', message ="Exit Window Edit Mode", pressedfn = exit},
        {key = 'q',      message ="Exit Window Edit Mode", pressedfn = exit},
        {key = 'tab',message ="Show Cheatsheet", pressedfn = _ModalMgr.show},

        {key = 'v', message ="Vim", pressedfn = run(qsihOpenVim)},
        {key = 't', message ="ToITerm2", pressedfn = run(qsaOpenCourrentFinderInITerm2)},
        {key = 'i', message ="iTerm2", pressedfn = run('iTerm')},

        {key = 'a', message ="ToTerminal", pressedfn = run(qsaOpenCourrentFinderInTerminal)},

        {key = 'p', message ="ssh pi树莓派",
            pressedfn = run(function()hsTerminalRunIn("ssh pi@192.168.31.188") end)},
        {key = 'f', message ="ssh IPhone",
                pressedfn = run(function()hsTerminalRunIn("ssh pi@192.168.31.188") end)},
        {key = '2', message ="open tcprelay 22:2222", pressedfn = run(function()
            hsTerminalRunIn("python "..hs.configdir.."/script/USBSSH/tcprelay.py -t 22:2222")
        end)},
        {key = 'l', message ="ssh localhost",
                pressedfn = run(function()hsTerminalRunIn("ssh root@localhost -p 2222") end)},
        {key = 'c', message ="Cycript", pressedfn = run(function()
            hs.application.launchOrFocus("Terminal")
            if hsIsWindowWithAppNamesFn({"终端","Terminal"}, 'Terminal is not in fornt') then
                hsDelayedFn(0.1, function() hsPasteWithString("/var/root/cy.sh ") end)
            end
            hsDelayedFn(0.5, function() hsIsSavePasteboard("@import com.joys.joys") end)
        end)},

        {key = 'o', message ="open 1234 and copy to pb",
                pressedfn = run(function()
                    hsTerminalRunIn("python "..hs.configdir.."/script/USBSSH/tcprelay.py -t 1234:1234")
                    hsIsSavePasteboard(
                        [[debugserver *:1234 -a "SpringBoard"   #连接到APP 手机
                        lldb    #电脑
                        process connect connect://loclahost:1234
                        image list -o -f  #ASLR 随机偏移]])
                end)},
         {key = 'z', message ="3ZipWithPW", pressedfn = run(qsaZipFileWithPassWord)},
         {key = 'u', message ="显示RAM CPU info 等", pressedfn = run(qss_showCPU_Info)},
         {key = 's', message ="show中文", pressedfn = run(qss_printChineseWord)},

         {key = 'w', message ="write mail", pressedfn = run(function()
             hsPasteWithString([[
sender = '501919181@qq.com'
receivers = 'joysnipple@icloud.com'
subject = '主题'
text = '内容'
]])
         end)},
        {key = 'e', message ="sentMail", pressedfn = run(sendMailWithContentWithEdit)},
    }
    _ModalMgr.run(bindKeys)
    _ModalMgr.show()
end


-- 打开垃圾桶 "⌥ + +      1.打开垃圾筒 2.清空垃圾筒"
function qsaOpenTrash()
    hs.osascript.applescript(qsaTell("Finder", [[
        set trashCount to count of items in the trash
        if (count of items in the trash) > 0 then
            open trash
            activate
        else
            beep
        end if
        ]])
    )
end
-- 清空垃圾桶
function qsaDumpTrash()
    hs.osascript.applescript(qsaTell("Finder", [[
        set trashCount to count of items in the trash
        if (count of items in the trash) > 0 then
            empty the trash
        else
            beep
        end if
        ]])
    )
end


function qsaTell(app, body)
    local str = [[tell application "]]..app..[["
]]..body..[[

    end tell
]]
    return str
end

function qsaCopyCourrentPath()
    hs.application.launchOrFocus("Finder")
    hsIsWindowWithAppNamesFn({"访达","Finder"}, '访达 找不到当前路径', function()
        hs.osascript.applescript(qsaTell("Finder", [[
        activate
        try
            set currentPath to POSIX path of (target of window 1 as alias)
        on error
            set currentPath to POSIX path of (path to desktop as text)
        end try
        set the clipboard to currentPath
        ]]))
        show("copy path")
    end)
end

function qsaNewFloder()
    hs.application.launchOrFocus("Finder")
    if hsIsWindowWithAppNamesFn({"访达","Finder"}, '不能在当前应用新建文件夹') then
        hsDelayedFn(0.2, qsFunction(koKeyStroke,{'cmd', 'shift'}, 'n'))
    end
end
function qsaNewFile()
    hs.application.launchOrFocus("Finder")
    hsIsWindowWithAppNamesFn({"访达","Finder"}, '不能在当前应用新建文本', function()
        hs.osascript.applescript(qsaTell("Finder", [[
           activate
           try
               set currentPath to POSIX path of (target of window 1 as alias)
           on error
               set currentPath to POSIX path of (path to desktop as text)
           end try
           set idx to ""
           set breaken to 0
           repeat until breaken = 1
               set targetPath to currentPath & "newFile" & idx & ".txt"
               set idx to idx + 1
               try
                   POSIX file targetPath as alias
               on error
                   set breaken to 1
                   do shell script "touch " & targetPath
               end try
           end repeat]])
         )
    end)
end

---------  生成 shell 模版
function _new_shell_file()
    local text = [[#!/bin/bash
# —————————————————————————————————————————————————————————————————————————
#
# Created by joys on ]]..qsOsTime()..[[

#
# FileName:    XXX.sh
# Version:     0.01
# QQ:          501919181
# E-mail:      joysnipple@icloud.com
# Author:      joys
# Description: shell脚本的功能描述
#
# —————————————————————————————————————————————————————————————————————————

# echo "参数总数有 $# 个!"
# echo "作为一个字符串输出所有参数 $* !"

# 判断 参数
if [ $# != 2 ];then
    echo "Parameter incorrect."
    exit 1
fi

#for I in {1..10};do
    #do sth
#done

# 定义环境变量
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/apps/bin/"

# 函数前的说明注释
func1(){
    #do sth
}
func2(){
    #do sth
}
main(){
    func1
    func2
}
main "$@"




]]
    return text
end

-- "⇪ + 0  新建 shell 模版"
function qsa_NewShellTemplate()
    if not hsIsWindowWithAppNamesFn({"访达","Finder"}, '访达 找不到当前路径') then return end
    qsaCopyCourrentPath()
    hsDelayedFn(0.3, function()
        local paste = hsReadPasteboard()
        if hs.fs.displayName(paste) then
            local shell = _new_shell_file()
            for i=1,100 do
                local path = nil
                if i == 1 then
                    path = paste.."shell.sh"
                else
                    path = paste.."shell"..(i-1)..".sh"
                end

                if not hs.fs.displayName(path) then
                     qsSaveOrAddWithStr(path,'w', shell)
                    break
                end
            end
        end
    end)
end

-- zip 文件
function qsaZipFileWithPassWord()
    --zip -r -P PasswordJoy /Volumes/WorkDisk/Temp/
    print("zipFileWithPassWord");
    hsIsWindowWithAppNamesFn({"访达","Finder"}, 'Finder not in fornt can not zip file', function()
        hs.osascript.applescript(qsaTell("Finder", [[
            activate
            try
                set currentPath to POSIX path of (target of window 1 as alias)
            on error
                set currentPath to POSIX path of (path to desktop as text)
            end try
            do shell script "cd " & currentPath & " && zip -r -P 135135 /Volumes/WorkDisk/Temp/RamDisk.zip *"
            do shell script "open /Volumes/WorkDisk/Temp/"
                ]])
        )
    end)
end

function qsaOpenCourrentFinderInITerm2()
    hs.application.launchOrFocus("Finder")
    if hsIsWindowWithAppNamesFn({"访达", "Finder"}) then
            qsaCopyCourrentPath()
            hsDelayedFn(0.1, function()
              local path = hs.pasteboard.getContents()
              if (#path > 1) then
                  hs.application.launchOrFocus("iTerm")
                  hsDelayedFn(0.25, function() hs.eventtap.keyStrokes("cd "..path.."\r") end)
              end
          end)
    else
        hs.application.launchOrFocus("iTerm")
    end
end
-- {'t',  "⌥ + T", "1.ToTerminal", qsaOpenCourrentFinderInTerminal, "2.Terminal", 'Terminal'},
function qsaOpenCourrentFinderInTerminal()
    hs.application.launchOrFocus("Finder")
    if hsIsWindowWithAppNamesFn({"访达", "Finder"}) then
        qsaCopyCourrentPath()
        hsDelayedFn(0.1, function()
            local path = hs.pasteboard.getContents()
            if (#path > 1) then
                hs.application.launchOrFocus("Terminal")
                hsDelayedFn(0.25, function() hs.eventtap.keyStrokes("cd "..path.."\r") end)
            end
        end)
    else
        hs.application.launchOrFocus("Terminal")
    end
end

-- "⌥ + E  Vim"
function qsihOpenVim()
    hs.osascript.applescript(
        [[  tell application "Terminal"
            activate
            do script "vim"
        end tell]])
end





--
