script_name("check_access")
script_version("2.1")

-- БИБЛИОТЕКИ
require "lib.moonloader"
local imgui = require "mimgui"
local encoding = require "encoding"
encoding.default = "CP1251"
local u8 = encoding.UTF8

-- КОНСТАНТЫ
local UPDATE_JSON_URL = "https://raw.githubusercontent.com/vzharyi/ARZ-scripts/refs/heads/main/version.json"
local UPDATE_FALLBACK_URL = "https://github.com/vzharyi/ARZ-scripts"
local MENU_COMMAND = "aupdate"

-- СОСТОЯНИЕ UI
local windowState = imgui.new.bool(false)
local updateStatus = "—"

-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = UPDATE_JSON_URL .. "?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = UPDATE_FALLBACK_URL
        end
    end
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(100)
    end

    sampRegisterChatCommand(MENU_COMMAND, function()
        windowState[0] = not windowState[0]
    end)

    -- Дальше твой код
    wait(-1)
end

imgui.OnFrame(function() return windowState[0] end, function()
    imgui.SetNextWindowSize(imgui.ImVec2(420, 220), imgui.Cond.FirstUseEver)
    imgui.Begin(u8("Автообновление"), windowState)

    imgui.Text(u8("Текущая версия: ") .. tostring(thisScript().version))
    imgui.Text(u8("Автообновление: ") .. (enable_autoupdate and u8("включено") or u8("выключено")))
    if imgui.Button(u8("Проверить обновления")) then
        if autoupdate_loaded and enable_autoupdate and Update then
            updateStatus = "Проверка запущена"
            pcall(Update.check, Update.json_url, Update.prefix, Update.url)
        else
            updateStatus = "Модуль обновления не загружен"
        end
    end
    imgui.SameLine()
    imgui.Text(u8("Статус: ") .. u8(updateStatus))
    imgui.Separator()
    imgui.Text(u8("JSON: ") .. UPDATE_JSON_URL)
    imgui.Text(u8("Ссылка для проверки: ") .. UPDATE_FALLBACK_URL)
    imgui.Separator()
    imgui.Text(u8("Команда меню: /") .. MENU_COMMAND)
    imgui.End()
end)
