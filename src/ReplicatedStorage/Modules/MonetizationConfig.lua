--[[
	MonetizationConfig.lua
	IDs des Game Passes et Developer Products, plus les bonus qu'ils
	donnent. Les IDs sont à 0 par défaut (= "pas encore configuré") :
	crée les Game Passes/Developer Products dans Studio (onglet Monetization)
	ou sur le Creator Dashboard, puis remplace les 0 ci-dessous par les
	vrais IDs. Rien d'autre à toucher.
]]

local MonetizationConfig = {}

-- Studio > Monetization > Game Passes > Create (récupère l'ID affiché après création)
MonetizationConfig.GamePasses = {
	DoubleCash = 1965620225,     -- "2x Vues" : double le revenu passif de la Chambre Rétro
	DoubleLuck = 1968430320,     -- "2x Chance" : tire deux fois et garde la meilleure rareté
	ExtraRoomSlot = 1969098263,  -- "+6 Slots Chambre" : plus de place pour poser des objets
}

-- Studio > Monetization > Developer Products > Create
MonetizationConfig.DeveloperProducts = {
	PremiumCapsule = 3711048121,       -- Ouvre une capsule instantanément, sans payer en Vues (30 Robux)
	GuaranteedLegendary = 3711048147,  -- Ouvre une capsule garantie Légendaire ou mieux (100 Robux)
}

-- Slots de base dans la Chambre Rétro (sans aucun Game Pass).
MonetizationConfig.BaseRoomSlots = 6

-- Slots supplémentaires accordés par le Game Pass "ExtraRoomSlot".
MonetizationConfig.ExtraRoomSlotsFromPass = 6

return MonetizationConfig
