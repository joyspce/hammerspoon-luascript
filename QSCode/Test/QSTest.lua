
----------------------------------------------------------------------

--这是转码用函数，必须要有

----------------------------------------------------------------------

function _UrlEncode(s)

s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)

return string.gsub(s, " ", "+")

end



----------------------------------------------------------------------

--这是图片转BASE64编码，必须要有

----------------------------------------------------------------------

function _ReadFileBase64(path)

f = io.open(path,"rb")

if f == null then

return null;

end

bytes = f:read("*all");

f:close();

return bytes:base64_encode();

end



----------------------------------------------------------------------

--这是根据图片识别文字主函数

----------------------------------------------------------------------

function _Img_To_Word(x1,y1,x2,y2,url)

local ts = require("ts")

local cjson = require ("cjson")



path=userPath()

TB_word={}

if url then

pic_name=url

else

snapshot("words.png", x1,y1,x2,y2)

pic_name=path.."/res/words.png"

end

picBS64=_UrlEncode(_ReadFileBase64(pic_name))



---------------------------------------------------------------------

--这里要开始接入百度大脑了，这个是参数1

---------------------------------------------------------------------

header_send = {

["Content-Type"] = "application/x-www-form-urlencoded",

}



---------------------------------------------------------------------

--参数2

---------------------------------------------------------------------

body_send = {

["image"]=picBS64,

["language_type"] = "CHN_ENG"

}



code,header_resp, body_resp =ts.httpsPost("https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic?access_token=这里是填写自己的TOKEN", header_send,body_send)



---------------------------------------------------------------------

--返回值是JSON的，LUA的CJSON可以转成TABLE

---------------------------------------------------------------------

local data = cjson.decode(body_resp)

for i=1,data["words_result_num"] do

for k, v in pairs(data["words_result"]) do

TB_word=v

end

end

return TB_word

end

---------------------------------------------------------------------

--调用识别文字的函数，传入屏幕上含有文字的范围坐标即可。

---------------------------------------------------------------------

Word_TB=_Img_To_Word(x1,y2,x2,y2)

for i=1,#Word_TB do

nLog(Word_TB)

end





-- 根据输入长和宽的尺寸裁切图片

-- 检测路径是否目录
local function is_dir(sPath)
    if type(sPath) ~= "string" then return false end

    local response = os.execute("cd " .. sPath)
    if response == 0 then
        return true
    end
    return false
end

-- 文件是否存在
function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end

-- 获取文件路径
function getFileDir(filename)
    return string.match(filename, "(.+)/[^/]*%.%w+$") --*nix system
end

-- 获取文件名
function strippath(filename)
    return string.match(filename, ".+/([^/]*%.%w+)$") -- *nix system
end

--去除扩展名
function stripextension(filename)
    local idx = filename:match(".+()%.%w+$")
    if (idx) then
        return filename:sub(1, idx - 1)
    else
        return filename
    end
end

--获取扩展名
function getExtension(filename)
    return filename:match(".+%.(%w+)$")
end

-- 开始执行
-- ngx.log(ngx.ERR, getFileDir(ngx.var.img_file));

local gm_path = 'gm'

-- check image dir
if not is_dir(getFileDir(ngx.var.img_file)) then
    os.execute("mkdir -p " .. getFileDir(ngx.var.img_file))
end

--  ngx.log(ngx.ERR,ngx.var.img_file);
--  ngx.log(ngx.ERR,ngx.var.request_filepath);

-- 裁剪后保证等比缩图 （缺点：裁剪了图片的一部分）
-- gm convert cropSize.jpg -thumbnail 300x300^ -gravity center -extent 300x300 -quality 100 +profile "*" cropSize.jpg_300x300.jpg
if (file_exists(ngx.var.request_filepath)) then
    local cmd = gm_path .. ' convert ' .. ngx.var.request_filepath
    cmd = cmd .. " -thumbnail " .. ngx.var.img_width .. "x" .. ngx.var.img_height .. "^"
    cmd = cmd .. " -gravity center -extent " .. ngx.var.img_width .. "x" .. ngx.var.img_height

    -- 由于压缩后比较模糊,默认图片质量为100,请根据自己情况修改quality
    cmd = cmd .. " -quality 100"
    cmd = cmd .. " +profile \"*\" " .. ngx.var.img_file;
--  ngx.log(ngx.ERR, cmd);
    os.execute(cmd);
    ngx.exec(ngx.var.uri);
else
    ngx.exit(ngx.HTTP_NOT_FOUND);
end


-- ["{\"key\":\"1\",\"message\":\"singleton\",\"data\":\"+ (instancetype)sharedManager;\\n+ (instancetype)sharedManager {\\n    static _replace_ *mine = nil;\\n    static dispatch_once_t onceToken;\\n    dispatch_once(&onceToken, ^{ mine = [[self alloc] init]; });\\n    return mine;\\n}\"}\n"]
-- ["{\"key\":\"2\",\"data\":\"@property (nonatomic, copy) void(^block)(NSString *value);\",\"message\":\"@property ^block\"}"]
-- ["{\"key\":\"3\",\"message\":\"@property ^btnClickedBlock\",\"data\":\"@property (nonatomic, copy) void (^btnClickedBlock)(UIButton *sender);\"}\n"]


-- {"key":"4","message":"message","data":"\/\/ typedef block\ntypedef NSString *(^MyBlock)(NSString *value);\nMyBlock block = ^ (NSString *value){       \n     return [NSString stringWithFormat:@\"%@\",value];   \n};    \nNSLog(@\"%@\", block(@\"小宇\"));"}



--
--         { key = 'InlineBlock，编译器会提示：',
--           str = [[returnType(^blockName)(parameterTypes)=^(parameters){
--     // statementes
-- };]] },
--         {
--         key ='iOS Block定义：',
--         str = [[//直接定义
-- @property (nonatomic, copy) void(^block)(NSInteger);
--
-- //方法中定义
-- - (void)block:(void(^) (NSInteger index))block;
--
-- //其他定义
-- typedef void(^Block)(NSInteger index);
-- @property (nonatomic, copy) Block block;
-- ]],
--         },
--         {
--         key ='gcd 后台执行：',
--         str = [[
-- dispatch_async(dispatch_get_global_queue(0, 0), ^{
--     // 主线程执行：
--     dispatch_async(dispatch_get_main_queue(), ^{
--         // something
--     });
-- });
-- ]],
--         },
--         {
--         key ='gcd 一次性执行：',
--         str = [[
-- static dispatch_once_t onceToken;
-- dispatch_once(&onceToken, ^{
--     // code to be executed once
-- });
-- ]],
--         },
--
--         {
--         key ='gcd 延迟2秒执行： ',
--         str = [[
-- dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
--     // code to be executed on the main queue after delay
-- });
-- ]],
--         },
--  }
--     end
--
-- end

--




hs.logger.defaultLogLevel="info"

hyper = {"cmd","alt","ctrl"}
shift_hyper = {"cmd","alt","ctrl","shift"}

col = hs.drawing.color.x11

swisscom_logo = hs.image.imageFromPath(hs.configdir .. "/files/swisscom_logo_2x.png")

hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.repos.zzspoons = {
  url = "https://github.com/zzamboni/zzSpoons",
  desc = "zzamboni's spoon repository",
}

spoon.SpoonInstall.use_syncinstall = true

Install=spoon.SpoonInstall

Install:andUse("BetterTouchTool", { loglevel = 'debug' })
BTT = spoon.BetterTouchTool

Install:andUse("URLDispatcher",
               {
                 config = {
                   url_patterns = {
                     { "https?://issue.swisscom.ch",                       "org.epichrome.app.SwisscomJira" },
                     { "https?://issue.swisscom.com",                      "org.epichrome.app.SwisscomJira" },
                     { "https?://jira.swisscom.com",                       "org.epichrome.app.SwisscomJira" },
                     { "https?://wiki.swisscom.com",                       "org.epichrome.app.SwisscomW408" },
                     { "https?://collaboration.swisscom.com",              "org.epichrome.app.SwisscomCollab" },
                     { "https?://smca.swisscom.com",                       "org.epichrome.app.SwisscomTWP" },
                     { "https?://portal.corproot.net",                     "com.apple.Safari" },
                     { "https?://app.opsgenie.com",                        "org.epichrome.app.OpsGenie" },
                     { "https?://app.eu.opsgenie.com",                     "org.epichrome.app.OpsGenie" },
                     { "https?://fiori.swisscom.com",                      "com.apple.Safari" },
                     { "https?://pmpgwd.apps.swisscom.com/fiori",  "com.apple.Safari" },
                     { "https?://.*webex.com",  "com.google.Chrome" },
                   },
                   -- default_handler = "com.google.Chrome"
                   -- default_handler = "com.electron.brave"
                   default_handler = "com.brave.Browser.dev"
                 },
                 start = true
               }
)

Install:andUse("WindowHalfsAndThirds",
               {
                 config = {
                   use_frame_correctness = true
                 },
                 hotkeys = 'default'
               }
)

Install:andUse("WindowScreenLeftAndRight",
               {
                 hotkeys = 'default'
               }
)

Install:andUse("WindowGrid",
               {
                 config = { gridGeometries = { { "6x4" } } },
                 hotkeys = {show_grid = {hyper, "g"}},
                 start = true
               }
)

Install:andUse("ToggleScreenRotation",
               {
                 hotkeys = { first = {hyper, "f15"} }
               }
)

Install:andUse("UniversalArchive",
               {
                 config = {
                   evernote_archive_notebook = ".Archive",
                   outlook_archive_folder = "Archive (diego.zamboni@swisscom.com)",
                   archive_notifications = false
                 },
                 hotkeys = { archive = { { "ctrl", "cmd" }, "a" } }
               }
)

Install:andUse("SendToOmniFocus",
               {
                 config = {
                   quickentrydialog = false,
                   notifications = false
                 },
                 hotkeys = {
                   send_to_omnifocus = { hyper, "t" }
                 },
                 fn = function(s)
                   s:registerApplication("Swisscom Collab", { apptype = "chromeapp", itemname = "tab" })
                   s:registerApplication("Swisscom Wiki", { apptype = "chromeapp", itemname = "wiki page" })
                   s:registerApplication("Swisscom Jira", { apptype = "chromeapp", itemname = "issue" })
                   s:registerApplication("Brave Browser Dev", { apptype = "chromeapp", itemname = "page" })
                 end
               }
)

Install:andUse("EvernoteOpenAndTag",
               {
                 hotkeys = {
                   open_note = { hyper, "o" },
                   ["open_and_tag-+work,+swisscom"] = { hyper, "w" },
                   ["open_and_tag-+personal"] = { hyper, "p" },
                   ["tag-@zzdone"] = { hyper, "z" }
                 }
               }
)

Install:andUse("TextClipboardHistory",
               {
                 disable = true,
                 config = {
                   show_in_menubar = false,
                 },
                 hotkeys = {
                   toggle_clipboard = { { "cmd", "shift" }, "v" } },
                 start = true,
               }
)

Install:andUse("Hammer",
               {
                 repo = 'zzspoons',
                 config = { auto_reload_config = false },
                 hotkeys = {
                   config_reload = {hyper, "r"},
                   toggle_console = {hyper, "y"}
                 },
                 fn = function(s)
                   BTT:bindSpoonActions(s,
                                        { config_reload = {
                                            kind = 'touchbarButton',
                                            uuid = "FF8DA717-737F-4C42-BF91-E8826E586FA1",
                                            name = "Restart",
                                            icon = hs.image.imageFromName(hs.image.systemImageNames.ApplicationIcon),
                                            color = hs.drawing.color.x11.orange,
                                        }
                   })
                 end,
                 start = true
               }
)

Install:andUse("Caffeine", {
                 start = true,
                 hotkeys = {
                   toggle = { hyper, "1" }
                 },
                 fn = function(s)
                   BTT:bindSpoonActions(s, {
                                          toggle = {
                                            kind = 'touchbarWidget',
                                            uuid = '72A96332-E908-4872-A6B4-8A6ED2E3586F',
                                            name = 'Caffeine',
                                            widget_code = [[
do
  title = " "
  icon = hs.image.imageFromPath(spoon.Caffeine.spoonPath.."/caffeine-off.pdf")
  if (hs.caffeinate.get('displayIdle')) then
    icon = hs.image.imageFromPath(spoon.Caffeine.spoonPath.."/caffeine-on.pdf")
  end
  print(hs.json.encode({ text = title, icon_data = BTT:hsimageToBTTIconData(icon) }))
end
  ]],
                                            code = "spoon.Caffeine.clicked()",
                                            widget_interval = 1,
                                            color = hs.drawing.color.x11.black,
                                            icon_only = true,
                                            icon_size = hs.geometry.size(15,15),
                                            BTTTriggerConfig = {
                                              BTTTouchBarFreeSpaceAfterButton = 0,
                                              BTTTouchBarItemPadding = -6,
                                            },
                                          }
                   })
                 end
})

Install:andUse("MenubarFlag",
               {
                 config = {
                   colors = {
                     ["U.S."] = { },
                     Spanish = {col.green, col.white, col.red},
                     German = {col.black, col.red, col.yellow},
                   }
                 },
                 start = true
               }
)

Install:andUse("MouseCircle",
               {
                 disable = true,
                 config = {
                   color = hs.drawing.color.x11.rebeccapurple
                 },
                 hotkeys = {
                   show = { hyper, "m" }
                 }
               }
)

Install:andUse("ColorPicker",
               {
                 disable = true,
                 hotkeys = {
                   show = { shift_hyper, "c" }
                 },
                 config = {
                   show_in_menubar = false,
                 },
                 start = true,
               }
)

Install:andUse("BrewInfo",
               {
                 config = {
                   brew_info_style = {
                     textFont = "Inconsolata",
                     textSize = 14,
                     radius = 10 }
                 },
                 hotkeys = {
                   -- brew info
                   show_brew_info = {hyper, "b"},
                   open_brew_url = {shift_hyper, "b"},
                   -- brew cask info
                   show_brew_cask_info = {hyper, "c"},
                   open_brew_cask_url = {shift_hyper, "c"},
                 }
               }
)

Install:andUse("TimeMachineProgress",
               {
                 start = true
               }
)

Install:andUse("ToggleSkypeMute",
               {
                 hotkeys = {
                   toggle_skype = { shift_hyper, "v" },
                   toggle_skype_for_business = { shift_hyper, "f" }
                 }
               }
)

Install:andUse("HeadphoneAutoPause",
               {
                 start = true
               }
)

Install:andUse("Seal",
               {
                 hotkeys = { show = { {"cmd"}, "space" } },
                 fn = function(s)
                   s:loadPlugins({"apps", "calc", "safari_bookmarks", "screencapture", "useractions"})
                   s.plugins.safari_bookmarks.always_open_with_safari = false
                   s.plugins.useractions.actions =
                     {
                         ["Hammerspoon docs webpage"] = {
                           url = "http://hammerspoon.org/docs/",
                           icon = hs.image.imageFromName(hs.image.systemImageNames.ApplicationIcon),
                         },
                         ["Leave corpnet"] = {
                           fn = function()
                             spoon.WiFiTransitions:processTransition('foo', 'corpnet01')
                           end,
                           icon = swisscom_logo,
                         },
                         ["Arrive in corpnet"] = {
                           fn = function()
                             spoon.WiFiTransitions:processTransition('corpnet01', 'foo')
                           end,
                           icon = swisscom_logo,
                         },
                         ["Translate using Leo"] = {
                           url = "http://dict.leo.org/englisch-deutsch/${query}",
                           icon = 'favicon',
                           keyword = "leo",
                         }
                     }
                   s:refreshAllCommands()
                 end,
                 start = true,
               }
)

function reconfigSpotifyProxy(proxy)
  local spotify = hs.appfinder.appFromName("Spotify")
  local lastapp = nil
  if spotify then
    lastapp = hs.application.frontmostApplication()
    spotify:kill()
    hs.timer.usleep(40000)
  end
  --   hs.notify.show(string.format("Reconfiguring %sSpotify", ((spotify~=nil) and "and restarting " or "")), string.format("Proxy %s", (proxy and "enabled" or "disabled")), "")
  -- I use CFEngine to reconfigure the Spotify preferences
  cmd = string.format("/usr/local/bin/cf-agent -K -f %s/files/spotify-proxymode.cf%s", hs.configdir, (proxy and " -DPROXY" or " -DNOPROXY"))
  output, status, t, rc = hs.execute(cmd)
  if spotify and lastapp then
    hs.timer.doAfter(3,
                     function()
                       if not hs.application.launchOrFocus("Spotify") then
                         hs.notify.show("Error launching Spotify", "", "")
                       end
                       if lastapp then
                         hs.timer.doAfter(0.5, hs.fnutils.partial(lastapp.activate, lastapp))
                       end
    end)
  end
end

function reconfigAdiumProxy(proxy)
  --   hs.notify.show("Reconfiguring Adium", string.format("Proxy %s", (proxy and "enabled" or "disabled")), "")
  local script = string.format([[
tell application "Adium"
  repeat with a in accounts
    if (enabled of a) is true then
      set proxy enabled of a to %s
    end if
  end repeat
  go offline
  go online
end tell
]], hs.inspect(proxy))
  hs.osascript.applescript(script)
end

Install:andUse("WiFiTransitions",
               {
                 config = {
                   actions = {
                     -- { -- Test action just to see the SSID transitions
                     --    fn = function(_, _, prev_ssid, new_ssid)
                     --       hs.notify.show("SSID change", string.format("From '%s' to '%s'", prev_ssid, new_ssid), "")
                     --    end
                     -- },
                     { -- Enable proxy in Spotify and Adium config when joining corp network
                       to = "corpnet01",
                       fn = {hs.fnutils.partial(reconfigSpotifyProxy, true),
                             hs.fnutils.partial(reconfigAdiumProxy, true),
                       }
                     },
                     { -- Disable proxy in Spotify and Adium config when leaving corp network
                       from = "corpnet01",
                       fn = {hs.fnutils.partial(reconfigSpotifyProxy, false),
                             hs.fnutils.partial(reconfigAdiumProxy, false),
                       }
                     },
                   }
                 },
                 start = true,
               }
)

wm=hs.webview.windowMasks
Install:andUse("PopupTranslateSelection",
               {
                 disable = true,
                 config = {
                   popup_style = wm.utility|wm.HUD|wm.titled|wm.closable|wm.resizable,
                 },
                 hotkeys = {
                   translate_to_en = { hyper, "e" },
                   translate_to_de = { hyper, "d" },
                   translate_to_es = { hyper, "s" },
                   translate_de_en = { shift_hyper, "e" },
                   translate_en_de = { shift_hyper, "d" },
                 }
               }
)

function obj:translatePopup(text, to, from)
   local query=hs.http.encodeForQuery(text)
   local url = "http://translate.google.com/translate_t?" ..
      (from and ("sl=" .. from .. "&") or "") ..
      (to and ("tl=" .. to .. "&") or "") ..
      "text=" .. query
   -- Persist the window between calls to reduce startup time on subsequent calls
   if self.webview == nil then
      local rect = hs.geometry.rect(0, 0, self.popup_size.w, self.popup_size.h)
      rect.center = hs.screen.mainScreen():frame().center
      self.webview=hs.webview.new(rect)
         :allowTextEntry(true)
         :windowStyle(self.popup_style)
         :closeOnEscape(self.popup_close_on_escape)
   end
   self.webview:url(url)
      :bringToFront()
      :show()
   self.webview:hswindow():focus()
   return self
end

popup_close_on_escape = true
popup_style = hs.webview.windowMasks.utility|hs.webview.windowMasks.HUD|hs.webview.windowMasks.titled|hs.webview.windowMasks.closable
webview=hs.webview.new(rect)
   :allowTextEntry(true)
   :windowStyle(popup_style)
   :closeOnEscape(popup_close_on_escape)

webview:hswindow():focus()


Install:andUse("DeepLTranslate",
               {
                 config = {
                   popup_style = wm.utility|wm.HUD|wm.titled|wm.closable|wm.resizable,
                 },
                 hotkeys = {
                   translate = { hyper, "e" },
                 }
               }
)

local localstuff=loadfile(hs.configdir .. "/init-local.lua")
if localstuff then
  localstuff()
end

Install:andUse("FadeLogo",
               {
                 config = {
                   default_run = 1.0,
                 },
                 start = true
               }
)

-- hs.notify.show("Welcome to Hammerspoon", "Have fun!", "")






--- === URLDispatcher ===
---
--- Route URLs to different applications with pattern matching
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/URLDispatcher.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/URLDispatcher.spoon.zip)
---
--- Sets Hammerspoon as the default browser for HTTP/HTTPS links, and
--- dispatches them to different apps according to the patterns defined
--- in the config. If no pattern matches, `default_handler` is used.

local obj={}
obj.__index = obj

-- Metadata
obj.name = "URLDispatcher"
obj.version = "0.1"
obj.author = "Diego Zamboni <diego@zzamboni.org>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- URLDispatcher.default_handler
--- Variable
--- Bundle ID for default URL handler. (Defaults to `"com.apple.Safari"`)
obj.default_handler = "com.apple.Safari"

--- URLDispatcher.decode_slack_redir_urls
--- Variable
--- If true, handle Slack-redir URLs to apply the rule on the destination URL. Defaults to `true`
obj.decode_slack_redir_urls = true

--- URLDispatcher.url_patterns
--- Variable
--- URL dispatch rules.
--- A table containing a list of dispatch rules. Each rule should be its own table in the format: `{ "url pattern", "application bundle ID", "function" }`, and they are evaluated in the order they are declared. Note that the patterns are [Lua patterns](https://www.lua.org/pil/20.2.html) and not regular expressions. Defaults to an empty table, which has the effect of having all URLs dispatched to the `default_handler`. If "application bundle ID" is specified, that application will be used to open matching URLs. If no "application bundle ID" is specified, but "function" is provided (and is a Lua function) it will be called with the URL.
obj.url_patterns = { }

--- URLDispatcher.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('URLDispatcher')

-- Local functions to decode URLs
function hex_to_char(x)
   return string.char(tonumber(x, 16))
end

function unescape(url)
   return url:gsub("%%(%x%x)", hex_to_char)
end

--- URLDispatcher:dispatchURL(scheme, host, params, fullUrl)
--- Method
--- Dispatch a URL to an application according to the defined `url_patterns`.
---
--- Parameters (according to the [httpCallback](http://www.hammerspoon.org/docs/hs.urlevent.html#httpCallback) specification):
---  * scheme - A string containing the URL scheme (i.e. "http")
---  * host - A string containing the host requested (e.g. "www.hammerspoon.org")
---  * params - A table containing the key/value pairs of all the URL parameters
---  * fullURL - A string containing the full, original URL
function obj:dispatchURL(scheme, host, params, fullUrl)
   local url = fullUrl
   self.logger.df("Dispatching URL '%s'", url)
   if self.decode_slack_redir_urls then
      local newUrl = string.match(url, 'https://slack.redir.net/.*url=(.*)')
      if newUrl then
         url = unescape(newUrl)
      end
   end
   for i,pair in ipairs(self.url_patterns) do
      local p = pair[1]
      local app = pair[2]
      local func = pair[3]
      if string.match(url, p) then
         id = app
         if id ~= nil then
            self.logger.df("Match found, opening with '%s'", id)
            hs.application.launchOrFocusByBundleID(id)
            hs.urlevent.openURLWithBundle(url, id)
            return
         end
         if func ~= nil then
            self.logger.df("Match found, calling func '%s'", func)
            func(url)
            return
         end
      end
   end
   self.logger.df("No match found, opening with default handler '%s'", self.default_handler)
   hs.application.launchOrFocusByBundleID(self.default_handler)
   hs.urlevent.openURLWithBundle(url, self.default_handler)
end

--- URLDispatcher:start()
--- Method
--- Start dispatching URLs according to the rules
function obj:start()
   if hs.urlevent.httpCallback then
      self.logger.w("An hs.urlevent.httpCallback was already set. I'm overriding it with my own but you should check if this breaks any other functionality")
   end
   hs.urlevent.httpCallback = function(...) self:dispatchURL(...) end
   hs.urlevent.setDefaultHandler('http')
   --   hs.urlevent.setRestoreHandler('http', self.default_handler)
   return self
end

return obj






hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0



-- Use the standardized config location, if present
custom_config = hs.fs.pathToAbsolute(os.getenv("HOME") .. '/.config/hammerspoon/private/config.lua')
if custom_config then
    print("Loading custom config")
    dofile( os.getenv("HOME") .. "/.config/hammerspoon/private/config.lua")
    privatepath = hs.fs.pathToAbsolute(hs.configdir .. '/private/config.lua')
    if privatepath then
        hs.alert("You have config in both .config/hammerspoon and .hammerspoon/private.\nThe .config/hammerspoon one will be used.")
    end
else
    -- otherwise fallback to 'classic' location.
    if not privatepath then
        privatepath = hs.fs.pathToAbsolute(hs.configdir .. '/private')
        -- Create `~/.hammerspoon/private` directory if not exists.
        hs.fs.mkdir(hs.configdir .. '/private')
    end
    privateconf = hs.fs.pathToAbsolute(hs.configdir .. '/private/config.lua')
    if privateconf then
        -- Load awesomeconfig file if exists
        require('private/config')
    end
end

hsreload_keys = hsreload_keys or {{"cmd", "shift", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "Reload Configuration", function() hs.reload() end)
end

-- ModalMgr Spoon must be loaded explicitly, because this repository heavily relies upon it.
hs.loadSpoon("ModalMgr")

-- Define default Spoons which will be loaded later
if not hspoon_list then
    hspoon_list = {
        "AClock",
        "BingDaily",
        "CircleClock",
        "ClipShow",
        "CountDown",
        "HCalendar",
        "HSaria2",
        "HSearch",
        "SpeedMenu",
        "WinWin",
        "FnMate",
    }
end

-- Load those Spoons
for _, v in pairs(hspoon_list) do
    hs.loadSpoon(v)
end

----------------------------------------------------------------------------------------------------
-- Then we create/register all kinds of modal keybindings environments.
----------------------------------------------------------------------------------------------------
-- Register windowHints (Register a keybinding which is NOT modal environment with modal supervisor)
hswhints_keys = hswhints_keys or {"alt", "tab"}
if string.len(hswhints_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hswhints_keys[1], hswhints_keys[2], 'Show Window Hints', function()
        spoon.ModalMgr:deactivateAll()
        hs.hints.windowHints()
    end)
end

----------------------------------------------------------------------------------------------------
-- appM modal environment
spoon.ModalMgr:new("appM")
local cmodal = spoon.ModalMgr.modal_list["appM"]
cmodal:bind('', 'escape', 'Deactivate appM', function() spoon.ModalMgr:deactivate({"appM"}) end)
cmodal:bind('', 'Q', 'Deactivate appM', function() spoon.ModalMgr:deactivate({"appM"}) end)
cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
if not hsapp_list then
    hsapp_list = {
        {key = 'f', name = 'Finder'},
        {key = 's', name = 'Safari'},
        {key = 't', name = 'Terminal'},
        {key = 'v', id = 'com.apple.ActivityMonitor'},
        {key = 'y', id = 'com.apple.systempreferences'},
    }
end
for _, v in ipairs(hsapp_list) do
    if v.id then
        local located_name = hs.application.nameForBundleID(v.id)
        if located_name then
            cmodal:bind('', v.key, located_name, function()
                hs.application.launchOrFocusByBundleID(v.id)
                spoon.ModalMgr:deactivate({"appM"})
            end)
        end
    elseif v.name then
        cmodal:bind('', v.key, v.name, function()
            hs.application.launchOrFocus(v.name)
            spoon.ModalMgr:deactivate({"appM"})
        end)
    end
end

-- Then we register some keybindings with modal supervisor
hsappM_keys = hsappM_keys or {"alt", "A"}
if string.len(hsappM_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hsappM_keys[1], hsappM_keys[2], "Enter AppM Environment", function()
        spoon.ModalMgr:deactivateAll()
        -- Show the keybindings cheatsheet once appM is activated
        spoon.ModalMgr:activate({"appM"}, "#FFBD2E", true)
    end)
end

----------------------------------------------------------------------------------------------------
-- clipshowM modal environment
if spoon.ClipShow then
    spoon.ModalMgr:new("clipshowM")
    local cmodal = spoon.ModalMgr.modal_list["clipshowM"]
    cmodal:bind('', 'escape', 'Deactivate clipshowM', function()
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'Q', 'Deactivate clipshowM', function()
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'N', 'Save this Session', function()
        spoon.ClipShow:saveToSession()
    end)
    cmodal:bind('', 'R', 'Restore last Session', function()
        spoon.ClipShow:restoreLastSession()
    end)
    cmodal:bind('', 'B', 'Open in Browser', function()
        spoon.ClipShow:openInBrowserWithRef()
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'S', 'Search with Bing', function()
        spoon.ClipShow:openInBrowserWithRef("https://www.bing.com/search?q=")
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'M', 'Open in MacVim', function()
        spoon.ClipShow:openWithCommand("/usr/local/bin/mvim")
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'F', 'Save to Desktop', function()
        spoon.ClipShow:saveToFile()
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'H', 'Search in Github', function()
        spoon.ClipShow:openInBrowserWithRef("https://github.com/search?q=")
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'G', 'Search with Google', function()
        spoon.ClipShow:openInBrowserWithRef("https://www.google.com/search?q=")
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'L', 'Open in Sublime Text', function()
        spoon.ClipShow:openWithCommand("/usr/local/bin/subl")
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)

    -- Register clipshowM with modal supervisor
    hsclipsM_keys = hsclipsM_keys or {"alt", "C"}
    if string.len(hsclipsM_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsclipsM_keys[1], hsclipsM_keys[2], "Enter clipshowM Environment", function()
            -- We need to take action upon hsclipsM_keys is pressed, since pressing another key to showing ClipShow panel is redundant.
            spoon.ClipShow:toggleShow()
            -- Need a little trick here. Since the content type of system clipboard may be "URL", in which case we don't need to activate clipshowM.
            if spoon.ClipShow.canvas:isShowing() then
                spoon.ModalMgr:deactivateAll()
                spoon.ModalMgr:activate({"clipshowM"})
            end
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register HSaria2
if spoon.HSaria2 then
    -- First we need to connect to aria2 rpc host
    hsaria2_host = hsaria2_host or "http://localhost:6800/jsonrpc"
    hsaria2_secret = hsaria2_secret or "token"
    spoon.HSaria2:connectToHost(hsaria2_host, hsaria2_secret)

    hsaria2_keys = hsaria2_keys or {"alt", "D"}
    if string.len(hsaria2_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsaria2_keys[1], hsaria2_keys[2], 'Toggle aria2 Panel', function() spoon.HSaria2:togglePanel() end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register Hammerspoon Search
if spoon.HSearch then
    hsearch_keys = hsearch_keys or {"alt", "G"}
    if string.len(hsearch_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsearch_keys[1], hsearch_keys[2], 'Launch Hammerspoon Search', function() spoon.HSearch:toggleShow() end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register Hammerspoon API manual: Open Hammerspoon manual in default browser
hsman_keys = hsman_keys or {"alt", "H"}
if string.len(hsman_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hsman_keys[1], hsman_keys[2], "Read Hammerspoon Manual", function()
        hs.doc.hsdocs.forceExternalBrowser(true)
        hs.doc.hsdocs.moduleEntitiesInSidebar(true)
        hs.doc.hsdocs.help()
    end)
end

----------------------------------------------------------------------------------------------------
-- countdownM modal environment
if spoon.CountDown then
    spoon.ModalMgr:new("countdownM")
    local cmodal = spoon.ModalMgr.modal_list["countdownM"]
    cmodal:bind('', 'escape', 'Deactivate countdownM', function() spoon.ModalMgr:deactivate({"countdownM"}) end)
    cmodal:bind('', 'Q', 'Deactivate countdownM', function() spoon.ModalMgr:deactivate({"countdownM"}) end)
    cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
    cmodal:bind('', '0', '5 Minutes Countdown', function()
        spoon.CountDown:startFor(5)
        spoon.ModalMgr:deactivate({"countdownM"})
    end)
    for i = 1, 9 do
        cmodal:bind('', tostring(i), string.format("%s Minutes Countdown", 10 * i), function()
            spoon.CountDown:startFor(10 * i)
            spoon.ModalMgr:deactivate({"countdownM"})
        end)
    end
    cmodal:bind('', 'return', '25 Minutes Countdown', function()
        spoon.CountDown:startFor(25)
        spoon.ModalMgr:deactivate({"countdownM"})
    end)
    cmodal:bind('', 'space', 'Pause/Resume CountDown', function()
        spoon.CountDown:pauseOrResume()
        spoon.ModalMgr:deactivate({"countdownM"})
    end)

    -- Register countdownM with modal supervisor
    hscountdM_keys = hscountdM_keys or {"alt", "I"}
    if string.len(hscountdM_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hscountdM_keys[1], hscountdM_keys[2], "Enter countdownM Environment", function()
            spoon.ModalMgr:deactivateAll()
            -- Show the keybindings cheatsheet once countdownM is activated
            spoon.ModalMgr:activate({"countdownM"}, "#FF6347", true)
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register lock screen
hslock_keys = hslock_keys or {"alt", "L"}
if string.len(hslock_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hslock_keys[1], hslock_keys[2], "Lock Screen", function()
        hs.caffeinate.lockScreen()
    end)
end

----------------------------------------------------------------------------------------------------
-- resizeM modal environment
if spoon.WinWin then
    spoon.ModalMgr:new("resizeM")
    local cmodal = spoon.ModalMgr.modal_list["resizeM"]
    cmodal:bind('', 'escape', 'Deactivate resizeM', function() spoon.ModalMgr:deactivate({"resizeM"}) end)
    cmodal:bind('', 'Q', 'Deactivate resizeM', function() spoon.ModalMgr:deactivate({"resizeM"}) end)
    cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
    cmodal:bind('', 'A', 'Move Leftward', function() spoon.WinWin:stepMove("left") end, nil, function() spoon.WinWin:stepMove("left") end)
    cmodal:bind('', 'D', 'Move Rightward', function() spoon.WinWin:stepMove("right") end, nil, function() spoon.WinWin:stepMove("right") end)
    cmodal:bind('', 'W', 'Move Upward', function() spoon.WinWin:stepMove("up") end, nil, function() spoon.WinWin:stepMove("up") end)
    cmodal:bind('', 'S', 'Move Downward', function() spoon.WinWin:stepMove("down") end, nil, function() spoon.WinWin:stepMove("down") end)
    cmodal:bind('', 'H', 'Lefthalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfleft") end)
    cmodal:bind('', 'L', 'Righthalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfright") end)
    cmodal:bind('', 'K', 'Uphalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfup") end)
    cmodal:bind('', 'J', 'Downhalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfdown") end)
    cmodal:bind('', 'Y', 'NorthWest Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerNW") end)
    cmodal:bind('', 'O', 'NorthEast Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerNE") end)
    cmodal:bind('', 'U', 'SouthWest Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerSW") end)
    cmodal:bind('', 'I', 'SouthEast Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerSE") end)
    cmodal:bind('', 'F', 'Fullscreen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen") end)
    cmodal:bind('', 'C', 'Center Window', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("center") end)
    cmodal:bind('', '=', 'Stretch Outward', function() spoon.WinWin:moveAndResize("expand") end, nil, function() spoon.WinWin:moveAndResize("expand") end)
    cmodal:bind('', '-', 'Shrink Inward', function() spoon.WinWin:moveAndResize("shrink") end, nil, function() spoon.WinWin:moveAndResize("shrink") end)
    cmodal:bind('shift', 'H', 'Move Leftward', function() spoon.WinWin:stepResize("left") end, nil, function() spoon.WinWin:stepResize("left") end)
    cmodal:bind('shift', 'L', 'Move Rightward', function() spoon.WinWin:stepResize("right") end, nil, function() spoon.WinWin:stepResize("right") end)
    cmodal:bind('shift', 'K', 'Move Upward', function() spoon.WinWin:stepResize("up") end, nil, function() spoon.WinWin:stepResize("up") end)
    cmodal:bind('shift', 'J', 'Move Downward', function() spoon.WinWin:stepResize("down") end, nil, function() spoon.WinWin:stepResize("down") end)
    cmodal:bind('', 'left', 'Move to Left Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("left") end)
    cmodal:bind('', 'right', 'Move to Right Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("right") end)
    cmodal:bind('', 'up', 'Move to Above Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("up") end)
    cmodal:bind('', 'down', 'Move to Below Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("down") end)
    cmodal:bind('', 'space', 'Move to Next Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("next") end)
    cmodal:bind('', '[', 'Undo Window Manipulation', function() spoon.WinWin:undo() end)
    cmodal:bind('', ']', 'Redo Window Manipulation', function() spoon.WinWin:redo() end)
    cmodal:bind('', '`', 'Center Cursor', function() spoon.WinWin:centerCursor() end)

    -- Register resizeM with modal supervisor
    hsresizeM_keys = hsresizeM_keys or {"alt", "R"}
    if string.len(hsresizeM_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsresizeM_keys[1], hsresizeM_keys[2], "Enter resizeM Environment", function()
            -- Deactivate some modal environments or not before activating a new one
            spoon.ModalMgr:deactivateAll()
            -- Show an status indicator so we know we're in some modal environment now
            spoon.ModalMgr:activate({"resizeM"}, "#B22222")
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- cheatsheetM modal environment (Because KSheet Spoon is NOT loaded, cheatsheetM will NOT be activated)
if spoon.KSheet then
    spoon.ModalMgr:new("cheatsheetM")
    local cmodal = spoon.ModalMgr.modal_list["cheatsheetM"]
    cmodal:bind('', 'escape', 'Deactivate cheatsheetM', function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)
    cmodal:bind('', 'Q', 'Deactivate cheatsheetM', function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)

    -- Register cheatsheetM with modal supervisor
    hscheats_keys = hscheats_keys or {"alt", "S"}
    if string.len(hscheats_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hscheats_keys[1], hscheats_keys[2], "Enter cheatsheetM Environment", function()
            spoon.KSheet:show()
            spoon.ModalMgr:deactivateAll()
            spoon.ModalMgr:activate({"cheatsheetM"})
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register AClock
if spoon.AClock then
    hsaclock_keys = hsaclock_keys or {"alt", "T"}
    if string.len(hsaclock_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsaclock_keys[1], hsaclock_keys[2], "Toggle Floating Clock", function() spoon.AClock:toggleShow() end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register browser tab typist: Type URL of current tab of running browser in markdown format. i.e. [title](link)
hstype_keys = hstype_keys or {"alt", "V"}
if string.len(hstype_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hstype_keys[1], hstype_keys[2], "Type Browser Link", function()
        local safari_running = hs.application.applicationsForBundleID("com.apple.Safari")
        local chrome_running = hs.application.applicationsForBundleID("com.google.Chrome")
        if #safari_running > 0 then
            local stat, data = hs.applescript('tell application "Safari" to get {URL, name} of current tab of window 1')
            if stat then hs.eventtap.keyStrokes("[" .. data[2] .. "](" .. data[1] .. ")") end
        elseif #chrome_running > 0 then
            local stat, data = hs.applescript('tell application "Google Chrome" to get {URL, title} of active tab of window 1')
            if stat then hs.eventtap.keyStrokes("[" .. data[2] .. "](" .. data[1] .. ")") end
        end
    end)
end

----------------------------------------------------------------------------------------------------
-- Register Hammerspoon console
hsconsole_keys = hsconsole_keys or {"alt", "Z"}
if string.len(hsconsole_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hsconsole_keys[1], hsconsole_keys[2], "Toggle Hammerspoon Console", function() hs.toggleConsole() end)
end

----------------------------------------------------------------------------------------------------
-- Finally we initialize ModalMgr supervisor
spoon.ModalMgr.supervisor:enter()



SEL sel　=　NSSelectorFromString(@"yourMethod:")//有参数
if([object　respondsToSelector:sel]) {
　　[object　performSelector:sel　withObject: @"test" ]; //如果有两个参数,使用两个withObject:参数;
}


--
-- function _qsse_comparePrefixString(str, perFix)
--     if string.sub(str,1,#preFix) == preFix then return string.gsub(str, preFix, "") end
--     return " "
-- end

--
-- function _qsse_stringWith(str)
--     local arg = ""
--     for i,v in ipairs({"With", "From"}) do
--         local _, to = string.find(str, v) --or string.find(str, "From")
--         if to then
--             arg = string.sub(str, to+1, #str)
--             break
--         end
--     end
--     if #arg == 0 and qsIsPreFix(str, "set") then
--         arg = string.sub(str, 4, #str)
--     end
--     if #arg > 1 then
--         arg = ":(<#type#>)"..arg
--         arg = string.lower(arg)
--     end
--     print(arg)
--     return arg
-- end
--
-- function qsse_mulitArg(array)
--     local text = ""
--     for i,v in ipairs(array) do
--         if i == 1 then
--             local arg = _qsse_stringWith(v)
--             if #arg > 1 then
--                 text = text..v..arg.." "
--             else
--                 text = text..v..":(<#type#>)"..v.." "
--             end
--         else
--             text = text..v..":(<#type#>)"..v.." "
--         end
--     end
--     return text
-- end

-- function _qsse_replace_keywords(str)
--     local keys = { "float", "bool", "id", "unsigned", "int", "long", "double", "NSInteger", "CGFloat",
--     "static", "self", "super", "switch", "if", "nil", "Nil", "NULL"}
--     for i,v in ipairs(keys) do
--         if str == v then return _..str end
--     end
--     return str
-- end
-- -- to self.xxxxs
-- function xcode_property_self()
--     hsSavePa-steboardFn(function(paste)
--         local array = qsSplit(paste, "\n")
--         local text = ""
--         for i,v in ipairs(array) do
--             if string.find(v, ";") and string.find(v, "@property")  then
--                 v = string.gsub(v, ";", "")
--                 local strs = qsSplit(v, " ")
--                 local property = strs[#strs]
--
--                 text = text.."self."..string.gsub(property, "*", "").." =\n"
--             elseif string.find(v, "///") then
--                 text = text..v.."\n"
--             end
--         end
--         return text
--     end)
-- end


--


-- %E5%BC%80%E5%8F%91%E8%BF%9B%E9%98%B6%28%E5%94%90%E5%B7%A7%29
--  scp -P 2222 root@localhost:/var/containers/Bundle/Application/402E5FEF-337C-41FA-8715-A9095AB49BFE/DiSpecialDriver.app /Volumes/WorkDisk/Temp/
-- scp -P 2222 root@localhost:/var/root/cy.sh /Volumes/WorkDisk/SyncFloder/WorkFiles/shell/cy.sh
-- local shell = [[bash -f "/var/root/cy.sh" &&scp -P 2222 root@localhost:/var/root/cy.sh /Volumes/WorkDisk/SyncFloder/WorkFiles/shell/cy.sh]]
-- os.execute(shell)

--


-- curl cht.sh/

-- ^[0-9] 匹配数字

--[[
    可以用它作为学习任何一门编程语言reminder
    curl cheat.sh/tar
    curl cht.sh/curl
    curl https://cheat.sh/rsync
    curl https://cht.sh/tr

    用法：curl+cht.sh/编程语言名称/需要查询的关键字或者问题

举个例子：

    curl cht.sh/go/Pointers     ##查询go语言中指针
    [root@79 Desktop]# curl cht.sh/go/Pointers
p := Vertex{1, 2}  // p is a Vertex
q := &p            // q is a pointer to a Vertex
r := &Vertex{1, 2} // r is also a pointer to a Vertex

// The type of a pointer to a Vertex is *Vertex
// new creates a pointer to a new struct instance

    curl cht.sh/scala/Functions    ##scala语言中函数用法
    curl cht.sh/python/lambda      ##python中lamba函数

[root@79 Desktop]# curl cht.sh/python
# Python is a high-level programming language
# and python is a Python interpreter.

#   Python language cheat sheets at /python/
#   list of pages:      /python/:list     ##python中可查询的列表
#   learn python:       /python/:learn    ##python基本语法
#   search in pages:    /python/~keyword  ##关键字

如果想要查询具体怎么操作，就需要添加问题：

Example：

    curl cht.sh/go/reverse+a+list      ##怎样反转数组
    curl cht.sh/python/random+list+elements   #怎样在列表中随机选取元素

import random
foo = ['a', 'b', 'c', 'd', 'e']
print(random.choice(foo))

    curl cht.sh/js/parse+json
    curl cht.sh/lua/merge+tables      ##在lua中合并列表
    curl cht.sh/clojure/variadic+function

如果查询内容不满意，可以看一些extended explanation.

    curl cht.sh/python/random+string
    curl cht.sh/python/random+string/1
    curl cht.sh/python/random+string/2

当然，为了更详细地解释查询内容，cheet sheets 中既有示例的代码，也有一些text comments。如果不喜欢的话，在命令后添加’?Q’就行。

    $ curl cht.sh/lua/table+keys?Q
    local keyset={}
    local n=0

    for k,v in pairs(tab) do
      n=n+1
      keyset[n]=k
    end

而且一般变量都会被高亮，’?T’可以去除高亮。
    curl cht.sh/lua/merge+tables?QT
--]]



-- list = nil
-- for i = 1, 10 do
-- 	list = { next = list ,value = i}
-- end

--
-- function List()
--     -- function listMake() return {point = nil, var = nil} end
--     local s = {}
--
--     local list = nil
--     local count = 0
--     s.last = nil
--     s.add = function(value)
--         list = {next = list, value = value}
--         if not s.last then s.last = list end
--         count = count + 1
--     end
--
--     s.count = function() return count end
--
--     s.clear = function()
--         while list do
--         	list.value = nil
--         	list = list.next
--         end
--         count = 0
--         list = nil
--     end
--
--     -- 扩展功能
--     s.contains = function(value)
--         while list do
--         	if list.value == value then return true end
--         	list = list.next
--         end
--         return false
--     end
--
--     s.find = function(predicate)
--         while list do
--             if predicate(list.value) then return list.value end
--         	list = list.next
--         end
--     end
--
--     s.forEachFn = function(fn)
--         while list do
--             fn(list.value)
--         	list = list.next
--         end
--     end
--
--     -- s.deleteFirst = function()
--     --     if #s.lists > 0 then table.remove(s.lists, 1) end
--     -- end
--     -- s.deleteLast = function()
--     --     if #s.lists > 0 then table.remove(s.lists, #s.lists) end
--     -- end
--     -- s.deleteAtIndex = function(index)
--     --     if #s.lists >= index then table.remove(s.lists, index) end
--     -- end
--     --
--     -- s.replaceAtIndex = function(index, var)
--     --     if #s.lists >= index then s.lists[index] = var end
--     -- end
--
--     s.show = function()
--         local count = 1
--         local list = s.first
--         while list do
--         	print("List "..count.. " :",tostring(list.value))
--         	list = list.next
--             count = count + 1
--         end
--     end
--     return s
-- end
--
-- list = List()
-- list.add(1)
-- list.add(2)
-- list.add(3)
-- list.add(4)
-- list.show()

-- {'i',  "⌥ + I", "1.Idaq64", 'idaq64', "2.Ida", 'ida', "3.Impactor", 'Impactor'},
-- {'h',  "⌥ + H", "Hopper Disassembler", 'Hopper Disassembler v3'},
-- {'r',  "⌥ + R", "1.Recents", 'RecentsF', "2.Reveal", 'Reveal'},
-- {'c',  "⌥ + C", "Charles", 'Charles'},
-- {'p',  "⌥ + P", "1.Pixelmator", 'Pixelmator', "2.截图", 'Jietu', "3.Enpass", 'Enpass'},
--
-- {'m',  "⌥ + M", "1.MachOView", 'MachOView', "2.IINA Movie", 'IINA'},
-- {'g',  "⌥ + G", "1.酷狗", 'KugouMusic'}
-- {'b',  "⌥ + B", "1.百度网盘", 'BaiduNetdisk_mac', "2.BT", 'Transmission'},
-- {'y',   "⌥ + Y", "1.FTP", 'Yummy FTP', "
-- 2.BetterZip", 'BetterZip'},


function pbArrayFormatString(str, split)
    local array = qsSplit(str, split)
    print("array  =", #array)
    local texts = {}

    for i,v in ipairs(array) do
        local text = ""
        v = qsOnlyOneSpace(v)
        local len = #v
        for i=1, len do
            local char = string.sub(v, i, i)
            if qsIsCharOrBlankOrChinese(char) then
                text = text .. char
            end
        end
        if #text > 1 then
            texts[#texts + 1] = qsTrim(text)
        end
    end
    return texts
end

function pbFormatString(format, split, begin, group, str)
    local array = qsSplit(str, "\n")
    local text = "\n"
    for i,v in ipairs(array) do
        local args = pbArrayFormatString(v, split)

        for j=1, begin do
            table.remove(args, 1)
        end

        for i=1, #args, group do
            local groups = {}
            for k=1, group do
                groups[#groups + 1] = args[i + k - 1]
            end
            text = text .. string.format(format, table.unpack(groups) ).."\n"
        end
    end
    print(text)
end


-- x * 5 + y *3 + z/3 = 100
-- many = 100
-- for x=1,many do
--     for y=1,many do
--         local z = many - x - y
--         -- if (z % 3 == 0) then
--             if (5 * x + 3 *y + z / 3) == 100 then
--                 print("x = ", x, "y =", y , "z = ", z)
--             end
--         -- end
--     end
-- end

-- 汉诺塔
-- hanoiCount = 0
-- function hanoi(n, a, b, c)
--     hanoiCount = hanoiCount + 1
--     if n == 1 then
--         print(hanoiCount, ":", a, "->", c)
--         return
--     end
--     hanoi(n - 1, a, c, b)
--     print("n ",  hanoiCount, ":", a, "->", c)
--     hanoi(n - 1, b, a, c)
-- end
-- hanoi(3, "a", "b", "c")

-- 复利 利滚利
-- function clFv(cash, precent, month)
--     function pow(num , time)
--         local tempPow = num
--         for i=1, time - 1 do
--             tempPow = tempPow  * num
--             -- print("tempPow :", tempPow)
--         end
--         return tempPow
--     end
--     local fv = cash * pow((1 + precent/month), month)
--     print("-----", fv)
--     return fv
-- end
-- clFv(100, 10/100, 12)

--
