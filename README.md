# 2016 Vault 🕹️✨

Jeu Roblox de collection/gacha sur le thème "nostalgie 2016" : ouvre des
capsules temporelles, obtiens des objets cultes de raretés différentes,
place-les dans ta Chambre Rétro pour générer des Vues en continu.

Ce dossier contient **tout le code déjà fonctionnel** : système de
capsules pondéré avec pity, sauvegarde des données, revenu passif,
interface joueur générée en Lua. Tu n'as rien à assembler à la main dans
Studio — seulement à connecter Rojo et appuyer sur Play.

## Étape 1 — Installer les outils (une seule fois)

1. **Roblox Studio** : télécharge-le sur https://create.roblox.com/ (bouton
   "Start Creating" → connecte-toi avec ton compte Roblox).
2. **Rojo** (l'outil qui synchronise ce dossier de code avec Studio) :
   - Installe [Aftman](https://github.com/LPGhatguy/aftman#installation)
     (le gestionnaire d'outils recommandé par la communauté Roblox).
   - Dans un terminal, place-toi à la racine de ce repo puis lance :
     ```
     aftman install
     ```
3. **Plugin Rojo dans Studio** : ouvre Roblox Studio → onglet "Plugins" →
   "Manage Plugins" → cherche "Rojo" dans le Toolbox → installe-le.

## Étape 2 — Générer le fichier de jeu

⚠️ Le plugin Rojo (`rojo serve` + Connect) plante parfois avec une erreur
`protocolVersion` selon la version installée. La méthode la plus fiable,
surtout pour un premier jeu, est de **construire un fichier de jeu complet**
directement :

1. Dans un terminal, à la racine du repo, lance :
   ```
   rojo build default.project.json --output 2016Vault.rbxlx
   ```
2. Ouvre **Roblox Studio** → **File → Open from File...** → sélectionne
   `2016Vault.rbxlx`. Tout le code est déjà à sa place, rien à copier.
3. **Ajoute un sol** (le build ne contient pas de Workspace/terrain) :
   - Clic droit sur **Workspace** dans l'Explorer → Insert Object →
     **SpawnLocation**.
   - Sélectionne-le, et dans Properties mets `Size` à `50, 1, 50`,
     `Position` à `0, 0, 0`, et coche `Anchored`.
4. Appuie sur **Play** pour tester.
5. Une fois content : **File → Publish to Roblox As...** pour le mettre
   en ligne sur ton compte.

Si tu modifies le code plus tard, relance `rojo build` puis rouvre le
fichier généré — ça écrase les changements faits à la main dans Studio
(sol, Game Passes...), donc pense à les refaire après un rebuild.

### Alternative (sync en direct, si le plugin fonctionne chez toi)

1. Ouvre Roblox Studio → "New" → modèle **Baseplate**, publie-le une
   première fois.
2. Dans un terminal, lance `rojo serve`.
3. Dans Studio, onglet "Plugins" → "Rojo" → "Connect". Le code se
   synchronise en direct à chaque modification de fichier.

## Étape 4 — Tester

Clique sur "Play" en haut de Studio. Tu dois voir :
- Un bouton rose **"🕹️ Ouvrir une Capsule 2016"** en bas de l'écran.
- Ton compteur **"Vues"** dans le tableau des scores à droite.
- En cliquant sur le bouton, un objet apparaît avec sa rareté (Commun,
  Rare, Épique, Légendaire, ✨Viral✨).

## Comment le jeu est organisé

```
2016Vault/
  default.project.json          → dit à Rojo où mettre chaque fichier
  src/
    ReplicatedStorage/Modules/
      CapsuleConfig.lua          → TOUTE la config : raretés, objets, prix
      RarityUtil.lua             → le tirage au sort pondéré + pity
    ServerScriptService/
      Main.server.lua            → point d'entrée, crée les RemoteEvents
      Services/
        DataService.lua          → sauvegarde/chargement (DataStore)
        LeaderstatsService.lua   → le compteur "Vues" affiché aux joueurs
        CapsuleService.lua       → logique d'ouverture d'une capsule
        RoomService.lua          → revenu passif de la Chambre Rétro
    StarterPlayer/StarterPlayerScripts/
      CapsuleUIController.client.lua → toute l'interface (bouton + popup)
```

**Pour ajouter du contenu** (nouveaux objets, nouvelles raretés, changer
les prix) : modifie uniquement `CapsuleConfig.lua`, rien d'autre à toucher.

## Prochaines étapes (roadmap monétisation)

Ce qui est déjà en place = la boucle de jeu gratuite complète. Pour
monétiser, dans l'ordre de priorité :

1. **Game Passes** (Studio → Monetization → Game Passes) : "2x Vues",
   "2x Chance", slots de Chambre Rétro supplémentaires. Se vérifient avec
   `MarketplaceService:UserOwnsGamePassAsync`.
2. **Developer Products** : capsule premium à l'unité, "capsule garantie
   Légendaire". Se déclenchent via `MarketplaceService:PromptProductPurchase`.
3. **Battle Pass hebdomadaire** thématique (nouvel objet du moment lié à
   la trend TikTok en cours).
4. **Anti-triche renforcé** avant de sortir de vrais paiements : limiter
   la fréquence d'ouverture côté serveur (déjà partiellement fait via le
   coût en Vues), logs des transactions.

⚠️ Respecte les [règles Roblox sur les objets aléatoires](https://en.help.roblox.com/hc/en-us/articles/8592065628180) :
les probabilités de chaque rareté doivent être affichées publiquement dans
le jeu avant tout achat réel de capsule.
