local PLAYER = {}

PLAYER.DisplayName = "Deathmatch Class"
PLAYER.WalkSpeed = 200
PLAYER.RunSpeed = 300
PLAYER.TeammateNoCollide = false

player_manager.RegisterClass( "player_dm", PLAYER, "player_default" )