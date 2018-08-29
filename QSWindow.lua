
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com


-- "⇪ + 空格 窗口最大化or合适大小"
function qswScreenResizeFullOrMiddle()
    qshs_getFocusedWindowFn(function(win)
        local frame = win:screen():frame()
        frame.x, frame.w = frame.x + 2, frame.w - 4;
        local fw = win:frame();
        -- full screen
        if fw.y < 1 then
            qsl_keyStroke({'cmd','ctrl'}, 'f')
            hs.timer.doAfter(0.03, qswScreenResizeFullOrMiddle)
        elseif not(math.abs(frame.x - fw.x) > 2 or math.abs(frame.y - fw.y) > 2
                or math.abs(frame.w - fw.w) > 2 or math.abs(frame.h - fw.h) > 2) then
            local percent = 0.15
            frame.x = frame.x + frame.w * percent;
            frame.y = frame.y + frame.h * percent;
            frame.w = frame.w * (1 - percent * 2);
            frame.h = frame.h * (1 - percent * 2);
        end
        win:setFrame(frame)
    end)
end
-- "⌥ + ↩:     move screen to next window"
function qswMoveScerrnToNextWindow()
    qshs_getFocusedWindowFn(function(win)
        -- app size
        local frame = win:frame()
        if frame.x > qsl_mainScreenW then -- move to left
            frame.x = 0
        else
            frame.x = qsl_mainScreenW -- move to right
        end
        win:setFrame(frame)
    end)
    qshs_getFocusedWindowFn(function(win)
        local frame = win:screen():frame()
        frame.x, frame.w = frame.x + 2, frame.w - 4;
        win:setFrame(frame)
    end)
    local mousepoint = hs.mouse.getAbsolutePosition()
    if mousepoint.x > qsl_mainScreenW then
        hs.mouse.setAbsolutePosition({x = mousepoint.x - qsl_mainScreenW, y = mousepoint.y})  -- move to left
    else
        hs.mouse.setAbsolutePosition({x = mousepoint.x + qsl_mainScreenW, y = mousepoint.y})  -- move to right
    end
end
-- "⇪ + ⇧ + C   窗口移动到中心"
function qswMoveWindowToCenter()
    qshs_getFocusedWindowFn(function(win)
        local frame = win:frame()
        local mainFrame = win:screen():frame()
        frame.x = mainFrame.x + (mainFrame.w - frame.w) * 0.5;
        frame.y = (mainFrame.h - frame.h) * 0.5;
        win:setFrame(frame);
    end)
end

-- toggle window within different monitor
function qsw_sendWindowNextMonitor()
    local win = hs.window.focusedWindow()
    local nextScreen = win:screen():next()
    win:moveToScreen(nextScreen)
-- function qswMoveScerrnToNextWindowSameSize()
--     qshs_getFocusedWindowFn(function(win)
--         local frame = win:frame()
--         local mainFrame = win:screen():frame()
--         if (frame.x > qsl_mainScreenW) then -- to small
--             frame.x = frame.x - mainFrame.x
--             hs.mouse.setAbsolutePosition({x = mainFrame.w /2, y = mainFrame.h /2})
--         else
--             frame.x = frame.x + mainFrame.w
--             hs.mouse.setAbsolutePosition({x = mainFrame.w /2 + mainFrame.w , y = mainFrame.h /2})
--         end
--         win:setFrame(frame)
--     end)
--     qswMoveWindowToCenter()
-- end
end

local grid
function qsw_showGrid()
    if (not grid ) then
        grid = require("hs.grid")
    end
    grid:show()
end

local qswShowSpaceBarOnce = false
function _qswMovetoSpecifyWindow(whichOne, win)
    if qswShowSpaceBarOnce then
        qswShowSpaceBarOnce = false
        qsl_keyStroke({'ctrl'}, 'Up')
    end
    qshs_delayedFn(0.3, qsl_fn(qsl_keyStroke,{'ctrl'}, tostring(whichOne)))
    -- qshs_delayedFn(0.7, win:focus())
    qshs_delayedFn(0.7, function() qswMoveScerrnToNextWindow() end)
end
-- "⇪ + 1-4    移动当前APP到桌面 1-4"
function moveToWhichWindow(whichOne) return function() _moveToWhichWindow(whichOne) end end
function _moveToWhichWindow(whichOne)
    qshs_getFocusedWindowFn(function(win)
        local frame = win:frame()
        -- 获取主屏
        local mainFrame = win:screen():frame()
        if (mainFrame.x ~= 0) then
            -- 获取当前鼠标
            local mousepoint = hs.mouse.getAbsolutePosition()
            if (mousepoint.x > qsl_mainScreenW) then
                _qswMovetoSpecifyWindow(whichOne, win)
            else
                show("window is not in laptop screen!")
            end
            return
        end
        -- 全屏下
        if (frame.y < 1) then
            qsl_keyStroke({'cmd','ctrl'}, 'f')
            hs.timer.doAfter(0.6, function() _moveToWhichWindow(whichOne) end)
            return
        end

        local mousepoint = hs.mouse.getAbsolutePosition()
        -- frame 大小的情况下
        if frame.w < 180 then frame.x = frame.w -200; end
        local point = { x = frame.x + 180 , y = frame.y + 3 };

        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, point):post();
        qshs_delayedFn(0.05,function() hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, point):post() end)
        qshs_delayedFn(0.13,function() hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, point):post() end)
        qshs_delayedFn(0.15,function() hs.mouse.setAbsolutePosition(mousepoint) end);
        qsl_keyStroke({'ctrl'}, tostring(whichOne))
    end)
end

-- "⇪ + ⇧ + <   窗口移动到左边 > 到右边"\
-- +---------+
-- |HERE|    |
-- +---------+
function qswMoveWindowToLeft()
    qshs_getFocusedWindowFn(function(win)
        local frame = win:screen():frame()
        frame.w = frame.w * 0.5;
        win:setFrame(frame)
    end)
end
-- +---------+
-- |    |HERE|
-- +---------+
function qswMoveWindowToRight()
    qshs_getFocusedWindowFn(function(win)
        local frame = win:screen():frame()
        if (frame.x > 1435) then
            frame.w = frame.w * 0.5
            frame.x = frame.w + 1440
        else
            frame.x = frame.w * 0.5  --  > Right
            frame.w = frame.x
        end
        win:setFrame(frame)
    end)
end
-- "⇪ + ↑ 窗口上 ↓窗口下"
function qswMoveWindowUp()
    qshs_getFocusedWindowFn(function(win)
        local frame = win:screen():frame()
        frame.h = frame.h * 0.5;
        win:setFrame(frame)
    end)
end
function qswMoveWindowDown()
    qshs_getFocusedWindowFn(function(win)
        local frame = win:screen():frame()
        frame.h = frame.h * 0.5;
        frame.y  = frame.h + 23
        win:setFrame(frame)
    end)
end
-- "⇪ + ⇧ + /   窗口最小化"
function qswWindowMinimize() qshs_getFocusedWindowFn(function(win) win:minimize() end) end
-- "⇪ + ⇧ + -   窗口缩小 + 窗口放大" "⇪ + ⇧ + J   窗口向左移动一格 L右I上K下"
local gap = 50;
function qswResizeScreen(whichKind)
    return function()
         qshs_getFocusedWindowFn(function(win)
             frame = win:frame();
             if whichKind == 5 then        -- Left
                 frame.x = frame.x - gap;
             elseif whichKind == 6 then    -- Right
                 frame.x = frame.x + gap;
             elseif whichKind == 7 then    -- Up
                 frame.y = frame.y - gap;
             elseif whichKind == 8 then    -- Down
                 frame.y = frame.y + gap;
             elseif whichKind == 10 then
                 frame.w = frame.w - gap;
                 frame.h = frame.h - gap;
                 frame.x = frame.x + gap * 0.5
                 frame.y = frame.y + gap * 0.5
             elseif whichKind == 11 then
                 frame.w = frame.w + gap;
                 frame.h = frame.h + gap;
                 frame.x = frame.x - gap * 0.5
                 frame.y = frame.y - gap * 0.5
             end
             win:setFrame(frame)
         end)
    end
end
-- "⇪ + ⇧ + ← 窗口减少一格 → 大一格"
function screenMoveShift(whichKind)
    return function()
        qshs_getFocusedWindowFn(function(win)
            local frame =  win:frame();
            if whichKind == 1 then          -- 窗口左上移动
                frame.x = frame.x - gap;
                frame.y = frame.y - gap;
            elseif whichKind == 2 then      -- 窗口右下移动
                frame.x = frame.x + gap;
                frame.y = frame.y + gap;
            elseif whichKind == 3 then      -- 窗口右上移动
                frame.x = frame.x + gap;
                frame.y = frame.y - gap;
            elseif whichKind == 4 then      -- 窗口左下移动
                frame.x = frame.x - gap;
                frame.y = frame.y + gap;
            elseif whichKind == 5 then      -- Left
                frame.w = frame.w - gap;
            elseif whichKind == 6 then      -- Right
                frame.w = frame.w + gap;
            elseif whichKind == 7 then      -- Up
                frame.h = frame.h - gap;
            elseif whichKind == 8 then      -- Down
                frame.h = frame.h + gap;
            end
            win:setFrame(frame);
        end)
    end
end

--{'r',  "⇪ + R",  "Fouse Next Screen", qsw_fouseNextScreen},
function qsw_fouseNextScreen()
    local origPoint = hs.mouse.getAbsolutePosition()
    -- 1. 获取当前window
    local win = hs.window.frontmostWindow()
    local frame = win:screen():frame()
    if frame.x > 0 then
        --show("在副屏") -> 主屏
        local point = {x =qsl_mainScreenW/2, y =qsl_mainScreenH/2}
        qshs_mouseTap(point)
    else
        --show("在主屏") -> 副屏
        local point = {x = qsl_mainScreenW + qsl_mainScreenW/2, y = qsl_mainScreenH/2}
        qshs_mouseTap(point)
    end
    qshs_delayedFn(0.1, function() hs.mouse.setAbsolutePosition(origPoint) end)
end

--  "⌥ + q       显示空间栏"
function qswShowSpaceBar()
    -- * 1. 鼠标移动 显示 空间栏
    -- 获取鼠标原点\
    local mousepoint = hs.mouse.getAbsolutePosition()
    -- 获取当前总window
    qshs_getFocusedWindowFn(function(win)
        local frame = win:screen():frame()
        -- 取屏center
        hs.mouse.setAbsolutePosition({x = frame.x + frame.w *0.5, 20 })
        qswShowSpaceBarOnce = true;
        -- * 2. 按 controller + up
        hs.eventtap.keyStroke({'ctrl'}, 'Up', 1000)
        -- * 3. 移动到原点
        hs.timer.doAfter(0.2, function() hs.mouse.setAbsolutePosition({x = mousepoint.x, y = mousepoint.y}) end);
        hs.timer.doAfter(3, function() qswShowSpaceBarOnce = false end);
    end)
end
-- {'h',  "⇪ + H",  "显示 1.隐藏文件", qsl_fn(qsl_keyStroke,{'shift', 'cmd'}, '.'), "2.App name", qsw_showCurrentAppName},
function qsw_showCurrentAppName()
    qshs_getFocusedWindowFn(function(win)
        local app = win:application()
        if (app) then
            print("current app:"..app:name())
            show("current app:"..app:name())
        else
            show("not find window")
        end
    end)
end
-- {"a",     "⇪ + A",  "提示 1.当前APP", hs.hints.windowHints, "2.MousePoint", qsw_mouseHighlight},
qsw_circle = nil
qsw_timerCircle = nil
function qsw_mouseHighlight()
    function qsw_fn_circle()
        qsw_circle:delete()
        qsw_circle = nil
        if qsw_timerCircle then qsw_timerCircle:stop() end
        qsw_timerCircle = nil
    end
    -- Delete an existing highlight if it exists
    if qsw_circle then qsw_fn_circle() end
    -- Get the current co-ordinates of the mouse pointer
    mousepoint = hs.mouse.getAbsolutePosition()
    -- Prepare a big red circle around the mouse pointer
    qsw_circle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
    qsw_circle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=0.9})
    qsw_circle:setFill(false)
    qsw_circle:setStrokeWidth(10)
    qsw_circle:show()
    -- Set a timer to delete the circle after 3 seconds
    qsw_timerCircle = hs.timer.doAfter(3, function()
        qsw_fn_circle()
    end)
end


--
