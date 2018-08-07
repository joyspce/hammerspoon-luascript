
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

-- // ********************************** mark by joys 2018-06-22 21:24 **
-- // * : define on or off
-- // *******************************************************************

-- hs.shutdownCallback = function() print("i am close") end

hs.window.animationDuration = 0

-- 我的库
require "QSLib"

require "QSHSLib"

-- 显示
require "QSWindow"
require "QSDrew"

-- 天气插件
require "QSWeatherWidgets"
--  analogclock 插件
require "widgets"

-- ****************** key operation

require "QSStringEdit"

require "QSWatch"

require "QSAction"
-- 存放 init 长代码
require "QSInitHelper"

require "QSShell"

require "QSChooser"

require "QSTimer"

require "QSXcode1"

-- require "QSTest"



-- ———————————————————————————— key Operation ————————————————————————————
function _init_addkey(tab)
    local keyword = tab[1]
    -- 鼠标左键点下
    if #tab == 6 and type(tab[4]) == "number" then
        hyperyKeyBind(keyword, tab[5], tab[6])
        return
    end

    local hyperkeyStr = tab[2]

    local hyperkeyFun = hyperyKeyBind
    if string.find(hyperkeyStr, "⌥") then
        hyperkeyFun = hyperyKeyAltBind
    elseif string.find(hyperkeyStr, "⇧") then
        hyperkeyFun = hyperyKeyShiftBind
    end

    local funcAndAppName = {}
    for i,v in ipairs(tab) do
        if type(v) == "function" then
            funcAndAppName[#funcAndAppName+1] = v
        elseif i > 3 and i % 2 == 0 then
            funcAndAppName[#funcAndAppName+1] = v
        end
    end

    assert(#funcAndAppName ~= 0, "Error init_addkey table < 2")
    if #funcAndAppName == 1 then
        if type(funcAndAppName[1]) == "string" then
            hyperkeyFun(keyword, function() hs.application.launchOrFocus(funcAndAppName[1]) end);
        else
            hyperkeyFun(keyword, funcAndAppName[1])
        end
    else
        hyperkeyFun(keyword, function() qshs_multClick(funcAndAppName) end )
    end
end


-- ———————————————————————————— Title ————————————————————————————
function _init_title(tab)
    -- 取出 str
    local str = ""
    for i,v in ipairs(tab) do
        if i == 2 then
            str = str..v
        elseif i == 3 and type(v) == "string" then
            str = str.."|"..v
        end

        if i > 3 then
            if i % 2 == 1 and type(v) == "string" then str = str.." "..v end
        end
    end
    return str
end
function init_retTitle(tab)
    local titleTips = {}
    for i,v in ipairs(tab) do
        if type(v) == "table" then
            assert(#v > 2, "Error init_addkey table < 2")
            local str = _init_title(v)
            if #str > 3 then titleTips[#titleTips+1] = str end
        else
            titleTips[#titleTips+1] = v
        end
    end
    return titleTips
end


--
