
--
-- // today weather

local     weatherHttp = "http://api.k780.com/?"
local weatherKey_orig = "appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4"
local   weatherKey_me = "appkey=35033&sign=4e2f45408afef906ff706fb8c41db1b3"

local     weather_curr = nil
local temperature_curr = nil
-- 给 widgets 访问
function qsww_getWeathetNow()
    if not weather_curr or not temperature_curr then return "" end
    return weather_curr.." "..temperature_curr.." "
end

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
        textColor = {hex="#A6AAC3"},
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
    function _qsww_setTime()
        local nowtable = os.date("*t")
        obj.canvas[6].text = "Left "..365-nowtable.yday.." days"
        local nowyear = nowtable.year
        local secs_since_epoch = os.time()
        local yearstartsecs_since_epoch = os.time({year=nowyear, month=1, day=1, hour=0})
        local nowyear_elapsed_secs = secs_since_epoch - yearstartsecs_since_epoch
        local yearendsecs_since_epoch = os.time({year=nowyear+1, month=1, day=1, hour=0})
        local nowyear_total_secs = yearendsecs_since_epoch - yearstartsecs_since_epoch
        obj.canvas[9].frame.w = 190 * nowyear_elapsed_secs/nowyear_total_secs
        print("_qsww_setTime")
    end
    _qsww_setTime()
    obj.timer = hs.timer.doAt("00:01", _qsww_setTime)
end

-- // * 2. weathet and ip
function _qsww_findWeather(url, key)
    print("5. 获取天气 url :", url, "key: ", key)
    hs.http.asyncGet(url..key, nil, function(status, body, headers)

        if (status ~= 200) then return end
        -- to json
        local weatherDics = hs.json.decode(body)

        if (weatherDics["success"] == "1") then

            weatherDics = weatherDics["result"]
            weather_curr     = weatherDics["weather_curr"]
            temperature_curr = weatherDics["temperature_curr"]
            print("\n", weather_curr, "\n", temperature_curr)

            qsww_weather_obj.canvas[3].text = "天气: "..weatherDics["weather"].." "
            ..weatherDics["temperature"].." "..weatherDics["wind"].." "..weatherDics["winp"]
        else
            _qsww_findWeather(weatherHttp.."app=weather.today&format=json&"..weatherKey_me.."&weaid=", key)
            print("Error: 从我自己的站号获取天气")
        end
    end)
end

local locationCityKey = nil
-- 获取城市 信息
function _qsww_findCity(city)
    print("3. 获取city:"..city)

    if not locationCityKey then

        local url = weatherHttp..
        "app=weather.city&appkey=35033&sign=4e2f45408afef906ff706fb8c41db1b3&format=json"

        hs.http.asyncGet(url, nil, function(status, body, headers)
            if (status ~= 200) then return end
            -- to json
            local cityDics = hs.json.decode(body)
            if (cityDics["success"] ~= "1") then return end

            for key,var in pairs(cityDics["result"]) do
                local cityTemp = var["citynm"]
                if (string.find(city, cityTemp ))then
                    -- print("天气收到city数据: ",city, key);
                    locationCityKey = key
                    _qsww_findWeather(weatherHttp.."app=weather.today&format=json&"..weatherKey_orig.."&weaid=", key)
                    break
                end
            end
        end)
    else
        _qsww_findWeather(weatherHttp.."app=weather.today&format=json&"..weatherKey_orig.."&weaid=", locationCityKey)
    end

    -- delayed time 20seconds 获取一次
    local delayedTime = 60*10
    qsl_delayedFn(delayedTime, function() print("qsww_findCity delayed running "..delayedTime) _qsww_findCity(city) end)
end

function qsww_getLocalIp()
    print("2. 获取本地IP网")
    -- lan
    local array = hs.network.addresses("en0")
    if not array or #array == 0 then
        -- wifi
        array = hs.network.addresses("en1")
    end

    for i,v in ipairs(array) do
        if #v < 17 then
            return v
        end
    end
    -- shell 获取
    local path = hs.configdir.."/Text/ipAddress.txt"
    os.execute("ipconfig getifaddr en0 >"..path)
    local arr = qsl_arrayRead(path)
    if (not arr or #arr==0) then
        os.execute("ipconfig getifaddr en1 >"..path)
        arr = qsl_arrayRead(path)
        if (arr and #arr > 0) then return arr[1] end
    else
        return arr[1]
    end
    return nil
end
function _qsww_asIPGetCity()
    print("1. 获取外网IP")
    hs.http.asyncGet("http://ip.chinaz.com/getip.aspx", nil, function(status, body, headers)
        if (status ~= 200) then
            print("Error : status = ", status)
            _qsww_asIPGetCity()
            return
        end
        -- 本地 IP
        local text4 = "网络: "..(qsww_getLocalIp() or "0.0.0.0")
        -- 外网 IP
        local ipaddr = string.gmatch(body, "%d+%.%d+%.%d+%.%d+")()
        -- print(ipaddr)
        if (#ipaddr > 10) then
            text4 = text4.." 外"..ipaddr
        else
            _qsww_asIPGetCity()
            return
        end
        qsww_weather_obj.canvas[5].text = text4
        _qsww_findCity(body)
    end)
end
-- star
_qsww_asIPGetCity()

-- // * 3. 农历
function _qsww_lunarDate()
    -- 获取当天数据
     -- {"status":200,"message":"success","data":{"year":2018,"month":7,"day":12,"lunarYear":2018,"lunarMonth":5,"lunarDay":29,"cnyear":"贰零壹捌 ","cnmonth":"五","cnday":"廿九","hyear":"戊戌","cyclicalYear":"戊戌","cyclicalMonth":"己未","cyclicalDay":"乙巳","suit":"纳采,订盟,嫁娶,祭祀,沐浴,塑绘,开光,出火,治病,习艺,伐木,盖屋,竖柱,上梁,安床,作灶,安碓磑,挂匾,掘井,纳畜","taboo":"出行,安葬,造桥","animal":"狗","week":"Thursday","festivalList":[],"jieqi":{"7":"小暑","23":"大暑"},"maxDayInMonth":29,"leap":false,"lunarYearString":"戊戌","bigMonth":false}}
    hs.http.asyncGet("https://www.sojson.com/open/api/lunar/json.shtml", nil, function(status, body, headers)
        if (status ~= 200) then return end

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
            for i,v in ipairs(festivalList) do
                festival = festival..v.." "
            end
            qsww_weather_obj.canvas[2].text = text..festival
        end
    end)
    hs.timer.doAt("00:01",_qsww_lunarDate)
end
-- star
_qsww_lunarDate()

-- // * 4. 股市
local _qsww_waitTime = 20
local stockSH_orig = 0;
local stockSZ_orig = 0;
function _qsww_stockSetVar(stockSH, stockSH_yesterday, stockSZ, stockSZ_yesterday)
    if not stockSH or not stockSZ or not stockSH_yesterday then return end

    local shUnDown = '⇡'
    local up = (tonumber(stockSH) or tonumber(stockSH_yesterday) or 0) - (tonumber(stockSH_yesterday) or tonumber(stockSH) or 0)
    if up < 0 then
        shUnDown = '⇣'
    end
    shUnDown= string.format("%d%s", math.floor(math.abs(up)+0.4) , shUnDown)

    local szUpDown = '⇡'
    up = tonumber(stockSZ) - tonumber(stockSZ_yesterday)
    if up < 0 then
        szUpDown = '⇣'
    end
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
    local stockSH = nil
    local stockSH_yesterday = nil
    local stockSZ = nil
    local stockSZ_yesterday = nil

    -- // * 1. 上市 var hq_str_sh000001="上证指数,2827.0823,2831.1837,2810.1569,2837.5092,2804.4929,0,0,80575377,97588619359,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2018-07-16,13:49:17,00"; Y2831.1837
    hs.http.asyncGet("http://hq.sinajs.cn/list=sh000001", nil, function(status, body, headers)
        if (status ~= 200) then return end
        local array = arrayWithStringAndSplit(body, ",")
        if (array and #array > 4) then
            stockSH_yesterday = array[3]
            stockSH = array[4]
        end
        _qsww_stockSetVar(stockSH, stockSH_yesterday, stockSZ, stockSZ_yesterday)
    end)
    -- // * 2. 深市
    hs.http.asyncGet("http://hq.sinajs.cn/list=sz399001", nil, function(status, body, headers)
        if (status ~= 200) then return end
        local array = arrayWithStringAndSplit(body, ",")
        if (array and #array > 4)  then
            stockSZ_yesterday = array[3]
            stockSZ = array[4]
        end
        _qsww_stockSetVar(stockSH, stockSH_yesterday, stockSZ, stockSZ_yesterday)
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
        qsl_delayedFn(_qsww_waitTime, _qsww_stockRepeat)
        print("qsww_stockRepeat")
    end
end

local dateTab = os.date("*t", os.time())
if _qsww_isInTime(dateTab, 9, 30, 11, 30) or _qsww_isInTime(dateTab, 13, 0, 15, 0) then
    _qsww_stockRepeat()
else
    _qsww_stock()
    hs.timer.doAt("9:30", _qsww_stockRepeat)
    hs.timer.doAt("13:00", _qsww_stockRepeat)
end



--
