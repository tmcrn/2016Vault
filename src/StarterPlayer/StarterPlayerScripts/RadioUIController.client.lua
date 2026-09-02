--[[
	RadioUIController.client.lua
	Bouton "📻 Radio" qui liste les pistes de RadioConfig, avec un
	Play/Stop par piste. Lecture 100% locale (SoundService) : seul le
	joueur qui clique entend sa radio, pas besoin de la synchroniser
	avec le serveur pour une chambre personnelle.
]]

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RadioConfig = require(ReplicatedStorage.Modules.RadioConfig)

local player = Players.LocalPlayer

-- === Le lecteur audio (un seul Sound réutilisé pour toutes les pistes) ===

local sound = Instance.new("Sound")
sound.Name = "RadioSound"
sound.Volume = RadioConfig.Volume
sound.Looped = true
sound.Parent = SoundService

local currentTrackIndex = nil

-- === Construction de l'interface ===

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RadioUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local radioButton = Instance.new("TextButton")
radioButton.Name = "RadioButton"
radioButton.Size = UDim2.new(0, 140, 0, 50)
radioButton.Position = UDim2.new(0, 440, 0, 20)
radioButton.BackgroundColor3 = Color3.fromRGB(150, 60, 220)
radioButton.Text = "📻 Radio"
radioButton.TextColor3 = Color3.new(1, 1, 1)
radioButton.TextScaled = true
radioButton.Font = Enum.Font.GothamBold
radioButton.Parent = screenGui

local radioButtonCorner = Instance.new("UICorner")
radioButtonCorner.CornerRadius = UDim.new(0, 10)
radioButtonCorner.Parent = radioButton

local radioPanel = Instance.new("Frame")
radioPanel.Name = "RadioPanel"
radioPanel.Size = UDim2.new(0, 260, 0, 220)
radioPanel.Position = UDim2.new(0, 440, 0, 80)
radioPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
radioPanel.Visible = false
radioPanel.Parent = screenGui

local radioPanelCorner = Instance.new("UICorner")
radioPanelCorner.CornerRadius = UDim.new(0, 16)
radioPanelCorner.Parent = radioPanel

local radioPadding = Instance.new("UIPadding")
radioPadding.PaddingTop = UDim.new(0, 10)
radioPadding.PaddingLeft = UDim.new(0, 10)
radioPadding.PaddingRight = UDim.new(0, 10)
radioPadding.Parent = radioPanel

local radioListLayout = Instance.new("UIListLayout")
radioListLayout.Padding = UDim.new(0, 6)
radioListLayout.SortOrder = Enum.SortOrder.LayoutOrder
radioListLayout.Parent = radioPanel

radioButton.MouseButton1Click:Connect(function()
	radioPanel.Visible = not radioPanel.Visible
end)

-- Redessine la liste pour que le bouton de la piste en cours affiche "⏸ Stop".
local trackButtons = {}

local function refreshButtonLabels()
	for index, btn in pairs(trackButtons) do
		local track = RadioConfig.Tracks[index]
		if currentTrackIndex == index then
			btn.Text = "⏸ " .. track.Name
		else
			btn.Text = "▶ " .. track.Name
		end
	end
end

for index, track in ipairs(RadioConfig.Tracks) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 45)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.Text = "▶ " .. track.Name
	btn.Parent = radioPanel

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	trackButtons[index] = btn

	btn.MouseButton1Click:Connect(function()
		if track.SoundId == 0 then
			btn.Text = "❌ Pas encore configurée"
			task.delay(1.5, refreshButtonLabels)
			return
		end

		if currentTrackIndex == index then
			-- Cette piste jouait déjà : on l'arrête.
			sound:Stop()
			currentTrackIndex = nil
		else
			sound.SoundId = "rbxassetid://" .. tostring(track.SoundId)
			sound:Play()
			currentTrackIndex = index
		end
		refreshButtonLabels()
	end)
end
