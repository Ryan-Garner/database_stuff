-- Ryan Garner 
-- a01049413

-- Query 1 LA Dodgers
-- List first and last name of every player that has ever
-- played for the LA Dodger. Each player listed once.
SELECT DISTINCT nameFirst, nameLast
FROM MASTER m, teams t, appearances a
WHERE m.masterID = a.masterID AND t.teamID = a.teamID AND t.yearID = a.yearID AND t.lgID = a.lgID AND t.name = "Los Angeles Dodgers";

-- Query 2 LA Dodgers Only
-- List first and last name of every player that has only ever
-- played for the LA Dodgers. Each player listed once.
SELECT DISTINCT nameFirst, nameLast
FROM MASTER m JOIN teams t JOIN appearances a
ON m.masterID = a.masterID AND t.yearID = a.yearID 
	AND t.lgID = t.lgID AND t.teamID = a.teamID
WHERE t.name = "Los Angeles Dodgers" AND m.masterID NOT IN (SELECT DISTINCT m.masterID
															FROM MASTER m JOIN teams t JOIN appearances a
															ON m.masterID = a.masterID AND t.yearID = a.yearID 
															   AND t.lgID = t.lgID AND t.teamID = a.teamID
															WHERE t.name <> "Los Angeles Dodgers");
-- Query 3 Expo Pitchers
-- List the first name and last name of every player
-- that has pitched for the team named "Montreal Expos"
-- Each player listed once.
SELECT DISTINCT nameFirst, nameLast
FROM MASTER m JOIN teams t JOIN pitching p
ON m.masterID = p.masterID AND t.teamID = p.teamID AND t.yearID = p.yearID AND t.lgID = p.lgID
WHERE t.name = "Montreal Expos";
-- Query 4 Error Kings
-- List the name of the team, year, and number of errors 
-- for every team that has had 160 or more errors in a season
SELECT t.name, t.yearID, t.e
FROM teams t
WHERE t.e > 160;
-- Query 5 USU Batters
-- List the first name, last name, year played, and batting average
-- of every player from the school named "Utah State University".
SELECT DISTINCT nameFirst, nameLast, b.yearID, b.h/b.ab as Average
FROM MASTER m JOIN schoolsplayers p JOIN schools s JOIN batting b
ON m.masterID = b.masterID AND b.masterID = p.masterID
WHERE p.schoolID = s.schoolID AND s.schoolName = "Utah State University";
-- Query 6 Yankee Run Kings
-- List the name, year, and number of home runs hit for each New
-- York Yankee batter, but only if they hit the most home runs for any player in that season
SELECT m.nameFirst, m.nameLast, t.yearID, b.hr
FROM MASTER m JOIN batting b JOIN teams t JOIN  (SELECT t.yearID, MAX(b.hr) as topYear
												 FROM teams t JOIN batting b  
												 ON t.teamID = b.teamID AND t.yearID = b.yearID AND t.lgID = b.lgID
												 GROUP BY t.yearID) a
ON m.masterID = b.masterID AND t.teamID = b.teamID AND t.yearID = b.yearID AND t.lgID = b.lgID AND t.yearID = a.yearID
WHERE t.name = "New York Yankees" AND b.hr = a.topYear;
-- Query 7 Bumper Salary Teams
-- List the total salary for two consecutive years, team name, 
-- and year for every team that had a total salary which was 1.5 
-- times as much as for the previous year
SELECT r.TeamName, r.PreviousSalary, r.PreviousYear, r.CurrentSalary, r.CurrentYear
FROM (SELECT t1.name AS TeamName, SUM(t2.salary) AS PreviousSalary, t2.yearID AS PreviousYear, SUM(t1.salary) AS CurrentSalary, t1.yearID AS CurrentYear
	  FROM (SELECT t.yearID, t.name, SUM(s.salary) AS salary
	        FROM Salaries s JOIN teams t
		    ON s.teamID = t.teamID AND s.yearID = t.yearID
			GROUP BY t.yearID, t.name) t1 JOIN (SELECT t.yearID, t.name, SUM(s.salary) AS salary
												FROM Salaries s JOIN teams t
												ON s.teamID = t.teamID AND s.yearID = t.yearID
												GROUP BY t.yearID, t.name) t2
	  ON t1.name = t2.name AND t1.yearID - t2.yearID = 1
	  GROUP BY t1.name, t2.name, t1.yearID, t2.yearID) r
WHERE r.CurrentSalary >= 1.5*r.PreviousSalary;
-- Query 8 Montreal Expos Three
-- List the first name and last name of every player that has batted 
-- for the Montreal Expos in at least three consecutive years. List 
-- each player only once.
SELECT DISTINCT
    m.nameFirst, m.nameLast
FROM
    MASTER m
        JOIN
    (SELECT 
        b.masterID, t.yearID
    FROM
        batting b
    JOIN teams t ON b.teamID = t.teamID
        AND b.yearID = t.yearID
        AND b.lgID = t.lgID
    WHERE
        t.name = 'Montreal Expos') y1
        JOIN
    (SELECT 
        b.masterID, t.yearID
    FROM
        batting b
    JOIN teams t ON b.teamID = t.teamID
        AND b.yearID = t.yearID
        AND b.lgID = t.lgID
    WHERE
        t.name = 'Montreal Expos') y2
        JOIN
    (SELECT 
        b.masterID, t.yearID
    FROM
        batting b
    JOIN teams t ON b.teamID = t.teamID
        AND b.yearID = t.yearID
        AND b.lgID = t.lgID
    WHERE
        t.name = 'Montreal Expos') y3 ON m.masterID = y1.masterID
        AND m.masterID = y2.masterID
        AND m.masterID = y3.masterID
        AND y1.yearID = y2.yearID - 1
        AND y2.yearID = y3.yearID - 1;
-- Query 9 Home Run Kings
-- List the first name, last name, year, and number of HRs of every 
-- player that has hit the most home runs in a single season. Order 
-- by the year. Note that the "batting" table has a column "HR" with 
-- the number of home runs hit by a player in that year. 
SELECT m.nameFirst, m.nameLast, t.yearID, b.hr
FROM MASTER m JOIN batting b JOIN teams t JOIN  (SELECT t.yearID, MAX(b.hr) as topYear
												 FROM teams t JOIN batting b  
												 ON t.teamID = b.teamID AND t.yearID = b.yearID AND t.lgID = b.lgID
												 GROUP BY t.yearID) a
ON m.masterID = b.masterID AND t.teamID = b.teamID AND t.yearID = b.yearID AND t.lgID = b.lgID AND t.yearID = a.yearID
WHERE b.hr = a.topYear;
-- Query 10 Third best home runs each year
-- List the first name, last name, year, and number of HRs of every 
-- player that hit the third most home runs for that year. Order by 
-- the year
select *
from (

select 
    b.yearID as year,
    b.teamID as team,
    m.nameFirst as first,
    m.nameLast as last,
    find_in_set(b.HR, x.teamRank) as rank,
    b.HR as HR


from 
    Batting b
    inner join Master m on m.masterID = b.masterID
    inner join (select yearID, group_concat(distinct HR order by HR desc) as teamRank from Batting group by yearID) x on x.yearID = b.yearID

) x
where 
    rank = 3;  
-- Query 11 Triple Happy Teammates
-- List the team name, year, names of player, the number of triples hit 
-- (column "3B" in the batting table), in which two or more players on the 
-- same team hit 10 or more triples each.
SELECT DISTINCT p1.yearID, p1.name, p1.nameFirst, p1.nameLast, p1.3b, p2.nameFirst, p2.nameLast, p2.3b
FROM (SELECT t.name, t.yearID, m.nameFirst, m.nameLast, b.3b
	  FROM Master m JOIN batting b JOIN teams t
	  ON m.masterID = b.masterID AND b.teamID = t.teamID AND b.yearID = t.yearID AND b.lgID = t.lgID 
	  WHERE b.3b > 10) p1 JOIN (SELECT t.name, t.yearID, m.nameFirst, m.nameLast, b.3b
								FROM Master m JOIN batting b JOIN teams t
								ON m.masterID = b.masterID AND b.teamID = t.teamID AND b.yearID = t.yearID AND b.lgID = t.lgID 
								WHERE b.3b > 10) p2
ON p1.yearID = p2.yearID AND p1.name = p2.name 
WHERE p1.nameLast <> p2.nameLast;
-- Query 12 Ranking the teams
-- Rank each team in terms of the winning percentage (wins divided by 
-- (wins + losses)) over its entire history. Consider a "team" to be a team 
-- with the same name, so if the team changes name, it is considered to be two 
-- different teams. Show the team name, win percentage, and the rank.
SELECT t.name,  t.w/(t.w+t.l) AS WinPercentage, t.w, t.l, FIND_IN_SET( t.w/(t.w+t.l), (
SELECT GROUP_CONCAT( t.w/(t.w+t.l)
ORDER BY t.w/(t.w+t.l) DESC ) 
FROM teams t )
) AS rank
FROM teams t;
-- Query 13 Pitchers for Mangaer Casey Stengel
-- List the year, first name, and last name of each pitcher who was a on 
-- a team managed by Casey Stengel (pitched in the same season on a team 
-- managed by Casey).
SELECT DISTINCT c.name, a.yearID, m.nameFirst, m.nameLast, c.nameFirst, c.nameLast
FROM MASTER m JOIN appearances a JOIN (SELECT t.name, t.yearID, t.teamID, t.lgID, m.nameFirst, m.nameLast
										FROM MASTER m JOIN managers man JOIN teams t
										ON man.masterID = m.masterID AND man.teamID = t.teamID AND man.yearID = t.yearID AND man.lgID = t.lgID
										WHERE m.nameFirst = "Casey" AND m.nameLast = "Stengel") c JOIN pitching p
ON m.masterID = a.masterID AND a.masterID = p.masterID AND a.teamID = c.teamID AND a.yearID = c.yearID AND a.lgID = c.lgID
WHERE a.teamID = p.teamID AND p.yearID = a.yearID AND p.lgID = a.lgID;
-- Query 14 Two degrees from Yogi Berra
-- List the name of each player who appeared on a team with a player that was 
-- at one time was a teamate of Yogi Berra. So suppose player A was a teamate 
-- of Yogi Berra. Then player A is one-degree of separation from Yogi Berra. 
-- Let player B be related to player A because A played on a team in the same 
-- year with player A. Then player A is two-degrees of separation from player A.
SELECT DISTINCT m.nameFirst, m.nameLast
FROM MASTER m JOIN (SELECT DISTINCT a.masterID
					FROM appearances a JOIN (SELECT a.teamID, a.yearID, a.lgID, a.masterID
										FROM appearances a JOIN (SELECT DISTINCT a.masterID
										FROM MASTER m JOIN appearances a JOIN (SELECT t.teamID, t.yearID, t.lgID, t.name
										FROM MASTER m JOIN teams t JOIN appearances a
										ON m.masterID = a.masterID AND t.teamID = a.teamID AND t.yearID = a.yearID AND a.lgID = t.lgID
										WHERE m.nameFirst = "Yogi" AND m.nameLast = "Berra") y
										ON m.masterID = a.masterID AND a.teamID = y.teamID AND a.yearID = y.yearID AND a.lgID = y.lgID
										WHERE m.nameFirst <> "Yogi" AND m.nameLast <> "Berra") yt
										ON a.masterID = yt.masterID) h
										ON h.teamID = a.teamID and h.yearID = a.yearID and a.lgID = h.lgID) a
ON m.masterID = a.masterID
WHERE a.masterID NOT IN (SELECT DISTINCT a.masterID
						 FROM MASTER m JOIN appearances a JOIN (SELECT t.teamID, t.yearID, t.lgID, t.name
										FROM MASTER m JOIN teams t JOIN appearances a
										ON m.masterID = a.masterID AND t.teamID = a.teamID AND t.yearID = a.yearID AND a.lgID = t.lgID
										WHERE m.nameFirst = "Yogi" AND m.nameLast = "Berra") y
										ON m.masterID = a.masterID AND a.teamID = y.teamID AND a.yearID = y.yearID AND a.lgID = y.lgID
WHERE m.nameFirst <> "Yogi" AND m.nameLast <> "Berra");
-- Query 15 Median team wins
-- For the 1970s, list the team name for teams in the National League ("NL") 
-- that had the median number of total wins in the decade (1970-1979 inclusive).
SELECT x.TotalWins, x.name
FROM (SELECT t.name, sum(t.w) AS TotalWins
		FROM teams t, teams b
		WHERE t.yearID >= 1970 AND t.yearID <= 1979
		GROUP BY t.name) x, (SELECT t.name, sum(t.w) AS TotalWins
							 FROM teams t, teams b
							 WHERE t.yearID >= 1970 AND t.yearID <= 1979
							 GROUP BY t.name) y
GROUP BY x.TotalWins
HAVING SUM(SIGN(1-SIGN(y.TotalWins-x.TotalWins))) = (COUNT(*)
+1)/2