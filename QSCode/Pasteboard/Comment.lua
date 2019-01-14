-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/12/02 21:50
-- Use    : Comment


function getFunctionName(functionName)
    local name = nil
    if string.find(functionName, "function") then
        if string.find(functionName, "=") then
            functionName = string.gsub(functionName, "=", " ")
            local array = qsSplit(functionName, " ")
            if qsIsPreFix(functionName, "local") then
                if #array >= 2 then name = array[2] end
            else
                name = array[1]
            end
        else
            local array = qsSplit(functionName, " ")
            if #array >= 2 then name = array[2] end
        end
    end
    if name then
        local from = string.find(name, "%(")
        if from then return string.sub(name, 1, from-1) end
    end
    return nil
end
function getFunctionArgs(functionName)
    local from = string.find(functionName, "%(")
    local to = string.find(functionName, "%)")
    if from and to and from ~= (to -1) then
        local text = string.sub(functionName, from+1, to-1)
        if #text > 0 then
            return qsSplit(text, ",")
        end
    end
    return {}
end
function _functionCommentDiscriptionLua(arg1, arg2)
    local paste = Pasteboard()
    paste._callBackFn = function(paste)
        local onBlank_paste = qsTrim(paste)
        --- * 01 取出 function name
        local functionName = getFunctionName(onBlank_paste)
        local args = getFunctionArgs(onBlank_paste)

        ---
        --- Description
        local text = "--- func : "..(functionName or "").."\n"
        --- param: make  description
        --- param: model description
        for i,v in ipairs(args) do
            text = text .."--- param: "..v.."\n"
        end
        --- return  value
        ---
        text = text .."--- return: \n"..paste
        -- qsPrintTable(args)
        return text
    end
    paste.setPasteboard()
end
-- ctrl.add( {0x2a, "\\"}, "注释 1.Function Discription 2.Cheatsheet", {functionCommentDiscription, commentShow})
function functionCommentDiscription()
    local cfg = QSConfig()
    local language = cfg.config.programsIndex
    --- * ① 1 = lua 2 = oc
    local pastStr = ""
    if language == 1 then
        _functionCommentDiscriptionLua()
    elseif language == 2 then
        koKeyStroke({'cmd','alt','ctrl'}, '/')
    else
        show("no language select")
    end
end

-- ctrl.add( {0x2c, "/" }, "注释 1./2. 2.Clear 3.Change",
--     {comment123,  commentClear, commentChange})
local comment123Count = 0
function comment123()
    local cfg = QSConfig()
    --- * 01 编程语言
    -- s.config.programsIndex = 1
    -- s.programs = {'lua', 'oc'}
    local language = cfg.programs[cfg.config.programsIndex]
    --- * 02 注释数字
    -- s.config.commentIndex = 1
    -- s.nums
    local nums = cfg.nums[cfg.config.commentIndex]

    local pastStr = ""
    if qsIsPreFix(language, "lua") then
        pastStr = pastStr .."--- * "..nums[comment123Count % #nums + 1].." "
    elseif qsIsPreFix(language, "oc") then
        pastStr = pastStr ..[[/// * ]]..nums[comment123Count % #nums + 1].." "
    end

    hsPasteWithString(pastStr)
    comment123Count = comment123Count + 1;
end

function commentShow()
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr= nil
        return
    end
    _ModalMgr = ModalMgr()

    function pressedfn(index)
        return function()
            if index then
                local time = qsOsTime()
                local array = {
                    -- 1
                    "// ************************ mark by joys "..time.." ***\n"..
                    "// NS : \n"..
                    "// **********************************************************\n",
                    -- 2
                    "// ------------------------ mark by joys "..time.." ---\n"..
                    "// UI : \n"..
                    "// ----------------------------------------------------------\n",
                    -- 3
                    "// -*-*-*-*-*-*-*-*-*-*-*-* mark by joys "..time.." -*-\n"..
                    "// C : \n"..
                    "// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n",

                    -- 1
                    "-- ************************ mark by joys "..time.." ***\n"..
                    "-- NS : \n"..
                    "-- **********************************************************\n",
                    -- 2
                    "-- ------------------------ mark by joys "..time.." ---\n"..
                    "-- UI : \n"..
                    "-- ----------------------------------------------------------\n",
                    -- 3
                    "-- -*-*-*-*-*-*-*-*-*-*-*-* mark by joys "..time.." -*-\n"..
                    "-- C : \n"..
                    "-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n",

                    -- 1
                    "# ************************* mark by joys "..time.." ***\n"..
                    "# NS : \n"..
                    "# ***********************************************************\n",
                    -- 2
                    "# ------------------------- mark by joys "..time.." ---\n"..
                    "# UI : \n"..
                    "# -----------------------------------------------------------\n",
                    -- 3
                    "# -*-*-*-*-*-*-*-*-*-*-*-* mark by joys "..time.." -*-\n"..
                    "# C : \n"..
                    "# -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n",
                }
                hsPasteWithString(array[index])
            end
            mmExit()
        end
    end

    -- key, message, pressedfn
    local bindKeys = {
        {key = 'tab',message ="Show 显示调度中心", pressedfn = _ModalMgr.show},
        {key = 'escape', message ="Exit 调度中心", pressedfn = pressedfn()},
        {key = 'q',      message ="Exit 调度中心", pressedfn = pressedfn()},

        {key = "1", message = '// ********* time',  pressedfn = pressedfn(1)},
        {key = "2", message = '// --------- time',  pressedfn = pressedfn(2)},
        {key = "3", message = '// -*-*-*-*- time',  pressedfn = pressedfn(3)},
        {key = "4", message = '-- ********* time',  pressedfn = pressedfn(4)},
        {key = "5", message = '-- --------- time',  pressedfn = pressedfn(5)},
        {key = "6", message = '-- -*-*-*-*- time',  pressedfn = pressedfn(6)},
        {key = "7", message = '# ********** time',  pressedfn = pressedfn(7)},
        {key = "8", message = '# ---------* time',  pressedfn = pressedfn(8)},
        {key = "9", message = '# -*-*-*-*-* time',  pressedfn = pressedfn(9)},
        {key = "t", message = '# -*-*-*-*-* time',  pressedfn = function()
            local config = QSConfig()
            local language = config.languages[config.config.languageIndex]

            if qsIsPreFix(language, "lua") then
                hsPasteWithString("-- ** "..qsOsTime().." ** ")
            elseif qsIsPreFix(language, "oc") then
                hsPasteWithString("// ** "..qsOsTime().." ** ")
            end
            mmExit()
        end},

    }
    local cfg = QSConfig()
    local nums = cfg.nums[cfg.config.commentIndex]
    local message = "Clear Comment current is "..comment123Count % #nums + 1
    bindKeys[#bindKeys + 1] = {key = "n", message = message,  pressedfn = function()
        comment123Count = 0
        mmExit()
    end}

    message = 'comment Change current is '..nums[comment123Count % #nums + 1]
    bindKeys[#bindKeys + 1] = {key = "c", message = message,  pressedfn = function()
        cfg.changeComment()
        mmExit()
    end}

    _ModalMgr.run(bindKeys)
    _ModalMgr.show()
end



--
