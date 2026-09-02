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

-- Palmier procédural (tronc + palmes), pas d'asset externe nécessaire.
local function buildPalmTree(position, room)
	local trunk = Instance.new("Part")
	trunk.Name = "PalmTrunk"
	trunk.Shape = Enum.PartType.Cylinder
	trunk.Size = Vector3.new(8, 1, 1)
	trunk.Orientation = Vector3.new(0, 0, 90)
	trunk.Position = position + Vector3.new(0, 4, 0)
	trunk.Anchored = true
	trunk.Material = Enum.Material.Wood
	trunk.Color = Color3.fromRGB(120, 80, 50)
	trunk.Parent = room

	for i = 1, 6 do
		local leaf = Instance.new("Part")
		leaf.Name = "PalmLeaf"
		leaf.Size = Vector3.new(0.4, 0.4, 5)
		leaf.Anchored = true
		leaf.Material = Enum.Material.Grass
		leaf.Color = Color3.fromRGB(60, 180, 90)
		leaf.CFrame = CFrame.new(position + Vector3.new(0, 8, 0))
			* CFrame.Angles(0, math.rad(i * 60), math.rad(35))
			* CFrame.new(0, 0, -2.5)
		leaf.Parent = room
	end
end

-- Petite pluie de paillettes façon Tumblr, au-dessus du tapis central.
local function buildSparkles(position, room)
	local emitterPart = Instance.new("Part")
	emitterPart.Name = "SparkleEmitter"
	emitterPart.Size = Vector3.new(1, 1, 1)
	emitterPart.Position = position + Vector3.new(0, 10, 0)
	emitterPart.Anchored = true
	emitterPart.CanCollide = false
	emitterPart.Transparency = 1
	emitterPart.Parent = room

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 200, 230))
	emitter.Size = NumberSequence.new(0.25)
	emitter.Lifetime = NumberRange.new(3, 5)
	emitter.Rate = 6
	emitter.Speed = NumberRange.new(1, 2)
	emitter.SpreadAngle = Vector2.new(60, 60)
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Parent = emitterPart
end

-- Construit les murs/sol/spawn/décor d'une chambre vide à l'index donné.
-- 100% synchrone (aucun `wait`) pour pouvoir fixer le spawn du joueur
-- avant que son personnage n'apparaisse.
local function buildRoomShell(index, playerName)
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

	-- Murs néon : alternance rose/violet pour l'ambiance coucher de soleil.
	local wallColors = { Color3.fromRGB(255, 0, 128), Color3.fromRGB(150, 60, 220) }
	local wallIndex = 0
	local function wall(offsetX, offsetZ, sizeX, sizeZ)
		wallIndex += 1
		local w = Instance.new("Part")
		w.Size = Vector3.new(sizeX, 12, sizeZ)
		w.Anchored = true
		w.Material = Enum.Material.Neon
		w.Color = wallColors[(wallIndex % 2) + 1]
		w.Transparency = 0.8
		w.Position = origin + Vector3.new(offsetX, 6.5, offsetZ)
		w.Parent = room
	end
	wall(0, -half, ROOM_SIZE, 1)
	wall(0, half, ROOM_SIZE, 1)
	wall(-half, 0, 1, ROOM_SIZE)
	wall(half, 0, 1, ROOM_SIZE)

	-- Tapis central + palmiers dans deux coins + paillettes.
	local rug = Instance.new("Part")
	rug.Name = "Rug"
	rug.Size = Vector3.new(14, 0.2, 14)
	rug.Position = origin + Vector3.new(0, 1.1, 0)
	rug.Anchored = true
	rug.Material = Enum.Material.Fabric
	rug.Color = Color3.fromRGB(255, 190, 210)
	rug.Parent = room

	buildPalmTree(origin + Vector3.new(-half + 4, 1, -half + 4), room)
	buildPalmTree(origin + Vector3.new(half - 4, 1, -half + 4), room)
	buildSparkles(origin, room)

	-- Néon flottant avec le pseudo du joueur au-dessus de l'entrée.
	local signPart = Instance.new("Part")
	signPart.Name = "NameSign"
	signPart.Size = Vector3.new(1, 1, 1)
	signPart.Position = origin + Vector3.new(0, 11, half - 1)
	signPart.Anchored = true
	signPart.CanCollide = false
	signPart.Transparency = 1
	signPart.Parent = room

	local signBillboard = Instance.new("BillboardGui")
	signBillboard.Size = UDim2.new(0, 260, 0, 50)
	signBillboard.AlwaysOnTop = true
	signBillboard.Adornee = signPart
	signBillboard.Parent = signPart

	local signLabel = Instance.new("TextLabel")
	signLabel.Size = UDim2.new(1, 0, 1, 0)
	signLabel.BackgroundTransparency = 1
	signLabel.TextColor3 = Color3.fromRGB(255, 0, 128)
	signLabel.TextStrokeTransparency = 0
	signLabel.Font = Enum.Font.GothamBold
	signLabel.TextScaled = true
	signLabel.Text = "🌴 Chambre de " .. playerName
	signLabel.Parent = signBillboard

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

	local pedestalsFolder, spawn, origin = buildRoomShell(index, player.Name)
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
