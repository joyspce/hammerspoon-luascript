
-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/26 22:18

-- Use    : Lua Header Class Make

function QSLuaLuanageTemplate()

    local lua = [[
-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : ]]..os.date("%Y/%m/%d %H:%M")..[[

-- Use    : xxx
-- Change :
function ClassName()

    local s = {}

    -- property
    s.property = nil

    -- method
    s.method = function()

    end
    return s
end

--
    ]]
    hsPasteWithString(lua)
end




--
