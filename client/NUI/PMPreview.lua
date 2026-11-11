-- PM Emotes: local, non-networked character preview.
-- Preview entities and cameras are always private to this client.
local previewPed, previewCamera
local previewActive = false
local previewGeneration = 0
local previewName, previewType

local function clearPreview()
    previewGeneration = previewGeneration + 1
    previewActive = false
    previewName, previewType = nil, nil
    PMInvalidatePreviewProps()
    if previewCamera and DoesCamExist(previewCamera) then
        RenderScriptCams(false, false, 0, true, false)
        SetCamActive(previewCamera, false)
        DestroyCam(previewCamera, false)
    end
    previewCamera = nil
    if previewPed and DoesEntityExist(previewPed) then
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
    if not DoesEntityExist(player) or IsEntityDead(player) then return false end

    local origin = GetEntityCoords(player)
    local heading = GetEntityHeading(player)
    local forward = GetEntityForwardVector(player)
    local right = vector3(-forward.y, forward.x, 0.0)
    -- Stage the clone away from the player and aim a private camera at it.
    -- The actual player is never moved or animated.
    local stage = vector3(origin.x + forward.x * 3.0, origin.y + forward.y * 3.0, origin.z)
    local clone = ClonePed(player, heading, false, false)
    if not clone or clone == 0 or not DoesEntityExist(clone) then return false end
    previewPed = clone
    SetEntityAsMissionEntity(clone, true, true)
    SetEntityCoordsNoOffset(clone, stage.x, stage.y, stage.z, false, false, false)
    SetEntityHeading(clone, heading)
    SetEntityCollision(clone, false, false)
    SetEntityVisible(clone, true, false)
    SetEntityAlpha(clone, 255, false)
    SetEntityInvincible(clone, true)
    SetEntityHasGravity(clone, false)
    FreezeEntityPosition(clone, true)
    SetPedCanRagdoll(clone, false)
    SetBlockingOfNonTemporaryEvents(clone, true)

    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    if not cam or not DoesCamExist(cam) then
        clearPreview()
        return false
    end
    previewCamera = cam
    -- Keep the clone facing the player's heading and put the camera ahead
    -- of it. This avoids filming its back or positioning the camera through
    -- the actual player, who is three meters behind the clone.
    local cameraPosition = vector3(stage.x + forward.x * 3.5 - right.x * 0.7,
        stage.y + forward.y * 3.5 - right.y * 0.7, stage.z + 1.3)
    SetCamCoord(cam, cameraPosition.x, cameraPosition.y, cameraPosition.z)
    PointCamAtCoord(cam, stage.x - right.x * 0.7, stage.y - right.y * 0.7, stage.z + 0.9)
    SetCamFov(cam, 45.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    previewActive = true
    return true
end

function PMPreviewCharacterEmote(emoteName, emoteType)
    if type(emoteName) ~= 'string' or emoteName == '' then return false end
    if previewActive and previewName == emoteName and previewType == emoteType
        and previewPed and DoesEntityExist(previewPed) then
        return true
    end
    if not PMOpenCharacterPreview() then return false end
    previewGeneration = previewGeneration + 1
    local generation = previewGeneration
    local ped = previewPed
    ClearPedTasksImmediately(ped)
    PMInvalidatePreviewProps()
    ClearFacialIdleAnimOverride(ped)

    local success = false
    if emoteType == 'Expressions' then
        local expression = ExpressionData and ExpressionData[emoteName]
        if expression then
            SetFacialIdleAnimOverride(ped, expression.anim, 0)
            success = true
        end
    elseif emoteType == 'Walks' or emoteType == 'Emojis' then
        -- Walk styles and emoji states do not have a standalone preview clip.
        success = true
    else
        local emote = (EmoteData and EmoteData[emoteName]) or (SharedEmoteData and SharedEmoteData[emoteName])
        if emote then success = EmotePlayOnNonPlayerPed(ped, emoteName) ~= false end
    end
    if generation ~= previewGeneration or ped ~= previewPed or not DoesEntityExist(ped) then
        return false
    end
    if success then
        previewName, previewType = emoteName, emoteType
    else
        -- A failed clip must not leave a clone/camera (or its props) active
        -- while the player browses the rest of the catalog.
        clearPreview()
    end
    return success
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then clearPreview() end
end)
