DEFINE_BASECLASS( "gamemode_base" )

surface.CreateFont( "DM_Bold", {
	
	font = "Roboto Bold",
	size = ScreenScale( 24 ),
	
} )
surface.CreateFont( "DM_BoldSmall", {
	
	font = "Roboto Bold",
	size = ScreenScale( 16 ),
	
} )
surface.CreateFont( "DM_BoldTiny", {
	
	font = "Roboto Bold",
	size = ScreenScale( 8 ),
	
} )

local function DrawShadowText( text, x, y, color, font )
	
	local shadow = math.ceil( ScrH() * 0.0025 )
	
	if font != nil then surface.SetFont( font ) end
	
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.SetTextPos( x + shadow, y + shadow )
	surface.DrawText( text )
	
	surface.SetTextColor( color )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
end

local function DrawHealth()
	
	local ply = LocalPlayer()
	
	local border = math.Round( ScrH() * 0.005 )
	local bgcolor = Color( 0, 0, 0, 150 )
	local bordercolor = ply:GetTeamColor()
	local altcolor = Color( 255, 255, 255, 255 )
	
	local x = ScrW() * 0.05
	local y = ScrH() * 0.85
	local w = ScrW() * 0.1
	local h = ScrH() * 0.1
	
	draw.RoundedBoxEx( 16, x - border, y - border, w + ( border * 2 ), h + ( border * 2 ), bordercolor, true, false, true, false )
	draw.RoundedBoxEx( 16, x, y, w, h, bgcolor, true, false, true, false )
	
	local health = ply:Health()
	if health <= 0 or ply:Alive() != true then health = "-" end
	surface.SetFont( "DM_Bold" )
	local tw, th = surface.GetTextSize( health )
	
	DrawShadowText( health, x + ( w * 0.5 ) - ( tw * 0.5 ), y + ( h * 0.5 ) - ( th * 0.5 ), altcolor )
	
end

local function DrawArmor()
	
	local ply = LocalPlayer()
	
	local armor = ply:Armor()
	
	local border = math.Round( ScrH() * 0.005 )
	local bgcolor = Color( 0, 0, 0, 150 )
	local bordercolor = ply:GetTeamColor()
	local altcolor = Color( 255, 255, 255, 255 )
	
	local x = ScrW() * 0.15 + border
	local y = ScrH() * 0.85
	local w = ScrW() * 0.1
	local h = ScrH() * 0.1
	draw.RoundedBoxEx( 16, x - border, y - border, w + ( border * 2 ), h + ( border * 2 ), bordercolor, false, true, false, true )
	draw.RoundedBoxEx( 16, x, y, w, h, bgcolor, false, true, false, true )
	
	if armor <= 0 or ply:Alive() != true then armor = "-" end
	surface.SetFont( "DM_Bold" )
	local tw, th = surface.GetTextSize( armor )
	
	DrawShadowText( armor, x + ( w * 0.5 ) - ( tw * 0.5 ), y + ( h * 0.5 ) - ( th * 0.5 ), altcolor )
	
end

local blacklist = {
	
	[ "weapon_crowbar" ] = true,
	[ "weapon_physcannon" ] = true,
	
}

local function DrawAmmo()
	
	local ply = LocalPlayer()
	
	local border = math.Round( ScrH() * 0.005 )
	local bgcolor = Color( 0, 0, 0, 150 )
	local bordercolor = ply:GetTeamColor()
	local altcolor = Color( 255, 255, 255, 255 )
	
	local weapon = ply:GetActiveWeapon()
	
	if IsValid( weapon ) != true then return end
	
	local x = ( ScrW() * 0.75 ) - border
	local y = ScrH() * 0.85
	local w = ScrW() * 0.1
	local h = ScrH() * 0.1
	draw.RoundedBoxEx( 16, x - border, y - border, w + ( border * 2 ), h + ( border * 2 ), bordercolor, true, false, true, false )
	draw.RoundedBoxEx( 16, x, y, w, h, bgcolor, true, false, true, false )
	
	local display
	if weapon.CustomAmmoDisplay != nil then display = weapon:CustomAmmoDisplay() end
	
	local clip = weapon:Clip1()
	if display != nil then clip = display.PrimaryClip or clip end
	
	local ammo = ply:GetAmmoCount( weapon:GetPrimaryAmmoType() )
	if weapon.Ammo1 != nil then ammo = weapon:Ammo1() end
	if weapon:GetPrimaryAmmoType() < 0 then ammo = "-" end
	if display != nil then ammo = display.PrimaryAmmo or ammo end
	
	if clip < 0 or ammo == "-" then
		
		surface.SetFont( "DM_Bold" )
		
		if clip >= 0 and blacklist[ weapon:GetClass() ] != true and ammo == "-" then ammo = clip end
		
		local ammow, ammoh = surface.GetTextSize( ammo )
		
		DrawShadowText( ammo, x + ( w * 0.5 ) - ( ammow * 0.5 ), y + ( h * 0.5 ) - ( ammoh * 0.5 ), altcolor )
		
	else
		
		surface.SetFont( "DM_BoldSmall" )
		
		local clipw, cliph = surface.GetTextSize( clip )
		local ammow, ammoh = surface.GetTextSize( ammo )
		
		DrawShadowText( clip, x + ( w * 0.5 ) - ( clipw * 0.5 ), y + ( h * 0.5 ) - cliph, altcolor )
		DrawShadowText( ammo, x + ( w * 0.5 ) - ( ammow * 0.5 ), y + ( h * 0.5 ), altcolor )
		
	end
	
end

local function DrawSecondaryAmmo()
	
	local ply = LocalPlayer()
	
	local border = math.Round( ScrH() * 0.005 )
	local bgcolor = Color( 0, 0, 0, 150 )
	local bordercolor = ply:GetTeamColor()
	local altcolor = Color( 255, 255, 255, 255 )
	
	local shadow = ScrH() * 0.005
	local shadowcolor = Color( 0, 0, 0, 255 )
	
	local weapon = ply:GetActiveWeapon()
	
	if IsValid( weapon ) != true then return end
	
	local x = ScrW() * 0.85
	local y = ScrH() * 0.85
	local w = ScrW() * 0.1
	local h = ScrH() * 0.1
	draw.RoundedBoxEx( 16, x - border, y - border, w + ( border * 2 ), h + ( border * 2 ), bordercolor, false, true, false, true )
	draw.RoundedBoxEx( 16, x, y, w, h, bgcolor, false, true, false, true )
	
	local display
	if weapon.CustomAmmoDisplay != nil then display = weapon:CustomAmmoDisplay() end
	
	local clip = weapon:Clip2()
	if display != nil then clip = display.SecondaryClip or clip end
	
	local ammo = ply:GetAmmoCount( weapon:GetSecondaryAmmoType() )
	if weapon.Ammo2 != nil then ammo = weapon:Ammo2() end
	if weapon:GetSecondaryAmmoType() < 0 then ammo = "-" end
	if display != nil then ammo = display.SecondaryAmmo or ammo end
	
	if clip < 0 or ammo == "-" then
		
		surface.SetFont( "DM_Bold" )
		
		if clip >= 0 and blacklist[ weapon:GetClass() ] != true and ammo == "-" then ammo = clip end
		
		local ammow, ammoh = surface.GetTextSize( ammo )
		
		DrawShadowText( ammo, x + ( w * 0.5 ) - ( ammow * 0.5 ), y + ( h * 0.5 ) - ( ammoh * 0.5 ), altcolor )
		
	else
		
		surface.SetFont( "DM_BoldSmall" )
		
		local clipw, cliph = surface.GetTextSize( clip )
		local ammow, ammoh = surface.GetTextSize( ammo )
		
		DrawShadowText( clip, x + ( w * 0.5 ) - ( clipw * 0.5 ), y + ( h * 0.5 ) - cliph, altcolor )
		DrawShadowText( ammo, x + ( w * 0.5 ) - ( ammow * 0.5 ), y + ( h * 0.5 ), altcolor )
		
	end
	
end

local function DrawDeathInfo( gm )
	
	local ply = LocalPlayer()
	
	if ply.DeathTime == nil or CurTime() > ply.DeathTime + gm:GetRespawnTime() then return end
	
	local border = math.Round( ScrH() * 0.005 )
	local bgcolor = Color( 0, 0, 0, 150 )
	local bordercolor = ply:GetTeamColor()
	local altcolor = Color( 255, 255, 255, 255 )
	
	local x = ScrW() * 0.5
	local y = ScrH() * 0.25
	
	surface.SetFont( "DM_BoldSmall" )
	
	local text = "Respawning in " .. math.Round( ( ply.DeathTime + gm:GetRespawnTime() ) - CurTime() ) .. " seconds"
	
	local w, h = surface.GetTextSize( text )
	
	DrawShadowText( text, x - ( w * 0.5 ), y - ( h * 0.5 ), altcolor )
	
end

local translation = {
	
	[ STATE_WAITINGFORPLAYERS ] = "Waiting for players",
	[ STATE_STARTING ] = "Starting",
	[ STATE_ONGOING ] = "Ongoing",
	[ STATE_ENDING ] = "Ending",
	
}

local function DrawRoundInfo( gm )
	
	local ply = LocalPlayer()
	
	local border = math.Round( ScrH() * 0.005 )
	local bgcolor = Color( 0, 0, 0, 150 )
	local bordercolor = ply:GetTeamColor()
	local altcolor = Color( 255, 255, 255, 255 )
	
	local state = gm:GetRoundState()
	local text = translation[ STATE_WAITINGFORPLAYERS ]
	if state != nil and translation[ state ] != nil then text = translation[ state ] end
	
	--round time and state
	local time = ( gm:GetRoundTime() + gm:GetRoundTimeLimit() ) - CurTime()
	local ftime = string.FormattedTime( time )
	local m = tostring( ftime.m )
	local s = tostring( ftime.s )
	if #s <= 1 then s = "0" .. s end
	local timestr = m .. ":" .. s
	if time < 0 then timestr = "" end
	
	surface.SetFont( "DM_BoldSmall" )
	
	local statew, stateh = surface.GetTextSize( text )
	local timew, timeh = surface.GetTextSize( timestr )
	
	local w = surface.GetTextSize( text )
	w = math.max( w, surface.GetTextSize( timestr ) )
	w = math.max( w, surface.GetTextSize( "9999:9999:9999" ) )
	
	local buffer = ScrH() * 0.025
	
	--local h = ScrH() * 0.1
	--local h = ( buffer * 0.5 ) + stateh + timeh
	local h = stateh
	if time > 0 then h = h + ( buffer * 0.5 ) + timeh end
	
	local x = ScrW() * 0.5
	local y = 0
	
	draw.RoundedBoxEx( 16, x - border - ( w * 0.5 ) - buffer, y, w + ( border * 2 ) + ( buffer * 2 ), h + border + buffer, bordercolor, false, false, true, true )
	draw.RoundedBoxEx( 16, x - ( w * 0.5 ) - buffer, y, w + ( buffer * 2 ), h + buffer, bgcolor, false, false, true, true )
	
	DrawShadowText( text, x - ( statew * 0.5 ), y + ( buffer * 0.5 ), altcolor )
	DrawShadowText( timestr, x - ( timew * 0.5 ), y + buffer + stateh, altcolor )
	
	--score
	if state != STATE_WAITINGFORPLAYERS then
		
		local friendscore = 0
		local friendcolor = bgcolor
		local enemyscore = 0
		local enemycolor = Color( 0, 0, 0, 0 )
		
		if gm:GetTeams() == true then
			
			if ply:Team() == TEAM_BLUE then
				
				friendscore = team.GetScore( TEAM_BLUE )
				friendcolor = team.GetColor( TEAM_BLUE )
				enemyscore = team.GetScore( TEAM_RED )
				enemycolor = team.GetColor( TEAM_RED )
				
			else
				
				friendscore = team.GetScore( TEAM_RED )
				friendcolor = team.GetColor( TEAM_RED )
				enemyscore = team.GetScore( TEAM_BLUE )
				enemycolor = team.GetColor( TEAM_BLUE )
				
			end
			
		else
			
			local highscore, winner = gm:GetHighScore( ply )
			
			friendscore = ply:GetScore()
			friendcolor = ply:GetTeamColor()
			enemyscore = highscore
			enemycolor = team.GetColor( TEAM_FFA )
			
		end
		
		local limitw = surface.GetTextSize( gm:GetScoreLimit() )
		local maxw = surface.GetTextSize( 9999 )
		local sep = ScrW() * 0.1
		
		
		--friendly score
		local fw, fh = surface.GetTextSize( friendscore )
		local fbgw = math.max ( fw, limitw )
		fbgw = math.max( fbgw, maxw )
		
		local fx = x - ( w * 0.5 ) - sep
		
		draw.RoundedBoxEx( 16, fx - ( fbgw * 0.5 ) - border - buffer, y, fbgw + ( border * 2 ) + ( buffer * 2 ), fh + border + buffer, friendcolor, false, false, true, true )
		draw.RoundedBoxEx( 16, fx - ( fbgw * 0.5 ) - buffer, y, fbgw + ( buffer * 2 ), fh + buffer, bgcolor, false, false, true, true )
		
		DrawShadowText( friendscore, fx - ( fw * 0.5 ), y + ( buffer * 0.5 ), altcolor )
		
		
		--enemy score
		local ew, eh = surface.GetTextSize( enemyscore )
		local ebgw = math.max ( ew, limitw )
		ebgw = math.max( ebgw, maxw )
		
		local ex = x + ( w * 0.5 ) + sep
		
		draw.RoundedBoxEx( 16, ex - ( ebgw * 0.5 ) - border - buffer, y, ebgw + ( border * 2 ) + ( buffer * 2 ), eh + border + buffer, enemycolor, false, false, true, true )
		draw.RoundedBoxEx( 16, ex - ( ebgw * 0.5 ) - buffer, y, ebgw + ( buffer * 2 ), eh + buffer, bgcolor, false, false, true, true )
		
		DrawShadowText( enemyscore, ex - ( ew * 0.5 ), y + ( buffer * 0.5 ), altcolor )
		
	end
	
end

function GM:HUDPaint()
	
	local ply = LocalPlayer()
	
	if IsValid( ply ) != true then return end
	
	local plyteam = ply:Team()
	
	if ( plyteam == TEAM_RED or plyteam == TEAM_BLUE or plyteam == TEAM_FFA ) and self:GetRoundState() != STATE_WAITINGFORPLAYERS and ply:Alive() == true then
		
		if hook.Run( "HUDShouldDraw", "DM_Health" ) != false then DrawHealth() end
		if hook.Run( "HUDShouldDraw", "DM_Armor" ) != false then DrawArmor() end
		if hook.Run( "HUDShouldDraw", "DM_Ammo" ) != false then DrawAmmo() end
		if hook.Run( "HUDShouldDraw", "DM_SecondaryAmmo" ) != false then DrawSecondaryAmmo() end
		if ply:Alive() != true and hook.Run( "HUDShouldDraw", "DM_DeathInfo" ) != false then DrawDeathInfo( self ) end
		
	end
	if hook.Run( "HUDShouldDraw", "DM_RoundInfo" ) != false then DrawRoundInfo( self ) end
	
	return BaseClass.HUDPaint( self )
	
end

local nodraw = {
	
	[ "CHudHealth" ] = false,
	[ "CHudBattery" ] = false,
	[ "CHudAmmo" ] = false,
	[ "CHudSecondaryAmmo" ] = false,
	
}

function GM:HUDShouldDraw( hud )
	
	if nodraw[ hud ] != nil then return nodraw[ hud ] end
	
	return BaseClass.HUDShouldDraw( self, hud )
	
end

local function getbind( bind )
	
	return input.LookupBinding( bind, true ) or "UNBOUND"
	
end



function GM:GetHelpPanel()
	
	local gethelppanel = hook.Run( "DM_GetHelpPanel" )
	if gethelppanel != nil then return gethelppanel end
	
	local help = vgui.Create( "DPanel" )
	function help:Paint() end
	
	local rich = vgui.Create( "RichText" )
	rich:SetParent( help )
	rich:Dock( FILL )
	
	rich:InsertColorChange( 255, 255, 255, 255 )
	
	rich:AppendText( "Press \"" .. getbind( "gm_showhelp" ) .. "\" to open this help menu\n" )
	rich:AppendText( "Press \"" .. getbind( "gm_showteam" ) .. "\" to open the teams menu\n" )
	
	return help
	
end

function GM:GetTeamsPanel()
	
	local getteamspanel = hook.Run( "DM_GetTeamsPanel" )
	if getteamspanel != nil then return getteamspanel end
	
	local teams = vgui.Create( "DPanel" )
	function teams:Paint() end
	
	if self:GetTeams() == true then
		
		local red = vgui.Create( "DButton" )
		red:SetParent( teams )
		red:Dock( TOP )
		red:SetText( "Red" )
		function red:DoClick()
			
			RunConsoleCommand( "changeteam", TEAM_RED )
			
		end
		
		local blue = vgui.Create( "DButton" )
		blue:SetParent( teams )
		blue:Dock( TOP )
		blue:SetText( "Blue" )
		function blue:DoClick()
			
			RunConsoleCommand( "changeteam", TEAM_BLUE )
			
		end
		
	else
		
		local ffa = vgui.Create( "DButton" )
		ffa:SetParent( teams )
		ffa:Dock( TOP )
		ffa:SetText( "FFA" )
		function ffa:DoClick()
			
			RunConsoleCommand( "changeteam", TEAM_FFA )
			
		end
		
	end
	
	local spec = vgui.Create( "DButton" )
	spec:SetParent( teams )
	spec:Dock( TOP )
	spec:SetText( "Spectate" )
	function spec:DoClick()
		
		RunConsoleCommand( "changeteam", 3 )
		
	end
	
	local auto = vgui.Create( "DButton" )
	auto:SetParent( teams )
	auto:Dock( TOP )
	auto:SetText( "Auto" )
	function auto:DoClick()
		
		RunConsoleCommand( "changeteam", 4 )
		
	end
	
	return teams
	
end

function GM:GetMenuPanel( tab )
	
	local getmenupanel = hook.Run( "DM_GetMenuPanel", tab )
	if getmenupanel != nil then return getmenupanel end
	
	if IsValid( self.MenuPanel ) != true then
		
		local panel = vgui.Create( "DFrame" )
		panel:SetPos( ScrW() * 0.3, ScrH() * 0.3 )
		panel:SetSize( ScrW() * 0.4, ScrH() * 0.4 )
		panel:SetTitle( "" )
		panel:SetSizable( true )
		panel:MakePopup()
		
		local show = vgui.Create( "DCheckBoxLabel" )
		show:SetParent( panel )
		show:Dock( BOTTOM )
		show:SetConVar( "dm_showmenu" )
		show:SetText( "Show menu when spawning for the first time" )
		
		local tabs = vgui.Create( "DPropertySheet" )
		tabs:SetParent( panel )
		tabs:Dock( FILL )
		
		tabs:AddSheet( "Help", self:GetHelpPanel(), "materials/icon16/help.png" )
		tabs:AddSheet( "Teams", self:GetTeamsPanel(), "materials/icon16/group.png" )
		
		self.MenuPanel = panel
		self.MenuPanelTabs = tabs
		
	end
	
	if tab != nil then self.MenuPanelTabs:SwitchToName( tab ) end
	
	return self.MenuPanel, self.MenuPanelTabs
	
end

function GM:ShowHelp()
	
	self:GetMenuPanel( "Help" )
	
end

function GM:ShowTeam()
	
	self:GetMenuPanel( "Teams" )
	
end

function GM:InitPostEntity()
	
	if GetConVar( "dm_showmenu" ):GetBool() == true then self:ShowHelp() end
	
end



--yikes this is a mess

local muted = Material( "icon16/sound_mute.png", "noclamp smooth" )
--local muted = Material( "icon16/sound_mute.png" )
local unmuted = Material( "icon16/sound.png", "noclamp smooth" )
--local unmuted = Material( "icon16/sound.png" )

function GM:ScoreboardPlayer( ply, panel )
	
	local border = math.Round( ScrH() * 0.005 )
	
	local plybg = vgui.Create( "DPanel" )
	plybg:SetParent( panel )
	plybg:DockMargin( border, border, border, border )
	plybg:DockPadding( border, border, border, border )
	plybg:Dock( TOP )
	plybg.Paint = function() end
	
	local avatar = vgui.Create( "AvatarImage" )
	avatar:SetParent( plybg )
	avatar:SetSize( ScrH() * 0.05, ScrH() * 0.05 )
	avatar:DockMargin( 0, 0, border * 2, 0 )
	avatar:Dock( LEFT )
	avatar:SetPlayer( ply, 184 )
	
	local profile = vgui.Create( "DButton" )
	profile:SetParent( avatar )
	profile:Dock( FILL )
	profile:SetText( "" )
	profile.Paint = function() end
	profile.DoClick = function()
		
		ply:ShowProfile()
		
	end
	
	local mute = vgui.Create( "DButton" )
	mute:SetParent( plybg )
	mute:SetSize( ScrH() * 0.05, ScrH() * 0.05 )
	mute:DockMargin( border * 4, 0, 0, 0 )
	mute:Dock( RIGHT )
	mute:SetText( "" )
	mute.Paint = function( panel, w, h ) 
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( unmuted )
		if ply:IsMuted() == true then surface.SetMaterial( muted ) end
		surface.DrawTexturedRect( w * 0.25, h * 0.25, w * 0.5, h * 0.5 )
		
	end
	mute.DoClick = function( panel )
		
		if ply:IsMuted() == true then
			
			ply:SetMuted( false )
			
		else
			
			ply:SetMuted( true )
			
		end
		
	end
	
	local ping = vgui.Create( "DLabel" )
	ping:SetParent( plybg )
	ping:DockMargin( border * 4, 0, 0, 0 )
	ping:Dock( RIGHT )
	ping:SetFont( "DM_BoldTiny" )
	ping:SetText( "Ping: " .. tostring( ( ply:IsBot() == true and "BOT" ) or ply:Ping() ) )
	ping:SizeToContents()
	
	local deaths = vgui.Create( "DLabel" )
	deaths:SetParent( plybg )
	deaths:DockMargin( border * 4, 0, 0, 0 )
	deaths:Dock( RIGHT )
	deaths:SetFont( "DM_BoldTiny" )
	deaths:SetText( "Deaths: " .. ply:Deaths() )
	deaths:SizeToContents()
	
	local kills = vgui.Create( "DLabel" )
	kills:SetParent( plybg )
	kills:DockMargin( border * 4, 0, 0, 0 )
	kills:Dock( RIGHT )
	kills:SetFont( "DM_BoldTiny" )
	kills:SetText( "Kills: " .. ply:Frags() )
	kills:SizeToContents()
	
	local name = vgui.Create( "DLabel" )
	name:SetParent( plybg )
	name:Dock( LEFT )
	name:SetFont( "DM_BoldTiny" )
	name:SetText( ply:Nick() )
	name:SizeToContents()
	
	plybg:SetTall( avatar:GetWide() )
	
	avatar:SetWide( plybg:GetTall() - ( border * 2 ) )
	mute:SetWide( plybg:GetTall() - ( border * 2 ) )
	
	return plybg
	
end

function GM:HUDDrawScoreBoard()
end

function GM:ScoreboardShow()
	
	if IsValid( self.ScoreboardPanel ) == true then
		
		self.ScoreboardPanel:Remove()
		self.ScoreboardPanel = nil
		
	end
	
	local ply = LocalPlayer()
	
	local border = math.Round( ScrH() * 0.005 )
	local bgcolor = Color( 0, 0, 0, 150 )
	local bordercolor = ply:GetTeamColor()
	local altcolor = Color( 255, 255, 255, 255 )
	
	local plyteam = ply:Team()
	local teams = self:GetTeams()
	
	if teams == true then
		
		if ply:Team() == TEAM_BLUE then
			
			friendcolor = team.GetColor( TEAM_BLUE )
			enemycolor = team.GetColor( TEAM_RED )
			
		else
			
			friendcolor = team.GetColor( TEAM_RED )
			enemycolor = team.GetColor( TEAM_BLUE )
			
		end
		
	else
		
		friendcolor = ply:GetTeamColor()
		enemycolor = team.GetColor( TEAM_FFA )
		
	end
	
	self.ScoreboardPanel = vgui.Create( "DPanel" )
	if teams == true then
		
		self.ScoreboardPanel:SetPos( ( ScrW() * 0.15 ) - border, ( ScrH() * 0.15 ) - border )
		self.ScoreboardPanel:SetSize( ( ScrW() * 0.7 ) - ( border * 2 ), ( ScrH() * 0.7 ) - ( border * 2 ) )
		self.ScoreboardPanel.Paint = function( panel, w, h )
			
			draw.RoundedBoxEx( 16, 0, 0, w * 0.5, h, friendcolor, true, true, true, true )
			draw.RoundedBoxEx( 16, border, border, ( w * 0.5 ) - ( border * 2 ), h - ( border * 2 ), bgcolor, true, true, true, true )
			
			draw.RoundedBoxEx( 16, w * 0.5, 0, w * 0.5, h, enemycolor, true, true, true, true )
			draw.RoundedBoxEx( 16, ( w * 0.5 ) + border, border, ( w * 0.5 ) - ( border * 2 ), h - ( border * 2 ), bgcolor, true, true, true, true )
			
		end
		
	else
		
		self.ScoreboardPanel:SetPos( ( ScrW() * 0.325 ) - border, ( ScrH() * 0.15 ) - border )
		self.ScoreboardPanel:SetSize( ( ScrW() * 0.35 ) - ( border * 2 ), ( ScrH() * 0.7 ) - ( border * 2 ) )
		self.ScoreboardPanel.Paint = function( panel, w, h )
			
			draw.RoundedBoxEx( 16, 0, 0, w, h, friendcolor, true, true, true, true )
			draw.RoundedBoxEx( 16, border, border, w - ( border * 2 ), h - ( border * 2 ), bgcolor, true, true, true, true )
			
		end
		
	end
	self.ScoreboardPanel:MakePopup()
	self.ScoreboardPanel:SetKeyboardInputEnabled( false )
	
	if teams == true then
		
		local friendx = border * 2
		local enemyx = ( ScrW() * 0.35 ) + border
		local teamy = border * 2
		
		local red = vgui.Create( "DScrollPanel" )
		red:SetParent( self.ScoreboardPanel )
		red:SetPos( friendx, teamy )
		red:SetSize( ( ScrW() * 0.35 ) - ( border * 5 ), ( ScrH() * 0.7 ) - ( border * 6 ) )
		red.Paint = function() end
		
		local redplys = team.GetPlayers( TEAM_RED )
		for i = 1, #redplys do
			
			self:ScoreboardPlayer( redplys[ i ], red )
			
		end
		
		local blue = vgui.Create( "DScrollPanel" )
		blue:SetParent( self.ScoreboardPanel )
		blue:SetPos( friendx, teamy )
		blue:SetSize( ( ScrW() * 0.35 ) - ( border * 5 ), ( ScrH() * 0.7 ) - ( border * 6 ) )
		blue.Paint = function() end
		
		local blueplys = team.GetPlayers( TEAM_BLUE )
		for i = 1, #blueplys do
			
			self:ScoreboardPlayer( blueplys[ i ], blue )
			
		end
		
		if plyteam == TEAM_BLUE then
			
			red:SetPos( enemyx, teamy )
			
		else
			
			blue:SetPos( enemyx, teamy )
			
		end
		
	else
		
		local ffa = vgui.Create( "DScrollPanel" )
		ffa:SetParent( self.ScoreboardPanel )
		ffa:SetPos( border * 2, border * 2 )
		ffa:SetSize( ( ScrW() * 0.35 ) - ( border * 5 ), ( ScrH() * 0.7 ) - ( border * 6 ) )
		ffa.Paint = function() end
		
		local ffaplys = team.GetPlayers( TEAM_FFA )
		for i = 1, #ffaplys do
			
			self:ScoreboardPlayer( ffaplys[ i ], ffa )
			
		end
		
	end
	
end

function GM:ScoreboardHide()
	
	if IsValid( self.ScoreboardPanel ) == true then
		
		self.ScoreboardPanel:Remove()
		self.ScoreboardPanel = nil
		
	end
	
end



GM.DeathNotices = {}

function GM:AddDeathNotice( attacker, ateam, inflictor, victim, vteam )
	
	table.insert( self.DeathNotices, {
		
		time = CurTime(),
		attacker = attacker,
		ateam = ateam,
		inflictor = inflictor,
		victim = victim,
		vteam = vteam,
		
	} )
	
end

function GM:DrawDeathNotice( xr, yr )
	
	local ply = LocalPlayer()
	
	local border = math.Round( ScrH() * 0.005 )
	local bgcolor = Color( 0, 0, 0, 150 )
	local bordercolor = ply:GetTeamColor()
	local altcolor = Color( 255, 255, 255, 255 )
	
	local cx = ScrW() * 0.975
	local y = ScrH() * 0.025
	
	surface.SetFont( "DM_BoldTiny" )
	
	for i = 1, #self.DeathNotices do
		
		local notice = self.DeathNotices[ i ]
		
		if notice != nil then
			
			if CurTime() > notice.time + 5 then
				
				table.remove( self.DeathNotices, i )
				
			elseif notice.attacker != nil then
				
				local aw, ah = surface.GetTextSize( notice.attacker )
				local kw, kh = killicon.GetSize( notice.inflictor )
				local vw, vh = surface.GetTextSize( notice.victim )
				
				local w = aw + kw + vw + ( border * 4 )
				local h = math.max( ah, kh, vh ) + ( border * 2 )
				
				local x = cx - w
				
				draw.RoundedBoxEx( 16, x - border, y - border, w + ( border * 2 ), h + ( border * 2 ), bordercolor, true, true, true, true )
				draw.RoundedBoxEx( 16, x, y, w, h, bgcolor, true, true, true, true )
				
				DrawShadowText( notice.attacker, x + border, y + ( h * 0.5 ) - ( ah * 0.5 ), team.GetColor( notice.ateam ) )
				killicon.Draw( x + aw + ( kw * 0.5 ) + ( border * 2 ), y + ( h * 0.5 ), notice.inflictor, 255 )
				surface.SetFont( "DM_BoldTiny" )
				DrawShadowText( notice.victim, x + aw + kw + ( border * 3 ), y + ( h * 0.5 ) - ( vh * 0.5 ), team.GetColor( notice.vteam ) )
				
				y = y + h + border
				
			else
				
				local kw, kh = killicon.GetSize( notice.inflictor )
				local vw, vh = surface.GetTextSize( notice.victim )
				
				local w = kw + vw + ( border * 3 )
				local h = math.max( kh, vh ) + ( border * 2 )
				
				local x = cx - w
				
				draw.RoundedBoxEx( 16, x - border, y - border, w + ( border * 2 ), h + ( border * 2 ), bordercolor, true, true, true, true )
				draw.RoundedBoxEx( 16, x, y, w, h, bgcolor, true, true, true, true )
				
				killicon.Draw( x + ( kw * 0.5 ) + ( border * 1 ), y + ( h * 0.5 ), notice.inflictor, 255 )
				surface.SetFont( "DM_BoldTiny" )
				DrawShadowText( notice.victim, x + kw + ( border * 2 ), y + ( h * 0.5 ) - ( vh * 0.5 ), team.GetColor( notice.vteam ) )
				
				y = y + h + ( border * 3 )
				
			end
			
		end
		
	end
	
end