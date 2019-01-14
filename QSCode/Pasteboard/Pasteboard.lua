-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/12/01 19:52
-- Use    : Pasteboard


function Pasteboard()

    local s = {}

    -- property
    s._pasteboard = ""
    s._pasteboard_cmdX = ""

    s.textTemp = ""

    s._waitTime = 0

    s._callBackFn = nil

    -- method
    s.formatString = function(str)
        local string = string.gsub(str, "     ", " ")
        string = string.gsub(string, "   ", " ")
        string = string.gsub(string, "  ", " ")
        string = string.gsub(string, "//", "// ")
        string = string.gsub(string, " //", "//")
        string = string.gsub(string, "//  ", "// ")
        string = string.gsub(string, ":// ", "://")
        return string
    end
    s.waitTime = function(time)
        local time = time or 0.1
        s._waitTime = s._waitTime + time
        return s._waitTime
    end
    s.setPasteboard = function(isNotCut)
        s._pasteboard = hs.pasteboard.getContents() or ""
        if isNotCut then
            hsDelayedFn(s.waitTime(), qsFunction(koKeyStroke, {'cmd'}, 'c'))
        else
            hsDelayedFn(s.waitTime(), qsFunction(koKeyStroke, {'cmd'}, 'x'))
        end
        hsDelayedFn(s.waitTime(), function()
            s._pasteboard_cmdX = hs.pasteboard.getContents() or ""
            if qsIsStringEmpty(s._pasteboard_cmdX) and 2 > #s._pasteboard_cmdX  then
                s._pasteboard_cmdX = s._pasteboard
            end

            if not isNotCut then
                s._pasteboard_cmdX = s.formatString(s._pasteboard_cmdX)
            end

            if s._callBackFn then
                local text = s._callBackFn(s._pasteboard_cmdX)
                if text then
                    hs.pasteboard.writeObjects(text)
                    hsDelayedFn(s.waitTime(0.05), qsFunction(koKeyStroke,{'cmd'}, 'v')) -- 粘贴

                    hsDelayedFn(s.waitTime(0.20), function()
                        hs.pasteboard.writeObjects(s._pasteboard) -- 写回内存
                    end)
                end
            end
        end)
    end

    s.pasteToEdit = function()
        s._pasteboard = hs.pasteboard.getContents() or ""
        hs.pasteboard.writeObjects(s.textTemp)
        hsDelayedFn(s.waitTime(0.1), qsFunction(koKeyStroke,{'cmd'}, 'v')) -- 粘贴

        hsDelayedFn(s.waitTime(0.20), function()
            hs.pasteboard.writeObjects(s._pasteboard) -- 写回内存
        end)
    end

    return s
end

-- ctrl.add('e',   "对齐 = @ method", pbAlignString)
function pbAlignString()
    function alignMethod(str)
        -- 特殊字符如下：(). % + - * ? [ ^ $  也作为以上特殊字符的转义字符 %
        local text = string.gsub(str, "    ", " ")
        text = string.gsub(text, "   ", " ")
        text = string.gsub(text, "  ", " ")

        text = string.gsub(text, "+", "+ ")
        text = string.gsub(text, "-", "- ")

        text = string.gsub(text, " %(", "(")
        text = string.gsub(text, "%( ", "(")

        text = string.gsub(text, "%) ", ")")
        text = string.gsub(text, " %)", ")")

        text = string.gsub(text, ": ", ":")
        text = string.gsub(text, " :", ":")

        text = string.gsub(text, " {", "{")
        text = string.gsub(text, "{", " {")

        text = string.gsub(text, "} ", "}")
        return text
    end

    function propertyMaxLen(array)
        local max = 0;
        for i, str in ipairs(array) do
            if qsIsPreFix(str, "@property") then
                local code = qsSplit(str, "%)")
                if #code >= 2 then
                    code = qsSplit(code[2], " ")
                    local len = #code[1]
                    if len > max then
                        print(code[1])
                        max = len
                    end
                end
            end
        end
        print(max)
        return max
    end
    function propertyAtomic(str)
        local dict = {
            strong    = "strong",
            weak      = "weak  ",
            retain    = "retain",
            copy      = "copy  ",
            assign    = "assign",

            atomic    = "atomic   ",
            nonatomic = "nonatomic",
        }
        local key = qsRemoveAllSpace(str)
        return dict[key] or str
    end
    function alignProperty(str, typeLen)
        -- 1. @property (nonatomic, copy)
        print(str)
        local form = string.find(str, "%(")
        local to = string.find(str, "%)")

        local atomic = string.sub(str, form+1, to-1)
        local array = qsSplit(atomic, ",")
        local text = "@property ("
        for i,v in ipairs(array) do
            if i == #array then
                text = text ..propertyAtomic(v)
            else
                text = text ..propertyAtomic(v)..", "
            end
        end
        text = text..") "
        -- (). % + - * ? [ ^ $
        -- 2.  NSString *endKeyWords2;
        local lastStr = string.sub(str, to+1, #str)
        local lastArray = qsSplit(lastStr, " ")

        for i,v in ipairs(lastArray) do
            if i == 1 then
                text = text..v..qsStringTimes(typeLen - #v + 1)
            else
                text = text..v
            end
        end
        return text
    end

    function alignEqualMaxLen(array)
        -- 1 先计数出最大line
        local maxLine = 0;
        for i, str in ipairs(array) do

            local leftStr = ""

            local from = string.find(str, "=")
            if (from) then
                local left = string.sub(str, 1, from - 1)
                for i,v in ipairs( qsSplit(left, " ") ) do leftStr = leftStr.." "..v end
            end

            if (#leftStr > maxLine) then maxLine = #leftStr end
        end
        return maxLine
    end
    function alignEqual(str, equalLen)
        local text = ""

        local str = string.gsub(str, "  ", " ")

        local from, to = string.find(str, "=");
        if (from) then
            -- 右边不动
            local rightStr = string.sub(str, to + 1, #str)
            rightStr = qsTrim(d)
            local leftStr = string.sub(str, 1, from-1)
            leftStr = qsTrim(leftStr)

            local array = qsSplit(leftStr, " ")
            for i,v in ipairs(array) do
                text = text..v.." "
                if i == #array then
                    local space = qsStringTimes(equalLen - #text - 1)
                    text = text .. space
                end
            end
            text = text.."= "..rightStr
        end
        return text
    end

    local paste = Pasteboard()
    paste._callBackFn = function(paste)
        local    array = qsSplit(paste,"\n")

        local text          = ""
        local propertyMax   = nil
        local alignEqualMax = nil

        for i, str in ipairs(array) do
            -- //
            if qsIsPreFix(str, "//") then
                text = text .. str
            --  property
            elseif qsIsPreFix(str, "@property") then
                if not propertyMax then propertyMax = propertyMaxLen(array) end
                text = text .. alignProperty(str, propertyMax)
            -- method
            elseif qsIsPreFix(str, "-") or qsIsPreFix(str, "+") then
                text = text .. alignMethod(str)
            -- =
        elseif string.find(str, "=" ) then
                if not alignEqualMax then alignEqualMax = alignEqualMaxLen(array) end
                text = text .. alignEqual(str, alignEqualMax)
            else
                text = text .. str
            end
            text = text .. "\n"
        end
        return text
    end
    paste.setPasteboard()
end



--
