--[[
--TODO
important:
spawns for css maps



stop the scraping sounds the hull makes
]]--
DeriveGamemode( "base" )

DEFINE_BASECLASS( "gamemode_base" )

AddCSLuaFile( "player.lua" )
include( "player.lua" )
AddCSLuaFile( "round.lua" )
include( "round.lua" )

CreateConVar( "dm_autoitemspawn", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Automatically convert items into item spawns at the start of each round" )
CreateConVar( "dm_itemrespawntime", "10", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Item respawn time" )

GM.Name = "Impact"
GM.Author = "AwfulRanger"
GM.TeamBased = true

TEAM_FFA = 0
TEAM_RED = 1
TEAM_BLUE = 2

GM.FFASpawn = { "info_player_deathmatch", "gmod_player_start", "info_player_teamspawn", "ins_spawnpoint", "aoc_spawnpoint", "dys_spawn_point", "info_player_pirate", "info_player_viking", "info_player_knight", "info_player_coop", "info_player_zombiemaster" }
GM.RedSpawn = { "info_player_rebel", "info_player_terrorist", "info_player_axis", "diprip_start_team_red", "info_player_red", "info_player_zombie" }
GM.BlueSpawn = { "info_player_combine", "info_player_counterterrorist", "info_player_allies", "diprip_start_team_blue", "info_player_blue", "info_player_human" }

function GM:CreateTeams()
	
	team.SetUp( TEAM_FFA, "FFA", Color( 255, 255, 0 ) )
	team.SetSpawnPoint( TEAM_FFA, self.FFASpawn )
	team.SetUp( TEAM_RED, "Red", Color( 255, 0, 0 ) )
	team.SetSpawnPoint( TEAM_RED, self.RedSpawn )
	team.SetUp( TEAM_BLUE, "Blue", Color( 0, 0, 255 ) )
	team.SetSpawnPoint( TEAM_BLUE, self.BlueSpawn )
	
end

GM.LastTeams = nil
function GM:Think()
	
	local teams = self:GetTeams()
	
	if self.LastTeams == nil then self.LastTeams = teams end
	if self.LastTeams != teams then
		
		self:OnTeamsChanged( self.LastTeams, teams )
		self.LastTeams = teams
		
	end
	
	if SERVER then self:HandleRound() end
	
end

function GM:ShouldCollide( ent1, ent2 )
	
	--if IsValid( ent1 ) == true and IsValid( ent2 ) == true and ent1:IsPlayer() == true and ent2:IsPlayer() == true and ( ( ent1:Team() == TEAM_RED and ent2:Team() == TEAM_RED ) or ( ent1:Team() == TEAM_BLUE and ent2:Team() == TEAM_BLUE ) ) then print( "NOCOLLIDE TEAMMATE" ) return false end
	
	return BaseClass.ShouldCollide( self, ent1, ent2 )
	
end

function GM:GetItemRespawnTime()
	
	local itemrespawntime = hook.Run( "DM_GetItemRespawnTime" )
	if itemrespawntime != nil then return itemrespawntime end
	
	return GetConVar( "dm_itemrespawntime" ):GetFloat()
	
end

function GM:PlayerCanPickupItem( ply, item )
	
	local state = self:GetRoundState()
	if state == STATE_ONGOING or state == STATE_ENDING then return BaseClass.PlayerCanPickupItem( self, ply, item ) end
	
	return false
	
end

function GM:PlayerCanPickupWeapon( ply, weapon )
	
	local state = self:GetRoundState()
	if state == STATE_ONGOING or state == STATE_ENDING then return BaseClass.PlayerCanPickupWeapon( self, ply, weapon ) end
	
	return false
	
end