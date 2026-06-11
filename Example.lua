local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Unwalker1337/PlagueUI/main/source.lua", true))()

-- Customize UI text
library:ChangeWeb("plagueui.xyz")          -- changes the URL in bottom-left
library:ChangeGame("PlagueUI v2 | Beta")    -- changes the game label in bottom-right

-- Customize GUI toggle keybind (default: RightControl)
library:SetGUIToggleKey(Enum.KeyCode.RightControl)

-- Create a watermark with custom text
local watermark = library:AddWatermark("PlagueUI | User")

-- Create window tabs
local Legit = library:AddWindow('Legit')
local Rage = library:AddWindow('Rage')
local Visuals = library:AddWindow('Visuals')
local Misc = library:AddWindow('Misc')

-- Create Settings tab (includes ConfigManager)
local Settings = library:CreateSettings('Settings')

-- ============================================
-- LEGIT TAB
-- ============================================
local legitSection = Legit:AddSection('Aimbot')

legitSection:AddLabel('Main Settings')
legitSection:AddToggle('Enabled', true, Enum.KeyCode.L, function(v)
    print("Aimbot:", v)
end)
legitSection:AddToggle('Visible Check', true, nil, function(v)
    print("Visible check:", v)
end)
legitSection:AddToggle('Auto Shoot', false, nil, function(v)
    print("Auto shoot:", v)
end)
legitSection:AddSeparateBar()
legitSection:AddLabel('Accuracy')
legitSection:AddSlider('Hit Chance', 100, 0, 75, function(v)
    print("Hit chance:", v)
end)
legitSection:AddSlider('Smoothness', 100, 1, 15, function(v)
    print("Smooth:", v)
end)

local legitSection2 = Legit:AddSection('Triggerbot')
legitSection2:AddToggle('Triggerbot', false, Enum.KeyCode.T, function(v)
    print("Triggerbot:", v)
end)
legitSection2:AddSlider('Trigger Delay', 500, 0, 50, function(v)
    print("Delay:", v, "ms")
end)

-- ============================================
-- RAGE TAB
-- ============================================
local rageSection = Rage:AddSection('Ragebot')
rageSection:AddToggle('Ragebot', false, Enum.KeyCode.R, function(v)
    print("Rage:", v)
end)
rageSection:AddToggle('Automatic Penetration', true, nil, function(v)
    print("Penetration:", v)
end)
rageSection:AddSlider('Minimum Damage', 100, 0, 70, function(v)
    print("Min damage:", v)
end)
rageSection:AddSeparateBar()

rageSection:AddLabel('Resolver')
rageSection:AddToggle('Resolver', true, nil, function(v)
    print("Resolver:", v)
end)
rageSection:AddSlider('Resolve Type', 3, 1, 1, function(v)
    print("Resolve type:", v)
end)

-- ============================================
-- VISUALS TAB
-- ============================================
local visSection = Visuals:AddSection('ESP')

visSection:AddLabel('Player ESP')
visSection:AddToggle('Box ESP', true, Enum.KeyCode.Z, function(v)
    print("Box ESP:", v)
end)
visSection:AddToggle('Tracers', false, nil, function(v)
    print("Tracers:", v)
end)
visSection:AddToggle('Health Bar', true, nil, function(v)
    print("Health bar:", v)
end)
visSection:AddColorPallete('Box Color', Color3.fromRGB(89, 125, 255), function(c)
    print("Box color:", c)
end)
visSection:AddSeparateBar()

visSection:AddLabel('World')
visSection:AddToggle('Night Mode', false, nil, function(v)
    print("Night mode:", v)
end)
visSection:AddSlider('Brightness', 10, 0, 5, function(v)
    print("Brightness:", v)
end)

local visSection2 = Visuals:AddSection('Chams')
visSection2:AddToggle('Chams', true, nil, function(v)
    print("Chams:", v)
end)
visSection2:AddColorPallete('Chams Color', Color3.fromRGB(255, 70, 70), function(c)
    print("Chams color:", c)
end)
visSection2:AddDropdown('Chams Material', {'ForceField','Neon','Glass'}, 'ForceField', function(v)
    print("Material:", v)
end)

-- ============================================
-- MISC TAB
-- ============================================
local miscSection = Misc:AddSection('Movement')
miscSection:AddToggle('Bunny Hop', true, Enum.KeyCode.Space, function(v)
    print("BHop:", v)
end)
miscSection:AddToggle('Auto Strafe', false, nil, function(v)
    print("Auto strafe:", v)
end)
miscSection:AddSlider('Jump Power', 100, 10, 50, function(v)
    print("Jump power:", v)
end)

local miscSection2 = Misc:AddSection('Settings')
miscSection2:AddLabel('Customize your GUI')
miscSection2:AddSeparateBar()

-- Notification customization
miscSection2:AddLabel('Notifications')
miscSection2:AddDropdown('Notif Position', {'TopRight','TopLeft','BottomRight','BottomLeft'}, 'TopRight', function(v)
    library:SetNotifPosition(v)
end)
miscSection2:AddButton('Test Notification', function()
    library:Notify({title = 'PlagueUI', text = 'Notification test!', duration = 3})
end)
miscSection2:AddSeparateBar()

-- MultiDropdown example
miscSection2:AddLabel('Multi-Select Example')
miscSection2:AddMultiDropdown('Select Targets', {'Players','NPCs','Vehicles','Dropped Items'}, {'Players','Vehicles'}, function(t)
    print("Selected targets:", table.concat(t, ", "))
end)

library:Init('Misc')
