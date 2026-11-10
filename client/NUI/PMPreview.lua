-- PowerMoves NUI character preview. Local clone only; never teleports or animates the player.
local previewPed, previewCamera
local previewActive = false

local function clearPreview()
    if previewCamera and DoesCamExist(previewCamera) then
        RenderScriptCams(false, true, 250, true, false)
        DestroyCam(previewCamera, false)
    end
    previewCamera = nil
    if previewPed and DoesEntityExist(previewPed) then
        DeleteEntity(previewPed)
    end
    previewPed = nil
    previewActive = false
end

function PMCloseCharacterPreview()
    clearPreview()
end

function PMOpenCharacterPreview()
    if previewActive then return true end
    clearPreview()
    local player = PlayerPedId()
    if not DoesEntityExist(player) then return false end

    local origin = GetEntityCoords(player)
    local heading = GetEntityHeading(player)
    local forward = GetEntityForwardVector(player)
    local clonePos = vector3(origin.x + forward.x * 2.0, origin.y + forward.y * 2.0, origin.z)
    previewPed = ClonePed(player, heading + 180.0, false, false)
    if not previewPed or previewPed == 0 or not DoesEntityExist(previewPed) then
        previewPed = nil
        return false
    end
    SetEntityCoordsNoOffset(previewPed, clonePos.x, clonePos.y, clonePos.z, false, false, false)
    SetEntityHeading(previewPed, heading + 180.0)
    SetEntityCollision(previewPed, false, false)
    SetEntityInvincible(previewPed, true)
    FreezeEntityPosition(previewPed, true)
    SetBlockingOfNonTemporaryEvents(previewPed, true)

    local camPos = vector3(clonePos.x + forward.x * 3.0, clonePos.y + forward.y * 3.0, clonePos.z + 1.45)
    previewCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    if not previewCamera or not DoesCamExist(previewCamera) then
        clearPreview()
        return false
    end
    SetCamCoord(previewCamera, camPos.x, camPos.y, camPos.z)
    PointCamAtCoord(previewCamera, clonePos.x, clonePos.y, clonePos.z + 0.85)
    SetCamFov(previewCamera, 40.0)
    SetCamActive(previewCamera, true)
    RenderScriptCams(true, true, 250, true, false)
    previewActive = true
    return true
end

function PMPreviewCharacterEmote(emoteName, emoteType)
    if not previewActive or not previewPed or not DoesEntityExist(previewPed) then return false end
    ClearPedTasksImmediately(previewPed)
    if not emoteName or emoteName == '' then return true end
    if emoteType == 'Emojis' or emoteType == 'Walks' or emoteType == 'Expressions' then return true end
    -- Reuse upstream's non-player animation engine rather than playing on the actual player.
    EmotePlayOnNonPlayerPed(previewPed, emoteName)
    return true
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then clearPreview() end
end)
