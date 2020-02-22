/*
SQL Views

Description:
This script will create all of the views that are used to produce the datasets for the various jsons 
	that will be created by the Flask application and returned to the dashboard

*/

--drop views if they exist
DROP VIEW IF EXISTS top_10_coal_state_stats;
DROP VIEW IF EXISTS facility_emissions_by_year;
DROP VIEW IF EXISTS facility_list;
DROP VIEW IF EXISTS state_list;

-- create views for analysis, charting, drop-down lists, pop-ups and...fun

-- state list (for drop downs, and metadata for pop-ups)
	-- the view uses common table expressions (CTEs) to make things faster and more readable
CREATE VIEW state_list
AS
	  -- this CTE returns total emissions by state and year, also has a rank so we can pull
	  	-- by most recent year, or 2nd most recent year, etc.
	WITH state_facility_emissions_by_year
	  AS
	   (
		  SELECT f.state,
				 fe.year,
				 SUM(fe.emissions_mt) as total_facility_emissions,
				 RANK() OVER (PARTITION BY f.state ORDER BY fe.year DESC) AS recent_year_rank
			FROM facility_emissions fe inner join facility f
		      ON fe.facility_id = f.facility_id
		GROUP BY f.state,
				 fe.year
	   ),
	  -- this CTE returns any state that has air quality data, gets the % of good, medium and bad days
	  	-- bad days is a combination of the rest of the AQI columns
		-- also has a rank function so we can get most recent year, etc.
		 state_air_quality_by_year
	  AS 
	   (
		  SELECT aq.state,
				 aq.year,
				 RANK() OVER (PARTITION BY aq.state ORDER BY aq.year DESC) AS recent_year_rank,
				 ROUND(SUM(good_days)/(SUM(days_with_aqi)*1.00),3) * 100 AS good_days_percent,
				 ROUND(SUM(moderate_days)/(SUM(days_with_aqi)*1.00),3) * 100 AS moderate_days_percent,
				 ROUND(SUM(unhealthy_days + unhealthy_sensitive_days + very_unhealthy_days + hazardous_days)
					   /(SUM(days_with_aqi)*1.00),3) * 100 AS unhealthy_days_percent
			FROM air_quality aq
		GROUP BY aq.state,
				 aq.year
	   ),
	  -- this CTE returns any state that has a facility, and the number of facilities in that state
	     state_facility_count
	  AS
	   (
		  SELECT f.state,
				 COUNT(*) AS facility_count
			FROM facility f
		GROUP BY f.state		   
	   )
  SELECT s.state,
  		 s.state_name,
		 r.region,
		 r.region_group,
		 sfc.facility_count,
		 sfeby1.year AS year_most_recent,
		 sfeby1.total_facility_emissions AS emissions_most_recent,
		 saqby1.good_days_percent AS good_days_pct_most_recent,
		 saqby1.moderate_days_percent AS moderate_days_pct_most_recent,	
		 saqby1.unhealthy_days_percent AS unhealthy_days_pct_most_recent,
		 sfeby2.year AS year_2nd_most_recent,
		 sfeby2.total_facility_emissions AS emissions_2nd_most_recent,
		 saqby2.good_days_percent AS good_days_pct_2nd_most_recent,
		 saqby2.moderate_days_percent AS moderate_days_pct_2nd_most_recent,	
		 saqby2.unhealthy_days_percent AS unhealthy_days_pct_2nd_most_recent,		 
		 sfeby3.year AS year_3rd_most_recent,
		 sfeby3.total_facility_emissions AS emissions_3rd_most_recent,
		 saqby3.good_days_percent AS good_days_pct_3rd_most_recent,
		 saqby3.moderate_days_percent AS moderate_days_pct_3rd_most_recent,	
		 saqby3.unhealthy_days_percent AS unhealthy_days_pct_3rd_most_recent		 
    FROM state s INNER JOIN state_region sr
	  ON s.state = sr.state INNER JOIN region r
	  ON sr.region = r.region LEFT OUTER JOIN state_facility_count sfc
	  ON s.state = sfc.state LEFT OUTER JOIN state_facility_emissions_by_year sfeby1
	  ON s.state = sfeby1.state LEFT OUTER JOIN state_facility_emissions_by_year sfeby2
	  ON s.state = sfeby2.state LEFT OUTER JOIN state_facility_emissions_by_year sfeby3
	  ON s.state = sfeby3.state LEFT OUTER JOIN state_air_quality_by_year saqby1
	  ON s.state = saqby1.state LEFT OUTER JOIN state_air_quality_by_year saqby2
	  ON s.state = saqby2.state LEFT OUTER JOIN state_air_quality_by_year saqby3
	  ON s.state = saqby3.state
	  -- limit the CTE's by the rank to grab the last three years of total facility emissions
   WHERE sfeby1.recent_year_rank = 1
     AND sfeby2.recent_year_rank = 2
	 AND sfeby3.recent_year_rank = 3
     AND saqby1.recent_year_rank = 1
	 AND saqby2.recent_year_rank = 2
	 AND saqby3.recent_year_rank = 3;

-- facility list (for drop downs, and metadata for pop-ups)
CREATE VIEW facility_list
AS
  SELECT f.facility_id,
  		 f.latitude,
		 f.longitude,
  		 f.frs_id,
		 f.facility_name,
		 f.state,
		 s.state_name,
		 r.region,
		 r.region_group
    FROM facility f INNER JOIN state s
	  ON f.state = s.state INNER JOIN state_region sr
	  ON s.state = sr.state INNER JOIN region r
	  ON sr.region = r.region;
	  
-- facility emissions by year dataset (for charting)
CREATE VIEW facility_emissions_by_year
AS
  SELECT f.facility_id,
  		 f.latitude,
		 f.longitude,
  		 f.frs_id,
		 f.facility_name,
		 f.state,
		 s.state_name,
		 r.region,
		 r.region_group,
		 fe.year,
		 fe.emissions_mt
    FROM facility f INNER JOIN state s
	  ON f.state = s.state INNER JOIN state_region sr
	  ON s.state = sr.state INNER JOIN region r
	  ON sr.region = r.region INNER JOIN facility_emissions fe
	  ON f.facility_id = fe.facility_id;	  

-- simple dataset, just curious
CREATE VIEW top_10_coal_state_stats
AS
    WITH top_10_coal_states
	  AS
	   (
		  SELECT state,
				 generation_mwh
			FROM state_data
		   WHERE generation_mwh IS NOT NULL	
			 AND energy_source = 'Coal'
			 AND year = 2018
			 AND state <> 'US'
		ORDER BY generation_mwh DESC
		   LIMIT 10
	   )
  SELECT SD.state,
  		 SD.year,
		 SD.generation_mwh,
		 SD.co2_mt,
		 SD.so2_mt,
		 SD.nox_mt
	FROM top_10_coal_states TOP INNER JOIN state_data SD
	  ON TOP.state = SD.state
   WHERE energy_source = 'Coal';