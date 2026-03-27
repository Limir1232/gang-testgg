local PANEL = {}

function PANEL:Init()

end

function PANEL:CreatePopup( text )
    if( IsValid( self.popup ) ) then return end

    local margin = 25

    self.popup = vgui.Create( "DPanel", self )
    self.popup:SetSize( self.panelWide-(2*margin), 50 )
    self.popup:SetPos( margin, ScrH()*0.65-40 )
    self.popup:MoveTo( margin, ScrH()*0.65-40-margin-self.popup:GetTall(), 0.2 )
    local yBound = (ScrH()/2)-(ScrH()*0.65/2)
    self.popup.Paint = function( self2, w, h )
        local x, y = self2:LocalToScreen( 0, 0 )

        BRICKS_SERVER.BSHADOWS.BeginShadow( 0, yBound, ScrW(), yBound+(ScrH()*0.65) )
        draw.RoundedBox( 5, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )			
        BRICKS_SERVER.BSHADOWS.EndShadow( 1, 2, 2, 255, 0, 0, false )
    
        draw.SimpleText( text, "BRICKS_SERVER_Font23", 15, h/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    end

    return self.popup
end

function PANEL:SettingChanged()
    if( not self.settingsChanged ) then
        self.settingsChanged = true
        local popup = self:CreatePopup( BRICKS_SERVER.Func.L( "gangUnsavedChanges" ) )

        if( IsValid( popup ) ) then
            surface.SetFont( "BRICKS_SERVER_Font23" )
            local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "gangSaveChanges" ) )

            local margin = 8

            local saveChanges = vgui.Create( "DButton", popup )
            saveChanges:Dock( RIGHT )
            saveChanges:DockMargin( 0, margin, margin, margin )
            saveChanges:SetWide( textX+10 )
            saveChanges:SetText( "" )
            local alpha = 0
            saveChanges.Paint = function( self2, w, h )
                if( self2:IsDown() ) then
                    alpha = 0
                elseif( self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 255 )
                else
                    alpha = math.Clamp( alpha-10, 0, 255 )
                end

                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )

                surface.SetAlphaMultiplier( alpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )		
                surface.SetAlphaMultiplier( 1 )
            
                draw.SimpleText( BRICKS_SERVER.Func.L( "gangSaveChanges" ), "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            saveChanges.DoClick = function()
                local settingsData = util.Compress( util.TableToJSON( self.settingsCopy ) )
                net.Start( "BricksServerNet_SaveGangSettings" )
                    net.WriteData( settingsData, string.len( settingsData ) )
                net.SendToServer()
            end

            surface.SetFont( "BRICKS_SERVER_Font23" )
            local text2X, text2Y = surface.GetTextSize( BRICKS_SERVER.Func.L( "gangReset" ) )

            local resetChanges = vgui.Create( "DButton", popup )
            resetChanges:Dock( RIGHT )
            resetChanges:DockMargin( margin, 10, margin, margin )
            resetChanges:SetWide( text2X+10 )
            resetChanges:SetText( "" )
            local alpha = 0
            local whiteColor = BRICKS_SERVER.Func.GetTheme( 6 )
            resetChanges.Paint = function( self2, w, h )
                if( self2:IsDown() ) then
                    alpha = 0
                elseif( self2:IsHovered() ) then
                    alpha = math.Clamp( alpha+10, 0, 255 )
                else
                    alpha = math.Clamp( alpha-10, 0, 255 )
                end

                surface.SetAlphaMultiplier( alpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )		
                surface.SetAlphaMultiplier( 1 )
            
                draw.SimpleText( BRICKS_SERVER.Func.L( "gangReset" ), "BRICKS_SERVER_Font20", w/2, h/2-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            resetChanges.DoClick = function()
                popup:MoveTo( 25, ScrH()*0.65-40, 0.2, 0, -1, function()
                    if( IsValid( popup ) ) then
                        popup:Remove()
                    end
                end )

                self.RefreshPanel()
            end
        end
    end
end

function PANEL:FillPanel( gangTable )
    local scrollPanel = vgui.Create( "bricks_server_scrollpanel", self )
    scrollPanel:Dock( FILL )

    function self.RefreshPanel()
        scrollPanel:Clear()

        self.settingsCopy = {
            gangName = gangTable.Name,
            gangIcon = gangTable.Icon
        }

        self.settingsChanged = false

        if( IsValid( self.popup ) ) then
            self.popup:MoveTo( 25, ScrH()*0.65-40, 0.2, 0, -1, function()
                if( IsValid( self.popup ) ) then
                    self.popup:Remove()
                end
            end )
        end

        local gangInfoBack = vgui.Create( "DPanel", scrollPanel )
        gangInfoBack:Dock( TOP )
        gangInfoBack:DockMargin( 10, 10, 10, 10 )
        gangInfoBack:SetTall( 150 )
        local iconMat
        BRICKS_SERVER.Func.GetImage( (self.settingsCopy.gangIcon or ""), function( mat ) 
            iconMat = mat 
        end )
        gangInfoBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            draw.RoundedBoxEx( 5, 0, 0, h, h, BRICKS_SERVER.Func.GetTheme( 2 ), true, false, true, false )

            if( iconMat ) then
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( iconMat )
                local iconSize = 64
                surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end
        end

        local gangNameBack = vgui.Create( "DPanel", gangInfoBack )
        gangNameBack:Dock( TOP )
        gangNameBack:DockMargin( gangInfoBack:GetTall()+10, 10, 10, 0 )
        gangNameBack:SetTall( 40 )
        surface.SetFont( "BRICKS_SERVER_Font20" )
        local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "gangName" ) )
        textX = textX+20
        gangNameBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

            draw.RoundedBoxEx( 5, 0, 0, textX, h, BRICKS_SERVER.Func.GetTheme( 2 ), true, false, true, false )

            draw.SimpleText( BRICKS_SERVER.Func.L( "gangName" ), "BRICKS_SERVER_Font20", textX/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        local gangNameEntry = vgui.Create( "bricks_server_textentry", gangNameBack )
        gangNameEntry:Dock( FILL )
        gangNameEntry:DockMargin( textX+5, 0, 0, 0 )
        gangNameEntry:SetFont( "BRICKS_SERVER_Font23" )
        gangNameEntry:SetValue( self.settingsCopy.gangName or BRICKS_SERVER.Func.L( "nil" ) )
        gangNameEntry.OnChange = function()
            self.settingsCopy.gangName = gangNameEntry:GetValue()

            if( not self.settingsChanged ) then
                self:SettingChanged()
            end
        end

        local gangIconBack = vgui.Create( "DPanel", gangInfoBack )
        gangIconBack:Dock( TOP )
        gangIconBack:DockMargin( gangInfoBack:GetTall()+10, 10, 10, 0 )
        gangIconBack:SetTall( 40 )
        surface.SetFont( "BRICKS_SERVER_Font20" )
        local textX, textY = surface.GetTextSize( BRICKS_SERVER.Func.L( "gangIcon" ) )
        textX = textX+20
        gangIconBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

            draw.RoundedBoxEx( 5, 0, 0, textX, h, BRICKS_SERVER.Func.GetTheme( 2 ), true, false, true, false )

            draw.SimpleText( BRICKS_SERVER.Func.L( "gangIcon" ), "BRICKS_SERVER_Font20", textX/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        local gangIconEntry = vgui.Create( "bricks_server_textentry", gangIconBack )
        gangIconEntry:Dock( FILL )
        gangIconEntry:DockMargin( textX+5, 0, 0, 0 )
        gangIconEntry:SetValue( self.settingsCopy.gangIcon or "" )
        gangIconEntry:SetFont( "BRICKS_SERVER_Font23" )
        gangIconEntry.OnChange = function()
            self.settingsCopy.gangIcon = gangIconEntry:GetValue()

            BRICKS_SERVER.Func.GetImage( (self.settingsCopy.gangIcon or ""), function( mat ) 
                iconMat = mat 
            end )

            if( not self.settingsChanged ) then
                self:SettingChanged()
            end
        end
    end
    self.RefreshPanel()

    hook.Add( "BRS_RefreshGang", self, function( self, valuesChanged )
        if( IsValid( self ) ) then
            if( valuesChanged and (valuesChanged["Name"] or valuesChanged["Icon"]) ) then
                self.RefreshPanel()
            end
        else
            hook.Remove( "BRS_RefreshGang", self )
        end
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_settings", PANEL, "DPanel" )