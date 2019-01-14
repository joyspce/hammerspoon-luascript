-- author : joys
-- qq     : 501919181
-- Email  : joysnipple@icloud.com
-- Updata : 2018/12/03 21:34
-- Use    : OCCode

-- set
-- ctrl.add('s',  '1.Set 2.@Property', {occXcodeSet, occCustomProperty})
-- @property (nonatomic, strong) DSNewOrder    *model;
-- - (void)setModel:(DSNewOrder*)model {
--     _model = model;
-- }
local function _occXcodeSet(str)
    if string.find(str, ";") and string.find(str, "@property") then
        local array = qsSplit( string.gsub(str, ";", ""), " ")
        local property = array[#array]
        local form = string.find(str, "*")
        local star = ""
        if form then
            star = "*"
            property = string.sub(property, 2, #property)
        end
        return string.format("- (void)set%s:(%s%s)%s {\n    _%s = %s;\n}",
                    qsUpperFirstWord(property), array[#array-1], star, property, property, property)
    end
    return str
end
function occXcodeSet()
    local paste = Pasteboard()
    paste._callBackFn = function(str)
        local text = ""
        local propertys = qsSplit(str, "\n")
        for i, var in ipairs(propertys) do
            text = text .. _occXcodeSet(var) .. "\n"
        end
        return text
    end
    paste.setPasteboard()
end
-- get
-- ctrl.add('g',  '1.Get 2.OC Other',  {occXcodeGet, pboChangeOther})
-- occXcodeGet
-- - (DSNewOrder*)model {
--     if (!_model) {
--         _model = [ ];
--     }
--     return _model;
-- }
local function _occXcodeGet(str)
    if string.find(str, ";") and string.find(str, "@property") then
        local array = qsSplit( string.gsub(str, ";", ""), " ")
        local property = array[#array]
        local form = string.find(str, "*")
        local star = ""
        if form then
            star = "*"
            property = string.sub(property, 2, #property)
        end

        local ifStr = "    if (!_"..property..") {\n        _"..property.." = [ ];\n    }\n    return _"..property
        local text = string.format("- (%s%s)%s {\n%s;\n}", array[#array - 1], star,
                        property, ifStr)
        return text
    end
    return str
end
function occXcodeGet()
    local paste = Pasteboard()
    paste._callBackFn = function(str)
        local text = ""
        local propertys = qsSplit(str, "\n")
        for i, var in ipairs(propertys) do
            text = text .. _occXcodeGet(var) .. "\n"
        end
        return text
    end
    paste.setPasteboard()
end

-- ctrl.add({0xa,  "§"},  "@property", occCustomProperty)
-- ADhotkey w 2; NSString s 1;
function occCustomProperty()

    function assignVar(str)
        local dict = {
            int      = "int",
            i        = "int",
            long     = "ling",
            nsinteger = "NSInteger",
            l        = "long",
            unsigned = "unsigned",
            u        = "unsigned",

            bool     = "BOOL",
            b        = "BOOL",

            float    = "float",
            f        = "float",
            cgfloat  = "CGFloat",
            double   = "double",
            d        = "double",
        }
        return dict[string.lower(str)]
    end
    function prefix(str)
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
        if qsIsPreFix(str, "NS") or qsIsPreFix(str, "UI") then
             return string.lower(string.sub(str,3,5));
        end

        -- 取所有大写字母
        preFix = qsGetUpChar(str)
        if preFix then return string.lower(preFix) end
        return str
    end

    function generateStrongOrWrek(class_info)
        local key = class_info[1]

        if string.lower(key) == "nsstring" then return "@property (nonatomic, copy  ) NSString *str" end

        if assignVar(key) then
            -- 取第一个str
            local firstChar = string.sub(assignVar(key), 0, 1);
            return "@property (nonatomic, assign) "..assignVar(key).." "..string.lower(firstChar)
        end

        local strongOrWeak = "strong"
        if #class_info >=2 and class_info[2] == "w" then strongOrWeak = "weak  " end

        return string.format("@property (nonatomic, %s) %s *%s", strongOrWeak, key, prefix(key))
    end

    -- class strong|weak times;
    -- NSString w 2;
    local paste = Pasteboard()
    paste._callBackFn = function(paste)
        local array = qsSplit(paste,"\n")
        local text  = ""

        for i, v in ipairs(array) do
            if #array[1] > 0 then
                print(v)
                local array = qsSplit(v, " ")
                local property = generateStrongOrWrek(array)

                local times;
                for idx,var in ipairs(array) do
                    times = tonumber(var);
                    if times then break end
                end
                if times then
                    for j = 1, times do text = text..property.."_"..j..';\n' end
                else
                    text = text..property..'_;\n'
                end
            end
        end

        return text
    end
    paste.setPasteboard()
end



--
