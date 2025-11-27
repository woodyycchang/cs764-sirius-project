-- ============================================================
-- IMDB schema + load script for DuckDB
-- ============================================================

-- ============================================================
-- 1) CREATE TABLES (from schematext.sql in original repo)
-- ============================================================

CREATE TABLE aka_name (
    id INTEGER NOT NULL PRIMARY KEY,
    person_id INTEGER NOT NULL,
    name VARCHAR,
    imdb_index VARCHAR(3),
    name_pcode_cf VARCHAR(11),
    name_pcode_nf VARCHAR(11),
    surname_pcode VARCHAR(11),
    md5sum VARCHAR(65)
);

CREATE TABLE aka_title (
    id INTEGER NOT NULL PRIMARY KEY,
    movie_id INTEGER NOT NULL,
    title VARCHAR,
    imdb_index VARCHAR(4),
    kind_id INTEGER NOT NULL,
    production_year INTEGER,
    phonetic_code VARCHAR(5),
    episode_of_id INTEGER,
    season_nr INTEGER,
    episode_nr INTEGER,
    note VARCHAR(72),
    md5sum VARCHAR(32)
);

CREATE TABLE cast_info (
    id INTEGER NOT NULL PRIMARY KEY,
    person_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    person_role_id INTEGER,
    note VARCHAR,
    nr_order INTEGER,
    role_id INTEGER NOT NULL
);

CREATE TABLE char_name (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR NOT NULL,
    imdb_index VARCHAR(2),
    imdb_id INTEGER,
    name_pcode_nf VARCHAR(5),
    surname_pcode VARCHAR(5),
    md5sum VARCHAR(32)
);

CREATE TABLE comp_cast_type (
    id INTEGER NOT NULL PRIMARY KEY,
    kind VARCHAR(32) NOT NULL
);

CREATE TABLE company_name (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR NOT NULL,
    country_code VARCHAR(6),
    imdb_id INTEGER,
    name_pcode_nf VARCHAR(5),
    name_pcode_sf VARCHAR(5),
    md5sum VARCHAR(32)
);

CREATE TABLE company_type (
    id INTEGER NOT NULL PRIMARY KEY,
    kind VARCHAR(32)
);

CREATE TABLE complete_cast (
    id INTEGER NOT NULL PRIMARY KEY,
    movie_id INTEGER,
    subject_id INTEGER NOT NULL,
    status_id INTEGER NOT NULL
);

CREATE TABLE info_type (
    id INTEGER NOT NULL PRIMARY KEY,
    info VARCHAR(32) NOT NULL
);

CREATE TABLE keyword (
    id INTEGER NOT NULL PRIMARY KEY,
    keyword VARCHAR NOT NULL,
    phonetic_code VARCHAR(5)
);

CREATE TABLE kind_type (
    id INTEGER NOT NULL PRIMARY KEY,
    kind VARCHAR(15)
);

CREATE TABLE link_type (
    id INTEGER NOT NULL PRIMARY KEY,
    link VARCHAR(32) NOT NULL
);

CREATE TABLE movie_companies (
    id INTEGER NOT NULL PRIMARY KEY,
    movie_id INTEGER NOT NULL,
    company_id INTEGER NOT NULL,
    company_type_id INTEGER NOT NULL,
    note VARCHAR
);

CREATE TABLE movie_info_idx (
    id INTEGER NOT NULL PRIMARY KEY,
    movie_id INTEGER NOT NULL,
    info_type_id INTEGER NOT NULL,
    info VARCHAR NOT NULL,
    note VARCHAR(1)
);

CREATE TABLE movie_keyword (
    id INTEGER NOT NULL PRIMARY KEY,
    movie_id INTEGER NOT NULL,
    keyword_id INTEGER NOT NULL
);

CREATE TABLE movie_link (
    id INTEGER NOT NULL PRIMARY KEY,
    movie_id INTEGER NOT NULL,
    linked_movie_id INTEGER NOT NULL,
    link_type_id INTEGER NOT NULL
);

CREATE TABLE name (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR NOT NULL,
    imdb_index VARCHAR(9),
    imdb_id INTEGER,
    gender VARCHAR(1),
    name_pcode_cf VARCHAR(5),
    name_pcode_nf VARCHAR(5),
    surname_pcode VARCHAR(5),
    md5sum VARCHAR(32)
);

CREATE TABLE role_type (
    id INTEGER NOT NULL PRIMARY KEY,
    role VARCHAR(32) NOT NULL
);

CREATE TABLE title (
    id INTEGER NOT NULL PRIMARY KEY,
    title VARCHAR NOT NULL,
    imdb_index VARCHAR(5),
    kind_id INTEGER NOT NULL,
    production_year INTEGER,
    imdb_id INTEGER,
    phonetic_code VARCHAR(5),
    episode_of_id INTEGER,
    season_nr INTEGER,
    episode_nr INTEGER,
    series_years VARCHAR(49),
    md5sum VARCHAR(32)
);

CREATE TABLE movie_info (
    id INTEGER NOT NULL PRIMARY KEY,
    movie_id INTEGER NOT NULL,
    info_type_id INTEGER NOT NULL,
    info VARCHAR NOT NULL,
    note VARCHAR
);

CREATE TABLE person_info (
    id INTEGER NOT NULL PRIMARY KEY,
    person_id INTEGER NOT NULL,
    info_type_id INTEGER NOT NULL,
    info VARCHAR NOT NULL,
    note VARCHAR
);

-- ============================================================
-- 2) LOAD DATA FROM CSVs USING read_csv_auto
-- ============================================================

INSERT INTO aka_name
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/aka_name.csv');

INSERT INTO aka_title
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/aka_title.csv');

INSERT INTO cast_info
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/cast_info.csv');

INSERT INTO char_name
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/char_name.csv');

INSERT INTO comp_cast_type
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/comp_cast_type.csv');

INSERT INTO company_name
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/company_name.csv');

INSERT INTO company_type
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/company_type.csv');

INSERT INTO complete_cast
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/complete_cast.csv');

INSERT INTO info_type
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/info_type.csv');

INSERT INTO keyword
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/keyword.csv');

INSERT INTO kind_type
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/kind_type.csv');

INSERT INTO link_type
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/link_type.csv');

INSERT INTO movie_companies
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/movie_companies.csv');

INSERT INTO movie_info_idx
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/movie_info_idx.csv');

INSERT INTO movie_keyword
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/movie_keyword.csv');

INSERT INTO movie_link
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/movie_link.csv');

INSERT INTO name
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/name.csv');

INSERT INTO role_type
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/role_type.csv');

INSERT INTO title
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/title.csv');

INSERT INTO movie_info
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/movie_info.csv');

INSERT INTO person_info
SELECT *
FROM read_csv_auto('~/sirius/test_datasets/imdb/person_info.csv');


-- ============================================================
-- 3) CREATE INDEXES (again from original repo fkindex.sql)
-- ============================================================

CREATE INDEX company_id_movie_companies ON movie_companies(company_id);
CREATE INDEX company_type_id_movie_companies ON movie_companies(company_type_id);
CREATE INDEX info_type_id_movie_info_idx ON movie_info_idx(info_type_id);
CREATE INDEX info_type_id_movie_info ON movie_info(info_type_id);
CREATE INDEX info_type_id_person_info ON person_info(info_type_id);
CREATE INDEX keyword_id_movie_keyword ON movie_keyword(keyword_id);
CREATE INDEX kind_id_aka_title ON aka_title(kind_id);
CREATE INDEX kind_id_title ON title(kind_id);
CREATE INDEX linked_movie_id_movie_link ON movie_link(linked_movie_id);
CREATE INDEX link_type_id_movie_link ON movie_link(link_type_id);
CREATE INDEX movie_id_aka_title ON aka_title(movie_id);
CREATE INDEX movie_id_cast_info ON cast_info(movie_id);
CREATE INDEX movie_id_complete_cast ON complete_cast(movie_id);
CREATE INDEX movie_id_movie_companies ON movie_companies(movie_id);
CREATE INDEX movie_id_movie_info_idx ON movie_info_idx(movie_id);
CREATE INDEX movie_id_movie_keyword ON movie_keyword(movie_id);
CREATE INDEX movie_id_movie_link ON movie_link(movie_id);
CREATE INDEX movie_id_movie_info ON movie_info(movie_id);
CREATE INDEX person_id_aka_name ON aka_name(person_id);
CREATE INDEX person_id_cast_info ON cast_info(person_id);
CREATE INDEX person_id_person_info ON person_info(person_id);
CREATE INDEX person_role_id_cast_info ON cast_info(person_role_id);
CREATE INDEX role_id_cast_info ON cast_info(role_id);