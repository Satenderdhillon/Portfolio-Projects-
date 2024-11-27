-- exploratory Data Analysis --

Select *
from layoffs_staging2;
--- 'checking the maximum number of layoffs and the percentage in accordance to companys_strength'
Select Max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;
---- 'Result = 12000 employees laid off in one go and 100 percent employees were the maximum'

---- 'selecting the companies  with 100 percent layoffs'----
Select *
from layoffs_staging2
where percentage_laid_off = 1;
---- 'result = 116 companies with 100 percent layoffs'

--- 'selecting the companies with 100 percent layoffs and with  descending order of their fund_raised_million column'
Select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;
--- 'result = british volt raised the highest amount of funds with 2400 millions '

--- 'selecting the companies and their sum of their total_laid_off'
select company , sum(total_laid_off)
from layoffs_staging2
group by company 
order by 2 desc;
--- 'results = amazon laid off the most , followed by google with 12000 employees getting laid off, well there are companies who either not laid off anybody or we have no data for them at the  moment'

--- 'selecting the minimum date and maximum date'
select min(date), max(date)  '\'or \'     \'select min(`date`), max(`date`)\''
from layoffs_staging2;
--- 'results = we have 2 and half year of data which started in the very end of 2020 and ended by mid of 2023 '

--- 'now  we are checking which industry has the most layoffs '
select industry , sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;
--- 'result= consumer industry faced the substantially high number of layoffs  and retail was standing on second spot '

--- 'checking which country had the highest lay offs?'
select country , sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;
--- 'results = united states had the far higher number of layoffs than any other country'

--- 'years and their total number of layoffs'
select Year(date) , sum(total_laid_off)
from layoffs_staging2
group by Year(date)
order by 1 desc;
--- 'the highest number of layoffs were recorded  in 2022 but still we can expect the layoff number to boom in 2023 because the data we have is just for the first three months of 2023 and still numbers are closer the what the total was for 2022'

--- 'now the stage column against total laid off'
select stage , sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;
--- ' post-ipo was the highest '

--- 'deriving the total layoffs in each month of the year'
select substring(`date`,1,7 )  as `month` ,sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7 )  is not null 
group by `month`
order by 2 desc;
--- 'result = january 2023 is the month which can be accounted for highest total number of layoffs'
 
--- 'selecting the  months ,sum of total laid off and cumulative total by months'
with Rolling_Total as
(
select substring(`date`,1,7 )  as `month` ,sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7 )  is not null 
group by `month`
order by 1 asc
)
select `month` , total_off , sum(total_off) over(order by `month`) as  rolling_total
from Rolling_Total;
--- ' result = a tremendous incline in number of employees laid off was seen in last 5 months with more the 150,000'

select company , sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

---- 'selecting the companies and their total laid off with year'
select company , year(`date`) , sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc ;
---- 'result = well- known companies like google , meta ,amazon , microsoft  had the higher number in layoffs and regarless of only three month data of 2023 , it recorded the highest number of layoffs from google'


--- 'selecting top 5 during each year who laid off the highest number of employees'
with company_year (company, years  , total_laid_off) as 
(
select company , year(`date`) , sum(total_laid_off)
from layoffs_staging2
where year(`date`) is not null
group by company, year(`date`) 
) , company_year_rank as 
(select * , 
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
)
select *
from company_year_rank
where ranking <= 5
--- 'result = in 2020-uber, in 2021-bytedance , in 2022-meta , in 2023-google'
































