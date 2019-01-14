-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/11/26 22:24
-- Use    : 配置 QSConfig




-- ctrl.add('c', "Change 1.programs 2.localLanguage",
_config = nil

function QSConfig()
    if _config then return _config end

    local s = {}
    _config = s

    s.config = {}

    --- * 01 编程语言
    s.config.programsIndex = 1
    s.programs = {'lua', 'oc'}
    s.changeprograms = function()
        local index = s.config.programsIndex
        index =  index % #s.programs + 1
        s.config.programsIndex = index
        s.save()
        show("programs language changed to "..s.programs[index])
    end

    --- * 02 注释数字
    s.config.commentIndex = 1
    s.nums = { -- 1
            {'01','02','03','04','05','06','07','08','09','10',
             '11','12','13','14','15','16','17','18','19','20'},
             -- 2
            { "①","②","③",'④','⑤','⑥','⑦','⑧','⑨','⑩',
              '⑪','⑫','⑬','⑭','⑮','⑯','⑰','⑱','⑲','⑳'}
            }
    s.changeComment = function()
        s.config.commentIndex = s.config.commentIndex % #s.nums + 1
        s.save()
        local num = s.nums[s.config.commentIndex]
        show("comment number changed to :"..num[1])
    end
    --- * 03 本地语言支持
    s.config.localIndex = 1
    s.localLanguage = {'English', '中文'}
    s.changeLocal = function()
        s.config.localIndex = s.config.localIndex % #s.localLanguage +  1
        s.save()
        show('local language changed to :' .. s.localLanguage[s.config.localIndex])
        hs.reload()
    end

    s.path = hs.configdir.."/resources/Config.txt"
    s.save = function() qsSaveOrAddWithStr(s.path, 'w', hs.json.encode(s.config)) end
    -- init
    -- * 1.read path
    if hsIsFileExist(s.path) then
        local jsons = qsReadFile(s.path)
        s.config = hs.json.decode(jsons[1])
    else
        s.save()
    end

    return s
end

function qscLang(...)
    local lan = {...}
    local cfg = QSConfig()
    return lan[cfg.config.localIndex]
end








--
