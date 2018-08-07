
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

-- //  : QSLib

-- // ———————————————————————————— file operation ————————————————————————————
function qsl_arrayRead(path)
   local arrayStr,configfile = {},assert(io.open(path,"r"));
   if configfile then
      for configline in configfile:lines() do arrayStr[ #arrayStr + 1 ] = configline; end
      configfile:close();
   end
   return arrayStr;
end
function qsl_readOrSaveOrAdd(path,readOrWriteOrAdd,...)
   local readOrWriteOrAdd,file = readOrWriteOrAdd or "r",assert(io.open(path,readOrWriteOrAdd));
   if file then file:write(...); file:close(); end
end

function delFile(path) os.execute("rm -rf "..path);  end
function copyFile(filePath, toPath) os.execute("cp -rf "..filePath.." "..toPath); end

-- // ———————————————————————————— function ————————————————————————————
-- function conditionFn(isTrue, fnA, fnB) if isTrue then fnA() else fnB() end end

-- // ———————————————————————————— table ————————————————————————————
function lenTable(theTable)
    assert(theTable, "function lenTable(theTable) 值不对")
    -- array
    if #theTable > 0 then
        return #theTable;
    -- table
    else
        local count = 0;
        for k,v in pairs(theTable) do count = count + 1; end
        return count;
    end
end
function indexOrKeyTable(theTable,theValue)
    -- array
    if #theTable > 0 then
        for i,v in ipairs(theTable) do
            if v == theValue then return i; end
        end
    -- table
    else
        for k,v in pairs(theTable) do
            if v == theValue then return k end
        end
    end
    return 0
end
-- 去除相同数组里的string
function removeSameStringInArray(array)
    local targetDic = {}
    for i,v in ipairs(array) do targetDic[v] = v end

    local retArray = {}
    for k,v in pairs(targetDic) do retArray[#retArray + 1] = k end
    return retArray
end
-- 字符串到数组
function arrayWithStringAndSplit(str,sep)
   local sep,fields = sep or ":",{}
   local pattern = string.format("([^%s]+)",sep)
   str:gsub(pattern,function(c) fields[#fields + 1] = c end)
   return fields
end
function qsl_arrayWithStringAndSplit(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
       if not nFindLastIndex then
           nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
           break
       end
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)
       nSplitIndex = nSplitIndex + 1
    end
    print("nSplitArray :", #nSplitArray)
    return nSplitArray
end
-- 打印 tab or fnAction
function printTab(tabOrArr)
    assert(type(tabOrArr) == "table", "Error: function printTab(tabOrArr, fnAction) tabOrArr is not table This type is ->"..type(tabOrArr))
    -- array
    if #tabOrArr > 0 then
        for i,v in ipairs(tabOrArr) do
            if type(v) == "table" then printTab(v) else print("arr["..i.."] :", " var :", v, "\n") end
        end
    -- table
    else
        for k,v in pairs(tabOrArr) do
            if type(v) == "table" then printTab(v) else print("key :", k, " var :", v, "\n") end
        end
    end
end

-- // ———————————————————————————— string ————————————————————————————

-- is前缀
function qsl_isPreFix(str, preFix) return string.sub(str,1,#preFix) == preFix end
-- is小写
function isLowerWithChar(char)
    if string.len(char) == 1 then
        local varNum = string.byte(char)
        return (varNum >= 97 and varNum <= 122);
    end
    return false;
end
-- is大写
function isUpperWithChar(char)
    if string.len(char) == 1 then
        local varNum = string.byte(char)
        if varNum >= 65 and varNum <= 90 then return true end
    end
    return false;
end
-- is数字
function isNumberWithChar(char)
    if string.len( char ) == 1 then
        local varNum = string.byte( char )
        if varNum >= 48 and varNum <= 57 then return true; end
    end
    return false;
end
-- ret 首字母大写
function upperFirstWord(words)
    if not words or #words < 1 then show("upperFirstWord Error"); return end
    local aletter = string.sub(words, 0, 1);
    aletter = string.upper(aletter);
    return aletter .. string.sub(words, 2, #words)
end
-- ret 取大写字母
function qsl_getUpChar(str)
    local len = #str
    local ret = ""
    for i=1, len do
        local char = string.sub(str, i, i)
        if isUpperWithChar(char) then ret = ret..char end
    end
    return ret
end
-- ret current time
function qsl_osTime() return os.date("%Y-%m-%d %H:%M") end
-- ret char * time
function retChar(char,time)
    local ret = ""
    for i=1, time do ret = ret .. char; end
    return ret;
end
-- 去空格
function qslRemoveSpace(str) return string.gsub(str," ","") end
-- 找出文件名
function last_fileName(str)
    while true do
        local index = string.find(str, '/', 1)
        if (index == nil) then return str; end
        str = string.sub(str, index + 1, string.len(str));
    end
end

-- // ———————————————————————————— net ————————————————————————————
-- qslCurlFtpSentToServer('pi', 'joyspace', '/Users/qinshaobo/Desktop/config.txt', 'ftp://192.168.31.188/anonymous/config.txt')
-- net ftp
function qslCurlFtpSentToServer(user, password, localFullPath, serverFullFilePath)
    --  curl --user pi:joyspace -T /Users/qinshaobo/Desktop/config.txt ftp://192.168.31.188/anonymous/config.txt
    local shell = " curl --user "..user ..":" ..password.." -T "..localFullPath.." "..serverFullFilePath
    print(shell)
    os.execute(shell)
end
function qslCurlFtpDownFromServer(user, password, localFullPath, serverFullFilePath)
    -- curl ftp://www.xxx.com/size.zip –u name:passwd -o size.zip
    local shell = "curl "..serverFullFilePath.." -u "..user..":"..password.." -o "..localFullPath
    os.execute(shell)
end
-- delete
function qslCurlFtpDeleteFile(user, password, serverFullFilePath, file)
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
        qslCurlFtpSentToServer(this.user, this.password, fromPath, this.host..toPath)
    end
    this.fetchFile = function(fromPath, toPath)
        qslCurlFtpDownFromServer(this.user, this.password, this.host..fromPath, toPath)
    end
    this.deleteFile = function(deletePath)
        local file = last_fileName(deletePath)
        qslCurlFtpDeleteFile(this.user, this.password,
        this.host..deletePath, file)
    end
    return this
end

-- net ssh
function qslSSHSentToServer(port, host, localFullFile, serverFullFilePath)
    -- scp -P 2222 localFile root@loclahost:path
    local shell = "scp -P "..port.." "..localFullFile.." "..host..":"..serverFullFilePath
    os.execute(shell)
end
function qslSSHDownFromServer(port, host, localFullFile, serverFullFilePath)
    -- scp -P 2222 host:serverFullFilePath localFullFile
    local shell = "scp -P "..port.." "..serverFullFilePath.." "..localFullFile
    os.execute(shell)
end





--
