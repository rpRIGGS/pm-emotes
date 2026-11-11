local npCatalog = {}
local npFavorites = {}
local npQuick = {false, false, false, false, false, false, false, false, false, false}
local nuiReady = false
local initialDataLoaded = false
local localesLoaded = false


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
    ToggleNUIMenu()
    PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    cb({["ok"] = true})
end)

RegisterNUICallback('SEARCH_BAR_FOCUS', function(data, cb)
    if data.isFocused then
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

RegisterNUICallback('ROUTE_EMOTE', function(data, cb)
    if data.type == "emote" then
        if data.emoteName == "_reset" then
            if data.emoteType == EmoteType.WALKS then
                ResetWalk()
                DeleteResourceKvp("walkstyle")
            elseif data.emoteType == EmoteType.EXPRESSIONS then
                DeleteResourceKvp(EmoteType.EXPRESSIONS)
                ClearFacialIdleAnimOverride(PlayerPedId())
            end
        else
            RouteEmoteToFunction(data.emoteName, data.emoteType, 1)
        end
    elseif data.type == "groupemote" then
        PMCloseCharacterPreview()
        ToggleNUIMenu() -- Important to close first. Group emote request blocks the thread until you actually start the request.
        OnGroupEmoteRequest(data.emoteName)
    elseif data.type == "placement" then
        if Config.PlacementEnabled then
            PMCloseCharacterPreview()
            StartNewPlacement(data.emoteName)
            ToggleNUIMenu() -- Important to close *after* the placement request. Closing it before the request will block the preview ped on the screen.
        end
    end

    cb({["ok"] = true})
end)

RegisterNUICallback("FAVORITE_EMOTE", function(data, cb)
    if data.emoteName and data.emoteType and data.emoteLabel then
        local emoteData = {
            id = data.emoteType.."_"..data.emoteName,
            name = data.emoteName,
            emoteType = data.emoteType,
            label = data.emoteLabel or data.emoteName,
            textureVariation = 1
        }
        ToggleFavoriteEmote(emoteData.id, emoteData)
        local favData = GetFavoriteEmotes()
        local favMap = GetFavoriteEmotesMap()
        local favorites = {}
        for index, emoteId in pairs(favMap) do
            favorites[index] = favData[emoteId]
        end
        cb({["favorites"] = favorites})
        return
    end
    cb({["ok"] = true})
end)

RegisterNUICallback('KEYBIND_EMOTE', function(data, cb)
    if data.type == "set" then
        if data.emoteName and data.emoteType and data.emoteLabel and data.id then
            EmoteBindStart({data.id, data.emoteName, data.emoteLabel, data.emoteType})
            RebuildEmoteMenu()
        end
    elseif data.type == "clear" then
        if data.id then
            DeleteEmoteBind({data.id})
            RebuildEmoteMenu()
        end
    end

    cb({["ok"] = true})
end)


RegisterNUICallback('SIT_NEARBY', function(data, cb)
    -- Release the preview camera and focus before interacting with the world.
    PMCloseCharacterPreview()
    ToggleNUIMenu()
    PMToggleNearbySeat()
    cb({["ok"] = true})
end)

RegisterNUICallback('PREVIEW_EMOTE', function(data, cb)
    local success = PMPreviewCharacterEmote(data.emoteName, data.emoteType)
    cb({["ok"] = true, ["done"] = success})
end)

RegisterNUICallback('SEARCH_EMOTES', function(data, cb)
    local retval = {}
    if data.searchTerm ~= nil then
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
    PlaySoundFrontend(-1, data.soundName, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

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

    while not nuiReady or not localesLoaded do Citizen.Wait(10) end
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
    if data.isFavorite then
        table.insert(dataForMenu["favorites"], data)
        return
    end
    local cat = ({[EmoteType.DANCES] = 'dances', [EmoteType.EXPRESSIONS] = 'expressions', [EmoteType.WALKS] = 'walks', [EmoteType.SHARED] = 'synced', [EmoteType.ANIMAL_EMOTES] = 'animals', [EmoteType.PROP_EMOTES] = 'placed'})[data.emoteType] or 'emotes'
    npCatalog[cat] = npCatalog[cat] or {}
    local index = #npCatalog[cat] + 1
    npCatalog[cat][index] = {category = cat, index = index, value = data.emoteName, label = data.label or data.emoteName, emoteType = data.emoteType}
    local tbl = dataForMenu[NUIEmoteCategories[data.categoryName] and NUIEmoteCategories[data.categoryName].id] or dataForMenu[NUIEmoteType[data.emoteType]]
    if tbl ~= nil then
        table.insert(tbl, data)
    end
end

AddEventHandler("rpemotes:internal:sendMenuDataToNUI", function()
    while not nuiReady or not initialDataLoaded do Citizen.Wait(10) end

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
    while not nuiReady or not initialDataLoaded do Citizen.Wait(10) end
    DebugPrint("[ NUI KEYBINDS BUILT ]")
    SendNUIMessage({
        type = "BUILD_KEYBINDS_MENU",
        ["keybinds"] = binds
    })
end)

function ToggleNUIMenu() 
    if not IsNuiFocused() then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
        TriggerEvent("rpemotes:internal:handleNUIOpened")
    else
        PMCloseCharacterPreview()
        SetNuiFocus(false, false)
    end
end

AddEventHandler("rpemotes:internal:handleNUIOpened", function()
    local _showEmoji = ShouldShowEmojiMenu()
    -- Restore preview clone for emote selection; camera framing is handled in PMPreview.
    SendNUIMessage({event = "emotes:open", args = {}})
    SendNUIMessage({type = "OPEN_MENU", value = true, shouldShowEmojiMenu = _showEmoji})
    SendNUIMessage({type = "TOGGLE_CURSOR_INPUT", value = true})

    local scaleform_instructions = SetupButtons(keyListKeyboard)
    local cursorActive = true

    local function setCursorActive(state)
        if cursorActive == state then return end
        cursorActive = state
        SetNuiFocus(true, state)
        SendNUIMessage({type = "TOGGLE_CURSOR_INPUT", value = state})
        SetScaleformMovieAsNoLongerNeeded(scaleform_instructions)
        scaleform_instructions = SetupButtons(state and keyListMouse or keyListKeyboard)
    end

    while IsNuiFocused() do
        -- The original NoPixel UI uses a mouse-first interaction model.
        DisableControlAction(0,37,true)
        DisableControlAction(0,200,true)
        if IsControlJustPressed(0,19) then
            -- As a toggle, every tap flips the cursor. Otherwise, it is only shown for as long as the key is held down.
            if Config.CursorAsToggle then
                setCursorActive(not cursorActive)
            else
                setCursorActive(true)
            end
        elseif not Config.CursorAsToggle and IsControlJustReleased(0,19) then
            setCursorActive(false)
        end
        if cursorActive then
            DisableControlAction(0,1,true)
            DisableControlAction(0,2,true)
            DisableControlAction(0,14,true)
            DisableControlAction(0,15,true)
            DisableControlAction(0,24,true)
            DisableControlAction(0,25,true)
        end
        Wait(1)
    end
    PMCloseCharacterPreview()
    SetScaleformMovieAsNoLongerNeeded(scaleform_instructions)
    SendNUIMessage({type = "OPEN_MENU", value = false, shouldShowEmojiMenu = _showEmoji})
end)
-- The quick bar is local per-player and survives resource restarts.
local quickKvp = 'pm_emotes_nopixel_quick'
local savedQuick = GetResourceKvpString(quickKvp)
if savedQuick then
    local ok, decoded = pcall(json.decode, savedQuick)
    if ok and type(decoded) == 'table' then
        for i = 1, 10 do npQuick[i] = decoded[tostring(i)] or decoded[i] or false end
    end
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
    local event = data.event
    local args = data.args or {}
    if event == 'emotes:getEmotes' then
        cb(npCatalog)
    elseif event == 'emotes:getFavorites' then
        local favorites = {}
        local stored = GetFavoriteEmotes()
        for _, id in ipairs(GetFavoriteEmotesMap()) do
            local fav = stored[id]
            if fav then
                local item = findNPItem(fav.name, fav.emoteType)
                if item then
                    favorites[#favorites + 1] = {id = id, category = item.category, index = item.index, value = item.value, emoteType = item.emoteType}
                end
            end
        end
        npFavorites = favorites
        cb(favorites)
    elseif event == 'emotes:getQuickEmotes' then
        cb(npQuick)
    elseif event == 'emotes:close' then
        ToggleNUIMenu()
        cb(true)
    elseif event == 'emotes:play' then
        local item = args[1] or {}
        if item.category and item.index and npCatalog[item.category] then
            item = npCatalog[item.category][tonumber(item.index)] or item
        end
        if item.value then
            RouteEmoteToFunction(item.value, item.emoteType or EmoteType.EMOTES, 1)
        end
        cb(true)
    elseif event == 'emotes:setFavorite' then
        local item = args[1] or {}
        if item.category and item.index and npCatalog[item.category] then
            local original = npCatalog[item.category][tonumber(item.index)]
            if original then item.emoteType = original.emoteType item.label = original.label end
        end
        if item.value then
            local id = (item.category or 'emotes') .. '_' .. item.value
            local emote = {id = id, name = item.value, emoteType = item.emoteType or EmoteType.EMOTES, label = item.label or item.value, textureVariation = 1}
            ToggleFavoriteEmote(id, emote)
            local found = false
            for i = #npFavorites, 1, -1 do
                if npFavorites[i].value == item.value then table.remove(npFavorites, i) found = true end
            end
            if not found then
                item.id = id
                npFavorites[#npFavorites + 1] = item
            end
            cb(found and false or id)
        else cb(false) end
    elseif event == 'emotes:setQuickEmote' then
        local slot = tonumber(args[1])
        if slot and slot >= 0 and slot <= 9 then
            npQuick[slot + 1] = args[2] or false
            SetResourceKvp(quickKvp, json.encode(npQuick))
        end
        cb(true)
    else
        cb(false)
    end
end)
