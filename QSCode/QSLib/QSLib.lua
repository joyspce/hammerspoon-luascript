
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

-- //  : QSLib

-- a = 6 > 5 and "大" or "小"

-- // ———————————————————————————— function ————————————————————————————
-- function conditionFn(isTrue, fnA, fnB) if isTrue then fnA() else fnB() end end

---
--- Description qsRange 效仿 python range

--- param: intger > 0
--- return: function
---
-- for i in qsRange(3) do  print(i) end
function qsRange(intger)
    assert(type (intger) == "number", "qsRange 参数 输入 Error")
    local i = 0
    return function()
        i = i + 1
        if i <= intger then return i end
    end
end
function urlDecode(url)
	return url:gsub('%%(%x%x)', function(x)
		return string.char(tonumber(x, 16))
	end)
end

function qsFunction(fn, ...)
    local args = {...}
    return function() fn(table.unpack(args)) end end

function NSLog(format, ...) print(string.format(format, ...)) end

function qsInc(num, val) return num + (val or 1) end

function qsDec(num, val) return num - (val or 1) end

-- // ———————————————————————————— file operation ————————————————————————————
function qsReadFile(path)
   local array={}
   local file = assert(io.open(path,"r"))
   if file then
       local i = 1
       for line in file:lines() do
           array[ i ] = line
           i = i + 1
       end
       file:close()
   end
   return array
end
function qsSaveOrAddWithStr(path,r_w_a,...)
   local r_w_a = r_w_a or "r"
   local file = assert(io.open(path,r_w_a))
   if file then
       file:write(...)
       file:close()
   end
end

-- // ———————————————————————————— table ————————————————————————————
function qsTableLen(tab)
    assert(tab, "qsTableLen(tab) 值不对")
    local count = 0
    for k,v in pairs(tab) do count = count + 1; end
    return count
end

-- 判断是否是数组
function qsIsArray(array) return #array == qsTableLen(array) end

function isFileKinds(val, tbl)
    for _, v in ipairs(tbl) do
        if val == v then
            return true
        end
    end
    return false
end
function qsIndexOrKeyInTable(tab,value)
    -- array
    if qsIsArray(tab) then
        for i,v in ipairs(tab) do
            if v == value then return i; end
        end
    else
        -- table
        for k,v in pairs(tab) do if v == value then return k end end
    end
    return nil
end

--- func : keys and vars to dictionary
--- param: keys array
--- param:  vars array
--- return: table dictionary
function qsDictFormKeysAndVars(keys, vars)
    assert(#keys == #vars, "function qsDictFormKeysAndVars error")
    local dict = {}
    for i, key in ipairs(keys) do dict[key] = vars[i] end
    return dict
end

-- 去除相同数组里的string
function qsRemoveSameStringInArray(array)
    local dict = {}
    for i,v in ipairs(array) do dict[v] = v end
    local array = {}
    for k,v in pairs(dict) do array[#array + 1] = k end
    return array
end

-- 字符串到数组
function qsSplit(str, separator)
    local startIndex = 1
    local splitIndex = 1
    local array = {}
    while true do
        local index = string.find(str, separator, startIndex)
        if not index then
            array[splitIndex] = string.sub(str, startIndex, string.len(str))
            break
        end
        array[splitIndex] = string.sub(str, startIndex, index - 1)
        startIndex = index + string.len(separator)
        splitIndex = splitIndex + 1
    end
    return array
end

function qsArray1_z()
    return {
        '1','2','3','4','5','6','7','8','9','0',
         'a','b','c','d','e','f','g',
         'h','i','j','k','l','m','n',
         'o','p','q','r','s','t',
         'u','v','w','x','y','z'
     }
end
function qsArray1_zKey()
    local array1_z = qsArray1_z()
    local i = 1
    return function ()
        local temp = array1_z[i]
        i = i + 1
        return temp
    end
end

-- // ———————————————————————————— string ————————————————————————————

function qsIsEmpty(var)
    if var == nil then return true end
    local varType = type(var)
    if varType == "bool" then return not var end
    if varType == "number" and var == 0 then return true end
    if varType == "string" and #var == 0 then return true end
    if varType == "table" and qsTableLen(var) == 0 then return true end
    return false
end

function qsIsStringEmpty(str)
    if not str or #str == 0 then return true end
    str = string.match(str, "%s*(.-)%s*$")
    str = string.gsub(str, '\n', '')
    if not str or #str == 0 then return true end
    return false
end

function qsIsNumber(value) return type(value) == "number" end

function qsIsTable(value) return type(value) == "table" end

function qsIsFindInLower(str, str1)
    str = string.lower(str)
    str1 = string.lower(str1)
    return string.find(str, str1)
end
-- is前缀
function qsIsPreFix(str, preFix) return string.sub(str,1,#preFix) == preFix end
-- is小写
function qsIsLowerWithChar(char)
    if string.len(char) == 1 then
        local varNum = string.byte(char)
        return (varNum >= 97 and varNum <= 122);
    end
    return false;
end
-- is大写
function qsIsUpperWithChar(char)
    if string.len(char) == 1 then
        local varNum = string.byte(char)
        if varNum >= 65 and varNum <= 90 then return true end
    end
    return false;
end
-- is数字
function qsIsNumberWithChar(char)
    if string.len( char ) == 1 then
        local varNum = string.byte( char )
        if varNum >= 48 and varNum <= 57 then return true; end
    end
    return false;
end



-- 中文字节识别
function qsChineseWordLen(curByte)
    local byteCount = 0
    if curByte > 0 and curByte < 128 then
        byteCount = 1
    elseif curByte>=128 and curByte<224 then
        byteCount = 2
    elseif curByte>=224 and curByte<240 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

function qsIsCharOrBlankOrChinese(char)
    local byte = qsChineseWordLen(string.byte(char))
    if byte == 3 or byte == 4 or char == " " then return true end
    return qsIsNumberWithChar(char) or qsIsLowerWithChar(char) or qsIsUpperWithChar(char)
end

-- ret 首字母大写
function qsUpperFirstWord(words)
    if not words or #words < 1 then show("qsUpperFirstWord Error"); return end
    local aletter = string.sub(words, 0, 1);
    aletter = string.upper(aletter);
    return aletter .. string.sub(words, 2, #words)
    -- return words:gsub("^%a", string.upper):gsub("%s+%a", string.upper)
end
-- ret 取大写字母
function qsGetUpChar(str)
    local len = #str
    local ret = ""
    for i=1, len do
        local char = string.sub(str, i, i)
        if qsIsUpperWithChar(char) then ret = ret..char end
    end
    return ret
end

-- 去除首位空格
function qsTrim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

-- 只留一个空格
function qsOnlyOneSpace(s)
    local array = qsSplit(str, " ")
    local text = ""
    for i,v in ipairs(array) do if #v > 0 then text = text..v.." " end end
    return text
end
-- 去所有空格
function qsRemoveAllSpace(str) return string.gsub(str," ","") end

-- ret str * time
function qsStringTimes(time, str)
    if time < 1 then return "" end
    local str = str or " "
    local text = ""
    for i=1, time do text = text .. str end
    return text
end

-- ret current time
function qsOsTime() return os.date("%Y-%m-%d %H:%M") end


-- 找出文件名
function qsLasFileName(str)
    while true do
        local index = string.find(str, '/', 1)
        if (index == nil) then return str; end
        str = string.sub(str, index + 1, string.len(str));
    end
end


-- 打印 tab or fnAction
function qsPrintTable(tab)

    local count = 1
    -- array
    if qsIsArray(tab) then
        for i,v in ipairs(tab) do
            if type(v) == "table" then
                qsPrintTable(v)
            elseif type(v) ~= "function" then
                print(count.." : arr["..i.."] :", " var :", tostring(v), "\n")
                count = count + 1
            end
        end
    -- table
    else
        for k,v in pairs(tab) do
            if type(v) == "table" then
                qsPrintTable(v)
            elseif type(v) ~= "function" then
                print(count.." : key :", k, " var :", tostring(v), "\n")
                count = count + 1
            end
        end
    end
end

function qsDelFile(path) os.execute("rm -rf "..path);  end
function qsCopyFile(filePath, toPath) os.execute("cp -rf "..filePath.." "..toPath); end

-- local _qsInspect = nil
-- function qsInspect(...)
--     if not _qsInspect then
--         _qsInspect = require("QSCode/QSLib/inspect")
--     end
--     _qsInspect(...)
-- end

-- // ———————————————————————————— net ————————————————————————————
-- qsCurlFtpSentToServer('pi', 'joyspace', '/Users/qinshaobo/Desktop/config.txt', 'ftp://192.168.31.188/anonymous/config.txt')
-- net ftp
function qsCurlFtpSentToServer(user, password, localFullPath, serverFullFilePath)
    --  curl --user pi:joyspace -T /Users/qinshaobo/Desktop/config.txt ftp://192.168.31.188/anonymous/config.txt
    local shell = " curl --user "..user ..":" ..password.." -T "..localFullPath.." "..serverFullFilePath
    print(shell)
    os.execute(shell)
end
function qsCurlFtpDownFromServer(user, password, localFullPath, serverFullFilePath)
    -- curl ftp://www.xxx.com/size.zip –u name:passwd -o size.zip
    local shell = "curl "..serverFullFilePath.." -u "..user..":"..password.." -o "..localFullPath
    os.execute(shell)
end
-- delete
function qsCurlFtpDeleteFile(user, password, serverFullFilePath, file)
    -- curl -v -u username：pwd ftp：// host /FileTodelete.xml -Q'-DELE FileTodelete.xml'
    local shell = "curl --user "..user..":"..password.." "..serverFullFilePath.." -Q '-DELE "..file.."'"
    print(shell)
    os.execute(shell)
end
-- QSFtp('pi', 'joyspace', 'ftp://192.168.31.188/') class
function QSFtp(user, password, host)
    local this = {}
    this.user = user
    this.password = password
    this.host = host

    this.sentFile = function(fromPath, toPath)
        qsCurlFtpSentToServer(this.user, this.password, fromPath, this.host..toPath)
    end
    this.fetchFile = function(fromPath, toPath)
        qsCurlFtpDownFromServer(this.user, this.password, this.host..fromPath, toPath)
    end
    this.deleteFile = function(deletePath)
        local file = qsLasFileName(deletePath)
        qsCurlFtpDeleteFile(this.user, this.password,
        this.host..deletePath, file)
    end
    return this
end

-- net ssh
function qsSSHSentToServer(port, host, localFullFile, serverFullFilePath)
    -- scp -P 2222 localFile root@loclahost:path
    local shell = "scp -P "..port.." "..localFullFile.." "..host..":"..serverFullFilePath
    os.execute(shell)
end
function qsSSHDownFromServer(port, host, localFullFile, serverFullFilePath)
    -- scp -P 2222 host:serverFullFilePath localFullFile
    local shell = "scp -P "..port.." "..serverFullFilePath.." "..localFullFile
    os.execute(shell)
end



--
