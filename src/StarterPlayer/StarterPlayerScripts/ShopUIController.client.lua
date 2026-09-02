--[[
	ShopUIController.client.lua
	Petit menu boutique : un bouton "🛒 Boutique" ouvre un panneau avec les
	Game Passes et Developer Products. Cliquer ouvre directement la
	fenêtre d'achat officielle de Roblox (MarketplaceService s'en charge).
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConfig = require(ReplicatedStorage.Modules.MonetizationConfig)

local player = Players.LocalPlayer

-- === Construction de l'interface ===

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShopUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local shopButton = Instance.new("TextButton")
shopButton.Name = "ShopButton"
shopButton.Size = UDim2.new(0, 140, 0, 50)
shopButton.Position = UDim2.new(0, 20, 0, 20)
shopButton.BackgroundColor3 = Color3.fromRGB(0, 190, 120)
shopButton.Text = "🛒 Boutique"
shopButton.TextColor3 = Color3.new(1, 1, 1)
shopButton.TextScaled = true
shopButton.Font = Enum.Font.GothamBold
shopButton.Parent = screenGui

local shopButtonCorner = Instance.new("UICorner")
shopButtonCorner.CornerRadius = UDim.new(0, 10)
shopButtonCorner.Parent = shopButton

local shopPanel = Instance.new("Frame")
shopPanel.Name = "ShopPanel"
shopPanel.Size = UDim2.new(0, 260, 0, 340)
shopPanel.Position = UDim2.new(0, 20, 0, 80)
shopPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
shopPanel.Visible = false
shopPanel.Parent = screenGui

local shopPanelCorner = Instance.new("UICorner")
shopPanelCorner.CornerRadius = UDim.new(0, 16)
shopPanelCorner.Parent = shopPanel

local shopPadding = Instance.new("UIPadding")
shopPadding.PaddingTop = UDim.new(0, 10)
shopPadding.PaddingLeft = UDim.new(0, 10)
shopPadding.PaddingRight = UDim.new(0, 10)
shopPadding.Parent = shopPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = shopPanel

shopButton.MouseButton1Click:Connect(function()
	shopPanel.Visible = not shopPanel.Visible
end)

local function addShopButton(text, color, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 50)
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.Text = text
	btn.Parent = shopPanel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(onClick)
	return btn
end

-- === Game Passes ===

local PINK = Color3.fromRGB(255, 0, 128)
local GOLD = Color3.fromRGB(255, 170, 0)

addShopButton("💰 2x Vues", PINK, function()
	MarketplaceService:PromptGamePassPurchase(player, MonetizationConfig.GamePasses.DoubleCash)
end)

addShopButton("🍀 2x Chance", PINK, function()
	MarketplaceService:PromptGamePassPurchase(player, MonetizationConfig.GamePasses.DoubleLuck)
end)

addShopButton("🏠 +6 Slots Chambre", PINK, function()
	MarketplaceService:PromptGamePassPurchase(player, MonetizationConfig.GamePasses.ExtraRoomSlot)
end)

-- === Developer Products ===

addShopButton("🕹️ Capsule Premium", GOLD, function()
	MarketplaceService:PromptProductPurchase(player, MonetizationConfig.DeveloperProducts.PremiumCapsule)
end)

addShopButton("✨ Capsule Garantie Légendaire", GOLD, function()
	MarketplaceService:PromptProductPurchase(player, MonetizationConfig.DeveloperProducts.GuaranteedLegendary)
end)
