--[[
	MonetizationService.lua
	Gère les Game Passes (vérification de possession, mise en cache) et les
	Developer Products (traitement des achats via ProcessReceipt).
	C'est le seul endroit qui parle à MarketplaceService côté serveur.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConfig = require(ReplicatedStorage.Modules.MonetizationConfig)
local DataService = require(script.Parent.DataService)

local MonetizationService = {}

-- === Game Passes ===

local gamePassCache = {} -- [player][passId] = boolean

local function ownsGamePass(player, passId)
	if not passId or passId == 0 then
		return false -- Game Pass pas encore créé/configuré dans MonetizationConfig
	end

	gamePassCache[player] = gamePassCache[player] or {}
	local cached = gamePassCache[player][passId]
	if cached ~= nil then
		return cached
	end

	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)

	local result = ok and owns or false
	gamePassCache[player][passId] = result
	return result
end

function MonetizationService.HasDoubleCash(player)
	return ownsGamePass(player, MonetizationConfig.GamePasses.DoubleCash)
end

function MonetizationService.HasDoubleLuck(player)
	return ownsGamePass(player, MonetizationConfig.GamePasses.DoubleLuck)
end

function MonetizationService.HasExtraRoomSlot(player)
	return ownsGamePass(player, MonetizationConfig.GamePasses.ExtraRoomSlot)
end

function MonetizationService.GetCashMultiplier(player)
	return MonetizationService.HasDoubleCash(player) and 2 or 1
end

function MonetizationService.GetLuckMultiplier(player)
	return MonetizationService.HasDoubleLuck(player) and 2 or 1
end

function MonetizationService.GetMaxRoomSlots(player)
	local slots = MonetizationConfig.BaseRoomSlots
	if MonetizationService.HasExtraRoomSlot(player) then
		slots += MonetizationConfig.ExtraRoomSlotsFromPass
	end
	return slots
end

Players.PlayerRemoving:Connect(function(player)
	gamePassCache[player] = nil
end)

-- === Developer Products ===

-- [productId] = function(player) -- exécutée quand l'achat est confirmé
local productHandlers = {}

--[[
	Enregistre ce qui doit se passer quand un joueur achète ce Developer
	Product. À appeler depuis Main.server.lua (pour éviter que ce fichier
	ait besoin de connaître CapsuleService, RoomService, etc.).
]]
function MonetizationService.RegisterProductHandler(productId, handler)
	if not productId or productId == 0 then
		return -- ID pas encore configuré, on ignore silencieusement
	end
	productHandlers[productId] = handler
end

-- Empêche de traiter deux fois le même achat (Roblox peut renvoyer le
-- même reçu plusieurs fois tant qu'on ne confirme pas explicitement).
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- Le joueur s'est déconnecté entre l'achat et le traitement :
		-- Roblox réessaiera plus tard.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local data = DataService.Get(player)
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	data.ProcessedReceipts = data.ProcessedReceipts or {}
	if data.ProcessedReceipts[receiptInfo.PurchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local handler = productHandlers[receiptInfo.ProductId]
	local ok = true
	if handler then
		ok = pcall(handler, player)
	end

	if not ok then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	data.ProcessedReceipts[receiptInfo.PurchaseId] = true
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

return MonetizationService
