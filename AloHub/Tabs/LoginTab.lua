return function(app)
    local tab = app.Window:CreateTab("Login", "")

    tab:AddSection("Authentication")

    local usernameInput = tab:AddInput("Username", "Enter username...", app.State.SavedUsername or "", false)
    local passwordInput = tab:AddInput("Password", "Enter password...", app.State.SavedPassword or "", true)

    local rememberMe = app.State.RememberMe == true
    local statusLabel = tab:AddLabel("Status: Waiting for login")

    tab:AddToggle("Remember Me", rememberMe, function(state)
        rememberMe = state
        app.State.RememberMe = state
    end)

    tab:AddButton("Login", function()
        local username = usernameInput:Get()
        local password = passwordInput:Get()

        app.Loading:Show("Authenticating", "Verifying credentials...")

        task.delay(0.6, function()
            local ok = app:TryLogin(username, password)

            if ok then
                app:SaveConfig(
                    rememberMe and username or "",
                    rememberMe and password or "",
                    rememberMe
                )

                statusLabel:Set("Status: Login successful")
                app:Refresh()
            else
                statusLabel:Set("Status: Invalid username or password")
                app.Loading:Hide()
            end
        end)
    end)

    return tab
end