-- PM Emotes: local, non-networked preview. Never move or animate the player.
local previewPed, previewCamera
local previewActive = false
local previewGeneration = 0

local function clearPreview()
    previewGeneration = previewGeneration + 1
    previewActive = false
    if previewCamera and DoesCamExist(previewCamera) then
        RenderScriptCams(false, false, 0, true, false)
        SetCamActive(previewCamera, false)
        DestroyCam(previewCamera, false)
    end
    previewCamera = nil
    if previewPed and DoesEntityExist(previewPed) then
        DestroyAllProps(true)
        SetEntityAsMissionEntity(previewPed, true, true)
        DeleteEntity(previewPed)
    end
    previewPed = nil
end

function PMCloseCharacterPreview()
    clearPreview()
end

function PMOpenCharacterPreview()
    if previewActive and previewPed and DoesEntityExist(previewPed) then return true end
    clearPreview()
    local player = PlayerPedId()
    if not DoesEntityExist(player) then return false end

    local origin = GetEntityCoords(player)
    local heading = GetEntityHeading(player)
    local forward = GetEntityForwardVector(player)
    local clonePos = vector3(origin.x + forward.x * 2.5, origin.y + forward.y * 2.5, origin.z)
    previewPed = ClonePed(player, heading + 180.0, false, false)
    if not previewPed or previewPed == 0 or not DoesEntityExist(previewPed) then
        previewPed = nil
        return false
    end
    SetEntityAsMissionEntity(previewPed, true, true)
    SetEntityCoordsNoOffset(previewPed, clonePos.x, clonePos.y, clonePos.z, false, false, false)
    SetEntityHeading(previewPed, heading + 180.0)
    SetEntityCollision(previewPed, false, false)
    SetEntityInvincible(previewPed, true)
    FreezeEntityPosition(previewPed, true)
    SetBlockingOfNonTemporaryEvents(previewPed, true)

    -- Aim at a point left of the clone in camera space so the clone occupies the right pane.
    -- Camera is in front of the clone, facing back toward the player.
    local rightX, rightY = forward.y, -forward.x
    local camPos = vector3(clonePos.x + forward.x * 3.0, clonePos.y + forward.y * 3.0, clonePos.z + 1.45)
    previewCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    if not previewCamera or not DoesCamExist(previewCamera) then
        clearPreview()
        return false
    end
    SetCamCoord(previewCamera, camPos.x, camPos.y, camPos.z)
    -- The target is left of the clone, putting the clone right-of-center in the camera image.
    PointCamAtCoord(previewCamera, clonePos.x - rightX * 1.2, clonePos.y - rightY * 1.2, clonePos.z + 0.9)
    SetCamFov(previewCamera, 40.0)
    SetCamActive(previewCamera, true)
    RenderScriptCams(true, false, 0, true, false)
    previewActive = true
    return true
end

function PMPreviewCharacterEmote(emoteName, emoteType)
    if not previewActive or not previewPed or not DoesEntityExist(previewPed) then return false end
    previewGeneration = previewGeneration + 1
    ClearPedTasksImmediately(previewPed)
    DestroyAllProps(true)
    if not emoteName or emoteName == '' then return true end
    if emoteType == 'Emojis' or emoteType == 'Walks' then return true end
    if emoteType == 'Expressions' then
        local expression = ExpressionData and ExpressionData[emoteName]
        if expression then
            SetFacialIdleAnimOverride(previewPed, expression.anim, 0)
            return true
        end
        ClearFacialIdleAnimOverride(previewPed)
        return false
    end
    ClearFacialIdleAnimOverride(previewPed)
    local emote = EmoteData[emoteName] or SharedEmoteData[emoteName]
    if not emote then return false end
    EmotePlayOnNonPlayerPed(previewPed, emoteName)
    return true
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then clearPreview() end
end)
