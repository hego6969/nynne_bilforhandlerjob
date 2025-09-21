local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "vRP_showroom")

local spawnDirect = Config.spawnDirect
local webhookURL = Config.webhookURL
local sellerPercentage = Config.sellerPercentage or 10

local function sendWebhook(msg)
    if not webhookURL or webhookURL == "" then return end
    PerformHttpRequest(webhookURL, function() end, "POST", json.encode({
        username = "Bilforhandler Log",
        embeds = {{
            title = "🚗 Bilhandel",
            description = msg,
            color = 16753920
        }}
    }), {["Content-Type"] = "application/json"})
end

RegisterServerEvent("bilforhandler:sælgbil")
AddEventHandler("bilforhandler:sælgbil", function(targetId, bilModel, pris, veh_type)
    local sellerSource = source
    local seller_user_id = vRP.getUserId({sellerSource})
    if not seller_user_id then return end

    local target_user_id = vRP.getUserId({targetId})
    if not target_user_id then
        TriggerClientEvent("ox_lib:notify", sellerSource, {
            type = "error",
            description = "Køberen er ikke online!"
        })
        return
    end

    TriggerClientEvent("bilforhandler:tilbud", targetId, sellerSource, bilModel, pris, veh_type)
end)

-- Køber accepterer
RegisterServerEvent("bilforhandler:accepterKøb")
AddEventHandler("bilforhandler:accepterKøb", function(sellerSource, bilModel, pris, veh_type)
    local buyerSource = source
    local buyer_user_id = vRP.getUserId({buyerSource})
    local seller_user_id = vRP.getUserId({sellerSource})

    if not buyer_user_id or not seller_user_id then return end

    if vRP.tryFullPayment({buyer_user_id, pris}) then
        local sellerEarning = math.floor(pris * (sellerPercentage / 100))

        vRP.giveMoney({seller_user_id, sellerEarning})

        exports.oxmysql:execute("SELECT vehicle FROM vrp_user_vehicles WHERE user_id = ? AND vehicle = ?", 
        {buyer_user_id, bilModel}, function(result)
            if result[1] then
                TriggerClientEvent("ox_lib:notify", buyerSource, {
                    type = "error",
                    description = "Du ejer allerede denne bil!"
                })
                return
            end

            vRP.getUserIdentity({buyer_user_id, function(identity)
                local plate = "P "..identity.registration

                exports.oxmysql:execute(
                    "INSERT INTO vrp_user_vehicles (user_id, vehicle, vehicle_plate, veh_type) VALUES (?, ?, ?, ?)",
                    {buyer_user_id, bilModel, plate, veh_type}
                )

                if spawnDirect then
                    TriggerClientEvent("bilforhandler:givBil", buyerSource, bilModel, plate)
                end

                TriggerClientEvent("ox_lib:notify", sellerSource, {
                    type = "success",
                    description = ("Dit salg lykkedes! Du fik %s DKK"):format(sellerEarning)
                })

                TriggerClientEvent("ox_lib:notify", buyerSource, {
                    type = "success",
                    description = spawnDirect and "Du har fået bilen!" or "Bilen er lagt i din garage!"
                })

                sendWebhook(("**Sælger (ID:%s)** solgte en **%s** til **Køber (ID:%s)** for **%s DKK** (Sælger fik %s DKK)\nNummerplade: `%s`"):format(seller_user_id, bilModel, buyer_user_id, pris, sellerEarning, plate))
            end})
        end)
    else
        TriggerClientEvent("ox_lib:notify", buyerSource, {
            type = "error",
            description = "Du har ikke nok penge!"
        })
    end
end)

-- Køber afviser
RegisterServerEvent("bilforhandler:afvisKøb")
AddEventHandler("bilforhandler:afvisKøb", function(sellerSource, bilModel, pris)
    TriggerClientEvent("ox_lib:notify", sellerSource, {
        type = "error",
        description = "Køberen afviste dit tilbud."
    })
end)


RegisterNetEvent('nynne_bilforhandler:checkPerms')
AddEventHandler('nynne_bilforhandler:checkPerms', function()
		local user_id = vRP.getUserId({source})
    if user_id then
        if vRP.hasPermission({user_id, "admin.bilforhandler"}) then
            TriggerClientEvent('opencardealermenu', source)
        else
            TriggerClientEvent("pNotify:SendNotification", source,{text = "Du har ikke adgang.", type = "error", queue = "global", timeout = 12000, layout = "centerRight",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"},killer = true})
        end
    end
end)