---------------------------------------------------------------------------------------------------------------------
-- TippyGary Arena History Browser
---------------------------------------------------------------------------------------------------------------------
local tgb = CreateFrame("Frame","TippyGaryBrowser",UIParent,BackdropTemplateMixin and "BackdropTemplate");
tinsert(UISpecialFrames, tgb:GetName());

-- Constants
local NUM_ITEMS = 10;
local ITEM_HEIGHT = 50;
local COL2_X = 90;
local COL3_X = COL2_X + 70;
local COL4_X = COL3_X + 115;
local COL5_X = COL4_X + 130;
local COL6_X = COL5_X + 90;

local function colorPlayerName(name, class)
	local classColor;
	if(class == "Death Knight") then
		classColor = "|cffc41e3a";
	elseif(class == "Demon Hunter") then
		classColor = "|cffa330c9";
	elseif(class == "Druid") then
		classColor = "|cffff7c0a";
	elseif(class == "Hunter") then
		classColor = "|cffaad372";
	elseif(class == "Mage") then
		classColor = "|cff3fc7eb";
	elseif(class == "Monk") then
		classColor = "|cff00ff98";
	elseif(class == "Paladin") then
		classColor = "|cfff48cba";
	elseif(class == "Priest") then
		classColor = "|cffffffff";
	elseif(class == "Rogue") then
		classColor = "|cfffff468";
	elseif(class == "Shaman") then
		classColor = "|cff0070dd";
	elseif(class == "Warlock") then
		classColor = "|cff8788ee";
	elseif(class == "Warrior") then
		classColor = "|cffc69b6d";
	end
	return classColor .. name .. "|r";
end

local function initGameListHeader(header)
	-- Column: When			{1}
	local colWhen = header:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
	colWhen:SetText("When");
	colWhen:SetFont(colWhen:GetFont(), 14);
	colWhen:SetPoint("TOPLEFT", 0, 0);
	
	-- Column: Type			{2}
	local colType = header:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
	colType:SetText("Type");
	colType:SetFont(colType:GetFont(), 14);
	colType:SetPoint("TOPLEFT", COL2_X, 0);
	
	-- Column: Team			{3}
	local colTeam = header:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
	colTeam:SetText("Team");
	colTeam:SetFont(colTeam:GetFont(), 14);
	colTeam:SetPoint("TOPLEFT", COL3_X, 0);
	
	-- Column: Opponents	{4}
	local colOpponents = header:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
	colOpponents:SetText("Opponents");
	colOpponents:SetFont(colOpponents:GetFont(), 14);
	colOpponents:SetPoint("TOPLEFT", COL4_X, 0);
	
	-- Column: Result		{5}
	local colResult = header:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
	colResult:SetText("Result");
	colResult:SetFont(colResult:GetFont(), 14);
	colResult:SetPoint("TOPLEFT", COL5_X, 0);
	
	-- Column: Rating		{6}
	local colRating = header:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
	colRating:SetText("Rating");
	colRating:SetFont(colRating:GetFont(), 14);
	colRating:SetPoint("TOPLEFT", COL6_X, 0);
end

local function initBrowserPanel()
	-- Initialize browser window
	tgb:SetSize(620, 568);
	tgb:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 } });
	tgb:SetBackdropColor(0.1,0.22,0.35,1);
	tgb:SetBackdropBorderColor(0.1,0.1,0.1,1);
	tgb:EnableMouse(true);
	tgb:SetMovable(true);
	tgb:SetToplevel(true);
	tgb:SetPoint("CENTER");
	tgb:Hide();
	
	-- Create header icon
	tgb.hicon = tgb:CreateTexture(nil,"ARTWORK");
	tgb.hicon:SetPoint("TOPLEFT", 14, -10);
	tgb.hicon:SetSize(25, 25);
	tgb.hicon:SetTexture(2124573);

	-- Create header text
	tgb.header = tgb:CreateFontString(nil,"ARTWORK","GameFontHighlight");
	tgb.header:SetFont(tgb.header:GetFont(),20,"THICKOUTLINE");
	tgb.header:SetPoint("TOPLEFT", tgb.hicon, "TOPRIGHT", 10, -4);
	tgb.header:SetText("Arena History");
	
	-- Create close button
	tgb.close = CreateFrame("Button",nil,tgb,"UIPanelCloseButton");
	tgb.close:SetPoint("TOPRIGHT",-5,-5);
	tgb.close:SetScript("OnClick",function() tgb:Hide(); end);
	
	-- Create game count text
	tgb.GameCountWrap = CreateFrame("Button", nil, tgb);
	tgb.GameCountWrap:SetPoint("TOPRIGHT", tgb.close, "TOPLEFT", -25, -11);
	tgb.GameCountWrap:SetSize(140, 15);
	tgb.GameCountWrap:SetScript("OnEnter", tgb.OnEnter_GameCount);
	tgb.GameCountWrap:SetScript("OnLeave", tgb.OnLeave_GameCount);
	tgb.GameCountWrap:SetScript("OnClick", tgb.OnClick_GameCount);
	tgb.GameCountText = tgb.GameCountWrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	tgb.GameCountText:SetPoint("TOPRIGHT", 0, 0);
	tgb.GameCountText:SetJustifyH("RIGHT");
	--tgb.GameCountText:SetFont(tgb.GameCountText:GetFont(), 14);
	tgb:UpdateGameCountText();
	
	-- Create game type filter dropdown
	tgb.FilterByType = false;
	tgb.DropDownArenaType = TippyGaryData.DropDown:CreateDropDown(tgb, -110, tgb.DropDown_FilterByType_Init, tgb.DropDown_FilterByType_SelectValue, false, false);
	tgb.DropDownArenaType:SetPoint("TOP", 0, -11);
	tgb.DropDownArenaType:SetText("All Games");
	
	
	-- Create game list wrapper
	tgb.outline = CreateFrame("Frame",nil,tgb,BackdropTemplateMixin and "BackdropTemplate");	-- 9.0.1: Using BackdropTemplate
	tgb.outline:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
	tgb.outline:SetBackdropColor(0.1,0.1,0.2,1);
	tgb.outline:SetBackdropBorderColor(0.8,0.8,0.9,0.4);
	tgb.outline:SetPoint("TOPLEFT",12,-38);
	tgb.outline:SetPoint("BOTTOMRIGHT",-12,42);

	-- Create game list item placeholders
	tgb.GameList = {};
	for i = 1,NUM_ITEMS do
		local glItem = CreateFrame("Button", nil, tgb.outline);
		glItem.GameListIndex = i;
		
		
		if (i == 1) then
			-- Create list header row
			initGameListHeader(glItem);
			glItem:SetSize(ITEM_HEIGHT,16);
			glItem:SetPoint("TOPLEFT",8,-8);
			glItem:SetPoint("TOPRIGHT",-8,-8);
		else
			-- Create regular game list row
			glItem:SetSize(ITEM_HEIGHT,ITEM_HEIGHT);
			glItem:SetPoint("TOPLEFT",tgb.GameList[i - 1],"BOTTOMLEFT",0,-1);
			glItem:SetPoint("TOPRIGHT",tgb.GameList[i - 1],"BOTTOMRIGHT",0,-1);
			glItem:RegisterForClicks("AnyUp");
			glItem:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD");
			
			
			-- Add When Column
			glItem.when1 = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.when1:SetPoint("LEFT", 0, 6);
			glItem.when1:SetJustifyH("LEFT");
			glItem.when1:SetTextColor(0.7,0.7,0.7);
			glItem.when2 = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.when2:SetPoint("TOPLEFT", glItem.when1, "BOTTOMLEFT", 0, -2);
			glItem.when2:SetJustifyH("LEFT");
			glItem.when2:SetTextColor(0.7,0.7,0.7);
			glItem.when2:SetText("8/27/22");
			glItem.when2:SetFont(glItem.when2:GetFont(), 10);
			
			-- Add Type Column
			glItem.type = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.type:SetPoint("LEFT", COL2_X, 0);
			glItem.type:SetJustifyH("LEFT");
			glItem.type:SetTextColor(0.7,0.7,0.7);
			glItem.type:SetFont(glItem.type:GetFont(), 16);
			
			-- Add Team Column
			glItem.team1 = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.team1:SetPoint("TOPLEFT", COL3_X+15, -4);
			glItem.team1:SetJustifyH("LEFT");
			glItem.teamicon1 = glItem:CreateTexture(nil,"ARTWORK");
			glItem.teamicon1:SetPoint("TOPLEFT", COL3_X, -4);
			glItem.teamicon1:SetSize(12, 12);
			glItem.team2 = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.team2:SetPoint("TOPLEFT", glItem.team1, "BOTTOMLEFT", 0, -2);
			glItem.team2:SetJustifyH("LEFT");
			glItem.teamicon2 = glItem:CreateTexture(nil,"ARTWORK");
			glItem.teamicon2:SetPoint("TOPLEFT", glItem.teamicon1, "BOTTOMLEFT", 0, -2);
			glItem.teamicon2:SetSize(12, 12);
			glItem.team3 = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.team3:SetPoint("TOPLEFT", glItem.team2, "BOTTOMLEFT", 0, -2);
			glItem.team3:SetJustifyH("LEFT");
			glItem.teamicon3 = glItem:CreateTexture(nil,"ARTWORK");
			glItem.teamicon3:SetPoint("TOPLEFT", glItem.teamicon2, "BOTTOMLEFT", 0, -2);
			glItem.teamicon3:SetSize(12, 12);
			
			-- Add Opponents Column
			glItem.opponent1 = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.opponent1:SetPoint("TOPLEFT", COL4_X, -4);
			glItem.opponent1:SetJustifyH("LEFT");
			glItem.opponenticon1 = glItem:CreateTexture(nil,"ARTWORK");
			glItem.opponenticon1:SetPoint("TOPLEFT", COL4_X, -4);
			glItem.opponenticon1:SetSize(12, 12);
			glItem.opponent2 = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.opponent2:SetPoint("TOPLEFT", glItem.opponent1, "BOTTOMLEFT", 0, -2);
			glItem.opponent2:SetJustifyH("LEFT");
			glItem.opponenticon2 = glItem:CreateTexture(nil,"ARTWORK");
			glItem.opponenticon2:SetPoint("TOPLEFT", glItem.opponenticon1, "BOTTOMLEFT", 0, -2);
			glItem.opponenticon2:SetSize(12, 12);
			glItem.opponent3 = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.opponent3:SetPoint("TOPLEFT", glItem.opponent2, "BOTTOMLEFT", 0, -2);
			glItem.opponent3:SetJustifyH("LEFT");
			glItem.opponenticon3 = glItem:CreateTexture(nil,"ARTWORK");
			glItem.opponenticon3:SetPoint("TOPLEFT", glItem.opponenticon2, "BOTTOMLEFT", 0, -2);
			glItem.opponenticon3:SetSize(12, 12);
			
			-- Add Result Column
			glItem.result = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.result:SetPoint("LEFT", COL5_X+15, 0);
			glItem.result:SetJustifyH("LEFT");
			glItem.result:SetFont(glItem.result:GetFont(), 18);
			
			-- Add Rating Column
			glItem.rating = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.rating:SetPoint("LEFT", COL6_X, 6);
			glItem.rating:SetJustifyH("LEFT");
			glItem.rating:SetTextColor(0.7,0.7,0.7);
			glItem.rating:SetFont(glItem.rating:GetFont(), 16);
			glItem.ratingchange = glItem:CreateFontString(nil,"ARTWORK","GameFontNormal");
			glItem.ratingchange:SetPoint("TOPLEFT", glItem.rating, "BOTTOMLEFT", 0, -2);
			glItem.ratingchange:SetJustifyH("LEFT");
			
			
			-- Add click handler
			glItem:SetScript("OnClick", function(self,button)
				if(button == "LeftButton") then
					tgb.MatchDetails_Update(self.ArenaGameIndex);
				end
			end);
		
		end

		-- Add this constructed row to the {TippyGaryBrowser.GameList}
		tgb.GameList[i] = glItem;
	end

	-- Create game list scroll frame
	tgb.scroll = CreateFrame("ScrollFrame","TippyGaryScroll",tgb.outline,"FauxScrollFrameTemplate");
	tgb.scroll:SetPoint("TOPLEFT", tgb.GameList[2], "TOPLEFT", 0, 0);
	tgb.scroll:SetPoint("BOTTOMRIGHT",tgb.GameList[#tgb.GameList],-18,-1);
	tgb.scroll:SetScript("OnVerticalScroll", function(self,offset)
		FauxScrollFrame_OnVerticalScroll(self,offset,ITEM_HEIGHT,tgb.GameList_Update);
	end);
	
	
	-- Create bottom wrapper
	tgb.BottomContent = CreateFrame("Frame", nil, tgb);
	tgb:initBrowserBottom();
	
	-- Create option: Show Player Names
	tgb.optShowPlayerNames = CreateFrame( "CheckButton", "TippyGaryOptions_ArenaHistShowPlayerNames", tgb, "InterfaceOptionsCheckButtonTemplate");
	tgb.optShowPlayerNames.Label = _G["TippyGaryOptions_ArenaHistShowPlayerNamesText"];
	tgb.optShowPlayerNames.Label:SetText("Show player names");
	tgb.optShowPlayerNames:SetPoint("BOTTOMLEFT", tgb, "BOTTOMLEFT", 10, 10)
	tgb.optShowPlayerNames:SetScript("OnClick", function(self)
		if self:GetChecked() then
			TippyGaryOptions.ArenaHistShowPlayerNames = true;
		else
			TippyGaryOptions.ArenaHistShowPlayerNames = false;
		end
		tgb.GameList_Update(tgb.scroll);
		if(tgb.GameDetailsPanel.GameId) then tgb.MatchDetails_Update(tgb.GameDetailsPanel.GameId) end
	end);


	-- Handle click & drag to move main window
	tgb:SetScript("OnMouseDown", function(self, button) 
		if (button == "LeftButton") then tgb:StartMoving() end
	end);
	tgb:SetScript("OnMouseUp", function(self, button)
		if (button == "LeftButton") then tgb:StopMovingOrSizing() end
		TippyGaryData.DropDown:HideMenu()
	end);


	-- Update game list when window is opened
	tgb:SetScript("OnShow", function(self) tgb:Refresh(true) end);
	
	
	-- Create the game details panel
	tgb.initGameDetailsPanel();
	
end

tgb.Refresh = function(self, home)
	if home then
		tgb.GameDetailsPanel:Hide();
		tgb.GameDetailsPanel.GameId = nil;
		tgb.outline:Show();
		tgb.DropDownArenaType:Show();
	end
	tgb.optShowPlayerNames:SetChecked(TippyGaryOptions.ArenaHistShowPlayerNames);
	tgb.GameList_Update(tgb.scroll);
	tgb:UpdateGameCountText();
end

tgb.OnEnter_GameCount = function(self)
	local gcttTxt = tgb:GetGameCountTooltipText();
	GameTooltip:SetOwner(tgb.GameCountWrap, "ANCHOR_TOPRIGHT");
	for i,v in ipairs(gcttTxt) do GameTooltip:AddLine(v) end
	GameTooltip:Show();
	
	local nl = GameTooltip:NumLines();
	local te = GameTooltip["TextLeft"..nl];
	if te then te:SetFontObject("GameFontGreenSmall") end
end

tgb.OnLeave_GameCount = function(self)
	GameTooltip:Hide();
end

tgb.OnClick_GameCount = function(self)
	if not tgb.GameDetailsPanel.GameId then TippyGaryStatsBrowser:Show() end
end

tgb.GameList_Update = function(self)
	local tdb = _G["TippyGaryDB"];
	local ag = tdb.ArenaGames;
	local fi = nil;
	if tgb.FilterByType then 
		ag,fi = tgb:FilterGamesByType();
	elseif tgb.FilterByCurrentSession then
		ag,fi = tgb:FilterGamesByCurrentSession();
	end
--function FauxScrollFrame_Update(frame, numItems, numToDisplay, valueStep, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth, alwaysShowScrollBar )
	FauxScrollFrame_Update(self, #ag, 9, 50);
	local index = self.offset;
	for i = 2, #tgb.GameList do
		index = (index + 1);
		local btn = tgb.GameList[i];
		if (index <= #ag) then
			local nic = index - 1;
			local newIndex = #ag - nic;
			local v = rawget(ag, newIndex);
			if not fi then
				btn.ArenaGameIndex = newIndex;
			else
				btn.ArenaGameIndex = fi[newIndex];
			end

			-- Set time/date
			local ged = date("*t", v.timeEnded);
			local ampm = "am";
			local geHr = ged.hour;
			local geMin = ged.min;
			if(geHr == 0) then
				geHr = "12";
			else
				if(geHr > 11) then ampm = "pm" end
				if(geHr > 12) then geHr = (geHr - 12) end
			end
			if(geMin < 10) then geMin = ("0" .. geMin) end
			local geTime = geHr .. ":" .. geMin .. ampm;
			local geDate = date("%a %b %e", v.timeEnded);
			btn.when1:SetText(geTime);
			btn.when2:SetText(geDate);
			
			-- Set match type
			btn.type:SetText(v.arenaType);
			
			-- Set Team
			local team = v.arenaFriendlies;
			btn.team2:Hide();
			btn.teamicon2:Hide();
			btn.team3:Hide();
			btn.teamicon3:Hide();
			for t = 1, #team do
				-- Set spec icon
				local vt = team[t];
				local teid = "team" .. t;
				local tiid = "teamicon" .. t;
				btn[tiid]:SetTexture(TippyGaryData.GetClassSpecInfo(vt.Class, vt.Spec, "icon"));
				
				-- Set text
				if (TippyGaryOptions.ArenaHistShowPlayerNames == true) then
					local tName = vt.Name;
					local nd = string.find(tName, "-", 1, true);
					if nd then tName = string.sub(vt.Name, 0, nd-1) end
					btn[teid]:SetText(colorPlayerName(tName, vt.Class));
				else
					local specName = TippyGaryData.GetClassSpecInfo(vt.Class, vt.Spec, "short");
					btn[teid]:SetText(colorPlayerName(specName, vt.Class));
				end
				
				btn[teid]:Show();
				btn[tiid]:Show();
			end 
			
			-- Set Opponents
			local opponents = v.arenaOpponents;
			btn.opponent2:Hide();
			btn.opponenticon2:Hide();
			btn.opponent3:Hide();
			btn.opponenticon3:Hide();
			for o = 1, #opponents do
				-- Set spec icon
				local vo = opponents[o];
				local oeid = "opponent" .. o;
				local oiid = "opponenticon" .. o;
				btn[oiid]:SetTexture(TippyGaryData.GetClassSpecInfo(vo.Class, vo.Spec, "icon"));
				-- Set text
				if (TippyGaryOptions.ArenaHistShowPlayerNames == true) then
					local oName = vo.Name;
					local nd = string.find(oName, "-", 1, true)
					if nd then oName = string.sub(vo.Name, 0, nd-1) end
					btn[oeid]:SetText(colorPlayerName(oName, vo.Class));
				else
					local specName = TippyGaryData.GetClassSpecInfo(vo.Class, vo.Spec, "short");
					btn[oeid]:SetText(colorPlayerName(specName, vo.Class));
				end
				
				btn[oeid]:Show();
				btn[oiid]:Show();
			end
			
			-- Position Team/Opponents
			if(v.arenaType == "2v2" or v.arenaType == "2v1" or v.arenaType == "1v2") then
				btn.team1:SetPoint("TOPLEFT", COL3_X+15, -12);
				btn.teamicon1:SetPoint("TOPLEFT", COL3_X, -12);
				btn.opponent1:SetPoint("TOPLEFT", COL4_X+15, -12);
				btn.opponenticon1:SetPoint("TOPLEFT", COL4_X, -12);
			else
				btn.team1:SetPoint("TOPLEFT", COL3_X+15, -4);
				btn.teamicon1:SetPoint("TOPLEFT", COL3_X, -4);
				btn.opponent1:SetPoint("TOPLEFT", COL4_X+15, -4);
				btn.opponenticon1:SetPoint("TOPLEFT", COL4_X, -4);
			end
			
			-- Set Result
			btn.result:SetText(v.matchResult);
			if(v.matchResult == "W") then
				btn.result:SetPoint("LEFT", COL5_X+11, 0);
			else
				btn.result:SetPoint("LEFT", COL5_X+15, 0);
			end
			
			-- Set Rating
			local function bill()
				if not team[1].RatingChange then
					print("no rating change for #" .. newIndex);
				end
			end
			if not pcall(bill) then print("error at " .. newIndex) end
			local ratingChange = team[1].RatingChange;
			local newRating = team[1].OldRating + ratingChange;
			if(ratingChange > 0) then
				ratingChange = ("|cff00ff00+" .. ratingChange .. "|r");
			elseif(ratingChange < 0) then
				ratingChange = ("|cffff0000" .. ratingChange .. "|r");
			else
				ratingChange = "No change";
			end
			btn.rating:SetText(newRating);
			btn.ratingchange:SetText(ratingChange);
			
			
			-- Display the row
			btn:Show();
		else
			btn:Hide();
		end
	end
end

tgb.MatchDetails_Update = function(gid)
	local md = _G["TippyGaryDB"].ArenaGames[gid];
	local tgas = _G["TippyGaryData"].ArenaStats;
	local gdp = tgb.GameDetailsPanel;
	gdp.GameId = gid;
	
	-- hide other players during setup
	gdp.MyTeam2:Hide();
	gdp.MyTeam3:Hide();
	gdp.Opponent1:Hide();
	gdp.Opponent2:Hide();
	gdp.Opponent3:Hide();
	
	-- update bracket (2v2 or 3v3)
	gdp.Bracket:SetText(md.arenaType);
	
	-- update result (W or L)
	local mResult = gdp:GetResult(md.matchResult);
	gdp.Result:SetText(mResult);
	
	-- update map
	local mapStats = tgas:GetMapStats(md.mapName);
	gdp.Map:SetText(md.mapName);
	gdp.MapStatsTooltipText = gdp:GetMapStatsDetails(mapStats);
	
	-- update rating change
	local ratingChange, rctt = gdp:GetRatingChange(md.arenaFriendlies);
	gdp.RatingChange:SetText(ratingChange);
	gdp.RCTooltipText = rctt;
	
	-- update duration
	local mDuration = tgas:GetMatchDuration(md);
	gdp.Duration:SetText(mDuration);
	gdp.DurationTooltipText = gdp:GetDurationDetails(gid);
	
	-- update new rating
	local newRating = gdp:GetNewRating(md.arenaFriendlies);
	gdp.Rating:SetText(newRating);
	
	-- update my team
	gdp:UpdateTeamList(true, md.arenaFriendlies);
	
	-- update opponents
	gdp:UpdateTeamList(false, md.arenaOpponents);
	
	-- update team stats
	gdp:UpdateTeamStats();
	
	-- update opponent stats
	gdp:UpdateOpponentStats();
	
	-- to do:
	
	-- match details panel
		-- show different bottom options?
		
		-- change Total Games tooltip to viewing
		
		-- map tooltip
			-- add 2v2 and 3v3 stats
		
		-- arena player tooltip
			-- add # games played with/against player
				-- 2v2 and 3v3
	
	
	-- todo: change this line to set the map texture
	--gdp.MapThumb:SetTexture("Interface\\addons\\TippyGary\\textures\\map_nagrand.blp");
	
	-- future: determine team stats versus opponents (by name and by class/spec)
	
	
	
	-- display the match details panel
	tgb.outline:Hide();
	tgb.DropDownArenaType:Hide();
	gdp:Show();
	
	-- show game id
	tgb.GameCountText:SetText("Match #:  |cffffffff" .. gid .. "|r");
end


tgb.initGameDetailsFunctions = function(gdp)
	gdp.GetResult = function(self, mdr)
		local resultColor = "|cffffffff";
		local resultText = "Unknown";
		if(mdr == "W") then
			resultColor = "|cff00ff00";
			resultText = "Win";
		else
			resultColor = "|cffff0000";
			resultText = "Loss";
		end
		local gameResult = resultColor .. resultText .. "|r";
		return gameResult;
	end
	
	gdp.GetDurationDetails = function(self, gid, wintip)
		local ddStr = "null";
		if(not gid) then
			return ddStr;
		else
			local md = _G["TippyGaryDB"].ArenaGames[gid];
			if(wintip) then
				local matchEntered = gdp:MdTime(md.timeEntered);
				local matchStarted = gdp:MdTime(md.timeStarted);
				local matchEnded = gdp:MdTime(md.timeEnded);
				local tLines = {};
				tinsert(tLines, "Match #" .. gid);
				tinsert(tLines, "Joined:  |cffffffff" .. matchEntered .. "|r");
				tinsert(tLines, "Started:  |cffffffff" .. matchStarted .. "|r");
				tinsert(tLines, "Ended:  |cffffffff" .. matchEnded .. "|r");
				return tLines;
			else
				local secsPrepTime = md.timeStarted - md.timeEntered;
				local secsGameTime = md.timeEnded - md.timeStarted;
				ddStr = "Prep Time:  |cffffffff" .. secsPrepTime .. " seconds|r\n";
				ddStr = ddStr .. "Game Time:  |cffffffff" .. SecondsToTime(secsGameTime) .. "|r\n";
				return ddStr;
			end
		end
	end
	
	gdp.GetRatingChange = function(self, mdf, idx)
		if not idx then idx = 1 end;
		local rc;
		local oldRating = mdf[idx].OldRating;
		local ratingChange = mdf[idx].RatingChange;
		local newRating = oldRating + ratingChange;
		if(ratingChange > 0) then
			rc = ("|cff00ff00+" .. ratingChange .. "|r");
		elseif(ratingChange < 0) then
			rc = ("|cffff0000" .. ratingChange .. "|r");
		else
			rc = "|cffffffffNo Change|r";
		end
		local ttTxt = "Old Rating:  |cffffffff" .. oldRating .. "|r\n";
		ttTxt = ttTxt .. "New Rating:  |cffffffff" .. newRating .. "|r"; 
		return rc, ttTxt;
	end
	
	gdp.GetNewRating = function(self, mdf)
		local ratingChange = mdf[1].RatingChange;
		local newRating = mdf[1].OldRating + ratingChange;
		return newRating;
	end
	
	gdp.GetMapStatsDetails = function(self, ms)
		local playRate = ms.Total_Percent;
		local wlsp = "|r";
		local wlsAll = (ms.Wins_All - ms.Loss_All);
		if(wlsAll > 0) then 
			wlsp = "  (|cff00ff00+";
		elseif(wlsAll < 0) then
			wlsp = "  (|cffff0000";
		else
			wlsp = "|r";
		end
		local mstTxt =     "Total Played:  |cffffffff" .. ms.Total_All .. " of " .. ms.Total_Played .. " games  (" .. playRate .. ")|r\n";
		mstTxt = mstTxt .. "Total Win/Loss:  |cffffffff" .. ms.Wins_All .. "-" .. ms.Loss_All .. wlsp;
		if(wlsAll ~= 0) then mstTxt = mstTxt .. wlsAll .. "|r)" end
		return mstTxt;
	end
	
	gdp.MdTime = function(self, mdt)
		local tt = date("*t", mdt);
		local ampm = "am";
		local mdHr = tt.hour;
		local mdMin = tt.min;
		if(mdHr == 0) then
			mdHr = "12";
		else
			if(mdHr > 11) then ampm = "pm" end
			if(mdHr > 12) then mdHr = (mdHr - 12) end
		end
		if(mdMin < 10) then mdMin = ("0" .. mdMin) end
		local mdTime = mdHr .. ":" .. mdMin .. ampm;
		local mdDate = date("%a %b %e", mdt);
		return mdDate .. " @ " .. mdTime;
	end
	
	gdp.GetArenaPlayerIcons = function(self, arenaPlayer)
		local apSex;
		if not arenaPlayer.Sex then
			apSex = "male";
		else
			apSex = string.lower(arenaPlayer.Sex);
		end
		local apRace = string.lower(string.gsub(arenaPlayer.Race, " ", ""));
		local apClass = string.lower(string.gsub(arenaPlayer.Class, " ", ""));
		local raceIcon = "raceicon128-" .. apRace .. "-" .. apSex;
		local classIcon = "classicon-" .. apClass;
		local specIcon = TippyGaryData:GetClassSpecInfo(arenaPlayer.Class, arenaPlayer.Spec, "icon");
		return raceIcon, classIcon, specIcon;
	end

	gdp.UpdateTeamList = function(self, bFriendly, arenaTeam)
		for ti,tv in ipairs(arenaTeam) do
			local raceAtlas, classAtlas, specTexture = gdp:GetArenaPlayerIcons(tv);
			local eid = "MyTeam";
			if not bFriendly then eid = "Opponent" end;
			local tElem = gdp[eid..ti];
			
			-- set race icon
			tElem.RaceIcon:SetAtlas(raceAtlas);
			
			-- set class icon
			tElem.ClassIcon:SetAtlas(classAtlas);
			
			-- set spec icon
			tElem.SpecIcon:SetTexture(specTexture);
			
			-- set texts
			if(TippyGaryOptions.ArenaHistShowPlayerNames == true) then
				local pName = tv.Name;
				local psc = colorPlayerName(tv.Spec .. " " .. tv.Class, tv.Class);
				local nd = string.find(pName, "-", 1, true);
				if nd then pName = string.sub(tv.Name, 0, nd-1) end
				tElem.Text1:SetText(colorPlayerName(pName, tv.Class));
				tElem.Text2:SetText(psc);
			else
				tElem.Text1:SetText(colorPlayerName(tv.Spec, tv.Class));
				tElem.Text2:SetText(colorPlayerName(tv.Class, tv.Class));
			end
			tElem.Text3:SetText(tv.Race);
			tElem.TooltipText = gdp:ArenaPlayerFrame_GetTooltipText(tv);
			
			-- Unhide the frame
			tElem:Show();
		end
	end

	gdp.UpdateTeamStats = function(self)
		-- get current team
		local ag = _G["TippyGaryDB"].ArenaGames;
		local ct = ag[gdp.GameId].arenaFriendlies;
		local teamPlayers = {};
		for pi,pv in ipairs(ct) do
			if(TippyGaryOptions.ArenaHistShowPlayerNames == false) then
				-- show comp record
				tinsert(teamPlayers, {["class"]=pv.Class, ["spec"]=pv.Spec});
			else
				-- show team record
				tinsert(teamPlayers, pv.Name);
			end
		end
		
		-- get stats for current team
		local totalGames = #ag;
		local tGames, tWins, tLoss, tSpread = TippyGaryData.ArenaStats:GetTeamRecord(teamPlayers);
		local tgpp = string.format("%.1f", (tGames / totalGames * 100));
		local d = string.find(tgpp, ".0");
		if d then tgpp = string.sub(tgpp, 0, d-1) end
		
		-- update team games played
		local ts1 = "Games Played:    |cffffffff" .. tGames .. "|r  |cffffff80(" .. tgpp .. "%)|r";
		gdp.TeamStats1:SetText(ts1);
		
		-- update team record
		local ts2 = "Record:    |cffffffff" .. tWins .. "-" .. tLoss .. "|r  (" .. tSpread .. ")";
		gdp.TeamStats2:SetText(ts2);
	end
	
	gdp.UpdateOpponentStats = function(self)
		-- get current opponents
		local ag = _G["TippyGaryDB"].ArenaGames;
		local co = ag[gdp.GameId].arenaOpponents;
		local oppoPlayers = {};
		
		for pi,pv in ipairs(co) do
			if(TippyGaryOptions.ArenaHistShowPlayerNames == false) then
				-- show comp record
				tinsert(oppoPlayers, {["class"]=pv.Class, ["spec"]=pv.Spec});
			else
				-- show team record
				tinsert(oppoPlayers, pv.Name);
			end
		end
			
		
		-- get stats for current team
		local totalGames = #ag;
		local tGames, tWins, tLoss, tSpread = TippyGaryData.ArenaStats:GetOpponentRecord(oppoPlayers);
		local tgpp = string.format("%.1f", (tGames / totalGames * 100));
		local d = string.find(tgpp, ".0");
		if d then tgpp = string.sub(tgpp, 0, d-1) end
		
		-- update opponents games played
		local os1 = "Games Played:    |cffffffff" .. tGames .. "|r  |cffffff80(" .. tgpp .. "%)|r";
		gdp.OpponentStats1:SetText(os1);
		
		-- update team record
		local os2 = "Record:    |cffffffff" .. tWins .. "-" .. tLoss .. "|r  (" .. tSpread .. ")";
		gdp.OpponentStats2:SetText(os2);
	end 
	
	-- Function: Initialize arena player frame
	gdp.InitArenaPlayerFrame = function(self, apf)
		apf:SetSize(227, 50);
		apf.ClassIcon = apf:CreateTexture(nil, "ARTWORK");
			apf.ClassIcon:SetPoint("TOPLEFT", 0, 0);
			apf.ClassIcon:SetSize(50, 50);
			apf.ClassIcon:SetTexture(1662186, "CLAMPTOBLACKADDITIVE");
			apf.ClassIcon:SetBlendMode("ADD");
		apf.RaceIcon = apf:CreateTexture(nil, "ARTWORK");
			apf.RaceIcon:SetPoint("TOPLEFT", 50, -25);
			apf.RaceIcon:SetSize(25, 25);
			apf.RaceIcon:SetTexture(1662186, "CLAMPTOBLACKADDITIVE");
			apf.RaceIcon:SetBlendMode("ADD");
		apf.SpecIcon = apf:CreateTexture(nil, "ARTWORK");
			apf.SpecIcon:SetPoint("TOPLEFT", 50, 0);
			apf.SpecIcon:SetSize(25, 25);
			apf.SpecIcon:SetBlendMode("ADD");
		apf.Text1 = apf:CreateFontString(nil,"ARTWORK","GameFontNormal");
			apf.Text1:SetPoint("TOPLEFT", 85, 0);
			apf.Text1:SetSize(142, 25);
			apf.Text1:SetJustifyH("LEFT");
			apf.Text1:SetJustifyV("TOP");
			apf.Text1:SetFont(apf.Text1:GetFont(), 24);
		apf.Text2 = apf:CreateFontString(nil,"ARTWORK","GameFontNormal");
			apf.Text2:SetPoint("TOPLEFT", 85, -25);
			apf.Text2:SetSize(142, 25);
			apf.Text2:SetJustifyH("LEFT");
			apf.Text2:SetJustifyV("TOP");
		apf.Text3 = apf:CreateFontString(nil,"ARTWORK","GameFontNormal");
			apf.Text3:SetPoint("TOPLEFT", 85, -38);
			apf.Text3:SetSize(142, 25);
			apf.Text3:SetJustifyH("LEFT");
			apf.Text3:SetJustifyV("TOP");
		apf.Highlight = apf:CreateTexture(nil, "BACKGROUND");
			apf.Highlight:SetPoint("TOPLEFT", 0, 0);
			apf.Highlight:SetSize(227, 67);
			apf.Highlight:SetTexture(904010, "CLAMPTOBLACKADDITIVE");
			apf.Highlight:SetColorTexture(0, 0, 0, 0.25);
			apf.Highlight:SetAtlas("campaignheader_selectedglow");
			apf.Highlight:SetAlpha(0.5);
			apf.Highlight:Hide();
		
		apf:SetScript("OnEnter", gdp.OnEnter_ArenaPlayerFrame);
		apf:SetScript("OnLeave", gdp.OnLeave_ArenaPlayerFrame);
	end
	
	-- Event Handler: Mouseover ArenaPlayerFrame
	gdp.OnEnter_ArenaPlayerFrame = function(apf)
		apf.Highlight:Show();
		GameTooltip:SetOwner(apf, "ANCHOR_TOPRIGHT");
		for ti,tv in ipairs(apf.TooltipText) do GameTooltip:AddLine(tv) end
		GameTooltip:Show();
	end
	
	-- Event Handler: Mouseout ArenaPlayerFrame
	gdp.OnLeave_ArenaPlayerFrame = function(apf)
		apf.Highlight:Hide();
		GameTooltip:Hide();
	end
	
	-- Function: Get tooltip text to display on mouseover ArenaPlayerFrame
	gdp.ArenaPlayerFrame_GetTooltipText = function(self, tv)
		local oldRating = tv.OldRating;
		local ratingChange = tv.RatingChange;
		local newRating = oldRating + ratingChange;
		
		local ttTxt = { tv.Name };
		if(TippyGaryOptions.ArenaHistShowPlayerNames == false) then
			local psc = tv.Spec .. " " .. tv.Class;
			local cpn = colorPlayerName(psc, tv.Class);
			ttTxt = { cpn };
		end
		tinsert(ttTxt, "|cffffffffOld Rating: " .. oldRating .. "|r");
		tinsert(ttTxt, "|cffffffffNew Rating: " .. newRating .. "|r\n");
		
		local pn = UnitName("player");
		if(pn == tv.Name) then
			return ttTxt;
		else
			local pgStats = TippyGaryData.ArenaStats:GetGamesPlayedWith(tv);
			-- Show games played together (player)
			if(pgStats.ByName.TeamGames) then
				local bntg = pgStats.ByName.TeamGames;
				local bntw = pgStats.ByName.TeamWins;
				local bntl = pgStats.ByName.TeamLoss;
				local bnts = TippyGaryData:GetWinLossSpread(bntw, bntl);
				local bntp = "game";
				if(bntg > 1) then bntp = "games" end;
				local gptp = "|cffffff80(" .. string.format("%.1f", (bntg / #TippyGaryDB.ArenaGames * 100)) .. "%)|r";
				tinsert(ttTxt, "\n");
				tinsert(ttTxt, bntg .. " " .. bntp .. " played together  " .. gptp);
				tinsert(ttTxt, "|cffffffffRecord: " .. bntw .. "-" .. bntl .. "  " .. bnts);
				
				
				-- games played with class/spec
				local tcsn = colorPlayerName(TippyGaryData:GetClassSpecInfo(tv.Class, tv.Spec, "short"), tv.Class);
				local bstg = pgStats.BySpec.TeamGames;
				local bstw = pgStats.BySpec.TeamWins;
				local bstl = pgStats.BySpec.TeamLoss;
				local bsts = TippyGaryData:GetWinLossSpread(bstw, bstl);
				local bstp = "game";
				if(bstg > 1) then bstp = "games" end;
				local gptc = "  |cffffff80(" .. string.format("%.1f", (bstg / #TippyGaryDB.ArenaGames * 100)) .. "%)|r";
				tinsert(ttTxt, "\n");
				tinsert(ttTxt, bstg .. " " .. bstp .. " played with " .. tcsn .. gptc);
				tinsert(ttTxt, "|cffffffffAll: " .. bstw .. "-" .. bstl .. "  " .. bsts);
			end
			
			-- Show games played against this player
			if(pgStats.ByName.EnemyGames) then
				local bneg = pgStats.ByName.EnemyGames;
				if(bneg > 1) then
					local bnew = pgStats.ByName.EnemyWins;
					local bnel = pgStats.ByName.EnemyLoss;
					local bnes = TippyGaryData:GetWinLossSpread(bnew, bnel);
					local bnep = "game";
					if(bneg > 1) then bnep = "games" end;
					tinsert(ttTxt, "\n");
					tinsert(ttTxt, bneg .. " " .. bnep .. " played against player");
					tinsert(ttTxt, "|cffffffffMy Record: " .. bnew .. "-" .. bnel .. "  " .. bnes);
				end
				
				-- games played against this class/spec
				local bseg = pgStats.BySpec.EnemyGames;
				local ecsn = colorPlayerName(TippyGaryData:GetClassSpecInfo(tv.Class, tv.Spec, "short"), tv.Class);
				if(bseg > 1) then
					local bsew = pgStats.BySpec.EnemyWins;
					local bsel = pgStats.BySpec.EnemyLoss;
					local bses = TippyGaryData:GetWinLossSpread(bsew, bsel);
					local bsep = "game";
					if(bseg > 1) then bsep = "games" end;
					local gpec = "  |cffffff80(" .. string.format("%.1f", (bseg / #TippyGaryDB.ArenaGames * 100)) .. "%)|r";
					tinsert(ttTxt, "\n");
					tinsert(ttTxt, bseg .. " " .. bsep .. " played against " .. ecsn .. gpec);
					tinsert(ttTxt, "|cffffffffMy Record: " .. bsew .. "-" .. bsel .. "  " .. bses);
				end
			end
		end
		
		
		return ttTxt;
	end
end


tgb.initBrowserBottom = function(self)
	local bb = tgb.BottomContent;
	
	
end



tgb.initGameDetailsPanel = function(self)
	-- Create game details wrapper
	local gdw = CreateFrame("Frame",nil,tgb,BackdropTemplateMixin and "BackdropTemplate");
	gdw:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
	gdw:SetBackdropColor(0.1,0.1,0.2,1);
	gdw:SetBackdropBorderColor(0.8,0.8,0.9,0.4);
	gdw:SetPoint("TOPLEFT",12,-38);
	gdw:SetPoint("BOTTOMRIGHT",-12,42);
	gdw:Hide();
	tgb.initGameDetailsFunctions(gdw);
	
	-- Back button
	local backBtn = CreateFrame("Button", nil, gdw, "UIPanelButtonTemplate");
	backBtn:SetText("Back");
	backBtn:SetSize(64, 24);
	backBtn:SetPoint("TOPLEFT", 8, -8);
	backBtn:SetScript("OnClick", function(self)
		gdw.GameId = nil;
		tgb:Refresh(true);
	end);
	
	-- Subheader text
	local sht = gdw:CreateFontString(nil,"ARTWORK","GameFontNormal");
	sht:SetPoint("TOP", 0, -8);
	sht:SetFont(sht:GetFont(), 22);
	sht:SetText("Match Details");
	
	-- [Row 1] -- [Left] -- Bracket (2v2 or 3v3)
	local bracketLabel = gdw:CreateFontString(nil,"ARTWORK","GameFontNormal");
	bracketLabel:SetPoint("TOPLEFT", 16, -60);
	bracketLabel:SetFont(bracketLabel:GetFont(), 16);
	bracketLabel:SetText("Bracket:");
	local bracketTxt = gdw:CreateFontString(nil,"ARTWORK","GameFontNormal");
	bracketTxt:SetPoint("TOPLEFT", bracketLabel, "TOPRIGHT", 15, 1);
	bracketTxt:SetFont(bracketTxt:GetFont(), 18);
	bracketTxt:SetTextColor(0.8,0.8,0.8);
	gdw.Bracket = bracketTxt;
	
	-- [Row 1] -- [Right] -- Result (Win or Loss)
	local resultLabel = gdw:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	resultLabel:SetPoint("TOPLEFT", 340, -60);
	resultLabel:SetFont(resultLabel:GetFont(), 16);
	resultLabel:SetText("Result:");
	local resultTxt = gdw:CreateFontString(nil,"ARTWORK","GameFontNormal");
	resultTxt:SetPoint("TOPLEFT", resultLabel, "TOPRIGHT", 15, 1);
	resultTxt:SetFont(resultTxt:GetFont(), 18);
	gdw.Result = resultTxt;
	
	-- [Row 2] -- [Left] -- Map
	local mapWrapper = CreateFrame("Frame", nil, gdw);
		mapWrapper:SetSize(250, 16);
		mapWrapper:SetPoint("TOPLEFT", bracketLabel, "BOTTOMLEFT", 0, -14);
		mapWrapper:SetScript("OnEnter", function()
			GameTooltip:SetOwner(mapWrapper, "ANCHOR_TOPRIGHT");
			GameTooltip:SetText(gdw.MapStatsTooltipText);
			GameTooltip:Show();
		end);
		mapWrapper:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end);
	local mapLabel = mapWrapper:CreateFontString(nil,"ARTWORK","GameFontNormal");
		mapLabel:SetPoint("TOPLEFT", 0, 0);
		mapLabel:SetFont(mapLabel:GetFont(), 16);
		mapLabel:SetText("Map:");
	local mapTxt = mapWrapper:CreateFontString(nil,"ARTWORK","GameFontNormal");
		mapTxt:SetPoint("TOPLEFT", mapLabel, "TOPRIGHT", 15, 0);
		mapTxt:SetFont(mapTxt:GetFont(), 16);
		mapTxt:SetTextColor(0.8,0.8,0.8);
	gdw.Map = mapTxt;
	gdw.MWrap = mapWrapper;
	
	-- [Row 2] -- [Right] -- Rating Change
	local rcWrapper = CreateFrame("Frame", nil, gdw);
		rcWrapper:SetSize(250, 16);
		rcWrapper:SetPoint("TOPLEFT", resultLabel, "BOTTOMLEFT", 0, -14);
		rcWrapper:SetScript("OnEnter", function()
			GameTooltip:SetOwner(rcWrapper, "ANCHOR_TOPRIGHT");
			GameTooltip:SetText(gdw.RCTooltipText);
			GameTooltip:Show();
		end);
		rcWrapper:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end);
	local rcLabel = rcWrapper:CreateFontString(nil,"ARTWORK","GameFontNormal");
		rcLabel:SetPoint("TOPLEFT", 0, 0);
		rcLabel:SetFont(rcLabel:GetFont(), 16);
		rcLabel:SetText("Rating Change:");
	local rcTxt = rcWrapper:CreateFontString(nil,"ARTWORK","GameFontNormal");
		rcTxt:SetPoint("TOPLEFT", rcLabel, "TOPRIGHT", 15, 0);
		rcTxt:SetFont(rcTxt:GetFont(), 16);
	gdw.RatingChange = rcTxt;
	gdw.RCWrap = rcWrapper;
	
	-- [Row 3] -- [Left] -- Match Duration
	local mdWrapper = CreateFrame("Frame", nil, gdw);
		mdWrapper:SetSize(250, 16);
		mdWrapper:SetPoint("TOPLEFT", 16, -120);
		mdWrapper:SetScript("OnEnter", function()
			GameTooltip:SetOwner(mdWrapper, "ANCHOR_TOPRIGHT");
			GameTooltip:SetText(gdw.DurationTooltipText);
			GameTooltip:Show();
		end);
		mdWrapper:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end);
	local mdLabel = mdWrapper:CreateFontString(nil,"ARTWORK","GameFontNormal");
		mdLabel:SetPoint("TOPLEFT", 0, 0);
		mdLabel:SetFont(mdLabel:GetFont(), 16);
		mdLabel:SetText("Duration:");
	local mdTxt = mdWrapper:CreateFontString(nil,"ARTWORK","GameFontNormal");
		mdTxt:SetPoint("TOPLEFT", mdLabel, "TOPRIGHT", 15, 0);
		mdTxt:SetFont(mdTxt:GetFont(), 16);
		mdTxt:SetTextColor(0.8,0.8,0.8);
	gdw.Duration = mdTxt;
	gdw.DWrap = mdWrapper;
	
	-- [Row 3] -- [Right] -- New Rating
	local ratingLabel = gdw:CreateFontString(nil,"ARTWORK","GameFontNormal");
		ratingLabel:SetPoint("TOPLEFT", rcWrapper, "BOTTOMLEFT", 0, -14);
		ratingLabel:SetFont(ratingLabel:GetFont(), 16);
		ratingLabel:SetText("New Rating:");
	local ratingTxt = gdw:CreateFontString(nil,"ARTWORK","GameFontNormal");
		ratingTxt:SetPoint("TOPLEFT", ratingLabel, "TOPRIGHT", 15, 0);
		ratingTxt:SetFont(ratingTxt:GetFont(), 16);
		ratingTxt:SetTextColor(0.8,0.8,0.8);
	gdw.Rating = ratingTxt;
	
	
	-- My Team
	local myTeamWrapper = CreateFrame("Frame", nil, gdw, BackdropTemplateMixin and "BackdropTemplate");
		myTeamWrapper:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true,
			tileEdge = true,
			tileSize = 32,
			edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 }
		});
		myTeamWrapper:SetBackdropBorderColor(0.8,0.8,0.9,0.4);
		myTeamWrapper:SetPoint("TOPLEFT", 16, -200);
		myTeamWrapper:SetSize(250, 205);
		
	local mtlWrapper = CreateFrame("Frame", nil, myTeamWrapper);
		mtlWrapper:SetPoint("TOPLEFT", 12, 15);
		mtlWrapper:SetSize(250, 16);
		mtlWrapper:SetScript("OnEnter", function()
			GameTooltip:SetOwner(mtlWrapper, "ANCHOR_TOPRIGHT");
			GameTooltip:SetText("Coming soon:  |cffffffffClick to view team stats|r");
			GameTooltip:Show();
		end);
		mtlWrapper:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end);
	local myTeamLabel = mtlWrapper:CreateFontString(nil,"ARTWORK","GameFontNormal");
		myTeamLabel:SetPoint("TOPLEFT", 0, 0);
		myTeamLabel:SetFont(myTeamLabel:GetFont(), 16);
		myTeamLabel:SetText("My Team:");
	local myTeam1 = CreateFrame("Frame", nil, myTeamWrapper);
		myTeam1:SetPoint("TOPLEFT", 11, -12);
		gdw:InitArenaPlayerFrame(myTeam1);	
	local myTeam2 = CreateFrame("Frame", nil, myTeamWrapper);
		myTeam2:SetPoint("TOPLEFT", myTeam1, "BOTTOMLEFT", 0, -15);
		gdw:InitArenaPlayerFrame(myTeam2);
	local myTeam3 = CreateFrame("Frame", nil, myTeamWrapper);
		myTeam3:SetPoint("TOPLEFT", myTeam2, "BOTTOMLEFT", 0, -15);
		gdw:InitArenaPlayerFrame(myTeam3);	
	gdw.MyTeamWrapper = myTeamWrapper;
	gdw.MyTeam1 = myTeam1;
	gdw.MyTeam2 = myTeam2;
	gdw.MyTeam3 = myTeam3;
	

	-- Opponents
	local opponentsWrapper = CreateFrame("Frame", nil, gdw, BackdropTemplateMixin and "BackdropTemplate");
		opponentsWrapper:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true,
			tileEdge = true,
			tileSize = 32,
			edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 }
		});
		opponentsWrapper:SetBackdropBorderColor(0.8,0.8,0.9,0.4);
		opponentsWrapper:SetPoint("TOPLEFT", 328, -200);
		opponentsWrapper:SetSize(250, 205);
	local otlWrapper = CreateFrame("Frame", nil, opponentsWrapper);
		otlWrapper:SetPoint("TOPLEFT", 12, 15);
		otlWrapper:SetSize(250, 16);
		otlWrapper:SetScript("OnEnter", function()
			GameTooltip:SetOwner(otlWrapper, "ANCHOR_TOPRIGHT");
			GameTooltip:SetText("Coming soon:  |cffffffffClick to view stats versus opponents|r");
			GameTooltip:Show();
		end);
		otlWrapper:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end);
	local opponentsLabel = otlWrapper:CreateFontString(nil,"ARTWORK","GameFontNormal");
		opponentsLabel:SetPoint("TOPLEFT", 0, 0);
		opponentsLabel:SetFont(opponentsLabel:GetFont(), 16);
		opponentsLabel:SetText("Opponents:");
	local opponent1 = CreateFrame("Frame", nil, opponentsWrapper);
		opponent1:SetPoint("TOPLEFT", 11, -12);
		gdw:InitArenaPlayerFrame(opponent1);	
	local opponent2 = CreateFrame("Frame", nil, opponentsWrapper);
		opponent2:SetPoint("TOPLEFT", opponent1, "BOTTOMLEFT", 0, -15);
		gdw:InitArenaPlayerFrame(opponent2);
	local opponent3 = CreateFrame("Frame", nil, opponentsWrapper);
		opponent3:SetPoint("TOPLEFT", opponent2, "BOTTOMLEFT", 0, -15);
		gdw:InitArenaPlayerFrame(opponent3);
	gdw.OpponentsWrapper = opponentsWrapper;
	gdw.Opponent1 = opponent1;
	gdw.Opponent2 = opponent2;
	gdw.Opponent3 = opponent3;
	
	
	-- Team Stats
	local ts1 = gdw:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	ts1:SetPoint("TOPLEFT", myTeamWrapper, "BOTTOMLEFT", 0, 0);
	ts1:SetSize(250, 20);
	local ts2 = gdw:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	ts2:SetPoint("TOPLEFT", ts1, "BOTTOMLEFT", 0, 0);
	ts2:SetSize(250, 20);
	gdw.TeamStats1 = ts1;
	gdw.TeamStats2 = ts2;
	
	-- Opponents Stats
	local os1 = gdw:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	os1:SetPoint("TOPLEFT", opponentsWrapper, "BOTTOMLEFT", 0, 0);
	os1:SetSize(250, 20);
	local os2 = gdw:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	os2:SetPoint("TOPLEFT", os1, "BOTTOMLEFT", 0, 0);
	os2:SetSize(250, 20);
	gdw.OpponentStats1 = os1;
	gdw.OpponentStats2 = os2;
	
	
	
	-- Attach to parent frame (TippyGaryBrowser) as GameDetailsPanel
	tgb.GameDetailsPanel = gdw;
end

tgb.UpdateGameCountText = function(self)
	local fbcs = tgb.FilterByCurrentSession;
	local gngp = nil;
	if fbcs then gngp = tgb.FilterGamesByCurrentSession() end
	local gci = TippyGaryData.ArenaStats:GetNumGamesPlayed(gngp);
	local x = tgb.FilterByType;
	if not x or (x == false) then x = "All" end
	local ng = gci[x].Games;
	tgb.GameCountText:SetText("Total Games:  |cffffffff" .. ng .. "|r");
end

tgb.GetGameCountTooltipText = function(self)
	local ttLines = {};
	if not tgb.GameDetailsPanel.GameId then
		local tgas = TippyGaryData.ArenaStats;
		local gci = tgas:GetNumGamesPlayed();
		local ft = tgb.FilterByType or "All";
		tinsert(ttLines, "Arena Stats");
		tinsert(ttLines, "|cffffffff" .. ft .. " Games Played: " .. gci[ft].Games .. "|r");
		tinsert(ttLines, "|cffffffff" .. ft .. " Games Won: " .. gci[ft].Won .. gci[ft].WP .. "|r");
		tinsert(ttLines, "|cffffffff" .. ft .. " Games Lost: " .. gci[ft].Lost .. gci[ft].LP .. "|r");
		tinsert(ttLines, "\n");
		tinsert(ttLines, "|cff0091ffClick to open arena stats|r");
	else
		ttLines = tgb.GameDetailsPanel:GetDurationDetails(tgb.GameDetailsPanel.GameId, true);
	end
	return ttLines;
end

tgb.DropDown_FilterByType_Init = function(self, list)
	-- session games filter
	list[1].value = "CurrentSession";
	list[1].text = "|cffffff80Current Session|r";
	list[1].checked = tgb.FilterByCurrentSession;
	
	-- game type filters
	local gameTypes = {"All Games", "2v2", "3v3"}
	for index, gType in ipairs(gameTypes) do
		local li = index + 1;
		list[li].text = gType;
		if(li == 2) then
			list[li].value = false;
			list[li].checked = (tgb.FilterByType == false);
		else
			list[li].value = gType;
			list[li].checked = (tgb.FilterByType == gType);
		end
	end
	
end

tgb.DropDown_FilterByType_SelectValue = function(self, entry, index)
	if not entry.value then
		tgb.FilterByType = entry.value;
		if tgb.FilterByCurrentSession then
			tgb.DropDownArenaType:SetText("Session Games");
		else
			tgb.DropDownArenaType:SetText("All Games");
		end
		
	else
		if entry.value ~= "CurrentSession" then
			tgb.FilterByType = entry.value;
			if tgb.FilterByCurrentSession then
				tgb.DropDownArenaType:SetText("Session " .. entry.value);
			else
				tgb.DropDownArenaType:SetText(entry.value);
			end
			
		else
			if tgb.FilterByCurrentSession then
				tgb.FilterByCurrentSession = false;
				if not tgb.FilterByType then
					tgb.DropDownArenaType:SetText("All Games");
				else
					tgb.DropDownArenaType:SetText(tgb.FilterByType);
				end
				
			else
				tgb.FilterByCurrentSession = true;
				if not tgb.FilterByType then
					tgb.DropDownArenaType:SetText("Session Games");
				else
					tgb.DropDownArenaType:SetText("Session " .. tgb.FilterByType);
				end
			end
		end
		
		
	end
	--TippyGaryData.DropDown:HideMenu();
	tgb:Refresh();
end

tgb.FilterGamesByType = function(self)
	local ag = _G["TippyGaryDB"].ArenaGames;
	local gType = tgb.FilterByType;
	if not gType then return ag end
	local fg = {};
	local fi = {};
	local gcs = tgb.FilterByCurrentSession;
	for i,v in ipairs(ag) do
		if(v.arenaType == gType) then
			if not gcs then
				tinsert(fg, v);
				tinsert(fi, i);
			else
				if tContains(TippyGaryDB.CurrentSession.ArenaGames, i) then
					tinsert(fg, v);
					tinsert(fi, i);
				end
			end
		end
	end
	return fg, fi;
end

tgb.FilterGamesByCurrentSession = function(self)
	local ag = _G["TippyGaryDB"].ArenaGames;
	local gcs = tgb.FilterByCurrentSession;
	if not gcs then return ag end
	local csg = TippyGaryDB.CurrentSession.ArenaGames;
	local fg = {};
	local fi = {};
	if(#csg > 0) then
		local gf = csg[1];
		local gl = csg[#csg];
		for i = gf,gl do
			tinsert(fg, ag[i]);
			tinsert(fi, i);
		end
	end
	return fg, fi;
end


-- Initialize this module at the start of each session
tgb:RegisterEvent("PLAYER_LOGIN");
tgb:SetScript("OnEvent", initBrowserPanel);







-- /run ConquestFrame.Arena2v2.Tier.Icon:SetTexture(1713488)


-- wow.tools/dbc
-- https://wow.tools/dbc/?dbc=uitextureatlas&build=9.2.7.45338
-- https://wow.tools/dbc/?dbc=uitextureatlasmember&build=9.2.7.45338
-- https://wow.tools/dbc/?dbc=filedatacomplete&build=1.13.0.28377#page=1&colFilter[1]=Interface%5C%5C
-- https://wow.tools/dbc/?dbc=texturefiledata&build=9.2.7.45338#page=1


-- FileDataIDs
-- 	1065418  (interface/helpframe/newplayerexperienceparts.blp)
--  1662186  (interface/glues/charactercreate/charactercreateicons.blp)
--  904010   (Interface\QuestFrame\QuestMapLogAtlas.blp)
--  985877   (interface/lfgframe/groupfinder.blp)

-- atlases:
	--904010:
		-- questdetails-topoverlay
			-- UiTextureAtlasID = 103
			-- TopLeft: 579, 458
			-- BtmRight: 866, 509


	-- 985877
		-- groupfinder-icon-class-{class}
			-- UiTextureAtlasID = 236


	-- uiTextureAtlasIds: 607, 695


-- Add filter and sort options

-- Show W/L stats for:
	-- This session
	-- Today
	-- This Week
	-- This Season
	
	
-- stats to add:
---- W/L with/against every class/spec
---- team W/L


-- track talents used for each match

-- one day when i feel like fixing the scroll:
-- https://wowpedia.fandom.com/wiki/UIHANDLER_OnMouseWheel
