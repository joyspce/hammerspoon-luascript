

-- // ********************************** mark by joys 2018-06-19 15:39 **
-- // * : fileWatch
-- // *******************************************************************

function QSWatch()
    local s = {}
    s.watchPath = nil
    s.targetPath = nil

    s.changePathToTargetPath = function(path)
        return s.targetPath..string.gsub(path, s.watchPath, "")
    end

    s.deleteTargetFile = function(path)
        -- 替换目录
        local targtPath = s.changePathToTargetPath(path)
        -- 文件 存在 delete
        if hs.fs.displayName(targtPath) then
            hs.execute("rm -r "..string.gsub(targtPath, " ", "\\ "))
            print("s.delete path :", path, "targtPath", targtPath)
        end
    end

    s.copy = function(path, targtPath)
        path = string.gsub(path, " ", "\\ ")
        targtPath = string.gsub(targtPath, " ", "\\ ")
        hs.execute("cp "..path.." "..targtPath)
        print("s.copy:", "cp "..path.." "..targtPath)
    end

    s.copyToTargetFile = function(path, flag)

        if flag.itemIsFile then
            s.copy(path, s.changePathToTargetPath(path))
            print("s.copyToTargetFile 我是文件:", path)
        elseif (flag.itemIsDir) then
            local targtPath = s.changePathToTargetPath(path)
            --
            if hs.fs.displayName(path) then
                hs.fs.mkdir(targtPath)
                hs.execute("cp -r -f "..path.."/* "..targtPath)
                print("s.copyToTargetFile 我是文件夹", targtPath)
            else
                print("remove s.copyToTargetFile 我是文件夹", targtPath)
                hs.fs.rmdir(targtPath)
            end
        else
            show("s.copyToTargetFile Error: 我是什么也不是")
        end
    end

    s.operateTargetFile = function(path, flag)
        if flag.itemCreated then
            print("s.operateTargetFile itemCreate 1. 创建文件 :", path)
            s.copyToTargetFile(path, flag)
        elseif flag.itemModified or flag.itemRenamed then
            print("s.operateTargetFile itemModified 2. 修改文件:", path)
            s.copyToTargetFile(path, flag)
        else
            print("s.operateTargetFile 3. 什么也不做:", path)
        end
    end

    s.operateFile = function(path, flag)
        -- 文件存在 或 create
        if hs.fs.displayName(path) or flag.itemCreated then
            s.operateTargetFile(path, flag)
        else
            print("deleteTargetFile")
            s.deleteTargetFile(path)
        end
    end

    s.changeDirOrFileName = function(path, toPath)
        local targetPath = s.changePathToTargetPath(path)
        local changeToPath = s.changePathToTargetPath(toPath)
        print(path, "--------", targetPath)
        if hs.fs.displayName(targetPath) then
            print("changeToPath --------", changeToPath)
            hs.execute("mv "..targetPath.." "..changeToPath)
        else
            print(targetPath.." s.changeDicName 不存在 ", "cp -r -f "..toPath.."/* "..changeToPath )
            hs.execute("cp -r -f "..toPath.." "..changeToPath)
        end
    end
    s.isDirOrFileRenane = function(paths, flagTables)
        if #paths == 2 then
            local flag2 = flagTables[2]
            local flag1 = flagTables[1]
            if  (flag2.itemIsDir or flag2.itemIsFile) and flag2.itemRenamed
            and (flag1.itemIsDir or flag2.itemIsFile) and flag1.itemRenamed then
                print("文件夹or文件修改名字")
                if hs.fs.displayName(paths[2]) then
                    print("文件夹or文件存在")
                    s.changeDirOrFileName(paths[1], paths[2])
                    return true
                end
            end
        end
        return false
    end

    -- 目录 监测
    s.pathwatcher_fn = function (paths, flagTables, fn)

        if s.isDirOrFileRenane(paths, flagTables) then return end

        for i, path in ipairs(paths) do
            if string.find(path, ".DS_Store") then
                print(".DS_Store file :", path, "不做任何事")
            else
                s.operateFile(path, flagTables[i])
            end
        end
    end
    return s
end
--- for watch hammerspoon file
-- watch_hammerPath = QSWatch()
-- -- watch_hammerPath.watchPath  = hs.configdir -- /Users/joyspace/.hammerspoon
-- -- watch_hammerPath.targetPath = "/Volumes/MACHigh/Users/qinshaobo/.hammerspoon"
-- watch_hammerPath.watchPath  = hs.configdir
-- watch_hammerPath.targetPath = "/Volumes/WorkDisk/Work工作/MyCode/Lua/hammerSpoon/"
--
-- g_watch_SyncFloder_file = hs.pathwatcher.new(watch_hammerPath.watchPath,
--     function(paths, flagTables)
--         watch_hammerPath.pathwatcher_fn(paths, flagTables, nil)
--     end
-- ):start()

-- --- wifi watcher
-- wifiwatcher = hs.wifi.watcher.new( function()
--     local net = hs.wifi.currentNetwork()
--     if net then
--         hs.notify.show("WiFi connected", "", net, "")
--     else
--         hs.notify.show("WiFi disconnected", "", "", "")
--     end
-- end)
-- wifiwatcher:start()
--
-- --- for auto sent mail
-- mail_pass = nil -- 输入你的 Email 密码
-- if not mail_pass then
--     local path = "/Volumes/WorkDisk/Temp/password.txt"
--     if hsIsFileExist(path) then
--         local array = qsReadFile(path)
--         mail_pass = array[1]
--     end
-- end
--  ——————————————————— 手动分割线 监测 WIFI打开后 Email to joysnipple@icloud.com  ———————————————————
-- function qsw_sentMail(mail, isShow)
--     local python = [[#!/usr/bin/python
-- # -*- coding: UTF-8 -*-
--
-- import smtplib
-- from email.mime.text import MIMEText
--
-- mail_host = 'smtp.qq.com'
-- mail_user = '501919181'
--
-- ]]
-- .."mail_pass = "..mail_pass.."\n"
-- ..mail..
-- [[
--
-- message = MIMEText(text, 'plain', 'utf-8')
-- message['From'] = sender
-- message['To'] = receivers
-- message['Subject'] = subject
-- try:
--     smtpObj = smtplib.SMTP()
--     smtpObj.connect(mail_host, 25)
--     smtpObj.login(mail_user,mail_pass)
--     smtpObj.sendmail(sender, receivers, message.as_string())
--     print "邮件发送成功"
-- except smtplib.SMTPException:
--     print "Error: 无法发送邮件"
-- ]]
--     local path = hs.configdir.."/script/Email.py"
--     qsSaveOrAddWithStr(path, "w", python)
--
--     hsDelayedFn(0.20, function()
--         local path1 = hs.configdir.."/script/Email.py"
--         local ret = hs.execute("python "..path1)
--         if isShow then
--             show(ret)
--             print("python "..path1, ret)
--         end
--     end)
-- end
--
-- function sendMailWithContentWithEdit()
--     mail = hsReadPasteboard()
--     if qsIsFindInLower(mail, "sender") and qsIsFindInLower(mail, "subject")
--     and qsIsFindInLower(mail, "receivers") and qsIsFindInLower(mail, "text") then
--         qsw_sentMail(mail, true)
--     else
--         show("Error: sent no Templete")
--         return
--     end
-- end
--
-- local count_qsw_time_doEvery = 0
-- qsw_time_doEvery = hs.timer.doEvery(10, function()
--     -- 1. 获取 Wifi and Len IP
--     local array = hs.network.addresses("en1")
--     for i,v in ipairs(hs.network.addresses("en0")) do
--         array[#array + 1] = v
--     end
--
--     count_qsw_time_doEvery = count_qsw_time_doEvery + 1
--     if count_qsw_time_doEvery > 2 then
--         print("i am not sent")
--         qsw_time_doEvery:stop()
--     end
--
--     if #array == 0 then return end
--     for i,v in ipairs(array) do
--         if qsIsFindInLower(v, "192.168.31.120") then
--             print("本机")
--             return
--         end
--     end
--
--     print("to sent")
--     -- 获取 经纬度
--     local dis = hs.location.get()
--     if dis then
--         local info = ""
--             for k,v in pairs(dis) do
--             info = info.."key :"..k.." var :"..v
--         end
--         qsw_sentMail([[sender = '501919181@qq.com'
-- receivers = 'joysnipple@icloud.com'
-- subject = 'auot sent mail'
-- text = ']]..info.." time :"..qsOsTime().."'", nil)
--         print("i am sented")
--         qsw_time_doEvery:stop()
--     else
--         print("location not found")
--     end
-- end):start()


--- for IME 输入法
function chineseIME()
    if not hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM.ITABC") then
        hs.keycodes.setMethod("Pinyin - Simplified")
    end
end
function englishIME()
    if not hs.keycodes.currentSourceID("com.apple.keylayout.ABC") then
        hs.keycodes.setLayout("U.S.")
    end
end
function ime_watcher(appName, eventType)
    if eventType == hs.application.watcher.activated then
        local appsChinese = {
            "QQ", "WeChat", "微信"
        }
        for i,v in ipairs(appsChinese) do
            if qsIsFindInLower(appName, v) then
                chineseIME()
                print("chineseIME")
                return
            end
        end
        englishIME()
        print(appName, "englishIME")
    end
end

--- for copy 双击 拖动鼠标 监测
local eventTime = 0
eventLeftMouseUp = hs.eventtap.new( { hs.eventtap.event.types.leftMouseDown,
                                      hs.eventtap.event.types.leftMouseDragged,
                                      hs.eventtap.event.types.leftMouseUp, },
    function(arg)
        -- qsPrintTable(arg)
        local type = arg:getType()
        if type == hs.eventtap.event.types.leftMouseDragged then
            eventTime = os.clock() + 1.0
            -- print("dragged :", eventTime)
            return
        end

        if type == hs.eventtap.event.types.leftMouseUp then
            if eventTime == 0 then
                eventTime = os.clock()
                return
            end

            if (os.clock() - eventTime ) > 0.021 then
                eventTime = os.clock()
                -- 检测 shift down
                local shift = arg:getFlags()
                if not shift["shift"] then
                    return
                end
            end

            print("copy: ", eventTime, "---", os.clock() - eventTime)
            hsDelayedFn(0.2, function() koKeyStroke({'cmd'}, 'c') end)
            eventTime = 0
        end
    end
)
function copy_watcher(appName, eventType)
    if (eventType == hs.application.watcher.activated) then
        local appArr = { "Quiver","Xcode","Safari 浏览器","Dash", "Atom"}
        for i,v in ipairs(appArr) do
            if qsIsFindInLower(appName, v) then
                eventLeftMouseUp:start()
                print("watch ", v)
                return
            else
                eventLeftMouseUp:stop()
            end
        end
    end
end

qsAppWatcher = hs.application.watcher.new(function(appName, eventType, app)
    ime_watcher(appName, eventType)
    copy_watcher(appName, eventType)
end)
qsAppWatcher:start()



--


--
