---------------------------------------------------------------------------------------------------------------------
-- TippyGary Arena Stats
---------------------------------------------------------------------------------------------------------------------

local tgas = {};
tgas.GetMapStats = function(self, mapName)
	local allGames = _G["TippyGaryDB"].ArenaGames;
	local agPlayed = 0;
	local winsAll = 0;
	local wins2v2 = 0;
	local wins3v3 = 0;
	local lossAll = 0;
	local loss2v2 = 0;
	local loss3v3 = 0;
	
	
	for i,g in ipairs(allGames) do
		agPlayed = agPlayed + 1;
	
		-- Get match result for each game played on {mapName}
		if(g.mapName == mapName) then
			-- Record "All" value
			if(g.matchResult == "W") then
				winsAll = winsAll + 1;
			else
				lossAll = lossAll + 1;
			end
			if(g.arenaType == "2v2") then
				-- Record "2v2" value
				if(g.matchResult == "W") then
					wins2v2 = wins2v2 + 1;
				else
					loss2v2 = loss2v2 + 1;
				end
			elseif(g.arenaType == "3v3") then
				-- Record "3v3" value
				if(g.matchResult == "W") then
					wins3v3 = wins3v3 + 1;
				else
					loss3v3 = loss3v3 + 1;
				end
			end
		end
	end
	
	-- Get the sum of all games played on {mapName}
	local totalAll = winsAll + lossAll;
	local total2v2 = wins2v2 + loss2v2;
	local total3v3 = wins3v3 + loss3v3;
	
	-- Determine the play rate of {mapName}
	local playRate = "0%";
	local prpFloat = tostring((totalAll / agPlayed) * 100);
	local prpDec = string.find(prpFloat, ".", 1, true);
	if(prpDec ~= nil) then
		local prpNbd = tonumber(string.sub(prpFloat, 1, prpDec-1));
		local prpNad = tonumber(string.sub(prpFloat, prpDec, prpDec+1));
		if(prpNad == 0) then
			playRate = prpNbd .. "%";
		else
			playRate = string.sub(prpFloat, 1, prpDec+1) .. "%";
		end
	else
		playRate = prpFloat .. "%";
	end
	
	
	-- Return all map stats
	local mapStats = {
		Total_Played = agPlayed,
		Total_Percent = playRate,
		Total_All = totalAll,
		Total_2v2 = total2v2,
		Total_3v3 = total3v3,
		Wins_All = winsAll,
		Wins_2v2 = wins2v2,
		Wins_3v3 = wins3v3,
		Loss_All = lossAll,
		Loss_2v2 = loss2v2,
		Loss_3v3 = loss3v3
	};
	
	return mapStats;
end

tgas.GetMatchDuration = function(self, md)
	local stt = SecondsToTime;
	local secsDuration = md.timeEnded - md.timeEntered;
	local gameDuration = stt(secsDuration);
	return gameDuration;
end

tgas.GetTeamRecord = function(self, tp)
	local ag = _G["TippyGaryDB"].ArenaGames;
	local teamGames = 0;
	local teamWins = 0;
	local teamLoss = 0;
	local mt = #tp .. "v" .. #tp;
	local cs = (type(tp[1]) == "table");
	
	for gi,gv in ipairs(ag) do
		if(gv.arenaType == mt) then
			local isTeamGame = false;
			local itgNum = 0;
			for fi,fv in ipairs(gv.arenaFriendlies) do
				for ti,tv in ipairs(tp) do
					if cs then
						-- match class spec
						if(tv.class == fv.Class and tv.spec == fv.Spec) then
							itgNum = itgNum + 1;
						end
					else
						if(tv == fv.Name) then
							itgNum = itgNum + 1;
						end
					end
				end
			end
			if(itgNum == #tp) then 
				isTeamGame = true;
			end
			if isTeamGame then
				teamGames = teamGames + 1;
				if(gv.matchResult == "W") then
					teamWins = teamWins + 1;
				else
					teamLoss = teamLoss + 1;
				end
			end
		end
	end
	
	local tSpread = teamWins - teamLoss;
	local trsc = "|cffffffff";
	local trss = "";
	if(tSpread > 0) then
		trsc = "|cff00ff00";
		trss = "+";
	elseif(tSpread < 0) then
		trsc = "|cffff0000";
	end
	local teamSpread = trsc .. trss .. tSpread .. "|r";
	
	return teamGames, teamWins, teamLoss, teamSpread;
end

tgas.GetOpponentRecord = function(self, tp)
	local ag = _G["TippyGaryDB"].ArenaGames;
	local teamGames = 0;
	local teamWins = 0;
	local teamLoss = 0;
	local mt = #tp .. "v" .. #tp;
	local cs = (type(tp[1]) == "table");
	
	for gi,gv in ipairs(ag) do
		if(gv.arenaType == mt) then
			local isTeamGame = false;
			local itgNum = 0;
			local pmfi = {};
			local pmoi = {};
			for fi,fv in ipairs(gv.arenaOpponents) do
				for ti,tv in ipairs(tp) do
					if cs then
						-- match class spec
						if(tv.class == fv.Class and tv.spec == fv.Spec) then
							if (tContains(pmoi, ti) == false) and (tContains(pmfi, fi) == false) then
								tinsert(pmfi, fi);
								tinsert(pmoi, ti);
								itgNum = itgNum + 1;
							end
						end
					else
						if(tv == fv.Name) then
							itgNum = itgNum + 1;
						end
					end
				end

				
			end
			if(itgNum == #tp) then
				isTeamGame = true;
			end
			if isTeamGame then
				teamGames = teamGames + 1;
				if(gv.matchResult == "W") then
					teamWins = teamWins + 1;
				else
					teamLoss = teamLoss + 1;
				end
			end
		end
	end
	
	local tSpread = teamWins - teamLoss;
	local trsc = "|cffffffff";
	local trss = "";
	if(tSpread > 0) then
		trsc = "|cff00ff00";
		trss = "+";
	elseif(tSpread < 0) then
		trsc = "|cffff0000";
	end
	local teamSpread = trsc .. trss .. tSpread .. "|r";
	
	return teamGames, teamWins, teamLoss, teamSpread;

end

tgas.GetSessionStats = function(self, agt)
	local ag = _G["TippyGaryDB"].ArenaGames;
	local csag = _G["TippyGaryDB"].CurrentSession.ArenaGames;
	local sessionWins = 0;
	local sessionGames = #csag;
	if agt then sessionGames = 0 end
	
	for i,k in ipairs(csag) do
		local sg = ag[k];
		if not agt then
			if(sg.matchResult == "W") then	
				sessionWins = sessionWins + 1;
			end
		else
			if(sg.arenaType == agt) then
				sessionGames = sessionGames + 1;
				if(sg.matchResult == "W") then	
					sessionWins = sessionWins + 1;
				end
			end
		end
	end
	
	local sessionLoss = sessionGames - sessionWins;
	return sessionGames, sessionWins, sessionLoss;
end

tgas.GetArenaSessions = function(self)
	local tdb = _G["TippyGaryDB"];
	local sessions = {};
	local fi = {};
	
	for i,s in ipairs(tdb.Sessions) do
		local sag = s.ArenaGames;
		if(#sag > 0) then 
			tinsert(sessions, s);
			tinsert(fi, i);
		end
	end
	
	return sessions, fi;
end

tgas.GetNumGamesPlayed = function(self, games)
	local ag = _G["TippyGaryDB"].ArenaGames;
	if games then ag = games end;
	local agAll = #ag;
	local ag2v2 = 0;
	local ag3v3 = 0;
	local winsAll = 0;
	local wins2v2 = 0;
	local wins3v3 = 0;
	local lossAll = 0;
	local loss2v2 = 0;
	local loss3v3 = 0;
	
	for i,v in ipairs(ag) do
		if(v.matchResult == "W") then
			winsAll = winsAll + 1;
		else
			lossAll = lossAll + 1;
		end
		
		if(v.arenaType == "2v2") then
			ag2v2 = ag2v2 + 1;
			if(v.matchResult == "W") then
				wins2v2 = wins2v2 + 1;
			else
				loss2v2 = loss2v2 + 1;
			end
			
		elseif(v.arenaType == "3v3") then
			ag3v3 = ag3v3 + 1;
			if(v.matchResult == "W") then
				wins3v3 = wins3v3 + 1;
			else
				loss3v3 = loss3v3 + 1;
			end
		end
		
		-- 3v3 games played
	end
	
	local result = {
		["All"] = {
			["Games"] = agAll,
			["Won"] = winsAll,
			["WP"] = "  (" .. string.format("%.1f", (winsAll / agAll * 100)) .. "%)",
			["Lost"] = lossAll,
			["LP"] = "  (" .. string.format("%.1f", (lossAll / agAll * 100)) .. "%)"
		},
		["2v2"] = {
			["Games"] = ag2v2,
			["Won"] = wins2v2,
			["WP"] = "  (" .. string.format("%.1f", (wins2v2 / ag2v2 * 100)) .. "%)",
			["Lost"] = loss2v2,
			["LP"] = "  (" .. string.format("%.1f", (loss2v2 / ag2v2 * 100)) .. "%)"
		},
		["3v3"] = {
			["Games"] = ag3v3,
			["Won"] = wins3v3,
			["WP"] = "  (" .. string.format("%.1f", (wins3v3 / ag3v3 * 100)) .. "%)",
			["Lost"] = loss3v3,
			["LP"] = "  (" .. string.format("%.1f", (loss3v3 / ag3v3 * 100)) .. "%)"
		}
	};
	return result;
end

tgas.GetGamesPlayedWith = function(self, noc, spec)
	-- GetGamesPlayedWith(arenaPlayer|"class" [,"spec" ])

	local ag = _G["TippyGaryDB"].ArenaGames;
	local nc = type(noc);
	
	if(nc == "table") then
		local pwnGames, pwnWins, pwnLoss = 0, 0, 0;
		local panGames, panWins, panLoss = 0, 0, 0;
		local pwcGames, pwcWins, pwcLoss = 0, 0, 0;
		local pacGames, pacWins, pacLoss = 0, 0, 0;
		local pwsGames, pwsWins, pwsLoss = 0, 0, 0;
		local pasGames, pasWins, pasLoss = 0, 0, 0;
		
		for gi,gv in ipairs(ag) do
			for fi,fv in ipairs(gv.arenaFriendlies) do
				-- Get games played with player Name
				if(fv.Name == noc.Name) then
					pwnGames = pwnGames + 1;
					if(gv.matchResult == "W") then
						pwnWins = pwnWins + 1;
					else
						pwnLoss = pwnLoss + 1;
					end
				end
				
				-- Get games played with player Class
				if(fv.Class == noc.Class) then
					pwcGames = pwcGames + 1;
					if(gv.matchResult == "W") then
						pwcWins = pwcWins + 1;
					else
						pwcLoss = pwcLoss + 1;
					end
					
					-- Get games played with player Spec
					if(fv.Spec == noc.Spec) then
						pwsGames = pwsGames + 1;
						if(gv.matchResult == "W") then
							pwsWins = pwsWins + 1;
						else
							pwsLoss = pwsLoss + 1;
						end
					end
				end
			end
			
			for oi,ov in ipairs(gv.arenaOpponents) do
				-- Get games played against player Name
				if(ov.Name == noc.Name) then
					panGames = panGames + 1;
					if(gv.matchResult == "W") then
						panWins = panWins + 1;
					else
						panLoss = panLoss + 1;
					end
				end
				
				-- Get games played against player Class
				if(ov.Class == noc.Class) then
					pacGames = pacGames + 1;
					if(gv.matchResult == "W") then
						pacWins = pacWins + 1;
					else
						pacLoss = pacLoss + 1;
					end
					
					-- Get games played against player Spec
					if(ov.Spec == noc.Spec) then
						pasGames = pasGames + 1;
						if(gv.matchResult == "W") then
							pasWins = pasWins + 1;
						else
							pasLoss = pasLoss + 1;
						end
					end
				end
			end
		end
		
		-- Consolidate results into a table and return
		local results = {
			["ByName"] = {},
			["ByClass"] = {},
			["BySpec"] = {}
		};
		if(pwnGames > 0) then
			results.ByName.TeamGames = pwnGames;
			results.ByName.TeamWins = pwnWins;
			results.ByName.TeamLoss = pwnLoss;
		end
		if(pwcGames > 0) then
			results.ByClass.TeamGames = pwcGames;
			results.ByClass.TeamWins = pwcWins;
			results.ByClass.TeamLoss = pwcLoss;
		end
		if(pwsGames > 0) then
			results.BySpec.TeamGames = pwsGames;
			results.BySpec.TeamWins = pwsWins;
			results.BySpec.TeamLoss = pwsLoss;
		end
		if(panGames > 0) then
			results.ByName.EnemyGames = panGames;
			results.ByName.EnemyWins = panWins;
			results.ByName.EnemyLoss = panLoss;
		end
		if(pacGames > 0) then
			results.ByClass.EnemyGames = pacGames;
			results.ByClass.EnemyWins = pacWins;
			results.ByClass.EnemyLoss = pacLoss;
		end
		if(pasGames > 0) then
			results.BySpec.EnemyGames = pasGames;
			results.BySpec.EnemyWins = pasWins;
			results.BySpec.EnemyLoss = pasLoss;
		end
		return results;
		
	elseif(nc == "string") then
		
		-- Get games played with & against {class/spec}
		for gi,gv in ipairs(ag) do
			for fi,fv in ipairs(gv.arenaFriendlies) do
				
			end
			for oi,ov in ipairs(gv.arenaOpponents) do
				
			end
		end
	else
		-- Error: Invalid parameters
		return false;
	end
end

_G["TippyGaryData"].ArenaStats = tgas;



-- longest win streak
-- longest loss streak

-- longest game
-- shortest game