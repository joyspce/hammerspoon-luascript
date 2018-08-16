
-- 特殊字符如下：(). % + - * ? [ ^ $  也作为以上特殊字符的转义字符 %

qsk_delay = 0.3
qsk_keyTab = {"iTerm2", "终端"}
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
    if _qsk_is_stroke and hyperyKeyIsStrock then
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


--
