--[[
	WorldDecorService.lua
	Décor extérieur PARTAGÉ (une seule fois pour tout le serveur, pas
	par joueur) : skyline façon downtown LA au coucher de soleil, boulevard
	bordé de palmiers et lampadaires rétro, plage + océan, et une grande
	roue façon Santa Monica Pier. Visible à travers les murs
	semi-transparents des Chambres. Pensé "2016 Tumblr aesthetic".

	NOTE: ce script ne construit QUE dans son propre dossier "WorldDecor".
	Il ne touche jamais à ce que tu as ajouté toi-même dans le Workspace
	(ta route par exemple) — aucun risque de conflit ou d'écrasement.
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

-- Silhouette de montagnes au loin, très plates et désaturées, pour donner
-- de la profondeur derrière la skyline (façon San Gabriel Mountains vues
-- depuis downtown LA au coucher de soleil). Toutes tournées face caméra
-- (pas de rotation aléatoire complète, sinon ça part dans tous les sens)
-- et espacées pour qu'on distingue des pics plutôt qu'un mur plein.
local function buildDistantMountains(folder)
	local rng = Random.new(4242)

	local x = WORLD_X_MIN - 200
	while x < WORLD_X_MAX + 200 do
		local width = rng:NextNumber(90, 160)
		local height = rng:NextNumber(35, 75)
		local mountain = Instance.new("WedgePart")
		mountain.Name = "DistantMountain"
		mountain.Size = Vector3.new(width, height, 30)
		-- Léger tilt aléatoire (+/-8°) seulement, pour varier sans casser
		-- l'alignement général de la chaîne.
		mountain.CFrame = CFrame.new(x, height / 2 - 20, 1100) * CFrame.Angles(0, math.rad(rng:NextNumber(-8, 8)), 0)
		mountain.Anchored = true
		mountain.CanCollide = false
		mountain.Material = Enum.Material.Sand
		mountain.Color = Color3.fromRGB(160, 120, 140)
		mountain.Transparency = 0.45
		mountain.Parent = folder
		x += width + rng:NextNumber(-10, 20)
	end
end

-- Plage + océan : sable sec, bande de sable mouillé plus sombre le long de
-- l'eau, ligne d'écume, puis l'océan teinté par le coucher de soleil.
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

	local wetSand = Instance.new("Part")
	wetSand.Name = "WetSand"
	wetSand.Size = Vector3.new(spanX, 1.02, 14)
	wetSand.CFrame = CFrame.new(centerX, 0.02, -76)
	wetSand.Anchored = true
	wetSand.Material = Enum.Material.Sand
	wetSand.Color = Color3.fromRGB(190, 155, 130)
	wetSand.Parent = folder

	local foamLine = Instance.new("Part")
	foamLine.Name = "FoamLine"
	foamLine.Size = Vector3.new(spanX, 0.3, 3)
	foamLine.CFrame = CFrame.new(centerX, 0.4, -82)
	foamLine.Anchored = true
	foamLine.CanCollide = false
	foamLine.Material = Enum.Material.Neon
	foamLine.Color = Color3.fromRGB(255, 245, 250)
	foamLine.Transparency = 0.35
	foamLine.Parent = folder

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

	-- Quelques rangées de vaguelettes qui remontent vers la plage, plus
	-- claires que l'océan pour simuler l'écume qui déferle.
	local rng = Random.new(3131)
	for row = 1, 4 do
		local wave = Instance.new("Part")
		wave.Name = "Wave"
		wave.Size = Vector3.new(spanX, 0.2, 2.5)
		wave.CFrame = CFrame.new(centerX + rng:NextNumber(-30, 30), 0.1, -95 - row * 22)
		wave.Anchored = true
		wave.CanCollide = false
		wave.Material = Enum.Material.Neon
		wave.Color = Color3.fromRGB(255, 220, 220)
		wave.Transparency = 0.55 + row * 0.08
		wave.Parent = folder
	end
end

-- Panneau lumineux "rooftop billboard" façon pub géante des années 2010,
-- posé sur un building précis pour casser la skyline avec du texte animé.
local function buildRooftopBillboard(building, height, width, folder)
	local frame = Instance.new("Part")
	frame.Name = "BillboardFrame"
	frame.Size = Vector3.new(width * 0.9, 14, 1)
	frame.Position = building.Position + Vector3.new(0, height / 2 + 8, 0)
	frame.Anchored = true
	frame.CanCollide = false
	frame.Material = Enum.Material.Metal
	frame.Color = Color3.fromRGB(20, 20, 20)
	frame.Parent = folder

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundColor3 = Color3.fromRGB(10, 5, 15)
	label.BackgroundTransparency = 0.1
	label.Text = "2016"
	label.TextColor3 = Color3.fromRGB(0, 220, 255)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Parent = gui
end

-- Petit chapeau de toit : soit des blocs de climatisation, soit un château
-- d'eau cylindrique sur pattes, façon vrais toits de downtown LA.
local function buildRooftopDetail(building, height, width, rng, folder)
	if rng:NextNumber() < 0.5 then
		for _ = 1, rng:NextInteger(2, 4) do
			local unit = Instance.new("Part")
			unit.Name = "RooftopAC"
			unit.Size = Vector3.new(rng:NextNumber(2, 4), rng:NextNumber(1.5, 2.5), rng:NextNumber(2, 4))
			unit.Anchored = true
			unit.CanCollide = false
			unit.Material = Enum.Material.Metal
			unit.Color = Color3.fromRGB(90, 90, 95)
			unit.Position = building.Position
				+ Vector3.new(rng:NextNumber(-width / 3, width / 3), height / 2 + 1, rng:NextNumber(-width / 3, width / 3))
			unit.Parent = folder
		end
	else
		local tankBody = Instance.new("Part")
		tankBody.Name = "WaterTank"
		tankBody.Shape = Enum.PartType.Cylinder
		tankBody.Size = Vector3.new(6, 3.5, 3.5)
		tankBody.Orientation = Vector3.new(0, 0, 90)
		tankBody.Anchored = true
		tankBody.CanCollide = false
		tankBody.Material = Enum.Material.WoodPlanks
		tankBody.Color = Color3.fromRGB(110, 75, 55)
		tankBody.Position = building.Position + Vector3.new(0, height / 2 + 5, 0)
		tankBody.Parent = folder

		for _, offset in ipairs({ Vector3.new(1.3, -3, 1.3), Vector3.new(-1.3, -3, 1.3), Vector3.new(1.3, -3, -1.3), Vector3.new(-1.3, -3, -1.3) }) do
			local leg = Instance.new("Part")
			leg.Name = "WaterTankLeg"
			leg.Size = Vector3.new(0.3, 3, 0.3)
			leg.Anchored = true
			leg.CanCollide = false
			leg.Material = Enum.Material.Metal
			leg.Color = Color3.fromRGB(40, 40, 40)
			leg.Position = tankBody.Position + offset
			leg.Parent = folder
		end
	end
end

-- Silhouette de buildings façon downtown LA, avec fenêtres allumées en
-- motifs (pas juste aléatoire), toits détaillés, et un panneau publicitaire
-- lumineux sur une tour landmark. Un building sur 6 est une tour "landmark"
-- plus haute avec un feu rouge clignotant.
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
	local windowColors = {
		Color3.fromRGB(255, 210, 120),
		Color3.fromRGB(255, 170, 90),
		Color3.fromRGB(180, 220, 255),
	}

	local billboardPlaced = false

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

		-- Retrait ("setback") : une tour plus fine posée sur une base plus
		-- large, comme beaucoup d'immeubles de downtown LA.
		if rng:NextNumber() < 0.35 and height > 50 then
			local towerHeight = height * rng:NextNumber(0.3, 0.5)
			local towerWidth = width * rng:NextNumber(0.45, 0.65)
			local tower = Instance.new("Part")
			tower.Name = "BuildingSetback"
			tower.Size = Vector3.new(towerWidth, towerHeight, towerWidth)
			tower.Position = Vector3.new(x, height + towerHeight / 2, 150)
			tower.Anchored = true
			tower.Material = building.Material
			tower.Color = building.Color
			tower.Parent = folder
		end

		-- Fenêtres allumées disposées en colonnes régulières plutôt qu'en
		-- nuage aléatoire, pour un vrai effet "grille d'immeuble".
		local windowColor = windowColors[rng:NextInteger(1, #windowColors)]
		local columns = math.max(2, math.floor(width / 4))
		local rows = math.max(3, math.floor(height / 6))
		for col = 0, columns - 1 do
			if rng:NextNumber() < 0.7 then
				for row = 0, rows - 1 do
					if rng:NextNumber() < 0.35 then
						local window = Instance.new("Part")
						window.Name = "Window"
						window.Size = Vector3.new(1.4, 1.4, 0.2)
						window.Anchored = true
						window.CanCollide = false
						window.Material = Enum.Material.Neon
						window.Color = windowColor
						window.Position = Vector3.new(
							x - width / 2 + 2 + col * (width / columns),
							3 + row * (height / rows),
							150 - width / 2 - 0.1
						)
						window.Parent = folder
					end
				end
			end
		end

		buildRooftopDetail(building, height, width, rng, folder)

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

			-- La première tour landmark rencontrée reçoit le grand panneau
			-- publicitaire "2016" façon Sunset Strip.
			if not billboardPlaced then
				billboardPlaced = true
				buildRooftopBillboard(building, height, width, folder)
			end
		end
	end
end

-- Colline avec un grand panneau "2016 VAULT" façon Hollywood Sign,
-- derrière la skyline.
local function buildHillsideSign(folder)
	local hillCenterX = (WORLD_X_MIN + WORLD_X_MAX) / 2

	-- Base basse et lointaine, juste pour ne pas voir le vide sous les
	-- bosses de colline. Nettement plus petite que la skyline pour rester
	-- un arrière-plan et pas un mur qui écrase tout.
	local base = Instance.new("Part")
	base.Name = "HillBase"
	base.Size = Vector3.new(WORLD_X_MAX - WORLD_X_MIN + 200, 20, 140)
	base.Position = Vector3.new(hillCenterX, 5, 420)
	base.Anchored = true
	base.CanCollide = false
	base.Material = Enum.Material.Grass
	base.Color = Color3.fromRGB(65, 60, 65)
	base.Transparency = 0.2
	base.Parent = folder

	-- Chaîne de bosses arrondies (demi-sphères enfoncées) pour un vrai
	-- profil de colline vallonnée plutôt qu'une dalle plate.
	local rng = Random.new(7777)
	local x = WORLD_X_MIN - 100
	while x < WORLD_X_MAX + 100 do
		local bumpHeight = rng:NextNumber(25, 55)
		local bump = Instance.new("Part")
		bump.Name = "HillBump"
		bump.Shape = Enum.PartType.Ball
		bump.Size = Vector3.new(bumpHeight * 2.2, bumpHeight * 2, bumpHeight * 2.2)
		bump.Position = Vector3.new(x, bumpHeight * 0.15, 420 + rng:NextNumber(-20, 20))
		bump.Anchored = true
		bump.CanCollide = false
		bump.Material = Enum.Material.Grass
		bump.Color = Color3.fromRGB(70, 65, 70)
		bump.Transparency = 0.2
		bump.Parent = folder
		x += bumpHeight * rng:NextNumber(1.6, 2.2)
	end

	local sign = Instance.new("Part")
	sign.Name = "HillsideSign"
	sign.Size = Vector3.new(110, 18, 1)
	sign.Position = Vector3.new(hillCenterX, 38, 350)
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

-- Palmier procédural, réutilisé le long de la plage et du boulevard.
local function buildPalmTree(position, folder, scale)
	scale = scale or 1
	local trunk = Instance.new("Part")
	trunk.Name = "PalmTrunk"
	trunk.Shape = Enum.PartType.Cylinder
	trunk.Size = Vector3.new(10 * scale, 1.2 * scale, 1.2 * scale)
	trunk.Orientation = Vector3.new(0, 0, 90)
	trunk.Position = position + Vector3.new(0, 5 * scale, 0)
	trunk.Anchored = true
	trunk.CanCollide = false
	trunk.Material = Enum.Material.Wood
	trunk.Color = Color3.fromRGB(120, 80, 50)
	trunk.Parent = folder

	for i = 1, 6 do
		local leaf = Instance.new("Part")
		leaf.Name = "PalmLeaf"
		leaf.Size = Vector3.new(0.5 * scale, 0.5 * scale, 6 * scale)
		leaf.Anchored = true
		leaf.CanCollide = false
		leaf.Material = Enum.Material.Grass
		leaf.Color = Color3.fromRGB(60, 180, 90)
		leaf.CFrame = CFrame.new(position + Vector3.new(0, 10 * scale, 0))
			* CFrame.Angles(0, math.rad(i * 60), math.rad(35))
			* CFrame.new(0, 0, -3 * scale)
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

-- Poste de secours façon Baywatch, rouge et blanc, avec petite échelle.
local function buildLifeguardTower(position, folder)
	local legColor = Color3.fromRGB(230, 230, 235)
	for _, offset in ipairs({ Vector3.new(2, 0, 2), Vector3.new(-2, 0, 2), Vector3.new(2, 0, -2), Vector3.new(-2, 0, -2) }) do
		local leg = Instance.new("Part")
		leg.Name = "TowerLeg"
		leg.Size = Vector3.new(0.5, 6, 0.5)
		leg.Position = position + offset + Vector3.new(0, 3, 0)
		leg.Anchored = true
		leg.CanCollide = false
		leg.Material = Enum.Material.WoodPlanks
		leg.Color = legColor
		leg.Parent = folder
	end

	local cabin = Instance.new("Part")
	cabin.Name = "TowerCabin"
	cabin.Size = Vector3.new(6, 4, 6)
	cabin.Position = position + Vector3.new(0, 8, 0)
	cabin.Anchored = true
	cabin.CanCollide = false
	cabin.Material = Enum.Material.WoodPlanks
	cabin.Color = Color3.fromRGB(220, 60, 60)
	cabin.Parent = folder

	local roof = Instance.new("Part")
	roof.Name = "TowerRoof"
	roof.Size = Vector3.new(7, 0.5, 7)
	roof.Position = position + Vector3.new(0, 10.3, 0)
	roof.Anchored = true
	roof.CanCollide = false
	roof.Material = Enum.Material.WoodPlanks
	roof.Color = Color3.fromRGB(255, 255, 255)
	roof.Parent = folder

	local ladder = Instance.new("Part")
	ladder.Name = "TowerLadder"
	ladder.Size = Vector3.new(1.5, 6, 0.2)
	ladder.CFrame = CFrame.new(position + Vector3.new(0, 3, 3)) * CFrame.Angles(math.rad(-10), 0, 0)
	ladder.Anchored = true
	ladder.CanCollide = false
	ladder.Material = Enum.Material.Wood
	ladder.Color = Color3.fromRGB(150, 100, 70)
	ladder.Parent = folder
end

-- Filet de volley-ball planté dans le sable.
local function buildVolleyballNet(position, folder)
	for _, offsetX in ipairs({ -6, 6 }) do
		local pole = Instance.new("Part")
		pole.Name = "VolleyballPole"
		pole.Size = Vector3.new(0.4, 6, 0.4)
		pole.Position = position + Vector3.new(offsetX, 3, 0)
		pole.Anchored = true
		pole.CanCollide = false
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(230, 230, 230)
		pole.Parent = folder
	end

	local net = Instance.new("Part")
	net.Name = "VolleyballNet"
	net.Size = Vector3.new(12, 2.5, 0.1)
	net.Position = position + Vector3.new(0, 4.5, 0)
	net.Anchored = true
	net.CanCollide = false
	net.Material = Enum.Material.Fabric
	net.Color = Color3.fromRGB(255, 255, 255)
	net.Transparency = 0.5
	net.Parent = folder
end

-- Sème palmiers, coins parasol, poste de secours et filet de volley le
-- long de toute la plage.
local function buildBeachDecor(folder)
	local rng = Random.new(5678)
	local spotColors = {
		Color3.fromRGB(255, 0, 128),
		Color3.fromRGB(0, 200, 255),
		Color3.fromRGB(255, 200, 0),
	}

	local x = WORLD_X_MIN
	while x < WORLD_X_MAX do
		buildPalmTree(Vector3.new(x, 1, -25 + rng:NextNumber(-3, 3)), folder)
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

	local centerX = (WORLD_X_MIN + WORLD_X_MAX) / 2
	buildLifeguardTower(Vector3.new(centerX - 220, 1, -40), folder)
	buildLifeguardTower(Vector3.new(centerX + 260, 1, -40), folder)
	buildVolleyballNet(Vector3.new(centerX - 60, 1, -35), folder)
end

-- Lampadaire rétro double-globe (façon boulevard des années 2010), avec
-- lumière chaude.
local function buildStreetlight(position, folder)
	local pole = Instance.new("Part")
	pole.Name = "StreetlightPole"
	pole.Size = Vector3.new(0.6, 11, 0.6)
	pole.Position = position + Vector3.new(0, 5.5, 0)
	pole.Anchored = true
	pole.CanCollide = false
	pole.Material = Enum.Material.Metal
	pole.Color = Color3.fromRGB(35, 35, 40)
	pole.Parent = folder

	for _, offsetX in ipairs({ -0.9, 0.9 }) do
		local globe = Instance.new("Part")
		globe.Name = "StreetlightGlobe"
		globe.Shape = Enum.PartType.Ball
		globe.Size = Vector3.new(1.4, 1.4, 1.4)
		globe.Position = position + Vector3.new(offsetX, 11, 0)
		globe.Anchored = true
		globe.CanCollide = false
		globe.Material = Enum.Material.Neon
		globe.Color = Color3.fromRGB(255, 225, 170)
		globe.Parent = folder

		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 200, 150)
		light.Range = 18
		light.Brightness = 1.5
		light.Parent = globe
	end
end

-- Voiture low-poly façon 2016 (berline compacte), couleur au choix.
local function buildParkedCar(position, color, folder)
	local body = Instance.new("Part")
	body.Name = "ParkedCarBody"
	body.Size = Vector3.new(7, 2, 3.2)
	body.Position = position + Vector3.new(0, 1.2, 0)
	body.Anchored = true
	body.CanCollide = false
	body.Material = Enum.Material.SmoothPlastic
	body.Color = color
	body.Parent = folder

	local cabin = Instance.new("Part")
	cabin.Name = "ParkedCarCabin"
	cabin.Size = Vector3.new(3.6, 1.4, 3)
	cabin.Position = position + Vector3.new(-0.3, 2.4, 0)
	cabin.Anchored = true
	cabin.CanCollide = false
	cabin.Material = Enum.Material.Glass
	cabin.Color = Color3.fromRGB(40, 45, 55)
	cabin.Transparency = 0.2
	cabin.Parent = folder

	for _, offsetX in ipairs({ -2.4, 2.4 }) do
		for _, offsetZ in ipairs({ -1.5, 1.5 }) do
			local wheel = Instance.new("Part")
			wheel.Name = "ParkedCarWheel"
			wheel.Shape = Enum.PartType.Cylinder
			wheel.Size = Vector3.new(0.6, 1.6, 1.6)
			wheel.Orientation = Vector3.new(0, 0, 90)
			wheel.Position = position + Vector3.new(offsetX, 0.6, offsetZ)
			wheel.Anchored = true
			wheel.CanCollide = false
			wheel.Material = Enum.Material.Slate
			wheel.Color = Color3.fromRGB(20, 20, 20)
			wheel.Parent = folder
		end
	end
end

--[[
	Boulevard bordé de palmiers, lampadaires et voitures garées, en
	contrebas de la skyline. Placé volontairement en retrait des buildings
	(Z=125) pour ne jamais chevaucher une route que tu aurais toi-même
	posée dans le Workspace : ce ne sont que des éléments de trottoir.
]]
local function buildBoulevard(folder)
	local rng = Random.new(8642)
	local carColors = {
		Color3.fromRGB(200, 40, 60),
		Color3.fromRGB(230, 230, 235),
		Color3.fromRGB(40, 60, 120),
		Color3.fromRGB(230, 190, 40),
		Color3.fromRGB(30, 30, 35),
	}

	local x = WORLD_X_MIN + 10
	while x < WORLD_X_MAX do
		buildStreetlight(Vector3.new(x, 1, 128), folder)
		if rng:NextNumber() < 0.6 then
			buildPalmTree(Vector3.new(x + rng:NextNumber(8, 14), 1, 122), folder, 0.85)
		end
		if rng:NextNumber() < 0.5 then
			buildParkedCar(
				Vector3.new(x + rng:NextNumber(-6, 6), 1, 112),
				carColors[rng:NextInteger(1, #carColors)],
				folder
			)
		end
		x += rng:NextNumber(35, 55)
	end
end

-- Petits nuages plats qui flottent dans le ciel, pour casser le vide.
local function buildClouds(folder)
	local rng = Random.new(9999)
	local cloudTints = {
		Color3.fromRGB(255, 220, 230),
		Color3.fromRGB(255, 200, 190),
		Color3.fromRGB(230, 200, 235),
	}
	for _ = 1, 28 do
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
		cloud.Color = cloudTints[rng:NextInteger(1, #cloudTints)]
		cloud.Transparency = 0.25
		cloud.Parent = folder
	end
end

-- Jetée en bois qui part de la plage jusqu'à la grande roue, avec ses
-- propres lampadaires façon Santa Monica Pier.
local function buildPier(startPos, endPos, folder)
	local plank = partBetween(startPos, endPos, 8, Enum.Material.WoodPlanks, Color3.fromRGB(110, 75, 50), folder, "Pier")
	plank.Size = Vector3.new(8, 1, (endPos - startPos).Magnitude)

	local direction = (endPos - startPos).Unit
	local length = (endPos - startPos).Magnitude
	for dist = 15, length - 10, 25 do
		local pos = startPos + direction * dist
		for _, side in ipairs({ -4.5, 4.5 }) do
			local lamp = Instance.new("Part")
			lamp.Name = "PierLampPost"
			lamp.Size = Vector3.new(0.4, 7, 0.4)
			lamp.Position = pos + Vector3.new(side, 4, 0)
			lamp.Anchored = true
			lamp.CanCollide = false
			lamp.Material = Enum.Material.Metal
			lamp.Color = Color3.fromRGB(30, 30, 35)
			lamp.Parent = folder

			local bulb = Instance.new("Part")
			bulb.Name = "PierLampBulb"
			bulb.Shape = Enum.PartType.Ball
			bulb.Size = Vector3.new(1.1, 1.1, 1.1)
			bulb.Position = pos + Vector3.new(side, 7.5, 0)
			bulb.Anchored = true
			bulb.CanCollide = false
			bulb.Material = Enum.Material.Neon
			bulb.Color = Color3.fromRGB(255, 225, 170)
			bulb.Parent = folder

			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(255, 200, 150)
			light.Range = 14
			light.Parent = bulb
		end
	end
end

-- Grande roue procédurale (rayons + jante en segments + nacelles), posée
-- à cheval sur la plage et l'océan façon jetée de Santa Monica. Les rayons
-- alternent en néon coloré pour un vrai effet "illuminé la nuit".
local function buildFerrisWheel(center, folder)
	local RADIUS = 24
	local SEGMENTS = 12
	local metalColor = Color3.fromRGB(220, 220, 230)
	local gondolaColors = {
		Color3.fromRGB(255, 0, 128),
		Color3.fromRGB(0, 200, 255),
		Color3.fromRGB(255, 200, 0),
	}
	local rimNeonColors = {
		Color3.fromRGB(255, 0, 128),
		Color3.fromRGB(0, 220, 255),
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

	-- Petite billetterie au pied de la roue.
	local booth = Instance.new("Part")
	booth.Name = "TicketBooth"
	booth.Size = Vector3.new(6, 6, 5)
	booth.Position = center - Vector3.new(0, center.Y - 3, 12)
	booth.Anchored = true
	booth.Material = Enum.Material.WoodPlanks
	booth.Color = Color3.fromRGB(255, 200, 0)
	booth.Parent = folder

	for i, rimPos in ipairs(rimPositions) do
		local spoke = partBetween(center, rimPos, 0.4, Enum.Material.Neon, rimNeonColors[(i % 2) + 1], folder, "FerrisSpoke")
		spoke.Transparency = 0.1

		local nextPos = rimPositions[(i % SEGMENTS) + 1]
		local rim = partBetween(rimPos, nextPos, 0.5, Enum.Material.Neon, rimNeonColors[(i % 2) + 1], folder, "FerrisRim")
		rim.Transparency = 0.1

		local rimLight = Instance.new("PointLight")
		rimLight.Color = rimNeonColors[(i % 2) + 1]
		rimLight.Range = 10
		rimLight.Brightness = 1
		rimLight.Parent = rim

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

	Ne touche jamais à ce que tu as construit toi-même ailleurs dans le
	Workspace (comme ta route) : tout va dans le dossier "WorldDecor".
]]
function WorldDecorService.Build()
	if Workspace:FindFirstChild("WorldDecor") then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "WorldDecor"
	folder.Parent = Workspace

	buildDistantMountains(folder)
	buildBeachAndOcean(folder)
	buildSkyline(folder)
	buildHillsideSign(folder)
	buildBeachDecor(folder)
	buildBoulevard(folder)
	buildClouds(folder)

	local ferrisCenter = Vector3.new(150, 30, -90)
	buildFerrisWheel(ferrisCenter, folder)
	buildPier(Vector3.new(150, 1, -50), Vector3.new(150, 1, ferrisCenter.Z), folder)
end

return WorldDecorService
