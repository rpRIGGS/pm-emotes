local npCatalog = {}
local npFavorites = {}
local npQuick = {false, false, false, false, false, false, false, false, false, false}
local nuiReady = false
local initialDataLoaded = false
local localesLoaded = false
local pendingNuiOpen = false
local menuSession = 0
local pendingOpenToken = 0


-- The NUI logic is designed to run *on top* of the existing NativeUI logic, since that menu already does all the data handling that we need.
-- As the NativeUI menu is being built, this data will be built as well. When we send this to NUI, we will clear it from Lua to get some bytes back.
-- In my opinion, this is a better way to maintain both menu styles, as any new logic that will be added to the emotes data, will reflect in both menus. -CritteR


local dataForMenu = {
    type = "BUILD_EMOTE_MENUS",
    ["emotes"] = {},
    ["danceemotes"] = {},
    ["propemotes"] = {},
    ["sharedemotes"] = {},
    -- ["Custom Category Name"] = {} -- Automagically added by the builder.
    ["walkstyles"] = {},
    ["moods"] = {},
    ["emojis"] = {},
    ["favorites"] = {}
}

local NUIEmoteType = {
    [EmoteType.EXPRESSIONS] = "moods",
    [EmoteType.WALKS] = "walkstyles",
    [EmoteType.SHARED] = "sharedemotes",
    [EmoteType.DANCES] = "danceemotes",
    [EmoteType.ANIMAL_EMOTES] = "emotes",
    [EmoteType.EXITS] = "emotes",
    [EmoteType.EMOTES] = "emotes",
    [EmoteType.PROP_EMOTES] = "propemotes",
    [EmoteType.EMOJI] = "emojis"
}

local cursorButtonText = Config.CursorAsToggle and 'btn_cursor_toggle' or 'btn_cursor'

local keyListKeyboard = {
    { controlGroup = 2, key = 176, text = 'btn_select' },
    { controlGroup = 2, keys = {176, 209}, text = 'btn_contextmenu'},
    { controlGroup = 2, key = 177,  text = 'btn_back' },
    { controlGroup = 2, keys = {172, 173}, text = 'btn_move'},
    { controlGroup = 2, key = 209,  text = 'btn_move_faster' },
    { key = 19,  text = cursorButtonText }
}

local keyListMouse = {
    { controlGroup = 2, key = 223, text = 'btn_select' },
    { controlGroup = 2, key = 225, text = 'btn_contextmenu'},
    { key = 19,  text = cursorButtonText }
}

local function getEmojiFromCategoryName(str)
    -- Wild for-loop to find emojis in the string.
    for i, char in utf8.codes(str) do
        if (
            (char >= 0x1F600 and char <= 0x1F64F)  -- Emoticons
            or (char >= 0x1F300 and char <= 0x1F5FF)  -- Misc Symbols
            or (char >= 0x1F680 and char <= 0x1F6FF)  -- Transport/Map
            or (char >= 0x2600 and char <= 0x26FF)    -- Misc Symbols
            or (char >= 0x2700 and char <= 0x27BF)    -- Dingbats
            or (char >= 0x1F900 and char <= 0x1F9FF)  -- Supplemental
            or (char >= 0x1FA70 and char <= 0x1FAFF)  -- Extended-A
        ) then
            return utf8.char(char)
        end
    end
    -- Stable icon fallback: categories must not change identity every rebuild.
    local icons = {"🚵", "🥳", "💃", "🤸", "🤹‍♂️", "🤹‍♀️", "🤓", "🏄‍♂️", "⛹️‍♀️", "🏋️"}
    local hash = 0
    for i = 1, #str do
        hash = (hash * 31 + str:byte(i)) % 2147483647
    end
    return icons[(hash % #icons) + 1]
end

local function getHtmlClassFromCategoryName(str)
    -- CSS-safe, deterministic category IDs. Keep different punctuation/emoji
    -- categories distinct, and avoid invalid selectors in the browser.
    local normalized = str:lower():gsub("[^%w]", "")
    if normalized == "" then normalized = "category" end
    local hash = 0
    for i = 1, #str do
        hash = (hash * 31 + str:byte(i)) % 2147483647
    end
    return ("custom-%s-%x"):format(normalized, hash)
end

local NUIEmoteCategories = {
    -- ["Custom Category Name"] = {id="new-category-name", icon = "🥳"}
}

RegisterNUICallback('NUI_READY', function(data, cb)
    nuiReady = true
    DebugPrint("[ NUI READY ]")
    local configForNUI = {
        Keybinding = Config.Keybinding,
        MenuPosition = Config.MenuPosition,
        EmojiMenuEnabled = Config.EmojiMenuEnabled,
        ExpressionsEnabled = Config.ExpressionsEnabled,
        WalkingStylesEnabled = Config.WalkingStylesEnabled,
        PlacementEnabled = Config.PlacementEnabled,
        Search = Config.Search,
    }
    cb({["ok"] = true, ["config"] = configForNUI})
end)

RegisterNUICallback('INITIAL_DATA_LOADED', function(data, cb)
    initialDataLoaded = true
    DebugPrint("[ NUI CATEGORIES LOADED ]")
    cb({["ok"] = true})
end)

RegisterNUICallback('LOCALES_LOADED', function(data, cb)
    localesLoaded = true
    DebugPrint("[ NUI LOCALES LOADED ]")
    cb({["ok"] = true})
end)

RegisterNUICallback('CLOSE_MENU', function(data, cb)
    pendingOpenToken = pendingOpenToken + 1
    pendingNuiOpen = false
    if IsNuiFocused() then ToggleNUIMenu() end
    PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    cb({["ok"] = true})
end)

RegisterNUICallback('SEARCH_BAR_FOCUS', function(data, cb)
    if not IsNuiFocused() then cb({["ok"] = true}) return end
    if type(data) == 'table' and data.isFocused then
        SetNuiFocusKeepInput(false)
    else
        SetNuiFocusKeepInput(true)
    end
    cb({["ok"] = true})
end)

RegisterNUICallback('CANCEL_EMOTE', function(data, cb)
    EmoteCancel()
    DestroyAllProps()

    cb({["ok"] = true})
end)

-- Shared validation for legacy NativeUI NUI callbacks. The compiled NoPixel
-- interface and older UI endpoints must use the same permission policy.
local function validNUIEmote(name, emoteType)
    return type(name) == 'string' and name ~= ''
        and type(emoteType) == 'string'
        and HasEmotePermission(name, emoteType)
end

RegisterNUICallback('ROUTE_EMOTE', function(data, cb)
    if type(data) ~= 'table' or type(data.type) ~= 'string' then
        cb({ok = false})
        return
    end
    if data.type == 'emote' then
        if data.emoteName == '_reset' then
            if data.emoteType == EmoteType.WALKS then
                ResetWalk()
                DeleteResourceKvp('walkstyle')
            elseif data.emoteType == EmoteType.EXPRESSIONS then
                DeleteResourceKvp(EmoteType.EXPRESSIONS)
                ClearFacialIdleAnimOverride(PlayerPedId())
            else
                cb({ok = false})
                return
            end
        elseif validNUIEmote(data.emoteName, data.emoteType) then
            RouteEmoteToFunction(data.emoteName, data.emoteType, 1)
        else
            cb({ok = false})
            return
        end
    elseif data.type == 'groupemote' then
        if type(data.emoteName) ~= 'string' or data.emoteName == '' then
            cb({ok = false})
            return
        end
        PMCloseCharacterPreview()
        if IsNuiFocused() then ToggleNUIMenu() end
        OnGroupEmoteRequest(data.emoteName)
    elseif data.type == 'placement' then
        if not Config.PlacementEnabled or type(data.emoteName) ~= 'string'
            or not HasEmotePermission(data.emoteName, EmoteType.PROP_EMOTES) then
            cb({ok = false})
            return
        end
        PMCloseCharacterPreview()
        StartNewPlacement(data.emoteName)
        if IsNuiFocused() then ToggleNUIMenu() end
    else
        cb({ok = false})
        return
    end
    cb({ok = true})
end)

RegisterNUICallback('FAVORITE_EMOTE', function(data, cb)
    if type(data) ~= 'table' or not validNUIEmote(data.emoteName, data.emoteType) then
        cb({ok = false})
        return
    end
    local id = data.emoteType .. '_' .. data.emoteName
    ToggleFavoriteEmote(id, {
        id = id, name = data.emoteName, emoteType = data.emoteType,
        label = type(data.emoteLabel) == 'string' and data.emoteLabel or data.emoteName,
        textureVariation = 1
    })
    local favorites, stored, seen = {}, GetFavoriteEmotes(), {}
    for _, emoteId in pairs(GetFavoriteEmotesMap()) do
        if not seen[emoteId] and stored[emoteId] then
            seen[emoteId] = true
            favorites[#favorites + 1] = stored[emoteId]
        end
    end
    cb({ok = true, favorites = favorites})
end)

RegisterNUICallback('KEYBIND_EMOTE', function(data, cb)
    if type(data) ~= 'table' or (data.type ~= 'set' and data.type ~= 'clear') then
        cb({ok = false})
        return
    end
    local id = tonumber(data.id)
    if not id or id % 1 ~= 0 or id < 1 or id > 10 then
        cb({ok = false})
        return
    end
    if data.type == 'set' then
        if not validNUIEmote(data.emoteName, data.emoteType) then
            cb({ok = false})
            return
        end
        EmoteBindStart({id, data.emoteName,
            type(data.emoteLabel) == 'string' and data.emoteLabel or data.emoteName,
            data.emoteType})
    else
        DeleteEmoteBind({id})
    end
    RebuildEmoteMenu()
    cb({ok = true})
end)


RegisterNUICallback('SIT_NEARBY', function(data, cb)
    -- Release the preview camera and focus before interacting with the world.
    PMCloseCharacterPreview()
    if IsNuiFocused() then ToggleNUIMenu() end
    PMToggleNearbySeat()
    cb({["ok"] = true})
end)

RegisterNUICallback('PREVIEW_EMOTE', function(data, cb)
    if type(data) ~= 'table' or (data.emoteName ~= nil and type(data.emoteName) ~= 'string') then
        cb({["ok"] = false, ["done"] = false})
        return
    end
    local success = PMPreviewCharacterEmote(data.emoteName, data.emoteType)
    cb({["ok"] = true, ["done"] = success})
end)

RegisterNUICallback('SEARCH_EMOTES', function(data, cb)
    local retval = {}
    if type(data) == 'table' and type(data.searchTerm) == 'string' then
        retval = SearchEmotes(data.searchTerm)
    end
    --
    -- Sending results data from `SearchEmotes()` without encoding causes FiveM to crash.
    -- Not sure why, but I assume it's related to JSON encoding / decoding.
    -- Doing it manually seems to work fine.
    --
    cb({["ok"] = true, ["emotes"] = json.encode(retval)})
end)


RegisterNUICallback('PLAY_SOUND_FRONTEND', function(data, cb)
    if type(data) == 'table' and type(data.soundName) == 'string' then
        PlaySoundFrontend(-1, data.soundName, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end

    cb({["ok"] = true})
end)

RegisterNUICallback('GET_LOCALES', function(data, cb)
    cb({["ok"] = true, ["data"] = Locales[Config.MenuLanguage]})
end)


AddEventHandler("rpemotes:internal:loadEmoteDataToNUI", function(EmoteData, CategoryToEmotes)
    -- Rebuild the category index from the engine on every catalog conversion.
    -- A removed/renamed category must not remain in the PowerMoves sidebar.
    NUIEmoteCategories = {}
    for name, emotes in pairs(CategoryToEmotes) do
        local htmlClass = getHtmlClassFromCategoryName(name)
        NUIEmoteCategories[name] = {id=htmlClass, icon = getEmojiFromCategoryName(name)}
        dataForMenu[htmlClass] = {}
    end

    local deadline = GetGameTimer() + 15000
    while (not nuiReady or not localesLoaded) and GetGameTimer() < deadline do Wait(50) end
    if not nuiReady or not localesLoaded then
        print('[pm-emotes] NUI catalog sync timed out waiting for browser/locales')
        return
    end
    SendNUIMessage({type = "LOAD_EMOTE_DATA", emoteData = EmoteData, categoryToEmotes = CategoryToEmotes, emoteCategories = NUIEmoteCategories, emoteTypeIcons = EmoteTypeEmoji})
end)

function ResetNUIQueue()
    npCatalog = {}
    for key, val in pairs(dataForMenu) do
        if type(val) == "table" then
            dataForMenu[key] = {}
        end
    end
end

function AddEmoteToNUIQueue(data)
    -- data = {emoteName, emoteType, label, categoryName, hasPermission, isFavorite}
    if data.isFavorite and data.hasPermission ~= false then
        table.insert(dataForMenu["favorites"], data)
        -- Favorites are also catalog entries; do not hide them from search or All.
    end
    -- Keep one canonical entry per animation. NativeUI inserts favorites again
    -- while building its Favorites tab; without deduplication the NoPixel All
    -- and Search views show duplicate tiles and quick slots can shift.
    local cat = ({[EmoteType.DANCES] = 'dances', [EmoteType.EXPRESSIONS] = 'expressions', [EmoteType.WALKS] = 'walks', [EmoteType.SHARED] = 'synced', [EmoteType.ANIMAL_EMOTES] = 'animals', [EmoteType.PROP_EMOTES] = 'placed'})[data.emoteType] or 'emotes'
    npCatalog[cat] = npCatalog[cat] or {}
    local found = false
    for _, existing in ipairs(npCatalog[cat]) do
        if existing.value == data.emoteName and existing.emoteType == data.emoteType then
            found = true
            break
        end
    end
    if not found and data.hasPermission ~= false then
        local index = #npCatalog[cat] + 1
        npCatalog[cat][index] = {
            category = cat, index = index, value = data.emoteName,
            label = data.label or data.emoteName, emoteType = data.emoteType
        }
    end
    local tbl = dataForMenu[NUIEmoteCategories[data.categoryName] and NUIEmoteCategories[data.categoryName].id] or dataForMenu[NUIEmoteType[data.emoteType]]
    if tbl ~= nil and data.hasPermission ~= false then
        table.insert(tbl, data)
    end
end

AddEventHandler("rpemotes:internal:sendMenuDataToNUI", function()
    local deadline = GetGameTimer() + 15000
    while (not nuiReady or not initialDataLoaded) and GetGameTimer() < deadline do Wait(50) end
    if not nuiReady or not initialDataLoaded then
        print('[pm-emotes] NUI menu build timed out waiting for browser')
        return
    end

    -- Multiple builds can queue sends while waiting above (e.g. InitMenu plus a
    -- RebuildEmoteMenu during startup). The first send empties the queue, so a
    -- stale send would push an all-empty payload and blank out the NUI menu.
    local total = 0
    for _, val in pairs(dataForMenu) do
        if type(val) == "table" then
            total = total + #val
        end
    end
    if total == 0 then
        DebugPrint("[ NUI EMOTES SKIPPED - EMPTY QUEUE ]")
        return
    end

    DebugPrint("[ NUI EMOTES BUILT ]")
    SendNUIMessage(dataForMenu)
    for key in pairs(dataForMenu) do
        dataForMenu[key] = {}
    end
    dataForMenu.type = "BUILD_EMOTE_MENUS"
end)

AddEventHandler("rpemotes:internal:sendKeybindsDataToNUI", function(binds)
    local deadline = GetGameTimer() + 15000
    while (not nuiReady or not initialDataLoaded) and GetGameTimer() < deadline do Wait(50) end
    if not nuiReady or not initialDataLoaded then
        print('[pm-emotes] NUI keybind sync timed out waiting for browser')
        return
    end
    DebugPrint("[ NUI KEYBINDS BUILT ]")
    SendNUIMessage({
        type = "BUILD_KEYBINDS_MENU",
        ["keybinds"] = binds
    })
end)

function ToggleNUIMenu()
    if not IsNuiFocused() then
        -- The NoPixel page initializes asynchronously. Avoid sending the first
        -- F4 open before its message listener has registered.
        if not nuiReady or not initialDataLoaded then
            -- Repeated F4 presses while the browser loads must not create
            -- multiple wait threads that reopen the menu after it closes.
            if pendingNuiOpen then return end
            pendingNuiOpen = true
            pendingOpenToken = pendingOpenToken + 1
            local token = pendingOpenToken
            CreateThread(function()
                local deadline = GetGameTimer() + 10000
                while (not nuiReady or not initialDataLoaded) and GetGameTimer() < deadline do
                    Wait(50)
                end
                if token ~= pendingOpenToken then return end
                pendingNuiOpen = false
                if nuiReady and initialDataLoaded and not IsNuiFocused() then
                    ToggleNUIMenu()
                elseif not nuiReady or not initialDataLoaded then
                    print('[pm-emotes] NUI did not become ready; F4 menu was not opened')
                end
            end)
            return
        end
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
        TriggerEvent("rpemotes:internal:handleNUIOpened")
    else
        pendingOpenToken = pendingOpenToken + 1
        pendingNuiOpen = false
        menuSession = menuSession + 1
        PMCloseCharacterPreview()
        SetNuiFocus(false, false)
        SendNUIMessage({event = "emotes:closeUI", args = {}})
    end
end

AddEventHandler("rpemotes:internal:handleNUIOpened", function()
    menuSession = menuSession + 1
    local session = menuSession
    local _showEmoji = ShouldShowEmojiMenu()
    -- Restore preview clone for emote selection; camera framing is handled in PMPreview.
    SendNUIMessage({event = "emotes:open", args = {}})
    SendNUIMessage({type = "OPEN_MENU", value = true, shouldShowEmojiMenu = _showEmoji})
    SendNUIMessage({type = "TOGGLE_CURSOR_INPUT", value = true})

    -- NoPixel is mouse-driven: retain cursor focus and prevent gameplay controls
    -- from firing behind the UI. Escape is handled by the frontend.
    while IsNuiFocused() and menuSession == session do
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)
        DisableControlAction(0, 14, true)
        DisableControlAction(0, 15, true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 37, true)
        DisableControlAction(0, 200, true)
        Wait(0)
    end
    -- An older menu thread must not close a newer F4 session.
    if menuSession ~= session then return end
    PMCloseCharacterPreview()
    SendNUIMessage({event = "emotes:closeUI", args = {}})
    SendNUIMessage({type = "OPEN_MENU", value = false, shouldShowEmojiMenu = _showEmoji})
end)
-- The quick bar is local per-player and survives resource restarts.
local quickKvp = 'pm_emotes_nopixel_quick'
local savedQuick = GetResourceKvpString(quickKvp)
if savedQuick then
    local ok, decoded = pcall(json.decode, savedQuick)
    if ok and type(decoded) == 'table' then
        -- KVP stores Lua slots 1..10; the browser protocol uses 0..9.
        -- Preserve the persisted 1-based layout instead of shifting slot 1.
        for i = 1, 10 do
            local saved = decoded[tostring(i)]
            if saved == nil then saved = decoded[i] end
            npQuick[i] = type(saved) == 'table' and saved or false
        end
    end
end

-- The compiled NoPixel frontend requests favorites and quick slots independently.
-- Neither request may invalidate saved entries while the catalog is still building.
local function waitForNPCatalog()
    if next(npCatalog) then return true end
    local deadline = GetGameTimer() + 5000
    while not next(npCatalog) and GetGameTimer() < deadline do Wait(50) end
    return next(npCatalog) ~= nil
end

local function findNPItem(name, emoteType)
    for category, items in pairs(npCatalog) do
        for _, item in ipairs(items) do
            if item.value == name and (not emoteType or item.emoteType == emoteType) then
                return item
            end
        end
    end
    return nil
end

-- Adapter for the original NoPixel 4.0 compiled UI; all animation execution stays in RPEmotes.
RegisterNUICallback('PM_NP_RPC', function(data, cb)
    -- NUI messages are external input; malformed payloads must not break the
    -- callback dispatcher or leave the browser waiting indefinitely.
    if type(data) ~= 'table' or type(data.event) ~= 'string' then
        cb(false)
        return
    end
    local event = data.event
    local args = type(data.args) == 'table' and data.args or {}
    if event == 'emotes:getEmotes' then
        -- NativeUI builds the shared catalog asynchronously on initial startup.
        waitForNPCatalog()
        cb(npCatalog)
    elseif event == 'emotes:getFavorites' then
        if not waitForNPCatalog() then cb({}) return end
        local favorites = {}
        local stored = GetFavoriteEmotes()
        local seen = {}
        for _, id in pairs(GetFavoriteEmotesMap()) do
            local fav = stored[id]
            if fav and not seen[id] then
                seen[id] = true
                local item = findNPItem(fav.name, fav.emoteType)
                if item and HasEmotePermission(item.value, item.emoteType) then
                    favorites[#favorites + 1] = {id = id, category = item.category, index = item.index, value = item.value, emoteType = item.emoteType}
                end
            end
        end
        npFavorites = favorites
        cb(favorites)
    elseif event == 'emotes:getQuickEmotes' then
        local catalogReady = waitForNPCatalog()
        -- Catalog order can change when animation packs or categories change.
        -- Resolve saved slots by animation name, not a stale array index.
        local changed = false
        for i = 1, 10 do
            local saved = npQuick[i]
            if catalogReady and type(saved) == 'table' and saved.value then
                local item = findNPItem(saved.value, saved.emoteType)
                if item and HasEmotePermission(item.value, item.emoteType) then
                    if saved.category ~= item.category or saved.index ~= item.index or saved.emoteType ~= item.emoteType then
                        npQuick[i] = {category = item.category, index = item.index, value = item.value, emoteType = item.emoteType}
                        changed = true
                    end
                else
                    npQuick[i] = false
                    changed = true
                end
            elseif catalogReady and saved ~= false then
                npQuick[i] = false
                changed = true
            end
        end
        if changed then SetResourceKvp(quickKvp, json.encode(npQuick)) end
        -- NoPixel's drag-and-drop slots are numbered 0..9. Lua arrays are
        -- 1..10, so returning npQuick directly offsets every displayed slot.
        local slots = {}
        for i = 1, 10 do
            slots[tostring(i - 1)] = npQuick[i] or false
        end
        cb(slots)
    elseif event == 'emotes:preview' then
        local requested = args[1]
        if not IsNuiFocused() or type(requested) ~= 'table'
            or type(requested.value) ~= 'string' then
            cb(false)
            return
        end
        local item = findNPItem(requested.value, requested.emoteType)
        if not item or not HasEmotePermission(item.value, item.emoteType) then
            cb(false)
            return
        end
        cb(PMPreviewCharacterEmote(item.value, item.emoteType) == true)
    elseif event == 'emotes:clearPreview' then
        PMCloseCharacterPreview()
        cb(true)
    elseif event == 'emotes:close' then
        pendingOpenToken = pendingOpenToken + 1
        pendingNuiOpen = false
        if IsNuiFocused() then ToggleNUIMenu() end
        cb(true)
    elseif event == 'emotes:play' then
        local requested = args[1] or {}
        if type(requested) ~= 'table' then cb(false) return end
        -- Never trust a browser-provided animation name/type. Resolve against the
        -- catalog built by RPEmotes and enforce the existing permission gate.
        local item
        if requested.category and requested.index and npCatalog[requested.category] then
            item = npCatalog[requested.category][tonumber(requested.index) or -1]
            if item and (requested.value ~= item.value or (requested.emoteType and requested.emoteType ~= item.emoteType)) then item = nil end
        end
        if not item and requested.value then
            item = findNPItem(requested.value, requested.emoteType)
        end
        if not item or not HasEmotePermission(item.value, item.emoteType) then
            cb(false)
            return
        end
        if item.emoteType == EmoteType.SHARED then
            if IsNuiFocused() then ToggleNUIMenu() end
            SendSharedEmoteRequest(item.value)
        else
            RouteEmoteToFunction(item.value, item.emoteType, 1)
        end
        cb(true)
    elseif event == 'emotes:setFavorite' then
        local requested = args[1] or {}
        if type(requested) ~= 'table' then cb(false) return end
        local item
        if requested.category and requested.index and npCatalog[requested.category] then
            item = npCatalog[requested.category][tonumber(requested.index) or -1]
            if item and (requested.value ~= item.value or (requested.emoteType and requested.emoteType ~= item.emoteType)) then item = nil end
        end
        if not item and requested.value then
            item = findNPItem(requested.value, requested.emoteType)
        end
        if not item or not HasEmotePermission(item.value, item.emoteType) then
            cb(false)
            return
        end

        -- Use the same ID shape as the native favorites menu so the two UIs
        -- share one persistent favorite rather than creating duplicates.
        local id = item.emoteType .. '_' .. item.value
        local favorites = GetFavoriteEmotes()
        local alreadyFavorite = favorites[id] ~= nil
        ToggleFavoriteEmote(id, {
            id = id, name = item.value, emoteType = item.emoteType,
            label = item.label or item.value, textureVariation = 1
        })
        if alreadyFavorite then
            for i = #npFavorites, 1, -1 do
                if npFavorites[i].id == id then table.remove(npFavorites, i) end
            end
        else
            npFavorites[#npFavorites + 1] = {
                id = id, category = item.category, index = item.index,
                value = item.value, emoteType = item.emoteType
            }
        end
        cb(alreadyFavorite and false or id)
    elseif event == 'emotes:setQuickEmote' then
        local slot = tonumber(args[1])
        if not slot or slot % 1 ~= 0 or slot < 0 or slot > 9 then
            cb(false)
            return
        end
        local requested = args[2]
        local stored = false
        if requested and requested ~= false then
            local item
            if type(requested) == 'table' and requested.category and requested.index
                and npCatalog[requested.category] then
                item = npCatalog[requested.category][tonumber(requested.index) or -1]
                if item and (requested.value ~= item.value or (requested.emoteType and requested.emoteType ~= item.emoteType)) then item = nil end
            end
            -- A saved favorite can be dragged after the catalog is rebuilt.
            -- Resolve its stable animation identity if its old index moved.
            if not item and type(requested) == 'table' and type(requested.value) == 'string' then
                item = findNPItem(requested.value, requested.emoteType)
            end
            if not item or not HasEmotePermission(item.value, item.emoteType) then
                cb(false)
                return
            end
            stored = {category = item.category, index = item.index, value = item.value, emoteType = item.emoteType}
        end
        npQuick[slot + 1] = stored
        SetResourceKvp(quickKvp, json.encode(npQuick))
        cb(true)
    else
        cb(false)
    end
end)


-- NoPixel quick slots are independent of RPEmotes' existing keybinds and
-- the inventory hotbar. They work even when the NUI is closed.
-- Players can assign their preferred keys in FiveM Settings > Key Bindings.
local function playNPQuickSlot(slot)
    local saved = npQuick[slot + 1]
    if type(saved) ~= 'table' or type(saved.value) ~= 'string' then return end
    local item = findNPItem(saved.value, saved.emoteType)
    if not item or not HasEmotePermission(item.value, item.emoteType) then return end

    if item.emoteType == EmoteType.SHARED then
        SendSharedEmoteRequest(item.value)
    else
        RouteEmoteToFunction(item.value, item.emoteType, 1)
    end
end

for slot = 0, 9 do
    local currentSlot = slot
    local command = ('pmemotequick%s'):format(currentSlot)
    RegisterCommand(command, function()
        playNPQuickSlot(currentSlot)
    end, false)
    -- Intentionally unbound: do not override qb-inventory's 1-0 hotbar.
    RegisterKeyMapping(command, ('PowerMoves Emotes quick slot %s'):format(currentSlot), 'keyboard', '')
end

-- Resource restarts must never strand player input in a dead browser overlay.
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    menuSession = menuSession + 1
    pendingOpenToken = pendingOpenToken + 1
    pendingNuiOpen = false
    PMCloseCharacterPreview()
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
end)
