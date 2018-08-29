
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

-- {'c',  "⇪ + C",  "1.@\" \"", qssePasteEditStringToNSString,
function qssePasteEditStringToNSString()
    qshs_savePasteboardFn(function(paste)
        local array = arrayWithStringAndSplit(paste,"\n")
        local str = "";
        for i,v in ipairs(array) do
            if (#v > 0) then str = str .. "@\"" .. v .. "\",\n" end
        end
        return str
    end)
end
-- "2.去重复", qssePasteStringRemoveSameString,
function qssePasteStringRemoveSameString()
    function isNotInArray(array, var)
        for i,v in ipairs(array) do
            if v == var then return false end
        end
        return true
    end
    qshs_savePasteboardFn(function(paste)
        local array = qsl_arrayWithStringAndSplit(paste,"\n")
        local haveInArray = {}
        local text = ""
        for i,var in ipairs(array) do
            if #var == 0 then
                text = text.."\n"
            elseif isPreFix(var, "//") or isPreFix(var, "--") or
                   isPreFix(var, "#") or  isPreFix(var, '"') then
                text = text..var.."\n"
            else
                if isNotInArray(haveInArray, var) then
                    haveInArray[#haveInArray+1] = var
                    text = text..var.."\n"
                end
            end
        end
        return text
    end)
end
-- "3.InputV", defeating_paste_blocking},
function defeating_paste_blocking()
    local text = hs.pasteboard.getContents()
     qshs_delayedFn(0.5, function() hs.eventtap.keyStrokes(text) end)
end

function _qsse_property_max_typeLen(array)
    local max = 0;
    for i,v in ipairs(array) do
        if #v > 1 then
            local code = arrayWithStringAndSplit(v, "%)")
            if #code >= 2 then
                code = arrayWithStringAndSplit(code[2], " ")
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
function _qsse_property_atomic(str)
    local dict = {
        strong = "strong",
        retain = "retain",
        weak   = "weak",
        copy   = "copy  ",
        assign = "assign",
    }
    if str == "atomic" then
        str = "atomic   "
    elseif str == "nonatomic" then
        str = "nonatomic"
    else
        for k,v in pairs(dict) do
            if string.find(str, k) then
                str = v
                break;
            end
        end
    end
    return str
end
function _qsse_property(str, typeLen)
    -- 1. @property (nonatomic, copy)
    print(str)
    local form = string.find(str, "%(")
    local to = string.find(str, "%)")

    local atomic = string.sub(str, form+1, to-1)
    local array = arrayWithStringAndSplit(atomic, ",")
    local text = "@property ("
    for i,v in ipairs(array) do
        if i == #array then
            text = text .._qsse_property_atomic(v)
        else
            text = text .._qsse_property_atomic(v)..", "
        end
    end
    text = text..") "
    -- (). % + - * ? [ ^ $
    -- 2.  NSString *endKeyWords2;
    local last = string.sub(str, to+1, #str)
    local lastStr = string.gsub(last, ";", "; ")
    lastStr = string.gsub(lastStr, " ;", ";")

    local lastArray = arrayWithStringAndSplit(lastStr, " ")

    for i,v in ipairs(lastArray) do
        if i == 1 then
            local len = typeLen - #v + 1
            local space = ""
            for idx = 1, len do
                space = space .." "
            end
            text = text..v..space
        else
            text = text..v
        end
    end
    return text
end

function _qsse_equalLen_stringReArrange(str)
    local text = ""

    local from = string.find(str, "=")
    if (from) then
        local leftStr = string.sub(str, 1, from - 1)
        local array = arrayWithStringAndSplit(leftStr, " ")
        for i,v in ipairs(array) do
            text = text.." "..v
        end
    end
    return text
end
function _qsse_equalLen(array)
    -- 1 先计数出最大line
    local maxLine = 0;
    for i, v in ipairs(array) do
        local leftStr = _qsse_equalLen_stringReArrange(v)
        if (#leftStr > maxLine) then maxLine = #leftStr  end
    end
    return maxLine
end
function _qsse_equal_Align(str, equalLen)
    local text = ""

    local from, to = string.find(str, "=");
    if (from) then
        -- 右边不动
        local rightStr = string.sub(str, to + 1, #str)
        rightStr = string.gsub(rightStr, "^%s*(.-)%s*$", "%1")
        local leftStr = string.sub(str, 1, from-1)
        leftStr = string.gsub(leftStr, "^%s*(.-)%s*$", "%1")

        local array = arrayWithStringAndSplit(leftStr, " ")
        for i,v in ipairs(array) do
            if i == #array then
                local temp = text..v
                local space = retChar(" ", equalLen - #temp - 1)
                if 1 == #array then
                    text = text..v..space
                else
                    text = text..space..v
                end
            else
                text = text..v.." "
            end
        end
        text = text.." = "..rightStr
    end
    return text
end
--  {'e',  "⇪ + E",  "Align=property 1.cut", qsse_cutAlignString, "2.in paste", qssePasteEditAlignString},
function qssePasteEditAlignString()
    print("qssePasteEditAlignString begin")
    qshs_savePasteboardFn(function(paste)
        local array = qsl_arrayWithStringAndSplit(paste,"\n")
        -- 3. 计数长度
        local typeLen
        local equalLen

        local alignArray = {}
        local countSpace = 0;
        for i,v in ipairs(array) do
            -- 处理 空行
            if 1 > #v then
                if countSpace == 0 then alignArray[#alignArray + 1] = "" end
                countSpace = countSpace + 1
            else
                -- method
                if isPreFix(v, "-") or isPreFix(v, "+") then
                    -- 特殊字符如下：(). % + - * ? [ ^ $  也作为以上特殊字符的转义字符 %
                    local str = string.gsub(v, "    ", " ")
                    str = string.gsub(str, "   ", " ")
                    str = string.gsub(str, "  ", " ")
                    str = string.gsub(str, ": ", ":")
                    str = string.gsub(str, " :", ":")
                    str = string.gsub(str, "%) ", ")")
                    str = string.gsub(str, " %)", ")")

                    str = string.gsub(str, " %(", "(")
                    str = string.gsub(str, "%( ", "(")
                    str = string.gsub(str, "+", "+ ")
                    str = string.gsub(str, "-", "- ")
                    str = string.gsub(str, " {", "{")
                    str = string.gsub(str, "{", " {")
                    alignArray[#alignArray + 1] = str
                elseif isPreFix(v, "@property") then
                --  property
                    countSpace = 0
                    if not typeLen then typeLen = _qsse_property_max_typeLen(array) end
                    alignArray[#alignArray + 1] = _qsse_property(v, typeLen)
                else
                    --  = 对齐
                    local findEqual = string.find(v, "=" );
                    if findEqual then
                        if not equalLen then equalLen = _qsse_equalLen(array) end
                        alignArray[#alignArray + 1] = _qsse_equal_Align(v, equalLen)
                    else
                        v = string.gsub(v, "  ", " ")
                        v = string.gsub(v, " //", "//")
                        v = string.gsub(v, "  //", "//")
                        alignArray[#alignArray + 1] = v
                    end
                end
            end
        end
        local targetStr = ""
        for i,v in ipairs(alignArray) do targetStr = targetStr .. v .. "\n" end
        return targetStr
    end)
end
------------ 生成 粘贴 hook logs hook
function _qssetoSubStrs(args)
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
                    args[i] = arrayWithStringAndSplit(str, ":")[1]..":(/*block*/id) %p"
                    paras[#paras + 1] = "arg"..i
                -- class
                elseif ( string.find(idStr, "id")  ) then
                    args[i] = arrayWithStringAndSplit(str, ":")[1]..":(%@ *) %@ "
                    local arg = "arg"..i
                    paras[#paras + 1] = "[" .. arg .. " class],"..arg ..","
                -- double
                elseif( string.find(idStr, "double")  ) then
                    args[i] = arrayWithStringAndSplit(str, ":")[1]..":(double) %f"
                    paras[#paras + 1] = "arg"..i
                -- 默认 int
                else
                    args[i] = arrayWithStringAndSplit(str, ":")[1]..": %d"
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
-- 替换文字
function reWriteCodesHookFun(codes)
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
        local subStrs = arrayWithStringAndSplit(str, " ")

        codesStr = codesStr.._qssetoSubStrs(subStrs)

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
-- "⇪ + W   Xcode toHookString"
function qsseToHookFun()
    qshs_savePasteboardFn(function(paste)
        local toHookString = ""
        -- 1. hook string calss
        local from = string.find(paste, ")")
        if not from then
            toHookString = "%hook " .. paste .. "\n\n%end"
        else
            -- 2. method string
            -- 替换
            local replaceBlock = string.gsub(paste,  "CDUnknownBlockType", "/*block*/id" )
            -- 分成数组
            local arrayRe = arrayWithStringAndSplit(replaceBlock, ";")
            toHookString = reWriteCodesHookFun(arrayRe)
            show("hook method")
        end
        return toHookString
    end)
end

-- printTab(splitMethod("- (void)addNavigationItemWithImageNames:(NSArray *)imageNames isLeft:(BOOL)isLeft target:(id)target"))
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

function _splitMethod(str)
    local text = string.gsub(str, '%(', "  ")
    text = string.gsub(text, '%)', "  ")
    text = string.gsub(text, ":", "  ")
    text = string.gsub(text, "  ", " ")
    text = string.gsub(text, " %*", "*")
    text = string.gsub(text, ";", "")
    return arrayWithStringAndSplit(text, " ")
end
-- "⇪ + W   Hook 1.tweak2.Captain."
function qsseToHCaptainFunc()
    qshs_savePasteboardFn(function(paste)
        local array = _splitMethod(paste)
        --- 1.hook函数
        -- 1.hook类
        local text = "CHDeclareClass(<#input_your_class#>);\n"

        local classMethod = array[1]
        if classMethod == "+" then
            -- 2.hook类方法
            text = text .."CHOptimizedClassMethod("
        elseif classMethod == "-"then
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

        print(text, body, "\nCHLoadLateClass(<#input_your_class#>);\n", lastHook)
        return text..body.."\nCHLoadLateClass(<#input_your_class#>);\n"..lastHook
    end)
end

function _qsse_prefix(str)
    local dic = { UITextField = "tfd",
                  UIButton    = "btn",
                  UITableView = "tableView",
                  UILabel     = "lbl",
                  UIImageView = "imgView",
                  UIView      = "view",
                  UIImage     = "img",
                }
    local preFix = dic[str]
    if preFix then return preFix end

    -- foundation or uikit 取3位
    if isPreFix(str, "NS") or isPreFix(str, "UI") then
         return string.lower(string.sub(str,3,5));
    end

    -- 取所有大写字母
    preFix = getUpChar(str) or ""
    if 2 > #preFix then preFix = str end
    return string.lower(preFix)
end
function _qsse_replace_keywords(str)
    local keys = { "float", "bool", "id", "unsigned", "int", "long", "double", "NSInteger", "CGFloat",
    "static", "self", "super", "switch", "if", "nil", "Nil", "NULL"}
    for i,v in ipairs(keys) do
        if str == v then return _..str end
    end
    return str
end
function _qsse_isClass(str)
    local nonClassDic = {
        float    = "float",
        f        = "float",
        cgfloat  = "CGFloat",
        double   = "double",
        d        = "double",
        int      = "int",
        i        = "int",
        long     = "ling",
        l        = "long",
        unsigned = "unsigned",
        u        = "unsigned",
        bool     = "BOOL",
        b        = "BOOL",
        float    = "float",
    }
    return nonClassDic[string.lower(str)]
end
function _qsse_generate_strongOrWrek(class_info)
    local key = class_info[1]
    local property
    local noClassType = _qsse_isClass(key)
    if noClassType then
        -- 取第一个str
        local aletter = string.sub(noClassType, 0, 1);
        property = "@property (nonatomic, assign) "..noClassType.." "..string.lower(aletter)
    elseif key == "NSString" then
        property = "@property (nonatomic, copy  ) NSString *str"
    else
        local strongOrWeak = "strong"
        if #class_info >=2 and class_info[2] == "w" then
            strongOrWeak = "weak  "
        end
        local perFix = _qsse_prefix(key)
        property = string.format("@property (nonatomic, %s) %s *%s", strongOrWeak, key, perFix)
    end
    return property
end
function _strWithPropertys(propertys)
    local text = ""
    for i,v in ipairs(propertys) do
        if #array[1] > 0 then
            print(v)
            local array = arrayWithStringAndSplit(string.gsub(v ,"  "," "), " ")
            local property = _qsse_generate_strongOrWrek(array)

            local times;
            for idx,var in ipairs(array) do
                times = tonumber(var);
                if times or idx > 3 then break end
            end
            if times then
                for j = 1, times do text = text..property.."_"..j..';\n\n' end
            else
                text = text..property..'_;\n\n'
            end
        end
    end
    return text
end
-- "⇪ + S   1.Set2.@property3.singleton"
-- ADhotkey w 2; NSString s 1;
function qsse_customProperty()
    -- class strong|weak times;
    -- NSString w 2;
    qshs_savePasteboardFn(function(paste)
        local propertys = arrayWithStringAndSplit(paste,"\n")
        return _strWithPropertys(propertys)
    end)
end

local qsse_makeObj_c_Model_text = ""
local qsse_makeObj_c_Model_count = 0
function _qsse_makeObj_tab(tab)
    assert( type(tab) == "table", "Error:fn _qsse_makeObj_tab(tab) tab is not table This type is ->"..type(tab) )
    qsse_makeObj_c_Model_count = qsse_makeObj_c_Model_count + 1
    local text = "////////////////// ClassModel "..qsse_makeObj_c_Model_count.."\n\n"

    local format = string.format

    for k,v in pairs(tab) do
        if type(v) == "table" then
            if #v > 0 then
                text = text..format("@property (nonatomic, strong) NSSArray *%s;\n\n", k)
            else
                _qsse_makeObj_tab(v)
                text = text..format("@property (nonatomic, strong) ClassModel%d *%s;\n\n", qsse_makeObj_c_Model_count, k)
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

-- test {"kkd":11, "joyss1":true, "kids":{"age":11, "sex":true, "kkd1":11.1, "joys":"space"}, "kkd1":11.1, "joys":"space"}
function qsse_makeObjc_Model()
    -- hs.json
    -- // * 1. 读取内存 to json
    local past = qshslReadPasteboard();

    local jsonDic = hs.json.decode(past)

    if jsonDic then
        _qsse_makeObj_tab(jsonDic)
        qslPasteWithString(qsse_makeObj_c_Model_text)
    else
        show("no json in pasteboard")
    end
    qsse_makeObj_c_Model_count = 0
    qsse_makeObj_c_Model_text  = ""
end

function _qsse_comparePrefixString(str, perFix)
    if string.sub(str,1,#preFix) == preFix then
        str = string.gsub(str, preFix, "")
    else
        str = " "
    end
    return str
end

function _qsse_changeTo(split, actions)

    local paste = hs.pasteboard.getContents() or ""

    local array
    if string.find(split, "enter") then
        print("split == 回车")
        array = arrayWithStringAndSplit(paste, "\n")
    else
        array = arrayWithStringAndSplit(paste, split)
    end

    if #array == 0 then return end
    local tempText = ""
    for i, varStr in ipairs(array) do

        for idx, v in ipairs(actions) do
            -- rep=x-b|pre=x|suf=x
            if isPreFix(v, "rep=") then    -- 替换
                local repStr = string.sub(v, #"rep=" + 1, #v)
                print("rep=" .. repStr)
                local replaceArr = arrayWithStringAndSplit(repStr, "-")
                printTab(replaceArr)
                if 2 ~= #replaceArr then
                    varStr = string.gsub(varStr, " ", "")
                else
                    print("replaceArr[1]".. replaceArr[1])
                    varStr = string.gsub(varStr, replaceArr[1], replaceArr[2])
                end

            elseif isPreFix(v, "pre=") then -- 前缀
                print("pre=1 "..v)
                local pre = string.sub(v, #"pre="+1, #v)
                print("pre=2"..pre)
                if string.find(pre, "enter") then
                    varStr = '\n'..varStr
                    print("3 pre enter")
                else
                    varStr = pre..varStr
                end

            elseif isPreFix(v, "suf=") then -- 后缀
                print("suf="..v)
                local suf = string.sub(v, #"suf="+1, #v)

                if string.find(suf, "enter") then
                    varStr = varStr..'\n'
                else
                    varStr = varStr..suf
                end
            end
        end
        tempText = tempText..varStr.." "
        -- print( "varStr =", varStr)
    end
    qslPasteWithString(tempText)
end

-- stati ? sevarStrlf ? superxsuffixx
-- arr ?§§
--  "⇪ + §    paste 1.jsonModel2.changeStr"
function qsse_changPasteboardByText()
    local path = hs.configdir.."/Text/changPasteboard.txt"
    -- read
    local repText = qsl_arrayRead(path)
    repText = repText[1]

    qsl_textPrompt("替换文字", "spl 分割\nrep替换\npre前缀\nsuf后缀\nenter回车\n spl=x|rep=x-b|pre=x|suf=x",
    repText, function(text)
        -- write
        qsl_saveOrAddWithStr(path,'w', text)

        local actions = arrayWithStringAndSplit(text, "|")
        local  splits = actions[1]

        table.remove(actions, 1)

        print("splits :"..splits)

        local split = " "
        if string.sub(splits,1,#"spl=") == "spl=" then
            split = string.gsub(splits, "spl=", "")
        end

        print("split :"..split)

        _qsse_changeTo(split, actions)
    end)
end


--
