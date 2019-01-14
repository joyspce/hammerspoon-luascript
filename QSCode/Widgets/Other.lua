-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/27 17:32
-- Use    : xxx

function LunarDate(Class)
    local s = {}

    function _init()
        -- property
        s.callback = nil
        s.text = nil
    end
    _init()

    s.run = function()
        print("请求 农历 数据")
        -- {"status":200,"message":"success","data":{"year":2018,"month":7,"day":12,"lunarYear":2018,"lunarMonth":5,"lunarDay":29,"cnyear":"贰零壹捌 ","cnmonth":"五","cnday":"廿九","hyear":"戊戌","cyclicalYear":"戊戌","cyclicalMonth":"己未","cyclicalDay":"乙巳","suit":"纳采,订盟,嫁娶,祭祀,沐浴,塑绘,开光,出火,治病,习艺,伐木,盖屋,竖柱,上梁,安床,作灶,安碓磑,挂匾,掘井,纳畜","taboo":"出行,安葬,造桥","animal":"狗","week":"Thursday","festivalList":[],"jieqi":{"7":"小暑","23":"大暑"},"maxDayInMonth":29,"leap":false,"lunarYearString":"戊戌","bigMonth":false}}
        hsHttpAsyncGet("https://www.sojson.com/open/api/lunar/json.shtml", function(body)
            local lunaDates = hs.json.decode(body)
            if (lunaDates["status"] == 200) then
                local data = lunaDates["data"]
                -- 农历: 2018 戊戌 狗年 五月 廿九 or "jieqi":{"7":"小暑","23":"大暑"}
                -- 年                   2018               戊戌
                local text = "农历: ("..data["year"]..")"..data["cyclicalYear"].." "..data["animal"].."年 "
                -- 月 日
                text = text..data["cnmonth"].."月 "..data["cnday"].." "
                -- 节日
                local festival = ""
                local festivalList = data["festivalList"]
                for i,v in ipairs(festivalList) do festival = festival..v.." " end

                s.text = text..festival

                if (s.callback) then s.callback(s.text) end
                -- s.canvas[2].text = s.lunarDateText
            end
        end)
    end

    return s
end

function IPAll()
    local s = {}

    -- property
    s.callback = nil
    s.text = nil

    -- method
    s.run = function()

        local lan = nil
        -- lan
        local array = hs.network.addresses("en0")
        if not array or #array == 0 then array = hs.network.addresses("en1") end
        for i,v in ipairs(array) do
            if #v < 17 then
                lan = "网络: "..v
                break
            end
        end

        -- net
        print("请求 IP 数据")
        hsHttpAsyncGet("http://members.3322.org/dyndns/getip",  function(body)
            local net = string.gmatch(body, "%d+%.%d+%.%d+%.%d+")()
            if lan and net then
                s.text = lan.." 外"..net
                if s.callback then
                    s.callback(s.text)
                end
            end
        end)
    end
    return s
end

-- NetSpeedMenu 网络显示菜单
function NetSpeedMenu()
    local s = {}

    -- property
    s.callback = nil
    -- init
    s.menubar = hs.menubar.new()
    s.menubar:setClickCallback(hs.caffeinate.startScreensaver)
    -- hs.execute("caffeinate -t 3600")
    --show("1小时后关屏")

    s.count   = 0
    local isDouble = true
    local firstIn, firstOut
    s.run = function()

        if s.count == 0 or s.count > 60 then
            local activeInterface = hs.network.primaryInterfaces() or ""
            s.in_str = 'netstat -ibn | grep -e ' .. activeInterface .. ' -m 1 | awk \'{print $7}\''
            s.out_str = 'netstat -ibn | grep -e ' .. activeInterface .. ' -m 1 | awk \'{print $10}\''
            s.count = 1
        end

        s.count = s.count + 1

        local in_seq, out_seq = nil, nil
        if isDouble then
            isDouble = false
            firstIn  = hs.execute(s.in_str)
            firstOut = hs.execute(s.out_str)
        else
            isDouble = true
            in_seq  = ((hs.execute(s.in_str) - firstIn) or 0) * 0.5
            out_seq = ((hs.execute(s.out_str) - firstOut) or 0) * 0.5
        end

        if in_seq and out_seq then
            local kbin
            if in_seq / 1024 > 1024 then
                kbin = string.format("%.2f",in_seq/1024/1024) .. 'm'
            else
                kbin = string.format("%.1f",in_seq/1024) .. 'k'
            end
            local kbout
            if out_seq/1024 > 1024 then
                kbout = string.format("%.2f",out_seq/1024/1024) .. 'm'
            else
                kbout = string.format("%.1f",out_seq/1024) .. 'k'
            end
            local title = 'D'..kbin..'U'..kbout..' '
            if s.callback then title = s.callback(title) end
            s.menubar:setTitle(title)
        end
    end

    return s
end


--
