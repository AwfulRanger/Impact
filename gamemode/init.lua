DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
include( "mapdata.lua" )
AddCSLuaFile( "cl_hud.lua" )

util.AddNetworkString( "IM_State" )
util.AddNetworkString( "IM_DeathTime" )
util.AddNetworkString( "IM_ShowButton" )



function GM:Initialize()
	
	self:CreateMapData()
	
end


function GM:SetState( state )
	
	local setstate = hook.Run( "IM_SetState", state )
	if setstate != nil then state = setstate end
	
	self.RoundState = state
	self.RoundTime = CurTime()
	
	net.Start( "IM_State" )
		
		net.WriteInt( self.RoundState, 32 )
		net.WriteInt( self.RoundTime, 32 )
		
	net.Broadcast()
	
end



function GM:ShowHelp( ply )
	
	net.Start( "IM_ShowButton" )
		
		net.WriteInt( 0, 3 )
		
	net.Send( ply )
	
end

function GM:ShowTeam( ply )
	
	net.Start( "IM_ShowButton" )
		
		net.WriteInt( 1, 3 )
		
	net.Send( ply )
	
end

function GM:ShowSpare1( ply )
	
	net.Start( "IM_ShowButton" )
		
		net.WriteInt( 2, 3 )
		
	net.Send( ply )
	
end

function GM:ShowSpare2( ply )
	
	net.Start( "IM_ShowButton" )
		
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
	
	local isentityitem = hook.Run( "IM_IsEntityItem", ent )
	if isentityitem != nil then return isentityitem end
	
	if IsValid( ent ) == true and self.ItemClasses[ ent:GetClass() ] != nil then return self.ItemClasses[ ent:GetClass() ] end
	
	return false
	
end

function GM:GetAutoItemSpawn()
	
	local autoitemspawn = hook.Run( "IM_GetAutoItemSpawn" )
	if autoitemspawn != nil then return autoitemspawn end
	
	return GetConVar( "im_autoitemspawn" ):GetBool()
	
end

function GM:CreateItemSpawns( force )
	
	if force != true and self:GetAutoItemSpawn() != true then return end
	
	local precreateitemspawns = hook.Run( "IM_PreCreateItemSpawns" )
	if precreateitemspawns != nil then return precreateitemspawns end
	
	local entities = ents.GetAll()
	for i = 1, #entities do
		
		local ent = entities[ i ]
		if IsValid( ent ) == true and IsValid( ent:GetOwner() ) != true and ( self:IsEntityItem( ent ) == true or ent:IsWeapon() == true ) and ent:GetNW2Bool( "IM_ItemSpawn" ) != true then
			
			local spawn = ents.Create( "im_itemspawn" )
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
	
	local postcreateitemspawns = hook.Run( "IM_PostCreateItemSpawns" )
	if postcreateitemspawns != nil then return postcreateitemspawns end
	
end

function GM:MapSetup()
	
	local premapsetup = hook.Run( "IM_PreMapSetup" )
	if premapsetup != nil then return premapsetup end
	
	self:ApplyMapData()
	self:CreateSpawnPoints( true )
	self:CreateItemSpawns()
	
	local postmapsetup = hook.Run( "IM_PostMapSetup" )
	if postmapsetup != nil then return postmapsetup end
	
end

function GM:PostCleanupMap()
	
	self:MapSetup()
	
end

function GM:InitPostEntity()
	
	self:MapSetup()
	
end