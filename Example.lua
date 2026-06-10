local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Unwalker1337/PlagueUI/main/source.lua", true))()


local Legit = library:AddWindow('Legit')
local Rage = library:AddWindow('Rage')
local AntiAim = library:AddWindow('Anti-Aim')
local Settings = library:CreateSettings('Settings')


local e = Legit:AddSection('All features')

e:AddLabel('Template Label')

e:AddButton('Test button', function()
  print('a')
end)

e:AddToggle('Testing Toggle',true,Enum.KeyCode.LeftControl, function(v)
    print(v)
end)

e:AddToggle('Testing Toggle',true,nil, function(v)
    print(v)
end)

e:AddSlider('Template Slider', 100, 10, 50, function(c)
end)

e:AddKeyBind('Template Keybind', Enum.KeyCode.Y, function()
    library:Notify({title = 'Keybind', text = 'Y pressed', duration = 2})
end)

e:AddColorPallete('Testing Color Pallete', Color3.fromRGB(89, 125, 255), function(a)
  print(a)
end)

e:AddTextBox('No filter',nil,false,5,function(a) print(a) end)
e:AddTextBox('Only numbers',nil,false,1,function(a) print(a) end)
e:AddTextBox('No special chars',nil,false,2,function(a) print(a) end)
e:AddTextBox('Only nums+chars',nil,false,3,function(a) print(a) end)
e:AddTextBox('Only Chars',nil,false,4,function(a) print(a) end)

e:AddSeparateBar()

e:AddDropdown('Testing Dropdown',{'opt1','opt2','opt3'},'opt2',function(a) print(a) end)


library:Init('Settings')
