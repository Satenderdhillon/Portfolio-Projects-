-- Data Cleaning
-- Author = satender singh dhillon
-- date = 2024-11-23
-- description = Data Cleaning

select *
from world_layoffs.layoffs;

--- 1. remove duplicates 
--- 2. standardize the data 
--- 3. null values or blank values
--- 4. remove any columns
-------- 'creating an another table so that I would have a backup raw data in case something bad happen to data' 
Create table layoffs_staging
like layoffs; 

select * 
from layoffs_staging;

insert layoffs_staging 
select *
from layoffs;
----- 'creating the partition by few categories in order to simplify data  and indentify duplicates'
select * ,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`)  as row_num
from layoffs_staging;



-------- 'so now  i am using cte to find the duplicates eg. here rownumber will be more than 1 for duplicates'---
with duplicate_cte  As
(
select * ,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage , country, funds_raised_millions)  as row_num
from layoffs_staging
)
select *
from duplicate_cte 
where row_num > 1;



--- 'just checking if these are really a duplicates'--
select *
from layoffs_staging
where company = 'Casper' ;

---- 'deleting the duplicates but failed because the tables is not updatable' --
with duplicate_cte  As
(
select * ,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage , country, funds_raised_millions)  as row_num
from layoffs_staging
)
Delete 
from duplicate_cte 
where row_num > 1;


------- 'creating  a table which includes row number'
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
--- checking the table --
select * 
from layoffs_staging2;
--- inserting the data from layoffs_staging table --
Insert into layoffs_staging2
select * ,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage , country, funds_raised_millions)  as row_num
from layoffs_staging;
-- selecting the duplicated data --
select * 
from layoffs_staging2
where row_num > 1;
--- delete the duplicates finally-- this didn't work for the first time because I was working under safe mode where this sql server rejects all the updates and delete --
Delete
from layoffs_staging2
where row_num > 1;

---- standardizing data--- finding issues and fixing it-----------------------------------------------------------------------

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct(industry)
from layoffs_staging2
order by 1;

-- there are seperate  rows for crypto , crypto currency--- so we will be going to make these all as one---
select *
from layoffs_staging2
where industry like 'crypto%';

update  layoffs_staging2
set industry = 'crypto'
where industry like 'crypto%';

select distinct country
from layoffs_staging2
order by 1;

update  layoffs_staging2
set  country = 'United States'
where country like 'United%';
---------- or--------------
select distinct country , trim(trailing '.' from country )
from layoffs_staging2
order by 1;
--------- or --------------------
update  layoffs_staging2
set  country = trim(trailing '.' from country )
where country like 'United%';



select country
from layoffs_staging2
where country like 'United%';

--- changing the date format--
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update  layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select `date`
from layoffs_staging2;

alter table layoffs_staging2
modify column `date` DATE ;
-- looking for the nulls and blanks in the data  and trying to populate the blanks  ---
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2 
where industry is null
or industry = ''; --- never leave space between the ''----

select *
from layoffs_staging2 
where company = 'airbnb';

update  layoffs_staging2
set  industry = 'Travel'
where company = 'airbnb';

--- other method --
select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry = null or t1.industry = '') 
and t2.industry is not null;


update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry = null or t1.industry = '') 
and t2.industry is not null;

select *
from layoffs_staging2
where industry is null or industry = '';

update layoffs_staging2
set industry = null
where industry = '';

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry = null 
and t2.industry != null;

select *
from layoffs_staging2
where company = 'Juul'  ;

delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2;

alter table  layoffs_staging2
drop column row_num;


























