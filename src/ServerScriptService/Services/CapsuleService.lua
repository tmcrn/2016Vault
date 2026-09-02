--[[
	CapsuleService.lua
	Gère l'achat/ouverture des Capsules Temporelles 2016. C'est le coeur
	du système "gacha" : tout le calcul se fait ici, côté serveur, jamais
	côté client (sinon un joueur pourrait tricher).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Random_ = Random.new(os.clock() * 1000)

local CapsuleConfig = require(ReplicatedStorage.Modules.CapsuleConfig)
local RarityUtil = require(ReplicatedStorage.Modules.RarityUtil)

local DataService = require(script.Parent.DataService)
local LeaderstatsService = require(script.Parent.LeaderstatsService)
local MonetizationService = require(script.Parent.MonetizationService)

local CapsuleService = {}

-- Trouve l'index d'une rareté dans CapsuleConfig.Rarities à partir de son Id.
local function findRarityIndex(rarityId)
	for index, rarity in ipairs(CapsuleConfig.Rarities) do
		if rarity.Id == rarityId then
			return index
		end
	end
	return nil
end

--[[
	Coeur du tirage, partagé entre la capsule payée en Vues et celle payée
	en Robux. `forceMinRarityId` est optionnel (ex: "Legendaire" pour un
	achat garanti).
]]
local function rollAndGrant(player, data, forceMinRarityId)
	local luckMultiplier = MonetizationService.GetLuckMultiplier(player)
	local forceMinIndex = forceMinRarityId and findRarityIndex(forceMinRarityId) or nil

	local itemName, rarityId, rarityColor, newPity =
		RarityUtil.OpenCapsule(Random_, data.PityCounter, luckMultiplier, forceMinIndex)

	data.PityCounter = newPity
	table.insert(data.Inventory, { Name = itemName, Rarity = rarityId })

	return {
		ItemName = itemName,
		Rarity = rarityId,
		Color = { rarityColor.R, rarityColor.G, rarityColor.B },
	}
end

--[[
	Tente d'ouvrir une capsule "normale" (payée en Vues) pour `player`.
	Retourne (success: boolean, resultOrReason)
	  - si succès : { ItemName, Rarity, Color = {r,g,b} }
	  - si échec  : chaîne expliquant pourquoi (ex: "PAS_ASSEZ_DE_VUES")
]]
function CapsuleService.OpenCapsule(player)
	local data = DataService.Get(player)
	if not data then
		return false, "DONNEES_NON_CHARGEES"
	end

	if data.Cash < CapsuleConfig.CapsuleCost then
		return false, "PAS_ASSEZ_DE_VUES"
	end

	data.Cash -= CapsuleConfig.CapsuleCost
	local result = rollAndGrant(player, data)
	LeaderstatsService.SetCash(player, data.Cash)

	return true, result
end

--[[
	Ouvre une capsule sans toucher au solde de Vues : utilisé quand un
	Developer Product vient d'être payé en Robux (voir MonetizationService).
	`forceMinRarityId` optionnel, ex: "Legendaire" pour le produit
	"Capsule Garantie Légendaire".
	Retourne directement le résultat (pas de raison d'échec possible ici,
	l'achat est déjà confirmé).
]]
function CapsuleService.OpenPaidCapsule(player, forceMinRarityId)
	local data = DataService.Get(player)
	if not data then
		return nil
	end
	return rollAndGrant(player, data, forceMinRarityId)
end

return CapsuleService
