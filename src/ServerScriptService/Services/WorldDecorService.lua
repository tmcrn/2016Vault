--[[
	WorldDecorService.lua
	Décor extérieur PARTAGÉ (une seule fois pour tout le serveur, pas
	par joueur) : skyline façon Los Angeles d'un côté, plage + océan au
	coucher de soleil de l'autre, et une grande roue façon Santa Monica
	Pier. Visible à travers les murs semi-transparents des Chambres.
]]

local Workspace = game:GetService("Workspace")

local WorldDecorService = {}

-- Doit couvrir toute la largeur où les Chambres peuvent apparaître
-- (voir ROOM_STEP dans RoomVisualService) pour qu'il y ait toujours du
-- décor visible, même avec plusieurs joueurs alignés sur X.
local WORLD_X_MIN = -100
local WORLD_X_MAX = 1200

--[[
	Construit un "beam" (poutre/tige) reliant deux points avec l'épaisseur
	donnée. Astuce classique Roblox pour ne pas avoir à calculer soi-même
	les angles de rotation.
]]
local function partBetween(a, b, thickness, material, color, folder, name)
	local distance = (b - a).Magnitude
	local part = Instance.new("Part")
	part.Name = name or "Beam"
	part.Size = Vector3.new(thickness, thickness, distance)
	part.CFrame = CFrame.new(a, b) * CFrame.new(0, 0, -distance / 2)
	part.Anchored = true
	part.CanCollide = false
	part.Material = material
	part.Color = color
	part.Parent = folder
	return part
end

-- Plage + océan, teinté par le coucher de soleil (voir AmbianceService).
local function buildBeachAndOcean(folder)
	local centerX = (WORLD_X_MIN + WORLD_X_MAX) / 2
	local spanX = WORLD_X_MAX - WORLD_X_MIN

	local beach = Instance.new("Part")
	beach.Name = "Beach"
	beach.Size = Vector3.new(spanX, 1, 60)
	beach.CFrame = CFrame.new(centerX, 0, -50)
	beach.Anchored = true
	beach.Material = Enum.Material.Sand
	beach.Color = Color3.fromRGB(235, 205, 155)
	beach.Parent = folder

	local ocean = Instance.new("Part")
	ocean.Name = "Ocean"
	ocean.Size = Vector3.new(spanX, 1, 400)
	ocean.CFrame = CFrame.new(centerX, -0.3, -280)
	ocean.Anchored = true
	ocean.CanCollide = false
	ocean.Material = Enum.Material.Glass
	ocean.Color = Color3.fromRGB(255, 175, 150) -- teinte coucher de soleil réfléchi
	ocean.Transparency = 0.15
	ocean.Reflectance = 0.4
	ocean.Parent = folder
end

-- Silhouette de buildings façon downtown LA, avec quelques fenêtres
-- allumées pour le côté "skyline en fin de journée". Un building sur 6
-- est une tour "landmark" plus haute avec un feu rouge clignotant.
local function buildSkyline(folder)
	local rng = Random.new(1234) -- seed fixe : même skyline à chaque démarrage
	local spacing = 40
	local buildingCount = math.floor((WORLD_X_MAX - WORLD_X_MIN) / spacing)

	local buildingColors = {
		Color3.fromRGB(45, 25, 55),
		Color3.fromRGB(30, 30, 60),
		Color3.fromRGB(55, 30, 45),
		Color3.fromRGB(35, 45, 60),
	}
	local buildingMaterials = { Enum.Material.Slate, Enum.Material.Concrete, Enum.Material.Basalt }

	for i = 0, buildingCount do
		local isLandmark = (i % 6 == 0)
		local x = WORLD_X_MIN + i * spacing + rng:NextNumber(-8, 8)
		local height = isLandmark and rng:NextNumber(110, 150) or rng:NextNumber(30, 90)
		local width = rng:NextNumber(14, 24)

		local building = Instance.new("Part")
		building.Name = "Building"
		building.Size = Vector3.new(width, height, width)
		building.Position = Vector3.new(x, height / 2, 150)
		building.Anchored = true
		building.Material = buildingMaterials[rng:NextInteger(1, #buildingMaterials)]
		building.Color = buildingColors[rng:NextInteger(1, #buildingColors)]
		building.Parent = folder

		for _ = 1, rng:NextInteger(2, 4) do
			local window = Instance.new("Part")
			window.Name = "Window"
			window.Size = Vector3.new(1.5, 1.5, 0.2)
			window.Anchored = true
			window.CanCollide = false
			window.Material = Enum.Material.Neon
			window.Color = Color3.fromRGB(255, 210, 120)
			window.Position = Vector3.new(
				x + rng:NextNumber(-width / 2 + 1, width / 2 - 1),
				rng:NextNumber(5, height - 5),
				150 - width / 2 - 0.1
			)
			window.Parent = folder
		end

		if isLandmark then
			local beacon = Instance.new("Part")
			beacon.Name = "RooftopBeacon"
			beacon.Shape = Enum.PartType.Ball
			beacon.Size = Vector3.new(2, 2, 2)
			beacon.Anchored = true
			beacon.CanCollide = false
			beacon.Material = Enum.Material.Neon
			beacon.Color = Color3.fromRGB(255, 40, 40)
			beacon.Position = Vector3.new(x, height + 1, 150)
			beacon.Parent = folder

			local blink = Instance.new("PointLight")
			blink.Color = Color3.fromRGB(255, 40, 40)
			blink.Range = 20
			blink.Parent = beacon

			task.spawn(function()
				while beacon.Parent do
					beacon.Transparency = 0
					task.wait(1)
					beacon.Transparency = 0.85
					task.wait(1)
				end
			end)
		end
	end
end

-- Colline avec un grand panneau "2016 VAULT" façon Hollywood Sign,
-- derrière la skyline.
local function buildHillsideSign(folder)
	local hillCenterX = (WORLD_X_MIN + WORLD_X_MAX) / 2

	local hill = Instance.new("Part")
	hill.Name = "Hill"
	hill.Size = Vector3.new(WORLD_X_MAX - WORLD_X_MIN, 150, 200)
	hill.CFrame = CFrame.new(hillCenterX, -40, 320) * CFrame.Angles(math.rad(-12), 0, 0)
	hill.Anchored = true
	hill.Material = Enum.Material.Grass
	hill.Color = Color3.fromRGB(60, 70, 45)
	hill.Parent = folder

	local sign = Instance.new("Part")
	sign.Name = "HillsideSign"
	sign.Size = Vector3.new(140, 22, 1)
	sign.Position = Vector3.new(hillCenterX, 55, 260)
	sign.Anchored = true
	sign.CanCollide = false
	sign.Material = Enum.Material.SmoothPlastic
	sign.Color = Color3.fromRGB(255, 255, 255)
	sign.Parent = folder

	for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.LightInfluence = 0
		gui.Parent = sign

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "2016 VAULT"
		label.TextColor3 = Color3.fromRGB(255, 0, 128)
		label.Font = Enum.Font.GothamBlack
		label.TextScaled = true
		label.Parent = gui
	end
end

-- Palmier procédural, réutilisé le long de la plage.
local function buildBeachPalmTree(position, folder)
	local trunk = Instance.new("Part")
	trunk.Name = "PalmTrunk"
	trunk.Shape = Enum.PartType.Cylinder
	trunk.Size = Vector3.new(10, 1.2, 1.2)
	trunk.Orientation = Vector3.new(0, 0, 90)
	trunk.Position = position + Vector3.new(0, 5, 0)
	trunk.Anchored = true
	trunk.CanCollide = false
	trunk.Material = Enum.Material.Wood
	trunk.Color = Color3.fromRGB(120, 80, 50)
	trunk.Parent = folder

	for i = 1, 6 do
		local leaf = Instance.new("Part")
		leaf.Name = "PalmLeaf"
		leaf.Size = Vector3.new(0.5, 0.5, 6)
		leaf.Anchored = true
		leaf.CanCollide = false
		leaf.Material = Enum.Material.Grass
		leaf.Color = Color3.fromRGB(60, 180, 90)
		leaf.CFrame = CFrame.new(position + Vector3.new(0, 10, 0))
			* CFrame.Angles(0, math.rad(i * 60), math.rad(35))
			* CFrame.new(0, 0, -3)
		leaf.Parent = folder
	end
end

-- Parasol + transat, posés directement sur le sable.
local function buildBeachSpot(position, color, folder)
	local pole = Instance.new("Part")
	pole.Name = "UmbrellaPole"
	pole.Size = Vector3.new(0.4, 6, 0.4)
	pole.Position = position + Vector3.new(0, 3, 0)
	pole.Anchored = true
	pole.CanCollide = false
	pole.Material = Enum.Material.Metal
	pole.Color = Color3.fromRGB(200, 200, 200)
	pole.Parent = folder

	local canopy = Instance.new("Part")
	canopy.Name = "UmbrellaCanopy"
	canopy.Shape = Enum.PartType.Cylinder
	canopy.Size = Vector3.new(0.6, 6, 6)
	canopy.Orientation = Vector3.new(0, 0, 90)
	canopy.Position = position + Vector3.new(0, 6, 0)
	canopy.Anchored = true
	canopy.CanCollide = false
	canopy.Material = Enum.Material.Fabric
	canopy.Color = color
	canopy.Parent = folder

	local chair = Instance.new("Part")
	chair.Name = "BeachChair"
	chair.Size = Vector3.new(2, 0.3, 5)
	chair.CFrame = CFrame.new(position + Vector3.new(2.5, 0.3, 0)) * CFrame.Angles(math.rad(-15), 0, 0)
	chair.Anchored = true
	chair.CanCollide = false
	chair.Material = Enum.Material.Wood
	chair.Color = Color3.fromRGB(230, 230, 235)
	chair.Parent = folder
end

-- Sème palmiers et coins parasol le long de toute la plage.
local function buildBeachDecor(folder)
	local rng = Random.new(5678)
	local spotColors = {
		Color3.fromRGB(255, 0, 128),
		Color3.fromRGB(0, 200, 255),
		Color3.fromRGB(255, 200, 0),
	}

	local x = WORLD_X_MIN
	while x < WORLD_X_MAX do
		buildBeachPalmTree(Vector3.new(x, 1, -25 + rng:NextNumber(-3, 3)), folder)
		x += rng:NextNumber(50, 80)
	end

	x = WORLD_X_MIN + 20
	while x < WORLD_X_MAX do
		buildBeachSpot(
			Vector3.new(x, 1, -55 + rng:NextNumber(-5, 5)),
			spotColors[rng:NextInteger(1, #spotColors)],
			folder
		)
		x += rng:NextNumber(45, 70)
	end
end

-- Petits nuages plats qui flottent dans le ciel, pour casser le vide.
local function buildClouds(folder)
	local rng = Random.new(9999)
	for _ = 1, 25 do
		local cloud = Instance.new("Part")
		cloud.Name = "Cloud"
		cloud.Size = Vector3.new(rng:NextNumber(20, 50), 4, rng:NextNumber(15, 30))
		cloud.Position = Vector3.new(
			rng:NextNumber(WORLD_X_MIN, WORLD_X_MAX),
			rng:NextNumber(140, 220),
			rng:NextNumber(-150, 250)
		)
		cloud.Anchored = true
		cloud.CanCollide = false
		cloud.Material = Enum.Material.SmoothPlastic
		cloud.Color = Color3.fromRGB(255, 220, 230)
		cloud.Transparency = 0.25
		cloud.Parent = folder
	end
end

-- Jetée en bois qui part de la plage jusqu'à la grande roue.
local function buildPier(startPos, endPos, folder)
	local plank = partBetween(startPos, endPos, 8, Enum.Material.WoodPlanks, Color3.fromRGB(110, 75, 50), folder, "Pier")
	plank.Size = Vector3.new(8, 1, (endPos - startPos).Magnitude)
end

-- Grande roue procédurale (rayons + jante en segments + nacelles), posée
-- à cheval sur la plage et l'océan façon jetée de Santa Monica.
local function buildFerrisWheel(center, folder)
	local RADIUS = 24
	local SEGMENTS = 12
	local metalColor = Color3.fromRGB(220, 220, 230)
	local gondolaColors = {
		Color3.fromRGB(255, 0, 128),
		Color3.fromRGB(0, 200, 255),
		Color3.fromRGB(255, 200, 0),
	}

	local rimPositions = {}
	for i = 1, SEGMENTS do
		local angle = (i / SEGMENTS) * math.pi * 2
		rimPositions[i] = center + Vector3.new(math.cos(angle) * RADIUS, math.sin(angle) * RADIUS, 0)
	end

	local hub = Instance.new("Part")
	hub.Name = "FerrisHub"
	hub.Shape = Enum.PartType.Cylinder
	hub.Size = Vector3.new(2, 4, 4)
	hub.Orientation = Vector3.new(0, 0, 90)
	hub.Position = center
	hub.Anchored = true
	hub.Material = Enum.Material.Metal
	hub.Color = Color3.fromRGB(255, 0, 128)
	hub.Parent = folder

	-- Pilier qui tient la roue au sol.
	partBetween(center, center - Vector3.new(0, center.Y, 0), 3, Enum.Material.Metal, metalColor, folder, "FerrisPylon")

	for i, rimPos in ipairs(rimPositions) do
		partBetween(center, rimPos, 0.4, Enum.Material.Metal, metalColor, folder, "FerrisSpoke")

		local nextPos = rimPositions[(i % SEGMENTS) + 1]
		partBetween(rimPos, nextPos, 0.5, Enum.Material.Metal, metalColor, folder, "FerrisRim")

		if i % 2 == 0 then
			local gondola = Instance.new("Part")
			gondola.Name = "FerrisGondola"
			gondola.Size = Vector3.new(3, 3, 3)
			gondola.Position = rimPos - Vector3.new(0, 2, 0)
			gondola.Anchored = true
			gondola.Material = Enum.Material.SmoothPlastic
			gondola.Color = gondolaColors[(i % 3) + 1]
			gondola.Parent = folder
		end
	end
end

--[[
	Construit tout le décor. Appelé au démarrage du serveur (voir
	Main.server.lua) — mais NE FAIT RIEN si un dossier "WorldDecor"
	existe déjà dans le Workspace. Ça permet de le générer une seule
	fois à la main via la Command Bar en mode Édition (pour ensuite le
	modifier/compléter toi-même) sans qu'il se duplique à chaque Play.
]]
function WorldDecorService.Build()
	if Workspace:FindFirstChild("WorldDecor") then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "WorldDecor"
	folder.Parent = Workspace

	buildBeachAndOcean(folder)
	buildSkyline(folder)
	buildHillsideSign(folder)
	buildBeachDecor(folder)
	buildClouds(folder)

	local ferrisCenter = Vector3.new(150, 30, -90)
	buildFerrisWheel(ferrisCenter, folder)
	buildPier(Vector3.new(150, 1, -50), Vector3.new(150, 1, ferrisCenter.Z), folder)
end

return WorldDecorService
