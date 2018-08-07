



function qsaCopyCourrentPath()
    qshs_isWindowWithAppNamesFn({"访达","Finder"}, '访达 找不到当前路径',
    function()
        applescript([[
           tell application "Finder"
               activate
               try
                   set currentPath to POSIX path of (target of window 1 as alias)
               on error
                   set currentPath to POSIX path of (path to desktop as text)
               end try

               set the clipboard to currentPath
           end tell
        ]])
    end)
end

function qsaNewFloder()
    if qshs_isWindowWithAppNamesFn({"访达","Finder"}, '不能在当前应用新建文件夹') then
        qsl_delayedFn(0.2, qsl_fn_keyStroke({'cmd', 'shift'}, 'n'))
    end
end
function qsaNewFile()
    qshs_isWindowWithAppNamesFn({"访达","Finder"}, '不能在当前应用新建文本',
    function()
        applescript([[
        tell application "Finder"
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
           end repeat
        end tell
        ]])
    end)
end

---------  生成 shell 模版
function _new_shell_file()
    local text = [[#!/bin/bash
# —————————————————————————————————————————————————————————————————————————
#
# Created by joys on ]]..qsl_osTime()..[[

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
    if not qshs_isWindowWithAppNamesFn({"访达","Finder"}, '访达 找不到当前路径') then return end
    qsaCopyCourrentPath()
    qsl_delayedFn(0.3, function()
        local paste = qshslReadPasteboard()
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
                     qsl_readOrSaveOrAdd(path,'w', shell)
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
    qshs_isWindowWithAppNamesFn({"访达","Finder"}, 'Finder not in fornt can not zip file',
    function()
        applescript(
        [[tell application "Finder"
            activate
            try
                set currentPath to POSIX path of (target of window 1 as alias)
            on error
                set currentPath to POSIX path of (path to desktop as text)
            end try
            do shell script "cd " & currentPath & " && zip -r -P 135135 /Volumes/WorkDisk/Temp/RamDisk.zip *"
            do shell script "open /Volumes/WorkDisk/Temp/"
        end tell]])
    end
    )
end

-- 打开垃圾桶 "⌥ + +      1.打开垃圾筒 2.清空垃圾筒"
function qsaOpenTrash()
    applescript(
        [[tell application "Finder"
            set trashCount to count of items in the trash
            if (count of items in the trash) > 0 then
                open trash
                activate
            else
                beep
            end if
    end tell]])
end
-- 清空垃圾桶
function qsaDumpTrash()
    applescript(
        [[tell application "Finder"
            set trashCount to count of items in the trash
            if (count of items in the trash) > 0 then
                empty the trash
            else
                beep
            end if
    end tell]])
end

--- "⌥ + D:   鼠标左键点下"
_qsaIsLeftMouseUp = false;
function _qsaDragged()
    if _qsaIsLeftMouseUp then
        qsl_delayedFn(0.005, function()
            qshs_leftMouseDragged(hs.mouse.getAbsolutePosition())
            _qsaDragged()
        end)
    end
end
function qsa_leftMouseUp()
    print("qsa_LeftMouseUp")
    local point = hs.mouse.getAbsolutePosition()
    if point then qsl_delayedFn(0.02, function() qshs_leftMouseUp(point) end) end
    _qsaIsLeftMouseUp = false
end
function qsa_leftMouseDownAndDragged()
    print("qsa_leftMouseDownAndDragged")
    if _qsaIsLeftMouseUp  then
        qsa_leftMouseUp()
    else
        _qsaIsLeftMouseUp = true
        qshs_leftMouseDown(hs.mouse.getAbsolutePosition())
        qshs_leftMouseDragged(hs.mouse.getAbsolutePosition())
        _qsaDragged()
    end
end
-- {'t',  "⌥ + T", "1.ToTerminal", qsaOpenCourrentFinderInTerminal, "2.Terminal", 'Terminal'},
function qsaOpenCourrentFinderInTerminal()
    if qshs_isWindowWithAppNamesFn({"访达", "Finder"}) then
        applescript([[
               tell application "Finder"
                   activate
                   try
                       set currentPath to POSIX path of (target of window 1 as alias)
                   on error
                       set currentPath to POSIX path of (path to desktop as text)
                   end try
                   tell application "Terminal"
                       activate
                       do script "cd " &currentPath
                   end tell
               end tell
           ]])
    else
        applescript([[tell application "Terminal"
           activate
        end tell]])
    end
end

function _qsa_doAfter(interval, times, arr)
    local len = #arr;
    for i=1, (times * (len + 1)) do
        hs.timer.doAfter(interval * i, function()
            local key = arr[i % (len + 1)]
            if string.find(key, "0x") then key = tonumber(key) end
            hs.eventtap.keyStroke({}, key, 1000)
        end)
    end
end
-- 0.5 times \ Down
-- "⇪ + 8  时间 次数 ...键盘Keys"
function qsa_strokeInEditByPasteboard()
    qsl_textPrompt("自动操作", "0.5 times \\ Down", "0.1 10 \\ Down",  function(text)
        if text and  #text > 1 then
            local array = arrayWithStringAndSplit(text, " ")
            local interval = tonumber(array[1]);
            table.remove(array, 1)
            local times  = tonumber(array[1]) or 2;
            table.remove(array, 1)
            _qsa_doAfter(interval, times, array)
        end
    end)
end
-- 0.5 times \ Down

-- ⇪ + §  大小写
local is_qsa_capslock = true;
function qsa_capslock()
    hs.hid.capslock.set(is_qsa_capslock)
    is_qsa_capslock = not is_qsa_capslock;
end

--
