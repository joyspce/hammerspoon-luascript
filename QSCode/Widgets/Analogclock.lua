-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/26 22:26
-- Use    : analogclock 时钟

function Analogclock()
    local s = {}

    function _init()
        local frame = hs.screen.mainScreen():frame()
        s.center = {x= frame.w - 195, y=325}

        s.views = {};

        s.timer = nil
    end
    _init()

    s.close = function()
        s.timer:stop()
        s.timer=nil
        for i= 1, #s.views do s.views[i]:delete() end
        s.views = nil
        s.center = nil
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

    function updateClock()
        local secnum = math.tointeger(os.date("%S"))
        local minnum = math.tointeger(os.date("%M"))
        local hournum = math.tointeger(os.date("%I"))
        local seceangle = 6*secnum
        local mineangle = 6*minnum+6/60*secnum
        local houreangle = 30*hournum+30/60*minnum+30/60/60*secnum

        s.views[#s.views-6]:setArcAngles(0,seceangle)

        s.views[#s.views-5]:setArcAngles(0,mineangle)
        s.views[#s.views-4]:setArcAngles(0,mineangle)
        s.views[#s.views-3]:setArcAngles(0,mineangle)

        if houreangle >= 360 then houreangle = houreangle - 360 end

        s.views[#s.views-2]:setArcAngles(0,houreangle)
        s.views[#s.views-1]:setArcAngles(0,houreangle)
        s.views[#s.views]  :setArcAngles(0,houreangle)
    end

    -- method
    s.show = function()
        local seccolor = {red=158/255,blue=158/255,green=158/255,alpha=0.5}
        local tofilledcolor = {red=1,blue=1,green=1,alpha=0.5}
        local secfillcolor = {red=158/255,blue=158/255,green=158/255,alpha=0.2}
        local mincolor = {red=24/255,blue=215/255,green=135/255,alpha=0.95}
        local hourcolor = {red=246/255,blue=39/255,green=89/255,alpha=0.95}

        local imagerect = hs.geometry.rect(s.center.x-100,s.center.y-100,200,200)
        local imagedisp = hs.drawing.image(imagerect,"./resources/watchbg.png")
        imagedisp:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        imagedisp:setLevel(hs.drawing.windowLevels.desktopIcon)
        imagedisp:show()

        s.views[#s.views + 1] = imagerect;

        for _, var in ipairs({ {s.center,80,0,360, false, 1, seccolor},
                               {s.center,55,0,360, false, 3, tofilledcolor},
                               {s.center,40,0,360, false, 3, tofilledcolor} }) do
            local view = drawingArc( var[1], var[2], var[3], var[4], var[5], var[6], var[7] );
            s.views[#s.views + 1] = view;
        end

        local sechand =   drawingArc( s.center,80,0,0,   true,  1, seccolor )
        sechand:setFillColor(secfillcolor)
        s.views[#s.views + 1] = sechand;

        for _, var in ipairs({ {s.center,55,0,0, false, mincolor},      -- minhand1
                               {s.center,54,0,0, false, mincolor},      -- minhand2
                               {s.center,53,0,0, false, mincolor},      -- minhand3
                               {s.center,40,0,0, false, hourcolor},     -- hourhand1
                               {s.center,39,0,0, false, hourcolor},     -- hourhand2
                               {s.center,38,0,0, false, hourcolor},  }) do -- hourhand3
            local view = drawingArc( var[1], var[2], var[3], var[4], var[5] );
            view:setStrokeColor(var[6])
            s.views[#s.views + 1] = view;
        end

        s.timer = hs.timer.doEvery(1, updateClock)
        s.timer:start()
    end

    return s
end

if not analogclock then
    analogclock = Analogclock()
    analogclock.show()
end

------- analogclock

--
