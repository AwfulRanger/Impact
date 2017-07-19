DEFINE_BASECLASS( "gamemode_base" )

concommand.Add( "dm_forceassign", function( ply, cmd, args, arg )
	
	if IsValid( ply ) == true then return end
	
	local gm = GAMEMODE or GM
	if gm == nil then return end
	
	local plys = player.GetAll()
	for i = 1, #plys do
		
		gm:PlayerRequestTeam( plys[ i ], 4 )
		
	end
	
end, "Force assign players to teams", FCVAR_SERVER_CAN_EXECUTE )

function GM:PlayerSetModel( ply )
	
	ply:SetModel( player_manager.TranslatePlayerModel( ply:GetInfo( "cl_playermodel" ) ) )
	local color = ply:GetTeamColor()
	ply:SetPlayerColor( Vector( color.r / 255, color.g / 255, color.b / 255 ) )
	
	BaseClass.PlayerSetModel( self, ply )
	
end

function GM:PlayerSetHandsModel( ply, ent )
	
	local hands = player_manager.TranslatePlayerHands( player_manager.TranslateToPlayerModelName( ply:GetModel() ) )
	ent:SetModel( hands.model )
	ent:SetSkin( hands.skin )
	ent:SetBodyGroups( hands.body )
	
end

function GM:PlayerLoadout( ply )
	
	ply:SetMaxHealth( 100 )
	ply:SetHealth( 100 )
	
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	
	local state = self:GetRoundState()
	local plyteam = ply:Team()
	
	if state != STATE_WAITINGFORPLAYERS and state != STATE_STARTING and plyteam != TEAM_SPECTATOR and plyteam != TEAM_UNASSIGNED then
		
		ply:Give( "weapon_crowbar" )
		ply:Give( "weapon_physcannon" )
		ply:Give( "weapon_pistol" )
		ply:Give( "weapon_smg1" )
		
		ply:GiveAmmo( 256, "pistol", true )
		ply:GiveAmmo( 32, "357", true )
		ply:GiveAmmo( 256, "smg1", true )
		ply:GiveAmmo( 90, "ar2", true )
		ply:GiveAmmo( 64, "buckshot", true )
		ply:GiveAmmo( 2, "grenade", true )
		ply:GiveAmmo( 1, "smg1_grenade", true )
		
	end
	
end

function GM:PlayerInitialSpawn( ply )
	
	ply:SetTeam( TEAM_SPECTATOR )
	self:PlayerSpawnAsSpectator( ply )
	
end

function GM:PlayerSpawn( ply )
	
	ply:SetWalkSpeed( 200 )
	ply:SetRunSpeed( 300 )
	local nocollide = true
	if ply:Team() == TEAM_FFA then nocollide = false end
	ply:SetNoCollideWithTeammates( nocollide )
	
	local state = self:GetRoundState()
	
	if state == STATE_WAITINGFORPLAYERS or ply:Team() == TEAM_SPECTATOR then return self:PlayerSpawnAsSpectator( ply ) end
	
	local hull = ents.Create( "dm_playerhull" )
	if IsValid( hull ) == true then
		
		hull:SetPos( ply:GetPos() )
		hull:SetOwner( ply )
		hull:Spawn()
		
		ply:SetHullEntity( hull )
		
	end
	
	return BaseClass.PlayerSpawn( self, ply )
	
end

function GM:PlayerSpawnAsSpectator( ply )
	
	ply:StripWeapons()
	
	--ply:SetTeam( TEAM_SPECTATOR )
	ply:Spectate( OBS_MODE_ROAMING )
	
end

function GM:CanPlayerSuicide( ply )
	
	if self:GetRoundState() == STATE_STARTING then return false end
	if ply:Team() != TEAM_RED and ply:Team() != TEAM_BLUE and ply:Team() != TEAM_FFA then return false end
	
	return BaseClass.CanPlayerSuicide( self, ply )
	
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	
	if self:GetRoundState() == STATE_ONGOING and IsValid( attacker ) == true and attacker:IsPlayer() == true then
		
		if attacker:Team() == TEAM_RED and ply:Team() == TEAM_BLUE then
			
			team.AddScore( TEAM_RED, 1 )
			
		elseif attacker:Team() == TEAM_BLUE and ply:Team() == TEAM_RED then
			
			team.AddScore( TEAM_BLUE, 1 )
			
		elseif attacker:Team() == TEAM_FFA and ply:Team() == TEAM_FFA and ply != attacker then
			
			attacker:AddScore()
			
		end
		
	end
	
	if ply:Team() != TEAM_RED and ply:Team() != TEAM_BLUE and ply:Team() != TEAM_FFA then return end
	
	return BaseClass.DoPlayerDeath( self, ply, attacker, dmginfo )
	
end

function GM:PostPlayerDeath( ply )
	
	if ply.DeathTime != nil then
		
		net.Start( "DM_DeathTime" )
			
			net.WriteFloat( ply.DeathTime )
			
		net.Send( ply )
		
	end
	
	local hull = ply:GetHullEntity()
	if IsValid( hull ) == true then hull:Remove() end
	
end

function GM:PlayerDeathThink( ply )
	
	if CurTime() > ply.DeathTime + self:GetRespawnTime() or ply:KeyPressed( IN_JUMP ) == true or ply:KeyPressed( IN_ATTACK ) == true then
		
		ply:Spawn()
		
	end
	
	return true
	
end

function GM:GetFallDamage( ply, speed )
	
	return 0
	
end

function GM:PlayerCanJoinTeam( ply, teamid )
	
	if teamid == 3 then teamid = TEAM_SPECTATOR end
	
	local plyteam = ply:Team()
	
	if plyteam == teamid then return false end
	
	local rnum = team.NumPlayers( TEAM_RED )
	if plyteam == TEAM_RED then rnum = rnum - 1 end
	local bnum = team.NumPlayers( TEAM_BLUE )
	if plyteam == TEAM_BLUE then bnum = bnum - 1 end
	
	if self:GetTeams() != true then
		
		if teamid == TEAM_FFA or teamid == TEAM_SPECTATOR then return true end
		
	elseif teamid == TEAM_RED then
		
		if bnum >= rnum then return true end
		
	elseif teamid == TEAM_BLUE then
		
		if rnum >= bnum then return true end
		
	elseif teamid == TEAM_SPECTATOR then
		
		return true
		
	end
	
	return false
	
end

function GM:PlayerRequestTeam( ply, teamid )
	
	if teamid < 0 or teamid > 3 then
		
		if self:GetTeams() == true then
			
			local rnum = team.NumPlayers( TEAM_RED )
			local bnum = team.NumPlayers( TEAM_BLUE )
			
			if rnum >= bnum then
				
				teamid = TEAM_BLUE
				
			else
				
				teamid = TEAM_RED
				
			end
			
		else
			
			teamid = TEAM_FFA
			
		end
		
	end
	
	if teamid == 3 then teamid = TEAM_SPECTATOR end
	
	if self:PlayerCanJoinTeam( ply, teamid ) != true then return end
	
	local plyteam = ply:Team()
	
	if plyteam == teamid then return end
	
	if teamid != TEAM_FFA and teamid != TEAM_RED and teamid != TEAM_BLUE and teamid != TEAM_SPECTATOR then return end
	
	self:PlayerJoinTeam( ply, teamid )
	
end

function GM:PlayerJoinTeam( ply, teamid )
	
	local oldteam = ply:Team()
	
	if ply:Alive() == true and self:GetRoundState() != STATE_WAITINGFORPLAYERS then
		
		if oldteam != TEAM_RED and oldteam != TEAM_BLUE and oldteam != TEAM_FFA then
			
			ply:KillSilent()
			
		else
			
			ply:Kill()
			
		end
		
	end
	
	ply:SetTeam( teamid )
	
	self:OnPlayerChangedTeam( ply, oldteam, teamid )
	
end

function GM:OnPlayerChangedTeam( ply, oldteam, newteam )
	
	if self:GetRoundState() != STATE_WAITINGFORPLAYERS then
		
		if newteam == TEAM_SPECTATOR then
			
			local pos = ply:EyePos()
			ply:Spawn()
			ply:SetPos( pos )
			
		elseif oldteam == TEAM_SPECTATOR then
			
			ply:Spawn()
			
		end
		
	end
	
	PrintMessage( HUD_PRINTTALK, Format( "%s joined '%s'", ply:Nick(), team.GetName( newteam ) ) )
	
end

function GM:PlayerShouldTakeDamage( ply, attacker )
	
	if GetConVar( "dm_startgod" ):GetBool() == true and self:GetRoundState() == STATE_STARTING then return false end
	
	if ply == attacker or IsValid( attacker ) != true or attacker:IsPlayer() != true or self:GetTeams() != true or ply:Team() != attacker:Team() or self:GetFriendlyFire() == true then return BaseClass.PlayerShouldTakeDamage( self, ply, attacker ) end
	
	return false
	
end

function GM:CreateSpawnPoints( force )
	
	local preffa, prered, preblue = hook.Run( "DM_PreCreateSpawnPoints", force )
	if preffa != nil or prered != nil or preblue != nil then
		
		if preffa != nil then self.FFASpawnPoints = preffa end
		if prered != nil then self.RedSpawnPoints = prered end
		if preblue != nil then self.BlueSpawnPoints = preblue end
		
		return
		
	end
	
	if force == true or self.FFASpawnPoints == nil then
		
		local ffa = {}
		
		local ffaspawn = self.FFASpawn
		
		for i = 1, #ffaspawn do
			
			local spawns = ents.FindByClass( ffaspawn[ i ] )
			
			for i_ = 1, #spawns do
				
				table.insert( ffa, spawns[ i_ ] )
				
			end
			
		end
		
		self.FFASpawnPoints = ffa
		
	end
	
	if force == true or self.RedSpawnPoints == nil then
		
		local red = {}
		
		local redspawn = self.RedSpawn
		
		for i = 1, #redspawn do
			
			local spawns = ents.FindByClass( redspawn[ i ] )
			
			for i_ = 1, #spawns do
				
				table.insert( red, spawns[ i_ ] )
				
			end
			
		end
		
		self.RedSpawnPoints = red
		
	end
	
	if force == true or self.BlueSpawnPoints == nil then
		
		local blue = {}
		
		local bluespawn = self.BlueSpawn
		
		for i = 1, #bluespawn do
			
			local spawns = ents.FindByClass( bluespawn[ i ] )
			
			for i_ = 1, #spawns do
				
				table.insert( blue, spawns[ i_ ] )
				
			end
			
		end
		
		self.BlueSpawnPoints = blue
		
	end
	
	local postffa, postred, postblue = hook.Run( "DM_PostCreateSpawnPoints", force )
	if postffa != nil or postred != nil or postblue != nil then
		
		if postffa != nil then self.FFASpawnPoints = postffa end
		if postred != nil then self.RedSpawnPoints = postred end
		if postblue != nil then self.BlueSpawnPoints = postblue end
		
		return
		
	end
	
end

function GM:PlayerSelectSpawn( ply )
	
	if self:GetTeams() == true then
		
		local spawn = self:PlayerSelectTeamSpawn( ply:Team(), ply )
		if IsValid( spawn ) == true then return spawn end
		
	end
	
	self:CreateSpawnPoints()
	
	local spawns = table.Copy( self.FFASpawnPoints )
	
	if spawns != nil and #spawns <= 0 then
		
		if self.RedSpawnPoints != nil then table.Add( spawns, self.RedSpawnPoints ) end
		if self.BlueSpawnPoints != nil then table.Add( spawns, self.BlueSpawnPoints ) end
		
	end
	
	local spawn
	
	while spawns != nil and #spawns > 0 do
		
		local r = math.random( #spawns )
		spawn = spawns[ r ]
		
		local suitable = self:IsSpawnpointSuitable( ply, spawn, #spawns <= 1 )
		
		if suitable == true then
			
			break
			
		else
			
			table.remove( spawns, r )
			
		end
		
	end
	
	return spawn
	
end

function GM:PlayerSelectTeamSpawn( plyteam, ply )
	
	self:CreateSpawnPoints()
	
	local spawns
	
	if plyteam == TEAM_RED then
		
		if self.RedSpawnPoints != nil and #self.RedSpawnPoints > 0 then
			
			spawns = self.RedSpawnPoints
			
		else
			
			spawns = self.FFASpawnPoints
			
		end
		
	elseif plyteam == TEAM_BLUE then
		
		if self.BlueSpawnPoints != nil and #self.BlueSpawnPoints > 0 then
			
			spawns = self.BlueSpawnPoints
			
		else
			
			spawns = self.FFASpawnPoints
			
		end
		
	end
	
	spawns = table.Copy( spawns )
	
	local spawn
	
	while spawns != nil and #spawns > 0 do
		
		local r = math.random( #spawns )
		spawn = spawns[ r ]
		
		local suitable = self:IsSpawnpointSuitable( ply, spawn, #spawns <= 1 )
		
		if suitable == true then
			
			break
			
		else
			
			table.remove( spawns, r )
			
		end
		
	end
	
	return spawn
	
end

function GM:AllowPlayerPickup( ply, ent )
	
	local plyteam = ply:Team()
	if plyteam == TEAM_SPECTATOR or plyteam == TEAM_UNASSIGNED then return false end
	
	return BaseClass.AllowPlayerPickup( self, ply, ent )
	
end

function GM:OnPlayerCollide( ply, hull, phys, data )
	
	local onplayercollide = hook.Run( "DM_OnPlayerCollide", ply, hull, phys, data )
	if onplayercollide != nil then return onplayercollide end
	
	if IsValid( ply ) != true or IsValid( phys ) != true or data == nil or data.OurOldVelocity == nil then return end
	
	local vel = phys:GetVelocity():Length()
	local oldvel = data.OurOldVelocity:Length()
	local difvel = oldvel - vel
	
	if difvel < 100 then return end
	if util.TraceLine( { start = hull:GetPos(), endpos = ply:GetPos(), filter = { hull, ply } } ).Hit == true then return end
	
	local dmg = DamageInfo()
	dmg:SetDamage( difvel * 0.01 )
	dmg:SetDamageType( DMG_FALL )
	local attacker = hull:GetLastAttacker()
	if IsValid( attacker ) == true then dmg:SetAttacker( attacker ) end
	local inflictor = hull:GetLastInflictor()
	if IsValid( inflictor ) == true then dmg:SetInflictor( inflictor ) end
	self:PlayerCollideDamage( ply, dmg, difvel )
	
end

function GM:PlayerCollideDamage( ply, dmg, vel )
	
	local preplayercollidedamage = hook.Run( "DM_PrePlayerCollideDamage", ply, dmg, vel )
	if preplayercollidedamage != nil then return preplayercollidedamage end
	
	ply:TakeDamageInfo( dmg )
	
	local postplayercollidedamage = hook.Run( "DM_PostPlayerCollideDamage", ply, dmg, vel )
	if postplayercollidedamage != nil then return postplayercollidedamage end
	
end

local dmgtypes = {
	
	[ DMG_CRUSH ] = true,
	[ DMG_SLASH ] = true,
	[ DMG_FALL ] = true,
	[ DMG_PHYSGUN ] = true,
	[ DMG_DIRECT ] = true,
	
}

function GM:EntityTakeDamage( ent, dmg )
	
	if ent:IsPlayer() == true and dmgtypes[ dmg:GetDamageType() ] != true and IsValid( dmg:GetAttacker() ) == true and self:PlayerShouldTakeDamage( ent, dmg:GetAttacker() ) == true then
		
		ent:SetVelocity( dmg:GetDamageForce() )
		local hull = ent:GetHullEntity()
		if IsValid( hull ) == true then
			
			local attacker = dmg:GetAttacker()
			local inflictor = dmg:GetInflictor()
			
			hull:SetLastAttacker( attacker )
			if inflictor == attacker and inflictor:IsPlayer() == true then
				
				local weapon = inflictor:GetActiveWeapon()
				if IsValid( weapon ) == true then hull:SetLastInflictor( weapon ) end
				
			else
				
				hull:SetLastInflictor( inflictor )
				
			end
			
		end
		
		return true
		
	end
	
end



function GM:PlayerHealthRegen( ply )
	
	if ply.DM_HealthRegenTime == nil then ply.DM_HealthRegenTime = 0 end
	
	if CurTime() > ply.DM_HealthRegenTime then
		
		local hp = ply:Health()
		if hp < ply:GetMaxHealth() then ply:SetHealth( hp + 1 ) end
		
		ply.DM_HealthRegenTime = CurTime() + 1
		
	end
	
end

function GM:PlayerTick( ply )
	
	self:PlayerHealthRegen( ply )
	
end

function GM:VehicleMove( ply )
	
	self:PlayerHealthRegen( ply )
	
end