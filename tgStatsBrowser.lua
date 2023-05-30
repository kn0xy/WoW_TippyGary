---------------------------------------------------------------------------------------------------------------------
-- TippyGary Arena Stats Browser
---------------------------------------------------------------------------------------------------------------------
local tgas = TippyGaryData.ArenaStats;
local asb = CreateFrame("Frame","TippyGaryStatsBrowser",UIParent,BackdropTemplateMixin and "BackdropTemplate");
-- asb.categories = {};
-- asb.SelectedCategory = "General";	 (set by function initCategoriesList)
tinsert(UISpecialFrames, asb:GetName());

local function initCategoriesList(list)
	asb.categories = {"General", "Sessions", "Games", "Players", "Teams", "Maps", "Other"};
	asb.SelectedCategory = "General";
	
	for i,cat in ipairs(asb.categories) do
		-- create the category button
		local btn = CreateFrame("Button", nil, list);
		local top = (i * 24 - 24 + 4) * -1 ;
		btn.Top = top;
		btn:SetPoint("TOPLEFT", 4, top);
		btn:SetSize(130, 24);
		btn:SetScript("OnClick", function(self) asb:OnClick_Category(self) end);
		btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD");
		btn.Label = btn:CreateFontString(nil,"ARTWORK","GameFontNormal");
		btn.Label:SetPoint("LEFT", 5, 0);
		btn.Label:SetText(cat);
		btn.Label:SetFont(btn.Label:GetFont(), 14);
		if(i == 1) then 
			btn.Label:SetTextColor(41/255, 154/255, 1);
			btn:Disable();
		end
		list[cat] = btn;
	end
	
	-- create a separate frame for the selected category highlight (overlay)
	list.SelectedHighlight = list:CreateTexture(nil, "ARTWORK");
	list.SelectedHighlight:SetPoint("TOPLEFT", 4, -4);
	list.SelectedHighlight:SetSize(130, 24);
	list.SelectedHighlight:SetTexture(2123218, "CLAMPTOBLACKADDITIVE");
	list.SelectedHighlight:SetAtlas("pvpqueue-button-casual-highlight");
	list.SelectedHighlight:SetAlpha(0.25);
end

local function initCategory_General()
	local wrap = CreateFrame("Frame", nil, asb.StatsView);
	wrap:SetPoint("TOPLEFT", 10, -8);
	wrap:SetPoint("BOTTOMRIGHT", asb.StatsView, "BOTTOMRIGHT", -10, 8);
	
	-- total games played
	wrap.GamesPlayedAll = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.GamesPlayedAll:SetPoint("TOPLEFT", 0, 0);
	wrap.GamesPlayedAll:SetTextColor(1,1,1);
	wrap.GamesPlayedAll:SetText("Total Games Played: ");
	
	-- total games won
	wrap.GamesPlayed2v2 = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.GamesPlayed2v2:SetPoint("TOPLEFT", wrap.GamesPlayedAll, "BOTTOMLEFT", 0, -2);
	wrap.GamesPlayed2v2:SetTextColor(1,1,1);
	wrap.GamesPlayed2v2:SetText("2v2 Games Played: ");
	
	-- total games lost
	wrap.GamesPlayed3v3 = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.GamesPlayed3v3:SetPoint("TOPLEFT", wrap.GamesPlayed2v2, "BOTTOMLEFT", 0, -2);
	wrap.GamesPlayed3v3:SetTextColor(1,1,1);
	wrap.GamesPlayed3v3:SetText("3v3 Games Played: ");
	
	asb.StatsView.General = wrap;
end

local function initCategory_Sessions()
	local wrap = CreateFrame("Frame", nil, asb.StatsView);
	wrap:SetPoint("TOPLEFT", 10, -8);
	wrap:SetPoint("BOTTOMRIGHT", asb.StatsView, "BOTTOMRIGHT", -10, 8);
	
	wrap.StatText1 = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.StatText1:SetPoint("TOPLEFT", 0, 0);
	wrap.StatText1:SetTextColor(1,1,1);
	wrap.StatText1:SetText("Total Sessions:  0");
	
	wrap.StatText2 = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.StatText2:SetPoint("TOPLEFT", 210, 0);
	wrap.StatText2:SetTextColor(1,1,1);
	wrap.StatText2:SetText("Average Session Length:  N/A");
	
	wrap.StatText3 = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.StatText3:SetPoint("TOPLEFT", 0, -18);
	wrap.StatText3:SetTextColor(1,1,1);
	wrap.StatText3:SetText("Total Time:  N/A");
	
	wrap.StatText4 = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.StatText4:SetPoint("TOPLEFT", 210, -18);
	wrap.StatText4:SetTextColor(1,1,1);
	wrap.StatText4:SetText("Average Games Per Session:  N/A");
	
	wrap.StatText5 = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.StatText5:SetPoint("TOPLEFT", 0, -36);
	wrap.StatText5:SetTextColor(1,1,1);
	wrap.StatText5:SetText("Longest Session:  N/A");
	
	wrap.StatText6 = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.StatText6:SetPoint("TOPLEFT", 210, -36);
	wrap.StatText6:SetTextColor(1,1,1);
	wrap.StatText6:SetText("Most Games Per Session:  N/A");
	
	
	-- Session list table headers
	local slto = -140;
	wrap.SomeText = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		wrap.SomeText:SetPoint("TOPLEFT", 0, slto-5);
		wrap.SomeText:SetFont(wrap.SomeText:GetFont(), 13, "THICKOUTLINE");
		wrap.SomeText:SetText("Session Started");
	wrap.SomeText2 = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		wrap.SomeText2:SetPoint("TOPLEFT", 150, slto-5);
		wrap.SomeText2:SetFont(wrap.SomeText:GetFont(), 13, "THICKOUTLINE");
		wrap.SomeText2:SetText("Duration");
	wrap.SomeText3 = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		wrap.SomeText3:SetPoint("TOPLEFT", 275, slto-5);
		wrap.SomeText3:SetFont(wrap.SomeText:GetFont(), 13, "THICKOUTLINE");
		wrap.SomeText3:SetText("Games");
	
	
	-- Create session list buttons
	local ITEM_HEIGHT = 24;
	local NUM_ITEMS = 5;
	local SLT_OFFSET = (slto * -1) - 7;
	for i = 1,NUM_ITEMS do
		local top = (i * ITEM_HEIGHT * -1) - SLT_OFFSET;
		local slItem = CreateFrame("Button", nil, wrap);
		slItem:SetPoint("TOPLEFT", 0, top);
		slItem:SetSize(420, ITEM_HEIGHT);
		slItem:SetHighlightTexture(1400895);
		slItem:SetHighlightAtlas("UI-Character-Info-ItemLevel-Bounce");
		
		slItem.btnText = slItem:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		slItem.btnText:SetPoint("TOPLEFT", 0, -6);
		slItem.btnText:SetTextColor(1,1,1);
		slItem.btnText:SetText("Session Started");
		
		slItem.btnText2 = slItem:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		slItem.btnText2:SetPoint("TOPLEFT", 150, -6);
		slItem.btnText2:SetTextColor(1,1,1);
		slItem.btnText2:SetText("Duration");
		
		slItem.btnText3 = slItem:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		slItem.btnText3:SetPoint("TOPLEFT", 275, -6);
		slItem.btnText3:SetWidth(wrap.SomeText3:GetWidth());
		slItem.btnText3:SetJustifyH("CENTER");
		slItem.btnText3:SetTextColor(1,1,1);
		slItem.btnText3:SetText("Games");
		
		slItem:SetScript("OnClick", function(self)
			local si = self.SessionIndex;
			print("view games for session #" .. si);
		end);
		
		-- Make accessible via parent
		wrap["SessionBtn" .. i] = slItem;
	end
	
	-- Create session list scroll frame
	wrap.scroll = CreateFrame("ScrollFrame",nil,wrap,"FauxScrollFrameTemplate");
	wrap.scroll:SetPoint("TOPLEFT", wrap["SessionBtn1"], "TOPLEFT", 0, 0);
	wrap.scroll:SetPoint("BOTTOMRIGHT", wrap, "BOTTOMRIGHT", -18, 0);
	wrap.scroll:SetScript("OnVerticalScroll", function(self,offset)
		FauxScrollFrame_OnVerticalScroll(self,offset,ITEM_HEIGHT,asb.UpdateSessionList);
	end);
	
	

	wrap:Hide();
	asb.StatsView.Sessions = wrap;
	
end

local function initCategory_Games()
	local wrap = CreateFrame("Frame", nil, asb.StatsView);
	wrap:SetPoint("TOPLEFT", 10, -8);
	wrap:SetPoint("BOTTOMRIGHT", asb.StatsView, "BOTTOMRIGHT", -10, 8);
	
	wrap.SomeText = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.SomeText:SetPoint("TOPLEFT", 0, 0);
	wrap.SomeText:SetTextColor(1,1,1);
	wrap.SomeText:SetText("Games");
	wrap:Hide();

	
	asb.StatsView.Games = wrap;
end

local function initCategory_Players()
	local wrap = CreateFrame("Frame", nil, asb.StatsView);
	wrap:SetPoint("TOPLEFT", 10, -8);
	wrap:SetPoint("BOTTOMRIGHT", asb.StatsView, "BOTTOMRIGHT", -10, 8);
	
	wrap.SomeText = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.SomeText:SetPoint("TOPLEFT", 0, 0);
	wrap.SomeText:SetTextColor(1,1,1);
	wrap.SomeText:SetText("Players");
	wrap:Hide();

	
	asb.StatsView.Players = wrap;
end

local function initCategory_Teams()
	local wrap = CreateFrame("Frame", nil, asb.StatsView);
	wrap:SetPoint("TOPLEFT", 10, -8);
	wrap:SetPoint("BOTTOMRIGHT", asb.StatsView, "BOTTOMRIGHT", -10, 8);
	
	wrap.SomeText = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.SomeText:SetPoint("TOPLEFT", 0, 0);
	wrap.SomeText:SetTextColor(1,1,1);
	wrap.SomeText:SetText("Teams");
	wrap:Hide();

	
	asb.StatsView.Teams = wrap;
end

local function initCategory_Maps()
	local wrap = CreateFrame("Frame", nil, asb.StatsView);
	wrap:SetPoint("TOPLEFT", 10, -8);
	wrap:SetPoint("BOTTOMRIGHT", asb.StatsView, "BOTTOMRIGHT", -10, 8);
	
	wrap.SomeText = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.SomeText:SetPoint("TOPLEFT", 0, 0);
	wrap.SomeText:SetTextColor(1,1,1);
	wrap.SomeText:SetText("Maps");
	wrap:Hide();

	
	asb.StatsView.Maps = wrap;
end

local function initCategory_Other()
	local wrap = CreateFrame("Frame", nil, asb.StatsView);
	wrap:SetPoint("TOPLEFT", 10, -8);
	wrap:SetPoint("BOTTOMRIGHT", asb.StatsView, "BOTTOMRIGHT", -10, 8);
	
	wrap.SomeText = wrap:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	wrap.SomeText:SetPoint("TOPLEFT", 0, 0);
	wrap.SomeText:SetTextColor(1,1,1);
	wrap.SomeText:SetText("Other");
	wrap:Hide();

	
	asb.StatsView.Other = wrap;
end

local function initBrowserPanel()
	-- Initialize browser window
	asb:SetSize(620, 350);
	asb:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 } });
	asb:SetBackdropColor(0.1,0.22,0.35,1);
	asb:SetBackdropBorderColor(0.1,0.1,0.1,1);
	asb:EnableMouse(true);
	asb:SetMovable(true);
	asb:SetToplevel(true);
	asb:SetPoint("CENTER");
	asb:Hide();
	
	-- Create header icon
	asb.HeaderIcon = asb:CreateTexture(nil,"ARTWORK");
	asb.HeaderIcon:SetPoint("TOPLEFT", 14, -10);
	asb.HeaderIcon:SetSize(25, 25);
	asb.HeaderIcon:SetTexture(2124573);

	-- Create header text
	asb.HeaderText = asb:CreateFontString(nil,"ARTWORK","GameFontHighlight");
	asb.HeaderText:SetFont(asb.HeaderText:GetFont(),20,"THICKOUTLINE");
	asb.HeaderText:SetPoint("TOPLEFT", asb.HeaderIcon, "TOPRIGHT", 10, -4);
	asb.HeaderText:SetText("Arena Stats");
	
	-- Create close button
	asb.CloseBtn = CreateFrame("Button",nil,asb,"UIPanelCloseButton");
	asb.CloseBtn:SetPoint("TOPRIGHT",-5,-5);
	asb.CloseBtn:SetScript("OnClick",function() asb:Hide(); end);
	
	-- Create categories list wrapper
	asb.CategoriesList = CreateFrame("Frame",nil,asb,BackdropTemplateMixin and "BackdropTemplate");
	asb.CategoriesList:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
	asb.CategoriesList:SetBackdropColor(0.1,0.1,0.2,1);
	asb.CategoriesList:SetBackdropBorderColor(0.8,0.8,0.9,0.4);
	asb.CategoriesList:SetPoint("TOPLEFT", 12, -50);
	asb.CategoriesList:SetPoint("BOTTOMRIGHT", asb, "BOTTOMLEFT", 150, 12);
	initCategoriesList(asb.CategoriesList);
	
	-- Create stats view wrapper
	asb.StatsView = CreateFrame("Frame",nil,asb,BackdropTemplateMixin and "BackdropTemplate");
	asb.StatsView:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
	asb.StatsView:SetBackdropColor(0.1,0.1,0.2,1);
	asb.StatsView:SetBackdropBorderColor(0.8,0.8,0.9,0.4);
	asb.StatsView:SetPoint("TOPLEFT", asb.CategoriesList, "TOPRIGHT", 4, 0);
	asb.StatsView:SetPoint("BOTTOMRIGHT", asb, "BOTTOMRIGHT", -12, 12);
	
	-- Init category stats views
	initCategory_General();
	initCategory_Sessions();
	initCategory_Games();
	initCategory_Players();
	initCategory_Teams();
	initCategory_Maps();
	initCategory_Other();

	
	-- Handle click & drag to move main window
	asb:SetScript("OnMouseDown", function(self, button) 
		if (button == "LeftButton") then asb:StartMoving() end
	end);
	asb:SetScript("OnMouseUp", function(self, button)
		if (button == "LeftButton") then asb:StopMovingOrSizing() end
	end);
end

local function session_StartTime(tim)
	local sst = date("*t", tim);
	local ampm = "am";
	local ssHr = sst.hour;
	local ssMin = sst.min;
	if(ssHr == 0) then
		ssHr = "12";
	else
		if(ssHr > 11) then ampm = "pm" end
		if(ssHr > 12) then ssHr = (ssHr - 12) end
	end
	if(ssMin < 10) then ssMin = ("0" .. ssMin) end
	local ssTime = ssHr .. ":" .. ssMin .. ampm;
	local ssDate = date("%a %b %e", tim);
	return ssDate .. " " .. ssTime;
end


-- Public module functions
asb.OnClick_Category = function(self, cat)
	local cname = cat.Label:GetText();
	if(cname ~= asb.SelectedCategory) then
		asb.CategoriesList.SelectedHighlight:SetPoint("TOPLEFT", 4, cat.Top);
		asb.CategoriesList[asb.SelectedCategory]:Enable();
		asb.CategoriesList[asb.SelectedCategory].Label:SetTextColor(cat.Label:GetTextColor());
		cat.Label:SetTextColor(41/255, 154/255, 1);
		cat:Disable();
		asb.SelectedCategory = cname;
		asb:LoadCategory(cname);
	end
end

asb.LoadCategory = function(self, cat)
	asb:HideAllCategories();
	asb.StatsView[cat]:Show();
	
	if(cat == "Sessions") then asb:UpdateSessionStats() end
end

asb.HideAllCategories = function(self)
	for i,cat in ipairs(asb.categories) do
		asb.StatsView[cat]:Hide();
	end
end

asb.UpdateSessionStats = function(self)
	local sessions, fi = TippyGaryData.ArenaStats:GetArenaSessions();
	local totalLength = 0;
	local lg = 0;
	local ng = 0;
	local ls = 0;
	local mgps = 0;

	for i,v in ipairs(sessions) do
		if(v.TimeStopped > 0) then
			local durSecs = v.TimeStopped - v.TimeStarted;
			totalLength = totalLength + durSecs;
			lg = lg + 1;
			if (durSecs > ls) then ls = durSecs end
		end
		if(#v.ArenaGames > 0) then
			ng = ng + #v.ArenaGames;
			if(#v.ArenaGames > mgps) then mgps =  #v.ArenaGames end
		end
	end
	
	-- total sessions
	asb.StatsView.Sessions.StatText1:SetText("Total Sessions:  " .. #sessions);
	
	-- average session length
	if(lg > 0) then
		local al = totalLength / lg;
		local avgLength = SecondsToTime(al);
		asb.StatsView.Sessions.StatText2:SetText("Average Session Length:  " .. avgLength);
	end
	
	-- total arena session time
	if(totalLength > 0) then
		local tast = SecondsToTime(totalLength);
		asb.StatsView.Sessions.StatText3:SetText("Total Time:  " .. tast);
	end
	
	-- average games per session
	if(#sessions > 0) then
		local agps = math.floor((ng / #sessions) + 0.5);
		asb.StatsView.Sessions.StatText4:SetText("Average Games Per Session:  " .. agps);
	end
	
	-- longest session
	if(ls > 0) then
		local tls = SecondsToTime(ls);
		asb.StatsView.Sessions.StatText5:SetText("Longest Session:  " .. tls);
	end
	
	-- most games per session
	if(mgps > 0) then
		asb.StatsView.Sessions.StatText6:SetText("Most Games Per Session:  " .. mgps);
	end
	
	-- update session list
	asb.UpdateSessionList(asb.StatsView.Sessions.scroll)
end

asb.UpdateSessionList = function(self)
	local sessions, fi = TippyGaryData.ArenaStats:GetArenaSessions();
	FauxScrollFrame_Update(self, #sessions, 5, 24);
	local index = self.offset;
	for i = 1,5 do
		local btn = asb.StatsView.Sessions["SessionBtn"..i];
		index = index + 1;
		if (index <= #sessions) then
			local nic = index - 1;
			local newIndex = #sessions - nic;
			local v = rawget(sessions, newIndex);
			
			-- Set internal session index
			btn.SessionIndex = fi[newIndex];

			-- Set session started
			local sst = session_StartTime(v.TimeStarted);
			btn.btnText:SetText(sst);
			
			-- Set duration
			local durSecs = v.TimeStopped - v.TimeStarted;
			local duration = SecondsToTime(durSecs);
			btn.btnText2:SetText(duration);
			
			-- Set # games
			btn.btnText3:SetText(#v.ArenaGames);
			
			-- Display the row
			btn:Show();
		else
			btn:Hide();
		end
	end
end




-- Initialize this module at the start of each session
asb:RegisterEvent("PLAYER_LOGIN");
asb:SetScript("OnEvent", initBrowserPanel);