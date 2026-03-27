local PANEL = {}

function PANEL:Init()
    self:DockMargin( 10, 10, 10, 10 )
end

function PANEL:FillPanel()
    local newGangIcon, newGangName
    
    local createFinish = vgui.Create( "DButton", self )
    createFinish:Dock( BOTTOM )
    createFinish:SetText( "" )
    createFinish:DockMargin( 0, 5, 0, 0 )
    createFinish:SetTall( 40 )
    local changeAlpha = 0
    createFinish.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
        end
        
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )

        surface.SetAlphaMultiplier( changeAlpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
        surface.SetAlphaMultiplier( 1 )

        draw.SimpleText( BRICKS_SERVER.Func.L( "gangCreateString", DarkRP.formatMoney( BRICKS_SERVER.CONFIG.GANGS["Creation Fee"] or 1500 ) ), "BRICKS_SERVER_Font23", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    createFinish.DoClick = function()
        if( not newGangIcon or not newGangName ) then return end
        
        net.Start( "BricksServerNet_CreateGang" )
            net.WriteString( newGangIcon )
            net.WriteString( newGangName )
        net.SendToServer()
    end

    local gangInfoBack = vgui.Create( "DPanel", self )
    gangInfoBack:Dock( TOP )
    gangInfoBack:DockMargin( 0, 0, 0, 0 )
    gangInfoBack:SetTall( 150 )
    local iconMat
    BRICKS_SERVER.Func.GetImage( "gangs.png", function( mat ) 
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
    gangNameEntry:SetValue( newGangName or BRICKS_SERVER.Func.L( "gangNew" ) )
    gangNameEntry.OnChange = function()
        newGangName = gangNameEntry:GetValue()
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
    gangIconEntry:SetValue( newGangIcon or "" )
    gangIconEntry:SetFont( "BRICKS_SERVER_Font23" )
    gangIconEntry.OnChange = function()
        newGangIcon = gangIconEntry:GetValue()

        BRICKS_SERVER.Func.GetImage( (newGangIcon or ""), function( mat ) 
            iconMat = mat 
        end )
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_create", PANEL, "DPanel" )