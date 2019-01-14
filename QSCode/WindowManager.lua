-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/29 00:58
-- Use    : WindowManager

-- wmFocusedWindowFnFrame(function(win) end)
function wmFocusedWindow()
    local win = hs.window.focusedWindow()
    if win then return win end
    show("没有找到主窗口")
end
function wmFocusedWindowFnFrame(fn)
    local win = wmFocusedWindow()
    if win then fn(win, win:frame()) end
end
wm_sereenW = qs_mainScreenW

-- ctrl.add("a",          "Next moniter full size",    wmMoveToNextMoniterFullSize)
function wmMoveToNextMoniterFullSize()
    wmMoveToNextMoniterSameSize()
    wmFocusedWindowFnFrame(function(win)
        local frame =  win:screen():frame()
        frame.x, frame.w = frame.x + 2, frame.w - 4
        win:setFrame(frame)
    end)
end
-- ctrl.add('w',          "Next moniter same size",    wmMoveToNextMoniterSameSize)
function wmMoveToNextMoniterSameSize()
    local win = wmFocusedWindow()
    if win then
        local nextScreen = win:screen():next()
        win:moveToScreen(nextScreen)

        local mousepoint = hs.mouse.getAbsolutePosition()
        if mousepoint.x > wm_sereenW then
            hs.mouse.setAbsolutePosition({x = mousepoint.x - wm_sereenW, y = mousepoint.y})  -- move to left
        else
            hs.mouse.setAbsolutePosition({x = mousepoint.x + wm_sereenW, y = mousepoint.y})  -- move to right
        end
    end
end
-- ctrl.add({0x31,  "□"}, "窗口最大化or合适大小",         wmScreenFullOrMiddle)
function wmScreenFullOrMiddle()
    wmFocusedWindowFnFrame(function(win, winFrame)
        local frame = win:screen():frame()
        frame.x, frame.w = frame.x + 2, frame.w - 4
        -- full screen
        if win:isFullScreen() then
            koKeyStroke({'cmd','ctrl'}, 'f')
            hs.timer.doAfter(0.03, wmScreenFullOrMiddle)
        elseif not(math.abs(frame.x - winFrame.x) > 2 or math.abs(frame.y - winFrame.y) > 2
                or math.abs(frame.w - winFrame.w) > 2 or math.abs(frame.h - winFrame.h) > 2) then
            local percent = 0.15
            frame.x = frame.x + frame.w * percent;
            frame.y = frame.y + frame.h * percent;
            frame.w = frame.w * (1 - percent * 2);
            frame.h = frame.h * (1 - percent * 2);
        end
        win:setFrame(frame)
    end)
end

-- ctrl.add({'Left', '←'}, "MoveToLeft",   wmMovetoLeft)
function wmMovetoLeft()
    local winwin = WinWin()
    winwin.stash()
    winwin.moveAndResize("halfleft")
end
-- ctrl.add({'Right', '→'}, "MoveToRight",  wmMovetoRight)
function wmMovetoRight()
    local winwin = WinWin()
    winwin.stash()
    winwin.moveAndResize("halfright")
end

-- ctrl.add({'1', "1-4"}, "移动当前APP到桌面 1-4", moveToWhichWindow(1))
-- ctrl.add('2',          nil,                   moveToWhichWindow(2))
-- ctrl.add('3',          nil,                   moveToWhichWindow(3))
-- ctrl.add('4',          nil,                   moveToWhichWindow(4))
function wmMoveToWhichWindow(whichWindow)
    local win = wmFocusedWindow()
    local frame = win:frame()

    -- 全屏下
    if (win:isFullScreen()) then
        koKeyStroke({'cmd','ctrl'}, 'f')
        hs.timer.doAfter(1.0, function() wmMoveToWhichWindow(whichWindow) end)
    else
        local mousepoint = hs.mouse.getAbsolutePosition()
        -- frame 大小的情况下
        if frame.w < 180 then frame.x = frame.w -100; end
        local point = { x = frame.x + 180 , y = frame.y + 3 };
        if (frame.y > 0) then
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, point):post();
            hsDelayedFn(0.05,function() hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, point):post() end)
            hsDelayedFn(0.13,function() hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, point):post() end)
        end

        hsDelayedFn(0.15,function() hs.mouse.setAbsolutePosition(mousepoint) end);
        koKeyStroke({'ctrl'}, tostring(whichWindow))
    end
end
-- ctrl.add('q',   "1.显示空间栏 2.Cheatsheet", {wmShowSpaceBar, function() wmShowSpaceBar(true) end})
function wmShowSpaceBar(isShowCheatsheet)
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr= nil
        return
    end

    _ModalMgr = ModalMgr()

    function exit()
        if _ModalMgr then _ModalMgr.remove() end
        _ModalMgr= nil
    end
    ---- 显示 Mission Control
    -- 获取鼠标原点
    local mousepoint = hs.mouse.getAbsolutePosition()
    -- * 1. 鼠标移动 to 调度中心
    hs.mouse.setAbsolutePosition({mousepoint.x, y = 20})
    -- * 2. 按 controller + up
    hs.application.launchOrFocus("Mission Control")
    -- hs.eventtap.keyStroke('ctrl', 'Up')
    -- * 3. 移动到原点
    hs.timer.doAfter(0.2, function() hs.mouse.setAbsolutePosition(mousepoint) end)

    function pressedfnMove(key)
        return function()
            exit()
            local mousepoint = hs.mouse.getAbsolutePosition()
            koMouseTap(mousepoint)
            hs.timer.doAfter(0.6, function()
                _ = hs.window.focusedWindow() and wmMoveToWhichWindow(key)
            end)
        end
    end

    function pressedfn(key)
        return function()
            hs.timer.doAfter(0.1, function() koKeyStroke({''}, 'escape') end)
            if key then
                hs.timer.doAfter(0.4, function() koKeyStroke({'ctrl'}, key) end)
            end
            exit()
            hs.timer.doAfter(0.6, function() koMouseTap(mousepoint) end)
        end
    end

    -- key, message, pressedfn
    local bindKeys = {
        {key = 'escape', message ="Exit 调度中心", pressedfn = function()
            exit() koKeyStroke({''}, 'escape')
        end},
        {key = 'q',      message ="Exit 调度中心", pressedfn = function()
            exit() koKeyStroke({''}, 'escape')
        end},
        {key = 'tab',message ="Show 显示调度中心", pressedfn = _ModalMgr.show},

        {key = "1", message = '移动选定App到桌面1',  pressedfn = pressedfnMove("1")},
        {key = "2", message = '移动选定App到桌面2',  pressedfn = pressedfnMove("2")},
        {key = "3", message = '移动选定App到桌面3',  pressedfn = pressedfnMove("3")},
        {key = "4", message = '移动选定App到桌面4',  pressedfn = pressedfnMove("4")},

        {key = 'a',  message = '移动到桌面1', pressedfn = pressedfn("1")},
        {key = 's',  message = '移动到桌面2', pressedfn = pressedfn("2")},
        {key = 'd',  message = '移动到桌面3', pressedfn = pressedfn("3")},
        {key = 'f',  message = '移动到桌面4', pressedfn = pressedfn("4")},
    }
    _ModalMgr.run(bindKeys)
    _ = isShowCheatsheet and _ModalMgr.show()
end

function WinWin()
    local s = {}
    -- property
    s.history = {}

    s.gridparts = 30

    local function isInHistory(windowid)
        for idx,val in ipairs(s.history) do
            if val[1] == windowid then return idx end
        end
        return false
    end

    -- method
    s.stepMove = function(direction)
        wmFocusedWindowFnFrame( function(cwin)
            local cscreen = cwin:screen()
            local cres = cscreen:fullFrame()
            local stepw = cres.w/s.gridparts
            local steph = cres.h/s.gridparts
            local wtopleft = cwin:topLeft()

            local dict = {
                left = {x=wtopleft.x-stepw, y=wtopleft.y},
                right = {x=wtopleft.x+stepw, y=wtopleft.y},
                up = {x=wtopleft.x, y=wtopleft.y-steph},
                down = {x=wtopleft.x, y=wtopleft.y+steph}, }
            cwin:setTopLeft(dict[direction])
        end)
    end

    s.stepResize = function(direction)
        wmFocusedWindowFnFrame( function(cwin)
            local cscreen = cwin:screen()
            local cres = cscreen:fullFrame()
            local stepw = cres.w/s.gridparts
            local steph = cres.h/s.gridparts
            local wsize = cwin:size()

            local dict = {
                left  = {w=wsize.w-stepw, h=wsize.h},
                right = {w=wsize.w+stepw, h=wsize.h},
                up    = {w=wsize.w, h=wsize.h-steph},
                down  = {w=wsize.w, h=wsize.h+steph}, }
            cwin:setSize(dict[direction])
        end)
    end

    s.stash = function()
        wmFocusedWindowFnFrame( function(cwin)
            local winid = cwin:id()
            local winf = cwin:frame()
            local id_idx = isInHistory(winid)
            if id_idx then
                -- Bring recently used window id up, so they wouldn't get removed because of exceeding capacity
                if id_idx == 100 then
                    local tmptable = s.history[id_idx]
                    table.remove(s.history, id_idx)
                    table.insert(s.history, 1, tmptable)
                    -- Make sure the history for each application doesn't reach the maximum (100 items)
                    local id_history = s.history[1][2]
                    if #id_history > 100 then table.remove(id_history) end
                    table.insert(id_history, 1, winf)
                else
                    local id_history = s.history[id_idx][2]
                    if #id_history > 100 then table.remove(id_history) end
                    table.insert(id_history, 1, winf)
                end
            else
                -- Make sure the history of window id doesn't reach the maximum (100 items).
                if #s.history > 100 then table.remove(s.history) end
                -- Stash new window id and its first history
                local newtable = {winid, {winf}}
                table.insert(s.history, 1, newtable)
            end
        end)
    end

    s.moveAndResize = function(option)
        wmFocusedWindowFnFrame( function(cwin)
            local cscreen = cwin:screen()
            local cres = cscreen:fullFrame()
            local stepw = cres.w/s.gridparts
            local steph = cres.h/s.gridparts
            local wf = cwin:frame()

            if "center" == option then cwin:centerOnScreen() return end

            local dict = {
                halfleft  = {x=cres.x, y=cres.y, w=cres.w/2, h=cres.h},
                halfright = {x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h},
                halfup    = {x=cres.x, y=cres.y, w=cres.w, h=cres.h/2},
                halfdown  = {x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2},
                cornerNW  = {x=cres.x, y=cres.y, w=cres.w/2, h=cres.h/2},
                cornerNE  = {x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h/2},
                cornerSW  = {x=cres.x, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2},
                cornerSE  = {x=cres.x+cres.w/2, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2},
                fullscreen= {x=cres.x, y=cres.y, w=cres.w, h=cres.h},
                expand    = {x=wf.x-stepw, y=wf.y-steph, w=wf.w+(stepw*2), h=wf.h+(steph*2)},
                shrink    = {x=wf.x+stepw, y=wf.y+steph, w=wf.w-(stepw*2), h=wf.h-(steph*2)}
            }
            cwin:setFrame(dict[option])
        end)
    end

    s.moveToScreen = function(direction)
        wmFocusedWindowFnFrame( function(cwin)
            local cscreen = cwin:screen()
            local dict = {
                up = function() cwin:moveOneScreenNorth() end,
                down = function() cwin:moveOneScreenSouth() end,
                left = function() cwin:moveOneScreenWest() end,
                right = function() cwin:moveOneScreenEast() end,
                next = function() cwin:moveToScreen(cscreen:next()) end,
            }
            dict[direction]()
        end)
    end

    s.undo = function()
        local cwin = hs.window.focusedWindow()
        local winid = cwin:id()
        -- Has this window been stored previously?
        local id_idx = isInHistory(winid)
        if id_idx then
            -- Bring recently used window id up, so they wouldn't get removed because of exceeding capacity
            if id_idx == 100 then
                local tmptable = s.history[id_idx]
                table.remove(s.history, id_idx)
                table.insert(s.history, 1, tmptable)
                local id_history = s.history[1][2]
                cwin:setFrame(id_history[1])
                -- Rewind the history
                local tmpframe = id_history[1]
                table.remove(id_history, 1)
                table.insert(id_history, tmpframe)
            else
                local id_history = s.history[id_idx][2]
                cwin:setFrame(id_history[1])
                local tmpframe = id_history[1]
                table.remove(id_history, 1)
                table.insert(id_history, tmpframe)
            end
        end
    end

    s.redo = function()
        local cwin = hs.window.focusedWindow()
        local winid = cwin:id()
        -- Has this window been stored previously?
        local id_idx = isInHistory(winid)
        if id_idx then
            -- Bring recently used window id up, so they wouldn't get removed because of exceeding capacity
            if id_idx == 100 then
                local tmptable = s.history[id_idx]
                table.remove(s.history, id_idx)
                table.insert(s.history, 1, tmptable)
                local id_history = s.history[1][2]
                cwin:setFrame(id_history[#id_history])
                -- Play the history
                local tmpframe = id_history[#id_history]
                table.remove(id_history)
                table.insert(id_history, 1, tmpframe)
            else
                local id_history = s.history[id_idx][2]
                cwin:setFrame(id_history[#id_history])
                local tmpframe = id_history[#id_history]
                table.remove(id_history)
                table.insert(id_history, 1, tmpframe)
            end
        end
    end

    s.centerCursor = function()
        local cwin = hs.window.focusedWindow()
        local wf = cwin:frame()
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        if cwin then
            -- Center the cursor one the focused window
            hs.mouse.setAbsolutePosition({x=wf.x+wf.w/2, y=wf.y+wf.h/2})
        else
            -- Center the cursor on the screen
            hs.mouse.setAbsolutePosition({x=cres.x+cres.w/2, y=cres.y+cres.h/2})
        end
    end
    return s
end
-- ctrl.add('r',   "1.Window Edit 2.Cheatsheet",  {wmWindowEditMode, function() wmWindowEditMode(true) end})
function wmWindowEditMode()
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr= nil
        return
    end
    _ModalMgr = ModalMgr()
    local winiwn = WinWin()

    function exit()
        _ModalMgr.remove()
        _ModalMgr = nil
        winiwn = nil
    end

    -- key, message, pressedfn
    local bindKeys = {
        {key = 'escape', message ="Exit Window Edit Mode", pressedfn = exit },
        {key = 'q',      message ="Exit Window Edit Mode", pressedfn = exit },
        -- Cheatsheet
        {key = 'tab',message ="Show Cheatsheet", pressedfn = _ModalMgr.show},

        { key = 'A',message = 'Move Leftward',  pressedfn = function() winiwn.stepMove("left") end},
        { key = 'D',message = 'Move Rightward', pressedfn = function() winiwn.stepMove("right") end},
        { key = 'W',message = 'Move Upward',    pressedfn = function() winiwn.stepMove("up") end},
        { key = 'S',message = 'Move Downward',  pressedfn = function() winiwn.stepMove("down") end},
        { key = 'H',message = 'Lefthalf of Screen',  pressedfn = function() winiwn.stash() winiwn.moveAndResize("halfleft") end},
        { key = 'L',message = 'Righthalf of Screen', pressedfn = function() winiwn.stash() winiwn.moveAndResize("halfright") end},
        { key = 'K',message = 'Uphalf of Screen',    pressedfn = function() winiwn.stash() winiwn.moveAndResize("halfup") end},
        { key = 'J',message = 'Downhalf of Screen',  pressedfn = function() winiwn.stash() winiwn.moveAndResize("halfdown") end},
        { key = 'Y',message = 'NorthWest Corner', pressedfn = function() winiwn.stash() winiwn.moveAndResize("cornerNW") end},
        { key = 'O',message = 'NorthEast Corner', pressedfn = function() winiwn.stash() winiwn.moveAndResize("cornerNE") end},
        { key = 'U',message = 'SouthWest Corner', pressedfn = function() winiwn.stash() winiwn.moveAndResize("cornerSW") end},
        { key = 'I',message = 'SouthEast Corner', pressedfn = function() winiwn.stash() winiwn.moveAndResize("cornerSE") end},
        { key = 'F',message = 'Fullscreen',       pressedfn = function() winiwn.stash() winiwn.moveAndResize("fullscreen") end},
        { key = 'C',message = 'Center Window',    pressedfn = function() winiwn.stash() winiwn.moveAndResize("center") end},
        { key = '=',message = 'Stretch Outward',  pressedfn = function() winiwn.moveAndResize("expand") end, nil, function() winiwn.moveAndResize("expand") end},
        { key = '-',message = 'Shrink Inward',    pressedfn = function() winiwn.moveAndResize("shrink") end, nil, function() winiwn.moveAndResize("shrink") end},
        { shift = 'shift', key = 'H', message = 'Move Leftward', pressedfn = function() winiwn.stepResize("left") end, nil, function() winiwn.stepResize("left") end},
        { shift = 'shift', key = 'L', message = 'Move Rightward', pressedfn =  function() winiwn.stepResize("right") end, nil, function() winiwn.stepResize("right") end},
        { shift = 'shift', key = 'K', message = 'Move Upward', pressedfn = function() winiwn.stepResize("up") end, nil, function() winiwn.stepResize("up") end},
        { shift = 'shift', key = 'J', message = 'Move Downward', pressedfn = function() winiwn.stepResize("down") end, nil, function() winiwn.stepResize("down") end},
        { key = 'left',message = 'Move to Left Monitor', pressedfn = function() winiwn.stash() winiwn.moveToScreen("left") end},
        { key = 'right',message = 'Move to Right Monitor', pressedfn = function() winiwn.stash() winiwn.moveToScreen("right") end},
        { key = 'up',message = 'Move to Above Monitor', pressedfn = function() winiwn.stash() winiwn.moveToScreen("up") end},
        { key = 'down',message = 'Move to Below Monitor', pressedfn = function() winiwn.stash() winiwn.moveToScreen("down") end},
        { key = 'space',message = 'Move to Next Monitor', pressedfn = function() winiwn.stash() winiwn.moveToScreen("next") end},
        { shift = 'cmd', key = 'Z',message = 'Undo Window Manipulation', pressedfn = function() winiwn.undo() end},
        { shift = 'cmd, shift', key = 'Z',message = 'Redo Window Manipulation', pressedfn = function() winiwn.redo() end},
        { key = '`',message = 'Center Cursor', pressedfn = function() winiwn.centerCursor() end},
        }
    _ModalMgr.run(bindKeys)
    _ModalMgr.show()
end

-- ctrl.add({'tab', 'tab'}, "show 1.当前APP 2.App name",   {hs.hints.windowHints, wmShowCurrentAppName})
function wmShowCurrentAppName()
    wmFocusedWindowFnFrame(function(win)
        local app = win:application()
        if (app) then
            show("current app:"..app:name())
        else
            show("not find window")
        end
    end)
end
-- ctrl.add('f',   "Fouse next moniter", wmFouseNextMoniter)
function wmFouseNextMoniter()
    local origPoint = hs.mouse.getAbsolutePosition()
    -- 1. 获取当前window
    local win = hs.window.frontmostWindow()
    local frame = win:screen():frame()
    if frame.x > 0 then
        --show("在副屏") -> 主屏
        local point = {x =wm_sereenW/2, y =qs_mainScreenH/2}
        koMouseTap(point)
    else
        --show("在主屏") -> 副屏
        local point = {x = wm_sereenW + wm_sereenW/2, y = qs_mainScreenH/2}
        koMouseTap(point)
    end
    hsDelayedFn(0.1, function() hs.mouse.setAbsolutePosition(origPoint) end)
end
-- ctrl.add('m',   "MousePoint", wmMouseHighlight)
local circle = nil
local timerCircle = nil
function wmMouseHighlight()
    function fn_circle()
        circle:delete()
        circle = nil
        if timerCircle then timerCircle:stop() end
        timerCircle = nil
    end
    -- Delete an existing highlight if it exists
    if circle then
        fn_circle()
        return
    end
    -- Get the current co-ordinates of the mouse pointer
    mousepoint = hs.mouse.getAbsolutePosition()
    -- Prepare a big red circle around the mouse pointer
    local diameter = 100
    circle = hs.drawing.circle(
        hs.geometry.rect(mousepoint.x-diameter/2, mousepoint.y-diameter/2, diameter, diameter)
    )
    circle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=0.9})
    circle:setFill(false)
    circle:setStrokeWidth(15)
    circle:show()
    -- Set a timer to delete the circle after 3 seconds
    timerCircle = hs.timer.doAfter(3, fn_circle)
end


--
