﻿/*
Generated by quickdatabasediagrams.com
 Exported from QuickDBD: https://www.quickdatabasediagrams.com/
 Link to schema: https://app.quickdatabasediagrams.com/#/d/c2usl1
Diagram created by: Michael Dowlin
2/15/20

This is the data definition language (ddl) for the energy_db

STEP 1: Create a PostgresSQL Database called "energy_db"
STEP 2: Run this script to create all of the objects (tables, keys, views)

*/

--drop tables if they exist so it can be re-run
DROP TABLE IF EXISTS state_data;
DROP TABLE IF EXISTS air_quality;
DROP TABLE IF EXISTS region_degree_days;
DROP TABLE IF EXISTS state_region;
DROP TABLE IF EXISTS state_greenhouse_emissions;
DROM TABLE IF EXISTS facility_emissions;
DROP TABLE IF EXISTS region;
DROP TABLE IF EXISTS facility;
DROP TABLE IF EXISTS state;

CREATE TABLE "state" (
    "state" varchar   NOT NULL,
    "state_name" varchar   NOT NULL,
    CONSTRAINT "pk_state" PRIMARY KEY (
        "state"
     )
);

CREATE TABLE "region" (
    "region" varchar   NOT NULL,
    CONSTRAINT "pk_region" PRIMARY KEY (
        "region"
     )
);

CREATE TABLE "facility" (
    "facility_id" varchar   NOT NULL,
    "frs_id" varchar   NOT NULL,
    "facility_name" varchar   NOT NULL,
    "state" varchar   NOT NULL,
    "latitude" float   NOT NULL,
    "longitude" float   NOT NULL,
    CONSTRAINT "pk_facility" PRIMARY KEY (
        "facility_id"
     )
);

CREATE TABLE "facility_emissions" (
    "year" int   NOT NULL,
    "facility_id" varchar   NOT NULL,
    "emissions_mt" bigint   NOT NULL,
    CONSTRAINT "pk_facility_emissions" PRIMARY KEY (
        "year","facility_id"
     )
);

CREATE TABLE "state_data" (
    "year" int   NOT NULL,
    "state" varchar   NOT NULL,
    "producer_type" varchar   NOT NULL,
    "energy_source" varchar   NOT NULL,
    "co2_mt" bigint   NOT NULL,
    "so2_mt" bigint   NOT NULL,
    "nox_mt" bigint   NOT NULL,
    "consumption" bigint   NOT NULL,
    "generation_mwh" bigint   NOT NULL,
    CONSTRAINT "pk_state_data" PRIMARY KEY (
        "year","state","producer_type","energy_source"
     )
);

CREATE TABLE "region_degree_days" (
    "year" int   NOT NULL,
    "region" varchar   NOT NULL,
    "heating_degree_days" bigint   NOT NULL,
    "cooling_degree_days" bigint   NOT NULL,
    CONSTRAINT "pk_region_degree_days" PRIMARY KEY (
        "year","region"
     )
);

CREATE TABLE "state_greenhouse_emissions" (
    "year" int   NOT NULL,
    "state" varchar   NOT NULL,
    "greenhouse_emissions" bigint   NOT NULL,
    CONSTRAINT "pk_state_greenhouse_emissions" PRIMARY KEY (
        "year","state"
     )
);

CREATE TABLE "state_region" (
    "state" varchar   NOT NULL,
    "region" varchar   NOT NULL,
    CONSTRAINT "pk_state_region" PRIMARY KEY (
        "state","region"
     )
);

CREATE TABLE "air_quality" (
    "year" int   NOT NULL,
    "state" varchar   NOT NULL,
    "air_quality_avg" float   NOT NULL,
    CONSTRAINT "pk_air_quality" PRIMARY KEY (
        "year","state"
     )
);

ALTER TABLE "facility" ADD CONSTRAINT "fk_facility_state" FOREIGN KEY("state")
REFERENCES "state" ("state");

ALTER TABLE "facility_emissions" ADD CONSTRAINT "fk_facility_emissions_facility_id" FOREIGN KEY("facility_id")
REFERENCES "facility" ("facility_id");

ALTER TABLE "state_data" ADD CONSTRAINT "fk_state_data_state" FOREIGN KEY("state")
REFERENCES "state" ("state");

ALTER TABLE "region_degree_days" ADD CONSTRAINT "fk_region_degree_days_region" FOREIGN KEY("region")
REFERENCES "region" ("region");

ALTER TABLE "state_greenhouse_emissions" ADD CONSTRAINT "fk_state_greenhouse_emissions_state" FOREIGN KEY("state")
REFERENCES "state" ("state");

ALTER TABLE "state_region" ADD CONSTRAINT "fk_state_region_state" FOREIGN KEY("state")
REFERENCES "state" ("state");

ALTER TABLE "state_region" ADD CONSTRAINT "fk_state_region_region" FOREIGN KEY("region")
REFERENCES "region" ("region");

ALTER TABLE "air_quality" ADD CONSTRAINT "fk_air_quality_state" FOREIGN KEY("state")
REFERENCES "state" ("state");

