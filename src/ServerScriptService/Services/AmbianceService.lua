--[[
	AmbianceService.lua
	Ambiance générale du jeu : ciel de coucher de soleil façon "2016
	Tumblr aesthetic" (orange/rose/violet), brume légère. Appelé une
	seule fois au démarrage du serveur, pas de logique par joueur ici.
]]

local Lighting = game:GetService("Lighting")

local AmbianceService = {}

function AmbianceService.Apply()
	-- 17.2 = "golden hour" : le soleil est encore bien visible et bas sur
	-- l'horizon (orange/rose). Passé ~18, Roblox commence à faire
	-- apparaître la lune et tout s'assombrit vers la nuit.
	Lighting.ClockTime = 17.2
	Lighting.GeographicLatitude = 20 -- soleil plus bas dans le ciel, ombres longues
	Lighting.Brightness = 3.5
	Lighting.Ambient = Color3.fromRGB(110, 65, 100)
	Lighting.OutdoorAmbient = Color3.fromRGB(160, 100, 120)
	Lighting.FogColor = Color3.fromRGB(255, 160, 190)
	Lighting.FogStart = 200
	Lighting.FogEnd = 1600

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.22
	atmosphere.Offset = 0.15
	atmosphere.Color = Color3.fromRGB(255, 190, 205)
	atmosphere.Decay = Color3.fromRGB(200, 130, 170)
	atmosphere.Glare = 0.5
	atmosphere.Haze = 0.8
	atmosphere.Parent = Lighting
end

return AmbianceService
