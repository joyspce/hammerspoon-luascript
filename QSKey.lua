


-- 特殊字符如下：(). % + - * ? [ ^ $  也作为以上特殊字符的转义字符 %

--- "⌥ + D:   鼠标左键点下"
_qsaIsLeftMouseUp = false
function qsa_mouseUp()
    print("qsa_mouseUp")
    _qsaIsLeftMouseUp = false
end
function qsa_mouseDragged()
    if _qsaIsLeftMouseUp and hyperyKey.triggered then
        qshs_leftMouseDragged(hs.mouse.getAbsolutePosition())
        qsl_delayedFn(0.01, qsa_mouseDragged)
    else
        qshs_leftMouseUp(hs.mouse.getAbsolutePosition())
        _qsaIsLeftMouseUp = falseddddddd
    end
end
function qsa_mouseDown()
    if _qsaIsLeftMouseUp then
        qsa_mouseUp()
    else
        print("qsa_mouseDown")
        _qsaIsLeftMouseUp = true
        qshs_leftMouseDown(hs.mouse.getAbsolutePosition())
        qsa_mouseDragged()
    end
end

qsk_delay = 0.3
qsk_keyTab = {"iTerm2", "终端"}

qsk_double_click = 0
function qsk_double_click_capslock_equal_esckey()
    qsk_double_click = qsk_double_click + 1
    qsl_delayedFn(0.3, function()
        if qsk_double_click > 1 then
            qshs_isWindowWithAppNamesFn({"iTerm2", "终端", "Atom"}, nil, function()
                qsl_keyStroke({}, 'escape')
            end)
        end
        qsk_double_click = 0
    end)
end

-- Ctrl+b	o	选择下一面板
function qsk_tmux_o_next()
    qshs_isWindowWithAppNamesFn(qsk_keyTab, "Error : 我不在 iTerm2 下", function()
        qsl_keyStroke({'ctrl'}, 'b')
        qsl_delayedFn(qsk_delay, function()
            qsl_keyStroke({}, 'o')
        end)
    end)
end
-- Ctrl+b " - split pane horizontally
function qsk_tmux_split_horizontally()
    qshs_isWindowWithAppNamesFn(qsk_keyTab, "Error : 我不在 iTerm2 下", function()
        qsl_keyStroke({'ctrl'}, 'b')
        qsl_delayedFn(qsk_delay, function()
            hs.eventtap.keyStrokes('"')
        end)
    end)
end
-- Ctrl+b % - 将当前窗格垂直划分
function qsk_tmux_split_vertical()
    qshs_isWindowWithAppNamesFn(qsk_keyTab, "Error : 我不在 iTerm2 下", function()
        qsl_keyStroke({'ctrl'}, 'b')
        qsl_delayedFn(qsk_delay, function()
            hs.eventtap.keyStrokes('%')
        end)
    end)
end
-- Ctrl+b	n	切换到下一窗口
function qsk_tmux_n_next()
    qshs_isWindowWithAppNamesFn(qsk_keyTab, "Error : 我不在 iTerm2 下", function()
        qsl_keyStroke({'ctrl'}, 'b')
        qsl_delayedFn(qsk_delay, function()
            qsl_keyStroke({}, 'n')
        end)
    end)
end
-- Ctrl+b	c	新建窗口
function qsk_tmux_n_createWindow()
    qshs_isWindowWithAppNamesFn(qsk_keyTab, "Error : 我不在 iTerm2 下", function()
        qsl_keyStroke({'ctrl'}, 'b')
        qsl_delayedFn(qsk_delay, function()
            qsl_keyStroke({}, 'c')
        end)
    end)
end

_qsk_is_stroke = false
function qsk_strokeUp() _qsk_is_stroke = false end

function _qsk_strokeDown(key)
    -- print(_qsk_is_stroke)
    if _qsk_is_stroke and hyperyKey.triggered then
        qsl_keyStroke({}, key)
        qsl_delayedFn(0.2, function() _qsk_strokeDown(key) end)
    else
        _qsk_is_stroke = false
    end
end
local qsk_strokeDown_count = 0
function qsk_strokeDown(key)
    _qsk_is_stroke = true
    qsk_strokeDown_count = qsk_strokeDown_count + 1
    qsl_delayedFn(0.3, function()
        if qsk_strokeDown_count > 1 then
            _qsk_strokeDown(key)
            _qsk_strokeDown(key)
            _qsk_strokeDown(key)
        end
    end)
    qsl_delayedFn(0.4, function() qsk_strokeDown_count = 0 end)
    _qsk_strokeDown(key)
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
