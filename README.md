#### Web-Scraping-for-jobs-from-Blocket.se

##### An assignment of DSSS course of Computational Social Science in Linköping University, Sweden
#
##### The code is used to search for Data & IT, developer, Heltid"(full-time) jobs on "https://jobb.blocket.se/" A total of 300 results 20 pages * 15 posts/page with job(post) title, company, location, release_date, blocket_link, home_page, days_left_spe(cific), time(plenty or scarce), lat and long for location on maps.
#
##### In this assignment, I collected full time developer (Data & IT) jobs and their related information on blocket.se. 
#
##### I think it might be interesting to study where in Sweden has more job opportunities for developers/students whose major is computer science related, which companies are providing more positions for them and if it is a good idea to use blocket.se to search for jobs. Job advertisements on blocket.se are uploaded and deleted every day. The data used in this study was collected at 17:00 on April 24th, 2023.
#
#
#### Data collecting and cleaning process
##### I firstused a headless browser in R to browse https://jobb.blocket.se/ se/. After accepting the service terms and cookies, I clicked on the button “ Visa fler jobb ” to show more jobs (as well as Visa fler kategorier show more categories) and ticked “Data & IT”, “ Utvecklare” (developer) and “ Heltid” (full time) boxes using rm$findElement()  and clickElement(). There were 21 pages containing information about full time developer jobs and each page contained a maximum of 15 nodes. I extracted the job title, company name, work location ( city), job release date warning of limited days left for application ( only jobs with days left fewer than 7 would show this kind of information) as well as the links to detailed job pages on the blocket website of 300 jobs on 20 menu pages. I deleted all unnecessary spaces in the contents. Job release dates shown as “Igår” (yesterday) and “Idag” (today) were rewritten as “23 apr 2023” and “24 apr 2023” according to the real date. Only numbers in warnings of limited time left were kept and for those jobs without such warnings, which indicate d plenty of time before the application period ends, the values were coded as NA. Also, if the warnings wrote “sista dagen” (the last day), the values were rewritten as 0. The information was stored in a data frame which contains six columns ( showing href number, “job”, “company”, “location”,“release_date”, “days_left”, “blocket_link").
#
##### Then, using blocket_link from the first data frame, I extracted the links to the company ’s home page and application deadline s of the 300 jobs. The application deadline s were shown as the release date of the position with days left (regardless of how many days were left) in parentheses. Considering release dates were already obtained and stored in the first data frame, only the numbers in parentheses were collected. The data were th en stored in the second data frame which contains two columns (“home_page” and “days_left_spe”).
#
##### The 20 menu pages and detailed job descriptive pages of 300 jobs were saved as html files.
#
##### The two data frames were saved as csv files and then combined as one data frame (also saved as a csv file).
#
##### Jobs with location outside Sweden were filtered out from the combined data frame resulting in the data frame having 277 rows. The column days_left w as replaced by a new column named “time” which was coded “plenty” if days_left had the value NA and “scarce” otherwise. The “X” column which appeared after I combined the two data frames and showed the number of href was replaced by “ID” created based on row numbers.
#
##### To visualize the company location on a map, the “ tidygeocoder ” package was used to add two more columns based on the “location” column (“lat” for “latitude” and “long” for “longitude”).
#
##### The final data frame has a total of 11 columns (“ID”, “job”, “company”, “location”, “release_date”, “blocket_link”, “home_page”, “days_ spe”, “time”, “lat” and “long”).
#
#
#### Where in Sweden provides more opportunities for developers?
##### Packages “mapview” and “leaflet” were used to visualize the job locations on the map.
#
##### In Map 2, each location(city) is shown as a grey dot on the map of Sweden. For jobs with the same job location(city), the dots would overlap so dots with darker color suggest more job opportunities in a certain city. The majority of jobs are in the south of Swed en. In the north of Sweden, developers are more likely to find a job in cities along the east coast.
#
##### Graph 1 shows the distribution of jobs in different cities. Stockholm alone provides 77 positions for developers.  Uppsala has the second most positions (24) positions for developers followed by Gothenburg (20), Linköping (20) and Borlänge (15). It might be wise for those who intend to work as developers to move to these cities move to these cities for more job opportunities
#
#
#### Which companies provide more positions for developers? 
##### Graph 2 shows the number of jobs posted by different companies.138 of 277 jobs were provided by Academic Work. Megasol Technologies provided 20 positions.
#
##### Academic Work is a staffing and recruitment company for mainly students and academics, also called young professionals found in 1998.Academic Work now work s with providing students with part time assignments information and opportunities and full time consulting assignments and recruitments. With the target group being still newly graduated students, Academic Work could also be seen as a platform containing r ecruitment advertisements. So these 138 job positions provided by Academic Work do not suggest that there were 138 possible positions in this single company. It is more likely that Academic Work was promoting jobs provided by other companies which cooperate with Academic Work.
#
#
#### Is blocket.se a good website for finding jobs?
##### The blocket website is Sweden's largest online buying and selling market and was founded in 1996. One can find advertisement s of housing, cars, furniture, electronics as well as jobs on the website. According to data released in 2021, around 70% of Swedes had used this website trading things and the website had about five million unique visitors a week. While LinkedIn is used by many job seekers, one has to manually enter the job types in the search box to find if there is any job position that they can apply for. But the blocket website provides users with tick boxes which could guide users to jobs based on “ category ” such as “Data & IT”), “distant jobs”, “ places” ( if not remote jobs) and “ extent” ( such as “full time” or “part time”).
#
##### Graph 3.1 shows the number of jobs with certain days left for application. The most common situation is that there are ab out 30 days left before the application portal closes. There are also many “fresh” jobs with more than 50 days left for application.
#
##### Graph 3.2 shows the number of jobs which were coded as “plenty” and “scarce” in the “time” column in the data frame. As m entioned before, only jobs which had a warning message about limited application time on the menu page are coded as “scarce”. Out of 277 jobs, about 86.6% (240) of them had “plenty of” time left for application.
#
##### Considering how many “fresh” jobs are posted on the blocket website , the website is actively used by many employers so that job seekers could find updated advertisements every time they use this website.
#
##### Also, the blocket website did a great job by giving a warning when the time left for application is less than about 7 days on the menu page. Without clicking on the link to go to the detailed descrip tive page of a job, job seekers could be noticed as soon as they reached the menu page, which prevents them f rom missing potential employment chance due to deadline of application being unclear.
#
##### One disadvantage of using blocket.se to look for jobs is that the working locations (if not remoted jobs) are in general in Sweden while jobs in different countries can be found when users of LinkedIn manually type in the name of the country in the search box. Also, the default language used on blocket.se is Swedish and many job advertisements are also written in Swedish and there is no tick box for “English jobs” for example.
#
##### In general, blocket.se is a good website for job seekers as it provides a great number of newly released positions every day and the tick boxes for filtering make it convenient for job seekers to find jobs meeting their requirements. However, for non native Swedish speakers or those who wish to find jobs in not only Sweden but also other countries, it is a good idea to use other websites besides blocket.se.
