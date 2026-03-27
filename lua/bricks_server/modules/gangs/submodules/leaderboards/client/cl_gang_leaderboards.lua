BRICKS_SERVER.Func.AddConfigPage( BRICKS_SERVER.Func.L( "gangLeaderboards" ), "bricks_server_config_gang_leaderboards", "gangs" )

net.Receive( "BricksServerNet_SendGangLeaderboardTables", function()
    BRS_GANG_LEADERBOARDS = net.ReadTable() or {}

    hook.Run( "BRS_RefreshGangLeaderboards" )
end )

net.Receive( "BricksServerNet_SendLeaderboardGangTables", function()
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

    hook.Run( "BRS_RefreshGangLeaderboards" )
end )

function BRICKS_SERVER.Func.RequestLeaderboardGangs()
    if( CurTime() < (BRS_REQUEST_LEADERBOARDGANG_COOLDOWN or 0) ) then return end

    BRS_REQUEST_LEADERBOARDGANG_COOLDOWN = CurTime()+10

    net.Start( "BricksServerNet_RequestLeaderboardGangs" )
    net.SendToServer()
end

function BRICKS_SERVER.Func.RequestGangLeaderboards()
    if( CurTime() < (BRS_REQUEST_GANGLEADERBOARDS_COOLDOWN or 0) ) then return end

    BRS_REQUEST_GANGLEADERBOARDS_COOLDOWN = CurTime()+10

    net.Start( "BricksServerNet_RequestGangLeaderboards" )
    net.SendToServer()
end