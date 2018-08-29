
-- author : joys
-- qq: 501919181
-- Email: joysnipple@icloud.com

function qsx_stringFn(str, fn)
    local string = string.gsub(str, "     ", " ")
    string = string.gsub(string, "   ", " ")
    string = string.gsub(string, "  ", " ")
    string = string.gsub(string, "//", "// ")
    string = string.gsub(string, " //", "//")
    string = string.gsub(string, "//  ", "// ")
    string = string.gsub(string, ":// ", "://")

    local array = arrayWithStringAndSplit(string,"\n")
    local text = ""
    for i,v in ipairs(array) do
        if isPreFix(v, "//") then
            text = text..v.."\n"
        else
            if fn then text = text..fn(v).."\n" end
        end
    end
    return text
end

-- @property (nonatomic, strong) DSNewOrder    *model;
-- {"s",  "⇪ + S",  "1.Set", qsseXcodeSet, "2.@property", qsse_customProperty, "3.Singleton", qsseSingleton},
function qsx_XcodeSet()
    qshs_savePasteboardFn(function(paste)
        return qsx_stringFn(paste, function(str)
            if string.find(str, ";") and string.find(str, "@property") then

                local array = arrayWithStringAndSplit( string.gsub(str, ";", ""), " ")
                local property = array[#array]

                local form = string.find(str, "*")
                local star = ""
                if form then
                    star = "*"
                    property = string.sub(property, 2, #property)
                end

                local text = string.format("- (void)set%s:(%s%s)%s {\n    _%s = %s;\n}",
                            upperFirstWord(property), array[#array-1], star, property, property, property)
                return text
            else
                return str
            end
        end)
    end)
end
function qsx_XcodeGet()
    qshs_savePasteboardFn(function(paste)
        return qsx_stringFn(paste, function(str)
            if string.find(str, ";") and string.find(str, "@property") then

                local array = arrayWithStringAndSplit( string.gsub(str, ";", ""), " ")
                local property = array[#array]

                local form = string.find(str, "*")
                local star = ""
                if form then
                    star = "*"
                    property = string.sub(property, 2, #property)
                end

                local ifStr = "    if (!_"..property..") {\n    _"..property.." = [ ];\n}\n     return _"..property
                local text = string.format("- (%s%s)%s {\n%s;\n}", array[#array - 1], star,
                                property, ifStr)
                return text
            else
                return str
            end
        end)
    end)
end

-- {'f',  "⇪ + F",  "Method 1.obj", qsse_strToMethodObj, "2.class", qsse_strToMethodClass},
function _qsse_stringWith(str)
    local arg = ""
    for i,v in ipairs({"With", "From"}) do
        local _, to = string.find(str, v) --or string.find(str, "From")
        if to then
            arg = string.sub(str, to+1, #str)
            break
        end
    end
    if #arg == 0 and isPreFix(str, "set") then
        arg = string.sub(str, 4, #str)
    end
    if #arg > 1 then
        arg = ":(<#type#>)"..arg
        arg = string.lower(arg)
    end
    print(arg)
    return arg
end
function qsse_mulitArg(array)
    local text = ""
    for i,v in ipairs(array) do
        if i == 1 then
            local arg = _qsse_stringWith(v)
            if #arg > 1 then
                text = text..v..arg.." "
            else
                text = text..v..":(<#type#>)"..v.." "
            end
        else
            text = text..v..":(<#type#>)"..v.." "
        end
    end
    return text
end
function qsx_Xcode_ObjMethod()
    qshs_savePasteboardFn(function(paste)
        return qsx_stringFn(paste, function(str)
            local arr = arrayWithStringAndSplit(str, "|")
            if #arr > 0 then
                local text = "- (void)"
                if #arr == 1 then
                    local methodStr = arr[1]
                    text = text..methodStr.._qsse_stringWith(methodStr)
                else
                     text = text..qsse_mulitArg(arr)
                end
                return text.." {\n  //add code here\n  //return;\n}"
            end
        end)
    end)
end
function qsx_Xcode_classMethod()
    qshs_savePasteboardFn(function(paste)
        return qsx_stringFn(paste, function(str)
            local arr = arrayWithStringAndSplit(str, "|")
            if #arr > 0 then
                local text = "+ (void)"
                if #arr == 1 then
                    local methodStr = arr[1]
                    text = text..methodStr.._qsse_stringWith(methodStr)
                else
                     text = text..qsse_mulitArg(arr)
                end
                return text.." {\n  //add code here\n  //return;\n}"
            end
        end)
    end)
end

function qsx_Singleton()
    qshs_savePasteboardFn(function(paste)
        local array = arrayWithStringAndSplit(paste,";")
        return string.gsub([[
+ (instancetype)sharedManager {
    static _class_ *mine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{mine = [[self alloc] init];});
    return mine;
}
]], '_class_', array[1])
end, "+ (instancetype)sharedManager;")
end


function _qsx_index_comparesInLower(array, aType)
    if aType == "NSInteger" then aType = "int64" end
    for i,v in ipairs(array) do
        local lowerStr = string.lower(v)
        aType = string.lower(aType)
        print("lowerStr ", lowerStr, "aType ", aType)
        if string.find(lowerStr, aType) then return array[i] end
    end
    return "encodeObjectXXX"
end

function _xcode_NSCoding_encode(property, aType)
    local str = string.gsub(property, "*", "")
    if property == str then
        local encode = _qsx_index_comparesInLower(
        {"encodeBool", "encodeInt", "encodeInt64", "encodeFloat", "encodeDouble"}, aType)
        return string.format('[coder %s:_%s forKey:@"%s"];', encode, str, str)
    else -- obj
        return string.format('[coder encodeObject:_%s forKey:@"%s"];', str, str)
    end
end
function _xcode_NSCoding_decode(property, aType)
    local str = string.gsub(property, "*", "")
    if property == str then
        local decode = _qsx_index_comparesInLower(
        {"decodeBoolForKey","decodeIntForKey", "decodeInt64ForKey", "decodeFloatForKey", "decodeDoubleForKey"}, aType)
        return string.format('_%s = [coder %s:@"%s"];', str, decode, str)
    else -- obj
        return string.format('_%s = [coder decodeObjectForKey:@"%s"];', str, str)
    end
end

function xcode_NSCoding()
    qshs_savePasteboardFn(function(paste)
        local array = arrayWithStringAndSplit(paste, "\n")
        local text1, text2 = "", ""
        for i,v in ipairs(array) do
            if string.find(v, ";") and string.find(v, "@property")  then
                v = string.gsub(v, ";", "")
                local strs = arrayWithStringAndSplit(v, " ")
                local property = strs[#strs]
                print(property)
                text1 = text1.._xcode_NSCoding_encode(property, strs[#strs-1]).."\n"
                text2 = text2.._xcode_NSCoding_decode(property, strs[#strs-1]).."\n"
            elseif string.find(v, "///") then
                text1 = text1..v.."\n"
                text2 = text2..v.."\n"
            end
        end
        local fix = [[
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
]]
    return string.format([[
// 1、将数据以键值对的形式存储在 NSCoder中
- (void)encodeWithCoder:(NSCoder *)coder {
    //[super encodeWithCoder:coder];
    %s}
// 2、存储在NSCoder中的数据 通过键值对方式取出
- (instancetype)initWithCoder:(NSCoder *)coder {
    //self = [super initWithCoder:coder];
    if (self) {
        %s}
    return self;
}

%s
    ]], text1, text2, fix)
    end)
end
-- to self.xxxxs
function xcode_property_self()
    qshs_savePasteboardFn(function(paste)
        local array = arrayWithStringAndSplit(paste, "\n")
        local text = ""
        for i,v in ipairs(array) do
            if string.find(v, ";") and string.find(v, "@property")  then
                v = string.gsub(v, ";", "")
                local strs = arrayWithStringAndSplit(v, " ")
                local property = strs[#strs]

                text = text.."self."..string.gsub(property, "*", "").." =\n"
            elseif string.find(v, "///") then
                text = text..v.."\n"
            end
        end
        return text
    end)
end



--
