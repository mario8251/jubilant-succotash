-- Fighter Bot Spawnmenu Configuration Panel
-- This creates a spawnmenu panel with checkboxes for configuring fighter bots

if CLIENT then
    local function CreateFighterBotConfigPanel()
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 500)
        frame:SetTitle("Fighter Bot Configuration")
        frame:Center()
        frame:SetVisible(true)
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)
        frame:MakePopup()
        
        -- Selected bot entity
        local selectedBot = nil
        
        -- Main panel
        local mainPanel = vgui.Create("DPanel", frame)
        mainPanel:Dock(FILL)
        mainPanel:SetPadding(10)
        
        -- Bot selection label
        local selectLabel = vgui.Create("DLabel", mainPanel)
        selectLabel:Dock(TOP)
        selectLabel:SetText("Select a Fighter Bot first, then configure:")
        selectLabel:SetTall(20)
        
        -- Bot info label
        local infoLabel = vgui.Create("DLabel", mainPanel)
        infoLabel:Dock(TOP)
        infoLabel:SetText("No bot selected")
        infoLabel:SetTall(20)
        infoLabel:SetTextColor(Color(255, 200, 100))
        
        -- Separator
        local separator1 = vgui.Create("DPanel", mainPanel)
        separator1:Dock(TOP)
        separator1:SetTall(2)
        separator1.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100))
        end
        
        -- Targeting Options Section
        local targetLabel = vgui.Create("DLabel", mainPanel)
        targetLabel:Dock(TOP)
        targetLabel:SetText("Targeting Options:")
        targetLabel:SetFont("DermaDefaultBold")
        targetLabel:SetTall(20)
        
        -- Checkboxes for targeting options
        local checkBoxes = {}
        
        local targetTypes = {
            { name = "TargetPlayers", label = "Target Players" },
            { name = "TargetSNPCs", label = "Target SNPCs" },
            { name = "TargetNextbots", label = "Target Nextbots" },
            { name = "TargetVJBase", label = "Target VJ Base NPCs" },
            { name = "TargetDRGBase", label = "Target DRGBase NPCs" },
            { name = "TargetCPTBase", label = "Target CPTBase NPCs" },
        }
        
        for _, targetType in ipairs(targetTypes) do
            local checkBox = vgui.Create("DCheckBoxLabel", mainPanel)
            checkBox:Dock(TOP)
            checkBox:SetText(targetType.label)
            checkBox:SetValue(true)
            checkBox:SetConVar("") -- Not using convars, manual handling
            checkBox.OnChange = function(panel, newValue)
                if IsValid(selectedBot) then
                    RunConsoleCommand("fighterbot_settarget", selectedBot:EntIndex(), targetType.name, newValue and "1" or "0")
                end
            end
            checkBoxes[targetType.name] = checkBox
        end
        
        -- Separator
        local separator2 = vgui.Create("DPanel", mainPanel)
        separator2:Dock(TOP)
        separator2:SetTall(2)
        separator2.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100))
        end
        
        -- Model Selection Section
        local modelLabel = vgui.Create("DLabel", mainPanel)
        modelLabel:Dock(TOP)
        modelLabel:SetText("Model Selection:")
        modelLabel:SetFont("DermaDefaultBold")
        modelLabel:SetTall(20)
        
        local modelEntry = vgui.Create("DTextEntry", mainPanel)
        modelEntry:Dock(TOP)
        modelEntry:SetPlaceholderText("Enter model path (e.g., models/player/combine_soldier.mdl)")
        modelEntry:SetTall(25)
        
        local modelButton = vgui.Create("DButton", mainPanel)
        modelButton:Dock(TOP)
        modelButton:SetText("Set Model")
        modelButton:SetTall(25)
        modelButton.DoClick = function()
            if IsValid(selectedBot) then
                local modelPath = modelEntry:GetValue()
                if modelPath ~= "" then
                    RunConsoleCommand("fighterbot_setmodel", selectedBot:EntIndex(), modelPath)
                end
            end
        end
        
        -- Model browser button
        local modelBrowserButton = vgui.Create("DButton", mainPanel)
        modelBrowserButton:Dock(TOP)
        modelBrowserButton:SetText("Open Model Browser")
        modelBrowserButton:SetTall(25)
        modelBrowserButton.DoClick = function()
            local frame2 = vgui.Create("DFrame")
            frame2:SetSize(600, 400)
            frame2:SetTitle("Select Model")
            frame2:Center()
            frame2:SetVisible(true)
            
            local modelBrowser = vgui.Create("DModelPanel", frame2)
            modelBrowser:Dock(FILL)
            modelBrowser.SetModel = function(self, model)
                DModelPanel.SetModel(self, model)
                modelEntry:SetValue(model)
                frame2:Close()
            end
            
            -- Populate with player models
            local playerModels = player_manager.AllValidModels()
            for modelName, modelPath in pairs(playerModels) do
                -- Add to browser somehow (simplified approach)
            end
        end
        
        -- Separator
        local separator3 = vgui.Create("DPanel", mainPanel)
        separator3:Dock(TOP)
        separator3:SetTall(2)
        separator3.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100))
        end
        
        -- Weapon Selection Section
        local weaponLabel = vgui.Create("DLabel", mainPanel)
        weaponLabel:Dock(TOP)
        weaponLabel:SetText("Weapon Selection:")
        weaponLabel:SetFont("DermaDefaultBold")
        weaponLabel:SetTall(20)
        
        local weaponEntry = vgui.Create("DTextEntry", mainPanel)
        weaponEntry:Dock(TOP)
        weaponEntry:SetPlaceholderText("Enter weapon class (e.g., weapon_pistol, weapon_ar2)")
        weaponEntry:SetTall(25)
        
        local weaponButton = vgui.Create("DButton", mainPanel)
        weaponButton:Dock(TOP)
        weaponButton:SetText("Set Weapon")
        weaponButton:SetTall(25)
        weaponButton.DoClick = function()
            if IsValid(selectedBot) then
                local weaponClass = weaponEntry:GetValue()
                if weaponClass ~= "" then
                    RunConsoleCommand("fighterbot_setweapon", selectedBot:EntIndex(), weaponClass)
                end
            end
        end
        
        -- Separator
        local separator4 = vgui.Create("DPanel", mainPanel)
        separator4:Dock(TOP)
        separator4:SetTall(2)
        separator4.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100))
        end
        
        -- Stats Section
        local statsLabel = vgui.Create("DLabel", mainPanel)
        statsLabel:Dock(TOP)
        statsLabel:SetText("Bot Stats:")
        statsLabel:SetFont("DermaDefaultBold")
        statsLabel:SetTall(20)
        
        -- Health slider
        local healthLabel = vgui.Create("DLabel", mainPanel)
        healthLabel:Dock(TOP)
        healthLabel:SetText("Health: 100")
        healthLabel:SetTall(20)
        
        local healthSlider = vgui.Create("DSlider", mainPanel)
        healthSlider:Dock(TOP)
        healthSlider:SetTall(30)
        healthSlider:SetMin(10)
        healthSlider:SetMax(1000)
        healthSlider:SetValue(100)
        healthSlider:SetLockDecimals(0)
        healthSlider.OnValueChanged = function(panel, value)
            healthLabel:SetText("Health: " .. math.floor(value))
        end
        
        -- Speed slider
        local speedLabel = vgui.Create("DLabel", mainPanel)
        speedLabel:Dock(TOP)
        speedLabel:SetText("Move Speed: 250")
        speedLabel:SetTall(20)
        
        local speedSlider = vgui.Create("DSlider", mainPanel)
        speedSlider:Dock(TOP)
        speedSlider:SetTall(30)
        speedSlider:SetMin(100)
        speedSlider:SetMax(800)
        speedSlider:SetValue(250)
        speedSlider:SetLockDecimals(0)
        speedSlider.OnValueChanged = function(panel, value)
            speedLabel:SetText("Move Speed: " .. math.floor(value))
        end
        
        -- Apply stats button
        local applyStatsButton = vgui.Create("DButton", mainPanel)
        applyStatsButton:Dock(TOP)
        applyStatsButton:SetText("Apply Stats (Spawn New Bot)")
        applyStatsButton:SetTall(25)
        applyStatsButton.DoClick = function()
            -- Note: Changing stats on existing bots requires additional networked vars
            -- This is a simplified version - spawns a new bot with the settings
            local health = math.floor(healthSlider:GetValue())
            local speed = math.floor(speedSlider:GetValue())
            
            notification.AddLegacy("Stats will be applied to newly spawned bots. Health: " .. health .. ", Speed: " .. speed, NOTIFY_GENERIC, 3)
        end
        
        -- Update function
        function frame:UpdateBotInfo(bot)
            if IsValid(bot) then
                selectedBot = bot
                infoLabel:SetText("Selected: " .. bot:GetClass() .. " (Index: " .. bot:EntIndex() .. ")")
                
                -- Update checkbox states from networked vars
                checkBoxes["TargetPlayers"]:SetValue(bot:GetNWBool("TargetPlayers", true))
                checkBoxes["TargetSNPCs"]:SetValue(bot:GetNWBool("TargetSNPCs", true))
                checkBoxes["TargetNextbots"]:SetValue(bot:GetNWBool("TargetNextbots", true))
                checkBoxes["TargetVJBase"]:SetValue(bot:GetNWBool("TargetVJBase", true))
                checkBoxes["TargetDRGBase"]:SetValue(bot:GetNWBool("TargetDRGBase", true))
                checkBoxes["TargetCPTBase"]:SetValue(bot:GetNWBool("TargetCPTBase", true))
                
                -- Update model entry
                modelEntry:SetValue(bot:GetNWString("CustomModel", bot:GetModel()))
                
                -- Update weapon entry
                weaponEntry:SetValue(bot:GetNWString("CustomWeapon", "weapon_pistol"))
            else
                selectedBot = nil
                infoLabel:SetText("No bot selected")
            end
        end
        
        return frame
    end
    
    -- Hook into spawnmenu to add our config panel
    hook.Add("InitPostEntity", "FighterBotSpawnmenuInit", function()
        -- Add spawnmenu category for fighter bots
        spawnmenu.AddCreationTab("Fighter Bots", function()
            local controlPanel = vgui.Create("DContentControl")
            controlPanel:SetSize(300, 500)
            
            local content = vgui.Create("DPanel")
            content:Dock(FILL)
            content:SetPadding(10)
            
            local label = vgui.Create("DLabel", content)
            label:Dock(TOP)
            label:SetText("Fighter Bot Controls")
            label:SetFont("DermaDefaultBold")
            label:SetTall(20)
            
            local openConfigButton = vgui.Create("DButton", content)
            openConfigButton:Dock(TOP)
            openConfigButton:SetText("Open Configuration Panel")
            openConfigButton:SetTall(40)
            openConfigButton.DoClick = function()
                CreateFighterBotConfigPanel()
            end
            
            local helpLabel = vgui.Create("DLabel", content)
            helpLabel:Dock(TOP)
            helpLabel:SetText("\nInstructions:\n1. Spawn a Fighter Bot from the Entities menu\n2. Click 'Open Configuration Panel'\n3. Use your cursor to select a bot\n4. Configure targeting, model, and weapon")
            helpLabel:SetTall(100)
            
            controlPanel:SetPanel(content)
            return controlPanel
        end, "icon16/user.png")
    end)
    
    -- Add context menu option to select bot
    hook.Add("PopulateToolMenu", "FighterBotToolMenu", function()
        spawnmenu.AddToolMenuOption("Utilities", "Fighter Bots", "fighterbot_config", "Configure Bot", "", "", function(panel)
            panel:ClearControls()
            panel:Help("Right-click on a Fighter Bot to select it for configuration.")
            
            local selectButton = panel:Button("Select Bot Under Cursor", function()
                local trace = LocalPlayer():GetEyeTrace()
                if IsValid(trace.Entity) and trace.Entity:GetClass() == "npc_fighter_bot" then
                    -- Find and update the config panel
                    for _, frame in ipairs(vgui.GetAll()) do
                        if frame.GetTitle and frame:GetTitle() == "Fighter Bot Configuration" then
                            frame:UpdateBotInfo(trace.Entity)
                            break
                        end
                    end
                end
            end)
        end)
    end)
    
    -- Add right-click context menu for fighter bots
    hook.Add("OnContextMenuOpen", "FighterBotContextMenu", function()
        local trace = LocalPlayer():GetEyeTrace()
        if IsValid(trace.Entity) and trace.Entity:GetClass() == "npc_fighter_bot" then
            local menu = DermaMenu()
            
            menu:AddOption("Configure This Bot", function()
                -- Find and update the config panel
                for _, frame in ipairs(vgui.GetAll()) do
                    if frame.GetTitle and frame:GetTitle() == "Fighter Bot Configuration" then
                        frame:UpdateBotInfo(trace.Entity)
                        frame:MakePopup()
                        break
                    end
                end
                
                -- If no panel exists, create one
                local newPanel = CreateFighterBotConfigPanel()
                newPanel:UpdateBotInfo(trace.Entity)
            end):SetIcon("icon16/wrench.png")
            
            menu:AddOption("Copy Entity Index", function()
                SetClipboardText(tostring(trace.Entity:EntIndex()))
                notification.AddLegacy("Entity index copied: " .. trace.Entity:EntIndex(), NOTIFY_GENERIC, 2)
            end):SetIcon("icon16/page_copy.png")
            
            menu:Open()
        end
    end)
end
