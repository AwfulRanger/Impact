DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
include( "mapdata.lua" )
AddCSLuaFile( "cl_hud.lua" )

util.AddNetworkString( "DM_State" )
util.AddNetworkString( "DM_DeathTime" )
util.AddNetworkString( "DM_ShowButton" )

--[[
--DELET THIS
util.AddNetworkString( "DM_CreateItemSpawn" )
net.Receive( "DM_CreateItemSpawn", function( len, ply )
	
	local pos = ply:GetEyeTrace().HitPos
	local item = net.ReadString()
	
	print( "{" )
	print( "	" )
	print( "	Class = \"dm_itemspawn\"," )
	print( "	Functions = {" )
	print( "		" )
	print( "		SetPos = { Vector( " .. math.Round( pos.x ) .. ", " .. math.Round( pos.y ) .. ", " .. math.Round( pos.z ) .. " ) }," )
	print( "		SetItem = { \"" .. item .. "\" }," )
	print( "		" )
	print( "	}," )
	print( "	" )
	print( "}" )
	
	local ent = ents.Create( "dm_itemspawn" )
	if IsValid( ent ) == true then
		
		ent:SetPos( Vector( math.Round( pos.x ), math.Round( pos.y ), math.Round( pos.z ) ) )
		ent:SetItem( item )
		ent:Spawn()
		
	end
	
end )
]]--



function GM:Initialize()
	
	self:CreateMapData()
	
end


function GM:SetState( state )
	
	local setstate = hook.Run( "DM_SetState", state )
	if setstate != nil then state = setstate end
	
	self.RoundState = state
	self.RoundTime = CurTime()
	
	net.Start( "DM_State" )
		
		net.WriteInt( self.RoundState, 32 )
		net.WriteInt( self.RoundTime, 32 )
		
	net.Broadcast()
	
end



function GM:ShowHelp( ply )
	
	net.Start( "DM_ShowButton" )
		
		net.WriteInt( 0, 3 )
		
	net.Send( ply )
	
end

function GM:ShowTeam( ply )
	
	net.Start( "DM_ShowButton" )
		
		net.WriteInt( 1, 3 )
		
	net.Send( ply )
	
end

function GM:ShowSpare1( ply )
	
	net.Start( "DM_ShowButton" )
		
		net.WriteInt( 2, 3 )
		
	net.Send( ply )
	
end

function GM:ShowSpare2( ply )
	
	net.Start( "DM_ShowButton" )
		
		net.WriteInt( 3, 3 )
		
	net.Send( ply )
	
end


GM.ItemClasses = {
	
	[ "item_ammo_357" ] = true,
	[ "item_ammo_357_large" ] = true,
	[ "item_ammo_ar2" ] = true,
	[ "item_ammo_ar2_altfire" ] = true,
	[ "item_ammo_ar2_large" ] = true,
	[ "item_ammo_crossbow" ] = true,
	[ "item_ammo_pistol" ] = true,
	[ "item_ammo_pistol_large" ] = true,
	[ "item_ammo_smg1" ] = true,
	[ "item_ammo_smg1_grenade" ] = true,
	[ "item_ammo_smg1_large" ] = true,
	[ "item_battery" ] = true,
	[ "item_box_buckshot" ] = true,
	[ "item_healthkit" ] = true,
	[ "item_healthvial" ] = true,
	[ "item_rpg_round" ] = true,
	
}

function GM:IsEntityItem( ent )
	
	local isentityitem = hook.Run( "DM_IsEntityItem", ent )
	if isentityitem != nil then return isentityitem end
	
	if IsValid( ent ) == true and self.ItemClasses[ ent:GetClass() ] != nil then return self.ItemClasses[ ent:GetClass() ] end
	
	return false
	
end

function GM:GetAutoItemSpawn()
	
	local autoitemspawn = hook.Run( "DM_GetAutoItemSpawn" )
	if autoitemspawn != nil then return autoitemspawn end
	
	return GetConVar( "dm_autoitemspawn" ):GetBool()
	
end

function GM:CreateItemSpawns( force )
	
	if force != true and self:GetAutoItemSpawn() != true then return end
	
	local precreateitemspawns = hook.Run( "DM_PreCreateItemSpawns" )
	if precreateitemspawns != nil then return precreateitemspawns end
	
	local entities = ents.GetAll()
	for i = 1, #entities do
		
		local ent = entities[ i ]
		if IsValid( ent ) == true and IsValid( ent:GetOwner() ) != true and ( self:IsEntityItem( ent ) == true or ent:IsWeapon() == true ) then
			
			local spawn = ents.Create( "dm_itemspawn" )
			if IsValid( spawn ) == true then
				
				spawn:SetPos( ent:GetPos() )
				spawn:SetItem( ent:GetClass() )
				spawn:SetModel( ent:GetModel() )
				spawn:SetIsWeapon( ent:IsWeapon() )
				spawn:Spawn()
				ent:Remove()
				
			end
			
		end
		
	end
	
	local postcreateitemspawns = hook.Run( "DM_PostCreateItemSpawns" )
	if postcreateitemspawns != nil then return postcreateitemspawns end
	
end

function GM:MapSetup()
	
	local premapsetup = hook.Run( "DM_PreMapSetup" )
	if premapsetup != nil then return premapsetup end
	
	self:ApplyMapData()
	self:CreateSpawnPoints( true )
	self:CreateItemSpawns()
	
	local postmapsetup = hook.Run( "DM_PostMapSetup" )
	if postmapsetup != nil then return postmapsetup end
	
end

function GM:PostCleanupMap()
	
	self:MapSetup()
	
end

function GM:InitPostEntity()
	
	self:MapSetup()
	
end