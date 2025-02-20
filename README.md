# Layoffs Data Cleaning and Analysis using SQL

# Overview
This project involves cleaning and analysing a layoff dataset covering multiple industries, locations, and periods using SQL and presenting the insights as a Power BI dashboard. I took up this project to revise some SQL concepts like CTEs and try out Power BI.

# Data cleaning steps:
1. Handling duplicates: Identified and removed 2,915 duplicate entries across the dataset
2. Standardising data
3. Handling null values: Mainly removed records where both, total_laid_off and percentage_laid_off, were NULL since it doesn't give much insights

# Insights:
![image](https://github.com/user-attachments/assets/ca0a3959-fff0-493f-aeef-bbe09d97f4b0)
1. Companies affected: The Post-IPO companies mostly fired their employees. The dataset includes layoffs from 1,757 companies. Amazon, Meta, Intel, Microsoft, and Tesla had the highest number of layoffs.
2. Industry trends: The consumer, retail, transportation, hardware and food industries were hit hardest by layoffs.
3. Geographical impact: USA, India, Germany, and UK experienced the most layoffs, with the USA having 10x more layoffs than India. The USA also has the most companies in the dataset (1,101), explaining the high layoff count. Countries like Canada and Israel had many companies but relatively fewer layoffs.
4. Funding stage: Companies in the post-IPO stage were responsible for most layoffs, likely due to their larger workforce. Post-IPO companies laid off 311,196 employees, compared to 36,886 in earlier-stage companies (almost a 10x difference).
5. Layoffs over time: The highest number of layoffs occurred in 2023, followed by 2022 and 2024. The first six months of 2023 saw the most layoffs however this is not a general trend seen across other years. The rolling total of layoffs peaked from January to April 2023.
6. Extreme cases: 197 companies had to completely shut down operations, firing 100% of their workforce.
