SELECT *
FROM IPLPlayers;



-- 1. Find the total spending on players for each team.

SELECT Team, Sum(price_in_cr) AS 'Total spending'
FROM IPLPlayers
Group by Team
order by 'Total Spending' DESC

-- 2. Find the top three highest paid 'All-rounders' across all teams.

SELECT TOP 3 Player, Team, Price_in_cr
FROM IPLPlayers
WHERE Role= 'All-rounder'
ORDER BY Price_in_cr DESC

-- 3. Find the highest-priced player in each team.
SELECT *
FROM IPLPlayers
ORDER BY Price_in_cr DESC;


WITH CTE_MP AS (
	SELECT Team, Max(Price_in_cr) as MAXPRICE
	FROM IPLPlayers
	GROUP BY Team
)
SELECT i.Team, i.Player, c.MAXPRICE
FROM IPLPlayers i
JOIN CTE_MP c 
ON i.Team =c.Team
WHERE i.Price_in_cr = c.MAXPRICE

-- 4. Rank players by their price within each team and list the top 2 for every team.

SELECT *
FROM IPLPlayers
ORDER BY Team;


WITH Rankedplayers AS
(
	SELECT Player, Team, Price_in_cr,
	ROW_NUMBER() OVER(PARTITION BY Team ORDER BY Price_in_cr DESC) AS RankWithinTeam
	FROM IPLPlayers
)
SELECT Player, Team, Price_in_cr, RankWithinTeam
FROM Rankedplayers
WHERE RankWithinTeam <= 2

-- 5. Find the most expensiveplayer from each team, along with second most expensice player'name and price.

WITH Rankedplayers AS
(
	SELECT Player, Team, Price_in_cr,
	ROW_NUMBER() OVER(PARTITION BY Team ORDER BY Price_in_cr DESC) AS RankWithinTeam
	FROM IPLPlayers
)

SELECT Team, 
	MAX(CASE WHEN RankWithinTeam = 1 THEN Player END) AS MostExpensivePlayer,
	MAX(CASE WHEN RankWithinTeam = 1 THEN Price_in_cr END) AS MostHighestPriced,
	MAX(CASE WHEN RankWithinTeam = 2 THEN Player END) AS SecondMostExpensivePlayer,
	MAX(CASE WHEN RankWithinTeam = 2 THEN Price_in_cr END) AS SecondMostHighestPriced
FROM Rankedplayers
GROUP BY Team


-- 6. Calculate the percentage contribution of each player's price to their team's total spending.
Select Player, Team, Price_in_cr,
	(Price_in_cr/ SUM(Price_in_cr) OVER (PARTITION BY Team)) * 100 AS ContributionPercentage
FROM IPLPlayers;


Select Player, Team, Price_in_cr,
	CAST(Price_in_cr/ (SUM(Price_in_cr) OVER (PARTITION BY Team)) * 100 AS DECIMAL(10,2)) AS ContributionPercentage
FROM IPLPlayers


-- 7. Clasify players as 'High', 'Medium', or 'Low' priced based on the following:
--- High: Price > 15/- Cr
--- Medium: Price Between 5/- Cr to 15/- Cr
--- Low: Price < 5/- Cr
--- Find out the number of players in each bracket.

SELECT Team, Player, Price_in_cr,
CASE
	WHEN Price_in_cr > 15 THEN 'High'
	WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'Medium'
	Else 'Low'
END AS Category
FROM IPLPlayers;




WITH CTE_BR AS
(
	SELECT Team, Player, Price_in_cr,
	CASE
		WHEN Price_in_cr > 15 THEN 'High'
		WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'Medium'
		Else 'Low'
	END AS Category
	FROM IPLPlayers
)

SELECT Team, Category, COUNT(*) AS 'Numofplayers'
FROM CTE_BR
GROUP BY Team, Category
ORDER BY Team, Category

-- 8. Find the average price of Indian players and compare it with the overseas players using a subquery.

SELECT *
FROM IPLPlayers

SELECT
	'Indian' AS PlayerType,
	(SELECT AVG(Price_in_cr) 
	FROM IPLPlayers
	WHERE Type LIKE 'Indian%') AS AvgPricePlayers
UNION ALL
SELECT
	'Overseas' AS PlayerType,
	(SELECT AVG(Price_in_cr) 
	FROM IPLPlayers
	WHERE Type LIKE 'Overseas%') AS AvgPricePlayers


	-- 9. Identify players who earn more than the average price in their team.

	SELECT Player, Team, Price_in_cr
	FROM IPLPlayers p
	WHERE Price_in_cr > (
			SELECT AVG(Price_in_cr)
			FROM IPLPlayers
			WHERE Team = p.Team)


-- 10. For each role, find the most explensive player and the price for that player using a correlated subquery.

	SELECT Player, Team, Role, Price_in_cr
	FROM IPLPlayers p
	WHERE Price_in_cr = (
			SELECT MAX(Price_in_cr)
			FROM IPLPlayers
			WHERE Role = p.Role)
























































































































