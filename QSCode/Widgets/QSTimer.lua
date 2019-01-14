-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/28 00:57
-- Use    : xxx


local qSTimerRun = nil
function QSTimer()
    if qSTimerRun then return qSTimerRun end

    local s = {}
    qSTimerRun = s

    function drewView()
        local textSize = 130
        local width = textSize * 2
        local frame = hs.screen.mainScreen():frame()
        local rect = {x = frame.w - width - 20 , y = 410, w = width, h = textSize}
        local  color = {red=1, blue=0.85, green=0.85, alpha = 0.75}
        s.canvas = hs.canvas.new(rect):show()
        s.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
        s.canvas:level(hs.canvas.windowLevels.desktopIcon)

        s.canvas[1] = {
            id = "temperature_title",
            type = "text",
            text = "",
            textSize = 130,
            textColor = color,
            textAlignment = "left",
            frame = {x = 0, y = 0, w = width, h = textSize}
        }
    end
    drewView()

    -- property

    s.doEvery = nil

    -- method
    s.stop = function()
        if s.doEvery then
            s.doEvery:stop()
            s.canvas:delete()
            s.doEvery = nil
            s.canvas = nil
            s = nil
            qSTimerRun = nil
        end
    end

    s.second = 0
    s.timer_set = function(isStop)
        local min = math.floor(s.second/60 + 0.4)
        if s.second % 2 == 0 then
            s.canvas[1].text = min..". "
        else
            s.canvas[1].text = min
        end

        if isStop then
            s.canvas[1].text = min .. "-"
        end

        s.second = s.second - 1
        if s.second < 0 then
            s.stop()
            hs.caffeinate.startScreensaver()
        end
    end

    s.start = function()
        s.timer_set()
        if not s.doEvery then
            s.doEvery = hs.timer.doEvery(1, s.timer_set)
        else
            if not s.doEvery:running() then s.doEvery:start() end
        end
    end

    return s
end

function qst_timer()
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr= nil
        return
    end

    _ModalMgr = ModalMgr()

    function exit() _ModalMgr.remove() _ModalMgr = nil end

    local timer = QSTimer()

    function run(actionStr)
        return function()
            if type(actionStr) == "string" then
                if actionStr == "close" then
                    timer.stop()
                else
                    -- startOrPause
                   if timer.doEvery:running() then
                       timer.doEvery:stop()
                       timer.timer_set(true)
                   else
                       timer.doEvery:start()
                   end
                end
            else
                timer.second = timer.second + (actionStr * 60)
                timer.start()
            end
            exit()
        end
    end

    -- key, message, pressedfn
    local bindKeys = {
        {key = 'escape', message ="Exit Window Edit Mode", pressedfn = run("close")},
        {key = 'q',      message ="Exit Window Edit Mode", pressedfn = run("close")},
        {key = 'tab',message ="Show Cheatsheet", pressedfn = _ModalMgr.show},

        {key = 'o', message ="+ 1 Hour", pressedfn = run(60)},
        {key = 'h', message ="+ 30 Second", pressedfn = run(30)},
        {key = 't', message ="+ 10 Second", pressedfn = run(10)},
        {key = 'f', message ="+ 5 Second", pressedfn = run(5)},
        {key = 's', message ="start or pause", pressedfn = run("startOrPause")},
        {key = 'c', message ="close", pressedfn = run("close")},
    }
    _ModalMgr.run(bindKeys)
    _ModalMgr.show()
end
