--[[ Global Variables/Tables ]]--
BRICKS_SERVER = BRICKS_SERVER or {}
BRICKS_SERVER.Func = BRICKS_SERVER.Func or {}
BRICKS_SERVER.TEMP = BRICKS_SERVER.TEMP or {}

--[[ Modules Prep ]]--
BRICKS_SERVER.Modules = {}
local moduleMeta = {
	GetFolderName = function( self )
		return self.FolderName
	end,
	AddSubModule = function( self, folderName, name )
		BRICKS_SERVER.Modules[self:GetFolderName()][3][folderName] = name
	end
}

moduleMeta.__index = moduleMeta

function BRICKS_SERVER.Func.AddModule( folderName, name, icon, version )
	BRICKS_SERVER.Modules[folderName] = { name, icon, {}, version }
	
	local module = {
		FolderName = folderName
	}
	
	setmetatable( module, moduleMeta )
	
	return module
end

function BRICKS_SERVER.Func.SetModuleAuthKey( folderName, authKey )
	BRICKS_SERVER.Modules[folderName][5] = authKey
end

--[[ Autorun files ]]--
for k, v in pairs( file.Find( "bricks_server/*.lua", "LUA" ) ) do
	if( string.StartWith( v, "bricks_server_autorun_" ) ) then
		AddCSLuaFile( "bricks_server/" .. v )
		include( "bricks_server/" .. v )
	end
end

--[[ CONFIG LOADER ]]--
for k, v in pairs( file.Find( "bricks_server/*.lua", "LUA" ) ) do
	if( string.StartWith( v, "bricks_server_luacfg_" ) ) then
		AddCSLuaFile( "bricks_server/" .. v )
		include( "bricks_server/" .. v )
	end
end

BRICKS_SERVER.BASECONFIG = {}
AddCSLuaFile( "bricks_server/bricks_server_basecfg_main.lua" )
include( "bricks_server/bricks_server_basecfg_main.lua" )
hook.Run( "BRS_BaseConfigLoad" )

BRICKS_SERVER.CONFIG = table.Copy( BRICKS_SERVER.BASECONFIG )

if( SERVER ) then
	resource.AddFile("resource/fonts/montserrat-medium.ttf")
	resource.AddFile("resource/fonts/montserrat-bold.ttf")
	
	BRICKS_SERVER.CONFIG_LOADED = false
	function BRICKS_SERVER.Func.LoadConfig()
		for k, v in pairs( file.Find( "bricks_server/config/*", "DATA" ) ) do
			local dataTable = util.JSONToTable( file.Read( "bricks_server/config/" .. v, "DATA" ) )

			if( dataTable and istable( dataTable ) ) then
				BRICKS_SERVER.CONFIG[string.upper( string.Replace( v, ".txt", "" ) )] = dataTable
			end
		end

		-- Old rarity conversion (14/11/2020)
		if( BRICKS_SERVER.CONFIG.INVENTORY.Rarities ) then
			BRICKS_SERVER.CONFIG.GENERAL.Rarities = {}
			for k, v in pairs( BRICKS_SERVER.CONFIG.INVENTORY.Rarities ) do
				BRICKS_SERVER.CONFIG.GENERAL.Rarities[k] = { v[1], "SolidColor", v[2] }
			end

			BRICKS_SERVER.CONFIG.INVENTORY.Rarities = nil
		end

		-- Old modules conversion (15/11/2020)
		if( BRICKS_SERVER.CONFIG.MODULES ) then
			local essentialsModules = { "boosters", "boss", "crafting", "currencies", "deathscreens", "f4menu", "hud", "logging", "marketplace", "printers", "swepupgrader", "zones" }
			for k, v in pairs( BRICKS_SERVER.CONFIG.MODULES ) do
				if( istable( v ) ) then continue end

				if( table.HasValue( essentialsModules, k ) ) then
					if( not BRICKS_SERVER.CONFIG.MODULES["essentials"] ) then
						BRICKS_SERVER.CONFIG.MODULES["essentials"] = { true, {} }
					end

					BRICKS_SERVER.CONFIG.MODULES["essentials"][2][k] = v
					BRICKS_SERVER.CONFIG.MODULES[k] = nil
				elseif( k == "gangs" ) then
					BRICKS_SERVER.CONFIG.MODULES[k] = { v, {
						["achievements"] = true,
						["associations"] = true,
						["leaderboards"] = true,
						["printers"] = true,
						["storage"] = true,
						["territories"] = true
					} }
				else
					BRICKS_SERVER.CONFIG.MODULES[k] = { v, {} }
				end
			end
		end

		-- Old unboxing cases conversion (31/12/2020)
		if( BRICKS_SERVER.CONFIG.UNBOXING and BRICKS_SERVER.CONFIG.UNBOXING.Cases ) then
			for k, v in pairs( BRICKS_SERVER.CONFIG.UNBOXING.Cases ) do
				for key, val in pairs( v.Items ) do
					if( istable( val ) ) then continue end
					BRICKS_SERVER.CONFIG.UNBOXING.Cases[k].Items[key] = { val }
				end
			end
		end

		-- Unboxing item drops new table (02/01/2021)
		if( BRICKS_SERVER.CONFIG.UNBOXING and not BRICKS_SERVER.CONFIG.UNBOXING.Drops ) then
			BRICKS_SERVER.CONFIG.UNBOXING.Drops = table.Copy( BRICKS_SERVER.BASECONFIG.UNBOXING.Drops )
		end

		-- Old groups conversion (24/01/2021)
		if( BRICKS_SERVER.CONFIG.GENERAL.Groups ) then
			for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
				local valueChanged, newUserGroups = false, {}
				for key, val in pairs( v[2] or {} ) do
					if( not isbool( val ) ) then
						valueChanged = true
						newUserGroups[val] = true
					end
				end

				if( valueChanged ) then
					BRICKS_SERVER.CONFIG.GENERAL.Groups[k][2] = newUserGroups
				end
			end
		end
	end
	BRICKS_SERVER.Func.LoadConfig()

	BRICKS_SERVER.CONFIG_LOADED = true
	hook.Run( "BRS_ConfigLoad" )
end

function BRICKS_SERVER.Func.AddLanguageStrings( languageKey, stringTable )
	if( not BRICKS_SERVER.Languages[languageKey] ) then
		BRICKS_SERVER.Languages[languageKey] = stringTable
	else
		table.Merge( BRICKS_SERVER.Languages[languageKey], stringTable )
	end
end

function BRICKS_SERVER.Func.LoadLanguages()
	BRICKS_SERVER.Languages = {}
	local files, directories = file.Find( "bricks_server/languages/*", "LUA" )
	for k, v in pairs( directories ) do
		for key, val in pairs( file.Find( "bricks_server/languages/" .. v .. "/*", "LUA" ) ) do
			AddCSLuaFile( "bricks_server/languages/" .. v .. "/" .. val )
			include( "bricks_server/languages/" .. v .. "/" .. val )
		end
	end
end
BRICKS_SERVER.Func.LoadLanguages()

function BRICKS_SERVER.Func.L( languageKey, ... )
	local languageTable = BRICKS_SERVER.Languages[BRICKS_SERVER.CONFIG.LANGUAGE.Language or "english"] or BRICKS_SERVER.Languages["english"]

	local languageString = ((languageTable or {})[languageKey] or BRICKS_SERVER.Languages["english"][languageKey]) or "MISSING LANGUAGE"

	local configLanguageTable = (BRICKS_SERVER.CONFIG.LANGUAGE.Languages or {})[BRICKS_SERVER.CONFIG.LANGUAGE.Language or "english"]

	if( configLanguageTable and configLanguageTable[2] and configLanguageTable[2][languageKey] ) then
		languageString = configLanguageTable[2][languageKey]
	end

	return (not ... and languageString) or string.format( languageString, ... )
end

function BRICKS_SERVER.Func.GetTheme( key, alpha )
	local color = Color( 0, 0, 0 )
	if( BRICKS_SERVER.BASECONFIG.THEME[key] ) then
		if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).THEME[key] ) then
			color = (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).THEME[key]
		else
			color = BRICKS_SERVER.BASECONFIG.THEME[key]
		end
	end

	if( alpha ) then
		color = Color( color.r, color.g, color.b, alpha )
	end

	return color
end

function BRICKS_SERVER.Func.IsModuleEnabled( moduleName )
	if( BRICKS_SERVER.Modules[moduleName] ) then
		return BRICKS_SERVER.CONFIG.MODULES[moduleName] and BRICKS_SERVER.CONFIG.MODULES[moduleName][1] == true
	end
	
	return false
end

function BRICKS_SERVER.Func.IsSubModuleEnabled( moduleName, subModuleName )
	if( BRICKS_SERVER.Modules[moduleName] ) then
		return BRICKS_SERVER.Func.IsModuleEnabled( moduleName ) and BRICKS_SERVER.CONFIG.MODULES[moduleName][2][subModuleName]
	end
	
	return false
end

local function LoadClientConfig()
	BRICKS_SERVER.BASECLIENTCONFIG = BRICKS_SERVER.BASECLIENTCONFIG or {}
	hook.Run( "BRS_ClientConfigLoad" )
end

local function LoadDevConfig()
	BRICKS_SERVER.DEVCONFIG = BRICKS_SERVER.DEVCONFIG or {}
	AddCSLuaFile( "bricks_server/bricks_server_devcfg_main.lua" )
	include( "bricks_server/bricks_server_devcfg_main.lua" )
	hook.Run( "BRS_DevConfigLoad" )
end

LoadClientConfig()

if( SERVER ) then
	hook.Run( "BRS_SQLLoad" )
end

LoadDevConfig()

--[[ Automatic autoruns ]]--
local AutorunTable = {}
AutorunTable[1] = {
	Location = "bricks_server/core/shared/",
	Type = "Shared"
}
AutorunTable[2] = {
	Location = "bricks_server/core/server/",
	Type = "Server"
}
AutorunTable[3] = {
	Location = "bricks_server/core/client/",
	Type = "Client"
}
AutorunTable[4] = {
	Location = "bricks_server/vgui/",
	Type = "Client"
}

for key, val in ipairs( AutorunTable ) do
	for k, v in ipairs( file.Find( val.Location .. "*.lua", "LUA" ) ) do
		if( val.Type == "Shared" ) then
			if( SERVER ) then
				AddCSLuaFile( val.Location .. v )
			end

			include( val.Location .. v )
		elseif( val.Type == "Client" ) then	
			if( SERVER ) then
				AddCSLuaFile( val.Location .. v )
			elseif( CLIENT ) then
				include( val.Location .. v )
			end
		elseif( val.Type == "Server" and SERVER ) then	
			include( val.Location .. v )
		end
	end
end

hook.Run( "BRS_CoreLoaded" )

--[[ MODULES AUTORUN ]]--
local function loadModuleFiles( filePath )
	local moduleFiles, moduleDirectories = file.Find( filePath .. "/*", "LUA" )

	if( not moduleDirectories ) then return end

	for key, val in pairs( moduleDirectories ) do
		for key2, val2 in pairs( file.Find( filePath .. "/" .. val .. "/*.lua", "LUA" ) ) do
			if( val == "shared" ) then
				AddCSLuaFile( filePath .. "/" .. val .. "/" .. val2 )
				include( filePath .. "/" .. val .. "/" .. val2 )
			elseif( val == "server" and SERVER ) then
				include( filePath .. "/" .. val .. "/" .. val2 )
			elseif( val == "client" or val == "vgui" ) then
				if( CLIENT ) then
					include( filePath .. "/" .. val .. "/" .. val2 )
				elseif( SERVER ) then
					AddCSLuaFile( filePath .. "/" .. val .. "/" .. val2 )
				end
			end
		end
	end
end

if( not BRICKS_SERVER.CONFIG.MODULES["default"] or not BRICKS_SERVER.CONFIG.MODULES["default"][1] ) then
	BRICKS_SERVER.CONFIG.MODULES["default"] = { true, {} }
end

for k, v in pairs( BRICKS_SERVER.CONFIG.MODULES or {} ) do
	if( BRICKS_SERVER.Modules[k] and v[1] == true ) then
		loadModuleFiles( "bricks_server/modules/" .. k )
	else
		continue
	end

	if( table.Count( v[2] ) > 0 ) then
		for key, val in pairs( v[2] ) do
			if( BRICKS_SERVER.Modules[k][3][key] and val == true ) then
				loadModuleFiles( "bricks_server/modules/" .. k .. "/submodules/" .. key )
			end
		end
	end
end

hook.Add( "InitPostEntity", "BricksServerHooks_InitPostEntity_Loaded", function()
	BRICKS_SERVER.INITPOSTENTITY_LOADED = true
end )

hook.Add( "Initialize", "BricksServerHooks_Initialize_Loaded", function()
	BRICKS_SERVER.INITIALIZE_LOADED = true
end )

--[[ CLIENT REQUEST CONFIG ]]--
if( not CLIENT ) then return end

hook.Add( "BRS_ConfigReceived", "BricksServerHooks_BRS_ConfigReceived_ConfigWait", function()
	LoadClientConfig()
	LoadDevConfig()

	hook.Remove( "BRS_ConfigReceived", "BricksServerHooks_BRS_ConfigReceived_ConfigWait" )
end )

BRICKS_SERVER.TEMP.ReceivedConfig = false
BRICKS_SERVER.TEMP.LastConfigRequest = 0
hook.Add( "Think", "BricksServerHooks_Think_RequestConfig", function()
	if( not BRICKS_SERVER.TEMP.ReceivedConfig and CurTime() >= BRICKS_SERVER.TEMP.LastConfigRequest ) then
		net.Start( "BricksServerNet_RequestConfig" )
		net.SendToServer()
		BRICKS_SERVER.TEMP.LastConfigRequest = CurTime()+10
	end
end )

hook.Add( "BRS_ConfigReceived", "BricksServerHooks_BRS_ConfigReceived_RequestConfigRemover", function()
	if( not BRICKS_SERVER.TEMP.ReceivedConfig ) then
		BRICKS_SERVER.TEMP.ReceivedConfig = true
		hook.Remove( "Think", "BricksServerHooks_Think_RequestConfig" )
		hook.Remove( "BRS_ConfigReceived", "BricksServerHooks_BRS_ConfigReceived_RequestConfigRemover" )
	end
end )