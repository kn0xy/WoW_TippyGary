local _G = getfenv(0);
local mn, tgInternal = ...;
local tgVersion = "0.7.7.1";
local tgLastUpdated = "11/1/2022";
local modName = "TippyGary";
local hooksRegistered = false;




-- Initialize AddOn
local tg = CreateFrame("Frame",modName,UIParent,BackdropTemplateMixin and "BackdropTemplate");
TippyGaryData = {};
TippyGaryData.Frame = tg;
TippyGaryData.Version = tgVersion;
TippyGaryData.LastUpdated = tgLastUpdated;
TippyGaryData.InArena = false;
TippyGaryData.ArenaStarted = false;
TippyGaryData.SaveArena = false;
TippyGaryData.SessionStatsInitialized = false;
TippyGaryData.ConqTooltipSeen = false;

-- Initialize Options
if(TippyGaryOptions == nil) then
	TippyGaryOptions = {};
	TippyGaryOptions.ConqTooltip = true;
	TippyGaryOptions.ConqTooltipShowSession = true;
	TippyGaryOptions.EnlargeTargetMarkers = true;
	TippyGaryOptions.CenterTargetMarkers = true;
	TippyGaryOptions.HideFriendlyHealthbars = true;
	TippyGaryOptions.EnlargeFriendlyNameText = true;
	TippyGaryOptions.ArenaHistShowPlayerNames = true;
end

-- Initialize DB
TippyGaryData.InitDB = function(self)
	TippyGaryDB = {};
	TippyGaryDB.NumGames = 0;
	TippyGaryDB.ArenaGames = {};
	TippyGaryDB.Sessions = {};
	TippyGaryDB.CurrentGame = {};
	TippyGaryDB.CurrentSession = {};
	TippyGaryDB.CurrentSession.TimeStarted = time();
	TippyGaryDB.CurrentSession.ArenaGames = {};
end
if(TippyGaryDB == nil) then TippyGaryData:InitDB() end





--------------------------------------------------------------------------------------------------------
--    AddOn Functions                                          										  --
--------------------------------------------------------------------------------------------------------

TippyGaryData.InitSession = function(self)
	-- save last session if exists
	local cs = _G["TippyGaryDB"].CurrentSession;
	if(cs ~= nil) then
		tinsert(_G["TippyGaryDB"].Sessions, cs);
	end
	
	-- initialize new session
	cs = {};
	cs.TimeStarted = time();
	cs.TimeStopped = 0;
	cs.ArenaGames = {};
	cs.Highest2v2 = 0;
	cs.Highest3v3 = 0;
	cs.Lowest2v2 = 0;
	cs.Lowest3v3 = 0;
	
	-- update global
	_G["TippyGaryDB"].CurrentSession = cs;
end

TippyGaryData.InitSessionStats = function(self)
	local ctt = _G["ConquestTooltip"];
	
	-- Session Stats: Label
	local ssl = ctt:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	ssl:SetPoint("TOPLEFT", ctt.Tier, "BOTTOMLEFT", 0, -12);
	ssl:SetFont(ctt.WeeklyLabel:GetFont());
	ssl:SetText("Session Stats");
	ctt.SessionLabel = ssl;
	
	-- Session Stats: Best Rating
	local sstBest = ctt:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	sstBest:SetPoint("TOPLEFT", ssl, "BOTTOMLEFT", 0, -2);
	sstBest:SetFont(ctt.WeeklyBest:GetFont());
	sstBest:SetJustifyH("LEFT");
	sstBest:SetText("|cffffffffBest Rating: ?|r");
	ctt.SessionBest = sstBest;
	
	-- Session Stats: Games Played
	local sstPlayed = ctt:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	sstPlayed:SetPoint("TOPLEFT", sstBest, "BOTTOMLEFT", 0, -2);
	sstPlayed:SetFont(ctt.WeeklyBest:GetFont());
	sstPlayed:SetJustifyH("LEFT");
	sstPlayed:SetText("|cffffffffGames Played: ?|r");
	ctt.SessionGamesPlayed = sstPlayed;
	
	-- Session Stats: Games Won
	local sstWon = ctt:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	sstWon:SetPoint("TOPLEFT", sstPlayed, "BOTTOMLEFT", 0, -2);
	sstWon:SetFont(ctt.WeeklyBest:GetFont());
	sstWon:SetJustifyH("LEFT");
	sstWon:SetText("|cffffffffGames Won: ?|r");
	ctt.SessionGamesWon = sstWon;
	
	-- Enable / display on Conquest tooltip
	TippyGaryData:SessionStats_Enable();
	TippyGaryData.SessionStatsInitialized = true;
end

TippyGaryData.SessionStats_Enable = function(self)
	local ctt = _G["ConquestTooltip"];
	ctt:SetHeight(ctt:GetHeight()+75);
	if(TippyGaryData.SessionStatsInitialized == true) then
		ctt.SessionLabel:Show();
		ctt.SessionBest:Show();
		ctt.SessionGamesPlayed:Show();
		ctt.SessionGamesWon:Show();
	end
end

TippyGaryData.SessionStats_Disable = function(self)
	local ctt = _G["ConquestTooltip"];
	ctt:SetHeight(ctt:GetHeight()-75);
	ctt.SessionLabel:Hide();
	ctt.SessionBest:Hide();
	ctt.SessionGamesPlayed:Hide();
	ctt.SessionGamesWon:Hide();
end

TippyGaryData.GetSessionTimeElapsed = function(self)
	local stt = SecondsToTime;
	local secsNow = time();
	local secsStart = TippyGaryDB.CurrentSession.TimeStarted;
	local secsElapsed = secsNow - secsStart;
	return stt(secsElapsed);
end

TippyGaryData.GetWinLossSpread = function(self, sWins, sLoss)
	local sPosNeg = sWins - sLoss;
	local ssnc = "|cffffffff";
	local ssns = "";
	if(sPosNeg > 0) then
		ssnc = "|cff00ff00";
		ssns = "+";
	elseif(sPosNeg < 0) then
		ssnc = "|cffff0000";
	end
	return ssnc .. "(" .. ssns .. sPosNeg .. ")|r";
end

TippyGaryData.UpdateSessionHighestLowest = function(self)
	local ag = _G["TippyGaryDB"].ArenaGames;
	local lg = ag[#ag];
	local cht = "Highest" .. lg.arenaType;
	local clt = "Lowest" .. lg.arenaType;
	local oldRating = lg.arenaFriendlies[1].OldRating;
	local ratingChange = lg.arenaFriendlies[1].RatingChange;
	local newRating = oldRating + ratingChange;
	local currentHigh = _G["TippyGaryDB"].CurrentSession[cht];
	local currentLow = _G["TippyGaryDB"].CurrentSession[clt];
	if(newRating > currentHigh) then _G["TippyGaryDB"].CurrentSession[cht] = newRating end
	if(currentLow == 0) or (currentLow > 0 and newRating < currentLow) then
		_G["TippyGaryDB"].CurrentSession[clt] = newRating;
	end
end

TippyGaryData.GetClassSpecInfo = function(self, class, spec, prop)
	if(type(self) == "string") then
		prop = spec;
		spec = class;
		class = self;
	end
	local csi = {
		["Death Knight"] = {
			["Blood"] = {
				icon = "spell_deathknight_bloodpresence",
				short = "Blood DK"
			},
			["Frost"] = {
				icon = "spell_deathknight_frostpresence",
				short = "Frost DK"
			},
			["Unholy"] = {
				icon = "spell_deathknight_unholypresence",
				short = "Unholy DK"
			},
		},
		["Demon Hunter"] = {
			["Havoc"] = {
				icon = "ability_demonhunter_specdps",
				short = "Havoc DH"
			},
			["Vengeance"] = {
				icon = "ability_demonhunter_spectank",
				short = "Vengeance DH"
			}
		},
		["Druid"] = {
			["Balance"] = {
				icon = "spell_nature_starfall",
				short = "Balance Druid"
			},
			["Feral"] = {
				icon = "ability_druid_catform",
				short = "Feral Druid"
			},
			["Guardian"] = {
				icon = "ability_racial_bearform",
				short = "Tank Druid"
			},
			["Restoration"] = {
				icon = "spell_nature_healingtouch",
				short = "Resto Druid"
			}
		},
		["Hunter"] = {
			["Beast Mastery"] = {
				icon = "ability_hunter_bestialdiscipline",
				short = "BM Hunter"
			},
			["Marksmanship"] = {
				icon = "ability_hunter_focusedaim",
				short = "MM Hunter"
			},
			["Survival"] = {
				icon = "ability_hunter_camouflage",
				short = "Surv Hunter"
			}
		},
		["Mage"] = {
			["Arcane"] = {
				icon = "spell_holy_magicalsentry",
				short = "Arcane Mage"
			},
			["Fire"] = {
				icon = "spell_fire_firebolt02",
				short = "Fire Mage"
			},
			["Frost"] = {
				icon = "spell_frost_frostbolt02",
				short = "Frost Mage"
			}
		},
		["Monk"] = {
			["Brewmaster"] = {
				icon = "spell_monk_brewmaster_spec",
				short = "Tank Monk"
			},
			["Mistweaver"] = {
				icon = "spell_monk_mistweaver_spec",
				short = "MW Monk"
			},
			["Windwalker"] = {
				icon = "spell_monk_windwalker_spec",
				short = "WW Monk"
			}
		},
		["Paladin"] = {
			["Holy"] = {
				icon = "spell_holy_holybolt",
				short = "Holy Paladin"
			},
			["Protection"] = {
				icon = "ability_paladin_shieldofthetemplar",
				short = "Prot Paladin"
			},
			["Retribution"] = {
				icon = "spell_holy_auraoflight",
				short = "Ret Paladin"
			}
		},
		["Priest"] = {
			["Discipline"] = {
				icon = "spell_holy_powerwordshield",
				short = "Disc Priest"
			},
			["Holy"] = {
				icon = "spell_holy_guardianspirit",
				short = "Holy Priest"
			},
			["Shadow"] = {
				icon = "spell_shadow_shadowwordpain",
				short = "Shadow Priest"
			}
		},
		["Rogue"] = {
			["Assassination"] = {
				icon = "ability_rogue_deadlybrew",
				short = "Assa Rogue"
			},
			["Outlaw"] = {
				icon = "ability_rogue_waylay",
				short = "Outlaw Rogue"
			},
			["Subtlety"] = {
				icon = "ability_stealth",
				short = "Sub Rogue"
			}
		},
		["Shaman"] = {
			["Elemental"] = {
				icon = "spell_nature_lightning",
				short = "Ele Shaman"
			},
			["Enhancement"] = {
				icon = "spell_shaman_improvedstormstrike",
				short = "Enhance Sham"
			},
			["Restoration"] = {
				icon = "spell_nature_magicimmunity",
				short = "Resto Shaman"
			}
		},
		["Warlock"] = {
			["Affliction"] = {
				icon = "spell_shadow_deathcoil",
				short = "Affliction Lock"
			},
			["Demonology"] = {
				icon = "spell_shadow_metamorphosis",
				short = "Demo Lock"
			},
			["Destruction"] = {
				icon = "spell_shadow_rainoffire",
				short = "Destro Lock"
			}
		},
		["Warrior"] = {
			["Arms"] = {
				icon = "ability_warrior_savageblow",
				short = "Arms Warrior"
			},
			["Fury"] = {
				icon = "ability_warrior_innerrage",
				short = "Fury Warrior"
			},
			["Protection"] = {
				icon = "ability_warrior_defensivestance",
				short = "Prot Warrior"
			}
		}
	};
	
	if(prop == "icon") then
		return "interface\\icons\\" .. csi[class][spec][prop];
	else
		return csi[class][spec][prop];
	end
	
end

TippyGaryData.UpdateNameplates = function(self)
	local nameplates = C_NamePlate.GetNamePlates(true);
	for i,np in ipairs(nameplates) do
		local npn = np:GetName();
		if(npn ~= nil) then newNameplate(npn) end
	end
end

function TgMsg(msg) DEFAULT_CHAT_FRAME:AddMessage(tostring(msg):gsub("|1","|cffffff80"):gsub("|2","|cffffffff"),0.5,0.75,1.0); end

local function updateConquestTooltip()
	if(TippyGaryOptions.ConqTooltip == false and TippyGaryOptions.ConqTooltipShowSession == false) then return end
	local ctt = _G["ConquestTooltip"];
	
	-- Show session stats
	if(TippyGaryOptions.ConqTooltipShowSession == true) then
		if not TippyGaryData.SessionStatsInitialized then
			TippyGaryData:InitSessionStats();
		end
		
		-- Reposition tooltip
		local ttType = nil;
		local ttAnchor = nil;
		local gmf = GetMouseFocus();
		if(gmf.toolTipTitle == ConquestFrame.Arena2v2.toolTipTitle) then
			ttType = "2v2";
			ttAnchor = ConquestFrame.Arena2v2;
			
		elseif(gmf.toolTipTitle == ConquestFrame.Arena3v3.toolTipTitle) then
			ttType = "3v3";
			ttAnchor = ConquestFrame.Arena3v3;
		else
			ttType = "10v10";
			ttAnchor = ConquestFrame.RatedBG;
		end
		ctt:SetPoint("BOTTOMLEFT", ttAnchor, "BOTTOMRIGHT", 6, 0);
		ctt.WeeklyLabel:SetPoint("TOPLEFT", ctt.SessionLabel, "BOTTOMLEFT", 0, -56);
		
		-- Get base stats
		local sHighest = TippyGaryDB.CurrentSession["Highest"..ttType];
		local sGames, sWins, sLoss = TippyGaryData.ArenaStats:GetSessionStats(ttType);
		
		-- Update session stats texts
		if sHighest then
			ctt.SessionBest:SetText("|cffffffffBest Rating: " .. sHighest .. "|r");
			ctt.SessionGamesPlayed:SetText("|cffffffffGames Played: " .. sGames .. "|r");
			ctt.SessionGamesWon:SetText("|cffffffffGames Won: " .. sWins .. "|r");
		else
			ctt.SessionBest:SetText("|cffffffffBest Rating: ?|r");
			ctt.SessionGamesPlayed:SetText("|cffffffffGames Played: " .. sGames .. "|r");
			ctt.SessionGamesWon:SetText("|cffffffffGames Won: " .. sWins .. "|r");
		end
		
		if(TippyGaryOptions.ConqTooltip == true) then
			if(sGames > 0) then
				-- Show win/loss
				local sWinLoss = "  |cffffff80(" .. sWins .. "-" .. sLoss .. ")|r";
				ctt.SessionGamesPlayed:SetText(ctt.SessionGamesPlayed:GetText() .. sWinLoss);
				
				-- Show spread
				local sWlSpread = TippyGaryData:GetWinLossSpread(sWins, sLoss);
				ctt.SessionGamesWon:SetText(ctt.SessionGamesWon:GetText() .. "  " .. sWlSpread);
			end
		end
	end
	
	
	if(TippyGaryOptions.ConqTooltip == true) then
		-- Weekly W/L
		local cttWeeklyPlayed = ctt.WeeklyPlayed:GetText();
		local cttWeeklyWon = ctt.WeeklyWon:GetText();
		local numWeeklyPlayed = tonumber(string.sub(cttWeeklyPlayed, 14));
		if not numWeeklyPlayed then numWeeklyPlayed = tonumber(string.sub(cttWeeklyPlayed, 11)) end
		if numWeeklyPlayed then
			if(numWeeklyPlayed > 0) then
				local numWeeklyWon = tonumber(string.sub(cttWeeklyWon, 11));
				local numWeeklyLost = numWeeklyPlayed - numWeeklyWon;
				local weeklyWinLoss = "  |cffffff80(" .. numWeeklyWon .. "-" .. numWeeklyLost .. ")|r";
				local weeklyPosNeg = TippyGaryData:GetWinLossSpread(numWeeklyWon, numWeeklyLost);
				local strWeeklyPlayed = cttWeeklyPlayed .. weeklyWinLoss;
				local strWeeklyWon = cttWeeklyWon .. "  " .. weeklyPosNeg;
				ctt.WeeklyWon:SetText(strWeeklyPlayed);
				ctt.WeeklyPlayed:SetText(strWeeklyWon);
			else
				ctt.WeeklyWon:SetText(cttWeeklyPlayed);
				ctt.WeeklyPlayed:SetText(cttWeeklyWon);
			end
		end
		
		-- Season W/L
		local cttSeasonPlayed = ctt.SeasonPlayed:GetText();
		local cttSeasonWon = ctt.SeasonWon:GetText();
		local numSeasonPlayed = tonumber(string.sub(cttSeasonPlayed, 14));
		if not numSeasonPlayed then numSeasonPlayed = tonumber(string.sub(cttSeasonPlayed, 11)) end
		if numSeasonPlayed then
			if(numSeasonPlayed > 0) then
				local numSeasonWon = tonumber(string.sub(cttSeasonWon, 11));
				--local numSeasonLost = numSeasonPlayed - numSeasonWon;
				local numSeasonLost = numSeasonWon - numSeasonPlayed;
				local seasonWinLoss = "   |cffffff80(" .. numSeasonWon .. "-" .. numSeasonLost .. ")|r";
				local seasonPosNeg = TippyGaryData:GetWinLossSpread(numSeasonWon, numSeasonLost);
				local strSeasonPlayed = cttSeasonPlayed .. seasonWinLoss;
				local strSeasonWon = cttSeasonWon .. "  " .. seasonPosNeg;
				ctt.SeasonWon:SetText(strSeasonPlayed);
				ctt.SeasonPlayed:SetText(strSeasonWon);
			else
				ctt.SeasonWon:SetText(cttSeasonPlayed);
				ctt.SeasonPlayed:SetText(cttSeasonWon);
			end
		end
		
		-- Resize tooltip
		if not numWeeklyPlayed then numWeeklyPlayed = 0 end
		if not numSeasonPlayed then numSeasonPlayed = 0 end
		if(numWeeklyPlayed > 0 or numSeasonPlayed > 0) then
			local sw = ctt.SeasonWon:GetWidth();
			local ww = ctt.WeeklyWon:GetWidth();
			local nw = sw;
			if (ww > nw) then nw = ww end
			local newWidth = nw + 30;
			ctt:SetWidth(newWidth);
		end
		if(TippyGaryOptions.ConqTooltipShowSession == true and TippyGaryData.ConqTooltipSeen == true) then ctt:SetHeight(ctt:GetHeight()+70) end
		TippyGaryData.ConqTooltipSeen = true;
	end
end

local function newNameplate(unitID)
	--local nameplate = C_NamePlate.GetNamePlateForUnit(unitID);
	local nameplate = _G[unitID];
	if(nameplate == nil) then nameplate = C_NamePlate.GetNamePlateForUnit(unitID) end;
	nameplate.UnitFrame.RaidTargetFrame:ClearAllPoints();
	if(TippyGaryOptions.CenterTargetMarkers == true) then
		if(TippyGaryOptions.EnlargeTargetMarkers == true) then
			nameplate.UnitFrame.RaidTargetFrame:SetPoint("TOP", nameplate.UnitFrame, "TOP", 0, 20);
		else
			nameplate.UnitFrame.RaidTargetFrame:SetPoint("TOP", nameplate.UnitFrame, "TOP", 0, 10);
		end
	else
		if(TippyGaryOptions.EnlargeTargetMarkers == true) then
			nameplate.UnitFrame.RaidTargetFrame:SetPoint("LEFT", nameplate.UnitFrame.healthBar, "LEFT", -22, 0);
		else
			nameplate.UnitFrame.RaidTargetFrame:SetPoint("LEFT", nameplate.UnitFrame.healthBar, "LEFT", -25, 0);
		end
	end
	
	if(UnitIsFriend("player", unitID)) then
		nameplate.UnitFrame.healthBar:SetScale(0.5);
		if(TippyGaryOptions.EnlargeTargetMarkers == true) then
			nameplate.UnitFrame.RaidTargetFrame:SetScale(4);
		else
			nameplate.UnitFrame.RaidTargetFrame:SetScale(1);
		end
	else
		nameplate.UnitFrame.healthBar:SetScale(1.25);
		if(TippyGaryOptions.EnlargeTargetMarkers == true) then
			nameplate.UnitFrame.RaidTargetFrame:SetScale(2);
		else
			nameplate.UnitFrame.RaidTargetFrame:SetScale(1);
		end
	end
	
	
	-- nameplate.UnitFrame.hideHealthbar = true;
	-- nameplate.UnitFrame.name:SetScale(1.5))
end

local function arenaPlayerExists(unit)
	local tdb = _G["TippyGaryDB"];
	local cg = tdb.CurrentGame;
	if(unit == "player" or unit == "party1" or unit == "party2") then
		-- Look in Friendlies table
		for k,v in ipairs(cg.arenaFriendlies) do
			local tuId = v.UnitID;
			if(v.UnitID == unit) then
				return k;
			end
		end
	else
		-- Look in Opponents table
		for k,v in ipairs(cg.arenaOpponents) do
			local tuId = v.UnitID;
			if(v.UnitID == unit) then
				return k;
			end
		end
	end
	return false;
end

local function createArenaPlayer(unit)
	if(UnitExists(unit)) then
		local guid = UnitGUID(unit);
		if(string.sub(guid, 0, 6) == "Player") then
			local sex = {"", "male", "female"};
			local arenaPlayer = {};
			arenaPlayer.UnitID = unit;
			arenaPlayer.Guid = guid;
			arenaPlayer.Gender = sex[UnitSex(unit)];
			return arenaPlayer;
		else
			return false;
		end
	else
		return false;
	end
end

local function updateCurrentFriendlies()
	local af = {};
	local iMax = 1;
	local num = GetNumSubgroupMembers();
	if num then iMax = iMax + num end
	
	-- add player
	local me = createArenaPlayer("player");
	if not me then 
		TgMsg("|1TippyGary:|r |2Error creating arenaPlayer entity for current player|r")
	else
		tinsert(af, me);
	end
	
	-- add party
	for i = 1,5 do
		local str = "party" .. i;
		local ap = createArenaPlayer(str);
		if ap then tinsert(af, ap) end
		if(#af == iMax) then break end
	end
	
	_G["TippyGaryDB"].CurrentGame.arenaFriendlies = af;
end

local function arenaOpponentSeen(unit)
	if(UnitExists(unit)) then
		if(string.sub(UnitGUID(unit), 0, 6) ~= "Player") then return end
		if(not arenaPlayerExists(unit)) then
			local tdb = _G["TippyGaryDB"];
			local cg = tdb.CurrentGame;
			local ao = cg.arenaOpponents;
			local ap = createArenaPlayer(unit);
			if ap then
				tinsert(ao, ap);
				local num = GetNumGroupMembers();
				_G["TippyGaryDB"].CurrentGame.arenaType = num .. "v" .. table.getn(ao);
				--TgMsg("Added opponent: |2" .. unit .. "|r");
			end
			
			if(cg.mapName == "Unknown") then cg.mapName = GetRealZoneText() end
		end
	end
end

local function arenaEntered()
	-- Init new arena game
	local newGame = {};
	newGame.arenaType = "Unknown";
	newGame.arenaFriendlies = {};
	newGame.arenaOpponents = {};
	newGame.timeEntered = time();
	newGame.timeStarted = 0;
	newGame.timeEnded = 0;
	newGame.mapName = "Unknown";
	newGame.matchResult = "Unknown";
	
	TippyGaryDB.CurrentGame = newGame;
	TippyGaryData.InArena = true;
	TippyGaryData.ArenaStarted = false;
	
	tg:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL");
	--print("Entered arena");
end

local function arenaStarted()
	_G["TippyGaryDB"].CurrentGame.timeStarted = time();
	local isSkirmish = IsArenaSkirmish();
	local isShuffle = C_PvP.IsSoloShuffle();
	if isSkirmish or isShuffle then
		-- Don't save skirmishes or solo shuffles
		TippyGaryData.SaveArena = false;
	else
		TippyGaryData.SaveArena = true;
	end
	TippyGaryData.ArenaStarted = true;
end

local function arenaExited()
	-- capture as much data as possible and save the current game
	
	
	
	TippyGaryData.ArenaStarted = false;
	TippyGaryData.InArena = false;
end

local function gameTimeBaby()
	local prd = _G["PVPReadyDialog"];
	prd.label:SetText("IT'S GAME TIME BABY!")
end

local function groupRosterUpdated()
	if(TippyGaryData.InArena and not TippyGaryData.ArenaStarted) then
		updateCurrentFriendlies();
	end
end

local function parseArenaScoreInfo(arenaPlayer)
	local scoreInfo = C_PvP.GetScoreInfoByPlayerGuid(arenaPlayer.Guid);
	local aPlayer = {};
	aPlayer.Name = scoreInfo.name;
	aPlayer.Race = scoreInfo.raceName;
	aPlayer.Sex = arenaPlayer.Gender;
	aPlayer.Class = scoreInfo.className;
	aPlayer.Spec = scoreInfo.talentSpec;
	aPlayer.OldRating = scoreInfo.rating;
	aPlayer.RatingChange = scoreInfo.ratingChange;
	
	return aPlayer;
end

local function pvpMatchComplete(winner, duration)
	if(TippyGaryData.SaveArena) then
		local tdb = _G["TippyGaryDB"];
		local cg = tdb.CurrentGame;
		local cgf = cg.arenaFriendlies;
		local cgo = cg.arenaOpponents;
		local myFaction = GetBattlefieldArenaFaction();
		
		-- Save match result
		if(myFaction == winner) then
			cg.matchResult = "W";
		else
			cg.matchResult = "L";
		end
		
		-- Save end time
		cg.timeEnded = time();
		
		-- Save map name
		cg.mapName = GetRealZoneText();
		
		-- Save PvP score data for Friendlies
		for fi,fv in ipairs(cgf) do
			cgf[fi] = parseArenaScoreInfo(fv);
		end
		cg.arenaFriendlies = cgf;
		
		-- Save PvP score data for Opponents
		for oi,ov in ipairs(cgo) do
			cgo[oi] = parseArenaScoreInfo(ov);
		end
		cg.arenaOpponents = cgo;
		
		
		-- Save CurrentGame to ArenaGames
		local saveAg = tdb.ArenaGames;
		tinsert(saveAg, cg);
		_G["TippyGaryDB"].ArenaGames = saveAg;
		
		-- Update session
		local cs = tdb.CurrentSession.ArenaGames;
		tinsert(cs, #saveAg);
		_G["TippyGaryDB"].CurrentSession.ArenaGames = cs;
		TippyGaryData:UpdateSessionHighestLowest();
	end
	
	
	-- clear currentGame
	_G["TippyGaryDB"].CurrentGame = {};
	
	TippyGaryData.InArena = false;
	TippyGaryData.ArenaStarted = false;
	tg:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL");
	print("PVP Match Complete");
end

local function handleEvents(self, event, ...)
	if(event == "PVP_RATED_STATS_UPDATE") then
		if (not hooksRegistered) then
			local ctt = _G["ConquestTooltip"];
			ctt:HookScript("OnShow", updateConquestTooltip);
			local prd = _G["PVPReadyDialog"];
			prd:HookScript("OnShow", gameTimeBaby);
			hooksRegistered = true;
		end
	elseif(event == "NAME_PLATE_UNIT_ADDED") then
		local unitID = ...
		newNameplate(unitID)
	elseif(event == "PLAYER_ENTERING_WORLD") then
		local isLogin, isReload = ...;
		if(isLogin) then
			TippyGaryData:InitSession();
		end
		local inInstance, instanceType = IsInInstance()
		if(instanceType == "arena") then
			if(C_PvP.GetActiveMatchState() ~= Enum.PvPMatchState.Active) then
				arenaEntered();
			else
				-- most likely coming back from a dc; capture as much info as possible
				-- to do: add this function
			end
		else
			if TippyGaryData.InArena then
				arenaExited();
			end
		end
	
	
	elseif(event == "ARENA_OPPONENT_UPDATE") then
		local unitId, unitEvent = ...;
		if (unitEvent == "seen") then
			arenaOpponentSeen(unitId);
		end
		
	elseif(event == "GROUP_ROSTER_UPDATE") then
		groupRosterUpdated();
		
	elseif(event == "CHAT_MSG_BG_SYSTEM_NEUTRAL") then
		local msg = ...;
		if(msg == "The Arena battle has begun!") then
			arenaStarted();
		end
		
	elseif(event == "PVP_MATCH_COMPLETE") then
		local w, d = ...;
		pvpMatchComplete(w, d);
		
	elseif(event == "PLAYER_LOGOUT") then
		_G["TippyGaryDB"].CurrentSession.TimeStopped = time();
		
	end
end





--------------------------------------------------------------------------------------------------------
--    Slash Handling                                           										  --
--------------------------------------------------------------------------------------------------------

_G["SLASH_"..modName.."1"] = "/tippy";
_G["SLASH_"..modName.."2"] = "/tippygary";
_G["SLASH_"..modName.."3"] = "/tg";
SlashCmdList[modName] = function(cmd)
	-- Extract Parameters
	local param1, param2 = cmd:match("^([^%s]+)%s*(.*)$");
	param1 = (param1 and param1:lower() or cmd:lower());
	if (param1 == "") then
		TgMsg("|1TippyGary Options|r:");
		TgMsg("     |2options|r - Open the options window");
		TgMsg("     |2stats|r - Open the arena stats window");
		TgMsg("     |2hist|r - Open the arena history window");
		TgMsg("     |2clear|r - Clear saved arena history");
		TgMsg("     |2time|r - Display session time elapsed");
		TgMsg("     |2version|r - Display the addon version");
	elseif (param1 == "options") then
		TippyGaryData:OpenInterfacePanel(TippyGaryData.InterfacePanel);
	elseif (param1 == "time") then
		TgMsg("|2Current session time:|r " .. TippyGaryData:GetSessionTimeElapsed());
	elseif (param1 == "version") then
		TgMsg("|1TippyGary|r Version " .. tgVersion .. "  |2<" .. tgLastUpdated .. ">|r");
	elseif (param1 == "clear") then
		TippyGaryDB = nil;
		TippyGaryData:InitDB();
		TgMsg("|1TippyGary:|r Cleared all arena games!");
	elseif (param1 == "hist") then
		TippyGaryBrowser:Show();
	elseif (param1 == "stats") then
		TippyGaryStatsBrowser:Show();
	elseif (param1 == "test") then
		
	
	end
end





--------------------------------------------------------------------------------------------------------
--    Event Hooks    -----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

tg:RegisterEvent("PVP_RATED_STATS_UPDATE");
tg:RegisterEvent("NAME_PLATE_UNIT_ADDED");
tg:RegisterEvent("PLAYER_ENTERING_WORLD");
tg:RegisterEvent("PLAYER_LOGOUT");
tg:RegisterEvent("PVP_MATCH_COMPLETE");
tg:RegisterEvent("ARENA_OPPONENT_UPDATE");
tg:RegisterEvent("GROUP_ROSTER_UPDATE");
tg:SetScript("OnEvent", handleEvents);




--
-- 0.1 -- 08/15/2022 -- added stats to conquest tooltip
--
-- 0.2 -- 08/16/2022 -- modified default nameplates / raid target icons
--
-- 0.3 -- 08/17/2022 -- added interface panel for adjusting options
--
-- 0.4 -- 08/23/2022 -- added session time tracking. started on arena game data logger
--
-- 0.5 -- 08/27/2022 -- finished arena history logger and initial browser window
--
-- 0.6 -- 08/28/2022 -- disabled skirmish tracking, added spec icons + option to show player names
--
-- 0.7 -- 09/29/2022 -- disabled solo shuffle tracking, added match details, added session stats to conquest tooltip
--					 




-- FUTURE:

-- add win % to pvp stats on conq tooltip

-- show rated pvp highest rating + item level for other players on tooltips

-- (organized by "session" -- treeview)

-- save all possible game details at 15 second mark (friendlies, opponents, map)

-- create handler for early leave (when pvp_match_complete is not triggered)