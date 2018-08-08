

-- // ********************************** mark by joys 2018-06-19 15:39 **
-- // * : fileWatch
-- // *******************************************************************

function QSWatch()
    local mine = {}
    mine.watchPath = nil
    mine.targetPath = nil

    mine.changePathToTargetPath = function(path)
        return mine.targetPath..string.gsub(path, mine.watchPath, "")
    end

    mine.deleteTargetFile = function(path)
        -- 替换目录
        local targtPath = mine.changePathToTargetPath(path)
        -- 文件 存在 delete
        if hs.fs.displayName(targtPath) then
            hs.execute("rm -r "..string.gsub(targtPath, " ", "\\ "))
            print("mine.delete path :", path, "targtPath", targtPath)
        end
    end

    mine.copy = function(path, targtPath)
        path = string.gsub(path, " ", "\\ ")
        targtPath = string.gsub(targtPath, " ", "\\ ")
        hs.execute("cp "..path.." "..targtPath)
        print("mine.copy:", "cp "..path.." "..targtPath)
    end

    mine.copyToTargetFile = function(path, flag)

        if flag.itemIsFile then
            mine.copy(path, mine.changePathToTargetPath(path))
            print("mine.copyToTargetFile 我是文件:", path)
        elseif (flag.itemIsDir) then
            local targtPath = mine.changePathToTargetPath(path)
            --
            if hs.fs.displayName(path) then
                hs.fs.mkdir(targtPath)
                hs.execute("cp -r -f "..path.."/* "..targtPath)
                print("mine.copyToTargetFile 我是文件夹", targtPath)
            else
                print("remove mine.copyToTargetFile 我是文件夹", targtPath)
                hs.fs.rmdir(targtPath)
            end
        else
            show("mine.copyToTargetFile Error: 我是什么也不是")
        end
    end

    mine.operateTargetFile = function(path, flag)
        if flag.itemCreated then
            print("mine.operateTargetFile itemCreate 1. 创建文件 :", path)
            mine.copyToTargetFile(path, flag)
        elseif flag.itemModified or flag.itemRenamed then
            print("mine.operateTargetFile itemModified 2. 修改文件:", path)
            mine.copyToTargetFile(path, flag)
        else
            print("mine.operateTargetFile 3. 什么也不做:", path)
        end
    end

    mine.operateFile = function(path, flag)
        -- 文件存在 或 create
        if hs.fs.displayName(path) or flag.itemCreated then
            mine.operateTargetFile(path, flag)
        else
            print("deleteTargetFile")
            mine.deleteTargetFile(path)
        end
    end

    mine.changeDirOrFileName = function(path, toPath)
        local targetPath = mine.changePathToTargetPath(path)
        local changeToPath = mine.changePathToTargetPath(toPath)
        print(path, "--------", targetPath)
        if hs.fs.displayName(targetPath) then
            print("changeToPath --------", changeToPath)
            hs.execute("mv "..targetPath.." "..changeToPath)
        else
            print(targetPath.." mine.changeDicName 不存在 ", "cp -r -f "..toPath.."/* "..changeToPath )
            hs.execute("cp -r -f "..toPath.." "..changeToPath)
        end
    end
    mine.isDirOrFileRenane = function(paths, flagTables)
        if #paths == 2 then
            local flag2 = flagTables[2]
            local flag1 = flagTables[1]
            if  (flag2.itemIsDir or flag2.itemIsFile) and flag2.itemRenamed
            and (flag1.itemIsDir or flag2.itemIsFile) and flag1.itemRenamed then
                print("文件夹or文件修改名字")
                if hs.fs.displayName(paths[2]) then
                    print("文件夹or文件存在")
                    mine.changeDirOrFileName(paths[1], paths[2])
                    return true
                end
            end
        end
        return false
    end

    -- 目录 监测
    mine.pathwatcher_fn = function (paths, flagTables, fn)

        if mine.isDirOrFileRenane(paths, flagTables) then return end

        for i, path in ipairs(paths) do
            if string.find(path, ".DS_Store") then
                print(".DS_Store file :", path, "不做任何事")
            else
                mine.operateFile(path, flagTables[i])
            end
        end
    end
    return mine
end
--
qsw_watch = QSWatch()
-- qsw_watch.watchPath  = hs.configdir -- /Users/joyspace/.hammerspoon
-- qsw_watch.targetPath = "/Volumes/MACHigh/Users/qinshaobo/.hammerspoon"
qsw_watch.watchPath  = "/Volumes/WorkDisk/SyncFloder/MyCode/LUA/hammerSpoon/"
qsw_watch.targetPath = hs.configdir.."/"


g_watch_SyncFloder_file = hs.pathwatcher.new(qsw_watch.watchPath,
    function(paths, flagTables)
        qsw_watch.pathwatcher_fn(paths, flagTables, nil)
    end
):start()

---- for copy 双击 拖动鼠标 监测
local watcherEventTime, dubbleCickCount = 0, 0;
function qsw_dubbleCick()
    if watcherEventTime == 0 then watcherEventTime = os.clock() end
    dubbleCickCount = dubbleCickCount + 1
    if dubbleCickCount == 1 or ( os.clock() - watcherEventTime ) >= 0.025 then
        -- print(" 超时 第一次".. os.clock() - watcherEventTime );
        watcherEventTime = os.clock()
        return;
    end
    -- 第二次
    if dubbleCickCount > 1 then
        -- print("第二次"..os.clock() - watcherEventTime)
        if os.clock() - watcherEventTime < 0.026 then qsl_fn_keyStroke( {'cmd'}, 'c')() end
        dubbleCickCount = 1;
        -- 重新计算时间
        watcherEventTime = os.clock();
    end
end

local watcherEventIsDown, watcherEventIsDrag = false, false;

eventLeftMouseUp = hs.eventtap.new( { hs.eventtap.event.types.leftMouseDown,
                                      hs.eventtap.event.types.leftMouseDragged,
                                      hs.eventtap.event.types.leftMouseUp,
                                      hs.eventtap.event.types.mouseMoved, },
    function(arg1)
        local arg1Type = arg1:getType()
        if arg1Type == hs.eventtap.event.types.leftMouseDown then
            watcherEventIsDown = true;
        --show(watcherEventTiem)
        elseif arg1Type == hs.eventtap.event.types.leftMouseUp then
            if watcherEventIsDown and watcherEventIsDrag then
              qsl_fn_keyStroke( {'cmd'}, 'c')()
            else
              qsw_dubbleCick()
            end
        watcherEventIsDown, watcherEventIsDrag = false, false;
        elseif arg1Type == hs.eventtap.event.types.leftMouseDragged then
            watcherEventIsDrag = true;
        else
            dubbleCickCount = 0;
        end
    end )
local eventLeftMouseUpIsStop = false;

appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        local appArr = { "Quiver","Xcode","Safari 浏览器","Dash", "Atom" };
        for i=1, #appArr do
            if appName == appArr[i] then
                if not eventLeftMouseUpIsStop then
                    eventLeftMouseUp:start();
                    eventLeftMouseUpIsStop = true;
                    show( appArr[i].." -- isSelectCopy" );
                end
                break;
            else
                if eventLeftMouseUpIsStop then
                    eventLeftMouseUp:stop()
                    eventLeftMouseUpIsStop = false;
                end
            end
        end
    end
end)
appWatcher:start()

mail_pass = '' -- 输入你的 Email 密码
if #mail_pass < 1 then
    local path = "/Volumes/WorkDisk/Temp/password.txt"
    if doesFileExist(path) then
        local array = qsl_arrayRead(path)
        mail_pass = array[1]
    end
end
--  ——————————————————— 手动分割线 监测 WIFI打开后 Email to joysnipple@icloud.com  ———————————————————
function qsw_sentMail(mailItems, isShow)
    local python = [[#!/usr/bin/python
# -*- coding: UTF-8 -*-

import smtplib
from email.mime.text import MIMEText

mail_host = 'smtp.qq.com'
mail_user = '501919181'

]]
.."mail_pass = "..mail_pass.."\n"
..mailItems..
[[

message = MIMEText(text, 'plain', 'utf-8')
message['From'] = sender
message['To'] = receivers
message['Subject'] = subject
try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host, 25)
    smtpObj.login(mail_user,mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print "邮件发送成功"
except smtplib.SMTPException:
    print "Error: 无法发送邮件"
]]
    local path = hs.configdir.."/Text/Email.py"
    qsl_readOrSaveOrAdd(path, "w", python)

    qsl_delayedFn(0.20, function()
        local path1 = hs.configdir.."/Text/Email.py"
        local ret = hs.execute("python "..path1)
        if isShow then
            show(ret)
            print("python "..path1, ret)
        end
    end)
end

local g_qsw_time_doEvery_count = 0
g_qsw_time_doEvery = hs.timer.doEvery(10, function()
    -- 1. 获取 Wifi and Len IP
    local array = hs.network.addresses("en1")
    for i,v in ipairs(hs.network.addresses("en0")) do
        array[#array + 1] = v
    end

    g_qsw_time_doEvery_count = g_qsw_time_doEvery_count + 1
    if g_qsw_time_doEvery_count > 2 then
        print("i am not sent")
        g_qsw_time_doEvery:stop()
    end

    for i,v in ipairs(array) do
        if v == "192.168.31.120" then
            print("本机")
            return
        end
    end

    if #array == 0 then return end
    print("to sent")
    -- 获取 经纬度
    local dis = hs.location.get()
    if dis then
        local info = ""
            for k,v in pairs(dis) do
            info = info.."key :"..k.." var :"..v
        end
        qsw_sentMail([[sender = '501919181@qq.com'
receivers = 'joysnipple@icloud.com'
subject = 'auot sent mail'
text = ']]..info.." time :"..qsl_osTime().."'", nil)
        print("i am sented")
        g_qsw_time_doEvery:stop()
    else
        print("location not found")
    end


end):start()

function sentMailTemplete()
    qslPasteWithString(
    [[
sender = '501919181@qq.com'
receivers = 'joysnipple@icloud.com'
subject = '主题'
text = '内容'
    ]]
)
end
function sendMailWithContentWithEdit()
    mailItems = qshslReadPasteboard()
    if string.find(mailItems, "sender") and string.find(mailItems, "subject") and string.find(mailItems, "receivers")
    and string.find(mailItems, "text") and  string.find(mailItems, "=") then
        qsw_sentMail(mailItems, true)
    else
        show("Error: sent no Templete")
        return
    end
end

wifiwatcher =
    hs.wifi.watcher.new(
    function()
        net = hs.wifi.currentNetwork()
        if net == nil then
            hs.notify.show("WiFi disconnected", "", "", "")
        else
            hs.notify.show("WiFi connected", "", net, "")
        end
    end
)
wifiwatcher:start()


--
