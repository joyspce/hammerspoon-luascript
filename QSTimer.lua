
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

-- indexOrKe_yTable(theTable,theValue)
qst_drewView_obj = nil
function qst_drewView()
    if qst_drewView_obj then return end
    local textSize = 130
    local width = textSize * 2
    local rect = {x = qsl_mainScreenW - width - 20 , y = 410, w = width, h = textSize}
    local  color = {red=1, blue=0.85, green=0.85, alpha = 0.75}
    local obj = {}
    obj.canvas = hs.canvas.new(rect):show()
    obj.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    obj.canvas:level(hs.canvas.windowLevels.desktopIcon)

    obj.canvas[1] = {
        id = "temperature_title",
        type = "text",
        text = "",
        textSize = 130,
        textColor = color,
        textAlignment = "left",
        frame = {x = 0, y = 0, w = width, h = textSize}
    }
    qst_drewView_obj = obj
end

qst_drewView_timer = nil
function qst_timer_startOrPause()
    if qst_drewView_timer then
        if qst_drewView_timer:running() then
            qst_drewView_timer:stop()
        else
            qst_drewView_timer:start()
        end
    end
end

qst_min = 0
qst_second = 0
function qst_timer_close()
    if qst_drewView_timer then
        qst_drewView_timer:stop()
        qst_drewView_timer = nil
        qst_min = 0
        qst_second = 0
    end
    if qst_drewView_obj then qst_drewView_obj.canvas[1].text = "" end
end

function qst_fn_timer_set()
    if qst_second % 2 == 0 then
        qst_drewView_obj.canvas[1].text = qst_min..". "
    else
        qst_drewView_obj.canvas[1].text = qst_min
    end

    if qst_min == 0 then
        qst_timer_close()
        hs.caffeinate.startScreensaver()
    end

    qst_second = qst_second + 1
    if qst_second >= 60 then
        qst_second = 0
        qst_min = qst_min - 1
    end
end

function retFnWithSecond(num)
    return function()
        qst_drewView()
        if not qst_drewView_timer then
            qst_drewView_timer = hs.timer.doEvery(1, qst_fn_timer_set)
        end
        if not qst_drewView_timer:running() then qst_drewView_timer:start() end
        qst_min = qst_min + num
    end
end

-- 't',  "⇪ + T",  "1.计算器", qst_timer,
function qst_timer()
    local array = { "+ 1 Hour",
                    "+ 30 Second",
                    "+ 15 Second",
                    "+ 5 Second",
                    "+ 1 Second",
                    "start or pause",
                    "close",}
    local fus   = { retFnWithSecond(60),
                    retFnWithSecond(30),
                    retFnWithSecond(15),
                    retFnWithSecond(5),
                    retFnWithSecond(1),
                    qst_timer_startOrPause,
                    qst_timer_close, }

    local choices = {}
    for i,v in ipairs(array) do choices[#choices + 1] = {text = v} end

    qsl_chooser(choices,
    function(chosen)
        if chosen then
            local index = indexOrKeyTable(array, chosen["text"])
            if index > 0 then fus[index]() end
        end
    end)
end




--
