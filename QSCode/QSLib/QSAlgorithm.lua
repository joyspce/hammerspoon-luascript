-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/12/17 23:26
-- Use    : xxx
-- Change :
--


-- str="0xBA"
-- 十六进制转到十进制
-- print(string.format("%d",str))
--
-- str="12345"
-- 十进制转到十六进制
-- print(string.format("%#x",str))


-- buble排序
function qaBubbleSort(array)
    local len = #array
    local temp
    for i=1, len-1 do
        -- for i = start, limit, step do
        for j = len, i+1, -1 do
            if array[j -1] > array[j] then
                temp = array[j - 1]
                array[j-1] = array[j]
                array[j] = temp
            end
        end
    end
    return array
end
-- qsPrintTable(qaBubbleSort({ 1, 5, 3,4  }))
-- qsPrintTable(qaBubbleSort({ 5, 2, 6, 0, 3, 9, 1, 7, 4, 8 }))



function QAList()
    local s = {}
    -- property
    -- local stack = {}
    --
    -- s.top = nil
    -- -- method
    -- s.show = function() qsPrintTable(stack) end
    -- s.lenth = function() return #steak end
    -- s.isEmpty = function() return #steak == 0 end
    -- s.clear = function()
    --     for i=1, #stack do table.remove(stack,i) end
    -- end
    return s
end

function QAStack()

    local s = {}
    -- property
    local stack = {}

    s.top = nil
    -- method
    s.show = function() qsPrintTable(stack) end
    s.lenth = function() return #steak end
    s.isEmpty = function() return #steak == 0 end
    s.clear = function()
        for i=1, #stack do table.remove(stack,i) end
    end

    s.push = function(var)
        s.top = var
        stack[#stack + 1] = var
    end

    s.pop = function()
        local temp = stack[#stack]
        table.remove(stack, #stack)
        return temp
    end

    s.popWhich = function(which)
        if #stack >= which then
            table.remove(stack, #stack)
        else
            error("Error QSStack s.popWhich!")
        end
    end

    return s
end

function QAQueue()
    local s = {}
    -- property
    local queue = {}
    s.front = nil -- 头
    s.rear = nil  -- 尾
    -- method
    s.show = function() qsPrintTable(queue) end
    s.lenth = function() return #queue end
    s.isEmpty = function() return #queue == 0 end
    s.clear = function()
        for i=1, #queue do table.remove(queue,i) end
        s.front = nil
        s.rear = nil
    end

    s.enQueue = function(var)
        if not s.front then s.front = var end
        queue[#queue + 1] = var
        s.rear = var
    end
    s.deQueue = function()
        if not s.isEmpty() then
            local temp = queue[1]
            table.remove(queue, 1)
            if not s.isEmpty() then
                s.front = queue[1]
                s.rear = queue[#queue]
            end
            return temp
        end
    end
    return s
end

--
