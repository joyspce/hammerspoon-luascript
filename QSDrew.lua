
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

-- // ********************************** mark by joys 2018-06-20 13:10 **
-- // * : show
-- // *******************************************************************
function _qswMainFrameWithPrecentage(precentage)
    local frame = { x = 0, y = 23, w = qsl_mainScreenW, h = qsl_mainScreenH}
    frame.x = frame.w * precentage * 0.25
    frame.y = frame.h * precentage * 0.5
    frame.w = frame.w * (1 - precentage * 0.5)
    frame.h = frame.h * (1 - precentage * 0.5)
    return frame;
end

-- drawing main View
function _qswRectangleViewDrawingWithFrame(frame)
    local color = {["red"]=0.6,["blue"]=0.6,["green"]=0.6,["alpha"]=0.95}
    local view = hs.drawing.rectangle(frame):setFillColor(color):setRoundedRectRadii(10, 10);
    view:show()
    return view
end

function _qsw_makeView(x, y, w, h, str)
    local color = {["red"]=0.05,["blue"]=0.45,["green"]=0.05,["alpha"]= 1.0}
    local view = hs.drawing.text(hs.geometry.rect(x, y, w, h), str):setTextSize(16):setTextColor(color)
    view:show()
    return view
end

singeletenViews = nil;
-- drawing titles View
function _qswSetMainTitleWithRect(rect, titles)
    local gap = 30;
    local x, y, w, h = rect.x + gap, rect.y + gap, rect.w / 4, 30;
    local startW, count = 0, 1;
    for i, str in ipairs(titles) do
        local array = arrayWithStringAndSplit(str, "|")
        if #array == 0 then
            array = {""}
        end
        local keyStr = array[1]

        local keyView = _qsw_makeView(x, y, w, h, keyStr)
        singeletenViews[ #singeletenViews + 1] = keyView;

        if #array == 2 then
            local deviation = 60
            if #keyStr > 12 then
                deviation = deviation + 30
            end
            local detailView = _qsw_makeView(x + deviation, y, w - deviation, h, array[2])
            singeletenViews[ #singeletenViews + 1] = detailView;
        end
        -- 计算RECT
        y = rect.y + gap + h * count;
        if y >= (rect.y + rect.h - gap) then
            y = rect.y + gap;
            count = 0;
            startW = startW + 1;
            x = rect.x + w * startW;
        end
        count = count + 1;
    end
end

function _qswRemoveViews(views)
    for i,view in ipairs(views) do
        view:hide()
        view:delete()
    end
end
--  "⌥ + \\:        QS快捷键提示"
function showShortcutsTips()
    if singeletenViews then
        _qswRemoveViews(singeletenViews)
        singeletenViews = nil;
        return
    end

    singeletenViews     = {}
    local titleTips     = init_retTitle(operation_config_kyes)

    local mainFrame     = _qswMainFrameWithPrecentage(0.1)
    local rectangleView = _qswRectangleViewDrawingWithFrame(mainFrame)
    _qswSetMainTitleWithRect(mainFrame, titleTips)
    singeletenViews[ #singeletenViews + 1] = rectangleView;
end
