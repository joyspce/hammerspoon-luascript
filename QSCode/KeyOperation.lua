-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/12/04 22:22
-- Use    : KeyOperation

-- 特殊字符如下：(). % + - * ? [ ^ $  也作为以上特殊字符的转义字符 %

-- stroke Key
function koKeyStroke(mods, key)
    hs.eventtap.event.newKeyEvent(mods, key, true):post()
    --  can not add delay      hsDelayedFn
    hs.eventtap.event.newKeyEvent(mods, key, false):post()
end
-- //———————————————————————————— mouse action ————————————————————————————
function koMouseTap(point)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, point):post()
    hsDelayedFn(0.1, function()
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, point):post()
    end)
end
function koMouseDragged()
    if _koIsLeftMouseUp and hyperyKey.triggered then
        local point = hs.mouse.getAbsolutePosition()
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, point):post()
        hsDelayedFn(0.01, koMouseDragged)
    else
        local point = hs.mouse.getAbsolutePosition()
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, point):post()
        _koIsLeftMouseUp = false
    end
end

-- ctrl.add('d', "鼠标左键点下", koMouseDown, koMouseUp)
_koIsLeftMouseUp = false
function koMouseUp()
    print("koMouseUp")
    _koIsLeftMouseUp = false
end
function koMouseDown()
    if _koIsLeftMouseUp then
        koMouseUp()
    else
        print("koMouseDown")
        _koIsLeftMouseUp = true
        local point = hs.mouse.getAbsolutePosition()
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, point):post()
        koMouseDragged()
    end
end

-- ctrl.add('h',     "键盘 H左← J下↓ K上↑ L右→ ", function() koStrokeDown('Left') end)
-- ctrl.add('j',  nil,  function() koStrokeDown('Down') end)
-- ctrl.add('k',  nil,  function() koStrokeDown('Up') end)
-- ctrl.add('l',  nil,  function() koStrokeDown('Right') end)
local _koIsStrokeCount = 0
function koStrokeDown(key)
    _koIsStrokeCount = _koIsStrokeCount + 1
    hsDelayedFn(0.2, function()
        if _koIsStrokeCount > 1 then
            koKeyStroke({}, key)
            koKeyStroke({}, key)
        end
        _koIsStrokeCount = 0
    end)
    koKeyStroke({}, key)
end
-- ctrl.add('o',  "tmux 1.o next 2.n next 3.create window",
--     {koTmux_o_next, koTmux_n_next, koTmux_n_createWindow})
qsk_delay = 0.3
qsk_keyTab = {"iTerm2", "终端"}
-- Ctrl+b	o	选择下一面板
function koTmux_o_next()
    hsIsWindowWithAppNamesFn(qsk_keyTab, "Error : 我不在 iTerm2 下", function()
        koKeyStroke({'ctrl'}, 'b')
        hsDelayedFn(qsk_delay, function()
            koKeyStroke({}, 'o')
        end)
    end)
end
-- Ctrl+b	n	切换到下一窗口
function koTmux_n_next()
    hsIsWindowWithAppNamesFn(qsk_keyTab, "Error : 我不在 iTerm2 下", function()
        koKeyStroke({'ctrl'}, 'b')
        hsDelayedFn(qsk_delay, function()
            koKeyStroke({}, 'n')
        end)
    end)
end
-- Ctrl+b	c	新建窗口
function koTmux_n_createWindow()
    hsIsWindowWithAppNamesFn(qsk_keyTab, "Error : 我不在 iTerm2 下", function()
        koKeyStroke({'ctrl'}, 'b')
        hsDelayedFn(qsk_delay, function()
            koKeyStroke({}, 'c')
        end)
    end)
end
-- ctrl.add('0',  "tmux 1.vertical 2.horizontal",
--     {koTmux_split_vertical, koTmux_split_horizontally})
-- Ctrl+b " - split pane horizontally
function koTmux_split_horizontally()
    hsIsWindowWithAppNamesFn(qsk_keyTab, "Error : 我不在 iTerm2 下", function()
        koKeyStroke({'ctrl'}, 'b')
        hsDelayedFn(qsk_delay, function()
            hs.eventtap.keyStrokes('"')
        end)
    end)
end
-- Ctrl+b % - 将当前窗格垂直划分
function koTmux_split_vertical()
    hsIsWindowWithAppNamesFn(qsk_keyTab, "Error : 我不在 iTerm2 下", function()
        koKeyStroke({'ctrl'}, 'b')
        hsDelayedFn(qsk_delay, function()
            hs.eventtap.keyStrokes('%')
        end)
    end)
end
-- -- 重复自动操作键盘  -- time时间 times次数 ...键盘Keys
-- ctrl.add('8',  "AutoKeys 秒 次数 key1 key2...", koStrokeInEditByPasteboard)
-- 0.5 times \ Down
-- "⇪ + 8  时间 次数 ...键盘Keys"
function koStrokeInEditByPasteboard()
    hsTextPrompt("自动操作", "0.5 times \\ Down", "0.1 10 \\ Down",  function(text)
        if text and  #text > 1 then
            local array = qsSplit(text, " ")
            local interval = tonumber(array[1]);
            table.remove(array, 1)
            local times  = tonumber(array[1]) or 2;
            table.remove(array, 1)
            local len = #arr;
            for i=1, (times * (len + 1)) do
                hs.timer.doAfter(interval * i, function()
                    local key = arr[i % (len + 1)]
                    if string.find(key, "0x") then key = tonumber(key) end
                    hs.eventtap.keyStroke({}, key, 1000)
                end)
            end
        end
    end)
end



--
