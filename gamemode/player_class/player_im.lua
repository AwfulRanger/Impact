local PLAYER = {}

PLAYER.DisplayName = "Impact Class"
PLAYER.WalkSpeed = 200
PLAYER.RunSpeed = 300
PLAYER.TeammateNoCollide = false

player_manager.RegisterClass( "player_im", PLAYER, "player_default" )