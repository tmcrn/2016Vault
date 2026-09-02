--[[
	RoomVisualService.lua
	Construit une Chambre Rétro en 3D pour chaque joueur (une pièce
	perso, décalée dans le Workspace pour ne pas se superposer) et
	l'actualise à chaque fois qu'un objet est placé/retiré. RoomService
	gère les données ; ce fichier gère uniquement ce qu'on voit.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CapsuleConfig = require(ReplicatedStorage.Modules.CapsuleConfig)

local RoomVisualService = {}

local ROOM_SIZE = 40 -- studs, chambre carrée
local ROOM_STEP = ROOM_SIZE + 20 -- + espace entre deux chambres

local roomsFolder = Instance.new("Folder")
roomsFolder.Name = "PlayerRooms"
roomsFolder.Parent = Workspace

local playerRooms = {} -- [player] = { PedestalsFolder, Origin }
local nextRoomIndex = 0

-- Construit les murs/sol/spawn d'une chambre vide à l'index donné.
-- 100% synchrone (aucun `wait`) pour pouvoir fixer le spawn du joueur
-- avant que son personnage n'apparaisse.
local function buildRoomShell(index)
	local origin = Vector3.new(index * ROOM_STEP, 0, 0)

	local room = Instance.new("Model")
	room.Name = "Room"

	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(ROOM_SIZE, 1, ROOM_SIZE)
	floor.Position = origin
	floor.Anchored = true
	floor.Material = Enum.Material.WoodPlanks
	floor.Color = Color3.fromRGB(196, 164, 132)
	floor.Parent = room

	local half = ROOM_SIZE / 2
	local function wall(offsetX, offsetZ, sizeX, sizeZ)
		local w = Instance.new("Part")
		w.Size = Vector3.new(sizeX, 12, sizeZ)
		w.Anchored = true
		w.Material = Enum.Material.Neon
		w.Color = Color3.fromRGB(255, 0, 128)
		w.Transparency = 0.85
		w.Position = origin + Vector3.new(offsetX, 6.5, offsetZ)
		w.Parent = room
	end
	wall(0, -half, ROOM_SIZE, 1)
	wall(0, half, ROOM_SIZE, 1)
	wall(-half, 0, 1, ROOM_SIZE)
	wall(half, 0, 1, ROOM_SIZE)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "RoomSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = origin + Vector3.new(0, 1, half - 4)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Transparency = 1
	spawn.Parent = room

	local pedestalsFolder = Instance.new("Folder")
	pedestalsFolder.Name = "Pedestals"
	pedestalsFolder.Parent = room

	room.Parent = roomsFolder

	return pedestalsFolder, spawn, origin
end

--[[
	Crée la chambre d'un joueur et le fait spawn dedans. À appeler dans
	Players.PlayerAdded, AVANT tout `wait`/DataStore (voir Main.server.lua)
	pour que le spawn soit prêt avant l'apparition du personnage.
]]
function RoomVisualService.CreateRoomFor(player)
	local index = nextRoomIndex
	nextRoomIndex += 1

	local pedestalsFolder, spawn, origin = buildRoomShell(index)
	spawn.Parent.Name = player.Name .. "_Room"

	playerRooms[player] = {
		PedestalsFolder = pedestalsFolder,
		Origin = origin,
	}

	player.RespawnLocation = spawn
end

function RoomVisualService.DestroyRoomFor(player)
	local entry = playerRooms[player]
	if entry and entry.PedestalsFolder and entry.PedestalsFolder.Parent then
		entry.PedestalsFolder.Parent:Destroy()
	end
	playerRooms[player] = nil
end

-- Grille 4 colonnes pour poser les socles à l'intérieur de la chambre.
local COLUMNS = 4
local SPACING = 6

local function pedestalPosition(origin, slotIndex)
	local col = slotIndex % COLUMNS
	local row = math.floor(slotIndex / COLUMNS)
	local startX = -(COLUMNS - 1) * SPACING / 2
	return origin + Vector3.new(startX + col * SPACING, 0.5, -6 - row * SPACING)
end

local function findRarityColor(rarityId)
	for _, rarity in ipairs(CapsuleConfig.Rarities) do
		if rarity.Id == rarityId then
			return rarity.Color
		end
	end
	return Color3.fromRGB(200, 200, 200)
end

--[[
	Redessine tous les socles d'un joueur à partir de sa Chambre Rétro
	(`roomItems` = liste de {Name=, Rarity=}, dans DataService).
]]
function RoomVisualService.Refresh(player, roomItems)
	local entry = playerRooms[player]
	if not entry then
		return
	end

	entry.PedestalsFolder:ClearAllChildren()

	for slotIndex, item in ipairs(roomItems) do
		local color = findRarityColor(item.Rarity)
		local position = pedestalPosition(entry.Origin, slotIndex - 1)

		local pedestal = Instance.new("Part")
		pedestal.Name = "Pedestal"
		pedestal.Size = Vector3.new(2, 1, 2)
		pedestal.Anchored = true
		pedestal.Material = Enum.Material.Marble
		pedestal.Color = Color3.fromRGB(230, 230, 230)
		pedestal.Position = position
		pedestal.Parent = entry.PedestalsFolder

		local itemGlow = Instance.new("Part")
		itemGlow.Name = "Item"
		itemGlow.Shape = Enum.PartType.Ball
		itemGlow.Size = Vector3.new(1.5, 1.5, 1.5)
		itemGlow.Anchored = true
		itemGlow.Material = Enum.Material.Neon
		itemGlow.Color = color
		itemGlow.Position = position + Vector3.new(0, 1.5, 0)
		itemGlow.Parent = entry.PedestalsFolder

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 140, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 1.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = itemGlow
		billboard.Parent = itemGlow

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = color
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Text = item.Name
		label.Parent = billboard
	end
end

Players.PlayerRemoving:Connect(function(player)
	RoomVisualService.DestroyRoomFor(player)
end)

return RoomVisualService
