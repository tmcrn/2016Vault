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
-- allumées pour le côté "skyline en fin de journée".
local function buildSkyline(folder)
	local rng = Random.new(1234) -- seed fixe : même skyline à chaque démarrage
	local spacing = 40
	local buildingCount = math.floor((WORLD_X_MAX - WORLD_X_MIN) / spacing)

	for i = 0, buildingCount do
		local x = WORLD_X_MIN + i * spacing + rng:NextNumber(-8, 8)
		local height = rng:NextNumber(30, 90)
		local width = rng:NextNumber(14, 24)

		local building = Instance.new("Part")
		building.Name = "Building"
		building.Size = Vector3.new(width, height, width)
		building.Position = Vector3.new(x, height / 2, 150)
		building.Anchored = true
		building.Material = Enum.Material.Slate
		building.Color = Color3.fromRGB(45, 25, 55)
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
	end
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
	Construit tout le décor. À appeler UNE SEULE FOIS au démarrage du
	serveur (voir Main.server.lua) — jamais par joueur.
]]
function WorldDecorService.Build()
	local folder = Instance.new("Folder")
	folder.Name = "WorldDecor"
	folder.Parent = Workspace

	buildBeachAndOcean(folder)
	buildSkyline(folder)
	buildFerrisWheel(Vector3.new(150, 30, -90), folder)
end

return WorldDecorService
