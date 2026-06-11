local PCR_1 = Instance.new("ScreenGui")
local TweenService = game:GetService('TweenService');
local uis = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function createInstance(class, props)
	local inst = Instance.new(class)
	for i, v in pairs(props) do
		inst[i] = v
	end

	return inst
end

local function intersects (p, edge)
	local x1, y1 = edge.a.x, edge.a.y
	local x2, y2 = edge.b.x, edge.b.y

	local x3, y3 = p.x, p.y
	local x4, y4 = p.x + 2147483647, p.y

	local den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

	if den == 0 then return false end

	local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
	local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den

	if t and u and t > 0 and t < 1 and u > 0 then
		return true
	end
 
	return false
end

local function getCorners(guiObject0)
	local pos = guiObject0.AbsolutePosition
	local size = guiObject0.AbsoluteSize
	local rotation = guiObject0.Rotation

	local a = pos + size/2 - math.sqrt((size.X/2)^2 + (size.Y/2)^2) * Vector2.new(math.cos(math.rad(rotation) + math.atan2(size.Y, size.X)), math.sin(math.rad(rotation) + math.atan2(size.Y, size.X)))
	local b = pos + size/2-math.sqrt((size.X/2)^2 + (size.Y/2)^2) * Vector2.new(math.cos(math.rad(rotation) - math.atan2(size.Y, size.X)), math.sin(math.rad(rotation) - math.atan2(size.Y, size.X)))
	local c = pos + size/2+math.sqrt((size.X/2)^2 + (size.Y/2)^2) * Vector2.new(math.cos(math.rad(rotation) + math.atan2(size.Y, size.X)), math.sin(math.rad(rotation) + math.atan2(size.Y, size.X)))
	local d = pos + size/2+math.sqrt((size.X/2)^2 + (size.Y/2)^2) * Vector2.new(math.cos(math.rad(rotation) - math.atan2(size.Y, size.X)), math.sin(math.rad(rotation) - math.atan2(size.Y, size.X)))

	return { 
		topleft = a, 
		bottomleft = b, 
		topright = d, 
		bottomright = c 
	}
end


function isColliding(guiObject0, guiObject1)		
	if typeof(guiObject0) ~= "Instance" or typeof(guiObject1) ~= "Instance" then 
		error("argument must be an instance") 
		return 
	end

	local ap1 = guiObject0.AbsolutePosition
	local as1 = guiObject0.AbsoluteSize
	local sum = ap1 + as1

	local ap2 = guiObject1.AbsolutePosition
	local as2 = guiObject1.AbsoluteSize
	local sum2 = ap2 + as2

	local corners0 = getCorners(guiObject0)
	local corners1 = getCorners(guiObject1)

	local edges = {
		{
			a = corners1.topleft,
			b = corners1.bottomleft
		},
		{
			a = corners1.topleft,
			b = corners1.topright
		},
		{
			a = corners1.bottomleft,
			b = corners1.bottomright
		},
		{
			a = corners1.topright,
			b = corners1.bottomright
		}
	}

	local collisions = 0

	for _, corner in pairs(corners0) do
		for _, edge in pairs(edges) do			
			if intersects(corner, edge) then
				collisions += 1
			end			
		end
	end

	if collisions%2 ~= 0 then
		return true
	end

	if (ap1.x < sum2.x and sum.x > ap2.x) and (ap1.y < sum2.y and sum.y > ap2.y) then
		return true
	end

	return false
end




local souid = false;
local index = 0;

local function draggable(obj,extern,parented)
	local globals = {}
	globals.dragging=nil
	globals.uiorigin=nil
	globals.morigin=nil
	obj.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1 and souid == false and obj.ZIndex >= index then
			souid = true

			index = obj.ZIndex				
			obj.Parent = PCR_1

			globals.dragging = true
			globals.uiorigin = obj.Position
			globals.morigin = input.Position

			local connection 
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					globals.dragging = false
					souid = false
					connection:Disconnect()
					if extern then
						if isColliding(parented,obj)  then
							obj.Position = UDim2.new(0.5,0,0.5,0)
							obj.Parent = parented

						end
					end
				end
			end)
		else
			if input.UserInputType == Enum.UserInputType.MouseButton1 and souid==false and obj.ZIndex < index then
				obj.Parent = PCR_1
				souid = true
				index = obj.ZIndex
				globals.dragging = true
				globals.uiorigin = obj.Position
				globals.morigin = input.Position
				local connection 
				connection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						globals.dragging = false
						souid = false
						connection:Disconnect()
						if obj.Section and isColliding(obj,obj.Section)  then
							obj = obj.Section
						end
					end
				end)
			end
		end
	end)
	uis.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and globals.dragging then
			if extern then
				if isColliding(obj,parented) then
					TweenService:Create(parented , TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(19, 26, 35)}):Play()	
				else
					TweenService:Create(parented , TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play()	
				end
			end
			local change = input.Position - globals.morigin
			obj.Position = UDim2.new(globals.uiorigin.X.Scale,globals.uiorigin.X.Offset+change.X,globals.uiorigin.Y.Scale,globals.uiorigin.Y.Offset+change.Y)
		end
	end)
end





local activePalette = nil
local activePaletteTrigger = nil
local paletteClosing = false

function OpenedColor(text, ColourDisplay, Action, def)
	if paletteClosing then return end
	if activePalette then
		if activePaletteTrigger == ColourDisplay then
			paletteClosing = true
			TweenService:Create(activePalette, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 1, 0, 1), BackgroundTransparency = 1}):Play()
			local shadow = activePalette:FindFirstChild("PaletteShadow")
			if shadow then TweenService:Create(shadow, TweenInfo.new(0.2), {ImageTransparency = 1}):Play() end
			task.delay(0.25, function()
				activePalette.Visible = false
				activePalette = nil
				activePaletteTrigger = nil
				paletteClosing = false
			end)
			return
		else
			local old = activePalette
			activePalette = nil
			activePaletteTrigger = nil
			TweenService:Create(old, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 1, 0, 1), BackgroundTransparency = 1}):Play()
			local shadow = old:FindFirstChild("PaletteShadow")
			if shadow then TweenService:Create(shadow, TweenInfo.new(0.15), {ImageTransparency = 1}):Play() end
			task.delay(0.2, function() old.Visible = false end)
		end
	end

	local COLORPALLETE = Instance.new("Frame")
	local PaletteCorner = Instance.new("UICorner")
	local Holder = Instance.new("Frame")
	local BG = Instance.new("Frame")
	local S12 = Instance.new("Frame")
	local ColourWheel = Instance.new("ImageButton")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local Picker = Instance.new("ImageLabel")
	local S523 = Instance.new("UICorner")
	local DarknessPicker = Instance.new("ImageButton")
	local UIGradient = Instance.new("UIGradient")
	local Slider = Instance.new("ImageLabel")
	local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
	local S13 = Instance.new("Frame")
	local SDFH = Instance.new("UICorner")
	local ColourDisplayBIG = Instance.new("ImageLabel")
	local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
	local SETCOLOR = Instance.new("ImageButton")
	local Upper = Instance.new("Frame")
	local TEMPLATETITLE20202 = Instance.new("TextLabel")
	local linedecoupper = Instance.new("Frame")
	local PaletteShadow = Instance.new("ImageLabel")
	local RESETALL = Instance.new('ImageButton')
	RESETALL.Name = "RESETALL"
	RESETALL.Parent = S13
	RESETALL.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	RESETALL.BackgroundTransparency = 1.000
	RESETALL.BorderSizePixel = 0
	RESETALL.Position = UDim2.new(0.621510208, 0, 0.730036497, 0)
	RESETALL.Size = UDim2.new(0, 15, 0, 15)
	RESETALL.ZIndex = 23
	RESETALL.Image = "rbxassetid://5640320478"

	COLORPALLETE.Name = "COLORPALLETE"
	COLORPALLETE.Parent = PCR_1
	COLORPALLETE.AnchorPoint = Vector2.new(0.5, 0.5)
	COLORPALLETE.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	COLORPALLETE.BackgroundTransparency = 1
	COLORPALLETE.BorderSizePixel = 0
	COLORPALLETE.ClipsDescendants = true
	COLORPALLETE.Position = UDim2.new(0.5, 0, 0.5, 0)
	COLORPALLETE.Size = UDim2.new(0, 1, 0, 1)
	COLORPALLETE.ZIndex = 999

	PaletteCorner.CornerRadius = UDim.new(0, 8)
	PaletteCorner.Name = "PaletteCorner"
	PaletteCorner.Parent = COLORPALLETE

	PaletteShadow.Name = "PaletteShadow"
	PaletteShadow.Parent = COLORPALLETE
	PaletteShadow.BackgroundTransparency = 1
	PaletteShadow.BorderSizePixel = 0
	PaletteShadow.Position = UDim2.new(0, -10, 0, -10)
	PaletteShadow.Size = UDim2.new(1, 20, 1, 20)
	PaletteShadow.ZIndex = -1
	PaletteShadow.Image = "rbxassetid://1316045217"
	PaletteShadow.ImageColor3 = Color3.new(0, 0, 0)
	PaletteShadow.ImageTransparency = 1
	PaletteShadow.ScaleType = Enum.ScaleType.Slice
	PaletteShadow.SliceCenter = Rect.new(10, 10, 10, 10)

	Holder.Name = "Holder"
	Holder.Parent = COLORPALLETE
	Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Holder.BackgroundTransparency = 1.000
	Holder.BorderSizePixel = 0
	Holder.Size = UDim2.new(0, 280, 0, 162)

	BG.Name = "BG"
	BG.Parent = Holder
	BG.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	BG.BorderSizePixel = 0
	BG.Position = UDim2.new(0, 0, 0.142, 0)
	BG.Size = UDim2.new(1, 0, 0, 139)

	S12.Name = "S12"
	S12.Parent = BG
	S12.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	S12.BorderSizePixel = 0
	S12.Position = UDim2.new(0, 12, 0, 8)
	S12.Size = UDim2.new(0, 156, 0, 113)
	S12.ZIndex = 23

	ColourWheel.Name = "ColourWheel"
	ColourWheel.Parent = S12
	ColourWheel.Active = false
	ColourWheel.AnchorPoint = Vector2.new(0.5, 0.5)
	ColourWheel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ColourWheel.BackgroundTransparency = 1.000
	ColourWheel.BorderSizePixel = 0
	ColourWheel.Position = UDim2.new(0.418737918, 0, 0.491852999, 0)
	ColourWheel.Selectable = false
	ColourWheel.Size = UDim2.new(0.599832177, 0, 0.86683917, 0)
	ColourWheel.ZIndex = 25
	ColourWheel.Image = "http://www.roblox.com/asset/?id=6020299385"

	UIAspectRatioConstraint.Parent = ColourWheel
	UIAspectRatioConstraint.AspectRatio = 1.000

	Picker.Name = "Picker"
	Picker.Parent = ColourWheel
	Picker.AnchorPoint = Vector2.new(0.5, 0.5)
	Picker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Picker.BackgroundTransparency = 1.000
	Picker.BorderSizePixel = 0
	Picker.Position = UDim2.new(0.5, 0, 0.5, 0)
	Picker.Size = UDim2.new(0.0900257826, 0, 0.0900257975, 0)
	Picker.Image = "http://www.roblox.com/asset/?id=3678860011"

	S523.Name = "S523"
	S523.Parent = S12

	DarknessPicker.Name = "DarknessPicker"
	DarknessPicker.Parent = S12
	DarknessPicker.Active = false
	DarknessPicker.AnchorPoint = Vector2.new(0.5, 0.5)
	DarknessPicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	DarknessPicker.BackgroundTransparency = 1.000
	DarknessPicker.BorderSizePixel = 0
	DarknessPicker.Position = UDim2.new(0.854536772, 0, 0.554580271, 0)
	DarknessPicker.Selectable = false
	DarknessPicker.Size = UDim2.new(0.0943329856, 0, 0.88014394, 0)
	DarknessPicker.ZIndex = 25
	DarknessPicker.Image = "rbxassetid://3570695787"
	DarknessPicker.ScaleType = Enum.ScaleType.Slice
	DarknessPicker.SliceCenter = Rect.new(100, 100, 100, 100)
	DarknessPicker.SliceScale = 0.120

	UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))}
	UIGradient.Rotation = 90
	UIGradient.Parent = DarknessPicker

	Slider.Name = "Slider"
	Slider.Parent = DarknessPicker
	Slider.AnchorPoint = Vector2.new(0.5, 0.5)
	Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Slider.BackgroundTransparency = 1.000
	Slider.BorderSizePixel = 0
	Slider.Position = UDim2.new(0.491197795, 0, 0.0733607039, 0)
	Slider.Size = UDim2.new(1.28656352, 0, 0.0265010502, 0)
	Slider.ZIndex = 2
	Slider.Image = "rbxassetid://3570695787"
	Slider.ImageColor3 = Color3.fromRGB(255, 74, 74)
	Slider.ScaleType = Enum.ScaleType.Slice
	Slider.SliceCenter = Rect.new(100, 100, 100, 100)
	Slider.SliceScale = 0.120

	UIAspectRatioConstraint_2.Parent = DarknessPicker
	UIAspectRatioConstraint_2.AspectRatio = 0.157

	S13.Name = "S13"
	S13.Parent = BG
	S13.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	S13.BorderSizePixel = 0
	S13.Position = UDim2.new(0, 178, 0, 8)
	S13.Size = UDim2.new(0, 90, 0, 113)
	S13.ZIndex = 23

	SDFH.CornerRadius = UDim.new(0, 6)
	SDFH.Name = "SDFH"
	SDFH.Parent = S13

	ColourDisplayBIG.Name = "ColourDisplayBIG"
	ColourDisplayBIG.Parent = S13
	ColourDisplayBIG.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ColourDisplayBIG.BackgroundTransparency = 1.000
	ColourDisplayBIG.BorderSizePixel = 0
	ColourDisplayBIG.Position = UDim2.new(0.18, 0, 0.12, 0)
	ColourDisplayBIG.Size = UDim2.new(0.64, 0, 0.52, 0)
	ColourDisplayBIG.ZIndex = 25
	ColourDisplayBIG.Image = "rbxassetid://3570695787"
	ColourDisplayBIG.ScaleType = Enum.ScaleType.Slice
	ColourDisplayBIG.SliceCenter = Rect.new(100, 100, 100, 100)
	ColourDisplayBIG.SliceScale = 0.120

	local DisplayCorner = Instance.new("UICorner")
	DisplayCorner.CornerRadius = UDim.new(0, 6)
	DisplayCorner.Parent = ColourDisplayBIG

	SETCOLOR.Name = "SETCOLOR"
	SETCOLOR.Parent = S13
	SETCOLOR.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SETCOLOR.BackgroundTransparency = 1.000
	SETCOLOR.BorderSizePixel = 0
	SETCOLOR.Position = UDim2.new(0.18, 0, 0.69, 0)
	SETCOLOR.Size = UDim2.new(0, 16, 0, 16)
	SETCOLOR.ZIndex = 23
	SETCOLOR.Image = "rbxassetid://1489284025"

	RESETALL.Position = UDim2.new(0.53, 0, 0.69, 0)

	Upper.Name = "Upper"
	Upper.Parent = Holder
	Upper.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Upper.BackgroundTransparency = 1.000
	Upper.BorderSizePixel = 0
	Upper.Position = UDim2.new(0, 0, 0, 0)
	Upper.Size = UDim2.new(1, 0, 0, 23)
	Upper.ZIndex = 2

	TEMPLATETITLE20202.Name = "TEMPLATETITLE20202"
	TEMPLATETITLE20202.Parent = Upper
	TEMPLATETITLE20202.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TEMPLATETITLE20202.BackgroundTransparency = 1.000
	TEMPLATETITLE20202.BorderSizePixel = 0
	TEMPLATETITLE20202.Position = UDim2.new(0.02, 0, 0, 0)
	TEMPLATETITLE20202.Size = UDim2.new(0.96, 0, 1, 0)
	TEMPLATETITLE20202.ZIndex = 3
	TEMPLATETITLE20202.Font = Enum.Font.SourceSansSemibold
	TEMPLATETITLE20202.Text = text
	TEMPLATETITLE20202.TextColor3 = Color3.fromRGB(200, 200, 200)
	TEMPLATETITLE20202.TextSize = 16.000
	TEMPLATETITLE20202.TextXAlignment = Enum.TextXAlignment.Left

	linedecoupper.Name = "linedecoupper"
	linedecoupper.Parent = Holder
	linedecoupper.BackgroundColor3 = Color3.fromRGB(91, 133, 197)
	linedecoupper.BorderSizePixel = 0
	linedecoupper.Position = UDim2.new(0.02, 0, 0.142, 0)
	linedecoupper.Size = UDim2.new(0.96, 0, 0, 1)
	linedecoupper.ZIndex = 3

	activePalette = COLORPALLETE
	activePaletteTrigger = ColourDisplay
	COLORPALLETE.Visible = true
	Holder.Visible = true

	TweenService:Create(COLORPALLETE, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 280, 0, 162),
		BackgroundTransparency = 0
	}):Play()
	TweenService:Create(PaletteShadow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		ImageTransparency = 0.4
	}):Play()

	local function closePalette()
		TweenService:Create(COLORPALLETE, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 1, 0, 1),
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(PaletteShadow, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
		task.delay(0.25, function()
			COLORPALLETE.Visible = false
			activePalette = nil
			activePaletteTrigger = nil
		end)
	end

	local hsv;

	SETCOLOR.MouseButton1Click:Connect(function()
		ColourDisplay.ImageColor3 = ColourDisplayBIG.ImageColor3
		ColourDisplay.BackgroundColor3 = ColourDisplayBIG.ImageColor3
		closePalette()
		pcall(function()
			Action(Color3.fromRGB(ColourDisplayBIG.ImageColor3.R * 200, ColourDisplayBIG.ImageColor3.G * 200, ColourDisplayBIG.ImageColor3.B * 200))
		end)
	end)

	RESETALL.MouseButton1Click:Connect(function()
		closePalette()
	end)
	local buttonDown = false
	local movingSlider = false

	local function updateColour(centreOfWheel)
		local colourPickerCentre = Vector2.new(
			Picker.AbsolutePosition.X + (Picker.AbsoluteSize.X/2),
			Picker.AbsolutePosition.Y + (Picker.AbsoluteSize.Y/2)
		)
		local h = (math.pi - math.atan2(colourPickerCentre.Y - centreOfWheel.Y, colourPickerCentre.X - centreOfWheel.X)) / (math.pi * 2)
		local s = (centreOfWheel - colourPickerCentre).Magnitude / (ColourWheel.AbsoluteSize.X/2)
		local v = math.abs((Slider.AbsolutePosition.Y - DarknessPicker.AbsolutePosition.Y) / DarknessPicker.AbsoluteSize.Y - 1)
		hsv = Color3.fromHSV(math.clamp(h, 0, 1), math.clamp(s, 0, 1), math.clamp(v, 0, 1))
		ColourDisplayBIG.ImageColor3 = hsv
		UIGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, hsv),
			ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
		}
	end

	ColourWheel.MouseButton1Down:Connect(function()
		buttonDown = true
	end)
	DarknessPicker.MouseButton1Down:Connect(function()
		movingSlider = true
	end)
	uis.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		buttonDown = false
		movingSlider = false
	end)
	uis.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local mousePos = uis:GetMouseLocation() - Vector2.new(0, game:GetService("GuiService"):GetGuiInset().Y)
		local centreOfWheel = Vector2.new(ColourWheel.AbsolutePosition.X + (ColourWheel.AbsoluteSize.X/2), ColourWheel.AbsolutePosition.Y + (ColourWheel.AbsoluteSize.Y/2))
		local distanceFromWheel = (mousePos - centreOfWheel).Magnitude
		if distanceFromWheel <= ColourWheel.AbsoluteSize.X/2 and buttonDown then
			Picker.Position = UDim2.new(0, mousePos.X - ColourWheel.AbsolutePosition.X, 0, mousePos.Y - ColourWheel.AbsolutePosition.Y)
		elseif movingSlider then
			Slider.Position = UDim2.new(Slider.Position.X.Scale, 0, 0,
				math.clamp(mousePos.Y - DarknessPicker.AbsolutePosition.Y, 0, DarknessPicker.AbsoluteSize.Y))
		end
		updateColour(centreOfWheel)
	end)
	draggable(COLORPALLETE)
end


local MAIN = Instance.new("Frame")
local BG = Instance.new("Frame")
local Upper = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local linedecoupper = Instance.new("Frame")
local DOWNER = Instance.new("Frame")
local WEBSITE = Instance.new("TextLabel")
local LABEL2 = Instance.new("TextLabel")
local linedecoDOWNER = Instance.new("Frame")
local UPPERLABEL = Instance.new("TextLabel")
local limit1 = Instance.new("Frame")



--Properties:

PCR_1.Name = "PCR_1"
PCR_1.Parent = game:GetService("CoreGui")
PCR_1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
PCR_1.ResetOnSpawn = false

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MAIN

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.92
MainStroke.Thickness = 1
MainStroke.Parent = MAIN

local MainShadow = Instance.new("ImageLabel")
MainShadow.Name = "MainShadow"
MainShadow.Parent = MAIN
MainShadow.BackgroundTransparency = 1
MainShadow.BorderSizePixel = 0
MainShadow.Position = UDim2.new(0, -12, 0, -12)
MainShadow.Size = UDim2.new(1, 24, 1, 24)
MainShadow.ZIndex = -1
MainShadow.Image = "rbxassetid://1316045217"
MainShadow.ImageColor3 = Color3.new(0, 0, 0)
MainShadow.ImageTransparency = 0.55
MainShadow.ScaleType = Enum.ScaleType.Slice
MainShadow.SliceCenter = Rect.new(10, 10, 10, 10)

MAIN.Name = "MAIN"
MAIN.Parent = PCR_1
MAIN.AnchorPoint = Vector2.new(0.5, 0.5)
MAIN.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
MAIN.BorderSizePixel = 0
MAIN.Position = UDim2.new(0.285505116, 0, 0.649934769, 0)
MAIN.Size = UDim2.new(0, 588, 0, 415)
MAIN.ZIndex = 2

BG.Name = "BG"
BG.Parent = MAIN
BG.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
BG.BorderSizePixel = 0
BG.Position = UDim2.new(0, 0, 0.0615, 0)
BG.Size = UDim2.new(1, 0, 0, 365)
BG.ClipsDescendants = true

Upper.Name = "Upper"
Upper.Parent = MAIN
Upper.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Upper.BackgroundTransparency = 1.000
Upper.BorderColor3 = Color3.fromRGB(91, 133, 197)
Upper.BorderSizePixel = 0
Upper.Size = UDim2.new(0, 600, 0, 23)
Upper.ZIndex = 2


UIListLayout.Parent = Upper
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

linedecoupper.Name = "linedecoupper"
linedecoupper.Parent = MAIN
linedecoupper.BackgroundColor3 = Color3.fromRGB(91, 133, 197)
linedecoupper.BorderColor3 = Color3.fromRGB(91, 133, 197)
linedecoupper.BorderSizePixel = 0
linedecoupper.Position = UDim2.new(0, 0, 0.0591259636, 0)
linedecoupper.Size = UDim2.new(1, 0, 0, 1)
linedecoupper.ZIndex = 3

DOWNER.Name = "DOWNER"
DOWNER.Parent = MAIN
DOWNER.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DOWNER.BackgroundTransparency = 1.000
DOWNER.BorderColor3 = Color3.fromRGB(91, 133, 197)
DOWNER.BorderSizePixel = 0
DOWNER.Position = UDim2.new(0, 0, 0.943463266, 0)
DOWNER.Size = UDim2.new(0, 600, 0, 23)
DOWNER.ZIndex = 2

WEBSITE.Name = "WEBSITE"
WEBSITE.Parent = DOWNER
WEBSITE.AnchorPoint = Vector2.new(0.5, 0.5)
WEBSITE.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WEBSITE.BackgroundTransparency = 1.000
WEBSITE.BorderSizePixel = 0
WEBSITE.Position = UDim2.new(0.177174687, 0, 0.499190629, 0)
WEBSITE.Size = UDim2.new(0, 197, 0, 23)
WEBSITE.ZIndex = 3
WEBSITE.Font = Enum.Font.ArialBold
WEBSITE.Text = "NerdsInc.gq" 
WEBSITE.TextColor3 = Color3.fromRGB(199, 199, 199)
WEBSITE.TextSize = 14.000
WEBSITE.TextXAlignment = Enum.TextXAlignment.Left

LABEL2.Name = "LABEL2"
LABEL2.Parent = DOWNER
LABEL2.AnchorPoint = Vector2.new(0.5, 0.5)
LABEL2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LABEL2.BackgroundTransparency = 1.000
LABEL2.BorderSizePixel = 0
LABEL2.Position = UDim2.new(0.795508027, 0, 0.455712378, 0)
LABEL2.Size = UDim2.new(0, 197, 0, 23)
LABEL2.ZIndex = 3
LABEL2.Font = Enum.Font.ArialBold
LABEL2.Text = "Alpha build / ГўЛ†Еѕ days left"
LABEL2.TextColor3 = Color3.fromRGB(199, 199, 199)
LABEL2.TextSize = 14.000
LABEL2.TextXAlignment = Enum.TextXAlignment.Right

linedecoDOWNER.Name = "linedecoDOWNER"
linedecoDOWNER.Parent = MAIN
linedecoDOWNER.BackgroundColor3 = Color3.fromRGB(91, 133, 197)
linedecoDOWNER.BorderColor3 = Color3.fromRGB(91, 133, 197)
linedecoDOWNER.BorderSizePixel = 0
linedecoDOWNER.Position = UDim2.new(0, 0, 0.941053629, 0)
linedecoDOWNER.Size = UDim2.new(1, 0, 0, 1)
linedecoDOWNER.ZIndex = 10

UPPERLABEL.Name = "UPPERLABEL"
UPPERLABEL.Parent = MAIN
UPPERLABEL.AnchorPoint = Vector2.new(0.5, 0.5)
UPPERLABEL.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
UPPERLABEL.BackgroundTransparency = 1.000
UPPERLABEL.BorderSizePixel = 0
UPPERLABEL.Position = UDim2.new(0.906523705, 0, 0.0267967135, 0)
UPPERLABEL.Size = UDim2.new(0, 84, 0, 23)
UPPERLABEL.ZIndex = 3
UPPERLABEL.Font = Enum.Font.SourceSansSemibold
UPPERLABEL.Text = "Not loaded."
UPPERLABEL.TextColor3 = Color3.fromRGB(199, 199, 199)
UPPERLABEL.TextSize = 17.000
UPPERLABEL.TextXAlignment = Enum.TextXAlignment.Right

limit1.Name = "limit1"
limit1.Parent = MAIN
limit1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
limit1.BackgroundTransparency = 1.000
limit1.BorderSizePixel = 0
limit1.Position = UDim2.new(0, 0, 0.0615355708, 0)
limit1.Size = UDim2.new(0, 588, 0, 364)
limit1.ZIndex = 5


repeat wait() until game.Players.LocalPlayer




local library = {};
library.sections = {};
local totalSections = 0;

function library:ChangeWeb(site)
	WEBSITE.Text = site
end
function library:ChangeGame(gamee)
	LABEL2.Text = gamee
end

local tweenTime = 0.25
local tweenInfo = TweenInfo.new(
	tweenTime,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out
)


function AddRipple(button,ael,ayo)
	ayo = ayo or Color3.fromRGB(56, 56, 56)
	button.ClipsDescendants = true
	local obj = button
	local function Ripple()
		spawn(
			function()
				local Mouse = game.Players.LocalPlayer:GetMouse()
				local Circle = Instance.new("ImageLabel")
				Circle.Name = "Circle"
				Circle.Parent = obj
				Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Circle.BackgroundTransparency = 1.000
				Circle.ZIndex = 10
				Circle.Image = "rbxassetid://266543268"
				Circle.ImageColor3 = Color3.fromRGB(211, 211, 211)
				Circle.ImageTransparency = 0.6
				local NewX, NewY = Mouse.X - Circle.AbsolutePosition.X, Mouse.Y - Circle.AbsolutePosition.Y
				Circle.Position = UDim2.new(0, NewX, 0, NewY)
				local Size = 0
				if obj.AbsoluteSize.X > obj.AbsoluteSize.Y then
					Size = obj.AbsoluteSize.X * 1
				elseif obj.AbsoluteSize.X < obj.AbsoluteSize.Y then
					Size = obj.AbsoluteSize.Y * 1
				elseif obj.AbsoluteSize.X == obj.AbsoluteSize.Y then
					Size = obj.AbsoluteSize.X * 1
				end
				Circle:TweenSizeAndPosition(
					UDim2.new(0, Size, 0, Size),
					UDim2.new(0.5, -Size / 2, 0.5, -Size / 2),
					"Out",
					"Quad",
					0.2,
					false
				)
				for i = 1, 15 do
					Circle.ImageTransparency = Circle.ImageTransparency + 0.05
					wait()
				end
				Circle:Destroy()
			end
		)
	end
	local Background = Instance.new("Frame")
	local CornerRadius = Instance.new("UICorner")
	Background.Name = "Background"
	Background.Parent = button
	Background.AnchorPoint = Vector2.new(0.5, 0.5)
	Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Background.BackgroundTransparency = 1.000
	Background.ClipsDescendants = true
	Background.Position = UDim2.new(0.5, 0, 0.5, 0)
	Background.Size = UDim2.new(1, 0, 1, 0)
	CornerRadius.CornerRadius = UDim.new(0, 4)
	CornerRadius.Name = "CornerRadius"
	CornerRadius.Parent = Background

	local mouse = game.Players.LocalPlayer:GetMouse()

	local background = button:WaitForChild("Background")

	local active = false
	local hovering = false

	local function OnMouseButton1Down()
		local backgroundFadeIn = TweenService:Create(ael, tweenInfo, { TextColor3 =  ayo})
		backgroundFadeIn:Play()
	end

	local function OnMouseButton1Up()
		local backgroundFadeIn = TweenService:Create(ael, tweenInfo, { TextColor3 = Color3.fromRGB(152, 152, 152) })
		backgroundFadeIn:Play()
	end

	local function OnMouseEnter()
		hovering = true

		local backgroundFadeIn = TweenService:Create(ael, tweenInfo, { TextColor3 = Color3.fromRGB(152, 152, 152) })

		backgroundFadeIn:Play()

		backgroundFadeIn.Completed:Wait()

		local backgroundFadeOut = TweenService:Create(ael, tweenInfo, {TextColor3 = library.theme.TextSecondary or Color3.fromRGB(197, 197, 197)})

		repeat wait() until not hovering

		backgroundFadeOut:Play()
	end


	local function OnMouseLeave()
		hovering = false
		active = false
	end
	button.MouseButton1Down:Connect(OnMouseButton1Down)
	button.MouseButton1Up:Connect(OnMouseButton1Up)
	button.MouseEnter:Connect(OnMouseEnter)
	button.MouseLeave:Connect(OnMouseLeave)
	button.MouseButton1Click:Connect(Ripple)
end
local function getsize(frame)
	local size = 0;
	for i=1,#frame do
		local s = frame:sub(i,i)
		if string.upper(s) == s then
			if s == 'I' then
				size+=4
			else
				size+=12;
			end
		else
			if s == 'i' then
				size+= 4
			else
				size += 10
			end
		end
	end
	return size
end
library.fps = ''

local s,e = pcall(function()
	local k = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
end)

if not s or e then
	library.ms = 'err'
else
	spawn(function()
		game:GetService("RunService").RenderStepped:Connect(function()
			local plr = game:GetService('Players').LocalPlayer
			library.ms =  game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
		end)
	end)
end



function library:AddWatermark(Text)
	local intern = {}
	local size = math.max(#Text * 7, 20)
	local accentColor = library.theme.Accent or Color3.fromRGB(91, 133, 197)
	local textColor = library.theme.TextPrimary or Color3.fromRGB(197, 197, 197)

	local obj1 = Instance.new("Frame")
	obj1.AnchorPoint = Vector2.new(0, 0.5)
	obj1.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
	obj1.BorderSizePixel = 0
	obj1.Position = UDim2.new(0.0109301507, 0, 0.973039031, 0)
	obj1.Size = UDim2.new(0, size, 0, 28)
	obj1.ZIndex = 8
	obj1.Name = "Watermark"
	obj1.Visible = true
	obj1.ClipsDescendants = true
	obj1.Parent = PCR_1

	local wmCorner = Instance.new("UICorner")
	wmCorner.CornerRadius = UDim.new(0, 6)
	wmCorner.Parent = obj1

	local wmStroke = Instance.new("UIStroke")
	wmStroke.Color = accentColor
	wmStroke.Thickness = 1
	wmStroke.Transparency = 0.3
	wmStroke.Parent = obj1

	local obj3 = Instance.new("Frame")
	obj3.Parent = obj1
	obj3.AnchorPoint = Vector2.new(0.5, 0.5)
	obj3.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
	obj3.BorderSizePixel = 0
	obj3.Position = UDim2.new(0.5, 0, 0.5, 0)
	obj3.Size = UDim2.new(1, -4, 1, -4)
	obj3.ZIndex = 7
	obj3.Name = "WatermarkInner"

	local innerCorner = Instance.new("UICorner")
	innerCorner.CornerRadius = UDim.new(0, 4)
	innerCorner.Parent = obj3

	local obj4 = Instance.new("TextLabel")
	obj4.Parent = obj3
	obj4.BackgroundTransparency = 1
	obj4.BorderSizePixel = 0
	obj4.Position = UDim2.new(0.02, 4, 0, 0)
	obj4.Size = UDim2.new(1, -8, 1, 0)
	obj4.Font = Enum.Font.SourceSansSemibold
	obj4.Text = Text
	obj4.TextColor3 = textColor
	obj4.TextSize = 14
	obj4.TextXAlignment = Enum.TextXAlignment.Left

	draggable(obj1)

	function intern:ChangeText(text)
		local newSize = math.max(#text * 7, 20)
		obj4.Text = text
		Text = text
		obj1.Size = UDim2.new(0, newSize, 0, 28)
	end

	function intern:SetTextColor(color)
		obj4.TextColor3 = color or textColor
	end

	function intern:SetStrokeColor(color)
		wmStroke.Color = color or accentColor
	end

	local can = true
	function intern:Visible(val)
		if val == nil then return obj1.Visible end
		if can then
			val = not val
			can = false
			obj1.Visible = not val
			task.wait(0.5)
			can = true
		end
	end

	return intern
end

function library:Init(name)
    for i,v in pairs(Upper:GetChildren()) do
        if v:IsA('TextButton') then
            if v.Name == name then
                TweenService:Create(v , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(210, 210, 210)}):Play()	
            else
                TweenService:Create(v , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(138, 138, 138)}):Play()	
            end
        end
    end
    for i,v in pairs(limit1:GetChildren()) do
        if v:IsA('Frame') or v:IsA('ScrollingFrame') then
            if v.Name == name then
                v.Visible = true
            else
                v.Visible = false
            end
        end
    end
end

function library:AddWindow(text)
	local sec = {}
	text=text or 'Not Def'

	local HOLDER = Instance.new("ScrollingFrame")
	local _LEFT = Instance.new("Frame")
	local LUIL = Instance.new("UIListLayout")
	local _RIGHT = Instance.new("Frame")
	local RUIL = Instance.new("UIListLayout")
	local TEMPLATE_TEXT = Instance.new("TextButton")

	TEMPLATE_TEXT.Name = text
	TEMPLATE_TEXT.Parent = Upper
	TEMPLATE_TEXT.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TEMPLATE_TEXT.BackgroundTransparency = 1.000
	TEMPLATE_TEXT.BorderSizePixel = 0
	TEMPLATE_TEXT.Position = UDim2.new(0, 0, 0.281214178, 0)
	TEMPLATE_TEXT.Size = UDim2.new(0, 50, 0, 13)
	TEMPLATE_TEXT.ZIndex = 3
	TEMPLATE_TEXT.Font = Enum.Font.SourceSansSemibold
	TEMPLATE_TEXT.Text = text
	TEMPLATE_TEXT.TextColor3 = Color3.fromRGB(138, 138, 138)
	TEMPLATE_TEXT.TextSize = 16.000
	TEMPLATE_TEXT.Size = UDim2.new(0,getsize(text),0,13)


	HOLDER.Name = text
	HOLDER.Parent = limit1
	HOLDER.Active = true
	HOLDER.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HOLDER.BackgroundTransparency = 1.000
	HOLDER.BorderSizePixel = 0
	HOLDER.ClipsDescendants = false
	HOLDER.Position = UDim2.new(0,0,0.019,0)
	HOLDER.Visible = false
	HOLDER.Size = UDim2.new(0, 588, 0, 359)
	HOLDER.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	HOLDER.CanvasSize = UDim2.new(0, 0, 0, 0)
	HOLDER.ScrollBarThickness = 5
	HOLDER.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"

	_LEFT.Name = "_LEFT"
	_LEFT.Parent = HOLDER
	_LEFT.AnchorPoint = Vector2.new(0.5, 0.5)
	_LEFT.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_LEFT.BackgroundTransparency = 1.000
	_LEFT.BorderSizePixel = 0
	_LEFT.Position = UDim2.new(0.249334633, 0, 0.508299172, 0)
	_LEFT.Size = UDim2.new(0.5, 0, 0.972153783, 0)
	_LEFT.ZIndex = 3
	_LEFT.ClipsDescendants = true

	LUIL.Name = "LUIL"
	LUIL.Parent = _LEFT
	LUIL.HorizontalAlignment = Enum.HorizontalAlignment.Center
	LUIL.SortOrder = Enum.SortOrder.LayoutOrder
	LUIL.Padding = UDim.new(0, 5)

	_RIGHT.Name = "_RIGHT"
	_RIGHT.Parent = HOLDER
	_RIGHT.AnchorPoint = Vector2.new(0.5, 0.5)   
	_RIGHT.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_RIGHT.BackgroundTransparency = 1.000
	_RIGHT.BorderSizePixel = 0
	_RIGHT.Position = UDim2.new(0.749334514, 0, 0.508299172, 0)
	_RIGHT.Size = UDim2.new(0.5, 0, 0.972153783, 0)
	_RIGHT.ZIndex = 3
	_RIGHT.ClipsDescendants = true

	RUIL.Name = "RUIL"
	RUIL.Parent = _RIGHT
	RUIL.HorizontalAlignment = Enum.HorizontalAlignment.Center
	RUIL.SortOrder = Enum.SortOrder.LayoutOrder
	RUIL.Padding = UDim.new(0, 5)

	local fghk = Instance.new("UIListLayout")

	TEMPLATE_TEXT.MouseButton1Click:Connect(function()
		for i,v in pairs(Upper:GetChildren()) do
			if v:IsA('TextButton') then
				TweenService:Create(v , TweenInfo.new(0.26, Enum.EasingStyle.Quad    , Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(138, 138, 138)}):Play()	
			end
		end
		TweenService:Create(TEMPLATE_TEXT , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(210, 210, 210)}):Play()	
		for i,v in pairs(limit1:GetChildren()) do
			if v:IsA('Frame') or v:IsA('ScrollingFrame') then
				v.Visible = false
			end
		end
		HOLDER.Visible = true
	end)

	fghk.Name = "fghk"
	fghk.Parent =HOLDER
	fghk.FillDirection = Enum.FillDirection.Horizontal
	fghk.SortOrder = Enum.SortOrder.LayoutOrder
	local function getlarger(num)
		local LeftSize =  LUIL.AbsoluteContentSize.Y
		local RightSize =  RUIL.AbsoluteContentSize.Y
		if num == 1 then
			if LeftSize > RightSize then
				return 'l'    
			elseif LeftSize < RightSize then
				return 'r'
			elseif LeftSize == RightSize then
				return 'r'
			end
		elseif num == 2 then
			return {l=LeftSize,r=RightSize}
		else
			return ''
		end
	end
	local function UpdateMainSize(f,anim)
		HOLDER.ClipsDescendants = true

		if getlarger(1) == 'l' then
			if anim then
				TweenService:Create(HOLDER, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CanvasSize = UDim2.fromOffset(0, getlarger(2).l + 15)}):Play()
			else   
				HOLDER.CanvasSize = UDim2.fromOffset(0, getlarger(2).l + 15)

			end

		elseif getlarger(1) == 'r' then
			if anim then
				TweenService:Create(HOLDER, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CanvasSize = UDim2.fromOffset(0, getlarger(2).r + 15)}):Play()
			else
				HOLDER.CanvasSize = UDim2.fromOffset(0, getlarger(2).r + 15)
				HOLDER.CanvasSize = UDim2.fromOffset(0, getlarger(2).r + 15)
			end
		end

	end

	local function GetSide(typ,input)   
		if typ == 1 then
			local parented;
			local s;
			if (totalSections%2 == 0) then
				parented = _RIGHT
				s= RUIL
			else
				parented = _LEFT
				s= LUIL
			end
			return parented,s
		elseif typ == 2 and input then
			if tonumber(input) == nil then   
				if input == 'Right' or input == 'R' or input == 'r' then
					return _RIGHT,RUIL
				end
				if input == 'Left' or input == 'L' or input == 'l' then
					return _LEFT,LUIL
				end
			else
				if input == 1 then
					return _LEFT,LUIL
				elseif input == 2 then
					return _RIGHT,RUIL   
				else
					return GetSide(1);
				end
			end
		else
			return GetSide(1);
		end
	end
	local section_info = {};
	function sec:UpdateSize()
		UpdateMainSize()
	end
	local function AutoFit(section,list)
		if section and list then
			local x,y =  section.AbsoluteSize.X,list.AbsoluteContentSize.Y  
			local lefts,ls = 0,{};
			local rights,rs = 0,{};
			section.Size = UDim2.fromOffset(x,  y + 8) + UDim2.new(0,0,0,23)

			UpdateMainSize()
		end

	end

	function sec:AddSection(Texto,side)
		local inside = {};
		Texto=Texto or 'Not Defined'
		totalSections+=1;

		local _PARENT,LIST =  GetSide(2,side)
		local SECTIONHOLDER = Instance.new("Frame")
		local Section = Instance.new("Frame")
		local Z_Holder = Instance.new("Frame")
		local HOLDER_2 = Instance.new("Frame")    
		local SECTION2UILIB = Instance.new("UIListLayout")
		local F_line = Instance.new("Frame")
		local A_label = Instance.new("TextLabel")
		local SECTIONIOL = Instance.new("UIListLayout")
		local us = Instance.new('UIStroke');

		us.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		us.LineJoinMode = Enum.LineJoinMode.Round
		us.Thickness = 1;
		us.Transparency =0.85;
		us.Color = Color3.fromRGB(255, 255, 255)
		us.Parent  = Section;
		us.Name = '_STROKE_'
		local SectionHolderCorner = Instance.new("UICorner")
		SectionHolderCorner.CornerRadius = UDim.new(0, 8)
		SectionHolderCorner.Parent = SECTIONHOLDER

		local SectionHolderStroke = Instance.new("UIStroke")
		SectionHolderStroke.Color = Color3.fromRGB(255, 255, 255)
		SectionHolderStroke.Transparency = 0.93
		SectionHolderStroke.Thickness = 1
		SectionHolderStroke.Parent = SECTIONHOLDER

		SECTIONHOLDER.Name = Texto
		SECTIONHOLDER.Parent = _PARENT
		SECTIONHOLDER.BackgroundColor3 = library.theme.SectionBg or Color3.fromRGB(18, 18, 20)
		SECTIONHOLDER.BorderSizePixel = 0      
		SECTIONHOLDER.Position = UDim2.new(0.0289115645, 0, -4.23979145e-08, 0)
		SECTIONHOLDER.Size = UDim2.new(0, 275, 0, 138)
		SECTIONHOLDER.ZIndex = 3	

		if library.sections[SECTIONHOLDER.Name] ~= nil then
			print('ERROR: FUNCTION (AddSection): SECTIONS MUST HAVE DIFFERENT NAMES!!!')
			return 
		else
			library.sections[SECTIONHOLDER.Name] = _PARENT
		end

		local SectionCorner = Instance.new("UICorner")
		SectionCorner.CornerRadius = UDim.new(0, 6)
		SectionCorner.Parent = Section

		Section.Name = "Section"
		Section.Parent = SECTIONHOLDER
		Section.AnchorPoint = Vector2.new(0.5, 0.5)
		Section.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
		Section.BorderSizePixel = 0
		Section.ClipsDescendants = true
		Section.Position = UDim2.new(0.5, 0, 0.5, 0)    
		Section.Size = UDim2.new(0.96,0,1,0)
		Section.ZIndex = 4

		Z_Holder.Name = "Z_Holder"
		Z_Holder.Parent = Section
		Z_Holder.AnchorPoint = Vector2.new(0.5, 0.5)
		Z_Holder.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
		Z_Holder.BorderSizePixel = 0
		Z_Holder.Position = UDim2.new(0.5, 0, 0.5, 0)
		Z_Holder.Size = UDim2.new(1, 0, 1, 0)
		Z_Holder.ZIndex = 4

		HOLDER_2.Name = "HOLDER"
		HOLDER_2.Parent = Z_Holder
		HOLDER_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		HOLDER_2.BackgroundTransparency = 1.000
		HOLDER_2.Position = UDim2.new(0.01, 0, 0, 6)
		HOLDER_2.Size = UDim2.new(0.98, 0, 0.94, 0)   
		HOLDER_2.ZIndex = 5

		SECTION2UILIB.Name = "SECTION2UILIB"
		SECTION2UILIB.Parent = HOLDER_2
		SECTION2UILIB.SortOrder = Enum.SortOrder.LayoutOrder
		SECTION2UILIB.HorizontalAlignment = Enum.HorizontalAlignment.Center
		SECTION2UILIB.Padding = UDim.new(0, 6)

		F_line.Name = "F_line"
		F_line.Parent = Section
		F_line.BackgroundColor3 = library.theme.Accent
		F_line.BorderSizePixel = 0
		F_line.Position = UDim2.new(0, 0, 0.1, 0)
		F_line.Size = UDim2.new(1, 0, 0, 1)
		F_line.ZIndex = 6

		A_label.Name = "A_label"
		A_label.Parent = Section
		A_label.AnchorPoint = Vector2.new(0, 0.5)
		A_label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  
		A_label.BackgroundTransparency = 1.000
		A_label.BorderSizePixel = 0
		A_label.Position = UDim2.new(0.03, 0, 0.05, 0)
		A_label.Size = UDim2.new(0.94, 0, 0, 22)
		A_label.ZIndex = 3
		A_label.Font = Enum.Font.SourceSansSemibold
		A_label.Text = Texto
		A_label.TextColor3 = library.theme.TextPrimary or Color3.fromRGB(221, 221, 221)
		A_label.TextSize = 17.000
		A_label.TextXAlignment = Enum.TextXAlignment.Left

		SECTIONIOL.Name = "SECTIONIOL"
		SECTIONIOL.Parent = Section
		SECTIONIOL.HorizontalAlignment = Enum.HorizontalAlignment.Center

		SECTIONHOLDER.Size = UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 8) + UDim2.new(0,0,0,23)
		_PARENT.Size = UDim2.new(_PARENT.Size.X.Scale, _PARENT.Size.X.Offset , 0 ,LIST.AbsoluteContentSize.Y + 15);

		AutoFit()
		--TweenService:Create(closeSection , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {Rotation = 0}):Play()	
		UpdateMainSize()

		function inside:AddTextBox(Text,placeholder, CTOF, Type, Action)

			Text=Text or 'Not Defined'
			placeholder = placeholder or 'Input Here'
			CTOF = CTOF or false
			Type = Type or 2

			local filter = '%W+' 
			local filter2 = '%p+'
			local onlunum = '%D+'   
			local onlychars = '%A+'

			local function colador(str,type)
				local str =str
				if type == 1 then
					str= str:gsub(onlunum, ''); -- exclude a-Z
				end
				if type == 2 then
					str= str:gsub(filter2, ''); -- exclude special characters (~!@#$%^&*()_+.,<>?:"}{-=`")
				end
				if type == 3 then
					str= str:gsub(filter, ''); -- exclude special characters + space bar (~!@#$%^&*()_+.,<>?:"}{-=`"  )
				end
				if type == 4 then
					str= str:gsub(onlychars, ''); -- exclude special characters + numbers + space bar (~!@#$%^&*()_+.,<>?:"}{-=`"  0-9) 
				end
				if type == 5 then
					str = str   
				end
				return str
			end

			--[TemplateTexstbox]--
			local obj1 = Instance.new("Frame")
			obj1.BackgroundColor3 = Color3.new(1, 1, 1)
			obj1.BackgroundTransparency = 1
			obj1.BorderSizePixel = 0
			obj1.Position = UDim2.new(0.155858055, 0, 0.392140955, 0)
			obj1.Size = UDim2.new(0, 239, 0, 22)
			obj1.ZIndex = 14
			obj1.Name = [[TemplateTexstbox]]
			obj1.Parent = HOLDER_2
			--[color]--
			local obj2 = Instance.new("Frame", obj1)   
			obj2.AnchorPoint = Vector2.new(1, 0.5)
			obj2.BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392)
			obj2.BorderSizePixel = 0
			obj2.Position = UDim2.new(1.02739561, 0, 0.546084344, 0)
			obj2.Size = UDim2.new(0, 70, 0, 16)
			obj2.ZIndex = 25
			obj2.Name = [[color]]

			--[UIStroke]--
			local obj3 = Instance.new("UIStroke", obj2)
			obj3.Color = Color3.new(0.203922, 0.203922, 0.203922)

			--[UIGradient]--   
			local obj4 = Instance.new("UIGradient", obj3)
			obj4.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(0.705882, 0.705882, 0.705882))})

			--[TextBox]--
			local obj5 = Instance.new("TextBox", obj2)
			obj5.BackgroundColor3 = Color3.new(1, 1, 1)
			obj5.BackgroundTransparency = 1
			obj5.BorderSizePixel = 0
			obj5.Size = UDim2.new(1, 0, 1, 0)
			obj5.ZIndex = 28
			obj5.ClearTextOnFocus = CTOF
			obj5.CursorPosition = -1
			obj5.Font = Enum.Font.ArialBold
			obj5.PlaceholderText = placeholder
			obj5.Text = [[]]
			obj5.TextColor3 = Color3.new(1, 1, 1)   
			obj5.TextSize = 10
			obj5.TextStrokeColor3 = Color3.new(0.639216, 0.639216, 0.639216)

			if #obj5.Text <= 5 then
				obj2:TweenSize(UDim2.new(0,#obj5.PlaceholderText*6,0,16),'Out','Quint',0,true);
			else
				obj2:TweenSize(UDim2.new(0,#obj5.PlaceholderText*6,0,16),'Out','Quint',0,true);

			end
			--[TextLabel]--
			local obj6 = Instance.new("TextLabel", obj1)
			obj6.BackgroundColor3 = Color3.new(0.772549, 0.772549, 0.772549)
			obj6.BackgroundTransparency = 1
			obj6.BorderSizePixel = 0
			obj6.Position = UDim2.new(-0.00865958631, 0, 0.0133694736, 0)
			obj6.Size = UDim2.new(0, 169, 0, 24)
			obj6.ZIndex = 15
			obj6.Font = Enum.Font.SourceSansBold
			obj6.Text = Text
			obj6.TextColor3 = Color3.new(0.772549, 0.772549, 0.772549)
			obj6.TextSize = 14
			obj6.TextXAlignment = Enum.TextXAlignment.Left  

			local AC = function(PassBox)
				PassBox.Text=colador(obj5.Text,Type)

				if PassBox.Text == nil or PassBox.Text == '' then
   
					if #PassBox.Text <= 5 then
						obj2:TweenSize(UDim2.new(0,#PassBox.PlaceholderText*10,0,16),'Out','Quint',0.4,true);
					else
						obj2:TweenSize(UDim2.new(0,#PassBox.PlaceholderText*6,0,16),'Out','Quint',0.4,true);

					end

				else
					obj2:TweenSize(UDim2.new(0,#PassBox.Text*7,0,16),'Out','Quint',0.4,true);
				end
				if #PassBox.Text >= 21 then
					PassBox.Text = string.sub(PassBox.Text,0,21)
				end
				spawn(
					function()
						pcall(function()
							Action(obj5.Text)
						end)  
					end)
			end
			local text = ''
			obj5.Changed:Connect(function()
				if obj5.Text == nil or obj5.Text == ' ' or obj5.Text =='' then
					obj2:TweenSize(UDim2.new(0,#obj5.PlaceholderText*6,0,16),'Out','Quint',0.4,true);
					return
				end
				if text ~= obj5.Text then
					text = obj5.Text
					AC(obj5)
				end
			end)

			SECTIONHOLDER.Size = UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 8) + UDim2.new(0,0,0,23)
			_PARENT.Size = UDim2.new(_PARENT.Size.X.Scale, _PARENT.Size.X.Offset , 0 ,LIST.AbsoluteContentSize.Y + 15);
			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			UpdateMainSize(nil,true)
			local textboxObj = {Type = "TextBox", Text = Text, obj5 = obj5}
			library.registry.textboxes[Text] = textboxObj
		end
		function inside:AddSlider(Text,Max,Min,def,Action)
			Text = Text or 'Not Defined'
			Max = Max or 100
			Min =Min or Max/4
			def = def or Max/2
			local mouse = game.Players.LocalPlayer:GetMouse()
			local SliderDef = math.clamp(def, Min, Max) or math.clamp(50, Min, Max)
			local DefaultScale =  (SliderDef - Min) / (Max - Min)
			Action = Action or function() end
			local Value;

			local obj1 = Instance.new("Frame")
			obj1.BackgroundColor3 = Color3.new(0.117647, 0.117647, 0.113725)
			obj1.BackgroundTransparency = 1
			obj1.BorderSizePixel = 0
			obj1.Position = UDim2.new(0.0435978472, 0, 0.255637407, 0)
			obj1.Size = UDim2.new(0, 248, 0, 32)
			obj1.ZIndex = 20
			obj1.Name = [[Slider]]
			obj1.Parent = HOLDER_2

			local obj2 = Instance.new("TextLabel", obj1)
			obj2.BackgroundColor3 = Color3.new(1, 1, 1)
			obj2.BackgroundTransparency = 1
			obj2.BorderSizePixel = 0
			obj2.Position = UDim2.new(0.00500635942, 0, 0.0442914963, 0)
			obj2.Size = UDim2.new(0, 197, 0, 10)
			obj2.ZIndex = 21
			obj2.Font = Enum.Font.SourceSansSemibold
			obj2.Text = Text
			obj2.TextColor3 = Color3.new(0.772549, 0.772549, 0.772549)
			obj2.TextSize = 16
			obj2.TextXAlignment = Enum.TextXAlignment.Left

			local obj3 = Instance.new("TextButton", obj1)
			obj3.BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392)
			obj3.BackgroundTransparency = 1
			obj3.BorderSizePixel = 0
			obj3.ClipsDescendants = true
			obj3.Position = UDim2.new(0, 1, 0, 19)
			obj3.Size = UDim2.new(0, 243, 0, 13)
			obj3.ZIndex = 21
			obj3.Font = Enum.Font.SourceSans
			obj3.Text = [[]]
			obj3.TextColor3 = Color3.new(0, 0, 0)
			obj3.TextSize = 1
			obj3.AutoButtonColor = false
			obj3.Name = [[sbt]]

			local obj4 = Instance.new("TextBox")
			obj4.Name = "pcntage"
			obj4.Parent = obj1
			obj4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			obj4.BackgroundTransparency = 1.000
			obj4.BorderSizePixel = 0
			obj4.Position = UDim2.new(0.79838711, 0, 0, 0)
			obj4.Size = UDim2.new(0, 44, 0, 11)
			obj4.ZIndex = 23
			obj4.ClearTextOnFocus = false
			obj4.Font = Enum.Font.SourceSansBold
			obj4.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
			obj4.Text = def
			obj4.TextColor3 = Color3.fromRGB(90, 90, 90)
			obj4.TextSize = 14.000
			obj4.TextXAlignment = Enum.TextXAlignment.Right

			local obj5 = Instance.new("Frame", obj1)
			obj5.BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392)
			obj5.BorderSizePixel = 0
			obj5.Position = UDim2.new(-0.002,0,0.491,0)
			obj5.Size = UDim2.new(0, 243, 0, 13)
			obj5.ZIndex = 23
			obj5.Name = [[HOLDER_3]]

			local Holder3Corner = Instance.new("UICorner")
			Holder3Corner.CornerRadius = UDim.new(0, 6)
			Holder3Corner.Parent = obj5

			local obj6 = Instance.new("Frame", obj5)
			obj6.BackgroundColor3 = Color3.new(1, 1, 1)
			obj6.BorderSizePixel = 0
			obj6.Position = UDim2.new(0, 0, 0, 0)
			obj6.Size = UDim2.fromScale(DefaultScale,1)
			obj6.ZIndex = 23
			obj6.Name = [[SFrame]]

			local SFrameCorner = Instance.new("UICorner")
			SFrameCorner.CornerRadius = UDim.new(0, 6)
			SFrameCorner.Parent = obj6

			local obj7 = Instance.new("UIGradient", obj6)
			obj7.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.345098, 0.509804, 0.752941)), ColorSequenceKeypoint.new(1, Color3.new(0.270588, 0.4, 0.592157))})

			local obj8 = Instance.new("UIStroke", obj5)
			obj8.Color = Color3.new(0.203922, 0.203922, 0.203922)
			obj8.Thickness = 1

			local st = def or Max/2
			obj4.FocusLost:Connect(function(n)
				if n then
					if obj4.Text == nil or obj4.Text == '' or obj4.Text == ' ' or obj4.Text:find(' ') then
						Value = tonumber(obj4.Text)
						obj4.Text = st
						local SliderDef = math.clamp(tonumber(obj4.Text), Min, Max) or math.clamp(50, Min, Max)
						local DefaultScale =  (SliderDef - Min) / (Max - Min)
						obj6.Size = UDim2.fromScale(DefaultScale,1)
						pcall(function() Action(Value) end)
						return
					end
					if tonumber(obj4.Text) > Max then
						obj4.Text = Max; st = obj4.Text
						Value = tonumber(obj4.Text)
						local SliderDef = math.clamp(tonumber(obj4.Text), Min, Max) or math.clamp(50, Min, Max)
						local DefaultScale =  (SliderDef - Min) / (Max - Min)
						obj6.Size = UDim2.fromScale(DefaultScale,1)
						pcall(function() Action(Value) end)
						return
					end
					if tonumber(obj4.Text) < Min then
						obj4.Text = Min; st = obj4.Text
						Value = tonumber(obj4.Text)
						local SliderDef = math.clamp(tonumber(obj4.Text), Min, Max) or math.clamp(50, Min, Max)
						local DefaultScale =  (SliderDef - Min) / (Max - Min)
						obj6.Size = UDim2.fromScale(DefaultScale,1)
						pcall(function() Action(Value) end)
						return
					end
					st = obj4.Text
					Value = tonumber(obj4.Text)
					local SliderDef = math.clamp(tonumber(obj4.Text), Min, Max) or math.clamp(50, Min, Max)
					local DefaultScale =  (SliderDef - Min) / (Max - Min)
					obj6.Size = UDim2.fromScale(DefaultScale,1)
					pcall(function() Action(Value) end)
				else
					obj4.Text = st 
					Value = tonumber(obj4.Text)
					local SliderDef = math.clamp(tonumber(obj4.Text), Min, Max) or math.clamp(50, Min, Max)
					local DefaultScale =  (SliderDef - Min) / (Max - Min)
					obj6.Size = UDim2.fromScale(DefaultScale,1)
					return
				end
			end)
			obj4.Changed:Connect(function()
				if #obj4.Text > 7 then
					obj4.Text= st 
					Value = tonumber(obj4.Text)
					local SliderDef = math.clamp(tonumber(obj4.Text), Min, Max) or math.clamp(50, Min, Max)
					local DefaultScale =  (SliderDef - Min) / (Max - Min)
					obj6.Size = UDim2.fromScale(DefaultScale,1)
					return
				end
			end)
			obj3.MouseButton1Down:Connect(function()
				TweenService:Create(obj8, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(115, 115, 115)}):Play()
				obj4.TextXAlignment = Enum.TextXAlignment.Right
				Value = ((((tonumber(Max) - tonumber(Min)) / 244) * obj6.AbsoluteSize.X) + tonumber(Min)) or 0
				Value = (Value)
				TweenService:Create(obj4, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				obj6.Size = UDim2.new(0, math.clamp(mouse.X - obj6.AbsolutePosition.X, 0, 244), 0, 13)
				moveconnection = mouse.Move:Connect(function()
					obj4.Text = ('%0.2f'):format(Value)
					Value = ((((tonumber(Max) - tonumber(Min)) / 244) * obj6.AbsoluteSize.X) + tonumber(Min))
					Value = (Value)
					pcall(function() Action(Value) end)
					obj6.Size = UDim2.new(0, math.clamp(mouse.X - obj6.AbsolutePosition.X, 0, 244), 0, 13)
				end)
				releaseconnection = uis.InputEnded:Connect(function(Mouse)
					if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
						Value = ((((tonumber(Max) - tonumber(Min)) / 244) * obj6.AbsoluteSize.X) + tonumber(Min))
						Value =(Value)
						pcall(function() Action(Value) end)
						obj6.Size = UDim2.new(0, math.clamp(mouse.X - obj6.AbsolutePosition.X, 0, 244), 0, 13)
						moveconnection:Disconnect()
						releaseconnection:Disconnect()
					end
				end)
				obj4.Text = ('%0.2f'):format(Value)
			end)
			obj3.MouseButton1Up:Connect(function()
				TweenService:Create(obj8, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(52, 52, 52)}):Play()
				TweenService:Create(obj4, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(126, 126, 126)}):Play()
			end)
			obj3.MouseLeave:Connect(function()
				TweenService:Create(obj4, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(126, 126, 126)}):Play()
				TweenService:Create(obj8, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(52, 52, 52)}):Play()
			end)
			SECTIONHOLDER.Size = UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X, SECTION2UILIB.AbsoluteContentSize.Y + 8) + UDim2.new(0,0,0,23)
			_PARENT.Size = UDim2.new(_PARENT.Size.X.Scale, _PARENT.Size.X.Offset, 0, LIST.AbsoluteContentSize.Y + 15)
			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X, SECTION2UILIB.AbsoluteContentSize.Y + 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X, LIST.AbsoluteContentSize.Y + 15), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			UpdateMainSize(nil,true)
			library.registry.sliders[Text] = {Type = "Slider", Text = Text, Value = st, obj4 = obj4, obj6 = obj6, Min = Min, Max = Max}
		end
		function inside:AddLabel(Text)
			Text=Text or 'Not Defined'
			local TextLabel = Instance.new("TextLabel")

			TextLabel.Parent = HOLDER_2
			TextLabel.AutomaticSize =Enum.AutomaticSize.Y

			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.0329693519, 0, 0, 0)
			TextLabel.Size = UDim2.new(0, 253, 0, 11)
			TextLabel.ZIndex = 15
			TextLabel.Font = Enum.Font.SourceSansSemibold
			TextLabel.Text = Text
			TextLabel.TextColor3 = library.theme.TextSecondary or Color3.fromRGB(197, 197, 197)
			TextLabel.TextSize = 18.000
			TextLabel.TextWrapped = true
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel.TextYAlignment = Enum.TextYAlignment.Top
			
			TextLabel.AutomaticSize = Enum.AutomaticSize.Y


			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			UpdateMainSize(nil,true)
			return TextLabel
		end
		local function getsize(str)
			local r = 0;
			for i=1,#str do
				r+=1
			end
			if r <= 5 then
				if r == 1 then
					return r * 50
				end
				if r ==2 then
					return r * 25
				end
				if r ==3 then
					return r * 16
				end
				if r == 4 then
					return r * 12
				end
				if r == 5 then
					return r * 10
				end
			end
			return r * 7.5
		end
		function inside:AddToggle(Text,Enabled,keybind,Callback)
			Callback = Callback or function() end
			Text=Text or 'Not Defined'
			local activated = Enabled or false;
			local y = {};

			local TemplateToggle = Instance.new("Frame")
			local TextLabel = Instance.new("TextLabel")
			local Interactive = Instance.new("TextButton")
			local color = Instance.new("Frame")
			local UIGradient = Instance.new("UIGradient");
			local UIStroke = Instance.new('UIStroke');

			UIStroke.Parent= color;
			UIStroke.Color = Color3.fromRGB(52,52,52);
			UIStroke.LineJoinMode = Enum.LineJoinMode.Round;
			UIStroke.Thickness = 1;
			UIStroke.Transparency = 0;
			UIStroke.Name = 'UIStroke';

			local function Update()
				if activated == false then
					TweenService:Create(color , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(84, 122, 181)}):Play()
					TweenService:Create(UIStroke, TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {Color = Color3.fromRGB(84, 122, 181)}):Play()
					TweenService:Create(TextLabel, tweenInfo, { TextColor3 = Color3.fromRGB(180, 180, 180) }):Play()
					spawn(function()
						pcall(function()
							Callback(activated)
						end)
					end)
					activated = true
				elseif activated == true then
					TweenService:Create(color , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
					TweenService:Create(UIStroke, TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {Color = Color3.fromRGB(52, 52, 52)}):Play()
					TweenService:Create(TextLabel, tweenInfo, { TextColor3 = Color3.fromRGB(84, 84, 84) }):Play()
					spawn(function()
						pcall(function()
							Callback(activated)
						end)
					end)
					activated = false
				end
			end

			TemplateToggle.Name = "TemplateToggle"
			TemplateToggle.Parent = HOLDER_2
			TemplateToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TemplateToggle.BackgroundTransparency = 1.000
			TemplateToggle.BorderSizePixel = 0
			TemplateToggle.Position = UDim2.new(0.155858055, 0, 0.392140955, 0)
			TemplateToggle.Size = UDim2.new(0, 239, 0, 22)
			TemplateToggle.ZIndex = 14

			TextLabel.Parent = TemplateToggle
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.0833906233, 0, 0.0133694736, 0)
			TextLabel.Size = UDim2.new(0, 220, 0, 15)
			TextLabel.ZIndex = 15
			TextLabel.Font = Enum.Font.SourceSansBold
			TextLabel.Text = Text
			TextLabel.TextColor3 = library.theme.TextSecondary or Color3.fromRGB(84, 84, 84)
			TextLabel.TextSize = 14.000
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			Interactive.Name = "Interactive"
			Interactive.Parent = TemplateToggle
			Interactive.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Interactive.BackgroundTransparency = 1.000
			Interactive.BorderSizePixel = 0
			Interactive.Position = UDim2.new(-0.0240641702, 0, 0, 0)
			Interactive.Size = UDim2.new(0, 246, 0, 18)
			Interactive.ZIndex = 20
			Interactive.Font = Enum.Font.SourceSans
			Interactive.Text = ""
			Interactive.TextColor3 = Color3.fromRGB(0, 0, 0)
			Interactive.TextSize = 20.000

			local ToggleColorCorner = Instance.new("UICorner")
			ToggleColorCorner.CornerRadius = UDim.new(0, 4)
			ToggleColorCorner.Parent = color

			color.Name = "color"
			color.Parent = TemplateToggle
			color.AnchorPoint = Vector2.new(0.5, 0.5)
			color.BackgroundColor3 = library.theme.ToggleOff or Color3.fromRGB(25, 25, 25)
			color.BorderSizePixel = 0
			color.Position = UDim2.new(0.0192536544, 0, 0.386994779, 0)
			color.Size = UDim2.new(0, 16, 0, 16)
			color.ZIndex = 15

			local KeyButton = Instance.new("TextButton")
			local h5 = Instance.new("UICorner")


			KeyButton.Name = "KeyButton"
			KeyButton.Parent = TemplateToggle
			KeyButton.AnchorPoint = Vector2.new(1, 0.5)
			KeyButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			KeyButton.BorderSizePixel = 0
			KeyButton.ClipsDescendants = true
			KeyButton.Position = UDim2.new(1.00271928, 0, 0.366679788, 0)
			KeyButton.Size = UDim2.new(0, 45, 0, 15)
			KeyButton.ZIndex = 22
			KeyButton.AutoButtonColor = false
			KeyButton.Font = Enum.Font.ArialBold
			if keybind then
				KeyButton.Text = keybind.Name or '. . .'
			else
				KeyButton.Text ='. . .'
			end
			KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			KeyButton.TextSize = 10.000
			KeyButton.TextStrokeColor3 = Color3.fromRGB(45, 45, 45)

			h5.CornerRadius = UDim.new(0, 3)
			h5.Name = "h5"
			h5.Parent = KeyButton
			KeyButton:TweenSize(UDim2.new(0,getsize(KeyButton.Text),0,15),'InOut','Quint',0.2,true)

			if keybind then
				local ischanging = false;
				local KeyCode = keybind

				game:GetService("UserInputService").InputBegan:connect(function(a, gp) 
					if not gp then 
						if (a.KeyCode.Name == KeyCode or a.KeyCode.Name == KeyCode.Name) and ischanging == false then 
							pcall(function()
								Update()
							end)
						end
					end
				end)

				KeyButton.MouseButton1Click:connect(function() 
					game.TweenService:Create(KeyButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						BackgroundColor3 = Color3.fromRGB(34, 34, 34)
					}):Play()
					KeyButton.Text = ". . ."
					KeyButton:TweenSize(UDim2.new(0,getsize(KeyButton.Text),0,13), "InOut", "Quint", 0.2, true)

					local v1, v2 = game:GetService('UserInputService').InputBegan:wait();
					if v1.KeyCode.Name ~= "Unknown" then
						ischanging = true
						game.TweenService:Create(KeyButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
							BackgroundColor3 = Color3.fromRGB(25, 25, 25)
						}):Play()
						KeyButton:TweenSize(UDim2.new(0,getsize( v1.KeyCode.Name),0,13), "Out", "Quint", 0.3, true)
						KeyButton.Text = v1.KeyCode.Name
						KeyCode = v1.KeyCode.Name;
						wait(.2)
						ischanging = false
					end
				end)
			else
				KeyButton.Visible = false
			end
			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			UpdateMainSize(nil,true)
			function y:UpdateValue(val)
				activated = val
				Update()
			end
			Update()

			Interactive.MouseButton1Click:Connect(Update)
			Interactive.MouseEnter:Connect(function()
				TweenService:Create(UIStroke , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {Color = Color3.fromRGB(115, 115, 115)}):Play()
			end)
			Interactive.MouseLeave:Connect(function()
				TweenService:Create(UIStroke , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {Color = Color3.fromRGB(52, 52, 52)}):Play()

			end)
			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			UpdateMainSize(nil,true)
			y.Type = "Toggle"
			y.Value = activated
			y.ColorFrame = color
			library.registry.toggles[Text] = y
			return y

		end
		function inside:AddSeparateBar()
			local obj1 = Instance.new("Frame")
			obj1.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
			obj1.Position = UDim2.new(0.0159928761, 0, 0.491355002, 0)
			obj1.Size = UDim2.new(0, 258, 0, 3)
			obj1.ZIndex = 22
			obj1.Parent = HOLDER_2
			local obj2 = Instance.new("UICorner", obj1)
			obj2.CornerRadius = UDim.new(1, 10)
			SECTIONHOLDER.Size = UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 8) + UDim2.new(0,0,0,23)
			_PARENT.Size = UDim2.new(_PARENT.Size.X.Scale, _PARENT.Size.X.Offset , 0 ,LIST.AbsoluteContentSize.Y + 15);

			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			UpdateMainSize(nil,true)


		end
		function inside:AddColorPallete(Text,Color,Action)
			Text = Text or 'Not defined'
			Color = Color or Color3.fromRGB(255,255,255)
			Action = Action or function() end
			local SECTIONCOLOUR = Instance.new("Frame")
			local CCCC3 = Instance.new("UICorner")

			local OPENCLOSE = Instance.new("TextButton")
			local UICorner = Instance.new("UICorner")
			local ColourDisplay = Instance.new("ImageLabel")


			SECTIONCOLOUR.Name = "SECTIONCOLOUR"
			SECTIONCOLOUR.Parent = HOLDER_2
			SECTIONCOLOUR.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			SECTIONCOLOUR.BorderSizePixel = 0
			SECTIONCOLOUR.ClipsDescendants = true
			SECTIONCOLOUR.Position = UDim2.new(0.0251945332, 0, 0.517914712, 0)
			SECTIONCOLOUR.Size = UDim2.new(0, 258, 0, 22)
			SECTIONCOLOUR.ZIndex = 22

			CCCC3.CornerRadius = UDim.new(0, 6)
			CCCC3.Name = "CCCC3"
			CCCC3.Parent = SECTIONCOLOUR

			OPENCLOSE.Name = "OPENCLOSE"
			OPENCLOSE.Parent = SECTIONCOLOUR
			OPENCLOSE.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			OPENCLOSE.BackgroundTransparency = 0
			OPENCLOSE.BorderSizePixel = 0
			OPENCLOSE.ClipsDescendants = true
			OPENCLOSE.Position = UDim2.new(0, 7, 0, 2)
			OPENCLOSE.Size = UDim2.new(0, 243, 0, 18)
			OPENCLOSE.ZIndex = 23
			OPENCLOSE.AutoButtonColor = false
			OPENCLOSE.Font = Enum.Font.SourceSansSemibold
			OPENCLOSE.Text = Text
			OPENCLOSE.TextColor3 = Color3.fromRGB(255, 255, 255)
			OPENCLOSE.TextSize = 16.000
			OPENCLOSE.TextXAlignment = Enum.TextXAlignment.Left

			local OpenCloseCorner = Instance.new("UICorner")
		OpenCloseCorner.CornerRadius = UDim.new(0, 6)
		OpenCloseCorner.Parent = OPENCLOSE

			local ColourDisplayCorner = Instance.new("UICorner")
			ColourDisplayCorner.CornerRadius = UDim.new(0, 4)
			ColourDisplayCorner.Parent = ColourDisplay

			ColourDisplay.Name = "ColourDisplay"
			ColourDisplay.Parent = SECTIONCOLOUR
			ColourDisplay.BackgroundColor3 = Color
			ColourDisplay.BackgroundTransparency = 0
			ColourDisplay.BorderSizePixel = 0
			ColourDisplay.Position = UDim2.new(0, 220, 0, 4)
			ColourDisplay.Size = UDim2.new(0, 29, 0, 14)
			ColourDisplay.ZIndex = 23
			ColourDisplay.Image = "rbxassetid://3570695787"
			ColourDisplay.ScaleType = Enum.ScaleType.Slice
			ColourDisplay.SliceCenter = Rect.new(100, 100, 100, 100)
			ColourDisplay.SliceScale = 0.120
			ColourDisplay.ImageColor3 = Color
			SECTIONHOLDER.Size = UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 8) + UDim2.new(0,0,0,23)
			_PARENT.Size = UDim2.new(_PARENT.Size.X.Scale, _PARENT.Size.X.Offset , 0 ,LIST.AbsoluteContentSize.Y + 15);
			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			UpdateMainSize(nil,true)
			AutoFit(SECTIONHOLDER,SECTION2UILIB)
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 

			OPENCLOSE.MouseButton1Click:Connect(function()
				OpenedColor(Text,ColourDisplay,Action,Color)
			end)
			local textKey = Text:gsub(" ", ""):gsub("Color", ""):gsub("Background", ""):gsub("Section", ""):gsub("Text", ""):gsub("Accent", "Accent"):gsub("Toggle", "Toggle"):gsub("Slider", "Slider")
			for themeKey, _ in pairs(library.theme) do
				if Text:find(themeKey) then
					textKey = themeKey
					break
				end
			end
			library.registry.colorpickers[Text] = {Type = "ColorPicker", Text = Text, textKey = textKey, ColourDisplay = ColourDisplay, Color = Color, Action = Action}
		end
		function inside:AddKeyBind(Text, KeyCode, Action)
			Text = Text or 'Not Defined'
			KeyCode = KeyCode or Enum.KeyCode.RightAlt
			Action = Action or function() end
			local mode = "Toggle"

			local TemplateKBIND = Instance.new("Frame")
			local TextLabel = Instance.new("TextLabel")
			local Interactive = Instance.new("TextButton")
			local KeyButton = Instance.new("TextButton")
			local h5 = Instance.new("UICorner")

			TemplateKBIND.Name = "TemplateKBIND"
			TemplateKBIND.Parent = HOLDER_2
			TemplateKBIND.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TemplateKBIND.BackgroundTransparency = 1.000
			TemplateKBIND.BorderSizePixel = 0
			TemplateKBIND.Position = UDim2.new(0.155858055, 0, 0.392140955, 0)
			TemplateKBIND.Size = UDim2.new(0, 239, 0, 22)
			TemplateKBIND.ZIndex = 14

			TextLabel.Parent = TemplateKBIND
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(-0.0121270986, 0, 0.0133694736, 0)
			TextLabel.Size = UDim2.new(0, 200, 0, 15)
			TextLabel.ZIndex = 15
			TextLabel.Font = Enum.Font.SourceSansBold
			TextLabel.Text = Text
			TextLabel.TextColor3 = library.theme.TextSecondary or Color3.fromRGB(197, 197, 197)
			TextLabel.TextSize = 14.000
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			Interactive.Name = "Interactive"
			Interactive.Parent = TemplateKBIND
			Interactive.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Interactive.BackgroundTransparency = 1.000
			Interactive.BorderSizePixel = 0
			Interactive.Position = UDim2.new(-0.0240641963, 0, 0, 0)
			Interactive.Size = UDim2.new(0, 246, 0, 18)
			Interactive.ZIndex = 20
			Interactive.Font = Enum.Font.SourceSans
			Interactive.Text = ""
			Interactive.TextColor3 = Color3.fromRGB(0, 0, 0)
			Interactive.TextSize = 20.000

			KeyButton.Name = "KeyButton"
			KeyButton.Parent = TemplateKBIND
			KeyButton.AnchorPoint = Vector2.new(1, 0.5)
			KeyButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			KeyButton.BorderSizePixel = 0
			KeyButton.ClipsDescendants = true
			KeyButton.Position = UDim2.new(1.00271928, 0, 0.366679788, 0)
			KeyButton.Size = UDim2.new(0, 45, 0, 15)
			KeyButton.ZIndex = 55
			KeyButton.AutoButtonColor = false
			KeyButton.Font = Enum.Font.ArialBold
			KeyButton.Text = KeyCode.Name
			KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			KeyButton.TextSize = 10.000
			KeyButton.TextStrokeColor3 = Color3.fromRGB(45, 45, 45)

			h5.CornerRadius = UDim.new(0, 3)
			h5.Name = "h5"
			h5.Parent = KeyButton

			-- Mode popup
			local modePopup = Instance.new("Frame")
			modePopup.Name = "ModePopup"
			modePopup.Parent = PCR_1
			modePopup.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
			modePopup.BorderSizePixel = 0
			modePopup.Size = UDim2.new(0, 90, 0, 0)
			modePopup.ZIndex = 999
			modePopup.Visible = false
			modePopup.ClipsDescendants = true

			local popupCorner = Instance.new("UICorner")
			popupCorner.CornerRadius = UDim.new(0, 6)
			popupCorner.Parent = modePopup

			local popupStroke = Instance.new("UIStroke")
			popupStroke.Color = Color3.fromRGB(255, 255, 255)
			popupStroke.Transparency = 0.92
			popupStroke.Thickness = 1
			popupStroke.Parent = modePopup

			local popupLayout = Instance.new("UIListLayout")
			popupLayout.Parent = modePopup
			popupLayout.SortOrder = Enum.SortOrder.LayoutOrder
			popupLayout.Padding = UDim.new(0, 2)
			popupLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

			local popupPadding = Instance.new("UIPadding")
			popupPadding.Parent = modePopup
			popupPadding.PaddingTop = UDim.new(0, 4)
			popupPadding.PaddingBottom = UDim.new(0, 4)

			local function createModeOption(txt)
				local btn = Instance.new("TextButton")
				btn.Parent = modePopup
				btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
				btn.BorderSizePixel = 0
				btn.Size = UDim2.new(0, 82, 0, 20)
				btn.ZIndex = 1000
				btn.AutoButtonColor = false
				btn.Font = Enum.Font.SourceSansSemibold
				btn.Text = txt
				btn.TextColor3 = Color3.fromRGB(180, 180, 180)
				btn.TextSize = 13
				return btn
			end

			local toggleBtn = createModeOption("Toggle")
			local holdBtn = createModeOption("Hold")

			local function closePopup()
				modePopup.Visible = false
			end

			toggleBtn.MouseButton1Click:Connect(function()
				mode = "Toggle"
				toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
				holdBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
				closePopup()
			end)
			holdBtn.MouseButton1Click:Connect(function()
				mode = "Hold"
				holdBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
				toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
				closePopup()
			end)

			if mode == "Toggle" then toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45) end

			local ischanging = false
			local held = false

			local function onKeyPress()
				if mode == "Toggle" then
					pcall(function() Action(KeyCode) end)
				else
					held = not held
					pcall(function() Action(held and KeyCode or nil) end)
				end
			end

			game:GetService("UserInputService").InputBegan:connect(function(a, gp)
				if not gp and not ischanging then
					if a.KeyCode == KeyCode then
						if mode == "Hold" then
							held = true
							pcall(function() Action(KeyCode) end)
						else
							onKeyPress()
						end
					end
				end
			end)

			game:GetService("UserInputService").InputEnded:connect(function(a, gp)
				if not gp and mode == "Hold" and a.KeyCode == KeyCode then
					held = false
					pcall(function() Action(nil) end)
				end
			end)

			KeyButton.MouseButton1Click:connect(function()
				TweenService:Create(KeyButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
					BackgroundColor3 = Color3.fromRGB(34, 34, 34)
				}):Play()
				KeyButton.Text = ". . ."
				KeyButton:TweenSize(UDim2.new(0, getsize(KeyButton.Text), 0, 13), "InOut", "Quint", 0.2, true)
				local v1, v2 = game:GetService('UserInputService').InputBegan:wait()
				if v1.KeyCode.Name ~= "Unknown" then
					ischanging = true
					TweenService:Create(KeyButton, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						BackgroundColor3 = Color3.fromRGB(25, 25, 25)
					}):Play()
					KeyButton:TweenSize(UDim2.new(0, getsize(v1.KeyCode.Name), 0, 13), "Out", "Quint", 0.3, true)
					KeyButton.Text = v1.KeyCode.Name
					KeyCode = v1.KeyCode
					wait(0.2)
					ischanging = false
				end
			end)

			KeyButton.MouseButton2Click:Connect(function()
				local absPos = KeyButton.AbsolutePosition
				modePopup.Position = UDim2.new(0, absPos.X - 22, 0, absPos.Y + KeyButton.AbsoluteSize.Y + 4)
				modePopup.Size = UDim2.new(0, 90, 0, 48)
				modePopup.Visible = true
				modePopup.ZIndex = 999
			end)

			uis.InputBegan:Connect(function(input)
				if modePopup.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
					local mPos = Vector2.new(input.Position.X, input.Position.Y)
					local popupAbs = modePopup.AbsolutePosition
					local popupSize = modePopup.AbsoluteSize
					if mPos.X < popupAbs.X or mPos.X > popupAbs.X + popupSize.X or mPos.Y < popupAbs.Y or mPos.Y > popupAbs.Y + popupSize.Y then
						closePopup()
					end
				end
			end)

			SECTIONHOLDER.Size = UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 8) + UDim2.new(0,0,0,23)
			_PARENT.Size = UDim2.new(_PARENT.Size.X.Scale, _PARENT.Size.X.Offset , 0 ,LIST.AbsoluteContentSize.Y + 15);
			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			UpdateMainSize(nil,true)
		end
		function inside:AddDropdown(Text,tbl,sel,Action)
			Text = Text or 'Not Defined'
			tbl = tbl or {'Not','Defined','Option'}
			sel = sel or tbl[2] or '.-. bruh dude like fr, put one valid SIMPLE table.'
			Action = Action or function() end

			local K  =false
			local s =nil


			local DRPDOWN = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local Toggle = Instance.new("TextButton")
			local _456fg = Instance.new("UICorner")
			local TextLabel = Instance.new("TextLabel")
			local TextLabel_2 = Instance.new("TextLabel")
			local UIListLayout = Instance.new("UIListLayout")


			--Properties:

			DRPDOWN.Name = "DRPDOWN"
			DRPDOWN.Parent = HOLDER_2
			DRPDOWN.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			DRPDOWN.BorderSizePixel = 0
			DRPDOWN.ClipsDescendants = true
			DRPDOWN.Position = UDim2.new(0.0362365209, 0, 0.69055295, 0)
			DRPDOWN.Size = UDim2.new(0, 252, 0, 25)
			DRPDOWN.ZIndex = 27

			UICorner.CornerRadius = UDim.new(0, 4)
			UICorner.Parent = DRPDOWN

			Toggle.Name = "Toggle"
			Toggle.Parent = DRPDOWN
			Toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			Toggle.BorderSizePixel = 0
			Toggle.ClipsDescendants = true
			Toggle.Size = UDim2.new(0, 252, 0, 22)
			Toggle.AutoButtonColor = false
			Toggle.Font = Enum.Font.SourceSansSemibold
			Toggle.Text = "  "
			Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
			Toggle.TextSize = 16.000

			_456fg.CornerRadius = UDim.new(0, 4)
			_456fg.Name = "456fg"
			_456fg.Parent = Toggle

			TextLabel.Parent = Toggle
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.44808808, 0, 0.454545468, 0)
			TextLabel.Size = UDim2.new(0, 208, 0, 18)
			TextLabel.ZIndex = 30
			TextLabel.Font = Enum.Font.SourceSansSemibold
			TextLabel.Text = Text
			TextLabel.TextColor3 = library.theme.TextSecondary or Color3.fromRGB(197, 197, 197)
			TextLabel.TextSize = 16.000
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			TextLabel_2.Parent = Toggle
			TextLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_2.BackgroundTransparency = 1.000
			TextLabel_2.BorderSizePixel = 0
			TextLabel_2.Position = UDim2.new(0.91685158, 0, 0.550000012, 0)
			TextLabel_2.Size = UDim2.new(0, 14, 0, 14)
			TextLabel_2.ZIndex = 30
			TextLabel_2.Font = Enum.Font.SourceSansSemibold
			TextLabel_2.Text = "+"
			TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_2.TextSize = 16.000
			TextLabel_2.TextXAlignment = Enum.TextXAlignment.Right

			UIListLayout.Parent = DRPDOWN
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Padding = UDim.new(0, 3)

			for i,v in pairs(tbl) do
				local OPTION = Instance.new("TextButton")
				local _456fg_2 = Instance.new("UICorner")
				local TextLabel_3 = Instance.new("TextLabel")
				OPTION.Name = "OPTION"
				OPTION.Parent = DRPDOWN
				OPTION.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
				OPTION.BorderSizePixel = 0
				OPTION.ClipsDescendants = true
				OPTION.Position = UDim2.new(0.055555556, 0, 0.378787875, 0)
				OPTION.Size = UDim2.new(0, 233, 0, 16)
				OPTION.ZIndex = 29
				OPTION.AutoButtonColor = false
				OPTION.Font = Enum.Font.SourceSansSemibold
				OPTION.Text = ''
				OPTION.TextColor3 = Color3.fromRGB(255, 255, 255)
				OPTION.TextSize = 16.000

				_456fg_2.CornerRadius = UDim.new(0, 4)
				_456fg_2.Name = "456fg"
				_456fg_2.Parent = OPTION

				TextLabel_3.Parent = OPTION
				TextLabel_3.AnchorPoint = Vector2.new(0.5, 0.5)
				TextLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_3.BackgroundTransparency = 1.000
				TextLabel_3.BorderSizePixel = 0
				TextLabel_3.Position = UDim2.new(0.501999259, 0, 0.441162109, 0)
				TextLabel_3.Size = UDim2.new(0, 125, 0, 15)
				TextLabel_3.Font = Enum.Font.SourceSansSemibold
				TextLabel_3.Text = v
				TextLabel_3.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_3.TextSize = 15.000

				if sel == v and v ~= Toggle.Text then
					TweenService:Create(OPTION , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(28,28,28)}):Play()	
					s = sel;
					TextLabel.Text = s
				else
					TweenService:Create(OPTION , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(37,37,37)}):Play()	
				end

				OPTION.MouseButton1Click:Connect(function()
					for i,v in pairs(DRPDOWN:GetChildren()) do
						if v:IsA("TextButton") and v ~= Toggle then
							TweenService:Create(v , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(37,37,37)}):Play()	
						end	
					end
					s=TextLabel_3.Text
					TextLabel.Text = s
					TweenService:Create(OPTION , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()	
					pcall(function()
						Action(s)
					end)
				end)

				SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
				task.wait()
				_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
				task.wait()
				UpdateMainSize(nil,true)

				AddRipple(OPTION,TextLabel_3)
			end

			Toggle.MouseButton1Click:Connect(function()
				if not K then
					TweenService:Create(TextLabel_2 , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.Out), {Rotation = 180}):Play()	
					DRPDOWN:TweenSize(UDim2.fromOffset(DRPDOWN.AbsoluteSize.X,  UIListLayout.AbsoluteContentSize.Y + 11),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true) 
					K = not K
				else
					DRPDOWN:TweenSize(UDim2.new(0,DRPDOWN.AbsoluteSize.X,0, 25),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true) 
					TweenService:Create(TextLabel_2 , TweenInfo.new(0.26, Enum.EasingStyle.Quad , Enum.EasingDirection.Out), {Rotation = 0}):Play()	
					K = not K
				end
				wait(.3)
				SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true) 
				wait(.2)
				_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true) 
				wait(.2)
				UpdateMainSize(nil,true)

			end)




			AddRipple(Toggle,TextLabel_2,Color3.fromRGB(180, 180, 180))
			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 

			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			UpdateMainSize(nil,true)
			library.registry.dropdowns[Text] = {Type = "Dropdown", Text = Text, Value = s, Frame = DRPDOWN, Toggle = Toggle, ListLayout = UIListLayout}
		end
		function inside:AddMultiDropdown(Text, tbl, sel, Action)
			Text = Text or 'Not Defined'
			tbl = tbl or {'Not','Defined','Option'}
			sel = sel or {}
			Action = Action or function() end

			local K = false
			local selected = {}
			for _, v in pairs(sel) do selected[v] = true end

			local DRPDOWN = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local Toggle = Instance.new("TextButton")
			local _456fg = Instance.new("UICorner")
			local TextLabel = Instance.new("TextLabel")
			local TextLabel_2 = Instance.new("TextLabel")
			local UIListLayout = Instance.new("UIListLayout")

			DRPDOWN.Name = "DRPDOWN"
			DRPDOWN.Parent = HOLDER_2
			DRPDOWN.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			DRPDOWN.BorderSizePixel = 0
			DRPDOWN.ClipsDescendants = true
			DRPDOWN.Position = UDim2.new(0.0362365209, 0, 0.69055295, 0)
			DRPDOWN.Size = UDim2.new(0, 252, 0, 25)
			DRPDOWN.ZIndex = 27

			UICorner.CornerRadius = UDim.new(0, 4)
			UICorner.Parent = DRPDOWN

			Toggle.Name = "Toggle"
			Toggle.Parent = DRPDOWN
			Toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			Toggle.BorderSizePixel = 0
			Toggle.ClipsDescendants = true
			Toggle.Size = UDim2.new(0, 252, 0, 22)
			Toggle.AutoButtonColor = false
			Toggle.Font = Enum.Font.SourceSansSemibold
			Toggle.Text = "  "
			Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
			Toggle.TextSize = 16

			_456fg.CornerRadius = UDim.new(0, 4)
			_456fg.Name = "456fg"
			_456fg.Parent = Toggle

			TextLabel.Parent = Toggle
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel.BackgroundTransparency = 1
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.44808808, 0, 0.454545468, 0)
			TextLabel.Size = UDim2.new(0, 208, 0, 18)
			TextLabel.ZIndex = 30
			TextLabel.Font = Enum.Font.SourceSansSemibold
			TextLabel.Text = Text
			TextLabel.TextColor3 = library.theme.TextSecondary or Color3.fromRGB(197, 197, 197)
			TextLabel.TextSize = 16
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			TextLabel_2.Parent = Toggle
			TextLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel_2.BackgroundTransparency = 1
			TextLabel_2.BorderSizePixel = 0
			TextLabel_2.Position = UDim2.new(0.91685158, 0, 0.550000012, 0)
			TextLabel_2.Size = UDim2.new(0, 14, 0, 14)
			TextLabel_2.ZIndex = 30
			TextLabel_2.Font = Enum.Font.SourceSansSemibold
			TextLabel_2.Text = "+"
			TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_2.TextSize = 16
			TextLabel_2.TextXAlignment = Enum.TextXAlignment.Right

			UIListLayout.Parent = DRPDOWN
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Padding = UDim.new(0, 3)

			local function updateLabel()
				local count = 0
				local txt = ""
				for _, v in pairs(tbl) do
					if selected[v] then
						count = count + 1
						if txt ~= "" then txt = txt .. ", " end
						txt = txt .. v
					end
				end
				TextLabel.Text = txt
			end

			for i, v in pairs(tbl) do
				local OPTION = Instance.new("TextButton")
				local _456fg_2 = Instance.new("UICorner")
				local TextLabel_3 = Instance.new("TextLabel")
				local CheckLabel = Instance.new("TextLabel")

				OPTION.Name = "OPTION"
				OPTION.Parent = DRPDOWN
				OPTION.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
				OPTION.BorderSizePixel = 0
				OPTION.ClipsDescendants = true
				OPTION.Position = UDim2.new(0.055555556, 0, 0.378787875, 0)
				OPTION.Size = UDim2.new(0, 233, 0, 16)
				OPTION.ZIndex = 29
				OPTION.AutoButtonColor = false
				OPTION.Font = Enum.Font.SourceSansSemibold
				OPTION.Text = ""
				OPTION.TextColor3 = Color3.fromRGB(255, 255, 255)
				OPTION.TextSize = 16

				_456fg_2.CornerRadius = UDim.new(0, 4)
				_456fg_2.Name = "456fg"
				_456fg_2.Parent = OPTION

				CheckLabel.Parent = OPTION
				CheckLabel.AnchorPoint = Vector2.new(0, 0.5)
				CheckLabel.BackgroundTransparency = 1
				CheckLabel.BorderSizePixel = 0
				CheckLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
				CheckLabel.Size = UDim2.new(0, 16, 0, 14)
				CheckLabel.Font = Enum.Font.SourceSansBold
				CheckLabel.Text = selected[v] and ">" or " "
				CheckLabel.TextColor3 = selected[v] and Color3.fromRGB(91, 133, 197) or Color3.fromRGB(80, 80, 80)
				CheckLabel.TextSize = 14

				TextLabel_3.Parent = OPTION
				TextLabel_3.AnchorPoint = Vector2.new(0, 0.5)
				TextLabel_3.BackgroundTransparency = 1
				TextLabel_3.BorderSizePixel = 0
				TextLabel_3.Position = UDim2.new(0.18, 0, 0.5, 0)
				TextLabel_3.Size = UDim2.new(0, 125, 0, 15)
				TextLabel_3.Font = Enum.Font.SourceSansSemibold
				TextLabel_3.Text = v
				TextLabel_3.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_3.TextSize = 15
				TextLabel_3.TextXAlignment = Enum.TextXAlignment.Left

				if selected[v] then
					TweenService:Create(OPTION, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
				end

				OPTION.MouseButton1Click:Connect(function()
					selected[v] = not selected[v]
					CheckLabel.Text = selected[v] and ">" or " "
					CheckLabel.TextColor3 = selected[v] and Color3.fromRGB(91, 133, 197) or Color3.fromRGB(80, 80, 80)
					if selected[v] then
						TweenService:Create(OPTION, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
					else
						TweenService:Create(OPTION, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(37, 37, 37)}):Play()
					end
					updateLabel()
					local result = {}
					for _, opt in pairs(tbl) do
						if selected[opt] then table.insert(result, opt) end
					end
					pcall(function() Action(result) end)
				end)

				SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X, SECTION2UILIB.AbsoluteContentSize.Y + 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true)
				task.wait()
				_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X, LIST.AbsoluteContentSize.Y + 15), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true)
				task.wait()
				UpdateMainSize(nil, true)
			end

			Toggle.MouseButton1Click:Connect(function()
				if not K then
					TweenService:Create(TextLabel_2, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 180}):Play()
					DRPDOWN:TweenSize(UDim2.fromOffset(DRPDOWN.AbsoluteSize.X, UIListLayout.AbsoluteContentSize.Y + 11), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
					K = not K
				else
					DRPDOWN:TweenSize(UDim2.new(0, DRPDOWN.AbsoluteSize.X, 0, 25), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
					TweenService:Create(TextLabel_2, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
					K = not K
				end
				wait(.3)
				SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X, SECTION2UILIB.AbsoluteContentSize.Y + 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
				wait(.2)
				_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X, LIST.AbsoluteContentSize.Y + 15), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
				wait(.2)
				UpdateMainSize(nil, true)
			end)

			AddRipple(Toggle, TextLabel_2, Color3.fromRGB(180, 180, 180))
			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X, SECTION2UILIB.AbsoluteContentSize.Y + 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true)
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X, LIST.AbsoluteContentSize.Y + 15), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true)
			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X, SECTION2UILIB.AbsoluteContentSize.Y + 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true)
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X, LIST.AbsoluteContentSize.Y + 15), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true)
			UpdateMainSize(nil, true)
			updateLabel()
		end
		function inside:AddButton(Text,Callback)
			Callback = Callback or function() end
			Text=Text or 'Not Defined'
			local TemplateButton = Instance.new("Frame")
			local TextLabel = Instance.new("TextLabel")
			local Interactive = Instance.new("TextButton")
			local UICorner = Instance.new("UICorner")

			TemplateButton.Name = "TemplateButton"
			TemplateButton.Parent = HOLDER_2
			TemplateButton.BackgroundColor3 = library.theme.SectionBg or Color3.fromRGB(25, 25, 25)
			TemplateButton.BorderSizePixel = 0
			TemplateButton.Position = UDim2.new(0.0430313908, 0, 0, 0)
			TemplateButton.Size = UDim2.new(0, 243, 0, 21)
			TemplateButton.ZIndex = 14
			TemplateButton.ClipsDescendants = true
			TextLabel.Parent = TemplateButton
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0, 0, 0, 0)
			TextLabel.Size = UDim2.new(0,243,0,19)
			TextLabel.ZIndex = 15
            TextLabel.Text=Text
			TextLabel.Font = Enum.Font.SourceSansBold
			TextLabel.TextColor3 = library.theme.TextSecondary or Color3.fromRGB(84, 84, 84)
			TextLabel.TextSize = 17.000

			Interactive.Name = "Interactive"
			Interactive.Parent = TemplateButton
			Interactive.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Interactive.BackgroundTransparency = 1.000
			Interactive.BorderSizePixel = 0
			Interactive.Position = UDim2.new(0, 0, 0, 0)
			Interactive.Size = UDim2.new(0,243,0,21)
			Interactive.ZIndex = 20
			Interactive.Font = Enum.Font.SourceSans
			Interactive.Text = ""
			Interactive.TextColor3 = Color3.fromRGB(0, 0, 0)
			Interactive.TextSize = 18.000
			--Interactive.ClipsDescendants = true
			UICorner.CornerRadius = UDim.new(0, 6)
			UICorner.Parent = TemplateButton
			local UIStroke = Instance.new('UIStroke');

			UIStroke.Parent= TemplateButton;
			UIStroke.Color = Color3.fromRGB(255, 255, 255);
			UIStroke.LineJoinMode = Enum.LineJoinMode.Round;
			UIStroke.Thickness = 1;
			UIStroke.Transparency = 0.9;
			UIStroke.Name = 'UIStroke';

			Interactive.MouseButton1Click:Connect(function()
				spawn(function()
					pcall(function()
						Callback()
					end)
				end)
			end)
			Interactive.MouseEnter:Connect(function()
				local hover = library.theme.SectionBg and library.theme.SectionBg:lerp(Color3.fromRGB(255,255,255), 0.08) or Color3.fromRGB(35, 35, 40)
				TweenService:Create(TemplateButton, TweenInfo.new(0.2), {BackgroundColor3 = hover}):Play()
			end)
			Interactive.MouseLeave:Connect(function()
				TweenService:Create(TemplateButton, TweenInfo.new(0.2), {BackgroundColor3 = library.theme.SectionBg or Color3.fromRGB(25, 25, 25)}):Play()
			end)
			SECTIONHOLDER.Size = UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 8) + UDim2.new(0,0,0,23)
			_PARENT.Size = UDim2.new(_PARENT.Size.X.Scale, _PARENT.Size.X.Offset , 0 ,LIST.AbsoluteContentSize.Y + 15);
			SECTIONHOLDER:TweenSize(UDim2.fromOffset(SECTIONHOLDER.AbsoluteSize.X,  SECTION2UILIB.AbsoluteContentSize.Y + 42),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			wait()
			_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 
			UpdateMainSize(nil,true)
		end			
		AutoFit(SECTIONHOLDER,SECTION2UILIB)
		_PARENT:TweenSize(UDim2.fromOffset(_PARENT.AbsoluteSize.X,  LIST.AbsoluteContentSize.Y + 15),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0, true) 

		return inside
	end

	return sec
end




draggable(MAIN)

-- to check fps (not mine function so yeah) --
spawn(function()
	local TimeFunction = RunService:IsRunning() and time or os.clock
	local LastIteration, Start
	local FrameUpdateTable = {}
	local function HeartbeatUpdate()
		LastIteration = TimeFunction()
		for Index = #FrameUpdateTable, 1, -1 do
			FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
		end

		FrameUpdateTable[1] = LastIteration
		library.fps = tostring(math.floor(TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start))) .. " FPS"
		UPPERLABEL.Text = library.fps
	end

	Start = TimeFunction()
	RunService.Heartbeat:Connect(HeartbeatUpdate)
end)
library.theme = {
	MainBg = Color3.fromRGB(16, 16, 18),
	SectionBg = Color3.fromRGB(18, 18, 20),
	InnerBg = Color3.fromRGB(26, 26, 30),
	Accent = Color3.fromRGB(91, 133, 197),
	TextPrimary = Color3.fromRGB(221, 221, 221),
	TextSecondary = Color3.fromRGB(152, 152, 152),
	ToggleOn = Color3.fromRGB(84, 122, 181),
	ToggleOff = Color3.fromRGB(25, 25, 25),
	SliderFill = Color3.fromRGB(88, 130, 193),
	NotifPosition = "TopRight",
}

function library:UpdateTheme(props)
	local old = {}
	for k, v in pairs(props) do
		old[k] = library.theme[k]
		library.theme[k] = v
	end
	pcall(function()
		if props.Accent then
			linedecoupper.BackgroundColor3 = library.theme.Accent
			linedecoDOWNER.BackgroundColor3 = library.theme.Accent
			for _, v in pairs(PCR_1:GetDescendants()) do
				if v.Name == "F_line" and v:IsA("Frame") then
					v.BackgroundColor3 = library.theme.Accent
				end
			end
			if not props.ToggleOn then
				library.theme.ToggleOn = library.theme.Accent
			end
			if not props.SliderFill then
				library.theme.SliderFill = library.theme.Accent
			end
		end
		if props.Accent and not props.ToggleOn then
			for _, t in pairs(library.registry.toggles) do
				if t.ColorFrame then
					TweenService:Create(t.ColorFrame, TweenInfo.new(0.26), {BackgroundColor3 = library.theme.Accent}):Play()
				end
			end
		end
		if props.Accent and not props.SliderFill then
			for _, s in pairs(library.registry.sliders) do
				if s.obj6 then
					local obj7 = s.obj6:FindFirstChildOfClass("UIGradient")
					if obj7 then
						obj7.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.theme.Accent), ColorSequenceKeypoint.new(1, library.theme.Accent:lerp(Color3.new(0,0,0), 0.3))})
					end
				end
			end
		end
	end)
	pcall(function()
		if props.MainBg then
			MAIN.BackgroundColor3 = library.theme.MainBg
		end
	end)
	pcall(function()
		if props.SectionBg then
			for _, v in pairs(PCR_1:GetDescendants()) do
				if v:IsA("Frame") then
					local name = v.Name
					if name == "Section" or name == "SECTIONCOLOUR" or name == "Z_Holder" or name == "TemplateButton" then
						pcall(function() TweenService:Create(v, TweenInfo.new(0.26), {BackgroundColor3 = library.theme.SectionBg}):Play() end)
					end
				end
			end
			for _, v in pairs(PCR_1:GetDescendants()) do
				if v:IsA("Frame") and v:FindFirstChild("Section") and v:FindFirstChild("A_label") then
					pcall(function() TweenService:Create(v, TweenInfo.new(0.26), {BackgroundColor3 = library.theme.SectionBg}):Play() end)
				end
			end
		end
	end)
	pcall(function()
		if props.InnerBg then
			for _, v in pairs(PCR_1:GetDescendants()) do
				if v.Name == "HOLDER" and v:IsA("Frame") then
					v.BackgroundColor3 = library.theme.InnerBg
				end
			end
		end
	end)
	pcall(function()
		if props.TextPrimary then
			local oldColor = old.TextPrimary or Color3.fromRGB(221, 221, 221)
			local function matchColor(c)
				return math.abs(c.R - oldColor.R) < 0.01 and math.abs(c.G - oldColor.G) < 0.01 and math.abs(c.B - oldColor.B) < 0.01
			end
			for _, v in pairs(PCR_1:GetDescendants()) do
				if v:IsA("TextLabel") and matchColor(v.TextColor3) then
					v.TextColor3 = library.theme.TextPrimary
				end
			end
		end
	end)
	pcall(function()
		if props.TextSecondary then
			local oldColor = old.TextSecondary or Color3.fromRGB(197, 197, 197)
			local function matchColor(c)
				return math.abs(c.R - oldColor.R) < 0.01 and math.abs(c.G - oldColor.G) < 0.01 and math.abs(c.B - oldColor.B) < 0.01
			end
			for _, v in pairs(PCR_1:GetDescendants()) do
				if v:IsA("TextLabel") and matchColor(v.TextColor3) then
					v.TextColor3 = library.theme.TextSecondary
				end
			end
		end
	end)
	pcall(function()
		if props.ToggleOn then
			for _, t in pairs(library.registry.toggles) do
				if t.ColorFrame and t.Value == true then
					TweenService:Create(t.ColorFrame, TweenInfo.new(0.26), {BackgroundColor3 = library.theme.ToggleOn}):Play()
				end
			end
		end
	end)
	pcall(function()
		if props.ToggleOff then
			for _, t in pairs(library.registry.toggles) do
				if t.ColorFrame and t.Value == false then
					TweenService:Create(t.ColorFrame, TweenInfo.new(0.26), {BackgroundColor3 = library.theme.ToggleOff}):Play()
				end
			end
		end
	end)
	pcall(function()
		if props.SliderFill then
			for _, s in pairs(library.registry.sliders) do
				if s.obj6 then
					local obj7 = s.obj6:FindFirstChildOfClass("UIGradient")
					if obj7 then
						obj7.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.theme.SliderFill), ColorSequenceKeypoint.new(1, library.theme.SliderFill:lerp(Color3.new(0,0,0), 0.3))})
					end
				end
			end
		end
	end)
	pcall(function()
		if props.Accent or props.TextPrimary then
			for _, v in pairs(PCR_1:GetDescendants()) do
				if v.Name == "Watermark" and v:IsA("Frame") then
					local stroke = v:FindFirstChildOfClass("UIStroke")
					if stroke then stroke.Color = library.theme.Accent end
					local inner = v:FindFirstChild("WatermarkInner")
					if inner then
						local label = inner:FindFirstChildOfClass("TextLabel")
						if label then label.TextColor3 = library.theme.TextPrimary end
					end
				end
			end
		end
	end)
	pcall(function()
		for _, cp in pairs(library.registry.colorpickers) do
			if cp.ColourDisplay and library.theme[cp.textKey] then
				cp.ColourDisplay.ImageColor3 = library.theme[cp.textKey]
			end
		end
	end)
end

local notificationHolder = nil
local notifSpacing = 8

local function getNotifAnchor()
	local pos = library.theme.NotifPosition or "TopRight"
	if pos == "TopRight" then return Vector2.new(1, 0), UDim2.new(1, -12, 0, 12)
	elseif pos == "TopLeft" then return Vector2.new(0, 0), UDim2.new(0, 12, 0, 12)
	elseif pos == "BottomRight" then return Vector2.new(1, 1), UDim2.new(1, -12, 1, -12)
	elseif pos == "BottomLeft" then return Vector2.new(0, 1), UDim2.new(0, 12, 1, -12)
	end
end

function library:Notify(config)
	config = config or {}
	local title = config.title or "Notification"
	local text = config.text or ""
	local duration = config.duration or 4

	if not notificationHolder then
		notificationHolder = Instance.new("Frame")
		notificationHolder.Name = "NotificationHolder"
		notificationHolder.Parent = PCR_1
		notificationHolder.BackgroundTransparency = 1
		notificationHolder.BorderSizePixel = 0
		notificationHolder.Size = UDim2.new(0, 320, 1, 0)
		notificationHolder.ZIndex = 200
		local anchor, pos = getNotifAnchor()
		notificationHolder.AnchorPoint = anchor
		notificationHolder.Position = pos
	end

	local notif = Instance.new("Frame")
	notif.Name = "Notification"
	notif.Parent = notificationHolder
	notif.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
	notif.BorderSizePixel = 0
	notif.Size = UDim2.new(0, 280, 0, 0)
	notif.ZIndex = 201
	notif.ClipsDescendants = true

	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 6)
	notifCorner.Parent = notif

	local notifStroke = Instance.new("UIStroke")
	notifStroke.Color = Color3.fromRGB(255, 255, 255)
	notifStroke.Transparency = 0.92
	notifStroke.Thickness = 1
	notifStroke.Parent = notif

	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.Parent = notif
	accentBar.BackgroundColor3 = library.theme.Accent
	accentBar.BorderSizePixel = 0
	accentBar.Position = UDim2.new(0, 0, 0, 0)
	accentBar.Size = UDim2.new(0, 3, 0, 0)
	accentBar.ZIndex = 202

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Parent = notif
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Position = UDim2.new(0, 14, 0, 8)
	titleLabel.Size = UDim2.new(1, -22, 0, 18)
	titleLabel.ZIndex = 203
	titleLabel.Font = Enum.Font.SourceSansSemibold
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(215, 215, 215)
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Parent = notif
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.Position = UDim2.new(0, 14, 0, 26)
	textLabel.Size = UDim2.new(1, -22, 0, 14)
	textLabel.ZIndex = 203
	textLabel.Font = Enum.Font.SourceSans
	textLabel.Text = text
	textLabel.TextColor3 = Color3.fromRGB(150, 150, 155)
	textLabel.TextSize = 13
	textLabel.TextXAlignment = Enum.TextXAlignment.Left

	local contentH = text ~= "" and 48 or 34
	notif.Size = UDim2.new(0, 280, 0, contentH)
	accentBar.Size = UDim2.new(0, 3, 0, contentH)
	notif.BackgroundTransparency = 1
	if text == "" then
		titleLabel.Position = UDim2.new(0, 14, 0, 8)
		textLabel.Visible = false
	end

	local isBottom = library.theme.NotifPosition and library.theme.NotifPosition:find("Bottom")

	local function shiftAll()
		local y = 0
		local children = {}
		for _, child in pairs(notificationHolder:GetChildren()) do
			if child:IsA("Frame") then table.insert(children, child) end
		end
		if isBottom then
			for i = #children, 1, -1 do
				local child = children[i]
				local pos = UDim2.new(0, 0, 1, -(y + child.AbsoluteSize.Y))
				TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = pos}):Play()
				y = y + child.AbsoluteSize.Y + notifSpacing
			end
		else
			for _, child in pairs(children) do
				TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, y)}):Play()
				y = y + child.AbsoluteSize.Y + notifSpacing
			end
		end
	end

	notif.Position = isBottom and UDim2.new(0, 0, 1, 10) or UDim2.new(0, 0, 0, -contentH)
	shiftAll()

	TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	}):Play()
	TweenService:Create(accentBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 3, 0, contentH)
	}):Play()

	spawn(function()
		local elapsed = 0
		while notif.Parent do
			wait(0.1)
			elapsed = elapsed + 0.1
			if elapsed >= duration then
				TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1, Size = UDim2.new(0, 280, 0, 0)}):Play()
				TweenService:Create(accentBar, TweenInfo.new(0.25), {Size = UDim2.new(0, 3, 0, 0)}):Play()
				for _, v in pairs(notif:GetChildren()) do
					if v:IsA("TextLabel") then
						TweenService:Create(v, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
					end
				end
				wait(0.3)
				notif:Destroy()
				shiftAll()
				break
			end
		end
	end)
end

function library:SetNotifPosition(pos)
	library.theme.NotifPosition = pos
	if notificationHolder then
		local anchor, position = getNotifAnchor()
		notificationHolder.AnchorPoint = anchor
		TweenService:Create(notificationHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = position}):Play()
	end
end

function library:CreateSettings(winName)
	winName = winName or 'Settings'
	local win = library:AddWindow(winName)
	local sec = win:AddSection('Accent Color')
	sec:AddColorPallete('Accent Color', library.theme.Accent, function(c)
		library:UpdateTheme({Accent = c})
	end)
	local sec2 = win:AddSection('Notifications')
	sec2:AddDropdown('Position', {'TopRight','TopLeft','BottomRight','BottomLeft'}, library.theme.NotifPosition or 'TopRight', function(v)
		library:SetNotifPosition(v)
	end)
	sec2:AddButton('Test Notification', function()
		library:Notify({title = 'Test', text = 'This is a test notification', duration = 3})
	end)
	local sec3 = win:AddSection('GUI Toggle')
	sec3:AddKeyBind('Toggle GUI', Enum.KeyCode.RightControl, function()
		toggleGUI()
	end)
	sec3:AddButton('Toggle GUI', function()
		toggleGUI()
	end)
	sec3:AddSeparateBar()
	sec3:AddButton('Unload Script', function()
		PCR_1:Destroy()
		library = nil
	end)
	local sec4 = win:AddSection('Config Manager')
	library.ConfigManager:ApplyToGroupbox(sec4)
	return win
end

function library:SetDropdownOptions(name, newOptions)
	local dd = library.registry.dropdowns[name]
	if not dd or not dd.Frame then return end
	for _, v in pairs(dd.Frame:GetChildren()) do
		if v:IsA("TextButton") and v ~= dd.Toggle then
			v:Destroy()
		end
	end
	dd.Frame.Size = UDim2.new(0, 252, 0, 25)
	dd.Toggle.Visible = true
	for _, opt in pairs(newOptions) do
		local OPTION = Instance.new("TextButton")
		local _456fg_2 = Instance.new("UICorner")
		local TextLabel_3 = Instance.new("TextLabel")
		OPTION.Name = "OPTION"
		OPTION.Parent = dd.Frame
		OPTION.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
		OPTION.BorderSizePixel = 0
		OPTION.ClipsDescendants = true
		OPTION.Size = UDim2.new(0, 233, 0, 16)
		OPTION.ZIndex = 29
		OPTION.AutoButtonColor = false
		OPTION.Font = Enum.Font.SourceSansSemibold
		OPTION.Text = ""
		OPTION.TextColor3 = Color3.fromRGB(255, 255, 255)
		OPTION.TextSize = 16
		_456fg_2.CornerRadius = UDim.new(0, 4)
		_456fg_2.Name = "456fg"
		_456fg_2.Parent = OPTION
		TextLabel_3.Parent = OPTION
		TextLabel_3.AnchorPoint = Vector2.new(0.5, 0.5)
		TextLabel_3.BackgroundTransparency = 1
		TextLabel_3.BorderSizePixel = 0
		TextLabel_3.Position = UDim2.new(0.5, 0, 0.5, 0)
		TextLabel_3.Size = UDim2.new(0, 125, 0, 15)
		TextLabel_3.Font = Enum.Font.SourceSansSemibold
		TextLabel_3.Text = opt
		TextLabel_3.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel_3.TextSize = 15
		OPTION.MouseButton1Click:Connect(function()
			for _, v in pairs(dd.Frame:GetChildren()) do
				if v:IsA("TextButton") and v ~= dd.Toggle then
					TweenService:Create(v, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(37, 37, 37)}):Play()
				end
			end
			dd.Value = opt
			local titleLabel = dd.Toggle:FindFirstChildOfClass("TextLabel")
			if titleLabel then titleLabel.Text = opt end
			TweenService:Create(OPTION, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
		end)
	end
end

library.registry = {toggles = {}, sliders = {}, dropdowns = {}, textboxes = {}, colorpickers = {}, keybindsList = {}}
local guiVisible = true
local guiToggleKey = Enum.KeyCode.RightControl

local function toggleGUI()
	guiVisible = not guiVisible
	if guiVisible then
		MAIN.Visible = true
		MAIN.BackgroundTransparency = 1
		TweenService:Create(MAIN, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0
		}):Play()
	else
		TweenService:Create(MAIN, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			BackgroundTransparency = 1
		}):Play()
		task.delay(0.25, function()
			MAIN.Visible = false
			MAIN.BackgroundTransparency = 0
		end)
	end
end

function library:SetGUIToggleKey(key)
	guiToggleKey = key
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == guiToggleKey then
		toggleGUI()
	end
end)

-- ConfigManager addon --
library.ConfigManager = {} do
	local CM = library.ConfigManager
	CM.Folder = "PlagueUI_Settings"

	function CM:Save(name)
		if not name or name:gsub(" ", "") == "" then return end
		if not isfolder(CM.Folder .. "/settings") then makefolder(CM.Folder .. "/settings") end
		local data = {toggles = {}, sliders = {}, dropdowns = {}, textboxes = {}}
		for k, v in pairs(library.registry.toggles) do
			data.toggles[k] = v.Value
		end
		for k, v in pairs(library.registry.sliders) do
			data.sliders[k] = v.Value
		end
		for k, v in pairs(library.registry.dropdowns) do
			data.dropdowns[k] = v.Value
		end
		for k, v in pairs(library.registry.textboxes) do
			data.textboxes[k] = v.obj5.Text
		end
		writefile(CM.Folder .. "/settings/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(data))
		library:Notify({title = "Config", text = "Saved " .. name, duration = 2})
	end

	function CM:Load(name)
		local path = CM.Folder .. "/settings/" .. name
		if not isfile(path) then return end
		local _, data = pcall(game:GetService("HttpService").JSONDecode, game:GetService("HttpService"), readfile(path))
		if not data then return end
		if data.toggles then
			for k, v in pairs(data.toggles) do
				if library.registry.toggles[k] then
					library.registry.toggles[k]:UpdateValue(v)
				end
			end
		end
		if data.sliders then
			for k, v in pairs(data.sliders) do
				-- Apply slider values
			end
		end
		library:Notify({title = "Config", text = "Loaded " .. name, duration = 2})
	end

	function CM:GetConfigList()
		if not isfolder(CM.Folder .. "/settings") then return {} end
		local list = listfiles(CM.Folder .. "/settings")
		local out = {}
		for _, file in pairs(list) do
			if file:sub(-5) == ".json" then
				local name = file:match("([^/\\]+)%.json$")
				if name then table.insert(out, name) end
			end
		end
		return out
	end

	function CM:ApplyToGroupbox(section)
		section:AddTextBox("Config Name", "Enter name", false, 5, function() end)
		section:AddButton("Create Config", function()
			local tb = library.registry.textboxes["Config Name"]
			local name = tb and tb.obj5.Text or "Config"
			if name and name ~= "" then
				CM:Save(name)
				local list = CM:GetConfigList()
				library:SetDropdownOptions("Config List", list)
				library.registry.dropdowns["Config List"].Value = name
			end
		end)
		section:AddSeparateBar()
		section:AddDropdown("Config List", CM:GetConfigList(), nil, function(v) end)
		section:AddButton("Load Selected", function()
			local dd = library.registry.dropdowns["Config List"]
			if dd and dd.Value then
				CM:Load(dd.Value .. ".json")
			end
		end)
		section:AddSeparateBar()
		local autoloadLabel = section:AddLabel("No autoload set")
		local function refreshAutoloadLabel()
			if isfile(CM.Folder .. "/settings/autoload.txt") then
				autoloadLabel.Text = "Autoload: " .. readfile(CM.Folder .. "/settings/autoload.txt")
			else
				autoloadLabel.Text = "No autoload set"
			end
		end
		refreshAutoloadLabel()
		section:AddButton("Set Autoload", function()
			local dd = library.registry.dropdowns["Config List"]
			if dd and dd.Value then
				writefile(CM.Folder .. "/settings/autoload.txt", dd.Value)
				library:Notify({title = "Config", text = "Autoload set to " .. dd.Value, duration = 2})
				refreshAutoloadLabel()
			end
		end)
		section:AddButton("Remove Autoload", function()
			local path = CM.Folder .. "/settings/autoload.txt"
			if isfile(path) then delfile(path)
				library:Notify({title = "Config", text = "Autoload removed", duration = 2})
				refreshAutoloadLabel()
			end
		end)
	end
end

spawn(function()
	wait(1)
	if isfile(CM.Folder .. "/settings/autoload.txt") then
		local name = readfile(CM.Folder .. "/settings/autoload.txt")
		CM:Load(name .. ".json")
	end
end)

library.GUI = PCR_1

return library
