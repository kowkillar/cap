/*
	ZPM MK III Spawn Tool for GarrysMod10
	Copyright (C) 2010 Llapp
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Energy";
TOOL.Name=SGLanguage.GetMessage("stool_naq_bottle");

TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["model"] = "models/sandeno/naquadah_bottle.mdl";
TOOL.Entity.Class = "naquadah_bottle";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = StarGate.CFG:Get("naquadah_bottle","limit",5);
TOOL.Topic["name"] = "Naquadah bottle Spawner";
TOOL.Topic["desc"] = "Creates a Naquadah bottle";
TOOL.Topic[0] = "Left click, to spawn a Naquadah bottle";
TOOL.Language["Undone"] = "Naquadah bottle removed";
TOOL.Language["Cleanup"] = "Naquadah bottles";
TOOL.Language["Cleaned"] = "Removed all Naquadah bottles";
TOOL.Language["SBoxLimit"] = "Hit the Naquadah bottle limit";

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model);
	local weld = util.tobool(self:GetClientNumber("autoweld"));
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity);
	end
	local c = self:Weld(e,t.Entity,weld);
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"naq_bottle_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"naq_bottle_autolink"):SetToolTip("Autolink this to resource using Entities?");
	end
	Panel:AddControl("Label", {Text = "\nThis is the Naquadah bottle, this tool is in use for LifeSupport and Resource Distribution. If you don't got LS/RD this Naquadah bottle is quite useless for you.",})
end

TOOL:Register();