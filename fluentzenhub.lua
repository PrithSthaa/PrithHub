    local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    local Window = Fluent:CreateWindow({
        Title = "Zen Hub " .. Fluent.Version,
        SubTitle = "by Prith.Stha",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
    })

    -- // // // Services // // // --
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualUser = game:GetService("VirtualUser")
    local HttpService = game:GetService("HttpService")
    local GuiService = game:GetService("GuiService")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    local CoreGui = game:GetService('StarterGui')
    local ContextActionService = game:GetService('ContextActionService')
    local UserInputService = game:GetService('UserInputService')

    -- // // // Locals // // // --
    local LocalPlayer = Players.LocalPlayer
    local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = LocalCharacter:FindFirstChild("HumanoidRootPart")
    local UserPlayer = HumanoidRootPart:WaitForChild("user")
    local ActiveFolder = Workspace:FindFirstChild("active")
    local FishingZonesFolder = Workspace:FindFirstChild("zones"):WaitForChild("fishing")
    local TpSpotsFolder = Workspace:FindFirstChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
    local NpcFolder = Workspace:FindFirstChild("world"):WaitForChild("npcs")
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui", PlayerGui)
    local shadowCountLabel = Instance.new("TextLabel", screenGui)
    local RenderStepped = RunService.RenderStepped
    local WaitForSomeone = RenderStepped.Wait

    -- // // // Features List // // // --


    -- // // // Variables // // // --
    local TS = game:GetService("TeleportService")
    local Light = game:GetService("Lighting")

    ----------------------------------------Unknown's Custom Function's
    local function GetChar()
        return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    end
    local function GetRoot()
        return GetChar():FindFirstChild("HumanoidRootPart") or GetChar():WaitForChild("HumanoidRootPart")
    end
    local function GetHum()
        return GetChar():FindFirstChild("Humanoid") or GetChar():WaitForChild("Humanoid")
    end
    local function ReturnRod()
        local BPRod = LocalPlayer.Backpack:FindFirstChild("rod/client", true)
        local CharRod = GetChar():FindFirstChild("rod/client", true)
        if BPRod then
            return BPRod.Parent.Name
        elseif CharRod then
            return CharRod.Parent.Name
        end
    end
    ----------------------------------------

    --Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
    --    local Tabs = {
--        Main = Window:AddTab({ Title = "Main", Icon = "house" }),
--        AutoTab = Window:AddTab({ Title = "Auto", Icon = "code" }),
--        TeleportTab = Window:AddTab({ Title = "Teleport", Icon = "map" }),
--        PlayerTab = Window:AddTab({ Title = "Character", Icon = "user" }),
--        ShopTab = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
--        MiscTab = Window:AddTab({ Title = "Miscellaneous", Icon = "star" }),
--        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
--    }
local Tabs = {
    AutoTab = Window:AddTab({ Title = "Fishing", Icon = "" }),
    EventTab = Window:AddTab({ Title = "Event", Icon = "" }),
    TeleportTab = Window:AddTab({ Title = "Teleport", Icon = "" }),
    PlayerTab = Window:AddTab({ Title = "Character", Icon = "" }),
    ShopTab = Window:AddTab({ Title = "Shop", Icon = "" }),
    MiscTab = Window:AddTab({ Title = "Miscellaneous", Icon = "" }),
    DupeTab = Window:AddTab({Title = "Dupe", Icon = ""}),
    Settings = Window:AddTab({ Title = "UI Settings", Icon = "" })
}

 Fluent:Notify({
            Title = "Notification",
            Content = "Success",
            SubContent = "Thank you for using this script ! ", -- Optional
            Duration = 7 -- Set to nil to make the notification not disappear
        })


    --Auto Fishing
    local Options = Fluent.Options

    local AutoEquipToggle;
    local AutoCastToggle;
    local AutoShakeToggle;
    local AutoFishingToggle;
    local FreezeCharacterToggle;

    local Time = 0
    local abcd
    local hours, minutes, seconds

    local function updateTime()
        Time = math.floor(workspace.DistributedGameTime)

        hours = math.floor(Time / 3600)
        minutes = math.floor((Time % 3600) / 60)
        seconds = Time % 60
    end

    local aaaabbbb = Tabs.AutoTab:AddParagraph({
        Title = "Time Tracker",
        Content = abcd
    })

    RunService.Heartbeat:Connect(function()
        updateTime()
        abcd = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        aaaabbbb:SetDesc(abcd)
    end)


local Section = Tabs.AutoTab:AddSection("Main")

 -- Auto Equip Toggle
AutoEquipToggle = Tabs.AutoTab:AddToggle("autoequip", {Title = "Auto Equip", Default = false })

AutoEquipToggle:OnChanged(function()
    if AutoEquipToggle.Value then
        print("Auto Equip enabled.")
        task.spawn(function()
            while AutoEquipToggle.Value and task.wait() do
                if LocalPlayer.Backpack:FindFirstChild(ReturnRod()) and not GetChar():FindFirstChild(ReturnRod()) then
                    ReplicatedStorage.packages.Net["RE/Backpack/Equip"]:FireServer(LocalPlayer.Backpack:FindFirstChild(ReturnRod()))
                end
                task.wait(0.2)
            end
        end)
    else
        print("Auto Equip disabled.")
    end
end)

AutoEquipToggle:SetValue(false)

-- Auto Cast Toggle
AutoCastToggle = Tabs.AutoTab:AddToggle("autocast", {Title = "Auto Cast", Default = false })

AutoCastToggle:OnChanged(function()
    if AutoCastToggle.Value then
        task.spawn(function()
            while AutoCastToggle.Value do
                task.wait()
                if not LocalPlayer.PlayerGui:FindFirstChild("shakeui") and not LocalPlayer.PlayerGui:FindFirstChild("reel") then
                    if GetChar():FindFirstChild(ReturnRod()) then
                        GetChar()[ReturnRod()].events.cast:FireServer(100, 1)
                    end
                end
            end
        end)
    else
        print("Auto Cast disabled.")
    end
end)

-- Auto Shake Toggle
local __Alchemy = __Alchemy or {
    AutoShake = false,
    AutoFishing = false,
    methodFishing = "Mouse",
    Connection = nil
}



local AutoShakeToggle = Tabs.AutoTab:AddToggle("autoshake", {Title = "Auto Shake", Default = false })

AutoShakeToggle:OnChanged(function()
    if Options.autoshake.Value then
        __Alchemy.AutoShake = true
        if not __Alchemy.Connection then
            __Alchemy.Connection = RunService.RenderStepped:Connect(function()
                if __Alchemy.AutoShake or __Alchemy.AutoFishing then
                    if __Alchemy.methodFishing == "Mouse" then
                        if LocalPlayer.PlayerGui:FindFirstChild("shakeui") then
                            local button = LocalPlayer.PlayerGui:FindFirstChild("shakeui").safezone:FindFirstChild("button")
                            if button then
                                button.Size = UDim2.new(1000, 0, 1000, 0)
                                VirtualUser:Button1Down(Vector2.new(1, 1))
                                VirtualUser:Button1Up(Vector2.new(1, 1))
                            end
                        end
                    end
                end
            end)
        end
    else
        __Alchemy.AutoShake = false
        if not __Alchemy.AutoFishing and __Alchemy.Connection then
            __Alchemy.Connection:Disconnect()
            __Alchemy.Connection = nil
        end
    end
end)


-- Auto Reel Toggle

-- Initialize isReels variable
local isReels = false  -- Auto Fishing Toggle 
local AutoFishingToggle = Tabs.AutoTab:AddToggle("autofishing", {Title = "Auto Fishing", Default = false })  

AutoFishingToggle:OnChanged(function()
    print("Auto Fishing Toggle changed:", AutoFishingToggle.Value)
    
    if AutoFishingToggle.Value then
        task.spawn(function()
            while AutoFishingToggle.Value do
                task.wait()
                local success, err = pcall(function()
                    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                    if playerGui:FindFirstChild("reel") then
                        print("Reel UI found.")
                        local streakText = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("user"):FindFirstChild("streak")
                        if streakText then
                            -- Removed the conditions related to MissSomeCatch and MissWhenStreak
                            if not isReels then
                                wait(0.7)
                                game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished "):FireServer(100, true) -- Assuming true for PerfectCatch 
                                isReels = true
                                print("Reels Complete")
                                
                                -- Adjust player bar size
                                local playerbar = playerGui:FindFirstChild("reel"):FindFirstChild("bar"):FindFirstChild("playerbar")
                                if playerbar then
                                    playerbar.Size = UDim2.new(1, 0, 1, 0)
                                end
                                
                                wait(0.7) -- ttjy credit 
                                isReels = false
                            end
                        else
                            print("Streak text not found.")
                        end
                    else
                        print("Reel UI not found.")
                        isReels = false
                    end
                end)
                
                if not success then
                    print("Error in AutoFishingToggle:", err)
                end
            end
        end)
    else
        -- If the Auto Fishing toggle is turned off, reset isReels
        isReels = false
        print("Auto Fishing disabled.")
    end
end)






    -- Freeze Character Toggle
    local FreezeCharacterToggle = Tabs.AutoTab:AddToggle("freezecharacter", {Title = "Freeze Character", Default = false })

    FreezeCharacterToggle:OnChanged(function()
        if GetHum() then
            if Options.freezecharacter.Value then
                GetHum().WalkSpeed = 0
                GetHum().JumpPower = 0
            else
                GetHum().WalkSpeed = 16
                GetHum().JumpPower = 50
            end
        end
    end)

    -- Button for TP best C$ & exp Farm
    Tabs.AutoTab:AddButton({
        Title = "TP best C$ & exp Farm",
        Description = "Teleport to the best cash and experience farm location.",
        Callback = function()
            local location = CFrame.new(-3595.80, 131.70, 571.24)
            GetHum():ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.1)
            GetRoot().CFrame = location
        end
    })



    -- Spawn Bosses

    local Section = Tabs.EventTab:AddSection("Spawn")

local Toggle = Tabs.EventTab:AddToggle("MyToggle", {Title = "Toggle", Default = false })

local running = false -- Flag to control the loop

Toggle:OnChanged(function()
    running = Options.MyToggle.Value
    print("Toggle changed:", running)

    if running then
        task.spawn(function()
            while running do 
                task.wait(__Alchemy.TotemDelay)
                pcall(function()
                    if __Alchemy.autoTotemUntilKraken and hasTotem("Sundial Totem") and not krakenSpawn() then
                        local totemz = "Sundial Totem"
                        local player = game:GetService("Players").LocalPlayer
                        if not player.Character:FindFirstChild(totemz) and player.Backpack:FindFirstChild(totemz) then
                            local args = {player.Backpack:FindFirstChild(totemz)}
                            game:GetService("ReplicatedStorage"):WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/Backpack/Equip"):FireServer(unpack(args))
                        end
                        task.wait()
                        local RealTotem = player.Character:FindFirstChild(totemz)
                        if RealTotem then
                            RealTotem:Activate()
                        end
                    end
                end)
            end
        end)
    end
end)




    local Section = Tabs.TeleportTab:AddSection("Islands")

    -- Teleport
    -- Define a dictionary of island coordinates for teleportation
    local islandCoordinates = {
        ["Forsaken Shores"] = CFrame.new(-2509, 135, 1568),
        ["Roslit Bay"] = CFrame.new(-1472, 132, 710),
        ["Sunstone Island"] = CFrame.new(-916.835876, 135.842087, -1125.71436),
        ["Moosewood"] = CFrame.new(387.319153, 134.500031, 255.297958),
        ["Snowcap Island"] = CFrame.new(2597.84912, 135.283859, 2417.89453),
        ["Terrapin Island"] = CFrame.new(-167.348587, 145.085602, 1938.59583),
        ["Statue Of Sovereignty"] = CFrame.new(20.0280285, 159.014709, -1041.87463),
        ["Vertigo"] = CFrame.new(-112.719063, -515.299377, 1136.88416),
        ["The Depths"] = CFrame.new(945.280334, -711.662109, 1259.22156),
        ["Mushgrove Swamp"] = CFrame.new(2445.54224, 130.904053, -679.550842),
        ["Desolate Deep"] = CFrame.new(-1654.97, -213.68, -2845.95),
        ["Enchant Room"] = CFrame.new(1308.28259, -805.292236, -98.5643768),
        ["Roslit Volcano"] = CFrame.new(-1956.2760009765625, 193.0233612060547, 271.4600524902344),
        ["Brine Pool"] = CFrame.new(-1787.59717, -118.740646, -3384.49683),
        ["The Arch"] = CFrame.new(1007.4986, 131.516281, -1267.97058),
        ["Ancient Isles"] = CFrame.new(6063.52002, 195.18013, 285.97113),
        ["Rod Crafting"] = CFrame.new(-3161.23511, -747.214539, 1701.67944),
        ["Ancient Waterfall"] = CFrame.new(5800.40088, 135.301468, 406.355682),
        ["Snow Globe"] = CFrame.new(-101.126625, 364.635834, -9492.83594),
        ["Northern Summit"] = CFrame.new(19535.4453, 132.670074, 5293.35547),
        ["Glacial Grotto"] = CFrame.new(20015.3262, 1136.42773, 5531.2583),
        ["Cryogenic Canal"] = CFrame.new(20130, 670, 5486),
        ["Frigid Cavern"] = CFrame.new(19842, 438, 5617),
        ["Grand Reef"] = CFrame.new(-3580.25952, 150.961731, 515.507812),
        ["Keepers Altar"] = CFrame.new(1380, -805, -300),
        ["Birch Cay"] = CFrame.new(1700, 125, -2500),
        ["Earmark Island"] = CFrame.new(1230, 125, 575),
        ["Haddock Rock"] = CFrame.new(-530, 125, -425),
        ["Harvesters Spike"] = CFrame.new(-1264.76, 134.42, 1582.46),
        ["Northern Expedition"] = CFrame.new(19531.88, 132.67, 5294.57),
        ["Ancient Archives"] = CFrame.new(-3155.02, -754.82, 2193.14),
    }


    -- Dropdown menu for selecting an island to teleport
    local selectedIsland = "None" -- Variable to store the selected island

    -- Dropdown creation
    local Dropdown = Tabs.TeleportTab:AddDropdown("Dropdown", {
        Title = "Island Selector",
        Values = {
            "None", "Grand Reef", "Moosewood", "Roslit Bay", "Roslit Volcano", 
            "Mushgrove Swamp", "Terrapin Island", "Snowcap Island", "Sunstone Island", 
            "Forsaken Shores", "Statue Of Sovereignty", "Keepers Altar", "Vertigo",
            "The Depths", "Desolate Deep", "Brine Pool", "Ancient Isles", "Ancient Archives",
            "Earmark Island", "Haddock Rock", "The Arch", "Birch Cay", "Harvesters Spike", 
            "Northern Expedition"
        },
        Multi = false,
        Default = 1, -- Default value is the first item in the list
    })

    -- Set initial value of the dropdown
    Dropdown:SetValue("None")

    -- Handle value changes in the dropdown
    Dropdown:OnChanged(function(Value)
        selectedIsland = Value -- Update selected island when dropdown value changes
        print("Selected Island: " .. selectedIsland) -- Debug message
    end)

    -- Button creation for teleportation
    local islandButton = Tabs.TeleportTab:AddButton({
        Title = "Teleport To Island",
        Description = "Teleport to the selected island.",
        Callback = function()
            if selectedIsland == "None" or not islandCoordinates[selectedIsland] then
                print("Please select a valid island to teleport.") -- Debug message for invalid selection
            else
                local targetCFrame = islandCoordinates[selectedIsland]
                print("Teleporting to: " .. selectedIsland) -- Debug message for teleport
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = targetCFrame -- Teleport the player
                else
                    print("Player character or HumanoidRootPart not found.") -- Debug message for errors
                end
            end
        end
    })


    local Section = Tabs.TeleportTab:AddSection("Custom")

    --custom teleport
    local Input = Tabs.TeleportTab:AddInput("TeleportInput", {
        Title = "Teleport to Coordinates",
        Default = "", -- Default value (empty initially)
        Placeholder = "X, Y, Z", -- Placeholder text
        Numeric = false, -- Allow non-numeric input
        Finished = true, -- Only calls the callback when the user presses Enter
        Callback = function(Text)
            -- Attempt to parse the coordinates
            local success, coordinates = pcall(function()
                -- Split input by commas to extract X, Y, and Z
                local splitText = string.split(Text, ",")
                assert(#splitText == 3, "Please enter three coordinates separated by commas.")
                
                -- Convert input strings to numbers
                local x = tonumber(splitText[1])
                local y = tonumber(splitText[2])
                local z = tonumber(splitText[3])
                assert(x and y and z, "Coordinates must be valid numbers.")
                
                -- Return the coordinates as a Vector3 object
                return Vector3.new(x, y, z)
            end)

            -- Check if the input was valid
            if success then
                -- Teleport the player to the new coordinates
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(coordinates) -- Teleport the player
                    print("Teleported to:", coordinates) -- Debug message
                else
                    print("Player character or HumanoidRootPart not found.") -- Debug message for missing parts
                end
            else
                -- If input was invalid, warn the user
                warn("Invalid input for coordinates:", coordinates)
            end
        end
    })
    -- The OnChanged event is no longer needed as we are calling the callback when the user presses Enter
    -- Save Current Location Button
    local SaveLocationButton = Tabs.TeleportTab:AddButton({
        Title = "Save Current Location",
        Description = "Saves your current location for teleporting later.",
        Callback = function()
            savedCFrame = GetRoot().CFrame;
            Fluent:Notify({
                Title = "Location Saved",
                Content = "Your current location has been saved successfully.",
                SubContent = nil,  -- Optional, not provided
                Duration = 5 -- Duration of 5 seconds
            })
        end
    })

    -- Teleport to Saved Location Button
    local TeleportToSavedLocationButton = Tabs.TeleportTab:AddButton({
        Title = "Teleport to Saved Location",
        Description = "Teleports you to the previously saved location.",
        Callback = function()
            if savedCFrame then
                GetRoot().CFrame = savedCFrame;
                Fluent:Notify({
                    Title = "Teleport Successful",
                    Content = "You have been teleported to the saved location.",
                    SubContent = nil,  -- Optional, not provided
                    Duration = 5 -- Duration of 5 seconds
                })
            else
                Fluent:Notify({
                    Title = "Teleport Failed",
                    Content = "No location saved yet. Please save a location first.",
                    SubContent = nil,  -- Optional, not provided
                    Duration = 5 -- Duration of 5 seconds
                })
            end
        end
    })

    -- Copy XYZ Coordinates Button
    local CopyCoordinatesButton = Tabs.TeleportTab:AddButton({
        Title = "Copy XYZ",
        Description = "Copies your current XYZ coordinates to clipboard.",
        Callback = function()
            -- Get the player's character and humanoid root part
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                local currentPosition = humanoidRootPart.Position

                -- Copy the XYZ coordinates as a string to the clipboard, without labels
                local formattedCoordinates = string.format("%.2f, %.2f, %.2f", 
                    currentPosition.X, currentPosition.Y, currentPosition.Z)
                
                -- Copy the formatted coordinates string to the clipboard (Use setclipboard for Roblox environments)
                setclipboard(formattedCoordinates)
                
                -- Notify the user that the coordinates were copied
                Fluent:Notify({
                    Title = "Copy Successful",
                    Content = "XYZ Coordinates have been copied to clipboard.",
                    SubContent = nil,  -- Optional, not provided
                    Duration = 5 -- Duration of 5 seconds
                })
            else
                -- Notify the user that the humanoid root part is missing
                Fluent:Notify({
                    Title = "Copy Failed",
                    Content = "Character or HumanoidRootPart not found.",
                    SubContent = nil,  -- Optional, not provided
                    Duration = 5 -- Duration of 5 seconds
                })
            end
        end
    })

    --Player
    -- WalkSpeed Slider
    local Section = Tabs.PlayerTab:AddSection("Player")

    local WalkSpeedSlider = Tabs.PlayerTab:AddSlider("WalkSpeed", {
        Title = "WalkSpeed",
        Description = "Adjust your WalkSpeed",
        Default = 16,  -- Initial WalkSpeed value
        Min = 16,      -- Minimum value for WalkSpeed
        Max = 800,    -- Maximum value for WalkSpeed
        Rounding = 1,  -- Round the value to 1 decimal place
        Callback = function(Value)
            GetHum().WalkSpeed = Value  -- Update WalkSpeed to the selected value
            print("WalkSpeed changed:", Value)  -- Debug log for value change
        end
    })

    -- JumpPower Slider
    local JumpPowerSlider = Tabs.PlayerTab:AddSlider("JumpPower", {
        Title = "Jump Power",
        Description = "Adjust your Jump Power",
        Default = 50,  -- Initial JumpPower value
        Min = 50,      -- Minimum value for JumpPower
        Max = 800,    -- Maximum value for JumpPower
        Rounding = 1,  -- Round the value to 1 decimal place
        Callback = function(Value)
            GetHum().JumpPower = Value  -- Update JumpPower to the selected value
            print("JumpPower changed:", Value)  -- Debug log for value change
        end
    })

    local Section = Tabs.PlayerTab:AddSection("Game")

    -- Walk on Water Toggle
    local WalkOnWaterToggle = Tabs.PlayerTab:AddToggle("WalkOnWater", {
        Title = "Walk on Water",
        Default = false,
    })

    WalkOnWaterToggle:OnChanged(function(Value)
        _G.WalkWater = Value  -- Update WalkWater global variable
        print("Walk on Water Toggle changed:", Value)
        
        -- Create WaterPlate if it doesn't exist
        if not workspace:FindFirstChild("Water Plate") then
            local WaterPlate = Instance.new("Part")
            WaterPlate.Name = "Water Plate"
            WaterPlate.Size = Vector3.new(1000, 1, 1000)
            WaterPlate.Position = Vector3.new(0, -80, 0)
            WaterPlate.Anchored = true
            WaterPlate.Transparency = 1
            WaterPlate.CanCollide = true
            WaterPlate.Parent = workspace

            task.spawn(function()
                while task.wait() do
                    if _G.WalkWater then
                        WaterPlate.Position = Vector3.new(GetRoot().Position.X, 126, GetRoot().Position.Z)
                    else
                        WaterPlate.Position = Vector3.new(0, -80, 0)
                    end
                end
            end)
        end
    end)

    -- Infinity Oxygen Water Toggle
    local InfinityOxygenWaterToggle = Tabs.PlayerTab:AddToggle("InfinityOxygenWater", {
        Title = "Infinity Oxygen Water",
        Default = false,
    })

--    InfinityOxygenWaterToggle:OnChanged(function(Value)
 --       local oxygen = GetChar().client.oxygen
 --       if oxygen then
 --           oxygen.Disabled = Value  -- Toggle oxygen status
 --       end
--print("Infinity Oxygen Water Toggle changed:", Value)
 --   end)

    -- Infinity Oxygen Peak Toggle
    local InfinityOxygenPeakToggle = Tabs.PlayerTab:AddToggle("InfinityOxygenPeak", {
        Title = "Infinity Oxygen Peak",
        Default = false,
    })

---    InfinityOxygenPeakToggle:OnChanged(function(Value)
--        local oxygenPeak = GetChar().client['oxygen(peaks)']
 --       if oxygenPeak then
--            oxygenPeak.Disabled = Value  -- Toggle oxygen peak status
 --       end
--        print("Infinity Oxygen Peak Toggle changed:", Value)
--    end)

    -- Infinity Temperature Toggle
    local InfinityTemperatureToggle = Tabs.PlayerTab:AddToggle("InfinityTemperature", {
        Title = "Infinity Temperature",
        Default = false,
    })

--    InfinityTemperatureToggle:OnChanged(function(Value)
 --       local temperature = GetChar().client.temperature
 --       if temperature then
 --           temperature.Disabled = Value  -- Toggle temperature status
 --       end
 --       print("Infinity Temperature Toggle changed:", Value)
 --   end)


    --shop
    local Section = Tabs.ShopTab:AddSection("Sell")

    -- Sell Hand Button
    local sellHandButton = Tabs.ShopTab:AddButton({
        Title = "Sell Hand",
        Description = "Sells your hand item",
        Callback = function()
            ReplicatedStorage.events.Sell:InvokeServer()  -- Trigger the Sell event
        end
    })

    -- Sell All Button
    local sellAllButton = Tabs.ShopTab:AddButton({
        Title = "Sell All",
        Description = "Sells all items in your inventory",
        Callback = function()
            ReplicatedStorage.events.SellAll:InvokeServer()  -- Trigger the SellAll event
        end
    })

    -- TP Merchant Button
    local tpMerchantButton = Tabs.ShopTab:AddButton({
        Title = "TP Sell",
        Description = "Teleports to the merchant",
        Callback = function()
            local location = CFrame.new(466, 150, 228)  -- Merchant's location
            GetHum():ChangeState(Enum.HumanoidStateType.Jumping)  -- Set jumping state
            task.wait(0.1)  -- Small delay
            GetRoot().CFrame = location  -- Teleport to the merchant's location
        end
    })


local Section = Tabs.ShopTab:AddSection("Totem")


local Group = "Item"
local Itemsname = {
    -- Totems
    "Sundial Totem",
    "Eclipse Totem",
    "Aurora Totem",
    "Meteor Totem",
    "Blizzard Totem",
    "Avalanche Totem",
    "Tempest Totem",
    "Smokescreen Totem",
    "Windset Totem",
    "Zeus Storm Totem",
    "Poseidon Wrath Totem",

    -- Equipment & Gear
    "GPS",
    "Fish Radar",
    "Glider",
    "Pickaxe",
    "Advanced Glider",
    "Basic Diving Gear",
    "Advanced Diving Gear",
    "Flippers",
    "Super Flippers",
    "Tidebreaker",
    
    -- Oxygen Tanks
    "Basic Oxygen Tank",
    "Beginner Oxygen Tank",
    "Intermediate Oxygen Tank",
    "Advanced Oxygen Tank",

    -- Miscellaneous
    "Winter Cloak",

    -- Baits and Geodes

    -- Rods

}



-- Assuming you have a dropdown and slider defined as shown in your code
local itemsDropdown = Tabs.ShopTab:AddDropdown("Buy Totem", {
    Title = "Buy Totem",
    Values = {
        "Sundial Totem",
        "Eclipse Totem",
        "Aurora Totem",
        "Meteor Totem",
        "Blizzard Totem",
        "Avalanche Totem",
        "Tempest Totem",
        "Smokescreen Totem",
        "Windset Totem",
        "Zeus Storm Totem",
        "Poseidon Wrath Totem",
    },
    Multi = false,
    Default = 1,
})


local itemAmountInput = Tabs.ShopTab:AddInput("ItemAmount", {
    Title = "Amount (Press Enter)",
    Default = "1", -- Default value set to 1
    Placeholder = "Enter amount",
    Numeric = true, -- Ensures only numbers are allowed
    Finished = true, -- Calls the callback only when Enter is pressed
    Callback = function(Value)
        print("Amount Input changed:", Value)
    end
})

-- Button to purchase the item
local buyItem = Tabs.ShopTab:AddButton({
    Title = "Purchase Totem",
    Description = "Buy the selected Totem",
    Callback = function()
        -- Debug: Print objects
        print("Dropdown Object:", itemsDropdown)
        print("Input Object:", itemAmountInput)

        -- Check if dropdown and input are initialized correctly
        if itemsDropdown and itemAmountInput then
            local selectedItem = itemsDropdown.Value
            local amount = tonumber(itemAmountInput.Value) or 1 -- Convert to number, default to 1 if invalid

            -- Validate the amount
            if amount < 1 then
                print("Error: Amount must be at least 1.")
                return
            end
            
            Window:Dialog({
                Title = "Confirm Purchase",
                Content = "Are you sure you want to purchase " .. tostring(amount) .. " " .. tostring(selectedItem) .. "?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            -- Debugging print statements
                            print("Selected Item:", selectedItem)
                            print("Amount:", amount)

                            -- Check if selectedItem and amount are valid
                            if selectedItem and amount then
                                game:GetService("ReplicatedStorage").events.purchase:FireServer(selectedItem, Group, nil, amount)
                                print("Purchased " .. amount .. " of " .. selectedItem)
                            else
                                print("Error: Invalid item or amount.")
                            end
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the purchase.")
                        end
                    }
                }
            })
        else
            print("Error: Dropdown or Input not initialized.")
        end
    end
})

local Section = Tabs.ShopTab:AddSection("Items")

local itemsDropdown = Tabs.ShopTab:AddDropdown("Buy Item", {
    Title = "Buy Item",
    Values = {
        -- Equipment & Gear
        "GPS",
        "Fish Radar",
        "Glider",
        "Pickaxe",
        "Advanced Glider",
        "Basic Diving Gear",
        "Advanced Diving Gear",
        "Flippers",
        "Super Flippers",
        "Tidebreaker",
        
        -- Oxygen Tanks
        "Basic Oxygen Tank",
        "Beginner Oxygen Tank",
        "Intermediate Oxygen Tank",
        "Advanced Oxygen Tank",

        -- Miscellaneous
        "Winter Cloak"
    },
    Multi = false,
    Default = 1
})

-- Input Field for Amount
local itemAmountInput = Tabs.ShopTab:AddInput("ItemAmount", {
    Title = "Amount (Press Enter)",
    Default = "1", -- Default value set to 1
    Placeholder = "Enter amount",
    Numeric = true, -- Ensures only numbers are allowed
    Finished = true, -- Calls the callback only when Enter is pressed
    Callback = function(Value)
        print("Amount Input changed:", Value)
    end
})

-- Button to Purchase the Item
local buyItem = Tabs.ShopTab:AddButton({
    Title = "Purchase Item",
    Description = "Buy the selected item",
    Callback = function()
        -- Debug: Print objects
        print("Dropdown Object:", itemsDropdown)
        print("Input Object:", itemAmountInput)

        -- Check if dropdown and input are initialized correctly
        if itemsDropdown and itemAmountInput then
            local selectedItem = itemsDropdown.Value
            local amount = tonumber(itemAmountInput.Value) or 1 -- Convert to number, default to 1 if invalid

            -- Validate the amount
            if amount < 1 then
                print("Error: Amount must be at least 1.")
                return
            end
            
            -- Confirmation Dialog
            Window:Dialog({
                Title = "Confirm Purchase",
                Content = "Are you sure you want to purchase " .. tostring(amount) .. " " .. tostring(selectedItem) .. "?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            -- Debugging print statements
                            print("Selected Item:", selectedItem)
                            print("Amount:", amount)

                            -- Fire purchase event
                            game:GetService("ReplicatedStorage").events.purchase:FireServer(selectedItem, Group, nil, amount)
                            print("Purchased " .. amount .. " of " .. selectedItem)
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the purchase.")
                        end
                    }
                }
            })
        else
            print("Error: Dropdown or Input not initialized.")
        end
    end
})

local Group = "Fish"
local Itemsname = {
    -- Baits and Geodes
    "Common Crates",
    "Bait Crates",
    "Quality Bait Crates",
    "Volcanic Geodes",
    "Coral Geodes",
}

local Section = Tabs.ShopTab:AddSection("Bait (Fixing)")
local baitsDropdown = Tabs.ShopTab:AddDropdown("Buy Item", {
    Title = "Buy Item",
    Values = Itemsname,
    Multi = false,
    Default = 1,
})

-- Input Field for Amount
local baitsAmountInput = Tabs.ShopTab:AddInput("ItemAmount", {
    Title = "Amount (Press Enter)",
    Default = "1", -- Default value set to 1
    Placeholder = "Enter amount",
    Numeric = true, -- Ensures only numbers are allowed
    Finished = true, -- Calls the callback only when Enter is pressed
    Callback = function(Value)
        print("Amount Input changed:", Value)
    end
})

-- Button to Purchase the Item
local buyItem = Tabs.ShopTab:AddButton({
    Title = "Purchase Item",
    Description = "Buy the selected item",
    Callback = function()
        -- Debug: Print objects
        print("Dropdown Object:", baitsDropdown)
        print("Input Object:", baitsAmountInput)

        -- Check if dropdown and input are initialized correctly
        if baitsDropdown and baitsAmountInput then
            local selectedItem = baitsDropdown.Value
            local amount = tonumber(baitsAmountInput.Value) or 1 -- Convert to number, default to 1 if invalid

            -- Validate the amount
            if amount < 1 then
                print("Error: Amount must be at least 1.")
                return
            end
            
            -- Confirmation Dialog
            Window:Dialog({
                Title = "Confirm Purchase",
                Content = "Are you sure you want to purchase " .. tostring(amount) .. " " .. tostring(selectedItem) .. "?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            -- Debugging print statements
                            print("Selected Item:", selectedItem)
                            print("Amount:", amount)

                            -- Fire purchase event
                            game:GetService("ReplicatedStorage").events.purchase:FireServer(selectedItem, Group, nil, amount)
                            print("Purchased " .. amount .. " of " .. selectedItem)
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the purchase.")
                        end
                    }
                }
            })
        else
            print("Error: Dropdown or Input not initialized.")
        end
    end
})


local Group = "Rod"
local Rodnames = {
    "Flimsy Rod",
    "Fischer's Rod",
    "Training Rod",
    "Plastic Rod",
    "Carbon Rod",
    "Fast Rod",
    "Lucky Rod",
    "Long Rod",
    "Stone Rod",
    "Magma Rod",
    "Fungal Rod",
    "Steady Rod",
    "Fortune Rod",
    "Rapid Rod",
    "Magnet Rod",
    "Nocturnal Rod",
    "Reinforced Rod",
    "Arctic Rod",
    "Avalanche Rod",
    "Phoenix Rod",
    "Scurvy Rod",
    "Midas Rod",
    "Crystalized Rod",
    "Aurora Rod",
    "Mythical Rod",
    "Kings Rod",
    "Ice Warpers Rod",
    "Depthseeker Rod",
    "Trident Rod",
    "Summit Rod",
    "Precision Rod",
    "Wisdom Rod",
    "Resourceful Rod",
    "Rod Of The Depths",
    "Rod Of The Exalted One",
    "Destiny Rod",
    "Sunken Rod",
    "Auric Rod",
    "Seasons Rod",
    "Riptide Rod"
}

local Section = Tabs.ShopTab:AddSection("Rods")
local rodsDropdown = Tabs.ShopTab:AddDropdown("Buy Rod", {
    Title = "Buy Rod",
    Values = {
        "Flimsy Rod",
        "Fischer's Rod",
        "Training Rod",
        "Plastic Rod",
        "Carbon Rod",
        "Fast Rod",
        "Lucky Rod",
        "Long Rod",
        "Stone Rod",
        "Magma Rod",
        "Fungal Rod",
        "Steady Rod",
        "Fortune Rod",
        "Rapid Rod",
        "Magnet Rod",
        "Nocturnal Rod",
        "Reinforced Rod",
        "Arctic Rod",
        "Avalanche Rod",
        "Phoenix Rod",
        "Scurvy Rod",
        "Midas Rod",
        "Crystalized Rod",
        "Aurora Rod",
        "Mythical Rod",
        "Kings Rod",
        "Ice Warpers Rod",
        "Depthseeker Rod",
        "Trident Rod",
        "Summit Rod",
        "Precision Rod",
        "Wisdom Rod",
        "Resourceful Rod",
        "Rod Of The Depths",
        "Rod Of The Exalted One",
        "Destiny Rod",
        "Sunken Rod",
        "Auric Rod",
        "Seasons Rod",
        "Riptide Rod"
    },
    Multi = false,
    Default = 1,
})

local rodAmountInput = Tabs.ShopTab:AddInput("RodAmount", {
    Title = "Amount (Press Enter)",
    Default = "1", -- Default value set to 1
    Placeholder = "Enter amount",
    Numeric = true, -- Ensures only numbers are allowed
    Finished = true, -- Calls the callback only when Enter is pressed
    Callback = function(Value)
        print("Amount Input changed:", Value)
    end
})

-- Button to purchase the rod
local buyRodButton = Tabs.ShopTab:AddButton({
    Title = "Purchase Rod",
    Description = "Buy the selected Rod",
    Callback = function()
        -- Debug: Print objects
        print("Dropdown Object:", rodsDropdown)
        print("Input Object:", rodAmountInput)

        -- Check if dropdown and input are initialized correctly
        if rodsDropdown and rodAmountInput then
            local selectedRod = rodsDropdown.Value
            local amount = tonumber(rodAmountInput.Value) or 1 -- Convert to number, default to 1 if invalid

            -- Validate the amount
            if amount < 1 then
                print("Error: Amount must be at least 1.")
                return
            end

            Window:Dialog({
                Title = "Confirm Purchase",
                Content = "Are you sure you want to purchase " .. tostring(amount) .. " " .. tostring(selectedRod) .. "?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            -- Debugging print statements
                            print("Selected Rod:", selectedRod)
                            print("Amount:", amount)

                            -- Check if selectedRod and amount are valid
                            if selectedRod and amount then
                                game:GetService("ReplicatedStorage").events.purchase:FireServer(selectedRod, Group, nil, amount)
                                print("Purchased " .. amount .. " of " .. selectedRod)
                            else
                                print("Error: Invalid rod or amount.")
                            end
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the purchase.")
                        end
                    }
                }
            })
        else
            print("Error: Dropdown or Input not initialized.")
        end
    end
})



local Section = Tabs.ShopTab:AddSection("Merlin")
    -- Buy Relic Button
    local powerButton = Tabs.ShopTab:AddButton({
        Title = "Buy Relic",
        Description = "Teleport to Merlin and buy the relic.",
        Callback = function()
            GetRoot().CFrame = CFrame.new(-930, 225, -991)  -- Teleport to the specified coordinates
            workspace:WaitForChild("world"):WaitForChild("npcs"):WaitForChild("Merlin"):WaitForChild("Merlin"):WaitForChild("power"):InvokeServer()  -- Invoke power purchase
            VIM:SendKeyEvent(true, "E", false, game)  -- Simulate pressing the "E" key
            task.wait(0.05)  -- Small delay to ensure the event is processed
            VIM:SendKeyEvent(false, "E", false, game)  -- Simulate releasing the "E" key
        end
    })

    -- Buy Luck Button
    local luckButton = Tabs.ShopTab:AddButton({
        Title = "Buy Luck",
        Description = "Teleport to Merlin and buy the luck.",
        Callback = function()
            GetRoot().CFrame = CFrame.new(-930, 225, -991)  -- Teleport to the specified coordinates
            game.Workspace:WaitForChild("world"):WaitForChild("npcs"):WaitForChild("Merlin"):WaitForChild("Merlin"):WaitForChild("luck"):InvokeServer()  -- Invoke luck purchase
            VIM:SendKeyEvent(true, "E", false, game)  -- Simulate pressing the "E" key
            task.wait(0.05)  -- Small delay to ensure the event is processed
            VIM:SendKeyEvent(false, "E", false, game)  -- Simulate releasing the "E" key
        end
    })

local Section = Tabs.MiscTab:AddSection("Game")



local Section = Tabs.DupeTab:AddSection("New Dupe Coming SOON!!")

    -- Addons:
    -- SaveManager (Allows you to have a configuration system)
    -- InterfaceManager (Allows you to have a interface managment system)

    -- Hand the library over to our managers
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)

    -- Ignore keys that are used by ThemeManager.
    -- (we dont want configs to save themes, do we?)
    SaveManager:IgnoreThemeSettings()

    -- You can add indexes of elements the save manager should ignore
    SaveManager:SetIgnoreIndexes({})

    -- use case for doing it this way:
    -- a script hub could have themes in a global folder
    -- and game configs in a separate folder per game
    InterfaceManager:SetFolder("FluentScriptHub")
    SaveManager:SetFolder("FluentScriptHub/specific-game")

    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)


    Window:SelectTab(1)

    Fluent:Notify({
        Title = "Fluent",
        Content = "The script has been loaded.",
        Duration = 8
    })

    -- You can use the SaveManager:LoadAutoloadConfig() to load a config
    -- which has been marked to be one that auto loads!
    SaveManager:LoadAutoloadConfig()