-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/29 21:50
-- Use    : ModalMgr

local function labelWithFrameAndText(frame, text, tab)
    local label = {
        type = "text",
        text = text,
        textFont = "Courier-Bold",
        textSize = 16,
        textColor = {["red"]=0.05,["blue"]=0.45,["green"]=0.05,["alpha"]= 1.0},
        textAlignment = "left",
        frame = frame }
    if tab then
        for k,v in pairs(tab) do label[k] = v end
    end
    return label
end
-- drawing main View
local function viewWithFrameAndFillColor(frame, fillColor)

    local fillColor = fillColor or {["red"]=0.6,["blue"]=0.6,["green"]=0.6,["alpha"]=0.95}

    local view = hs.canvas.new(frame)
    view:level(hs.canvas.windowLevels.tornOffMenu)
    view[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = fillColor,
        roundedRectRadii = {xRadius = 10, yRadius = 10},
    }
    return view
end
local function redCycle()
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:fullFrame()
    local lcres = cscreen:absoluteToLocal(cres)

    local redView = hs.canvas.new({ x = (cres.w - 50) * 0.5, y = (cres.h - 50) * 0.3,
                                     w = 50,          h = 50 })
    redView:level(hs.canvas.windowLevels.tornOffMenu)
    redView[1] = {
        type = "circle",
        action = "fill",
        fillColor = {hex = "#EE0022", alpha = 0.6},
    }
    redView:show()
    return redView
end

function ViewsAndHotKeys()
    local s = {}
    s._hotKeys = {}
    s._views = {}

    s.remove = function()
        if s._views then
            for i,view in ipairs(s._views) do
                view:hide()
                view:delete()
            end
            s._views = nil
        end
        if s._hotKeys then
            for i, hotkey in ipairs(s._hotKeys) do
                if type(hotkey) ~= 'string' then
                    hotkey:delete()
                end
            end
            s._hotKeys = nil
        end
    end
    return s
end

_MenuView = nil
function MenuView(titles)
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr = nil
    end
    if _OperationMgr then
        _OperationMgr.remove()
        _OperationMgr = nil
    end

    local s = ViewsAndHotKeys()
    _MenuView = s
    local frame =  { x = qs_mainScreenW * 0.02, y = qs_mainScreenH * 0.1,
                     w = qs_mainScreenW * 0.96, h = qs_mainScreenH * 0.8}

    local views = viewWithFrameAndFillColor(frame)

    -- drawing titles View setLabels
    local length = #titles
    local x, y, w, h = 1, 4, 25, 94 / (length/4) - 0.2
    local y1 = y
    for i=1, length do
        if not (titles[i] == '' and y == y1) then
            local splitTitles = qsSplit(titles[i], "|")
            views[ #views + 1] =
                labelWithFrameAndText({x = x.."%", y = y.."%", w = w..'%', h = h..'%'}, splitTitles[1])
            if #splitTitles == 2 then
                local gap = 6
                views[ #views + 1] =
                    labelWithFrameAndText({x = (x+gap).."%", y = y.."%", w = (w-gap)..'%', h = h..'%'}, splitTitles[2])
            end
            y = y + h
            if y > 96 then
                x = x + 25
                y = y1
            end
        end
    end
    views:show()

    s._views[#s._views+1] = views
    s._hotKeys[#s._hotKeys + 1] = hs.hotkey.bind('', 'escape', "exit menus", function()
        s.remove()
        _MenuView = nil
        s = nil
    end)
    return s
end
_ModalMgr = nil
function mmExit()
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr = nil
    end

    if _OperationMgr then
         _OperationMgr.remove()
         _OperationMgr = nil
    end
end
function ModalMgr()
    if _MenuView then
        _MenuView.remove()
        _MenuView = nil
    end
    if _OperationMgr then
        _OperationMgr.remove()
        _OperationMgr = nil
    end

    local s = ViewsAndHotKeys()
    _ModalMgr = s

    s._bindKeys = nil
    -- method
    s.run = function(bindKeys)
        s._bindKeys = bindKeys
        if bindKeys then
            for i,var in ipairs(bindKeys) do
                s._hotKeys[#s._hotKeys + 1] =
                    hs.hotkey.bind('', var["key"], var["message"],var["pressedfn"])
            end
        end
        s._views[#s._views + 1] = redCycle()
    end

    local menu = nil
    s.show = function()
        if menu and menu:isShowing() then
            menu:hide()
        else
            local cscreen = hs.screen.mainScreen()
            local cres = cscreen:fullFrame()
            menu = viewWithFrameAndFillColor({ x = cres.x + cres.w / 5, y = cres.y + cres.h / 5,
                                               w = cres.w / 5 * 3,      h = cres.h / 5 * 3})

            local length = #s._bindKeys
            if length%2 == 1 then length = length + 1 end

            local y, y1 = 4, 4
            local h = (100-y)/(length/2)
            -- set Titles
            for i,v in ipairs(s._bindKeys) do
                local key = v["key"]
                if key == 'escape' then key = 'esc' end

                if  i <= length/2 then -- left
                    menu[#menu + 1] = labelWithFrameAndText(
                        {x = '4%',  y = y..'%',  w = '43%', h = h..'%'}, key..": "..v["message"])
                    y = y + h
                else -- right
                    menu[#menu + 1] = labelWithFrameAndText(
                        {x = '50%', y = y1..'%', w = '43%', h = h..'%'}, key..": "..v["message"])
                    y1 = y1 + h
                end
            end
            menu:show()
            s._views[#s._views + 1] = menu
        end
    end

    return s
end

-- http://translate.google.cn/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=auto&tl=zh_TW&q=calculate
-- http://fanyi.baidu.com/transapi?from=auto&to=cht&query=Calculation
-- http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=AFC76A66CF4F434ED080D245C30CF1E71C22959C&from=&to=en&text=考勤计算

-- http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=多少
-- {"type":"ZH_CN2EN","errorCode":0,"elapsedTime":0,"translateResult":[[{"src":"多少","tgt":"How many"}]]}
-- http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=english
-- {"type":"EN2ZH_CN","errorCode":0,"elapsedTime":1,"translateResult":[[{"src":"english","tgt":"英语"}]]}
local function translation(str, fn)
    -- 去除前后 空格
    local text = string.match(str, "%s*(.-)%s*$")
    -- english -- 中文
    if regular.evaluateWithString(text, "SELF MATCHES %@", '[a-z A-Z]{1,50}|[\\u4e00-\\u9fa5 ]{1,20}') then
        local url = 'http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i='
                        ..hs.http.encodeForQuery(text)
        hsHttpAsyncGet(url, function(body)
            local dict = hs.json.decode(body)
            if dict then
                local translateResult = dict['translateResult'][1][1]['tgt']
                if translateResult and #translateResult > 0 then
                    fn(text,  translateResult)
                end
            end
        end)
    end
end
_OperationMgr = nil
function OperationMgr(path)
    if _MenuView then
        _MenuView.remove()
        _MenuView = nil
    end
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr = nil
    end

    local s = ViewsAndHotKeys()
    _OperationMgr = s

    --- * ① dataSoruce
    s.dataSoruce = HSDataSoruce(path)
    s.saveWithStr = function(str)
        if #str > 1 then
            s.dataSoruce.saveInFristWithStrAndMax(str, 10)
        else
            show("Error: 没数据 保存")
        end
    end

    s.currentText = nil
    s.translationWord = nil
    -- func
    s.translation = function(str)
        translation(str, function(text, tText)
           s.translationWord = tText
           if text ~= tText then
               s.pasteboard(text ..' ==>>> '..tText)
           end
       end)
    end

    local translate = true
    s.setCurrentText =function(str, isNotSave)
        translate = true
        print(#str, '<---'..str..'--->')
        local str = str or ''
        if not isNotSave then
            if qsIsStringEmpty(str) then
                str = s.dataSoruce.dataSoruce[1]
            else
                s.saveWithStr(str)
            end
        end
        s.pasteboard(str)
        -- 翻译 一下
        s.translation(str)
    end
    s.copyTranslateToPasteboard = function()
        if translate then
            if s.translationWord and hsIsSavePasteboard(s.translationWord) then
                s.currentText = s.translationWord
                s.pasteboard(s.translationWord .. " is copied")
            else
                s.pasteboard(s.currentText .. " is not copy, there is no translation word!!!")
            end
            translate = false
        else
            s.setCurrentText(s.currentText)
        end
    end

    local menu = nil
    local titleColor = {["red"]=0.9,["blue"]=0.7,["green"]=0.8,["alpha"]= 1.0}
    -- lable
    s.pasteTitle = function(title)
        menu[4] = labelWithFrameAndText( { x = "2%", y = "3%", w = "55%", h = '4%' }, title,
                                           { textSize = 22,
                                             textColor = titleColor,
                                             textAlignment = 'center' } )
    end
    s.pasteboard = function(title)
        menu[5] = labelWithFrameAndText({ x = "2%", y = "8%", w = "55%", h = "20%" }, title,
                                                {textColor = titleColor, textSize = 20})
    end
    s.histoyTitle = function(title, textAlignment)
        local textAlignment = textAlignment or 'center'
        menu[6] = labelWithFrameAndText( { x = "2%", y = "32%", w = "55%", h = "4%" }, title,
                                           { textSize = 22,
                                             textColor = titleColor,
                                             textAlignment =  textAlignment} )
    end
    -- 'Operation'
    s.operationTitle = function(title)
        menu[7]  = labelWithFrameAndText({ x = "60%", y = "3%", w = "40%", h = "4%" }, title,
                                            { textSize = 22,
                                              textColor = titleColor,
                                              textAlignment = 'center' })
    end
    -- views
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:fullFrame()
    menu = viewWithFrameAndFillColor({ x = cres.x+cres.w*0.15/2, y = cres.y+cres.h*0.25/2,
                                             w = cres.w*0.85,          h = cres.h*0.75 },
                                             {hex="#000000", alpha=0.75})
    -- 横
    menu[2] = { type = "segments",
                strokeColor = {hex = "#FFFFFF", alpha = 0.4},
                coordinates = { {x="1%", y='30%'}, {x='59%', y='30%'} } }
    -- 竖
    menu[3] = { type = "segments",
                strokeColor = {hex = "#FFFFFF", alpha = 0.4},
                coordinates = { {x='60%', y="1%"}, {x='60%', y="99%"} } }
    menu:level(hs.canvas.windowLevels.tornOffMenu)

    -- 剪切板 标题
    s.pasteTitle('Pasteboard')
    -- 剪切板
    s.pasteboard('')
    -- Histoy 标题
    s.histoyTitle('Histoy')
    s.operationTitle('Operation')
    local histoyViewTitleStar = #menu

    s.historyViews = function()
        local y = 38
        local height = (98 - y)/10.0
        for i=1,10 do
            menu[#menu + 1] = labelWithFrameAndText( { x = "2%", y = y.."%", w = "55%", h = height.."%" },
                '', {textColor = titleColor, textSize = 20})
            y = y + height
        end
    end
    s.historyViews()

    local operationY = 8
    local height = 5
    s.addKey =function(key, message, pressedfn)
        if key then
            --- * ①  key
            s._hotKeys[#s._hotKeys + 1] = hs.hotkey.bind('', key, message, pressedfn)
            --- * ②  view
            if key == 'escape' then key = 'esc' end
            if #key == 1 then key = string.upper(key) end
            local len = 4 - #key
            key = string.format("%"..len.. "s", key)
            menu[#menu + 1] = labelWithFrameAndText(
                {x ="62%", y= operationY.."%", w="12%", h= height.."%"},
                "key "..key.." :",
                {textColor = titleColor, textSize = 20})
            --- * ③ message
            menu[#menu + 1] = labelWithFrameAndText(
                { x = "72%", y = operationY.."%", w = "29%", h = height.."%" },
                message,
                {textColor = titleColor, textSize = 20})
            --- * ④ height
            operationY = operationY + height
        else
            operationY = operationY + 1.5
        end
    end

    s.reloadData = function(func)
        --- * ① 清空 hotkey key
        for i,hotkey in ipairs(s._hotKeys) do
            local num = tonumber(hotkey.idx)
            if num then
                hotkey:delete()
                s._hotKeys[i] = ""
            end
        end

        local array1_z = qsArray1_z()
        for i=1, 10 do
            menu[ histoyViewTitleStar + i ].text = ''
            if #s.dataSoruce.dataSoruce >= i then
                local message = s.dataSoruce.dataSoruce[i]
                local hotkey = hs.hotkey.bind('', array1_z[i], "", function()
                    func(message)
                end)
                for i, v in ipairs(s._hotKeys) do
                    if type(v) == 'string' then
                        s._hotKeys[i] = hotkey
                        hotkey = nil
                        break
                    end
                end
                if hotkey then
                    s._hotKeys[#s._hotKeys + 1] = hotkey
                end

                local str = string.gsub(message, "\n", " ")
                str = qsTrim(str)
                local len = 72
                if #str > len then len = string.sub(str, 0, len) end
                menu[histoyViewTitleStar + i].text = 'key ' .. array1_z[i] .." :  "..str
            end
        end
    end

    -- s._views[#s._views + 1] = redCycle()
    s._views[#s._views + 1] = menu
    menu:show()

    return s
end




--
