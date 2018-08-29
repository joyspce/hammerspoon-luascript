
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

hs.hotkey.alertDuration=0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

local req = {
    "QSLib",    --我的库
    "QSHSLib",
    "QSView",
    "QSWindow", -- window
    "QSDrew",

    "widgets",          --analogclock插件

    "QSStringEdit",
    "QSWatch",
    "QSAction",

    "QSInitHelper",     --存放init长代码
    "QSShell",
    "QSChooser",
    "QSTimer",
    "QSXcode1",
    "QSKey",
    "QSAppWatcher",              --输入法
    -- "QSTest"
}
for i,v in ipairs(req) do require(v) end
req = nil

-- ———————————————————————————— key Operation ————————————————————————————
function _init_addkey(tab)
    local keyword = tab[1]
    -- 鼠标左键点下 "⇪ + H",
    if type(tab[4]) == "number" and tab[4] == 1 then
        hyperyKeyBind(keyword, tab[5], tab[6])
        return
    end
    --  "键盘 H左← J下↓ K上↑ K右→ "
    if type(tab[3]) == "number" and tab[3] == 1 then
        hyperyKeyBind(keyword, tab[4], tab[5])
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
