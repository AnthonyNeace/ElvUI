local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

function mod:UpdateElement_Name(frame)
	local name, realm = UnitName(frame.displayedUnit)
	if(not self.db.units[frame.UnitType].showName or not name) then return end
	
	frame.Name:SetText(name)
	
	if(frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "ENEMY_PLAYER") then
		local _, class = UnitClass(frame.displayedUnit)
		local color = RAID_CLASS_COLORS[class]
		if(class and color) then
			frame.Name:SetTextColor(color.r, color.g, color.b)
		end
	elseif(not self.db.units[frame.UnitType].healthbar.enable) then
		local reactionType = UnitReaction(frame.unit, "player")
		local r, g, b
		if(reactionType == 4) then
			r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
		elseif(reactionType > 4) then
			r, g, b = self.db.reactions.good.r, self.db.reactions.good.g, self.db.reactions.good.b
		else
			r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
		end	
		
		frame.Name:SetTextColor(r, g, b)
	else
		frame.Name:SetTextColor(1, 1, 1)
	end
end

function mod:ConfigureElement_Name(frame)
	local name = frame.name;

	name:SetJustifyH("LEFT");
	name:ClearAllPoints();
	if(self.db.healthBar.enable or frame.isTarget) then
		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", frame.healthBar, "TOPLEFT", 0, E.Border*2);
		name:SetPoint("BOTTOMRIGHT", frame.level, "BOTTOMLEFT");
	else
		name:SetJustifyH("CENTER");
		name:SetPoint("TOP", frame);
	end

	name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
end

function mod:ConstructElement_Name(frame)
	return frame:CreateFontString(nil, "OVERLAY");
end