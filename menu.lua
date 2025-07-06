local menuOpen = false
local selectedOption = 1
local toggleKey = nil -- Will be assigned on startup
local fishingThread = nil
local fishingActive = false

local options = {
    { name = "Refill Fuel", action = "refuel" },
    { name = "Repair Vehicle", action = "repair" },
    { name = "Unlock Vehicle", action = "unlock" },
    { name = "Auto Fish 1", action = "fish1" },
    { name = "Auto Fish 2", action = "fish2" },
    { name = "Stop Fishing", action = "stop_fish" },
    { name = "Exit Menu", action = "exit" }
}

-- First-time key selection
print("Press a key to bind as menu toggle...")
CreateThread(function()
    while not toggleKey do
        Wait(0)
        for key = 0, 359 do
            if IsControlJustPressed(0, key) then
                toggleKey = key
                print("Menu toggle key bound to:", key)
                break
            end
        end
    end
end)

-- Menu thread
CreateThread(function()
    while true do
        Wait(0)
        if toggleKey then
            -- Toggle menu
            if IsControlJustReleased(0, toggleKey) then
                menuOpen = not menuOpen
            end

            if menuOpen then
                -- Menu background
                DrawRect(0.5, 0.5, 0.3, 0.5, 30, 30, 30, 220)
                drawText(0.5, 0.35, "~b~QuickFix Vehicle, Fishing & Player Menu", 0.7)

                for i, opt in ipairs(options) do
                    local y = 0.37 + (i * 0.035)
                    if i == selectedOption then
                        DrawRect(0.5, y + 0.01, 0.28, 0.03, 60, 60, 60, 150)
                        drawText(0.5, y, "→ " .. opt.name, 0.5)
                    else
                        drawText(0.5, y, opt.name, 0.5)
                    end
                end

                -- Navigation
                if IsControlJustReleased(0, 172) then -- UP
                    selectedOption = selectedOption - 1
                    if selectedOption < 1 then selectedOption = #options end
                elseif IsControlJustReleased(0, 173) then -- DOWN
                    selectedOption = selectedOption + 1
                    if selectedOption > #options then selectedOption = 1 end
                elseif IsControlJustReleased(0, 191) then -- ENTER
                    local action = options[selectedOption].action
                    -- Special case for fishing: wait before closing menu to avoid blinking
                    if action == "fish1" or action == "fish2" then
                        menuOpen = false
                        Wait(200) -- Small delay to prevent blinking
                        handleAction(action)
                    else
                        handleAction(action)
                        menuOpen = false
                    end
                end
            end
        end
    end
end)

function drawText(x, y, text, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function handleAction(action)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if action == "refuel" then
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            SetVehicleFuelLevel(vehicle, 100.0)
            print("[QuickFix] Fuel refilled to 100.")
        else
            print("[QuickFix] Not in a vehicle.")
        end

    elseif action == "repair" then
        local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 70)
        if vehicle and DoesEntityExist(vehicle) then
            TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
            Wait(10000)
            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleUndriveable(vehicle, false)
            ClearPedTasksImmediately(playerPed)
            print("[QuickFix] Vehicle repaired.")
        else
            print("[QuickFix] No nearby vehicle.")
        end

    elseif action == "unlock" then
        local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 70)
        if vehicle and DoesEntityExist(vehicle) then
            SetVehicleDoorsLocked(vehicle, 1)
            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
            print("[QuickFix] Vehicle unlocked.")
        else
            print("[QuickFix] No nearby vehicle.")
        end

    elseif action == "fish1" then
        startFishing("fishing:setFishing")

    elseif action == "fish2" then
        startFishing("fishing:setFishing2")

    elseif action == "stop_fish" then
        stopFishing()

    elseif action == "exit" then
        print("[QuickFix] Menu closed.")
    end
end

-- Fishing automation
function startFishing(eventName)
    if fishingActive then
        print("[Fishing] Already fishing!")
        return
    end

    fishingActive = true
    fishingThread = CreateThread(function()
        while fishingActive do
            TriggerServerEvent(eventName, true)
            Wait(0)
            TriggerServerEvent('fishing:rewardPlayer')
            Wait(50)
        end
    end)
    print("[Fishing] Started auto-fishing with event:", eventName)
end

function stopFishing()
    if fishingActive then
        fishingActive = false
        print("[Fishing] Stopped auto-fishing.")
    else
        print("[Fishing] No fishing in progress.")
    end
end
