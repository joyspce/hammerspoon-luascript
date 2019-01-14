-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/12/03 00:24
-- Use    : TempSnippet


_TempSnippet = nil
function TempSnippet()
    if _TempSnippet then return _TempSnippet end

    local _TempSnippet = {}
    s = _TempSnippet

    local path =  hs.configdir.."/QSCode/Pasteboard/TempSnippet.txt"
    -- property
    s.dataSoruce = HSDataSoruce(path)

    s.snippet = ""

    if #s.dataSoruce.dataSoruce > 0 then
        s.snippet = s.dataSoruce.dataSoruce[1]
    end

    -- save
    s.saveSnippets = function(str)
        if #str > 3 then
            local max = 20
            s.dataSoruce.saveInFristWithStrAndMax(str, max)
            show(str.."\nTempSnippet save successful")
        else
            show("Error: 没数据 保存")
        end
    end

    s.output = function(str)

        s.snippet = str or s.snippet

        if not s.snippet then
            show("The is no snippet in TempSnippet pleses double click key add")
            return
        end

        local orig = hs.pasteboard.getContents()
        if hs.pasteboard.writeObjects(s.snippet) then
            hsDelayedFn(0.05, function()
                koKeyStroke({'cmd'}, 'v')
                hsDelayedFn(0.15, function() hs.pasteboard.writeObjects(orig) end)
            end)
        end
        -- show(s.snippet)
    end

    s.input = function()
        local paste = hs.pasteboard.getContents() or ""
        hsDelayedFn(0.4, function()
            koKeyStroke({'cmd'}, 'c')
            hsDelayedFn(0.2, function()
                local copy = hs.pasteboard.getContents()
                if #copy > 3 then paste = copy end
                s.saveSnippets(paste)
            end)
        end)
    end
    return s
end

-- ctrl.add('v',  "1.TempSnippet 2.Cheatsheet", {tempSnippetOutput, tempSnippetOutputCheatsheet})


function tempSnippetOutput()
    local snippet = TempSnippet()
    snippet.output()
end
function tempSnippetOutputCheatsheet()
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr= nil
        return
    end
    _ModalMgr = ModalMgr()

    function exit() _ModalMgr.remove() _ModalMgr = nil end

    local snippet = TempSnippet()

    function pressedfn(str)
        return function()
            snippet.output(str)
            snippet.saveSnippets(str, true)
            _ModalMgr.remove()
        end
    end

    -- key, message, pressedfn
    local bindKeys = {
        {key = 'escape', message ="Exit Window Edit Mode", pressedfn = exit},
        {key = 'q',      message ="Exit Window Edit Mode", pressedfn = exit},
        -- Cheatsheet
        {key = 'tab',message ="Show Cheatsheet", pressedfn = _ModalMgr.show},

        {key = 's',message ="Save snippets", pressedfn = function()
            snippet.input()
            _ModalMgr.remove()
        end}
    }

    local array = qsArray1_z()

    for i, str in ipairs(snippet.dataSoruce.dataSoruce) do
        local message = string.gsub(str, "  ", " ")
        message =  string.gsub(message, "\n", " ")
        local len = 35
        if #message > len then message =  string.sub(message, 0, len) end

        bindKeys[#bindKeys+1] = {key = array[i], message = message, pressedfn = pressedfn(str)}
    end

    _ModalMgr.run(bindKeys)
    _ModalMgr.show()
end



--
