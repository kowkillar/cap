if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_adrenaline");
	SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end

list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

if (SERVER) then
	AddCSLuaFile("shared.lua");
end

if CLIENT then
	if(file.Exists("materials/VGUI/weapons/sg_adrenaline.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/sg_adrenaline.vmt")
	end
end

SWEP.Author 		= "Gmod4phun, AlexALX"
SWEP.Purpose		= "Heal yourself during a battle."
SWEP.Instructions	= "Left click to heal yourself."

SWEP.AdminSpawnable = false
SWEP.Spawnable 		= false

SWEP.ViewModelFOV 	= 64
SWEP.ViewModel 		= "models/pg_props/pg_weapons/pg_shot_v.mdl"
SWEP.WorldModel 	= "models/pg_props/pg_stargate/pg_shot.mdl"

SWEP.AutoSwitchTo 	= false
SWEP.AutoSwitchFrom = true

SWEP.Slot 			= 1
SWEP.SlotPos = 1

SWEP.HoldType = "normal"

SWEP.FiresUnderwater = true

SWEP.Weight = 5

SWEP.DrawCrosshair = false

SWEP.DrawAmmo = true

SWEP.ReloadSound = ""

SWEP.base = "weapon_base"

SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = ""
SWEP.Primary.DefaultClip = -1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 3
SWEP.Primary.Cone = 0

SWEP.Secondary.NumberofShots = 0
SWEP.Secondary.Force = 0
SWEP.Secondary.Spread = 0
SWEP.Secondary.Sound = ""
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Delay = 2
SWEP.Secondary.TakeAmmo = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Damage = 0
SWEP.DrawWorldModel = true

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end


function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire(CurTime()+0.4)
	self:SetNextSecondaryFire(CurTime()+0.4)

	timer.Simple(0.32, function()
		if (IsValid(self)) then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)

	return true
end


function SWEP:PrimaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextPrimaryFire(CurTime()+3.4)

	if (SERVER) then
		timer.Simple(3, function()
			if (IsValid(self) and IsValid(self.Owner)) then
				self.Owner:StripWeapon(self:GetClass());
			end
		end)
	end

	timer.Simple(3.32, function()
		if (IsValid(self)) then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)

	if (SERVER) then
		timer.Simple(1.6, function()
			if (IsValid(self) and IsValid(self.Owner)) then
				if (self.Owner:Health()<120) then
					self.Owner:SetHealth(120)
				else
					if (self.Owner:Health()<165) then
						self.Owner:SetHealth(165)
					else
						if (self.Owner:Health()<200) then
							self.Owner:SetHealth(200)
							local ply = self.Owner;
							timer.Create("SGAdrenaline.Kill"..ply:EntIndex(),15.0,1,function()
								if (IsValid(ply) and ply:Health()>=180) then
									ply:Kill();
								end
							end);
						else
							self.Owner:Kill();
						end
					end
					if (self.Owner:Alive()) then
						self.Owner:SetNetworkedBool("SGAdrenaline_Heal", true);
					end
				end
			end
		end)
	end

	timer.Simple(0.6, function()
		if (IsValid(self)) then
			self:EmitSound("weapons/p90/p90_clipout.wav", 40, 170)
		end
	end)

	timer.Simple(1.5, function()
		if (IsValid(self)) then
			self:EmitSound("weapons/slam/mine_mode.wav", 100, 100)
		end
	end)

end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

if (SERVER) then

	util.AddNetworkString("SGAdrenaline.Reset");

	-- don't know why, but if set this on clien it wont send to server, so this is workaround.
	net.Receive("SGAdrenaline.Reset",function(len,ply)
		if (IsValid(ply)) then
			ply:SetNetworkedBool("SGAdrenaline_Heal", false)
		end
	end)

	local function playerDies( victim, weapon, killer )
		if (victim:GetNetworkedBool("SGAdrenaline_Heal", false)) then
			victim:SetNetworkedBool("SGAdrenaline_Heal", false);
		end
	end
	hook.Add( "PlayerDeath", "StarGate.Adrenaline", playerDies )
end


if (CLIENT) then
	local function BlindPlayer()
		if (not IsValid(LocalPlayer())) then return end
		local health = LocalPlayer():Health();
		local used = LocalPlayer():GetNWBool("SGAdrenaline_Heal", false);
		if (health > 150 and used) then
			if (health>200) then health = 200 end
			DrawMotionBlur( 0.2, (-150+health)/50, 0.05)

			local tab = {}
			tab[ "$pp_colour_addr" ] = 0
			tab[ "$pp_colour_addg" ] = 0
			tab[ "$pp_colour_addb" ] = 0
			tab[ "$pp_colour_brightness" ] = (-150+health)/150
			tab[ "$pp_colour_contrast" ] = (-150+health)/150+1
			tab[ "$pp_colour_colour" ] = 1
			tab[ "$pp_colour_mulr" ] = 1
			tab[ "$pp_colour_mulg" ] = 1
			tab[ "$pp_colour_mulb" ] = 1

			DrawColorModify( tab )

		elseif (used) then
			net.Start("SGAdrenaline.Reset")
			net.WriteBit(true)
			net.SendToServer()
		end
	end
	hook.Add( "RenderScreenspaceEffects", "SGAdrenaline.BlindPlayer", BlindPlayer )
end