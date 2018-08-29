
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

function qsaCopyCourrentPath()
    hs.application.launchOrFocus("Finder")
    qshs_isWindowWithAppNamesFn({"访达","Finder"}, '访达 找不到当前路径', function()
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
        show("copy path")
    end)
end

function qsaNewFloder()
    hs.application.launchOrFocus("Finder")
    if qshs_isWindowWithAppNamesFn({"访达","Finder"}, '不能在当前应用新建文件夹') then
        qshs_delayedFn(0.2, qsl_fn(qsl_keyStroke,{'cmd', 'shift'}, 'n'))
    end
end
function qsaNewFile()
    hs.application.launchOrFocus("Finder")
    qshs_isWindowWithAppNamesFn({"访达","Finder"}, '不能在当前应用新建文本', function()
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
    qshs_delayedFn(0.3, function()
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
                     qsl_saveOrAddWithStr(path,'w', shell)
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

function qsaOpenCourrentFinderInITerm2()
    if qshs_isWindowWithAppNamesFn({"访达", "Finder"}) then
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
          qshs_delayedFn(0.1, function()
              local path = hs.pasteboard.getContents()
              if (#path > 1) then
                  hs.application.launchOrFocus("iTerm")
                  qshs_delayedFn(0.25, function()
                      hs.eventtap.keyStrokes("cd "..path.."\r")
                  end)
              end
          end)
    else
        hs.application.launchOrFocus("iTerm")
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
                   set the clipboard to currentPath
                end tell
                ]])
               qshs_delayedFn(0.1, function()
                   local path = hs.pasteboard.getContents()
                   if (#path > 1) then
                       hs.application.launchOrFocus("Terminal")
                       qshs_delayedFn(0.25, function()
                           hs.eventtap.keyStrokes("cd "..path.."\r")
                       end)
                   end
               end)
    else
        hs.application.launchOrFocus("Terminal")
    end
end

--
