-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/27 00:50
-- Use    : 显示 View

if ShowboradRun then return end
ShowboradRun = true

-- lua 判断白天
function Showborad()
    local s = {}
    -- property
    function setView()
        local frame = hs.screen.mainScreen():frame()

        local width, height, wordsColor = 340, 165, {red=1.0, blue=1.0, green= 1.0, alpha = 0.6}
        s.canvas = hs.canvas.new({
            x = frame.w - width- 20, y = 45,
            w = width, h = height
        }):show()
        s.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
        s.canvas:level(hs.canvas.windowLevels.desktopIcon)

        -- canvas background
        s.canvas[1] = { action = "fill",
                          type = "rectangle",
                          fillColor = {hex="#000000", alpha=0.3},
                          roundedRectRadii = {xRadius=5, yRadius=5}, }

        local many, heightY, height = 4, 10, 26
        local widthX = 15
        for i = 1, many do
            s.canvas[i+1] = { id = "temperature_title",
                                type = "text",
                                text = "",
                                textSize = 18,
                                textColor = wordsColor,
                                textAlignment = "left",
                                frame = {x = widthX, y = heightY, w = width, h = height} }
            heightY = heightY + height
        end
        -- time left
        s.canvas[6] = { type = "text",
                          text = "time left",
                          textColor = wordsColor,
                          textSize = 18,
                          frame = { x = 225, y = heightY+10, w = width, h = height } }

        -- indicator background
        s.canvas[7] = {
            type = "image",
            image = hs.image.imageFromPath(hs.configdir.."/resources/timebg.png"),
            frame = { x = 0, y = heightY, w = tostring(185/280), h = tostring(30/125)} }
        -- light indicator
        local indicatorHeight = 20
        s.canvas[8] = {
            action = "fill",
            type = "rectangle",
            fillColor = {hex="#FFFFFF", alpha=0.2},
            frame = { x = widthX+2, y = heightY+5, w = 190, h = indicatorHeight}, }
        -- indicator mask
        s.canvas[9] = {
            action = "fill",
            type = "rectangle",
            frame = { x = widthX+2, y = heightY+5, w = 190, h = indicatorHeight}, }
        -- color indicator
        s.canvas[10] = {
            action = "fill",
            type = "rectangle",
            compositeRule = "sourceAtop",
            frame = { x = widthX+2, y = heightY+5, w = 190, h = indicatorHeight},
            fillGradient="linear",
            fillGradientColors = {
                {hex = "#00A0F7"},
                {hex = "#92D2E5"},
                {hex = "#4BE581"},
                {hex = "#EAF25E"},
                {hex = "#F4CA55"},
                {hex = "#E04E4E"},
            }, }
    end
    setView()
    function setLeftDaysView()
        local nowtable = os.date("*t")
        s.canvas[6].text = "Left "..365-nowtable.yday.." days"
        local nowyear = nowtable.year
        local secs_since_epoch = os.time()
        local yearstartsecs_since_epoch = os.time({year=nowyear, month=1, day=1, hour=0})
        local nowyear_elapsed_secs = secs_since_epoch - yearstartsecs_since_epoch
        local yearendsecs_since_epoch = os.time({year=nowyear+1, month=1, day=1, hour=0})
        local nowyear_total_secs = yearendsecs_since_epoch - yearstartsecs_since_epoch
        s.canvas[9].frame.w = 190 * nowyear_elapsed_secs/nowyear_total_secs
    end
    setLeftDaysView()

    -- init
    s.lunarDate = LunarDate() --√
    s.lunarDate.callback = function(text) s.canvas[2].text = text end
    s.lunarDate.run()

    s.weather_curr, s.temperature_curr = "", ""
    s.weather = Weather()
    s.weather.callback = function(text, weather_curr, temperature_curr)
        print("Weather ", weather_curr, temperature_curr, "\n")

        s.weather_curr = weather_curr or ""
        s.temperature_curr = temperature_curr or ""

        s.canvas[3].text = text
    end
    s.weather.run()

    s.stock = StockChinese() --√
    s.stock.callback = function(text) s.canvas[4].text = text end
    s.stock.run()

    s.ip = IPAll()
    s.ip.callback = function(text) s.canvas[5].text = text end
    s.ip.run()

    s.dictDay = {["云"]="🌥",["雾"]="🌥",["阴"]="🌥",["多云"]="⛅️",
                  ["雨"]="🌧",["风"]="🌬",["雪"]="🌨"}
    function isInDayTime()
        local date = os.date("*t", os.time())
        if date.hour > 5 and date.hour < 19 then
            s.dictDay["晴"] = "☀️"
            return true
        else
            s.dictDay["晴"] = "🌝"
            return false
        end
    end
    s.is_Day = isInDayTime()
    s.netSpeedMenu = NetSpeedMenu()
    s.netSpeedMenu.callback = function(title)
        local icon = s.dictDay[s.weather_curr] or ""
        return s.temperature_curr.. s.weather_curr ..icon.." "..title
    end
    --  每天 00.01 运行
    s.timer_doAt = hs.timer.doAt("00:01", function()
        s.lunarDate.run()
        setLeftDaysView()
    end)

    function isInTime(formTime, toTime, nowDate)
        local nowDate = nowDateTab or os.date("*t", os.time())
        local now =  nowDate.hour * 60 + nowDate.sec
        local array = qsSplit(formTime, ":")
        local begin = tonumber(array[1]) * 60 + tonumber(array[1])
        array = qsSplit(toTime, ":")
        local toEnd = tonumber(array[1]) * 60 + tonumber(array[1])
        return (now > begin and toEnd > now)
    end

    function isInStockTime()
        local date = os.date("*t", os.time())
        -- // * 1. wday，星期6为7 星期天为1  不工作
        if (date.wday == 1 or date.wday == 7) then return false end
        return isInTime("9:30", "11:30", date) or isInTime("13:0", "15:0", date)
    end

    s.count = 0

    local isStockRun = isInStockTime()
    local stockText = nil
    local countStop7 = 0

    function stockReset()
        isStockRun = isInStockTime()
        if isStockRun then countStop7 = 0 end
    end

    s.doMoring    = hs.timer.doAt("9:30",  stockReset)
    s.doAfternoon = hs.timer.doAt("13:00", stockReset)

    s.doEvery = hs.timer.doEvery(1, function()

        s.netSpeedMenu.run()

        s.count = s.count + 1

        -- 每个对象 查一下 是否 收到 数据
        if s.count % 30 == 0 then
            local objs = { s.lunarDate, s.weather, s.stock , s.ip} --,
            for i,var in ipairs(objs) do
                if not var.text or 10 > #var.text then
                    var.run()
                    print("doEvery for ", i)
                end
            end

            if countStop7 < 7 then
                -- 4 分钟 测一次
                if s.count % 240 == 0 then isStockRun = isInStockTime() end

                if isStockRun then
                    s.stock.run()
                    if stockText and s.stock.text and stockText == s.stock.text then
                        countStop7 = countStop7 + 1
                    end
                    stockText = s.stock.text
                end
            end
        end

        -- 30分钟
        if s.count % 1800 == 0 then
            s.count = 0
            s.weather.run()
            s.is_Day = isInDayTime()
        end
    end)

    return s
end

showborad = Showborad()


--
