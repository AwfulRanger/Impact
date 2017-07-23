GM.MapData = {}

local files = {
	
	"mapdata/cs_assault.lua",
	"mapdata/cs_compound.lua",
	"mapdata/cs_havana.lua",
	"mapdata/cs_italy.lua",
	"mapdata/cs_militia.lua",
	"mapdata/cs_office.lua",
	"mapdata/de_aztec.lua",
	"mapdata/de_cbble.lua",
	"mapdata/de_chateau.lua",
	"mapdata/de_dust.lua",
	"mapdata/de_dust2.lua",
	"mapdata/de_inferno.lua",
	"mapdata/de_nuke.lua",
	
}
for i = 1, #files do
	
	AddCSLuaFile( files[ i ] )
	include( files[ i ] )
	
end

function GM:AddMapSpawns( map, spawns )
	
	if map == nil then return end
	
	if self.MapSpawns[ map ] == nil then self.MapSpawns[ map ] = {} end
	self.MapSpawns[ map ].Spawns = spawns
	
end

function GM:RemoveMapSpawns( map )
	
	if map == nil then return end
	
	if self.MapSpawns[ map ] == nil then return end
	self.MapSpawns[ map ].Spawns = nil
	
end

function GM:GetMapSpawns( map )
	
	if map == nil then return end
	
	if self.MapSpawns[ map ] == nil then return end
	return self.MapSpawns[ map ].Spawns
	
end



--search for map data files
GM.MapDataPath = "impact/mapdata/"
function GM:CreateMapData()
	
	local files = file.Find( self.MapDataPath .. "*", "DATA" )
	
	for i = 1, #files do
		
		local data = util.JSONToTable( file.Read( self.MapDataPath .. files[ i ], "DATA" ) )
		if data != nil then self.MapData[ files[ i ] ] = data end
		
	end
	
end



function GM:ApplyMapData()
	
	local data = self.MapData[ game.GetMap() ]
	if data == nil then return end
	
	local entities = data.Entities
	if entities != nil then
		
		for i = 1, #entities do
			
			local entdata = entities[ i ]
			local class = entdata.Class
			local ent = ents.Create( class )
			if IsValid( ent ) == true then
				
				local functions = entdata.Functions
				if functions != nil then
					
					for _, v in pairs( functions ) do
						
						ent[ _ ]( ent, unpack( v ) )
						
					end
					
				end
				ent:Spawn()
					
			end
			
		end
		
	end
	
end