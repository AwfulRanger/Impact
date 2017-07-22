DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "player_class/player_dm.lua" )
include( "player_class/player_dm.lua" )
if SERVER then include( "sv_player.lua" ) end

CreateConVar( "dm_respawntime", "10", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "How long until the player is automatically respawned" )
CreateConVar( "dm_teambalance", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Prevent team stacking" )
CreateConVar( "dm_friendlyfire", "0", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Allow friendly fire" )
CreateConVar( "dm_flashlight", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable flashlight" )

local plymeta = FindMetaTable( "Player" )
function plymeta:SetScore( score )
	
	self:SetNW2Int( "score", score )
	
end
function plymeta:GetScore()
	
	return self:GetNW2Int( "score" )
	
end
function plymeta:AddScore( score )
	
	if score == nil then score = 1 end
	
	self:SetScore( self:GetScore() + score )
	
end
function plymeta:GetTeamColor()
	
	local plycolor = Vector( self:GetInfo( "cl_playercolor" ) )
	local color = Color( plycolor.x * 255, plycolor.y * 255, plycolor.z * 255, 255 )
	
	local gm = GAMEMODE or gm
	if gm != nil and gm:GetTeams() == true then color = team.GetColor( self:Team() ) end
	
	return color
	
end
function plymeta:SetHullEntity( hull )
	
	self:SetNW2Entity( "hull", hull )
	
end
function plymeta:GetHullEntity()
	
	return self:GetNW2Entity( "hull" )
	
end

function GM:GetRespawnTime()
	
	local getrespawntime = hook.Run( "DM_GetRespawnTime" )
	if getrespawntime != nil then return getrespawntime end
	
	return GetConVar( "dm_respawntime" ):GetFloat()
	
end

function GM:GetFriendlyFire()
	
	local getfriendlyfire = hook.Run( "DM_GetFriendlyFire" )
	if getfriendlyfire != nil then return getfriendlyfire end
	
	return GetConVar( "dm_friendlyfire" ):GetBool()
	
end