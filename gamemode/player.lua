DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "player_class/player_im.lua" )
include( "player_class/player_im.lua" )
if SERVER then include( "sv_player.lua" ) end

CreateConVar( "im_respawntime", "10", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "How long until the player is automatically respawned" )
CreateConVar( "im_teambalance", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Prevent team stacking" )
CreateConVar( "im_friendlyfire", "0", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Allow friendly fire" )
CreateConVar( "im_flashlight", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable flashlight" )

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
	
	local getrespawntime = hook.Run( "IM_GetRespawnTime" )
	if getrespawntime != nil then return getrespawntime end
	
	return GetConVar( "im_respawntime" ):GetFloat()
	
end

function GM:GetFriendlyFire()
	
	local getfriendlyfire = hook.Run( "IM_GetFriendlyFire" )
	if getfriendlyfire != nil then return getfriendlyfire end
	
	return GetConVar( "im_friendlyfire" ):GetBool()
	
end