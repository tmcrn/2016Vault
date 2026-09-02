--[[
	Main.server.lua
	Point d'entrée serveur : crée les RemoteEvents, branche les joueurs qui
	arrivent/partent sur DataService/LeaderstatsService, relie les actions
	du client (ouvrir une capsule, placer un objet) aux services, et
	enregistre ce que chaque Developer Product doit accorder à l'achat.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConfig = require(ReplicatedStorage.Modules.MonetizationConfig)

local DataService = require(script.Parent.Services.DataService)
local LeaderstatsService = require(script.Parent.Services.LeaderstatsService)
local CapsuleService = require(script.Parent.Services.CapsuleService)
local RoomService = require(script.Parent.Services.RoomService)
local RoomVisualService = require(script.Parent.Services.RoomVisualService)
local MonetizationService = require(script.Parent.Services.MonetizationService)
local AmbianceService = require(script.Parent.Services.AmbianceService)

AmbianceService.Apply()

-- Dossier + RemoteEvents créés au démarrage (pas besoin de les placer
-- à la main dans Studio, tout est fait en code).
local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

local openCapsuleRemote = Instance.new("RemoteEvent")
openCapsuleRemote.Name = "OpenCapsule"
openCapsuleRemote.Parent = remotesFolder

local capsuleResultRemote = Instance.new("RemoteEvent")
capsuleResultRemote.Name = "CapsuleResult"
capsuleResultRemote.Parent = remotesFolder

local placeItemRemote = Instance.new("RemoteEvent")
placeItemRemote.Name = "PlaceItem"
placeItemRemote.Parent = remotesFolder

-- Le client appelle ça pour savoir quoi afficher dans son panneau
-- Inventaire (liste d'objets pas encore placés dans la Chambre Rétro).
local getInventoryRemote = Instance.new("RemoteFunction")
getInventoryRemote.Name = "GetInventory"
getInventoryRemote.Parent = remotesFolder

getInventoryRemote.OnServerInvoke = function(player)
	local data = DataService.Get(player)
	return data and data.Inventory or {}
end

Players.PlayerAdded:Connect(function(player)
	-- Synchrone, pas de DataStore : fixe le spawn AVANT que le personnage
	-- apparaisse, pour que le joueur atterrisse dans sa propre chambre.
	RoomVisualService.CreateRoomFor(player)

	local data = DataService.Load(player)
	LeaderstatsService.Setup(player, data)
	RoomVisualService.Refresh(player, data.RoomItems)
end)

Players.PlayerRemoving:Connect(function(player)
	DataService.Release(player)
end)

openCapsuleRemote.OnServerEvent:Connect(function(player)
	local success, result = CapsuleService.OpenCapsule(player)
	capsuleResultRemote:FireClient(player, success, result)
end)

placeItemRemote.OnServerEvent:Connect(function(player, inventoryIndex)
	local success = RoomService.PlaceItem(player, inventoryIndex)
	if success then
		local data = DataService.Get(player)
		RoomVisualService.Refresh(player, data.RoomItems)
	end
end)

-- === Ce que chaque Developer Product accorde à l'achat ===
-- (ignoré silencieusement tant que l'ID vaut 0 dans MonetizationConfig)

MonetizationService.RegisterProductHandler(
	MonetizationConfig.DeveloperProducts.PremiumCapsule,
	function(player)
		local result = CapsuleService.OpenPaidCapsule(player)
		capsuleResultRemote:FireClient(player, true, result)
	end
)

MonetizationService.RegisterProductHandler(
	MonetizationConfig.DeveloperProducts.GuaranteedLegendary,
	function(player)
		local result = CapsuleService.OpenPaidCapsule(player, "Legendaire")
		capsuleResultRemote:FireClient(player, true, result)
	end
)

print("2016 Vault: serveur prêt.")
