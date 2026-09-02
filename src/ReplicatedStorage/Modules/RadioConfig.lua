--[[
	RadioConfig.lua
	Liste des pistes jouables sur la radio de la Chambre Rétro. Les
	`SoundId` sont à 0 par défaut (= pas encore configuré).

	⚠️ IMPORTANT : n'utilise QUE des pistes libres de droits/royalty-free
	(ou dont tu détiens les droits). Pas de vraies chansons commerciales
	(Justin Bieber, etc.) sans licence — Roblox les supprime tôt ou tard
	et ça peut faire suspendre ton compte développeur.

	Pour ajouter une piste :
	1. Trouve un morceau libre de droits (Pixabay Music, Free Music
	   Archive, la bibliothèque audio Roblox...).
	2. Uploade-le sur Roblox : Creator Dashboard → Creations → Audio →
	   Upload. Attends la modération (quelques minutes à quelques heures).
	3. Une fois approuvé, récupère son ID (le nombre dans rbxassetid://ID).
	4. Remplace un des 0 ci-dessous par ce nombre.
]]

local RadioConfig = {}

RadioConfig.Tracks = {
	{ Name = "Piste 1", SoundId = 0 },
	{ Name = "Piste 2", SoundId = 0 },
	{ Name = "Piste 3", SoundId = 0 },
	{ Name = "Piste 4", SoundId = 0 },
}

RadioConfig.Volume = 0.5

return RadioConfig
