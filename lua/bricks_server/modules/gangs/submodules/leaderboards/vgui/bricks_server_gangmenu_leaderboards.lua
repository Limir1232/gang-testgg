local PANEL = {}

function PANEL:Init()
    self:DockMargin( 10, 10, 10, 10 )
end

function PANEL:FillPanel( gangTable )
    BRICKS_SERVER.Func.RequestGangLeaderboards()

    function self.RefreshPanel()
        self:Clear()

        for k, v in pairs( BRICKS_SERVER.CONFIG.GANGS.Leaderboards or {} ) do
            local leaderboardTable = (BRS_GANG_LEADERBOARDS or {})[k] or {}

            local itemBack = vgui.Create( "DPanel", self )
            itemBack:Dock( TOP )
            itemBack:DockMargin( 0, 0, 0, 5 )
            itemBack:SetTall( 140 )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            end

            local topBar = vgui.Create( "DPanel", itemBack )
            topBar:Dock( TOP )
            topBar:SetTall( 40 )
            surface.SetFont( "BRICKS_SERVER_Font20" )
            local nameX, nameY = surface.GetTextSize( v.Name )
            topBar.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                BRICKS_SERVER.Func.DrawPartialRoundedBox( 5, 0, 0, 3, h, (v.Color or BRICKS_SERVER.Func.GetTheme( 5 )), 10, h )
            
                draw.SimpleText( v.Name, "BRICKS_SERVER_Font20", 15, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
            end

            local occupyingGangTable = {}
            if( leaderboardTable.GangID ) then
                if( BRICKS_SERVER_GANGS[leaderboardTable.GangID or 0] ) then
                    occupyingGangTable = BRICKS_SERVER_GANGS[leaderboardTable.GangID or 0]
                else
                    BRICKS_SERVER.Func.RequestLeaderboardGangs()
                end
            end

            local rightBackTall = itemBack:GetTall()-topBar:GetTall()

            local rightBack = vgui.Create( "DPanel", itemBack )
            rightBack:Dock( RIGHT )
            rightBack:DockMargin( 0, 0, 15, 0 )
            rightBack:SetWide( 150 )
            rightBack.Paint = function( self2, w, h ) end

            local noticeBack = vgui.Create( "DPanel", rightBack )
            noticeBack:SetSize( 0, 35 )
            noticeBack:SetPos( (rightBack:GetWide()/2)-(noticeBack:GetWide()/2), (rightBackTall/2)-(noticeBack:GetTall()/2) )
            noticeBack.Paint = function( self2, w, h ) end

            local itemNotices = {}

            local devConfig = BRICKS_SERVER.DEVCONFIG.GangLeaderboards[v.Type]

            if( devConfig ) then
                table.insert( itemNotices, { devConfig.FormatDescription( leaderboardTable.SortValue or 0 ), devConfig.Color } )
            end

            for k, v in pairs( itemNotices ) do
                surface.SetFont( "BRICKS_SERVER_Font23" )
                local textX, textY = surface.GetTextSize( v[1] )
                local boxW, boxH = textX+15, textY+5

                local itemInfoNotice = vgui.Create( "DPanel", noticeBack )
                itemInfoNotice:Dock( LEFT )
                itemInfoNotice:DockMargin( 0, 0, 5, 0 )
                itemInfoNotice:SetWide( boxW )
                itemInfoNotice.Paint = function( self2, w, h ) 
                    draw.RoundedBox( 5, 0, 0, w, h, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                    draw.SimpleText( v[1], "BRICKS_SERVER_Font23", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                if( noticeBack:GetWide() <= 5 ) then
                    noticeBack:SetSize( noticeBack:GetWide()+boxW, boxH )
                else
                    noticeBack:SetSize( noticeBack:GetWide()+5+boxW, boxH )
                end

                if( noticeBack:GetWide() > rightBack:GetWide() ) then
                    rightBack:SetWide( noticeBack:GetWide() )
                end

                noticeBack:SetPos( (rightBack:GetWide()/2)-(noticeBack:GetWide()/2), (rightBackTall/2)-(noticeBack:GetTall()/2) )
            end

            local avatarBack = vgui.Create( "DPanel", itemBack )
            avatarBack:Dock( FILL )
            avatarBack:DockMargin( 15, 15, 15, 15 )
            local iconMat
            BRICKS_SERVER.Func.GetImage( occupyingGangTable.Icon or "question.png", function( mat ) 
                iconMat = mat 
            end )
            avatarBack.Paint = function( self2, w, h )
                local avatarBackSize = 70
                local avatarSize = (occupyingGangTable.Icon and h-6) or 32
                local textStartPos = avatarBackSize+15

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.NoTexture()
                BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )
        
                draw.SimpleText( (occupyingGangTable.Name or BRICKS_SERVER.Func.L( "gangNone" )), "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
        
                draw.SimpleText( BRICKS_SERVER.Func.L( "gangID", (leaderboardTable.GangID or 0) ), "BRICKS_SERVER_Font17", textStartPos, h/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
        
                if( iconMat ) then
                    render.ClearStencil()
                    render.SetStencilEnable( true )
                
                    render.SetStencilWriteMask( 1 )
                    render.SetStencilTestMask( 1 )
                
                    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
                    render.SetStencilPassOperation( STENCILOPERATION_ZERO )
                    render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
                    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
                    render.SetStencilReferenceValue( 1 )
                
                    draw.NoTexture()
                    surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
                    BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarSize/2, avatarSize/2 )
                
                    render.SetStencilFailOperation( STENCILOPERATION_ZERO )
                    render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
                    render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
                    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
                    render.SetStencilReferenceValue( 1 )
                
                    surface.SetDrawColor( 255, 255, 255, 255 )
                    surface.SetMaterial( iconMat )
                    surface.DrawTexturedRect( (avatarBackSize-avatarSize)/2, (avatarBackSize-avatarSize)/2, avatarSize, avatarSize )
                
                    render.SetStencilEnable( false )
                    render.ClearStencil()
                end
            end
        end
    end
    self.RefreshPanel()

    hook.Add( "BRS_RefreshGangLeaderboards", self, function()
        if( IsValid( self ) ) then
            self.RefreshPanel()
        else
            hook.Remove( "BRS_RefreshGangLeaderboards", self )
        end
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_gangmenu_leaderboards", PANEL, "bricks_server_scrollpanel" )