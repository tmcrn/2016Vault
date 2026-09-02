--[[
	AmbianceService.lua
	Ambiance générale du jeu : ciel de coucher de soleil façon "2016
	Tumblr aesthetic" (orange/rose/violet), brume légère. Appelé une
	seule fois au démarrage du serveur, pas de logique par joueur ici.
]]

local Lighting = game:GetService("Lighting")

local AmbianceService = {}

function AmbianceService.Apply()
	Lighting.ClockTime = 18.3 -- fin d'après-midi : ciel orange/rose naturel
	Lighting.Brightness = 2.5
	Lighting.Ambient = Color3.fromRGB(80, 45, 90)
	Lighting.OutdoorAmbient = Color3.fromRGB(130, 75, 105)
	Lighting.FogColor = Color3.fromRGB(255, 150, 190)
	Lighting.FogStart = 100
	Lighting.FogEnd = 1200

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.3
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(255, 180, 205)
	atmosphere.Decay = Color3.fromRGB(150, 90, 160)
	atmosphere.Glare = 0.35
	atmosphere.Haze = 1.3
	atmosphere.Parent = Lighting
end

return AmbianceService
