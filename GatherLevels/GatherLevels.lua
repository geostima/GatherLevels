MINING_NODE_LEVEL = {
    ["Copper Vein"] = 1, ["Tin Vein"] = 65, ["Incendicite"] = 65,
    ["Silver Vein"] = 75, ["Iron Deposit"] = 125, ["Indurium Deposit"] = 150,
    ["Lesser Bloodstone Deposit"] = 155, ["Gold Vein"] = 155, ["Mithril Vein"] = 175,
    ["Mithril Deposit"] = 175, ["Truesilver Vein"] = 230, ["Truesilver Deposit"] = 230,
    ["Small Thorium Vein"] = 245, ["Rich Thorium Vein"] = 275, ["Ooze Covered Rich Thorium Vein"] = 275,
    ["Hakkari Thorium Vein"] = 250, ["Dark Iron Deposit"] = 230, ["Small Obsidian Chunk"] = 305,
    ["Large Obsidian Chunk"] = 305, ["Gemstone Deposit"] = 310
}

HERBALISM_NODE_LEVEL = {
    ["Peacebloom"] = 1, ["Silverleaf"] = 1, ["Earthroot"] = 15,
    ["Mageroyal"] = 50, ["Briarthorn"] = 70, ["Stranglekelp"] = 85,
    ["Bruiseweed"] = 100, ["Wild Steelbloom"] = 115, ["Grave Moss"] = 120,
    ["Kingsblood"] = 125, ["Liferoot"] = 150, ["Fadeleaf"] = 160,
    ["Goldthorn"] = 170, ["Khadgar's Whisker"] = 185, ["Wintersbite"] = 195,
    ["Firebloom"] = 205, ["Purple Lotus"] = 210, ["Arthas' Tears"] = 220,
    ["Sungrass"] = 230, ["Blindweed"] = 235, ["Ghost Mushroom"] = 245,
    ["Gromsblood"] = 250, ["Golden Sansam"] = 260, ["Dreamfoil"] = 270,
    ["Mountain Silversage"] = 280, ["Plaguebloom"] = 285, ["Icecap"] = 290,
    ["Black Lotus"] = 300
}

-- Lockboxes usually found in inventory (since they don't show skill req until clicked)
LOCKBOX_LEVEL = {
    ["Ornate Bronze Lockbox"] = 1, ["Heavy Bronze Lockbox"] = 25,
    ["Iron Lockbox"] = 70, ["Strong Iron Lockbox"] = 125,
    ["Steel Lockbox"] = 175, ["Reinforced Steel Lockbox"] = 225,
    ["Mithril Lockbox"] = 225, ["Thorium Lockbox"] = 225,
    ["Battered Junkbox"] = 1, ["Worn Junkbox"] = 75,
    ["Sturdy Junkbox"] = 175, ["Heavy Junkbox"] = 250
}

function GatherLevels_GetDifficultyInfo(playerSkill, reqSkill)
    if playerSkill < reqSkill then return 1.00, 0.13, 0.13, "Too Low" end
    if playerSkill >= (reqSkill + 100) then return 0.50, 0.50, 0.50, "Gray" end
    if playerSkill >= (reqSkill + 50) then return 0.25, 0.75, 0.25, ((reqSkill + 100) - playerSkill) .. " to Gray" end
    if playerSkill >= (reqSkill + 25) then return 1.00, 1.00, 0.00, ((reqSkill + 50) - playerSkill) .. " to Green" end
    return 1.00, 0.50, 0.25, ((reqSkill + 25) - playerSkill) .. " to Yellow"
end

function GatherLevels_GetProfessionLevel(skill)
    local numskills = GetNumSkillLines()
    for c = 1, numskills do
        local skillname, _, _, skillrank = GetSkillLineInfo(c)
        if(skillname == skill) then return skillrank or 0 end
    end
    return 0
end

function GatherLevels_OnShow()
    local parentFrame = this:GetParent()
    local parentFrameName = parentFrame:GetName()
    local itemName = _G[parentFrameName.."TextLeft1"]:GetText()
    
    -- Mining / Herbalism
    if(MINING_NODE_LEVEL[itemName]) then
        GatherLevels_SetMiningInfoOnLine(parentFrame, itemName)
    elseif(HERBALISM_NODE_LEVEL[itemName]) then
        GatherLevels_SetHerbalismInfoOnLine(parentFrame, itemName)
    -- Lockboxes in inventory
    elseif(LOCKBOX_LEVEL[itemName]) then
        GatherLevels_SetLockpickingInfo(parentFrame, LOCKBOX_LEVEL[itemName])
    end
    
    -- Dynamic Tooltip Scanning (For Skinning and World Objects like Doors/Chests)
    local isSkinnable = false
    local lockReq = nil

    for c = 1, GameTooltip:NumLines() do
        local lineText = _G["GameTooltipTextLeft"..c]:GetText()
        if lineText then
            if lineText == "Skinnable" then isSkinnable = true end
            -- Look for "Lockpicking (150)" pattern in tooltips
            local _, _, level = string.find(lineText, "Lockpicking %((%d+)%)")
            if level then lockReq = tonumber(level) end
        end
    end

    if isSkinnable then GatherLevels_AddSkinningInfo(parentFrame) end
    if lockReq then GatherLevels_SetLockpickingInfo(parentFrame, lockReq) end
end

function GatherLevels_SetMiningInfoOnLine(frame, itemname)
    local levelreq = MINING_NODE_LEVEL[itemname]
    local r, g, b, status = GatherLevels_GetDifficultyInfo(GatherLevels_GetProfessionLevel("Mining"), levelreq)
    frame:SetText("|cFFFFFFFFMining|r ("..status..")\n"..itemname.." ("..levelreq..")", r, g, b)
end

function GatherLevels_SetHerbalismInfoOnLine(frame, itemname)
    local levelreq = HERBALISM_NODE_LEVEL[itemname]
    local r, g, b, status = GatherLevels_GetDifficultyInfo(GatherLevels_GetProfessionLevel("Herbalism"), levelreq)
    frame:SetText("|cFFFFFFFFHerbalism|r ("..status..")\n"..itemname.." ("..levelreq..")", r, g, b)
end

function GatherLevels_SetLockpickingInfo(frame, levelreq)
    local r, g, b, status = GatherLevels_GetDifficultyInfo(GatherLevels_GetProfessionLevel("Lockpicking"), levelreq)
    -- If it's a world object (door/chest), we use AddLine so we don't overwrite the name
    frame:AddLine("Lockpicking ("..levelreq..") - "..status, r, g, b)
end

function GatherLevels_AddSkinningInfo(frame)
    local levelreq = 5 * UnitLevel("Mouseover")
    if(levelreq < 100) then levelreq = 1 end
    local r, g, b, status = GatherLevels_GetDifficultyInfo(GatherLevels_GetProfessionLevel("Skinning"), levelreq)
    frame:AddLine("Skinning ("..levelreq..") - "..status, r, g, b)
end

function GatherLevels_IsSkinnable()
    -- This is now handled inside the OnShow loop for better performance
    return false 
end