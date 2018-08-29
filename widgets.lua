
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com


if widgets then return end
widgets = true;

-------  analogclock
if not aclockcenter then
    aclockcenter = {x= qsl_mainScreenW - 195, y=325}
end
-- hs.drawing.arc(centerPoint, radius, startAngle, endAngle)
function drawingArc( centerPoint, radius, startAngle, endAngle, setFill, setStrokeWidth, setStrokeColor )

    local cirle = hs.drawing.arc( centerPoint, radius, startAngle, endAngle);
    cirle:setFill(setFill)
    if setStrokeWidth then cirle:setStrokeWidth(setStrokeWidth) end
    if setStrokeColor then cirle:setStrokeColor(setStrokeColor) end
    cirle:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    cirle:setLevel(hs.drawing.windowLevels.desktopIcon)
    cirle:show()
    return cirle;
end

local seccolor = {red=158/255,blue=158/255,green=158/255,alpha=0.5}
local tofilledcolor = {red=1,blue=1,green=1,alpha=0.5}
local secfillcolor = {red=158/255,blue=158/255,green=158/255,alpha=0.2}
local mincolor = {red=24/255,blue=215/255,green=135/255,alpha=0.95}
local hourcolor = {red=246/255,blue=39/255,green=89/255,alpha=0.95}

local analogClockViews = {};
function showAnalogClock()
    if not bgcirle then

        imagerect = hs.geometry.rect(aclockcenter.x-100,aclockcenter.y-100,200,200)
        imagedisp = hs.drawing.image(imagerect,"./resources/watchbg.png")
        imagedisp:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        imagedisp:setLevel(hs.drawing.windowLevels.desktopIcon)
        imagedisp:show()

        analogClockViews[#analogClockViews + 1] = imagerect;

        array = {
                {aclockcenter,80,0,360, false, 1, seccolor},
                {aclockcenter,55,0,360, false, 3, tofilledcolor},
                {aclockcenter,40,0,360, false, 3, tofilledcolor},
        }

        for _, var in ipairs(array) do
            local view = drawingArc( var[1], var[2], var[3], var[4], var[5], var[6], var[7] );
            analogClockViews[#analogClockViews + 1] = view;
        end


        local sechand =   drawingArc( aclockcenter,80,0,0,   true,  1, seccolor )
        sechand:setFillColor(secfillcolor)
        analogClockViews[#analogClockViews + 1] = sechand;

        local array1 = {
            {aclockcenter,55,0,0, false, mincolor},      -- minhand1
            {aclockcenter,54,0,0, false, mincolor},      -- minhand2
            {aclockcenter,53,0,0, false, mincolor},      -- minhand3
            {aclockcenter,40,0,0, false, hourcolor},     -- hourhand1
            {aclockcenter,39,0,0, false, hourcolor},     -- hourhand2
            {aclockcenter,38,0,0, false, hourcolor},     -- hourhand3
        }

        for _, var in ipairs(array1) do
            local view = drawingArc( var[1], var[2], var[3], var[4], var[5] );
            view:setStrokeColor(var[6])
            analogClockViews[#analogClockViews + 1] = view;
        end


        if clocktimer == nil then
            clocktimer = hs.timer.doEvery(1,function() updateClock() end)
        else
            clocktimer:start()
        end
    else
        clocktimer:stop()
        clocktimer=nil
        for i= 1, #analogClockViews do analogClockViews[i]:delete() end
        analogClockViews = nil;
    end
end
function updateClock()

    local secnum = math.tointeger(os.date("%S"))
    local minnum = math.tointeger(os.date("%M"))
    local hournum = math.tointeger(os.date("%I"))
    local seceangle = 6*secnum
    local mineangle = 6*minnum+6/60*secnum
    local houreangle = 30*hournum+30/60*minnum+30/60/60*secnum

    analogClockViews[#analogClockViews-6]:setArcAngles(0,seceangle)

    analogClockViews[#analogClockViews-5]:setArcAngles(0,mineangle)
    analogClockViews[#analogClockViews-4]:setArcAngles(0,mineangle)
    analogClockViews[#analogClockViews-3]:setArcAngles(0,mineangle)

    if houreangle >= 360 then houreangle = houreangle - 360 end

    analogClockViews[#analogClockViews-2]:setArcAngles(0,houreangle)
    analogClockViews[#analogClockViews-1]:setArcAngles(0,houreangle)
    analogClockViews[#analogClockViews]  :setArcAngles(0,houreangle)
end

if not launch_analogclock then
    showAnalogClock()
    launch_analogclock = true
 end
------- analogclock

local netSpeedMenu = hs.menubar.new()
netSpeedMenu:setClickCallback( function()
    -- hs.execute("caffeinate -t 3600")
    hs.caffeinate.startScreensaver()
    --show("1小时后关屏")
end)

function gain_after() in_seq2  = hs.execute(in_str); out_seq2 = hs.execute(out_str) end

function data_diff()
    in_seq1  = hs.execute(in_str)
    out_seq1 = hs.execute(out_str)
    if gainagain == nil then
        gainagain = hs.timer.doAfter(1,function() in_seq2 = hs.execute(in_str) out_seq2 = hs.execute(out_str) end)
    else
        gainagain:start()
    end

    if out_seq2 ~= nil then
        in_diff = in_seq1 - in_seq2
        out_diff = out_seq1 - out_seq2
        if in_diff/1024 > 1024 then
            kbin = string.format("%.2f",in_diff/1024/1024) .. 'm'
        else
            kbin = string.format("%.1f",in_diff/1024) .. 'k'
        end
        if out_diff/1024 > 1024 then
            kbout = string.format("%.2f",out_diff/1024/1024) .. 'm'
        else
            kbout = string.format("%.1f",out_diff/1024) .. 'k'
        end
        disp_str = 'D'..kbin..'U'..kbout..' '
        netSpeedMenu:setTitle(qsww_getWeathetNow().. disp_str)
    end
end
local activeInterface = hs.network.primaryInterfaces()
if activeInterface ~= false then
    in_str = 'netstat -ibn | grep -e ' .. activeInterface .. ' -m 1 | awk \'{print $7}\''
    out_str = 'netstat -ibn | grep -e ' .. activeInterface .. ' -m 1 | awk \'{print $10}\''
    data_diff()
    if nettimer == nil then
        nettimer = hs.timer.doEvery(3,data_diff)
    else
        nettimer:start()
    end
end

---- 番茄时间
local tomatoTimeManView, tomatoTimeDelay;
local tmTimeCount = 0;
local endPlaySound;

function tomatoClicked()
    tmTimeCount = 0;
    tomatoTimeDelay:stop()

    tomatoTimeManView:removeFromMenuBar();
    endPlaySound:stop();
end
local endPlaySoundDelay;
function setTomatoTitle()
    tmTimeCount  = tmTimeCount + 1
    local minute = math.floor(tmTimeCount/60);

    if tmTimeCount % 2 == 0 then
        tomatoTimeManView:setTitle( ":  " );
    else
        if minute == 0 then
            tomatoTimeManView:setTitle( "-  " );
        else
            tomatoTimeManView:setTitle( minute.."  " );
        end
    end
    hs.sound.getByFile(hs.configdir.."/resources/ticking.mp3"):play();
    -- 大于25分钟
    if tmTimeCount >= 1500 then
        tmTimeCount = 0;
        tomatoTimeDelay:stop()

        endPlaySound:play();

        if not endPlaySoundDelay then
            endPlaySoundDelay = qshs_delayedFn( 3, function()
                if not endPlaySound:isPlaying() then
                    tomatoTimeManView:removeFromMenuBar();
                    endPlaySoundDelay:stop();
                else
                    endPlaySoundDelay:start();
                end
            end)
        end
        endPlaySoundDelay:start();
    end
end
function runtomatoTimeManViewager()
    if endPlaySoundDelay then endPlaySoundDelay:stop(); end
    if tmTimeCount > 0 then tomatoClicked() return; end
    if not tomatoTimeManView then
        tomatoTimeManView = hs.menubar.new();
        tomatoTimeManView:setClickCallback(tomatoClicked)
    end
    tomatoTimeManView:returnToMenuBar()

    if not tomatoTimeDelay then tomatoTimeDelay = hs.timer.doEvery(1, setTomatoTitle) end
    tomatoTimeDelay:start();

    if not endPlaySound then
        endPlaySound = hs.sound.getByFile(hs.configdir.."/resources/123456.mp3")
    else
        endPlaySound:stop();
    end
end
---- /番茄时间



-- // * 1. 显示 View
qsww_weather_obj = nil
if not qsww_weather_obj then
    local obj = {}
    qsww_weather_obj = obj
    local width, height, wordsColor = 340, 165, {red=1.0, blue=1.0, green= 1.0, alpha = 0.6}
    obj.canvas = hs.canvas.new({
        x = qsl_mainScreenW - width- 20, y = 45,
        w = width, h = height
    }):show()
    obj.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    obj.canvas:level(hs.canvas.windowLevels.desktopIcon)

    -- canvas background
    obj.canvas[1] = {
        action = "fill",
        type = "rectangle",
        fillColor = {hex="#000000", alpha=0.3},
        roundedRectRadii = {xRadius=5, yRadius=5},
    }
    local many, heightY, height = 4, 10, 26
    local widthX = 15
    for i=1, many do
        obj.canvas[i+1] = {
            id = "temperature_title",
            type = "text",
            text = "",
            textSize = 18,
            textColor = wordsColor,
            textAlignment = "left",
            frame = {x = widthX, y = heightY, w = width, h = height}
        }
        heightY = heightY + height
    end
    -- time left
    obj.canvas[6] = {
        type = "text",
        text = "time left",
        textColor = wordsColor,
        textSize = 18,
        frame = { x = 225, y = heightY+10, w = width, h = height }
    }
    -- heightY = heightY + height
    -- indicator background
    obj.canvas[7] = {
        type = "image",
        image = hs.image.imageFromPath(hs.configdir.."/resources/timebg.png"),
        frame = { x = 0, y = heightY, w = tostring(185/280), h = tostring(30/125)}
    }
    -- light indicator
    local indicatorHeight = 20
    obj.canvas[8] = {
        action = "fill",
        type = "rectangle",
        fillColor = {hex="#FFFFFF", alpha=0.2},
        frame = { x = widthX+2, y = heightY+5, w = 190, h = indicatorHeight},
    }
    -- indicator mask
    obj.canvas[9] = {
        action = "fill",
        type = "rectangle",
        frame = { x = widthX+2, y = heightY+5, w = 190, h = indicatorHeight},
    }
    -- color indicator
    obj.canvas[10] = {
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
        },
    }
end

-- /// * 1. left days
function _qsww_setLeft_days()
    local nowtable = os.date("*t")
    qsww_weather_obj.canvas[6].text = "Left "..365-nowtable.yday.." days"
    local nowyear = nowtable.year
    local secs_since_epoch = os.time()
    local yearstartsecs_since_epoch = os.time({year=nowyear, month=1, day=1, hour=0})
    local nowyear_elapsed_secs = secs_since_epoch - yearstartsecs_since_epoch
    local yearendsecs_since_epoch = os.time({year=nowyear+1, month=1, day=1, hour=0})
    local nowyear_total_secs = yearendsecs_since_epoch - yearstartsecs_since_epoch
    qsww_weather_obj.canvas[9].frame.w = 190 * nowyear_elapsed_secs/nowyear_total_secs
    print("_qsww_setTime")
end
_qsww_setLeft_days()

-- //———————————————————————————— need net ————————————————————————————
_qsww_lunarDate = nil
-- 农历
function _qsww_setLunarDate()
    -- 获取当天数据
    -- {"status":200,"message":"success","data":{"year":2018,"month":7,"day":12,"lunarYear":2018,"lunarMonth":5,"lunarDay":29,"cnyear":"贰零壹捌 ","cnmonth":"五","cnday":"廿九","hyear":"戊戌","cyclicalYear":"戊戌","cyclicalMonth":"己未","cyclicalDay":"乙巳","suit":"纳采,订盟,嫁娶,祭祀,沐浴,塑绘,开光,出火,治病,习艺,伐木,盖屋,竖柱,上梁,安床,作灶,安碓磑,挂匾,掘井,纳畜","taboo":"出行,安葬,造桥","animal":"狗","week":"Thursday","festivalList":[],"jieqi":{"7":"小暑","23":"大暑"},"maxDayInMonth":29,"leap":false,"lunarYearString":"戊戌","bigMonth":false}}
    qshs_asyncGet("https://www.sojson.com/open/api/lunar/json.shtml", function(body)
        local lunaDates = hs.json.decode(body)
        if (lunaDates["status"] == 200) then
            local data = lunaDates["data"]
            -- 农历: 2018 戊戌 狗年 五月 廿九 or "jieqi":{"7":"小暑","23":"大暑"}
            -- 年                   2018               戊戌
            local text =  "农历: ("..data["year"]..")"..data["cyclicalYear"].." "..data["animal"].."年 "
            -- 月 日
            text = text..data["cnmonth"].."月 "..data["cnday"].." "
            -- 节日
            local festival = ""
            local festivalList = data["festivalList"]
            for i,v in ipairs(festivalList) do festival = festival..v.." " end
            _qsww_lunarDate = text..festival
            qsww_weather_obj.canvas[2].text = _qsww_lunarDate
        end
    end)
end
_qsww_setLunarDate()
--  每天 00.01 运行
qsww_weather_obj.timer = hs.timer.doAt("00:01", function()
    _qsww_setLeft_days()
    _qsww_setLunarDate()
end)
-- 本地 IP
_qsww_localIP_adress = nil
function _qsww_setLocalIp()
    print("2. 获取本地IP")
    -- lan
    local array = hs.network.addresses("en0")
    if not array or #array == 0 then array = hs.network.addresses("en1") end
    for i,v in ipairs(array) do
        if #v < 17 then
            _qsww_localIP_adress = "网络: "..v
            qsww_weather_obj.canvas[5].text = _qsww_localIP_adress
            return
        end
    end
end
_qsww_setLocalIp()
-- 外网IP
_qsww_IP_Address = nil
function _qsww_setIP()
    qshs_asyncGet("http://members.3322.org/dyndns/getip",  function(body)
        local ipAddress = string.gmatch(body, "%d+%.%d+%.%d+%.%d+")()
        if ipAddress and (#ipAddress > 10) then
            qsww_weather_obj.canvas[5].text = _qsww_localIP_adress.." 外"..ipAddress
            _qsww_IP_Address = ipAddress
        end
    end)
end
_qsww_setIP()

-- 天气
local        qsww_city = "深圳"
local      weatherHttp = "http://api.k780.com/?"
local  weatherKey_orig = "appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4"
local    weatherKey_me = "appkey=35033&sign=4e2f45408afef906ff706fb8c41db1b3"

local     weather_curr = nil
local temperature_curr = nil

-- 给 widgets 访问
function qsww_getWeathetNow()
    if weather_curr and temperature_curr then return weather_curr.." "..temperature_curr.." " end
    return ""
end

function _qsww_setWeather(url, key)
    print("5. 获取天气 url :", url, "key: ", key)
    qshs_asyncGet(url..key, function(body)
        local weatherDict = hs.json.decode(body)
        if (weatherDict["success"] == "1") then
            weatherDict = weatherDict["result"]
            weather_curr     = weatherDict["weather_curr"]
            temperature_curr = weatherDict["temperature_curr"]
            print("\n", weather_curr, "\n", temperature_curr)

            qsww_weather_obj.canvas[3].text = "天气: "..weatherDict["weather"].." "
            ..weatherDict["temperature"].." "..weatherDict["wind"].." "..weatherDict["winp"]
        else
            _qsww_setWeather(weatherHttp.."app=weather.today&format=json&"..weatherKey_me.."&weaid=", key)
            print("Error: 从我自己的站号获取天气")
        end
    end)
end
-- 获取城市 Key
function _qsww_findCityKey(city)
    local url = weatherHttp.."app=weather.city&appkey=35033&sign=4e2f45408afef906ff706fb8c41db1b3&format=json"
    qshs_asyncGet(url, function(body)
        local cityDics = hs.json.decode(body)
        if (cityDics["success"] and cityDics["success"] == "1") then
            for key,var in pairs(cityDics["result"]) do
                local cityTemp = var["citynm"]
                if string.find(city, cityTemp)then
                    _qsww_setWeather(weatherHttp.."app=weather.today&format=json&"..weatherKey_orig.."&weaid=", key)
                    break
                end
            end
        end
    end)
end
_qsww_findCityKey(qsww_city)
_qsww_runEveryTime = hs.timer.doEvery(60 * 3, function()
    if not _qsww_lunarDate then _qsww_setLunarDate() end
    if not _qsww_IP_Address then _qsww_setIP() end
    _qsww_findCityKey(qsww_city)
end)

-- // * 4. 股市
local    _qsww_waitTime = 20
local      stockSH_orig = 0;
local      stockSZ_orig = 0;

local           stockSH = nil
local stockSH_yesterday = nil
local           stockSZ = nil
local stockSZ_yesterday = nil
function _qsww_stockSetVar(market, stock, yesterday)

    if market == "sh" then
        stockSH, stockSH_yesterday = stock, yesterday
    elseif market == "sz" then
        stockSZ, stockSZ_yesterday = stock, yesterday
    end

    if not stockSZ or not stockSH then return end

    local shUnDown = '⇡'
    local up = (tonumber(stockSH) or tonumber(stockSH_yesterday) or 0) - (tonumber(stockSH_yesterday) or tonumber(stockSH) or 0)
    if up < 0 then shUnDown = '⇣' end
    shUnDown= string.format("%d%s", math.floor(math.abs(up)+0.4) , shUnDown)

    local szUpDown = '⇡'
    up = tonumber(stockSZ) - tonumber(stockSZ_yesterday)
    if up < 0 then szUpDown = '⇣' end
    szUpDown = string.format("%d%s", math.floor(math.abs(up)+0.4), szUpDown)

    local text = string.format("股市: 上%s%.3f深%s%.3f", shUnDown, stockSH, szUpDown, stockSZ)

    qsww_weather_obj.canvas[4].text = text
    stockSH = tostring(stockSH)
    stockSZ = tostring(stockSZ)

    if stockSH_orig == stockSH and stockSZ_orig == stockSZ then
        _qsww_waitTime = _qsww_waitTime + _qsww_waitTime
    else
        stockSH_orig = stockSH
        stockSZ_orig = stockSZ
        _qsww_waitTime = 20
    end
end
function _qsww_stock()
    -- // * 1. 上市 var hq_str_sh000001="上证指数,2827.0823,2831.1837,2810.1569,2837.5092,2804.4929,0,0,80575377,97588619359,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2018-07-16,13:49:17,00"; Y2831.1837
    qshs_asyncGet("http://hq.sinajs.cn/list=sh000001", function(body)
        local array = arrayWithStringAndSplit(body, ",")
        if (array and #array > 4) then
            local yesterday = array[3]
            local stock = array[4]
            _qsww_stockSetVar("sh", stock, yesterday)
        end
    end)
    -- // * 2. 深市
    qshs_asyncGet("http://hq.sinajs.cn/list=sz399001", function(body)
        local array = arrayWithStringAndSplit(body, ",")
        if (array and #array > 4)  then
            local yesterday = array[3]
            local stock = array[4]
            _qsww_stockSetVar("sz", stock, yesterday)
        end
    end)
end
function _qsww_isInTime(nowDate, hour, sec, toHour, toSec)
    -- key :hour var :13 type :number
    -- key :sec var :33 type :number
    local allSec =  nowDate.hour * 60 + nowDate.sec;
    local beginSec = hour * 60 + sec
    local endSec   = toHour * 60 + toSec
    return (allSec > beginSec and endSec > allSec)
end
function _qsww_stockRepeat()
    _qsww_stock()
    local dateTab = os.date("*t", os.time())
    -- // * 1. wday，星期6为7 星期天为1  不工作
    if (dateTab.wday == 1 or dateTab.wday == 7) then return end

    if _qsww_isInTime(dateTab, 9, 30, 11, 30) or _qsww_isInTime(dateTab, 13, 0, 15, 0) then
        qshs_delayedFn(_qsww_waitTime, _qsww_stockRepeat)
        print("qsww_stockRepeat")
    end
end
_qsww_stockRepeat()
_qsww_doMoring    = hs.timer.doAt("9:30",  _qsww_stockRepeat)
_qsww_doAfternoon = hs.timer.doAt("13:00", _qsww_stockRepeat)


-- qshs_asyncGet("http://ip.chinaz.com/getip.aspx", function(body)
--     local ipAddress = string.gmatch(body, "%d+%.%d+%.%d+%.%d+")()
--     if ipAddress and (#ipAddress > 10) then
--         print("获取外网IP", ipAddress)
--         qsww_weather_obj.canvas[5].text = qsww_localIP.." 外"..ipAddress
--         _qsww_findCity(body)
--     end
-- end)

-- -- shell 获取
-- local path = hs.configdir.."/Text/ipAddressess.txt"
-- os.execute("ipconfig getifaddr en0 >"..path)
-- local arr = qsl_arrayRead(path)
-- if (not arr or #arr==0) then
--     os.execute("ipconfig getifaddr en1 >"..path)
--     arr = qsl_arrayRead(path)
--     if (arr and #arr > 0) then return arr[1] end
-- else
--     return arr[1]
-- end
-- return nil

-- local locationCityKey = nil
-- -- 获取城市 信息
-- function _qsww_findCity(city)
--     print("3. 获取city:"..city)
--
--     if locationCityKey then
--         _qsww_findWeather(weatherHttp.."app=weather.today&format=json&"..weatherKey_orig.."&weaid=", locationCityKey)
--     else
--         local url = weatherHttp.."app=weather.city&appkey=35033&sign=4e2f45408afef906ff706fb8c41db1b3&format=json"
--         qshs_asyncGet(url, function(body)
--             local cityDics = hs.json.decode(body)
--             if (cityDics["success"] ~= "1") then return end
--
--             for key,var in pairs(cityDics["result"]) do
--                 local cityTemp = var["citynm"]
--                 if string.find(city, cityTemp)then
--                     -- print("天气收到city数据: ",city, key);
--                     locationCityKey = key
--                     _qsww_findWeather(weatherHttp.."app=weather.today&format=json&"..weatherKey_orig.."&weaid=", key)
--                     break
--                 end
--             end
--         end)
--     end
--
--     -- delayed time 600seconds 获取一次
--     qshs_delayedFn(60*10, function()
--         print("qsww_findCity delayed running "..delayedTime)
--         _qsww_findCity(city)
--     end)
-- end

--


--
