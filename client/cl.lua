-- Opret target zone for bilforhandler
for k,v in pairs(Config.cardealer) do
    exports.ox_target:addBoxZone({
        coords = v.menuPos, -- menu åbnes her
        size = vec3(2, 2, 2),
        rotation = 45,
        debug = drawZones,
        options = {
            {
                name = 'Garage',
                icon = 'fa-solid fa-car',
                label = 'Bilforhandler Menu',
                onSelect = function()
                    TriggerServerEvent('nynne_bilforhandler:checkPerms')
                end
            }
        }
    })
end

-- Registrer menu
lib.registerContext({
  id = 'cardealermenu-by-nyn',
  title = 'Bilforhandler Menu',
  options = {
    {
      title = 'Salgs Menu',
      description = 'Sælg køretøj til anden spiller',
      icon = 'car',
      onSelect = function()
        Sellcarmenu()
      end,
    },
    {
      title = 'Spawn testbil',
      description = 'Spawn en bil på testpladsen',
      icon = 'car',
      onSelect = function()
        TestSpawnMenu()
      end,
    },
  }
})

RegisterNetEvent('opencardealermenu')
AddEventHandler('opencardealermenu',function()
    lib.showContext('cardealermenu-by-nyn')
end)

-- Salgs menu
function Sellcarmenu()
    local input = lib.inputDialog("🚗 Sælg bil", {
        {type = "number", label = "Købers ID", placeholder = "fx 12"},
        {type = "input", label = "Bilens model", placeholder = "adder"},
        {type = "number", label = "Pris", placeholder = "100000"},
        {type = "select", label = "Type", options = {
            {label = "Car", value = "car"},
            {label = "Bike", value = "bike"}
        }}
    })

    if not input then return end

    local targetId, bilModel, pris, veh_type = table.unpack(input)
    if not targetId or not bilModel or not pris or not veh_type then
        lib.notify({title = "Bilforhandler", description = "Alle felter skal udfyldes", type = "error"})
        return
    end

    TriggerServerEvent("bilforhandler:sælgbil", targetId, bilModel, pris, veh_type)
end

-- Køber får tilbud
RegisterNetEvent("bilforhandler:tilbud", function(sellerSource, bilModel, pris, veh_type)
    local alert = lib.alertDialog({
        header = "🚗 Køb af bil",
        content = ("Sælger (ID: %s) tilbyder dig en %s for %s DKK\nVil du acceptere?"):format(sellerSource, bilModel, pris),
        centered = true,
        cancel = true,
        labels = {confirm = "Ja", cancel = "Nej"}
    })

    if alert == "confirm" then
        TriggerServerEvent("bilforhandler:accepterKøb", sellerSource, bilModel, pris, veh_type)
    else
        TriggerServerEvent("bilforhandler:afvisKøb", sellerSource, bilModel, pris)
    end
end)

-- Spawn bilen hos køberen, hvis spawnDirect = true
RegisterNetEvent("bilforhandler:givBil")
AddEventHandler("bilforhandler:givBil", function(bilModel, plate)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)

    local vehicleHash = GetHashKey(bilModel)
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do Wait(100) end

    local vehicle = CreateVehicle(vehicleHash, pos.x + 5, pos.y + 5, pos.z, GetEntityHeading(playerPed), true, false)
    SetVehicleNumberPlateText(vehicle, plate)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
end)

-- Test kørsel menu
-- Test kørsel menu
function TestSpawnMenu()
    local input = lib.inputDialog("🚗 Spawn testbil", {
        {type = "input", label = "Bilens model", placeholder = "adder"}
    })

    if not input then return end
    local vehicleName = input[1]
    if not vehicleName or vehicleName == "" then
        lib.notify({title = "Bilforhandler", description = "Indtast en bilmodel!", type = "error"})
        return
    end
    TriggerEvent("dealers:spawnVehicle", vehicleName)
end
-- Spawn testbil
RegisterNetEvent("dealers:spawnVehicle")
AddEventHandler("dealers:spawnVehicle", function(vehicleName)
    local playerPed = PlayerPedId()
    local spawnData = Config.cardealer[1].spawntestveh

    if not spawnData then
        lib.notify({title = "Bilforhandler", description = "Spawn-data mangler i config!", type = "error"})
        return
    end

    local x, y, z = spawnData.pos.x, spawnData.pos.y, spawnData.pos.z
    local heading = spawnData.heading or 0.0
    local deleteTime = spawnData.deleteTime or 300000 -- default 5 min

    local vehicleHash = GetHashKey(vehicleName)
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do Wait(100) end

    local vehicle = CreateVehicle(vehicleHash, x, y, z, heading, true, false)
    SetVehicleNumberPlateText(vehicle, "DEALER")
    --SetPedIntoVehicle(playerPed, vehicle, -1)
    --SetEntityAsMissionEntity(vehicle, true, true)

    -- Slet bilen efter deleteTime
    SetTimeout(deleteTime, function()
        if DoesEntityExist(vehicle) then
            DeleteVehicle(vehicle)
        end
    end)
end)



RegisterCommand("getcoords", function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    print(("X: %.3f, Y: %.3f, Z: %.3f, Heading: %.3f"):format(pos.x, pos.y, pos.z, heading))
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"COORDS", (" %.3f,  %.3f,  %.3f, Heading: %.3f"):format(pos.x, pos.y, pos.z, heading)}
    })
end, false)
