-- Initialize Config if it doesn't exist (Saved Variable)
if not GatherLevelsConfig then
    GatherLevelsConfig = { 
        showLeftText = true,
        enabled = true 
    }
end

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

LOCKBOX_LEVEL = {
    ["Ornate Bronze Lockbox"] = 1, ["Heavy Bronze Lockbox"] = 25,
    ["Iron Lockbox"] = 70, ["Strong Iron Lockbox"] = 125,
    ["Steel Lockbox"] = 175, ["Reinforced Steel Lockbox"] = 225,
    ["Mithril Lockbox"] = 225, ["Thorium Lockbox"] = 225,
    ["Battered Junkbox"] = 1, ["Worn Junkbox"] = 75,
    ["Sturdy Junkbox"] = 175, ["Heavy Junkbox"] = 250
}

function GatherLevels_GetDifficultyInfo(playerSkill, reqSkill)
    local r, g, b, status;
    local showExtra = GatherLevelsConfig.showLeftText

    local cGray   = "|cff808080Gray|r"
    local cGreen  = "|cff40bf40Green|r"
    local cYellow = "|cffffff00Yellow|r"
    local cOrange = "|cffff8040Orange|r"
    local cRed    = "|cffff2121Too Low|r"

    if playerSkill < reqSkill then
        return 1.00, 0.13, 0.13, cRed
    elseif playerSkill >= (reqSkill + 100) then
        return 0.50, 0.50, 0.50, cGray
    elseif playerSkill >= (reqSkill + 50) then
        status = showExtra and (((reqSkill + 100) - playerSkill) .. " to " .. cGray) or cGreen
        return 0.25, 0.75, 0.25, status
    elseif playerSkill >= (reqSkill + 25) then
        status = showExtra and (((reqSkill + 50) - playerSkill) .. " to " .. cGreen) or cYellow
        return 1.00, 1.00, 0.00, status
    else
        status = showExtra and (((reqSkill + 25) - playerSkill) .. " to " .. cYellow) or cOrange
        return 1.00, 0.50, 0.25, status
    end
end

SLASH_GATHERLEVELS1 = "/gl"
SlashCmdList["GATHERLEVELS"] = function(msg)
    if msg == "toggle" then
        GatherLevelsConfig.enabled = not GatherLevelsConfig.enabled
        local state = GatherLevelsConfig.enabled and "|cff00ff00ON|r" or "|cffff0000OFF|r"
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00GatherLevels:|r Addon is now " .. state)
    elseif msg == "left" then
        GatherLevelsConfig.showLeftText = not GatherLevelsConfig.showLeftText
        local state = GatherLevelsConfig.showLeftText and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00GatherLevels:|r Skill points remaining text is now " .. state .. ".")
    elseif msg == "skills" or msg == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00GatherLevels Profession Summary:|r")
        local skills = {"Mining", "Herbalism", "Skinning", "Lockpicking"}
        for _, s in pairs(skills) do
            local rank = GatherLevels_GetProfessionLevel(s)
            if rank > 0 then
                DEFAULT_CHAT_FRAME:AddMessage(" - " .. s .. ": |cff00ff00" .. rank .. "|r")
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage(" - |cFF00FF00/gl toggle|r : Turn addon tooltips ON/OFF.")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cFF00FF00/gl left|r : Toggle threshold text.")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00GatherLevels Commands:|r")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cFF00FF00/gl toggle|r : Enable/Disable addon tooltips.")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cFF00FF00/gl skills|r : Show your current gathering levels.")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cFF00FF00/gl left|r : Toggles 'points until next color' text.")
    end
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
    if not GatherLevelsConfig.enabled then return end

    local parentFrame = this:GetParent()
    local parentFrameName = parentFrame:GetName()
    local itemName = _G[parentFrameName.."TextLeft1"]:GetText()
    
    if(MINING_NODE_LEVEL[itemName]) then
        GatherLevels_SetMiningInfoOnLine(parentFrame, itemName)
    elseif(HERBALISM_NODE_LEVEL[itemName]) then
        GatherLevels_SetHerbalismInfoOnLine(parentFrame, itemName)
    elseif(LOCKBOX_LEVEL[itemName]) then
        GatherLevels_SetLockpickingInfo(parentFrame, LOCKBOX_LEVEL[itemName])
    end
    
    local isSkinnable = false
    local lockReq = nil

    for c = 1, GameTooltip:NumLines() do
        local line = _G["GameTooltipTextLeft"..c]
        if line then
            local lineText = line:GetText()
            -- Handle Skinning Redundancy
            if lineText == "Skinnable" then 
                isSkinnable = true 
                line:SetText("")
            end
            -- Handle Lockpicking Redundancy and Requirement Capture
            local _, _, level = string.find(lineText or "", "Lockpicking %((%d+)%)")
            if level then 
                lockReq = tonumber(level)
                line:SetText("") -- Hide the original requirement line
            end
            -- Optional: Hide the simple "Locked" line if you want it even cleaner
            if lineText == "Locked" then line:SetText("") end
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
    -- This adds the new line to world objects/boxes while original lines are hidden
    frame:AddLine("Lockpicking ("..levelreq..") - "..status, r, g, b)
end

function GatherLevels_AddSkinningInfo(frame)
    local levelreq = 5 * UnitLevel("Mouseover")
    if(levelreq < 100) then levelreq = 1 end
    local r, g, b, status = GatherLevels_GetDifficultyInfo(GatherLevels_GetProfessionLevel("Skinning"), levelreq)
    frame:AddLine("Skinning ("..levelreq..") - "..status, r, g, b)
end