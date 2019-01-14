-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2019/01/03 05:21
-- Use    : QSCode/Pasteboard/LanguageSyntax.lua
-- Change :

function lsFormatTextWithBeginAndEnd(text, begin, _end)
    if not text then return end
    -- 取文字(字母, 数字, 中文), 去处标点符号
    local symbolBegin, symbolEnd = '', ''
    --- * ① 去除前后空格
    text = string.match(text, "%s*(.-)%s*$")

    local firstChar = string.sub(text, 0, 1)
    if firstChar == '{' then
        symbolBegin, symbolEnd = '{ ', ' }'
    elseif firstChar == '(' then
        symbolBegin, symbolEnd = '( ', ' )'
    elseif firstChar == '[' then
        symbolBegin, symbolEnd = '[ ', ' ]'
    end

    local words = regular.array(text, "[a-zA-Z0-9\\u4e00-\\u9fa5]+")
    local str = ''
    for i,v in ipairs(words) do str = str..begin..v.._end end
    str = string.sub(str, 1, #str-2)
    return symbolBegin..str..symbolEnd
end
local function formatDictionary(text)
    if not text then return end
    local words = regular.array(text,
        "[a-zA-Z0-9\\u4e00-\\u9fa5]+\\s{0,}=\\s{0,}[a-zA-Z0-9\\u4e00-\\u9fa5]+|[a-zA-Z0-9\\u4e00-\\u9fa5]+\\s{0,}:\\s{0,}[a-zA-Z0-9\\u4e00-\\u9fa5]+")
    if words and #words ~= 0 then
        return words
    end
end

local function formatDictionaryLua(text)
    text = string.match(text, "%s*(.-)%s*$")
    local str = ''
    if regular.evaluateWithString(text, "SELF MATCHES %@", '[a-zA-Z0-9]{3,18}') then
        str = 'local '..text..'= {key = var}'
    else
        local dicts = formatDictionary(text)
        if dicts then
            str = "local dict = { "
            for i,v in ipairs(dicts) do
                str = str .. '\n'
                local replace = regular.replace(v,"\\s{0,}=\\s{0,}|\\s{0,}:\\s{0,}", ' = "')
                str = str .. replace..'", '
            end
            str = string.sub(str, 0, #str - 2)
            str = str .. " }"
        end
    end
    if str == '' then
        str = "local dict = { }"
    end
    hsPasteWithString(str)
end
local function formatDictionaryOC(text)
    text = string.match(text, "%s*(.-)%s*$")
    local str = ''
    if regular.evaluateWithString(text, "SELF MATCHES %@", '[a-zA-Z0-9]{3,18}') then
        str = 'NSDictionary *'..text..' = @{ };'
    else
        local dicts = formatDictionary(text)
        if dicts then
            str = "NSDictionary *dict = @{ "
            for i,v in ipairs(dicts) do
                str = str .. '\n'
                -- @"name":@"lnj"
                str = str .. '@"'..regular.replace(v,"\\s{0,}=\\s{0,}|\\s{0,}:\\s{0,}", [[" : @"]]).. '", '
            end
            str = string.sub(str, 0, #str - 2)
            str = str .. " };"
        end
    end
    if str == '' then
        str = 'NSDictionary *dict = @{ };'
    end
    hsPasteWithString(str)
end
local function formatArrayLua(text)
    local str= "local array = { }"
    if text then
        text = string.match(text, "%s*(.-)%s*$")
        if regular.evaluateWithString(text, "SELF MATCHES %@", '[a-zA-Z0-9]{3,18}') then
            str = 'local '..text..'= { }'
        else
            local words = regular.array(text, "[a-zA-Z0-9\\u4e00-\\u9fa5]+")
            if words then
                str = 'local array = { '
                for i,v in ipairs(words) do
                    str = str..'"'..v..'", '
                end
                str = string.sub(str, 0, #str - 2)
                str = str .. " }"
            end
        end
    end
    hsPasteWithString(str)
end
local function formatArrayOC(text)
    local str= "NSArray *array = @[ ];"
    if text then
        text = string.match(text, "%s*(.-)%s*$")
        if regular.evaluateWithString(text, "SELF MATCHES %@", '[a-zA-Z0-9]{3,18}') then
            str = 'NSArray *'..text..' = @[];'
        else
            local words = regular.array(text, "[a-zA-Z0-9\\u4e00-\\u9fa5]+")
            if words then
                -- @[@"Jack", @"Rose", @"Jim"];
                str = 'NSArray *array = @[ '
                for i,v in ipairs(words) do
                    str = str..'@"'..v..'", '
                end
                str = string.sub(str, 0, #str - 2)
                str = str .. " ];"
            end
        end
    end
    hsPasteWithString(str)
end
local function removeSameString(text)
    local array = qsSplit(text,"\n")
    local haveInArray = {}
    local str = ""
    for i,var in ipairs(array) do
        local temp = string.match(var, "%s*(.-)%s*$")
        if regular.evaluateWithString(temp, "SELF MATCHES %@", '[^a-z^A-Z^0-9]+.+') then
             str = str..var.."\n"
        else
            if not qsIndexOrKeyInTable(haveInArray, var) then
                haveInArray[#haveInArray+1] = var
                str = str..var.."\n"
            end
        end
    end
    hsPasteWithString(str)
end
-- - (instancetype)initWithMake: (NSString *)make model:(NSString *)model imageName:(NSString *)imageName
local function formatXcodeClassMethod(text)
    local rets =  regular.array(text, [[[-+]{1}[ ]{0,5}\({1}[ ]{0,5}[a-zA-Z0-9]{1,20}[ ]{0,5}\**]])
    local str = ''
    if rets and rets[1] then
        local ret = regular.replace(rets[1], "^\\s*[+-]?\\s+[(]{0,2}", "")
        ret = string.match(ret, "%s*(.-)%s*$")
        if ret and not qsIsFindInLower(ret, 'void') then
            if string.find(ret, '*') then
                str = text .." {\n\t//add code here\n\t".."return ("..ret..") value".."\n}"
            else
                str = text .." {\n\t//add code here\n\t".."return "..ret.." value".."\n}"
            end
        else
            str = text .." {\n\t//add code here\n}"
        end
        hsPasteWithString(str)
    else
        show("Error: " .. text)
    end
end

-- s.addKey('n', "NSCoding",        function() pboNSCoding(s.currentText) mmExit() end)
local function index_comparesInLower(array, aType)
    if aType == "NSInteger" then aType = "int64" end
    for i,v in ipairs(array) do
        local lowerStr = string.lower(v)
        aType = string.lower(aType)
        print("lowerStr ", lowerStr, "aType ", aType)
        if string.find(lowerStr, aType) then return array[i] end
    end
    return "encodeObjectXXX"
end
local function encodeNSCoding(property, aType)
    local str = string.gsub(property, "*", "")
    if property == str then
        local encode = index_comparesInLower(
        {"encodeBool", "encodeInt", "encodeInt64", "encodeFloat", "encodeDouble"}, aType)
        return string.format('\t[coder %s:_%s forKey:@"%s"];', encode, str, str)
    else -- obj
        return string.format('\t[coder encodeObject:_%s forKey:@"%s"];', str, str)
    end
end
local function decodeNSCoding(property, aType)
    local str = string.gsub(property, "*", "")
    if property == str then
        local decode = index_comparesInLower(
        {"decodeBoolForKey","decodeIntForKey", "decodeInt64ForKey", "decodeFloatForKey", "decodeDoubleForKey"}, aType)
        return string.format('\t\t_%s = [coder %s:@"%s"];', str, decode, str)
    else -- obj
        return string.format('\t\t_%s = [coder decodeObjectForKey:@"%s"];', str, str)
    end
end
local  function pboNSCoding(text)
    local array = qsSplit(text,"\n")
    local text1, text2 = "", ""
    for i,v in ipairs(array) do
        if string.find(v, ";") and string.find(v, "@property")  then
            v = string.gsub(v, ";", "")
            local strs = qsSplit(v, " ")
            local property = strs[#strs]
            print(property)
            text1 = text1..encodeNSCoding(property, strs[#strs-1]).."\n"
            text2 = text2..decodeNSCoding(property, strs[#strs-1]).."\n"
        else
            text1 = text1..v.."\n"
            text2 = text2..v.."\n"
        end
    end
    local str = string.format([[
// 1、将数据以键值对的形式存储在 NSCoder中
- (void)encodeWithCoder:(NSCoder *)coder {
    //[super encodeWithCoder:coder];
%s
}
// 2、存储在NSCoder中的数据 通过键值对方式取出
- (instancetype)initWithCoder:(NSCoder *)coder {
    //self = [super initWithCoder:coder];
    if (self) {
%s
    }
    return self;
}

%s
    ]], text1, text2, [[
//NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
//NSString *library = [filePaths objectAtIndex:0]
//NSString *filePath = [NSString stringWithFormat:@"%@/filedapp", library];
//NSFileManager *fileManager = [NSFileManager defaultManager];
//if ([fileManager fileExistsAtPath:filePath]) {
//    NSLog(@"存在");
//    QSArchiver *model = [NSKeyedUnarchiver unarchiveObjectWithFile: filePath];
//    NSLog(@"model.mobile : %@", model.mobile);
//    NSLog(@"model.type   : %@", model.type);
//} else {
//    NSLog(@"不存在");
//    QSArchiver *model = [[QSArchiver alloc]init];
//    model.mobile = @"123456789";
//    model.type   = @"phone";
//    [NSKeyedArchiver  archiveRootObject:model toFile:filePath];
//}
]])
    hsPasteWithString(str)
end
--- s.addKey('j', "JsonToModel",     function() pboJsonToModel(s.currentText) mmExit() end)
--- test {"kkd":11, "joys":"name", "flag":true, "kids":{"age":11, "sex":true,}, "kkd1":11.1 }
function pboJsonToModel(text)
    local jsonDic = hs.json.decode(text)

    local qsse_makeObj_c_Model_text = ""
    local count = 0
    function makeObj_tab(tab)
        local format = string.format
        count = count + 1
        local text = "////////////////// ClassModel "..count.."\n\n"
        for k,v in pairs(tab) do
            if type(v) == "table" then
                if #v > 0 then
                    text = text..format("@property (nonatomic, strong) NSSArray *%s;\n\n", k)
                else
                    makeObj_tab(v)
                    text = text..format("@property (nonatomic, strong) ClassModel%d *%s;\n\n", count, k)
                end
            else
                if type(v) == "string" then
                    text = text..format("@property (nonatomic, copy  ) NSString *%s;\n\n", k)
                elseif type(v) == "boolean" then
                    text = text..format("@property (nonatomic, assign) BOOL %s;\n\n", k)
                elseif type(v) == "number" then
                    local str_var = tostring(v)
                    if string.find(str_var, ".") and str_var+0 == math.floor(v) then
                        text = text..format("@property (nonatomic, assign) NSInteger %s;\n\n", k)
                    else
                        text = text..format("@property (nonatomic, assign) float %s;\n\n", k)
                    end
                else
                    show("json not clear")
                end
            end
        end
        qsse_makeObj_c_Model_text = qsse_makeObj_c_Model_text..text.."\n"
    end

    if jsonDic then
        makeObj_tab(jsonDic)
        hsPasteWithString(qsse_makeObj_c_Model_text)
    else
        show("no json in pasteboard")
    end
end
-- s.addKey('c', "To HCaptainFunc", function() pboToHCaptainFunc(s.currentText) mmExit() end)
--      pressedfn = function() pboToHCaptainFunc() mmExit() end},
-- qsPrintTable(splitMethod("- (void)addNavigationItemWithImageNames:(NSArray *)imageNames isLeft:(BOOL)isLeft target:(id)target"))
-- 1.hook函数
--
-- 1.hook类
--     CHDeclareClass(<#name#>)
--
-- 2.hook类方法
--     CHOptimizedClassMethod0(<#optimization#>, <#return_type#>, <#class_type#>, <#name#>)
--
-- 3.hook对象方法
--     CHOptimizedMethod0(<#optimization#>, <#return_type#>, <#class_type#>, <#name#>)
-- 2.新增函数
--
-- 1.新增属性
--     CHPropertyRetainNonatomic(<#class#>, <#type#>, <#getter#>, <#setter#>)
--
-- 2.新增方法
--     1.新增类方法
--         CHDeclareClassMethod0(<#return_type#>, <#class_type#>, <#name#>)
--     2.新增对象方法
--         CHDeclareMethod0(<#return_type#>, <#class_type#>, <#name#>)
-- 3.构造函数
--
-- CHConstructor{}
-- 在构造函数中
--           CHLoadLateClass(<#name#>);            hook类
--           CHClassHook0(<#class#>, <#name#>)     hook方法
--           CHHook0(<#class#>, <#name#>)          添加属性时,需要这样写对应的set, get
function pboToHCaptainFunc(text)
    local text = string.gsub(text, '%(', "  ")
    text = string.gsub(text, '%)', "  ")
    text = string.gsub(text, ":", "  ")
    text = string.gsub(text, "  ", " ")
    text = string.gsub(text, " %*", "*")
    text = string.gsub(text, ";", "")

    local array = qsSplit(text)
    --- 1.hook函数
    -- 1.hook类
    text = "CHDeclareClass(<#input_your_class#>);\n"

    local classMethod = array[1]
    if classMethod == "+" then
        -- 2.hook类方法
        text = text .."CHOptimizedClassMethod("
    elseif classMethod == "-" then
        -- 3.hook对象方法
        text = text .."CHOptimizedMethod("
    else
        show("Error : you have to copy object-c method")
        return ""
    end
    -- CHOptimizedMethod1(optimization, return_type, class_type, name1, type1, arg1)
    -- 参数的个数                -- optimization return_type
    local count = math.floor((#array - 2)/3)
    text = text..count..", self, "..array[2]..", <#input_your_class#>, "

    local nameAndtypeAndArg = ""
    local badyStr = ""
    local lastHookStr = ""
    for i= 3, #array do
        local var = array[i]
        var = string.gsub(var, "%*", " *")
        if i == #array then
            nameAndtypeAndArg = nameAndtypeAndArg..var..");"
        else
            nameAndtypeAndArg = nameAndtypeAndArg..var..", "
        end
        if not (i == 4 or i == 7 or i == 10 or i == 13 or i == 16 or i == 19 or i == 21 or i == 25) then
            if i%3 == 0 then lastHookStr = lastHookStr .. var.."," end
            badyStr = badyStr..var..","
        end
    end
    text = text..nameAndtypeAndArg
    badyStr = string.sub(badyStr, 1, #badyStr-1)
    local body = ""
    if array[2] == "void" then
        body = string.format("{\n    CHSuper%d(<#input_your_class#>,  %s)\n}",count,  badyStr)
    else
        body = string.format("{\n    return CHSuper%d(<#input_your_class#>,  %s)\n}",count,  badyStr)
    end
    -- CHConstructor
    lastHookStr = string.sub(lastHookStr, 1, #lastHookStr-1)
    local lastHook = string.format("CHHook%d(<#input_your_class#>, %s);",count, lastHookStr)

    hsPasteWithString(text..body.."\nCHLoadLateClass(<#input_your_class#>);\n"..lastHook)
end
-- s.addKey('h', "To HookFunc",     function() pboToHookFunc(s.currentText) mmExit() end)
-- 替换文字
local function pboWriteCodesHookFun(codes)
    ------------ 生成 粘贴 hook logs hook
    function toSubStrs(args)
        local paras = {};
        for i,str in ipairs(args) do
            if #str > 1 then
                -- 取括号内的str
                local from, to = string.find( str, ":" )
                local from1, to1 = string.find( str, "arg" )

                local idStr = "unknow"
                if (to and from1) then
                    idStr = string.sub(str, to+1, from1-1 )
                    -- block
                    if ( string.find(idStr, "block") ) then
                        args[i] = qsSplit(str, ":")[1]..":(/*block*/id) %p"
                        paras[#paras + 1] = "arg"..i
                    -- class
                    elseif ( string.find(idStr, "id")  ) then
                        args[i] = qsSplit(str, ":")[1]..":(%@ *) %@ "
                        local arg = "arg"..i
                        paras[#paras + 1] = "[" .. arg .. " class],"..arg ..","
                    -- double
                    elseif( string.find(idStr, "double")  ) then
                        args[i] = qsSplit(str, ":")[1]..":(double) %f"
                        paras[#paras + 1] = "arg"..i
                    -- 默认 int
                    else
                        args[i] = qsSplit(str, ":")[1]..": %d"
                        paras[#paras + 1] = "arg"..i
                    end
                end
            end
        end

        local strCon = ""
        for i,str in ipairs(args) do
            strCon = strCon ..str
        end

        if (#paras > 0) then            -- 有参数的 method
            strCon = strCon .. "\","
        else                            -- 没参数的 method
            strCon = strCon .. "\""
        end

        for i,str in ipairs(paras) do
            strCon = strCon ..str
        end

        return strCon;
    end

    local codesStr = ""
    -- - (id)
    local pre_voidOrID = ""
    for i, str in ipairs(codes) do
        codesStr = codesStr..str .. "{\n    KQL_SaveLog(@\""
        -- 去 - (id)
        local from, to = string.find(str, ")")
        pre_voidOrID = string.sub(str, 0, to)
        str = string.sub(str, to + 1, #str )
        --str to array
        local subStrs = qsSplit(str, " ")

        codesStr = codesStr..toSubStrs(subStrs)

        codesStr = codesStr .. ");\n"
        -- 尾部
        if ( string.find(pre_voidOrID, "void") ) then
            codesStr = codesStr .. "\n%orig;\n"
        else
            codesStr = codesStr .. [[   id ret = %orig;
    KQL_SaveLog(@"return class : %@", [ret class]);
    return ret;
            ]]
        end
        codesStr = codesStr .. "}"
    end
    return codesStr
end
function pboToHookFunc(text)
    local toHookString = ""
    -- 1. hook string calss
    local from = string.find(text, ")")
    if not from then
        toHookString = "%hook " .. text .. "\n\n%end"
    else
        -- 2. method string
        -- 替换
        local replaceBlock = string.gsub(text,  "CDUnknownBlockType", "/*block*/id" )
        -- 分成数组
        local arrayRe = qsSplit(replaceBlock, ";")
        toHookString = pboWriteCodesHookFun(arrayRe)
        -- show("hook method")
    end
    hsPasteWithString(toHookString)
end

function LanguageSyntax()
    if _OperationMgr then
        _OperationMgr.remove()
        _OperationMgr = nil
        return
    end

    local path = hs.configdir.."/QSCode/Pasteboard/LanguageSyntax__.txt"
    _OperationMgr = OperationMgr(path)

    local s = _OperationMgr

    s.addKey('escape', "Exit Edit Mode", mmExit)
    s.addKey('q',      "Exit Edit Mode",  mmExit)
    s.addKey()

    s.addKey('c', "Translate to Pasteboard", s.copyTranslateToPasteboard)

    s.addKey()
    s.addKey('p', "Pasteboard to current Edit", function()
        if s.currentText then
            hsPasteWithString(s.currentText)
        end
        mmExit()
    end)
    s.addKey('r', 'remove same line', function()
        if s.currentText then removeSameString(s.currentText) end
        mmExit()
    end)
    s.addKey('m', 'simple format to "string"', function()
        if s.currentText then
            local str = hs.json.encode({s.currentText})
            str = string.sub(str, 2, #str-1)
            hsPasteWithString(str)
        end
        mmExit()
    end)

    function currentTextFormatAndPast(block, line)
        if s.currentText then
            local str = nil
            if regular.evaluateWithString(s.currentText, "SELF MATCHES %@", '[a-zA-Z]{3,18}') then
                str = string.format(line, s.currentText)
            else
                str = string.format(block, s.currentText)
            end
            hsPasteWithString(str)
        end
        mmExit()
    end

    local cfg = QSConfig()
    -- Lua
    if cfg.config.programsIndex == 1 then
        s.operationTitle('Lua Sytnax Operation')

        -- "evrey"
        s.addKey('w', 'evrey words to "string"', function()
            if s.currentText then
                hsPasteWithString(lsFormatTextWithBeginAndEnd(s.currentText , '"',  '", '))
            end
            mmExit()
        end)

        s.addKey()
        s.addKey('i', "if then end",      function()
            currentTextFormatAndPast('if  then\n   %s\nend\n', 'if %s then\n\nend\n')
        end)
        s.addKey('e', "if then else end", function()
            currentTextFormatAndPast('if  then\n   %s\nelse\n\nend\n', 'if %s then\n\nelse\n\nend\n')
        end)
        s.addKey('f', "function() end",   function()
            currentTextFormatAndPast('function ()\n    %s\nend', 'function %s()\n    \nend' )
        end)
        s.addKey('n', "none name function() end", function()
            if s.currentText then hsPasteWithString('function()  end') end
            mmExit()
        end)
        s.addKey('o', 'function class() end', function()
            currentTextFormatAndPast(
            "function ClassName()\n\tlocal s = {}\n\t %s\n-- property\n\ts.property = nil\n\t-- method\n\ts.method = function()\n\n\tend\n\treturn s\nend",
            "function %s()\n\tlocal s = {}\n\t-- property\n\ts.property = nil\n\t-- method\n\ts.method = function()\n\n\tend\n\treturn s\nend"
            )
        end)
        s.addKey('d', 'local dict = {}', function()
            formatDictionaryLua(s.currentText)
            mmExit()
        end)
        s.addKey('a', 'local array = {}', function()
            formatArrayLua(s.currentText)
            mmExit()
        end)
        s.addKey('k', 'make snippets phrase', function()
            hsKeymessageData(s.currentText)
            mmExit()
        end)
    -- OC
    elseif cfg.config.programsIndex == 2 then
        s.operationTitle('OC Sytnax Operation')
        s.addKey('w', 'evrey words to @"string"', function()
            if s.currentText then
                hsPasteWithString(lsFormatTextWithBeginAndEnd(s.currentText , '@"',  '", '))
            end
            mmExit()
        end)

        s.addKey()
        s.addKey('d', 'NSDictionary *dict = {}', function()
            formatDictionaryOC(s.currentText)
            mmExit()
        end)
        s.addKey('a', 'NSArray *array = @[]', function()
            formatArrayOC(s.currentText)
            mmExit()
        end)
        s.addKey('o', '+- OC Method format', function()
            formatXcodeClassMethod(s.currentText)
            mmExit()
        end)
        s.addKey('n', "NSCoding",        function() pboNSCoding(s.currentText) mmExit() end)
        s.addKey('j', "JsonToModel",     function() pboJsonToModel(s.currentText) mmExit() end)
        s.addKey('b', "JailBreak To HCaptainFunc", function() pboToHCaptainFunc(s.currentText) mmExit() end)
        s.addKey('h', "JailBreak To HookFunc",     function() pboToHookFunc(s.currentText) mmExit() end)
    end

    s.reloadData(function(message)
        if hsIsSavePasteboard(message) then
            s.setCurrentText(message)
            s.currentText = message
        end
    end)

    local paste = Pasteboard()
    paste._callBackFn = function(str)
        s.setCurrentText(str)
        s.currentText = str
    end
    paste.setPasteboard(true)
end






--
