
-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/12/29 16:09
-- Use    : ClipShow
-- Change :


function ClipShow()
    if _OperationMgr then
        _OperationMgr.remove()
        _OperationMgr = nil
        return
    end

    local path = hs.configdir.."/QSCode/Pasteboard/ClipShow.txt"
    _OperationMgr = OperationMgr(path)

    local s = _OperationMgr

    s.operationTitle('Pasteboard Operation')
    --- * ③ Operation bindKeys
    function openURL(http)
        local text = s.currentText or ""
        local encoded_query = hs.http.encodeForQuery(text)
        print(encoded_query)
        local defaultbrowser = hs.urlevent.getDefaultHandler("http")
        hs.urlevent.openURLWithBundle(http..encoded_query, defaultbrowser)
        mmExit()
    end
    function copyToApp(app)
        if s.currentText and hsIsSavePasteboard(s.currentText) then
            if hs.application.launchOrFocus(app) then
                hsDelayedFn(0.4, function() koKeyStroke({'cmd'}, 'v') end)
            end
        end
        mmExit()
    end

    s.addKey('escape', "Exit Edit Mode", mmExit)
    s.addKey('q',      "Exit Edit Mode", mmExit)
    s.addKey()

    s.addKey('c', "Translate to Pasteboard", s.copyTranslateToPasteboard)

    s.addKey()
    s.addKey('o', "open in browser",
        function()
            local defaultbrowser = hs.urlevent.getDefaultHandler("http")
            local url = string.gsub(s.currentText, " ", "")
            -- replace(str, pattern, replace)
            url = regular.replace(s.currentText, [[https?|：?:?/?/?]], '')
            hs.urlevent.openURLWithBundle(url, defaultbrowser)
            mmExit()
        end)
    s.addKey('b', "search In Bing",
        function() openURL("https://www.bing.com/search?q=") end)
    s.addKey('j', "search In Janshu",
        function() penURL("https://www.jianshu.com/search?q=") end)
    s.addKey('z', "search In ZhiHu",
        function() openURL("https://www.zhihu.com/search?type=content&q=") end)
    s.addKey('t', "search In TaoBao",
        function() openURL("http://s.taobao.com/search?q=") end)
    s.addKey('s', "search In ShouGou",
        function() openURL("https://www.sogou.com/web?query=") end)
    s.addKey('d', "search In Baidu",
        function() openURL("https://www.baidu.com/s?wd=") end)
    s.addKey('g', "search In GitHub",
        function() openURL("https://github.com/search?q=") end)
    s.addKey()
    s.addKey('x', "Copy to Xcode",       function() copyToApp('Xcode') end)
    s.addKey('n', "Copy to Notes",       function() copyToApp("Notes") end)
    s.addKey('a', "Copy to Atom",        function() copyToApp("Atom")  end)
    s.addKey('u', "Copy to Quiver",      function() copyToApp("Quiver") end)
    s.addKey('i', "Copy to iTerm",       function() copyToApp("iTerm") end)
    s.addKey('h', "Copy to hammerspoon", function() copyToApp("hammerspoon") end)

    s.reloadData(function(message)
        if hsIsSavePasteboard(message) then
            s.setCurrentText(message)
            s.currentText = message
        end
    end)

    --- * ⑤ 从粘贴板读取
    local paste = Pasteboard()
    paste._callBackFn = function(str)
        s.setCurrentText(str)
        s.currentText = str
    end
    paste.setPasteboard(true)
end




--
