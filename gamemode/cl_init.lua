--[[
--delet this
concommand.Add( "dm_createitemspawn", function( ply, cmd, args, arg )
	
	local pos = LocalPlayer():GetEyeTrace().HitPos
	local item = arg
	
	print( "{" )
	print( "			" )
	print( "			Class = \"dm_itemspawn\"," )
	print( "			Functions = {" )
	print( "				" )
	print( "				SetPos = { Vector( " .. math.Round( pos.x ) .. ", " .. math.Round( pos.y ) .. ", " .. math.Round( pos.z ) .. " ) }," )
	print( "				SetItem = { \"" .. item .. "\" }," )
	print( "				" )
	print( "			}," )
	print( "			" )
	print( "		}," )
	
	net.Start( "DM_CreateItemSpawn" )
		
		net.WriteString( item )
		
	net.SendToServer( "" )
	
end )

concommand.Add( "dm_createffaspawn", function( ply, cmd, args, arg )
	
	local pos = LocalPlayer():GetPos()
	
	print( "{" )
	print( "			" )
	print( "			Class = \"info_player_deathmatch\"," )
	print( "			Functions = {" )
	print( "				" )
	print( "				SetPos = { Vector( " .. math.Round( pos.x ) .. ", " .. math.Round( pos.y ) .. ", " .. math.Round( pos.z ) + 8 .. " ) }," )
	print( "				SetAngles = { Angle( 0, " .. math.Round( LocalPlayer():EyeAngles().y ) .. ", 0 ) }," )
	print( "				" )
	print( "			}," )
	print( "			" )
	print( "		}," )
	
end )
]]--



DEFINE_BASECLASS( "gamemode_base" )

include( "shared.lua" )
include( "cl_hud.lua" )

CreateConVar( "cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )

CreateClientConVar( "dm_showmenu", "1", true, false, "Show menu when spawning for the first time" )

net.Receive( "DM_State", function()
	
	local gm = GAMEMODE or GM
	if gm == nil then return end
	
	gm.RoundState = net.ReadInt( 32 )
	gm.RoundTime = net.ReadInt( 32 )
	
end )

net.Receive( "DM_DeathTime", function()
	
	local ply = LocalPlayer()
	
	if IsValid( ply ) == true then ply.DeathTime = net.ReadFloat() end
	
end )

net.Receive( "DM_ShowButton", function()
	
	local gm = GAMEMODE or GM
	if gm == nil then return end
	
	local show = net.ReadInt( 3 )
	
	if show == 0 then
		
		if gm.ShowHelp != nil then gm:ShowHelp() end
		
	elseif show == 1 then
		
		if gm.ShowTeam != nil then gm:ShowTeam() end
		
	elseif show == 2 then
		
		if gm.ShowSpare1 != nil then gm:ShowSpare1() end
		
	elseif show == 3 then
		
		if gm.ShowSpare2 != nil then gm:ShowSpare2() end
		
	end
	
end )