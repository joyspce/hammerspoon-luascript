
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

-- last updata 2018/11/26

---- 番茄时间

function TomatoTime()
    local obj = {}

    function _init()
        obj.count = 0

        obj.menubar = nil
        obj.timeDoEvery1 = nil
        obj.playEndSound = nil
    end
    _init()

    obj.stop = function()
        if (obj.menubar)      then obj.menubar:removeFromMenuBar() end
        if (obj.timeDoEvery1) then obj.timeDoEvery1:stop() end
        if (obj.playEndSound) then obj.playEndSound:stop() end
        _init()
    end

    function p_doEvery()
        hs.sound.getByFile(hs.configdir.."/resources/ticking.mp3"):play()

        obj.count = obj.count + 1

        if obj.count % 2 == 0 then
            obj.menubar:setTitle( ":  " );
        else
            local minute = math.floor(obj.count/60)
            if minute == 0 then
                obj.menubar:setTitle( "-  " );
            else
                obj.menubar:setTitle( minute.."  " );
            end
        end
        -- 大于25分钟
        if obj.count >= (25 * 60) then

            obj.playEndSound = hs.sound.getByFile(hs.configdir.."/resources/123456.mp3")
            obj.playEndSound:start()

            if (obj.menubar)      then
                obj.menubar:removeFromMenuBar()
                obj.menubar = nil
            end
            if (obj.timeDoEvery1) then
                obj.timeDoEvery1:stop()
                obj.timeDoEvery1 = nil
            end
        end
    end

    obj.run = function()
        obj.menubar = hs.menubar.new()
        obj.menubar:setClickCallback(obj.stop)

        obj.timeDoEvery1 = hs.timer.doEvery(1, p_doEvery)
        -- obj.timeDoEvery1:start()
    end

    return obj
end

function runTomatoTime()
    if (tomatoTime) then
        tomatoTime.stop()
        tomatoTime = nil
    else
        tomatoTime = TomatoTime()
        tomatoTime.run()
    end
end

---- /番茄时间

--
