CreateConVar( "dm_starttime", "10", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Time limit for the start phase" )
CreateConVar( "dm_ongoingtime", "1200", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Time limit for the ongoing phase. Set to 0 or below for unlimited time" )
CreateConVar( "dm_endtime", "10", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Time limit for the end phase" )
CreateConVar( "dm_minplayers", "2", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Minimum players to start" )
CreateConVar( "dm_startfreeze", "0", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Freeze players during the start phase" )
CreateConVar( "dm_startgod", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable godmode on players during the start phase" )
CreateConVar( "dm_teams", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Team deathmatch or free for all" )
CreateConVar( "dm_scorelimit", "50", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Score limit. Set to 0 or below for unlimited score" )

STATE_WAITINGFORPLAYERS = 0
STATE_STARTING = 1
STATE_ONGOING = 2
STATE_ENDING = 3

GM.RoundState = STATE_WAITINGFORPLAYERS
GM.RoundTime = 0

function GM:GetRoundState()
	
	local roundstate = hook.Run( "DM_GetRoundState" )
	if roundstate != nil then return roundstate end
	
	return self.RoundState
	
end

function GM:GetRoundTime()
	
	local roundtime = hook.Run( "DM_GetRoundTime" )
	if roundtime != nil then return roundtime end
	
	return self.RoundTime
	
end

function GM:GetRoundTimeLimit()
	
	local roundtimelimit = hook.Run( "DM_GetRoundTimeLimit" )
	if roundtimelimit != nil then return roundtimelimit end
	
	local state = self:GetRoundState()
	
	if state == STATE_STARTING then
		
		return self:GetStartTime()
		
	elseif state == STATE_ONGOING then
		
		return self:GetOngoingTime()
		
	elseif state == STATE_ENDING then
		
		return self:GetEndTime()
		
	else
		
		return -1
		
	end
	
end

function GM:StartRound()
	
	local prestartround = hook.Run( "DM_PreStartRound" )
	if prestartround != nil then return prestartround end
	
	self:SetState( STATE_STARTING )
	
	game.CleanUpMap()
	
	for _, v in pairs( team.GetAllTeams() ) do
		
		team.SetScore( _, 0 )
		
	end
	
	local plys = player.GetAll()
	for i = 1, #plys do
		
		local ply = plys[ i ]
		
		if SERVER and ply:Team() != TEAM_SPECTATOR then
			
			local freeze = GetConVar( "dm_startfreeze" ):GetBool()
			--local god = GetConVar( "dm_startgod" ):GetBool()
			
			ply:UnSpectate()
			ply:Spawn()
			if freeze == true then ply:SetMoveType( MOVETYPE_NONE ) end
			--if god == true then ply:GodEnable() end
			
		end
		
		ply:SetScore( 0 )
		
	end
	
	local poststartround = hook.Run( "DM_PostStartRound" )
	if poststartround != nil then return poststartround end
	
end

function GM:EndWarmup()
	
	local preendwarmup = hook.Run( "DM_PreEndWarmup" )
	if preendwarmup != nil then return preendwarmup end
	
	self:SetState( STATE_ONGOING )
	
	if SERVER then
		
		local plys = player.GetAll()
		for i = 1, #plys do
			
			local ply = plys[ i ]
			if ply:Alive() != true then ply:Spawn() end
			ply:SetMoveType( MOVETYPE_WALK )
			ply:GodDisable()
			self:PlayerLoadout( ply )
			
		end
		
	end
	
	local postendwarmup = hook.Run( "DM_PostEndWarmup" )
	if postendwarmup != nil then return postendwarmup end
	
end

function GM:EndRound( winner )
	
	local preendround = hook.Run( "DM_PreEndRound" )
	if preendround != nil then return preendround end
	
	self:SetState( STATE_ENDING )
	
	if SERVER and winner != nil then
		
		if isnumber( winner ) == true then
			
			PrintMessage( HUD_PRINTCENTER, "Team " .. team.GetName( winner ) .. " wins!" )
			
		elseif isstring( winner ) == true then
			
			PrintMessage( HUD_PRINTCENTER, winner .. " wins!" )
			
		elseif winner:IsPlayer() == true then
			
			PrintMessage( HUD_PRINTCENTER, winner:Nick() .. " wins!" )
			
		end
		
	end
	
	local postendround = hook.Run( "DM_PostEndRound" )
	if postendround != nil then return postendround end
	
end

function GM:GetStartTime()
	
	local getstarttime = hook.Run( "DM_GetStartTime" )
	if getstarttime != nil then return getstarttime end
	
	return GetConVar( "dm_starttime" ):GetFloat()
	
end

function GM:GetOngoingTime()
	
	local getongoingtime = hook.Run( "DM_GetOngoingTime" )
	if getongoingtime != nil then return getongoingtime end
	
	return GetConVar( "dm_ongoingtime" ):GetFloat()
	
end

function GM:GetEndTime()
	
	local getendtime = hook.Run( "DM_GetEndTime" )
	if getendtime != nil then return getendtime end
	
	return GetConVar( "dm_endtime" ):GetFloat()
	
end

function GM:GetMinPlayers()
	
	local getminplayers = hook.Run( "DM_GetMinPlayers" )
	if getminplayers != nil then return getminplayers end
	
	return GetConVar( "dm_minplayers" ):GetInt()
	
end

function GM:GetTeams()
	
	local getteams = hook.Run( "DM_GetTeams" )
	if getteams != nil then return getteams end
	
	return GetConVar( "dm_teams" ):GetBool()
	
end

function GM:GetScoreLimit()
	
	local getscorelimit = hook.Run( "DM_GetScoreLimit" )
	if getscorelimit != nil then return getscorelimit end
	
	return GetConVar( "dm_scorelimit" ):GetInt()
	
end

function GM:WaitForPlayers()
	
	local prewaitforplayers = hook.Run( "DM_PreWaitForPlayers" )
	if prewaitforplayers != nil then return prewaitforplayers end
	
	self:SetState( STATE_WAITINGFORPLAYERS )
	
	if SERVER then
		
		local plys = player.GetAll()
		for i = 1, #plys do
			
			local ply = plys[ i ]
			ply:SetTeam( TEAM_SPECTATOR )
			self:PlayerSpawnAsSpectator( ply )
			
		end
		
	end
	
	local postwaitforplayers = hook.Run( "DM_PostWaitForPlayers" )
	if postwaitforplayers != nil then return postwaitforplayers end
	
end


function GM:GetHighScore( exclude )
	
	--return cached results if they're recent
	--if self.LastHighScoreTime == CurTime() then return self.LastHighScore, self.LastHighScoreWinner end
	
	if istable( exclude ) != true then
		
		if exclude != nil then
			
			exclude = { [ exclude ] = true }
			
		else
			
			exclude = {}
			
		end
		
	end
	
	local highscore = -1
	local winner
	if self:GetTeams() == true then
		
		local redscore = team.GetScore( TEAM_RED )
		local bluescore = team.GetScore( TEAM_BLUE )
		
		if redscore > highscore then
			
			highscore = redscore
			winner = TEAM_RED
			
		end
		if bluescore > highscore then
			
			highscore = bluescore
			winner = TEAM_BLUE
			
		end
		
	else
		
		local plys = player.GetAll()
		for i = 1, #plys do
			
			local ply = plys[ i ]
			if exclude[ ply ] != true then
				
				local plyscore = ply:GetScore()
				
				if plyscore > highscore then
					
					highscore = plyscore
					winner = ply
					
				end
				
			end
			
		end
		
	end
	
	--cache results
	--self.LastHighScoreTime = CurTime()
	--self.LastHighScore = highscore
	--self.LastHighScoreWinner = winner
	
	return highscore, winner
	
end


if SERVER then
	
	function GM:HandleRound()
		
		local state = self:GetRoundState()
		local time = self:GetRoundTime()
		
		local rnum = team.NumPlayers( TEAM_RED )
		local bnum = team.NumPlayers( TEAM_BLUE )
		local fnum = team.NumPlayers( TEAM_FFA )
		
		if state != STATE_WAITINGFORPLAYERS and rnum + bnum + fnum < self:GetMinPlayers() then
			
			self:WaitForPlayers()
			
		elseif state == STATE_STARTING then
			
			if CurTime() > time + self:GetStartTime() then
				
				self:EndWarmup()
				
			end
			
		elseif state == STATE_ONGOING then
			
			local highscore, winner = self:GetHighScore()
			
			local ongoingtime = self:GetOngoingTime()
			local scorelimit = self:GetScoreLimit()
			
			if ongoingtime > 0 and CurTime() > time + ongoingtime then
				
				self:EndRound( winner )
				
			elseif scorelimit > 0 and highscore >= scorelimit then
				
				self:EndRound( winner )
				
			end
			
		elseif state == STATE_ENDING then
			
			if CurTime() > time + self:GetEndTime() then
				
				self:StartRound()
				
			end
			
		else
			
			if rnum + bnum + fnum >= self:GetMinPlayers() then
				
				self:StartRound()
				
			end
			
		end
		
	end
	
end

function GM:OnTeamsChanged( oldteams, newteams )
	
	local onteamschanged = hook.Run( "DM_OnTeamsChanged", oldteams, newteams )
	if onteamschanged != nil then return onteamschanged end
	
	if CLIENT then return end
	
	local plys = player.GetAll()
	for i = 1, #plys do
		
		local ply = plys[ i ]
		
		ply:SetTeam( TEAM_SPECTATOR )
		self:PlayerSpawnAsSpectator( ply )
		
	end
	
end