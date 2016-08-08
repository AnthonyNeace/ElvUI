local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")
local max = math.max

function mod:UpdateElement_HealthColor(frame)
	if(not frame.HealthBar:IsShown()) then return end

	local r, g, b;
	local scale = 1
	if ( not UnitIsConnected(frame.unit) ) then
		r, g, b = self.db.reactions.offline.r, self.db.reactions.offline.g, self.db.reactions.offline.b
	else
		if ( frame.HealthBar.ColorOverride ) then
			--[[local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
			r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;]]
		else
			--Try to color it by class.
			local _, class = UnitClass(frame.displayedUnit);
			local classColor = RAID_CLASS_COLORS[class];
			if ( (frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "HEALER" or frame.UnitType == "ENEMY_PLAYER" or frame.UnitType == "PLAYER") and classColor and not frame.inVehicle ) then
				-- Use class colors for players if class color option is turned on
				r, g, b = classColor.r, classColor.g, classColor.b;
			elseif ( not UnitPlayerControlled(frame.unit) and UnitIsTapDenied(frame.unit) ) then
				-- Use grey if not a player and can"t get tap on unit
				r, g, b = self.db.reactions.tapped.r, self.db.reactions.tapped.g, self.db.reactions.tapped.b	
			else
				-- Use color based on the type of unit (neutral, etc.)
				local isTanking, status = UnitDetailedThreatSituation("player", frame.unit)
				if status then
					if(status == 3) then --Securely Tanking
						if(E:GetPlayerRole() == "TANK") then
							r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
							scale = self.db.threat.goodScale
						else
							r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
							scale = self.db.threat.badScale
						end
					elseif(status == 2) then --insecurely tanking
						if(E:GetPlayerRole() == "TANK") then
							r, g, b = self.db.threat.badTransition.r, self.db.threat.badTransition.g, self.db.threat.badTransition.b
						else
							r, g, b = self.db.threat.goodTransition.r, self.db.threat.goodTransition.g, self.db.threat.goodTransition.b
						end			
						scale = 1			
					elseif(status == 1) then --not tanking but threat higher than tank
						if(E:GetPlayerRole() == "TANK") then
							r, g, b = self.db.threat.goodTransition.r, self.db.threat.goodTransition.g, self.db.threat.goodTransition.b
						else
							r, g, b = self.db.threat.badTransition.r, self.db.threat.badTransition.g, self.db.threat.badTransition.b
						end			
						scale = 1		
					else -- not tanking at all
						if(E:GetPlayerRole() == "TANK") then
							--Check if it is being tanked by an offtank.
							if (IsInRaid() or IsInGroup()) and frame.isBeingTanked and self.db.threat.beingTankedByTank then
								r, g, b = self.db.threat.beingTankedByTankColor.r, self.db.threat.beingTankedByTankColor.g, self.db.threat.beingTankedByTankColor.b
								scale = self.db.threat.goodScale
							else
								r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
								scale = self.db.threat.badScale
							end
						else
							if (IsInRaid() or IsInGroup()) and frame.isBeingTanked and self.db.threat.beingTankedByTank then
								r, g, b = self.db.threat.beingTankedByTankColor.r, self.db.threat.beingTankedByTankColor.g, self.db.threat.beingTankedByTankColor.b
								scale = self.db.threat.goodScale
							else
								r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
								scale = self.db.threat.goodScale
							end	
						end
					end
				else
					--By Reaction
					local reactionType = UnitReaction(frame.unit, "player")
					if(reactionType == 4) then
						r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
					elseif(reactionType > 4) then
						r, g, b = self.db.reactions.good.r, self.db.reactions.good.g, self.db.reactions.good.b
					else
						r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
					end
				end
			end
		end
	end

	if ( r ~= frame.HealthBar.r or g ~= frame.HealthBar.g or b ~= frame.HealthBar.b ) then
		frame.HealthBar:SetStatusBarColor(r, g, b);
		frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b = r, g, b;
	end
	
	if(not frame.isTarget or not self.db.useTargetScale) then
		frame.ThreatScale = scale
		self:SetFrameScale(frame, scale)
	end
end

function mod:UpdateElement_MaxHealth(frame)
	local maxHealth = UnitHealthMax(frame.displayedUnit);
	frame.HealthBar:SetMinMaxValues(0, maxHealth)
end

function mod:UpdateElement_Health(frame)
	local health = UnitHealth(frame.displayedUnit);
	frame.HealthBar:SetValue(health)
end

function mod:ConfigureElement_HealthBar(frame, configuring)
	local healthBar = frame.healthBar;
	
	healthBar:SetPoint("BOTTOM", frame, "BOTTOM", 0, self.db.castBar.height + 3);
	if(UnitIsUnit(self.unit, "target") and not frame.isTarget) then
		healthBar:SetHeight(self.db.healthBar.height * self.db.targetScale);
		healthBar:SetWidth(self.db.healthBar.width * self.db.targetScale);
	else
		healthBar:SetHeight(self.db.healthBar.height);
		healthBar:SetWidth(self.db.healthBar.width);
	end

	healthBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar));
	if(self.db.healthBar.enable) then
		healthBar:Show()
		mod:ConfigureElement_Level(frame);
		mod:ConfigureElement_Name(frame);
	else
		healthBar:Hide()
		mod:ConfigureElement_Name(frame);
		mod:ConfigureElement_Level(frame);
	end
end

function mod:ConstructElement_HealthBar(parent)
	local frame = CreateFrame("StatusBar", nil, parent);
	self:CreateBackdrop(frame);

	frame.text = frame:CreateFontString(nil, "OVERLAY");
	frame.text:SetWordWrap(false);
	frame.scale = CreateAnimationGroup(frame);
	
	frame.scale.width = frame.scale:CreateAnimation("Width");
	frame.scale.width:SetDuration(0.2);
	frame.scale.height = frame.scale:CreateAnimation("Height");
	frame.scale.height:SetDuration(0.2);
	frame:Hide();
	return frame;
end