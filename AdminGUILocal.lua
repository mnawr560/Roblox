https://raw.githubusercontent.com/mnawr560/Roblox/main/AdminGUILocal.lua
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()

-- ========== واجهة المستخدم (UI) ==========
local gui = Instance.new("ScreenGui")
gui.Name = "AdminGUI"
gui.Parent = player:WaitForChild("PlayerGui")

-- الإطار الرئيسي (قابل للسحب)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 300)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

-- شريط العنوان
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Admin Panel"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- زر الإغلاق
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

-- منطقة الأوامر scrollable
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0.02, 0, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 320)
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = scrollFrame
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ========== أوامر الإدارة ==========
local function createButton(name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.Text = name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BorderSizePixel = 0
	btn.Parent = scrollFrame
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- توصيف محلي للطيران والحركات
local flying = false
local flyBodyGyro, flyBodyVelocity
local noclip = false
local noclipConnection

local character = player.Character
player.CharacterAdded:Connect(function(char)
	character = char
	flying = false -- إيقاف الطيران عند تبديل الشخصية
	noclip = false
end)

-- 1. الطيران
createButton("✈️ تفعيل الطيران", function()
	if not character then return end
	flying = not flying
	if flying then
		-- إنشاء جسم طيران
		flyBodyGyro = Instance.new("BodyGyro")
		flyBodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 400000
		flyBodyGyro.Parent = character.HumanoidRootPart

		flyBodyVelocity = Instance.new("BodyVelocity")
		flyBodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 4000
		flyBodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
		flyBodyVelocity.Parent = character.HumanoidRootPart

		game:GetService("RunService").Heartbeat:Connect(function()
			if flying and flyBodyVelocity and flyBodyGyro then
				-- التحكم بالاتجاه حسب الكاميرا
				local cam = workspace.CurrentCamera
				flyBodyGyro.CFrame = cam.CFrame

				local moveDir = Vector3.new()
				if require(player.PlayerScripts:WaitForChild("PlayerModule")):GetMouse() then
					-- باستخدام مدخلات اللاعب
					local humanoid = character.Humanoid
					local move = humanoid.MoveDirection
					moveDir = cam.CFrame:VectorToWorldSpace(Vector3.new(move.X, 0, move.Y))
				end

				local speed = 50
				local up = 0
				if mouse.KeyDown:FindFirstChild("Space") then up = speed end
				if mouse.KeyDown:FindFirstChild("LeftShift") then up = -speed end

				flyBodyVelocity.Velocity = moveDir * speed + Vector3.new(0, up, 0)
			end
		end)
	else
		if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
		if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
	end
end)

-- 2. زيادة السرعة
createButton("🏃 سرعة 50", function()
	if character and character.Humanoid then
		character.Humanoid.WalkSpeed = 50
	end
end)

-- 3. قفزة عالية
createButton("🦘 قفزة 100", function()
	if character and character.Humanoid then
		character.Humanoid.JumpPower = 100
	end
end)

-- 4. إعادة الضبط
createButton("🔄 إعادة الضبط", function()
	if character and character.Humanoid then
		character.Humanoid.WalkSpeed = 16
		character.Humanoid.JumpPower = 50
	end
end)

-- 5. الدخول في الجدران (NoClip)
createButton("👻 NoClip", function()
	if not character then return end
	noclip = not noclip
	if noclip then
		noclipConnection = game:GetService("RunService").Stepped:Connect(function()
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end
	end
end)

-- 6. إصلاح الشخصية
createButton("💚 إصلاح كامل", function()
	if character and character.Humanoid then
		character.Humanoid.Health = character.Humanoid.MaxHealth
		character.Humanoid.Sit = false
	end
end)

-- 7. جعل الوقت ليل (تأثير محلي)
createButton("🌙 ليل", function()
	game.Lighting.ClockTime = 0
end)

-- 8. جعل الوقت نهار
createButton("☀️ نهار", function()
	game.Lighting.ClockTime = 12
end)

-- إخفاء وإظهار المنيو بزر الإغلاق
closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

-- اختصاري: زر C لإعادة إظهار المنيو
mouse.KeyDown:Connect(function(key)
	if key == "c" then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

print("✅ Admin GUI تحميل بنجاح. اضغط C لإظهار/إخفاء المنيو.")
