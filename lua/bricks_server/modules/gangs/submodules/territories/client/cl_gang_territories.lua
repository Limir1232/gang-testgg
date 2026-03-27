BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "gangTerritories" ), "bricks_server_config_gang_territories", "gangs" )

BRS_GANG_TERRITORIES = BRS_GANG_TERRITORIES or {}
net.Receive( "BricksServerNet_SendGangTerritoriesTable", function()
    BRS_GANG_TERRITORIES = net.ReadTable() or {}

    hook.Run( "BRS_RefreshGangTerritories" )
end )

net.Receive( "BricksServerNet_SendGangTerritoriesValue", function()
    if( not BRS_GANG_TERRITORIES ) then
        BRS_GANG_TERRITORIES = {}
    end

    BRS_GANG_TERRITORIES[net.ReadUInt( 8 ) or 0] = net.ReadTable() or {}

    hook.Run( "BRS_RefreshGangTerritories" )
end )

net.Receive( "BricksServerNet_SendTerritoryGangTables", function()
    if( not BRICKS_SERVER_GANGS ) then
        BRICKS_SERVER_GANGS = {}
    end

    for k, v in pairs( net.ReadTable() or {} ) do
        if( not BRICKS_SERVER_GANGS[k] ) then
            BRICKS_SERVER_GANGS[k] = {}
        end

        for key, val in pairs( v ) do
            BRICKS_SERVER_GANGS[k][key] = val
        end
    end

    hook.Run( "BRS_RefreshGangTerritories" )
end )

function BRICKS_SERVER.Func.RequestTerritoryGangs()
    if( CurTime() < (BRS_REQUEST_TERRITORYGANG_COOLDOWN or 0) ) then return end

    BRS_REQUEST_TERRITORYGANG_COOLDOWN = CurTime()+10

    net.Start( "BricksServerNet_RequestTerritoryGangs" )
    net.SendToServer()
end

function BRICKS_SERVER.Func.RequestTerritoryIconMat( territoryKey )
    if( CurTime() < (BRS_REQUEST_TERRITORYICONMAT_COOLDOWN or 0) ) then return end

    BRS_REQUEST_TERRITORYICONMAT_COOLDOWN = CurTime()+10

    local gangID = (BRS_GANG_TERRITORIES[territoryKey] or {}).GangID
    if( BRICKS_SERVER_GANGS[gangID] and BRICKS_SERVER_GANGS[gangID].Icon ) then
        BRICKS_SERVER.Func.GetImage( BRICKS_SERVER_GANGS[gangID].Icon, function( mat ) 
            BRS_GANG_TERRITORIES[territoryKey].IconMat = mat 
        end )
    end
end