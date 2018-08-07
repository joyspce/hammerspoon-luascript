

if widgets then return end
widgets = true;

-------  analogclock
if not aclockcenter then
    aclockcenter = {x= qsl_mainScreenW - 195, y=325}
end
-- hs.drawing.arc(centerPoint, radius, startAngle, endAngle)
function drawingArc( centerPoint, radius, startAngle, endAngle, setFill, setStrokeWidth, setStrokeColor )

    local cirle = hs.drawing.arc( centerPoint, radius, startAngle, endAngle );
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
            endPlaySoundDelay = qsl_delayedFn( 3, function()
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

--
