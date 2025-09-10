-- Load CSVs into DuckDB as views
CREATE OR REPLACE VIEW team_style_features_clustered AS
SELECT * FROM read_csv_auto('C:/Users/chave/OneDrive/Desktop/soccer-team-styles/data/processed/team_style_features.csv', HEADER=TRUE);


CREATE OR REPLACE VIEW team_match_tidy AS
SELECT * FROM read_csv_auto(
    'C:/Users/chave/OneDrive/Desktop/soccer-team-styles/data/processed/team_match_tidy.csv', HEADER=TRUE);

-- Top 10 teams by points per game
SELECT league, season, team, ROUND(pts_per_game,3) AS pts_pg
FROM team_style_features_clustered
WHERE season = '2014/2015'
ORDER BY pts_pg DESC
LIMIT 10;

-- Average cluster performance
SELECT cluster,
       COUNT(*)                   AS teams,
       ROUND(AVG(pts_per_game),3) AS avg_pts_pg,
       ROUND(AVG(gd_per_game),3)  AS avg_gd_pg
FROM team_style_features_clustered
GROUP BY cluster
ORDER BY avg_pts_pg DESC;


--  Top scoring teams per league & season
SELECT league, season, team, SUM(goals_for) AS total_goals
FROM team_match_tidy
GROUP BY league, season, team
ORDER BY league, season, total_goals DESC;

-- Defensive strength: Teams with lowest goals conceded per game
SELECT league, season, team,
       ROUND(AVG(goals_against),2) AS avg_ga
FROM team_match_tidy
GROUP BY league, season, team
ORDER BY avg_ga ASC
LIMIT 10;

-- Possession vs. points correlation (league-wide averages)
SELECT league, season,
       ROUND(AVG(possession),2) AS avg_possession,
       ROUND(AVG(pts_per_game),2) AS avg_pts_pg
FROM team_style_features_clustered
GROUP BY league, season
ORDER BY season, league;

-- Cluster distribution by league
SELECT league, cluster, COUNT(*) AS num_teams
FROM team_style_features_clustered
GROUP BY league, cluster
ORDER BY league, num_teams DESC;

-- Year-to-year team performance change (EPL example)
SELECT t1.team,
       t1.season AS season_1,
       t2.season AS season_2,
       ROUND(t1.pts_per_game,2) AS pts_pg_season1,
       ROUND(t2.pts_per_game,2) AS pts_pg_season2,
       ROUND(t2.pts_per_game - t1.pts_per_game,2) AS pts_pg_change
FROM team_style_features_clustered t1
JOIN team_style_features_clustered t2
     ON t1.team = t2.team AND t1.league = t2.league
WHERE t1.league = 'EPL'
  AND t1.season = '2014/2015'
  AND t2.season = '2015/2016'
ORDER BY pts_pg_change DESC;

