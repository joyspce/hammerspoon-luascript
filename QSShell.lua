
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

-- // *********************************** mark by joys 2018-06-24 21:42 ***
-- //  : shell command
-- // *********************************************************************


-- "⌥ + Z    1.cycript 2.@import 3.show中文"
function qss_cycriptStep1()
    if qshs_isWindowWithAppNamesFn({"终端","Terminal"}, 'Terminal is not in fornt') then
        qslPasteWithString("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b/var/root/cy.sh ")
    end
end
function qss_cycriptStep2()
    if qshs_isWindowWithAppNamesFn({"终端","Terminal"}, 'Terminal is not in fornt') then
        qslPasteWithString("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b@import com.joys.joys")
    end
end
-- python 显示文字
function qss_printChineseWord()
    -- 1. 读 粘贴板
    local pasteboard = qshslReadPasteboard()
    pasteboard = qslRemoveSpace(pasteboard)

    if (string.find(pasteboard,'%%')) then
        pasteboard = string.gsub(pasteboard, '%%', '\\x')
        pasteboard = string.lower(pasteboard);
    end

    if not pasteboard then return end

    -- 2. 查看字符串 生成 python print code 两种中文 1. '\u6a21\u5f0f' 2."\xe7\x99\xbb\xe5\xbd\x95"
    local text = ""
    if string.find( pasteboard, 'x') then
        -- 1.中文 生成python
        text = "print "..pasteboard
    elseif string.find( pasteboard, 'u') then
        -- 2.中文 生成python
        text = "print u"..pasteboard
    else
        show("pasteboards data error"..pasteboard)
        return
    end

    local path = "/Volumes/WorkDisk/Temp/printString.py"
    -- 3. 保存 python print code
    qsl_readOrSaveOrAdd(path,"w",text)
    -- 4. run
    local shell = "python "..path
    qsl_delayedFn(0.1, function() qshslTerminalRunIn(shell) end)
end

function qss_showCPU_Info()
    local path = os.getenv("HOME").."/.hammerspoon/Shell/ShellCPUInfo.sh"
    hs.osascript.applescript( [[tell application "Terminal"
       activate
       do script "]] ..path.. [["
    end tell]] )
end

function qss_CopyToApp(app, appNames)
    qsl_delayedFn(0.15, qs_fn(qsl_keyStroke,{'cmd'}, 'c'))
    qsl_delayedFn(0.2, function() hs.application.launchOrFocus(app) end)
    qsl_delayedFn(0.3, function()
        if qshs_isLaunchOrFocus(app, appNames) then qsl_delayedFn(0.3, qs_fn(qsl_keyStroke,{'cmd'}, 'v')) end
    end)
end
-- {"v",  "⇪ + V",  "CopyTo 1.Xcode", qss_copyToXcode, "2.记事本", qss_copyToNotes},
function qss_copyToXcode() qss_CopyToApp('Xcode', {'Xcode'}) end
function qss_copyToNotes() qss_CopyToApp('Notes', {'Notes', '备忘录'}) end
-- x X
function qss_copyToAtom()  qss_CopyToApp('Atom', {'Atom'}) end
function qss_copyToQuiver()  qss_CopyToApp('Quiver', {'Quiver'}) end



-- %E5%BC%80%E5%8F%91%E8%BF%9B%E9%98%B6%28%E5%94%90%E5%B7%A7%29
--  scp -P 2222 root@localhost:/var/containers/Bundle/Application/402E5FEF-337C-41FA-8715-A9095AB49BFE/DiSpecialDriver.app /Volumes/WorkDisk/Temp/
-- scp -P 2222 root@localhost:/var/root/cy.sh /Volumes/WorkDisk/SyncFloder/WorkFiles/shell/cy.sh
-- local shell = [[bash -f "/var/root/cy.sh" &&scp -P 2222 root@localhost:/var/root/cy.sh /Volumes/WorkDisk/SyncFloder/WorkFiles/shell/cy.sh]]
-- os.execute(shell)

--
