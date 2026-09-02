--[[
	InventoryUIController.client.lua
	Bouton "🎒 Inventaire" qui liste les objets pas encore placés dans la
	Chambre Rétro, avec un bouton "Placer" sur chacun. Demande la liste
	au serveur (GetInventory) à chaque ouverture du panneau.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getInventoryRemote = remotes:WaitForChild("GetInventory")
local placeItemRemote = remotes:WaitForChild("PlaceItem")

-- === Construction de l'interface ===

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local invButton = Instance.new("TextButton")
invButton.Name = "InventoryButton"
invButton.Size = UDim2.new(0, 140, 0, 50)
invButton.Position = UDim2.new(0, 300, 0, 20)
invButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
invButton.Text = "🎒 Inventaire"
invButton.TextColor3 = Color3.new(1, 1, 1)
invButton.TextScaled = true
invButton.Font = Enum.Font.GothamBold
invButton.Parent = screenGui

local invButtonCorner = Instance.new("UICorner")
invButtonCorner.CornerRadius = UDim.new(0, 10)
invButtonCorner.Parent = invButton

local invPanel = Instance.new("ScrollingFrame")
invPanel.Name = "InventoryPanel"
invPanel.Size = UDim2.new(0, 300, 0, 360)
invPanel.Position = UDim2.new(0, 300, 0, 80)
invPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
invPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
invPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
invPanel.ScrollBarThickness = 6
invPanel.Visible = false
invPanel.Parent = screenGui

local invPanelCorner = Instance.new("UICorner")
invPanelCorner.CornerRadius = UDim.new(0, 16)
invPanelCorner.Parent = invPanel

local invPadding = Instance.new("UIPadding")
invPadding.PaddingTop = UDim.new(0, 10)
invPadding.PaddingLeft = UDim.new(0, 10)
invPadding.PaddingRight = UDim.new(0, 10)
invPadding.Parent = invPanel

local invListLayout = Instance.new("UIListLayout")
invListLayout.Padding = UDim.new(0, 6)
invListLayout.SortOrder = Enum.SortOrder.LayoutOrder
invListLayout.Parent = invPanel

local RARITY_COLORS = {
	Commun = Color3.fromRGB(176, 176, 176),
	Rare = Color3.fromRGB(85, 170, 255),
	Epique = Color3.fromRGB(170, 85, 255),
	Legendaire = Color3.fromRGB(255, 170, 0),
	Viral = Color3.fromRGB(255, 0, 128),
}

local function clearPanel()
	for _, child in ipairs(invPanel:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function refreshPanel()
	local inventory = getInventoryRemote:InvokeServer()

	clearPanel()

	if #inventory == 0 then
		local empty = Instance.new("Frame")
		empty.Size = UDim2.new(1, 0, 0, 50)
		empty.BackgroundTransparency = 1
		empty.Parent = invPanel

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
		label.Font = Enum.Font.Gotham
		label.TextScaled = true
		label.Text = "Inventaire vide — ouvre des capsules !"
		label.Parent = empty
		return
	end

	for index, item in ipairs(inventory) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 50)
		row.BackgroundColor3 = RARITY_COLORS[item.Rarity] or Color3.fromRGB(150, 150, 150)
		row.Parent = invPanel

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 8)
		rowCorner.Parent = row

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.65, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextScaled = true
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = "  " .. item.Name
		nameLabel.Parent = row

		local placeButton = Instance.new("TextButton")
		placeButton.Size = UDim2.new(0.35, -6, 1, -10)
		placeButton.Position = UDim2.new(0.65, 0, 0, 5)
		placeButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		placeButton.TextColor3 = Color3.new(1, 1, 1)
		placeButton.Font = Enum.Font.GothamBold
		placeButton.TextScaled = true
		placeButton.Text = "Placer"
		placeButton.Parent = row

		local placeButtonCorner = Instance.new("UICorner")
		placeButtonCorner.CornerRadius = UDim.new(0, 8)
		placeButtonCorner.Parent = placeButton

		placeButton.MouseButton1Click:Connect(function()
			placeItemRemote:FireServer(index)
			-- On redemande la liste juste après : le serveur a eu le temps
			-- de traiter l'événement avant que ce callback ne s'exécute.
			task.wait(0.2)
			refreshPanel()
		end)
	end
end

invButton.MouseButton1Click:Connect(function()
	invPanel.Visible = not invPanel.Visible
	if invPanel.Visible then
		refreshPanel()
	end
end)
