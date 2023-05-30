---------------------------------------------------------------------------------------------------------------------
-- TippyGary Interface Panel
---------------------------------------------------------------------------------------------------------------------
local tgd = _G["TippyGaryData"];
local font = "Fonts\\FRIZQT__.TTF";


local function CreateCheckButton(reference, parent, label)
	local checkbutton = CreateFrame( "CheckButton", reference, parent, "InterfaceOptionsCheckButtonTemplate")
	checkbutton.Label = _G[reference.."Text"]
	checkbutton.Label:SetText(label)
	checkbutton.GetValue = function() if checkbutton:GetChecked() then return true else return false end end
	checkbutton.SetValue = checkbutton.SetChecked

	return checkbutton
end

local function CreatePanelFrame(reference, listname, title)
	local panelframe = CreateFrame( "Frame", reference, UIParent, "BackdropTemplate");
	panelframe.name = listname
	panelframe.Label = panelframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	panelframe.Label:SetPoint("TOPLEFT", panelframe, "TOPLEFT", 16, -16)
	panelframe.Label:SetHeight(15)
	panelframe.Label:SetWidth(350)
	panelframe.Label:SetJustifyH("LEFT")
	panelframe.Label:SetJustifyV("TOP")
	panelframe.Label:SetText(title)
	return panelframe
end

local function SetConqTooltip(enable)
	if enable then
		TippyGaryOptions.ConqTooltip = true;
	else
		TippyGaryOptions.ConqTooltip = false;
	end
end

local function SetConqTooltipShowSession(enable)
	if enable then
		TippyGaryOptions.ConqTooltipShowSession = true;
		tgd:SessionStats_Enable();
	else
		TippyGaryOptions.ConqTooltipShowSession = false;
		tgd:SessionStats_Disable();
	end
end

local function SetEnlargeTargetMarkers(enable)
	if enable then
		TippyGaryOptions.EnlargeTargetMarkers = true;
	else
		TippyGaryOptions.EnlargeTargetMarkers = false;
	end
	tgd:UpdateNameplates();
end

local function SetCenterTargetMarkers(enable)
	if enable then
		TippyGaryOptions.CenterTargetMarkers = true;
	else
		TippyGaryOptions.CenterTargetMarkers = false;
	end
	tgd:UpdateNameplates();
end

local function BuildInterfacePanel(panel)
	panel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
	panel:SetBackdropColor(0, 0, 0, 0)

	--panel.Label:SetTextColor(255/255, 105/255, 6/255)

	-- Current Version
	panel.Version = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	panel.Version:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -16)
	panel.Version:SetHeight(15)
	panel.Version:SetWidth(350)
	panel.Version:SetJustifyH("RIGHT")
	panel.Version:SetJustifyV("TOP")
	panel.Version:SetText("Version " .. tgd.Version);
	
	-- Rated PvP Stats Label
	panel.RPTLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.RPTLabel:SetText("Rated PvP Stats")
	panel.RPTLabel:SetFont(font, 14)
	panel.RPTLabel:SetPoint("TOPLEFT", panel.Label, "TOPLEFT", 0, -35)
	
	-- Option: Show Win/Loss on Conquest Tooltip
	panel.ConqTooltip = CreateCheckButton("TippyGaryOptions_ConqTooltip", panel, "Show Win/Loss info on Rated PvP tooltip")
	panel.ConqTooltip:SetPoint("TOPLEFT", panel.RPTLabel, "BOTTOMLEFT", 10, -3)
	panel.ConqTooltip:SetScript("OnClick", function(self) SetConqTooltip(self:GetChecked()) end)
	panel.ConqTooltip:SetChecked(TippyGaryOptions.ConqTooltip);
	
	-- Option: Show session stats on Conquest Tooltip
	panel.ConqTooltipShowSession = CreateCheckButton("TippyGaryOptions_ConqTooltipShowSession", panel, "Show current session stats on Rated PvP tooltip")
	panel.ConqTooltipShowSession:SetPoint("TOPLEFT", panel.ConqTooltip, "BOTTOMLEFT", 0, 0);
	panel.ConqTooltipShowSession:SetScript("OnClick", function(self) SetConqTooltipShowSession(self:GetChecked()) end)
	panel.ConqTooltipShowSession:SetChecked(TippyGaryOptions.ConqTooltipShowSession);
	
	-- Target Markers Label
	panel.TargetMarkersLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.TargetMarkersLabel:SetText("Target Markers")
	panel.TargetMarkersLabel:SetFont(font, 14)
	panel.TargetMarkersLabel:SetPoint("TOPLEFT", panel.RPTLabel, "BOTTOMLEFT", 0, -70)
	
	-- Option: Enlarge Target Markers
	panel.EnlargeTargetMarkers = CreateCheckButton("TippyGaryOptions_EnlargeTargetMarkers", panel, "XL markers")
	panel.EnlargeTargetMarkers.tooltipText = "Oh my Tim these markers are huge!";
	panel.EnlargeTargetMarkers:SetPoint("TOPLEFT", panel.TargetMarkersLabel, "BOTTOMLEFT", 10, -5)
	panel.EnlargeTargetMarkers:SetScript("OnClick", function(self) SetEnlargeTargetMarkers(self:GetChecked()) end)
	panel.EnlargeTargetMarkers:SetChecked(TippyGaryOptions.EnlargeTargetMarkers);
	
	-- Option: Center Target Markers
	panel.CenterTargetMarkers = CreateCheckButton("TippyGaryOptions_CenterTargetMarkers", panel, "Center markers above nameplate")
	panel.CenterTargetMarkers:SetPoint("TOPLEFT", panel.EnlargeTargetMarkers, "BOTTOMLEFT", 0, 0)
	panel.CenterTargetMarkers:SetScript("OnClick", function(self) SetCenterTargetMarkers(self:GetChecked()) end)
	panel.CenterTargetMarkers:SetChecked(TippyGaryOptions.CenterTargetMarkers);
	
	
end



local TippyGaryInterfacePanel = CreatePanelFrame("TippyGaryInterfacePanel", "Tippy Gary", "Tippy Gary");
InterfaceOptions_AddCategory(TippyGaryInterfacePanel);
TippyGaryData.InterfacePanel = TippyGaryInterfacePanel;
TippyGaryData.OpenInterfacePanel = function(self, panel)
	local panelName = panel.name
	if not panelName then return end

	local t = {}
	
	InterfaceOptionsFrame_OpenToCategory(panel)
end;

local function tgipOnEvent()
	-- Setup the interface panel
	BuildInterfacePanel(TippyGaryInterfacePanel);
end

TippyGaryInterfacePanel:RegisterEvent("PLAYER_LOGIN");
TippyGaryInterfacePanel:SetScript("OnEvent", tgipOnEvent);