AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

function ENT:SetupDataTables()
	
	self:NetworkVar( "String", 0, "Item" )
	self:NetworkVar( "Bool", 0, "IsWeapon" )
	self:NetworkVar( "Bool", 1, "PickedUp" )
	self:NetworkVar( "Bool", 2, "TracePos" )
	self:NetworkVar( "Float", 0, "NextPickup" )
	
	self:SetItem( "" )
	self:SetIsWeapon( false )
	self:SetPickedUp( false )
	self:SetTracePos( true )
	self:SetNextPickup( 0 )
	
end

ENT.AutoModels = {
	
	[ "" ] = true,
	[ "models/error.mdl" ] = true,
	
}

function ENT:Initialize()
	
	self:DrawShadow( false )
	
	if SERVER then
		
		local model = self:GetModel()
		if self.AutoModels[ model ] == true then
			
			local item = self:GetItem()
			local ent = ents.Create( item )
			if IsValid( ent ) == true then
				
				ent:SetPos( self:GetPos() )
				ent:Spawn()
				self:SetModel( ent:GetModel() )
				self:SetIsWeapon( ent:IsWeapon() )
				ent:Remove()
				
			end
			
		end
		
		--self:PhysicsInit( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		--self:SetSolid( SOLID_VPHYSICS )
		self:SetSolid( SOLID_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		
		self:SetTrigger( true )
		self:UseTriggerBounds( true, 24 )
		
		if self:GetTracePos() == true then
			
			local up = self:GetAngles():Up() * 32
			
			local tr = util.TraceLine( {
				
				start = self:GetPos(),
				endpos = self:GetPos() - up,
				filter = self,
				
			} )
			
			local pos = self:GetPos()
			if tr.StartSolid != true then pos = tr.HitPos end
			
			self:SetPos( pos + up )
			
		end
		
	else
		
		self.DrawModelAng = Angle( 0, 0, 0 )
		
	end
	
end

ENT.NextPickup = 0

function ENT:IsActive()
	
	return CurTime() >= self:GetNextPickup()
	
end

function ENT:GetRespawnTime()
	
	local nextpickup = 10
	local gm = GAMEMODE or gm
	if gm != nil then nextpickup = gm:GetItemRespawnTime() end
	
	return nextpickup
	
end

if CLIENT then
	
	function ENT:Draw()
		
		if self:GetModel() != nil and self:GetModel() != "" then
			
			if IsValid( self.ClientModel ) != true then self.ClientModel = ClientsideModel( self:GetModel() ) end
			if self.ClientModel:GetModel() != self:GetModel() then self.ClientModel:SetModel( self:GetModel() ) end
			
		end
		
	end
	
	ENT.RotSpeed = 45
	
	function ENT:Think()
		
		if IsValid( self.ClientModel ) != true then return end
		
		if self.DrawModelAng == nil then self.DrawModelAng = Angle( 0, 0, 0 ) end
		
		self.ClientModel:SetPos( self:GetPos() + ( ( self.DrawModelAng:Up() * math.sin( CurTime() ) ) * 2 ) )
		
		if self.LastRot == nil then self.LastRot = CurTime() end
		
		self.DrawModelAng:RotateAroundAxis( self.DrawModelAng:Up(), self.RotSpeed * ( CurTime() - self.LastRot ) )
		
		self.ClientModel:SetAngles( self.DrawModelAng )
		
		self.LastRot = CurTime()
		
		self.ClientModel:SetNoDraw( self:IsActive() != true and self:GetPickedUp() != true )
		
	end
	
	function ENT:OnRemove()
		
		if IsValid( self.ClientModel ) == true then self.ClientModel:Remove() end
		
	end
	
elseif SERVER then
	
	function ENT:KeyValue( key, value )
		
		if key == "model" then
			
			self:SetModel( value )
			
		elseif key == "item" then
			
			self:SetItem( value )
			
		end
		
	end
	
	function ENT:Touch( ent )
		
		if self:IsActive() != true or IsValid( ent ) != true or ent:IsPlayer() != true then return end
		
		local valid = true
		local item
		
		if self:GetItem() != nil and self:GetItem() != "" then
			
			item = ent:Give( self:GetItem() )
			if IsValid( item ) == true then item:SetNoDraw( true ) end
			if self:GetIsWeapon() == true then
				
				if hook.Run( "PlayerCanPickupWeapon", ent, item ) != true then
					
					valid = false
					
				elseif IsValid( item ) != true then
					
					--give ammo if player already has weapon
					local wep = ent:GetWeapon( self:GetItem() )
					if IsValid( wep ) == true then
						
						local clip1 = wep:GetMaxClip1()
						local clip2 = wep:GetMaxClip2()
						local ammo1 = wep:GetPrimaryAmmoType()
						local ammo2 = wep:GetSecondaryAmmoType()
						
						if clip1 < 0 then clip1 = 1 end
						if clip2 < 0 then clip2 = 1 end
						
						if clip1 > 0 and ammo1 > 0 then
							
							ent:GiveAmmo( clip1, ammo1 )
							
						end
						if clip2 > 0 and ammo2 > 0 then
							
							ent:GiveAmmo( clip2, ammo2 )
							
						end
						
					end
					
				end
				
			elseif hook.Run( "PlayerCanPickupItem", ent, item ) != true then
				
				valid = false
				
			end
			
		end
		
		local pickup = self:GetNextPickup()
		
		self:SetNextPickup( CurTime() + self:GetRespawnTime() )
		
		--if the player can't pickup the item remove it and reset the pickup time
		if valid != true then
			
			if IsValid( item ) == true then item:Remove() end
			self:SetNextPickup( pickup )
			
		end
		
		self:SetPickedUp( true )
		
		timer.Simple( 0, function()
			
			if IsValid( item ) == true and IsValid( item:GetOwner() ) != true then
				
				item:Remove()
				valid = false
				
			end
			
			if IsValid( self ) != true then return end
			
			self:SetPickedUp( false )
			
			if valid != true then
				
				self:SetNextPickup( pickup )
				
			elseif IsValid( item ) == true then
				
				item:SetNoDraw( false )
				
			end
			
		end )
		
	end
	
end