net.Receive( "BricksServerNet_SendGangInbox", function()
	BRS_GANG_INBOXES = net.ReadTable() or {}
end )

net.Receive( "BricksServerNet_SendGangInboxEntry", function()
	local receiverKey = net.ReadString()
	local inboxKey = net.ReadUInt( 16 )
	local inboxEntryTable = net.ReadTable()

	if( not BRS_GANG_INBOXES ) then
		BRS_GANG_INBOXES = {}
	end

	if( isnumber( tonumber( receiverKey ) ) ) then
		receiverKey = tonumber( receiverKey )
	end

	if( not BRS_GANG_INBOXES[receiverKey] ) then
		BRS_GANG_INBOXES[receiverKey] = {}
	end

	BRS_GANG_INBOXES[receiverKey][inboxKey] = inboxEntryTable

	hook.Run( "BRS_RefreshGangInbox" )
end )

net.Receive( "BricksServerNet_RemoveGangInboxEntry", function()
	local receiverKey = net.ReadString()
	local inboxKey = net.ReadUInt( 16 )

	if( isnumber( tonumber( receiverKey ) ) ) then
		receiverKey = tonumber( receiverKey )
	end

	if( not BRS_GANG_INBOXES or not BRS_GANG_INBOXES[receiverKey] or not BRS_GANG_INBOXES[receiverKey][inboxKey] ) then return end

	BRS_GANG_INBOXES[receiverKey][inboxKey] = nil

	hook.Run( "BRS_RefreshGangInbox" )
end )

BRICKS_SERVER.Func.AddAdminPlayerFunc( BRICKS_SERVER.Func.L( "gangNotification" ), BRICKS_SERVER.Func.L( "add" ), function( ply ) 
	BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "gangNotificationHeader" ), BRICKS_SERVER.Func.L( "gangAdminNotification" ), function( header ) 
		BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "admin" ), BRICKS_SERVER.Func.L( "gangNotificationBody" ), "", function( body ) 
			net.Start( "BricksServerNet_AddGangAdminMail" )
				net.WriteString( ply:SteamID() )
				net.WriteString( header )
				net.WriteString( body )
			net.SendToServer()
		end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
	end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ) )
end )