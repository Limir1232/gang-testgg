util.AddNetworkString( "BricksServerNet_OpenBrickServer" )

function BRICKS_SERVER.Func.OpenMenu( ply )
	net.Start( "BricksServerNet_OpenBrickServer" )
	net.Send( ply )
end

hook.Add( "PlayerSay", "BricksServerHooks_PlayerSay_OpenMenu", function( ply, text )
	if( string.lower( text ) == "!bricksserver" or string.lower( text ) == "/bricksserver" ) then
		BRICKS_SERVER.Func.OpenMenu( ply )
		return ""
	end
end )

concommand.Add( "bricksserver", function( ply, cmd, args )
	if( IsValid( ply ) and ply:IsPlayer() ) then
		BRICKS_SERVER.Func.OpenMenu( ply )
	end
end )

util.AddNetworkString( "BricksServerNet_SendNetworkReady" )
net.Receive( "BricksServerNet_SendNetworkReady", function( len, ply )
	if( ply.BRS_ReadyNetworked ) then return end

	ply.BRS_ReadyNetworked = true

	hook.Run( "BRS_PlayerFullLoad", ply ) 
end )

util.AddNetworkString( "BricksServerNet_SendServerTime" )
hook.Add( "BRS_PlayerFullLoad", "BricksServerHooks_BRS_PlayerFullLoad_SendServerTime", function( ply )
	net.Start( "BricksServerNet_SendServerTime" )
		net.WriteInt( os.time(), 32 )
		net.WriteInt( CurTime(), 32 )
	net.Send( ply )
end )

util.AddNetworkString( "BricksServerNet_SendTopNotification" )
function BRICKS_SERVER.Func.SendTopNotification( ply, text, time, color )
	net.Start( "BricksServerNet_SendTopNotification" )
		net.WriteString( text or "" )
		net.WriteUInt( (time or 5), 8)
		net.WriteColor( color or Color( BRICKS_SERVER.Func.GetTheme( 5 ).r, BRICKS_SERVER.Func.GetTheme( 5 ).g, BRICKS_SERVER.Func.GetTheme( 5 ).b ) )
	net.Send( ply )
end

util.AddNetworkString( "BricksServerNet_SendNotification" )
function BRICKS_SERVER.Func.SendNotification( ply, type, time, message )
	net.Start( "BricksServerNet_SendNotification" )
		net.WriteString( message or "" )
		net.WriteUInt( (type or 1), 8)
		net.WriteUInt( (time or 3), 8)
	net.Send( ply )
end

util.AddNetworkString( "BricksServerNet_SendChatNotification" )
function BRICKS_SERVER.Func.SendChatNotification( ply, tagColor, tagString, msgColor, msgString )
	net.Start( "BricksServerNet_SendChatNotification" )
		net.WriteColor( tagColor or Color( BRICKS_SERVER.Func.GetTheme( 5 ).r, BRICKS_SERVER.Func.GetTheme( 5 ).g, BRICKS_SERVER.Func.GetTheme( 5 ).b ) )
		net.WriteString( tagString or "" )
		net.WriteColor( msgColor or Color( BRICKS_SERVER.Func.GetTheme( 6 ).r, BRICKS_SERVER.Func.GetTheme( 6 ).g, BRICKS_SERVER.Func.GetTheme( 6 ).b ) )
		net.WriteString( msgString or "" )
	net.Send( ply )
end

util.AddNetworkString( "BricksServerNet_UseMenuNPC" )