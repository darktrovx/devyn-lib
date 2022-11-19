Lib.Natives = {}

function Lib.Natives.BlipAddForCoords(x, y, z, hash)
    if hash == nil then hash = 1664425300 end
    return Citizen.InvokeNative(0x554D9D53F696D002, hash, x, y, z)
end

function Lib.Natives.AddBlipForEntity(entity, hash)
    if hash == nil then hash = -1230993421 end
    return Citizen.InvokeNative(0x23F74C2FDA6E7C61, hash, entity)
end

function Lib.Natives.SetBlipSprite(blip, hash, p2)
    Citizen.InvokeNative(0x74F74D3207ED525C, blip, hash, p2)
end

function Lib.Natives.SetBlipScale(blip, scale)
    Citizen.InvokeNative(0xD38744167B2FA257, blip, scale)
end

function Lib.Natives.SetBlipName(blip, name)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, name)
end

function Lib.Natives.SetBlipColor(blip, color)
    Citizen.InvokeNative(0x662D364ABF16DE2F, blip, color)
end

function Lib.Natives.RemoveBlip(blip)
    Citizen.InvokeNative(0xF2C3C9DA47AAA54A, blip)
end

function Lib.Natives.SetRandomOutfitVariation(ped)
    Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
end

function Lib.Natives.EquipMetaPedOutfit(ped, hash)
    Citizen.InvokeNative(0x1902C4CFCC5BE57C, ped, hash)
end

function Lib.Natives.SetPedFaceFeature(ped, index, value)
    Citizen.InvokeNative(0x5653AB26C82938CF, ped, index, value)
    Lib.Natives.UpdatePedVariation(ped)
end

function Lib.Natives.ApplyShopItemToPed(ped, componentHash, immediately, isMp)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, immediately, isMp, true)
end

function Lib.Natives.RemoveShopItemFromPedByCategory(ped, category, number, bool)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, category, number, bool)
end

function Lib.Natives.RemoveShopItemFromPed(ped, category)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, category, 0, 0)
end

function Lib.Natives.GetShopPedComponentCategory(isFemale, componentHash)
    return Citizen.InvokeNative(0x5FF9A878C3D115B8, componentHash, isFemale, true)
end

function Lib.Natives.RemoveTagFromMetaPed(ped, hash)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped, hash, 0)
end

function Lib.Natives.IsMetapedUsingComponent(ped, hash)
    return Citizen.InvokeNative(0xFB4891BD7578CDC1, ped, hash)
end

function Lib.Natives.UpdatePedVariation(ped)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)
end

function Lib.Natives.SavePedVaration(ped)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
end

function Lib.Natives.IsPedComponentEquipped(ped, componentHash)
    return Citizen.InvokeNative(0xFB4891BD7578CDC1, ped, componentHash)
end

function Lib.Natives.GetMetapedType(ped)
    return Citizen.InvokeNative(0xEC9A1261BF0CE510, ped)
end

function Lib.Natives.HasPedComponentLoaded(ped)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
end

function Lib.Natives.ClearPedTexture(textureId)
    Citizen.InvokeNative(0xB63B9178D0F58D82,textureId) 
end

function Lib.Natives.ReleaseTexture(textureId)
    Citizen.InvokeNative(0x6BEFAA907B076859,textureId)
end

function Lib.Natives.RequestTexture(albedoHash, normalHash, materialHash)
    return Citizen.InvokeNative(0xC5E7204F322E49EB, albedoHash, normalHash, materialHash)
end

function Lib.Natives.AddTextureLayer(textureId, albedoHash, normalHash, materialHash, blendType, texAlpha, sheetGridIndex)
    return Citizen.InvokeNative(0x86BB5FF45F193A02, textureId, albedoHash, normalHash, materialHash, blendType, texAlpha, sheetGridIndex)
end

function Lib.Natives.SetTextureLayerPallete(textureId, layerId, paletteHash)
    Citizen.InvokeNative(0x1ED8588524AC9BE1, textureId, layerId, paletteHash)
end

function Lib.Natives.SetTextureLayerTint(textureId, layerId, tint0, tint1, tint2)
    Citizen.InvokeNative(0x2DF59FFE6FFD6044, textureId, layerId, tint0, tint1, tint2)
end

function Lib.Natives.SetTextureLayerSheetgridIndex(textureId, layerId, sheetGridIndex)
    Citizen.InvokeNative(0x3329AAE2882FC8E4, textureId, layerId, sheetGridIndex)
end

function Lib.Natives.SetTextureLayerAlpha(textureId, layerId, alpha)
    Citizen.InvokeNative(0x6C76BC24F8BB709A, textureId, layerId, alpha)
end

function Lib.Natives.IsTextureValid(textureId)
    return Citizen.InvokeNative(0x31DC8D3F216D8509,textureId)
end

function Lib.Natives.ApplyTextureOnPed(ped, componentHash, textureId)
    Citizen.InvokeNative(0x0B46E25761519058, ped, componentHash, textureId)
end

function Lib.Natives.UpdatePedTexture(textureId)
    Citizen.InvokeNative(0x92DAABA2C1C10B0E, textureId)
end

function Lib.Natives.GetPedDamageCleanliness(ped)
    local Qualities = {
        'poor',
        'good',
        'perfect'
    }
    local quality = Citizen.InvokeNative(0x88EFFED5FE8B0B4A, ped)
    if not quality then quality = 0 end
    return Qualities[ quality + 1 ]
end

-- INVALID: -1 LOW: 0 MEDIUM: 1 HIGH: 2 MAX: 3
function Lib.Natives.GetPedQuality(ped)
    return Citizen.InvokeNative(0x7BCC6087D130312A, ped)
end

function Lib.Natives.IsPedCarryingSomething(ped)
    return Citizen.InvokeNative(0xA911EE21EDF69DAF, ped)
end

function Lib.Natives.GetFirstEntityPedIsCarrying(ped)
    return Citizen.InvokeNative(0xD806CD2A4F2C2996, ped)
end

function Lib.Natives.GetCarriableFromEntity(entity)
    return Citizen.InvokeNative(0x31FEF6A20F00B963, entity)
end

function Lib.Natives.DeleteCarriable(entity)
    Citizen.InvokeNative(0x0D0DB2B6AF19A987, entity)
end

function Lib.Natives.DetachCarriablePed(ped)
    Citizen.InvokeNative(0x36D188AECB26094B, ped)
end

function Lib.Natives.DetachCarriableEntity(entity, p1, p2)
    if p1 == nil then p1 = false end
    if p2 == nil then p2 = false end
    Citizen.InvokeNative(0xED00D72F81CF7278, entity, p1, p2)
end

function Lib.Natives.GetLastMount(ped)
    return Citizen.InvokeNative(0x4C8B59171957BCF7, ped) 
end

function Lib.Natives.ClearPeltFromHorse(entity, peltId)
    if peltId == nil then peltId = 0 end
    Citizen.InvokeNative(0x627F7F3A0C4C51FF, entity, peltId) 
end

function Lib.Natives.GetHorsePelt(entity, index)
    return Citizen.InvokeNative(0x0CEEB6F4780B1F2F, entity, index)
end

-- Returns: AnimScene
function Lib.Natives.CreateAnimScene(animDict, flags, playerbackListName, p4, p5)
    return Citizen.InvokeNative(0x1FCA98E33C1437B3, animDict, flags, playerbackListName, p4, p5)
end

function Lib.Natives.SetAnimSceneOrigin(animScene, posX, posY, posZ, rotX, rotY, rotZ, order)
    Citizen.InvokeNative(0x020894BF17A02EF2, animScene, posX, posY, posZ, rotX, rotY, rotZ, order)
end

function Lib.Natives.SetAnimSceneEntity(animScene, entityName, entity, flags)
    Citizen.InvokeNative(0x8B720AD451CA2AB3, animScene, entityName, entity, flags)
end

function Lib.Natives.LoadAnimScene(animScene)
    Citizen.InvokeNative(0xAF068580194D9DC7, animScene)
end

function Lib.Natives.StartAnimScene(animScene)
    Citizen.InvokeNative(0xF4D94AF761768700, animScene)
end

function Lib.Natives.DeleteAnimScene(animScene)
    Citizen.InvokeNative(0x84EEDB2C6E650000, animScene)
end

function Lib.Natives.CreateObject(modelHash, x, y, z, isNetwork, bScriptHostObj, dynamic, p7, p8)
   return Citizen.InvokeNative(0x509D5878EB39E842, modelHash, x, y, z, isNetwork, bScriptHostObj, dynamic, p7, p8)
end

function Lib.Natives.SetEntityVisible(entity, toggle)
    Citizen.InvokeNative(0x1794B4FCC84D812F, entity, toggle)
end

function Lib.Natives.AttachEntityToEntity(entity, target, boneIndex, x, y, z, xRot, yRot, zRot, p9, useSoftPinning, collision, isPed, vertexIndex, fixedRot, p15, p16)
    Citizen.InvokeNative(0x6B9BBD38AB0796DF, entity, target, boneIndex, x, y, z, xRot, yRot, zRot, p9, useSoftPinning, collision, isPed, vertexIndex, fixedRot, p15, p16)
end

function Lib.Natives.GetPedBoneIndex(ped, boneId)
    return Citizen.InvokeNative(0x3F428D08BE5AAE31, ped, boneId)
end

function Lib.Natives.GetPedCurrentHeldWeapon(ped)
    return Citizen.InvokeNative(0x8425C5F057012DAB, ped)
end

function Lib.Natives.GetWaterMapZoneAtCoords(x, y, z)
    return Citizen.InvokeNative(0x5BA7A68A346A5A91, x, y, z)
end