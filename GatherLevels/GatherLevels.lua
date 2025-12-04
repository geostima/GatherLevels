MINING_NODE_LEVEL = {
    	["Copper Vein"] = 1,
    	["Tin Vein"] = 65,
    	["Incendicite"] = 65,
    	["Silver Vein"] = 75,
    	["Iron Deposit"] = 125,
    	["Indurium Deposit"] = 150,
    	["Lesser Bloodstone Deposit"] = 155,
    	["Gold Vein"] = 155,
    	["Mithril Vein"] = 175,
    	["Truesilver Vein"] = 230,
	["Truesilver Deposit"] = 230,
	["Small Thorium Vein"] = 245,
    	["Rich Thorium Vein"] = 275,
    	["Ooze Covered Rich Thorium Vein"] = 275,
    	["Hakkari Thorium Vein"] = 250,
    	["Dark Iron Deposit"] = 230,
    	["Small Obsidian Chunk"] = 305,
    	["Large Obsidian Chunk"] = 305,
	["Gemstone Deposit"] = 310
    }

HERBALISM_NODE_LEVEL = {
		["Peacebloom"] = 1,
		["Silverleaf"] = 1,
		["Earthroot"] = 15,
		["Mageroyal"] = 50,
		["Briarthorn"] = 70,
		["Stranglekelp"] = 85,
		["Bruiseweed"] = 100,
		["Wild Steelbloom"] = 115,
		["Grave Moss"] = 120,
		["Kingsblood"] = 125,
		["Liferoot"] = 150,
		["Fadeleaf"] = 160,
		["Goldthorn"] = 170,
		["Khadgar's Whisker"] = 185,
		["Wintersbite"] = 195,
		["Firebloom"] = 205,
		["Purple Lotus"] = 210,
		["Arthas' Tears"] = 220,
		["Sungrass"] = 230,
		["Blindweed"] = 235,
		["Ghost Mushroom"] = 245,
		["Gromsblood"] = 250,
		["Golden Sansam"] = 260,
		["Dreamfoil"] = 270,
		["Mountain Silversage"] = 280,
		["Plaguebloom"] = 285,
		["Icecap"] = 290,
		["Black Lotus"] = 300
	}

function GatherLevels_OnShow()
    local parentFrame = this:GetParent();
    local parentFrameName = parentFrame:GetName();
    -- Use _G[] instead of deprecated getglobal()
    local itemName = _G[parentFrameName.."TextLeft1"]:GetText(); 
    
    -- Combine all logic here to modify the text *once*
    if(MINING_NODE_LEVEL[itemName]) then
    	GatherLevels_SetMiningInfoOnLine(parentFrame, itemName);
    elseif(HERBALISM_NODE_LEVEL[itemName]) then
    	GatherLevels_SetHerbalismInfoOnLine(parentFrame, itemName);
    end
    
    -- Check remains separate as it uses AddLine below other text
    if(GatherLevels_IsSkinnable()) then
    	GatherLevels_AddSkinningInfo(parentFrame, itemName);
	end
end

function GatherLevels_GetProfessionLevel(skill)
    local numskills = GetNumSkillLines();
    for c = 1, numskills do
        local skillname, _, _, skillrank = GetSkillLineInfo(c);
        if(skillname == skill) then
            return skillrank or 0;
        end     
    end
    return 0;
end

-- Main line for Mining
function GatherLevels_SetMiningInfoOnLine(frame, itemname)
    if(MINING_NODE_LEVEL[itemname]) then
        local levelreq = MINING_NODE_LEVEL[itemname];
        local MiningLevel = GatherLevels_GetProfessionLevel("Mining");
        local r, g, b;

        if(levelreq <= MiningLevel) then r, g, b = 0, 1, 0; else r, g, b = 1, 0, 0; end
        
        -- Use SetText to combine the string and set the color for the *first line*
	local whiteMiningText = "|cFFFFFFFFMining|r";
        frame:SetText(whiteMiningText .. "\n" .. itemname .. " ("..levelreq..")", r, g, b);
        -- frame:Show() is called by frame:SetText() automatically
    end
end    

-- Main line for Herbalism
function GatherLevels_SetHerbalismInfoOnLine(frame, itemname)
    if(HERBALISM_NODE_LEVEL[itemname]) then
        local levelreq = HERBALISM_NODE_LEVEL[itemname];
        local HerbalismLevel = GatherLevels_GetProfessionLevel("Herbalism");
        local r, g, b;

        if(levelreq <= HerbalismLevel) then r, g, b = 0, 1, 0; else r, g, b = 1, 0, 0; end

        -- Use SetText to combine the string and set the color for the *first line*
	local whiteHerbalismText = "|cFFFFFFFFHerbalism|r";
        frame:SetText(whiteHerbalismText .. "\n" .. itemname .. " ("..levelreq..")", r, g, b);
    end
end

function GatherLevels_AddSkinningInfo(frame, itemname)
    local levelreq = 5 * UnitLevel("Mouseover");
    if(levelreq < 100) then levelreq = 1; end
    if(levelreq > 0) then
    	local SkinningLevel= GatherLevels_GetProfessionLevel("Skinning");
        local r, g, b;
    	if(levelreq <= SkinningLevel) then r, g, b = 0, 1, 0; else r, g, b = 1, 0, 0; end
        	
        -- This uses AddLine correctly to put info on a NEW line below existing text
    	frame:AddLine("Skinning ("..levelreq..")", r, g, b);
        -- frame:SetHeight(frame:GetHeight() + 14); -- Manual height adjustment usually not needed
    end 	
end

function GatherLevels_IsSkinnable()
    for c = 1, GameTooltip:NumLines() do
        local line = _G["GameTooltipTextLeft"..c]; -- Use _G[]
        if(line and line:GetText() == "Skinnable") then return true; end
    end
    return false;
end
