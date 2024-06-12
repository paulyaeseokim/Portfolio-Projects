------------------
--Data Exploration

SELECT * 
FROM leaguematches

------------------------------------------------------------------
--Overall Win Rate for Blue and Red Teams:

SELECT 
    'Blue Team' AS team,
    COUNT(*) AS total_games,
    SUM(CASE WHEN blueWins = 1 THEN 1 ELSE 0 END) AS wins, 
    SUM(CASE WHEN blueWins = 0 THEN 1 ELSE 0 END) AS losses,
    ROUND((SUM(CASE WHEN blueWins = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS win_rate
FROM 
    leaguematches
UNION ALL
SELECT 
    'Red Team' AS team,
    COUNT(*) AS total_games,
    SUM(CASE WHEN redWins = 1 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN redWins = 0 THEN 1 ELSE 0 END) AS losses,
    ROUND((SUM(CASE WHEN redWins = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS win_rate
FROM 
    leaguematches;

--The win rate is around 50% for both the Blue and Red Team, as expected.
-------------------------------------------------------------------------

------------------------------------------
--Win Rate Variation based on First Baron:

WITH BaronStatus AS (
    SELECT 
        CASE 
            WHEN blueFirstBaron = 1 THEN 'Blue With Baron' 
            ELSE 'Blue Without Baron' 
        END AS baron_status,
        blueWins AS wins,
        1 AS game_count
    FROM 
        leaguematches

    UNION ALL

    SELECT 
        CASE 
            WHEN redFirstBaron = 1 THEN 'Red With Baron' 
            ELSE 'Red Without Baron' 
        END AS baron_status,
        redWins AS wins,
        1 AS game_count
    FROM 
        leaguematches
)

SELECT 
    baron_status,
    COUNT(*) AS total_games,
    SUM(wins) AS wins,
    ROUND((SUM(wins) * 100.0) / SUM(game_count), 2) AS win_rate
FROM 
    BaronStatus
GROUP BY 
    baron_status
ORDER BY 
	baron_status;

--Securing the first Baron buff does correlate with higher win rates.
---------------------------------------------------------------------

------------------------------------------------------------
--Average Kills, Deaths, and Assists for Blue and Red Teams:

SELECT 
    'Blue Team' AS team,
    AVG(blueKills) AS avg_kills,
    AVG(blueDeath) AS avg_deaths,
    AVG(blueAssist) AS avg_assists
FROM 
    leaguematches

UNION ALL

SELECT 
    'Red Team' AS team,
    AVG(redKills) AS avg_kills,
    AVG(redDeath) AS avg_deaths,
    AVG(redAssist) AS avg_assists
FROM 
    leaguematches;

--On average, there is a balance in kills, deaths, and assists between the Blue and Red teams.
----------------------------------------------------------------------------------------------

---------------------------------------------------------------------------
--Correlation between Champion Damage Dealt, Total Gold, and Winning Games:

WITH TeamStats AS (
    SELECT 
        'Blue Team' AS team,
        AVG(CASE WHEN blueWins = 1 THEN blueChampionDamageDealt ELSE 0 END) AS avg_damage_winning,
        AVG(CASE WHEN blueWins = 0 THEN blueChampionDamageDealt ELSE 0 END) AS avg_damage_losing,
        AVG(CASE WHEN blueWins = 1 THEN blueTotalGold ELSE 0 END) AS avg_gold_winning,
        AVG(CASE WHEN blueWins = 0 THEN blueTotalGold ELSE 0 END) AS avg_gold_losing
    FROM 
        leaguematches

    UNION ALL

    SELECT 
        'Red Team' AS team,
        AVG(CASE WHEN redWins = 1 THEN redChampionDamageDealt ELSE 0 END) AS avg_damage_winning,
        AVG(CASE WHEN redWins = 0 THEN redChampionDamageDealt ELSE 0 END) AS avg_damage_losing,
        AVG(CASE WHEN redWins = 1 THEN redTotalGold ELSE 0 END) AS avg_gold_winning,
        AVG(CASE WHEN redWins = 0 THEN redTotalGold ELSE 0 END) AS avg_gold_losing
    FROM 
        leaguematches
)

SELECT 
    team,
    AVG(avg_damage_winning) AS avg_damage_winning,
    AVG(avg_damage_losing) AS avg_damage_losing,
    AVG(avg_gold_winning) AS avg_gold_winning,
    AVG(avg_gold_losing) AS avg_gold_losing
FROM 
    TeamStats
GROUP BY 
    team;

--Teams that deal more champion damage and earn more gold on average tend to win more games.
--------------------------------------------------------------------------------------------

-----------------------------------------------------------------------
--Relationship between Destroying Towers/Kill Counts and Winning Games:

WITH TowerandKillCount AS (
    SELECT 
        'Blue Team' AS team,
        AVG(CASE WHEN blueWins = 1 THEN blueTowerKills ELSE 0 END) AS avg_tower_kills_winning,
        AVG(CASE WHEN blueWins = 0 THEN blueTowerKills ELSE 0 END) AS avg_tower_kills_losing,
        AVG(CASE WHEN blueWins = 1 THEN blueKills ELSE 0 END) AS avg_kills_winning,
        AVG(CASE WHEN blueWins = 0 THEN blueKills ELSE 0 END) AS avg_kills_losing
    FROM 
        leaguematches

    UNION ALL

    SELECT 
        'Red Team' AS team,
        AVG(CASE WHEN redWins = 1 THEN redTowerKills ELSE 0 END) AS avg_tower_kills_winning,
        AVG(CASE WHEN redWins = 0 THEN redTowerKills ELSE 0 END) AS avg_tower_kills_losing,
        AVG(CASE WHEN redWins = 1 THEN redKills ELSE 0 END) AS avg_kills_winning,
        AVG(CASE WHEN redWins = 0 THEN redKills ELSE 0 END) AS avg_kills_losing
    FROM 
        leaguematches
)

SELECT 
    team,
    AVG(avg_tower_kills_winning) AS avg_tower_kills_winning,
    AVG(avg_tower_kills_losing) AS avg_tower_kills_losing,
    AVG(avg_kills_winning) AS avg_kills_winning,
    AVG(avg_kills_losing) AS avg_kills_losing
FROM 
    TowerandKillCount
GROUP BY 
    team;

--Teams that secure more tower kills and higher kill counts tend to have higher win rates.
------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--Correlation between Objective Control (Dragon, Baron kills) and Winning Games:
WITH ObjectiveControl AS (
    SELECT 
        blueWins AS win_status,
        blueDragonKills AS dragon_kills,
        blueBaronKills AS baron_kills
    FROM 
        leaguematches

    UNION ALL

    SELECT 
        redWins AS win_status,
        redDragonKills AS dragon_kills,
        redBaronKills AS baron_kills
    FROM 
        leaguematches
)

SELECT 
    dragon_kills,
    baron_kills,
    COUNT(*) AS total_games,
    SUM(CASE WHEN win_status = 1 THEN 1 ELSE 0 END) AS wins,
    ROUND((SUM(CASE WHEN win_status = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS win_rate
FROM 
    ObjectiveControl
GROUP BY 
    dragon_kills, baron_kills
ORDER BY 
    dragon_kills, baron_kills;

--There is a clear correlation between objective control (Dragon and Baron kills) and winning games.
----------------------------------------------------------------------------------------------------