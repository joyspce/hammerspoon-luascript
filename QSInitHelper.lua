
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

-- 存放 init 长代码

-- "⌥ + K  Vim"
function qsihOpenVim()
    hs.osascript.applescript(
        [[  tell application "Terminal"
            activate
            do script "vim"
        end tell]])
end

local countTime = 0
function qsi_multipleClick(...)
    local array = {...}
    if (countTime == 0) then
        qsl_delayedFn(8, function() countTime = 0; print("countTime end "..countTime) end)
    end
    countTime = countTime + 1;
    if countTime > #array then countTime = 1 end
    local obj = array[countTime]
    obj()
end

local _qsiDefineHost = "localhost"
-- "⌥ + o    1.22:2222 2.phone 3.1234:1234"
function qsihSSLOpenPort2222()
    qsi_multipleClick(
        --  Error: hs.spoons.script_path() 不好用 nil
        function() qshslTerminalRunIn("python "..hs.configdir.."/USBSSH/tcprelay.py -t 22:2222") end,
        function() qshslTerminalRunIn("ssh root@".._qsiDefineHost.." -p 2222") end,
        function() qshslTerminalRunIn("python "..hs.configdir.."/USBSSH/tcprelay.py -t 1234:1234") end,
        function() qshs_isSavePasteboard(
            [[debugserver *:1234 -a "SpringBoard"   #连接到APP 手机
            lldb    #电脑
            process connect connect://loclahost:1234
            image list -o -f  #ASLR 随机偏移]])
        end
    )
end
-- "⌥ + :  1.phone 2.1234:1234"
function qsihSSLToPhone()
    qsi_multipleClick(
        function() qshslTerminalRunIn("ssh root@".._qsiDefineHost.." -p 2222") end,
        function() qshslTerminalRunIn("python "..hs.configdir.."/USBSSH/tcprelay.py -t 1234:1234") end,
        function() qshs_isSavePasteboard(
            [[debugserver *:1234 -a "SpringBoard"   #连接到APP 手机
            lldb    #电脑
            process connect connect://loclahost:1234
            image list -o -f  #ASLR 随机偏移]])
        end
    )
end


-- "⌥ + L    1.google镜像2.Lantern"
function qsih_OpenGoogleImage() qsih_openURL("https://init.pw ") end

function qsih_openURL(url)
    hs.osascript.applescript([[tell application "Safari"
        activate
        delay 0.1
        open location "]]..url..[["
    end tell ]])
end

-- "⌥ + ↑      向上翻页 ↓向下翻页"
function qswScrollWheelUp()
    local step = 20
    for i=1, step do
        hs.timer.usleep(300)
        hs.eventtap.scrollWheel({0, step}, {}, 'pixel')
    end
end
function qswScrollWheelDown()
    local step = 20
    for i=1, step do
        hs.timer.usleep(300)
        hs.eventtap.scrollWheel({0, -step}, {}, 'pixel')
    end
end

-- {0x2c, "⇪ + /",  "注释 1.(Time)", qsseComment1, "2.NS", qsseComment2, "3.UI", qsseComment3, "4.C", qsseComment4},
function qsseComment1() qslPasteWithString("// ** "..qsl_osTime().." ** ") end
function qsseComment2()
    qslPasteWithString("// *********************************** mark by joys "..qsl_osTime().." ***"
    .."\n// NS : ".. "\n".."// *********************************************************************\n")
end
function qsseComment3()
    qslPasteWithString("// ----------------------------------- mark by joys "..qsl_osTime().." ---"
     .."\n// UI : ".. "\n".."// ---------------------------------------------------------------------\n")
end
function qsseComment4()
    qslPasteWithString("// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* mark by joys "..qsl_osTime().." -*-"
     .."\n// C : ".. "\n".."// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n")
end
-- {0x2a, "⇪ + \\", "注释", qsseComment123, "1./ 2./ 3./", qssClearComment},
local qsseComment123Count = 1
function qsseComment123()
    local pastStr = "/// * "..qsseComment123Count..". \n"
    qslPasteWithString(pastStr)
    qsseComment123Count = qsseComment123Count + 1;
end
function qssClearComment() qsseComment123Count = 1 end


--

-- -- "⌥ + 9      打开WorkDisk盘的LuaZip目录"
-- function qsihOpenLuaZipeFloderAndPastProjetZipFile()
--     qssh_openFolder("/Volumes/WorkDisk/LuaZip/")();
--     qsl_delayedFn( 1.0, qs_fn(qsl_keyStroke,{'cmd'}, 'v'))
-- end
