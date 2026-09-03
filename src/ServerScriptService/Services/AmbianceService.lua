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
	Lighting.Brightness = 2.5
	Lighting.Ambient = Color3.fromRGB(75, 50, 70)
	Lighting.OutdoorAmbient = Color3.fromRGB(130, 90, 100)
	Lighting.FogColor = Color3.fromRGB(255, 175, 195)
	Lighting.FogStart = 500
	Lighting.FogEnd = 2200

	-- Densité/Haze nettement réduits : trop forts, ils noyaient toute la
	-- scène dans un même rose uniforme et effaçaient le contraste entre
	-- le premier plan (plage/chambre) et l'arrière-plan (skyline/collines).
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.1
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(255, 195, 210)
	atmosphere.Decay = Color3.fromRGB(190, 130, 165)
	atmosphere.Glare = 0.2
	atmosphere.Haze = 0.3
	atmosphere.Parent = Lighting
end

return AmbianceService
