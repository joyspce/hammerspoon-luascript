

--- for IME 输入法
function _chinese()
    if not hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM.ITABC") then
        hs.keycodes.setMethod("Pinyin - Simplified")
    end
end
function _english()
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
            if isContainStr(appName, v) then
                _chinese()
                print("_chinese")
                return
            end
        end
        _english()
        print(appName, "_english")
    end
end

--- for copy 双击 拖动鼠标 监测
local eventTime = 0
eventLeftMouseUp = hs.eventtap.new( { hs.eventtap.event.types.leftMouseDown,
                                      hs.eventtap.event.types.leftMouseDragged,
                                      hs.eventtap.event.types.leftMouseUp, },
    function(arg)
        -- printTab(arg)
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
            qshs_delayedFn(0.2, function() qsl_keyStroke({'cmd'}, 'c') end)
            eventTime = 0
        end
    end
)
function copy_watcher(appName, eventType)
    if (eventType == hs.application.watcher.activated) then
        local appArr = { "Quiver","Xcode","Safari 浏览器","Dash", "Atom"}
        for i,v in ipairs(appArr) do
            if isContainStr(appName, v) then
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
