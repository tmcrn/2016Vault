--[[
	LeaderboardService.lua
	Classement global des joueurs selon leurs Vues, sauvegardé dans un
	OrderedDataStore (partagé entre TOUS les serveurs du jeu, pas juste
	le tien). Affiché sur un panneau dans chaque Chambre Rétro.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local LeaderboardService = {}

-- Même filet de sécurité que DataService : si l'API DataStore n'est pas
-- accessible, on désactive juste le classement au lieu de tout faire
-- planter.
local LeaderboardStore
do
	local ok, result = pcall(function()
		return DataStoreService:GetOrderedDataStore("Vault2016_Leaderboard_v1")
	end)
	if ok then
		LeaderboardStore = result
	else
		warn("LeaderboardService: OrderedDataStore indisponible (" .. tostring(result) .. "). Classement désactivé pour l'instant.")
	end
end

-- Enregistre/actualise le score d'un joueur (ses Vues actuelles).
function LeaderboardService.SubmitScore(player, cash)
	if not LeaderboardStore then
		return
	end
	local score = math.floor(math.max(cash, 0))
	pcall(function()
		LeaderboardStore:SetAsync(tostring(player.UserId), score)
	end)
end

--[[
	Retourne jusqu'à `count` entrées {UserId, Name, Score}, triées du
	plus haut score au plus bas.
]]
function LeaderboardService.GetTop(count)
	if not LeaderboardStore then
		return {}
	end

	local ok, pages = pcall(function()
		return LeaderboardStore:GetSortedAsync(false, count)
	end)
	if not ok then
		warn("LeaderboardService: échec de lecture du classement: " .. tostring(pages))
		return {}
	end

	local page = pages:GetCurrentPage()
	local results = {}
	for _, entry in ipairs(page) do
		local userId = tonumber(entry.key)
		local name = "Joueur"
		if userId then
			local nameOk, fetchedName = pcall(function()
				return Players:GetNameFromUserIdAsync(userId)
			end)
			if nameOk then
				name = fetchedName
			end
		end
		table.insert(results, { UserId = userId, Name = name, Score = entry.value })
	end
	return results
end

return LeaderboardService
