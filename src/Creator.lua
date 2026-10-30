local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Root = script.Parent
local Themes = require(Root.Themes)
local Flipper = require(Root.Packages.Flipper)

local Creator = {
	Registry = {},
	Signals = {},
	TransparencyMotors = {},
	TooltipHolder = nil,
	TooltipLabel = nil,
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ScrollingFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ScrollBarImageColor3 = Color3.new(0, 0, 0),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			TextSize = 14,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
		},
		CanvasGroup = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
	},
}

local function ApplyCustomProps(Object, Props)
	if Props.ThemeTag then
		Creator.AddThemeObject(Object, Props.ThemeTag)
	end
end

function Creator.AddSignal(Signal, Function)
	table.insert(Creator.Signals, Signal:Connect(Function))
end

function Creator.Disconnect()
	for Idx = #Creator.Signals, 1, -1 do
		local Connection = table.remove(Creator.Signals, Idx)
		Connection:Disconnect()
	end
end

function Creator.GetThemeProperty(Property)
	if Themes[require(Root).Theme][Property] then
		return Themes[require(Root).Theme][Property]
	end
	return Themes["Dark"][Property]
end

function Creator.UpdateTheme()
	for Instance, Object in next, Creator.Registry do
		for Property, ColorIdx in next, Object.Properties do
			Instance[Property] = Creator.GetThemeProperty(ColorIdx)
		end
	end

	for _, Motor in next, Creator.TransparencyMotors do
		Motor:setGoal(Flipper.Instant.new(Creator.GetThemeProperty("ElementTransparency")))
	end
end

function Creator.AddThemeObject(Object, Properties)
	local Idx = #Creator.Registry + 1
	local Data = {
		Object = Object,
		Properties = Properties,
		Idx = Idx,
	}

	Creator.Registry[Object] = Data
	Creator.UpdateTheme()
	return Object
end

function Creator.OverrideTag(Object, Properties)
	Creator.Registry[Object].Properties = Properties
	Creator.UpdateTheme()
end

function Creator.New(Name, Properties, Children)
	local Object = Instance.new(Name)

	-- Default properties
	for Name, Value in next, Creator.DefaultProperties[Name] or {} do
		Object[Name] = Value
	end

	-- Properties
	for Name, Value in next, Properties or {} do
		if Name ~= "ThemeTag" then
			Object[Name] = Value
		end
	end

	-- Children
	for _, Child in next, Children or {} do
		Child.Parent = Object
	end

	ApplyCustomProps(Object, Properties)
	return Object
end

function Creator.SetupTooltip(ScreenGui)
	local TooltipLabel = Creator.New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		TextSize = 12,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeTag = {
			TextColor3 = "Text",
			BackgroundColor3 = "DropdownHolder",
		},
	}, {
		Creator.New("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		Creator.New("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
		}),
		Creator.New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = 0.5,
			ThemeTag = {
				Color = "ElementBorder",
			},
		}),
	})

	local TooltipHolder = Creator.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		Parent = ScreenGui,
		Visible = false,
		ZIndex = 1000,
	}, {
		Creator.New("UISizeConstraint", {
			MaxSize = Vector2.new(250, math.huge),
		}),
		TooltipLabel,
	})

	Creator.TooltipHolder = TooltipHolder
	Creator.TooltipLabel = TooltipLabel

	local Mouse = Players.LocalPlayer:GetMouse()
	RunService.RenderStepped:Connect(function()
		if TooltipHolder.Visible then
			local mouseX = Mouse.X + 12
			local mouseY = Mouse.Y + 12
			local viewportSize = workspace.CurrentCamera.ViewportSize

			if mouseX + TooltipHolder.AbsoluteSize.X > viewportSize.X then
				mouseX = Mouse.X - TooltipHolder.AbsoluteSize.X - 4
			end
			if mouseY + TooltipHolder.AbsoluteSize.Y > viewportSize.Y then
				mouseY = Mouse.Y - TooltipHolder.AbsoluteSize.Y - 4
			end

			TooltipHolder.Position = UDim2.fromOffset(mouseX, mouseY)
		end
	end)
end

function Creator.ShowTooltip(Text)
	if Creator.TooltipHolder and Text and Text ~= "" then
		Creator.TooltipLabel.Text = Text
		Creator.TooltipHolder.Visible = true
	end
end

function Creator.HideTooltip()
	if Creator.TooltipHolder then
		Creator.TooltipHolder.Visible = false
	end
end

function Creator.SpringMotor(Initial, Instance, Prop, IgnoreDialogCheck, ResetOnThemeChange)
	IgnoreDialogCheck = IgnoreDialogCheck or false
	ResetOnThemeChange = ResetOnThemeChange or false
	local Motor = Flipper.SingleMotor.new(Initial)
	Motor:onStep(function(value)
		Instance[Prop] = value
	end)

	if ResetOnThemeChange then
		table.insert(Creator.TransparencyMotors, Motor)
	end

	local function SetValue(Value, Ignore)
		Ignore = Ignore or false
		if not IgnoreDialogCheck then
			if not Ignore then
				if Prop == "BackgroundTransparency" and require(Root).DialogOpen then
					return
				end
			end
		end
		Motor:setGoal(Flipper.Spring.new(Value, { frequency = 8 }))
	end

	return Motor, SetValue
end

return Creator
