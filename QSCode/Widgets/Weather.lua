-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/27 14:34
-- Use    : xxx

if weatherRun then return end
weatherRun = true;

function Weather()
    local s = {}
    function _init()
        -- property
        s.weatherText  = nil
        s.callback = nil
        s.text = nil
    end
    _init()

    s.run = function() s.findCityKey("上饶") end

    local weatherHttp = "http://api.k780.com/?"

    local count = 0
    function weather(url, key)
        count = count + 1
        if count > 5 then
            print("Error weather: 获取天气超5次 ")
            return
        end
        hsHttpAsyncGet(url..key, function(body)
            local dict = hs.json.decode(body)
            if (dict["success"] == "1") then
                dict = dict["result"]
                count = 0
                -- s.canvas[3].text
                if s.callback then
                    s.text =  "天气: "..dict["weather"].." "..dict["temperature"]..
                                " "..dict["wind"].." "..dict["winp"]
                    s.callback(s.text, dict["weather_curr"], dict["temperature_curr"])
                end
            else
                local weatherKey_me = "appkey=35033&sign=4e2f45408afef906ff706fb8c41db1b3"
                weather(weatherHttp.."app=weather.today&format=json&"..weatherKey_me.."&weaid=", key)
                print("Error: 从我自己的站号获取天气")
            end
        end)
    end

    s.findCityKey = function(city)
        print("请求 天气 数据")
        local url = weatherHttp.."app=weather.city&appkey=35033&sign=4e2f45408afef906ff706fb8c41db1b3&format=json"
        hsHttpAsyncGet(url, function(body)
            local dict = hs.json.decode(body)
            if (dict["success"] and dict["success"] == "1") then
                for key,var in pairs(dict["result"]) do
                    local cityTemp = var["citynm"]
                    if string.find(city, cityTemp)then
                        local weatherKey_orig = "appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4"
                        weather(weatherHttp.."app=weather.today&format=json&"..weatherKey_orig.."&weaid=", key)
                        break
                    end
                end
            end
        end)
    end

    return s
end

--
