
-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/27 14:27
-- Use    : StockChinese

if stockChineseRun then return end
stockChineseRun = true

function StockChinese(Class)
    local obj
    if Class then obj = Class() else obj = {} end

    function _init()
        -- property
        obj.stockSZ = nil
        obj.stockSH = nil
        obj.callback = nil
        obj.text = nil
    end
    _init()

    function setStockText()

        if not obj.stockSZ or not obj.stockSH then return end

        local stockSH, yesterdaySH = tonumber(obj.stockSH[1]), tonumber(obj.stockSH[2])

        local up = stockSH - yesterdaySH
        local shUnDown = '⇡'
        if up < 0 then shUnDown = '⇣' end
        shUnDown= string.format("%d%s", math.floor(math.abs(up)+0.4) , shUnDown)

        local stockSZ, yesterdaySZ = tonumber(obj.stockSZ[1]), tonumber(obj.stockSZ[2])
        local szUpDown = '⇡'
        up = stockSZ - yesterdaySZ
        if up < 0 then szUpDown = '⇣' end
        szUpDown = string.format("%d%s", math.floor(math.abs(up)+0.4), szUpDown)

        -- obj.canvas[4].text
        if obj.callback then
            obj.text = string.format("股市: 上%s%.3f深%s%.3f", shUnDown, stockSH, szUpDown, stockSZ)
            obj.callback( obj.text )
        end
    end
    -- method

    obj.getStockSH = function()
        print("请求 股票 数据")
        -- // * 1. 上市 var hq_str_sh000001="上证指数,2827.0823,2831.1837,2810.1569,2837.5092,2804.4929,0,0,80575377,97588619359,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2018-07-16,13:49:17,00"; Y2831.1837
        hsHttpAsyncGet("http://hq.sinajs.cn/list=sh000001", function(body)
            local array = qsSplit(body, ",")
            if (array and #array > 4) then
                local yesterday = array[3]
                local stock = array[4]
                obj.stockSH = {stock, yesterday}
                setStockText()
            end
        end)
    end
    obj.getStockSZ = function()
        -- // * 2. 深市
        hsHttpAsyncGet("http://hq.sinajs.cn/list=sz399001", function(body)
            local array = qsSplit(body, ",")
            if (array and #array > 4)  then
                local yesterday = array[3]
                local stock = array[4]
                obj.stockSZ = {stock, yesterday}
                setStockText()
            end
        end)
    end

    obj.run = function()
        obj.getStockSH()
        obj.getStockSZ()
    end

    return obj
end
