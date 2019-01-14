-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2019/01/04 17:57
-- Use    : Snippets
-- Change :

function Snippets()
    if _ModalMgr then
        _ModalMgr.remove()
        _ModalMgr= nil
        return
    end

    _ModalMgr = ModalMgr()

    --- * ① read Data
    local path = hs.configdir.."/QSCode/Pasteboard/Snippets_Lua.txt"
    local message = "Exit Lua Snippets Edit Mode"
    local cfg = QSConfig()
    -- OC
    if cfg.config.programsIndex == 2 then
        path = hs.configdir.."/QSCode/Pasteboard/Snippets_OC.txt"
       message = "Exit OC Snippets Edit Mode"
    end
    local dataSoruce = HSDataSoruce(path)
    function saveWithStr(str)
        if #str > 0 then
            dataSoruce.dataSoruce[#dataSoruce.dataSoruce + 1] = str
            dataSoruce.save()
        else
            show("Error: 没数据 保存")
        end
    end

    local bindKeys = {
        {key = 'escape', message = message, pressedfn = mmExit},
        {key = 'q',      message = message, pressedfn = mmExit},
        -- Cheatsheet
        {key = 'tab',message ="Show Snippets Cheatsheet", pressedfn = _ModalMgr.show},

        {key = 'm',message ="make snippets phrase", pressedfn = function()
            local paste = Pasteboard()
            paste._callBackFn = function(text) hsKeymessageData(text) end
            paste.setPasteboard(true)
            mmExit()
        end},
        {key = 's',message ="Save code snippets", pressedfn = function()
            local paste = Pasteboard()
            paste._callBackFn = function(text)
                saveWithStr(text)
                show('Save code snippets' .. text)
            end
            paste.setPasteboard(true)
            mmExit()
        end},
        {key = 'r',message ="remove key snippets", pressedfn = function()
            local paste = Pasteboard()
            paste._callBackFn = function(text)
                for i,v in ipairs(dataSoruce.dataSoruce) do
                    local tab = hs.json.decode(v)
                    local key = tab['key']
                    if text == key then
                        dataSoruce.removeAtIndex(i)
                        dataSoruce.save()
                        show('remove snipple key : '..key..' at index : '..i )
                        break
                    end
                end
            end
            paste.setPasteboard(true)
            mmExit()
        end},
    }

    for i,v in ipairs(dataSoruce.dataSoruce) do
        -- {"key":"1","data":"paste.setPasteboard(true)","message":"message"}
        local tab = hs.json.decode(v)
        local key = tab['key']
        if #key == 1 then
            local message = tab['message']
            local data    = tab['data']
            if message == 'message' then
                -- 截取 35个 char
                message = string.gsub(data, "  ", " ")
                message = string.gsub(message, "\n", " ")
                local len = 35
                if #message > len then message =  string.sub(message, 0, len) end
            end

            bindKeys[#bindKeys + 1] = { key = key, message = message, pressedfn = function()
                if data then
                    if string.find(data, '_replace_') then
                        local paste = Pasteboard()
                        paste._callBackFn = function(text)
                            -- 替换 _replace_ 一个单词
                            if regular.evaluateWithString(text, "SELF MATCHES %@", '[a-zA-Z0-9]{3,18}') then
                                local replace = regular.replace(data, '_replace_', text)
                                return replace
                            end
                            return data
                        end
                        paste.setPasteboard(true)
                    elseif string.find(data, '_replaces_') then
                        show('_replaces_')
                    else
                        hsPasteWithString(data)
                    end
                end
                mmExit()
            end }
        else
            show('Snippets key Error :'..key)
        end
    end

    _ModalMgr.run(bindKeys)
    _ModalMgr.show()
end



--
