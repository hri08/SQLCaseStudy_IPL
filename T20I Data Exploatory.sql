-- 1. Identify mateches played between two specific teams; India and South Africa, in 2024 and their results.

Select *
From T20I
Where ((Team1= 'India' AND Team2 = 'South Africa') OR (Team1= 'South Africa' AND Team2 = 'India'))
AND YEAR(MatchDate) = 2024

Select *
From T20I
Where ((Team1= 'India' AND Team2 = 'South Africa') OR (Team1= 'South Africa' AND Team2 = 'India'))
AND YEAR(MatchDate) = 2023

-- 2. Find the team with the highest no. of wins in 2024 and the total matches it won.
Select *
From T20I

SELECT TOP 1 Winner, COUNT(*) AS 'NumOfWins'
FROM T20I
WHERE YEAR(MatchDate) = 2024
GROUP BY Winner
ORDER BY 'NumOfWins' DESC 

-- 3. Rank the team based on the total no. of wins in 2024.
SELECT Winner, COUNT(*) AS 'NumOfWins', Rank() OVER (ORDER BY COUNT(*) DESC) as RankAssigned
FROM T20I
WHERE YEAR(MatchDate) = 2024
GROUP BY Winner
 
SELECT Winner, COUNT(*) AS 'NumOfWins', DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as RankAssigned
FROM T20I
WHERE YEAR(MatchDate) = 2024 AND Winner NOT IN ('tied', 'no result')
GROUP BY Winner

-- 4.  Which team had the highest average winning margin (in runs), and what was the average margin?

SELECT Winner, AVG(CAST(SUBSTRING(Margin,1,CHARINDEX(' ', Margin) - 1) AS INT)) AS Avg_Margin
FROM T20I
WHERE Margin LIKE '%runs'
GROUP BY Winner
ORDER BY Avg_Margin DESC;


SELECT Top 1 Winner, AVG(CAST(SUBSTRING(Margin,1,CHARINDEX(' ', Margin) - 1) AS INT)) AS Avg_Margin
FROM T20I
WHERE Margin LIKE '%runs'
GROUP BY Winner
ORDER BY Avg_Margin DESC;

-- 5.  Which team had the highest average winning margin (in wickets), and what was the average margin?

SELECT Top 1 Winner, AVG(CAST(SUBSTRING(Margin,1,CHARINDEX(' ', Margin) - 1) AS INT)) AS Avg_Margin
FROM T20I
WHERE Margin LIKE '%wickets'
GROUP BY Winner
ORDER BY Avg_Margin DESC;

-- 6. List all the matches where the winning margin was greater than the average margin across all matches.

WITH CTE_AvgMargin AS
(
	SELECT  AVG(CAST(SUBSTRING(Margin,1,CHARINDEX(' ', Margin) - 1) AS INT)) AS Avg_OverAllMargin
	FROM T20I
	WHERE Margin LIKE '%runs'
)
SELECT T.Team1, T.Team2, T.Winner, T.Margin
FROM T20I T
LEFT JOIN CTE_AvgMargin A ON 1 = 1
WHERE T.Margin LIKE '%runs'
AND (CAST(SUBSTRING(Margin,1,CHARINDEX(' ', Margin) - 1) AS INT)) > A.Avg_OverAllMargin;

-- 7. Find the team with the most wins when chasing a target (wins by wickets)
SELECT *
FROM T20I


SELECT Winner, WinWhileChasing
FROM(
		SELECT Winner, COUNT(*) AS WinWhileChasing,
	    RANK() OVER(ORDER BY COUNT(*) DESC) AS rk
		FROM T20I
		WHERE Margin LIKE '%wickets'
		AND Winner NOT IN ('tied', 'no result')
		GROUP BY Winner) t
WHERE rk = 1


















































































































