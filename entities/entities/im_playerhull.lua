--aaaaaAA this is bad

AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

function ENT:SetPhysics( min, max )
	
	if SERVER then
		
		local owner = self:GetOwner()
		if IsValid( owner ) == true and owner:IsPlayer() == true and owner:Alive() == true then
			
			newmin, newmax = owner:GetCollisionBounds()
			min = min or newmin
			max = max or newmax
			self:PhysicsInitBox( min, max )
			
		end
		
		self:PhysicsInit( SOLID_VPHYSICS )
		--self:PhysicsInit( SOLID_BBOX )
		
	end
	
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetSolid( SOLID_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) == true then
		
		phys:SetMaterial( "default_silent" )
		
	end
	
	self:StartMotionController()
	self:PhysWake()
	self:EnableCustomCollisions( true )
	
end

function ENT:Initialize()
	
	self:DrawShadow( false )
	
	self:SetPhysics()
	
end

function ENT:Think()
	
	if CLIENT then return end
	
	local owner = self:GetOwner()
	if IsValid( owner ) == true and owner:IsPlayer() == true and owner:Alive() == true then
		
		self:SetAngles( Angle( 0, 0, 0 ) )
		
		local min, max = owner:GetCollisionBounds()
		min = min - Vector( 1, 1, 1 )
		max = max + Vector( 1, 1, 1 )
		
		if self.LastMin == nil then self.LastMin = min end
		if self.LastMax == nil then self.LastMax = max end
		
		if self.LastMin != min or self.LastMax != max then
			
			self:SetPhysics( min, max )
			
		end
		
		self.LastMin = min
		self.LastMax = max
		
	else
		
		self:Remove()
		
	end
	
end

function ENT:TestCollision( startpos, delta, isbox, extents )
end

if CLIENT then
	
	function ENT:Draw()
	end
	
elseif SERVER then
	
	function ENT:GetLastAttacker()
		
		if self.LastAttack == nil then self.LastAttack = 0 end
		
		if CurTime() < self.LastAttack and IsValid( self.LastAttacker ) == true then return self.LastAttacker end
		
	end
	
	function ENT:SetLastAttacker( attacker, time )
		
		if time == nil then time = 5 end
		
		self.LastAttack = CurTime() + time
		self.LastAttacker = attacker
		
	end
	
	function ENT:GetLastInflictor()
		
		if self.LastInflict == nil then self.LastInflict = 0 end
		
		if CurTime() < self.LastInflict and IsValid( self.LastInflictor ) == true then return self.LastInflictor end
		
	end
	
	function ENT:SetLastInflictor( inflictor, time )
		
		if time == nil then time = 5 end
		
		self.LastInflict = CurTime() + time
		self.LastInflictor = inflictor
		
	end
	
	function ENT:PhysicsSimulate( phys, delta )
		
		local owner = self:GetOwner()
		if IsValid( owner ) != true then return end
		
		phys:Wake()
		
		local tpdist = 1000
		if util.TraceLine( { start = self:GetPos(), endpos = owner:GetPos(), filter = { self, owner } } ).Hit == true then tpdist = 1 end
		
		phys:ComputeShadowControl( {
			
			pos = owner:GetPos(),
			angle = Angle( 0, 0, 0 ),
			deltatime = delta,
			
			secondstoarrive = 0.01,
			maxangular = 5000,
			maxangulardamp = 10000,
			maxspeed = 1000000,
			maxspeedamp = 10000,
			dampfactor = 0.8,
			teleportdistance = tpdist,
			
		} )
		
	end
	
	function ENT:PhysicsCollide( data, ent )
		
		local gm = GAMEMODE or GM
		if gm != nil then gm:OnPlayerCollide( self:GetOwner(), self, ent, data ) end
		
	end
	
end