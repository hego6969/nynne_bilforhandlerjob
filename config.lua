Config = {}

-- Spawn bilen direkte hos køberen eller kun i garage
-- true  = bilen spawn'er direkte
-- false = bilen skal hentes fra garage
Config.spawnDirect = false

-- Discord webhook URL for log
Config.webhookURL = "https://discord.com/api/webhooks/1408537820158758973/J6S38GopaM3vc7UzaeXstitxZccWXc7wSZLZ2_KJ_zOwvd_n3yUkcSk48yVtOqy7_dOb"

-- Procentdel af salget, som sælgeren får
Config.sellerPercentage = 15

Config.cardealer = {
    {
        menuPos = vec3(-31.719, -1095.552, 27.274), -- menu åbnes her
        spawntestveh = { 
            pos = vec3( -23.589,-1094.532, 26.895),        -- spawn coords
            heading = 340.197,                           -- valgfri heading
            deleteTime = 300000 -- tiden i millisekunder (her 5 min)
        }
    },
}