library(RSelenium)
library(XML)
library(httr)
library(rvest)
user_agent("Mozilla/5.0 (Macintosh;U; Intel MacOS X 
10.6; en-US")

# set up a headless browser
rm.driver <- rsDriver(browser = "firefox", phantomver = NULL, chromever = NULL)
rm <- rm.driver$client

# check if it did work
rm$getStatus()

# Navigate to the webpage
rm$navigate("https://jobb.blocket.se/") 
# accept service terms
rm$findElement(using = "xpath", value = '//button[@id="accept-ufti"]')$clickElement()
# accept cookies
rm$findElement(using = "xpath", value = '//button[@class="ui right floated basic button no-padding close-button"]/i[@class="icon close"]')$clickElement()
# view more jobs
rm$findElement(using = "xpath", value = '//a[@class="ui header blue"]')$clickElement()
# view more job categories # at least in my browser, Data & IT is hidden in the list until I click on this button
rm$findElement(using = "xpath", value = '//a[@class="show-filters-btn"]/b[contains(text(),"Visa fler kategorier")]')$clickElement()
# choose "Data & IT"
rm$findElement(using = "xpath", value = '//input[@id="ks-cg-9230"]')$clickElement()
# choose "developer"
rm$findElement(using = "xpath", value = '//input[@id="ks-scg-9231"]')$clickElement()
# choose "Heltid"(full-time)"
rm$findElement(using = "xpath", value = '//input[@id="ks-employment-1"]')$clickElement()

setwd("C:/Users/wangy/Documents/DSSS lab/assignment1/menu pages")
# create two empty list to store the contents
res <- list()
res_plus <- list()
# we need to turn page later. Create a empty vector to store the pages before we download a page.(have to do this or every saved page is the same page)
page <- c()
# let i range from 1 to 20 (on 2023.4.24 17:00 there were 21 pages)(*but I only used 20 pages for simplicity)
for (i in 1:20){ # for each page
  print(i)   # show me which page my loop is working on
  page[i] <- unlist(rm$getPageSource()) # get response from link(unlist it first as it is a list originally) and make it the ith item in the page vector 
  writeLines(page[i],paste0(i,"fulltime_data_job.html")) # save the page on my computer
  html <- htmlParse(page[i]) # restructure the page so that we can proceed and use functions in XML
  nodes <- xpathSApply(html,'//div[@class="item job-item"]') # collect nodes(a page could contain a maximum of 15 nodes)
  for (k in 1:15) { # for each node
    # Get the job title
    job <- xpathSApply(nodes[[k]], ".//a[@class='header']", xmlValue)
    # Get company names
    company <- xpathSApply(nodes[[k]], ".//a[@class='corp bold']", xmlValue)
    # Get job locations
    location <- xpathSApply(nodes[[k]], ".//a[@class='no-margin']", xmlValue)
    # There are two objects "release_date" and "days_left". Take the two objects separately 
    release_date <- xpathSApply(nodes[[k]], ".//div[@class='extra']/span", xmlValue)[[1]]
    days_left <- xpathSApply(nodes[[k]], ".//div[@class='extra']/span", xmlValue)[[2]]
    # Get links to the detailed job page
    blocket_link <- xpathSApply(nodes[[k]], ".//a[@class='header']/@href")
    # in case of missing info
    if (length(job) == 0) {
      job <- NA
    }
    if (length(company) == 0) {
      company <- NA
    }
    if (length(location) == 0) {
      location <- NA
    }
    if (length(release_date) == 0) {
      release_date <- NA
    }
    if (length(days_left) == 0) {
      days_left <- NA
    }
    if (length(blocket_link) == 0) {
      blocket_link <- NA
    }
    res[[k]] <- cbind(job,company,location,release_date,days_left,blocket_link) # keep items from the same node together
  }
  res_plus <- append(res_plus,res) # Update res_plus. Add new items from res to res_plus
  Sys.sleep(sample(1:3,1)) # set pause time from 1 sec to 3 sec
  # Turn the page
  rm$findElement(using = "xpath", value = '//i[@class="small chevron right icon no-margin"]')$clickElement()
}

#Transform the list into a dataframe. Call it df_1
df_1 <- as.data.frame(do.call(rbind, res_plus))

# data cleaning
# All jobs have a few spaces in the beginning. Remove them
df_1$job <- gsub(pattern = "^\\s+", replacement = "", x = df_1$job)
# There is one space before the company names in the column # delete possible spaces before and behind the text just in case 
df_1$company <- gsub("^\\s+|\\s+$","",df_1$company)
# All locations end with ",". Remove it
df_1$location <- gsub(pattern = ",", replacement = "", x = df_1$location)
# There are dates shown as "Idag" and "Igår". Change them according to the actual date
df_1$release_date <- gsub(pattern = "Idag", replacement = "24 apr 2023", x = df_1$release_date)
df_1$release_date <- gsub(pattern = "Igår", replacement = "23 apr 2023", x = df_1$release_date)
# There are days_left shown as "sista dagen"(final day) and "x dagar kvar"(x days left).
# Change "sista dagen" into 0 and only keep the number of days in "x dagar kvar"
df_1$days_left <- gsub(pattern = "sista dagen", replacement = "0", x = df_1$days_left)
df_1$days_left <- gsub("[^0-9]+", "",df_1$days_left)

# save the data frame
setwd("yourwd")
write.csv(df_1,"blocket_20_pages.csv")


# we have a total of 300 jobs
# set up a new working directory so that files could be stored in the new file holder
setwd("yourwd")
# use the links in df_1 to go to the detailed information page of each job 
links <- df_1$blocket_link
# create another empty lists
res_2 <- list()
# We have a total of XXX links
for (i in 1:300){
  # store the pages in my file holder (detail pages)
  res_z <- read_html(links[i])
  writeLines(as.character(res_z),paste0(i,"job_detail_page.html"))
  # restructure the page so that we can use functions in xml package
  html_z <- htmlParse(res_z)
  # the "mer info"(more information) part is a bit messy they share same attributes
  # but by inspecting the page, we know the link to the home page of each company is : the first link in "a" which contains "href"
  # I tried this for a few times until I found the right path
  home_page <- xpathSApply(html_z, "//a[contains(@href,'http')]/@href")[[1]]
  # days_left takes more steps to get
  # by inspecting the page, we know days_left is in a div which its class is 'sc-773ccdf1-4 cUtdMq' and also contains text "2023"
  days_left_spe <- xpathSApply(html_z,"//div[@class='sc-773ccdf1-4 cUtdMq' and contains(text(),'2023')]",xmlValue)
  # in case of missing information
  if (length(home_page) == 0) {
    home_page <- NA
  }
  if (length(days_left_spe) == 0) {
    days_left_spe <- NA
  }
  res_2[[i]] <- cbind(home_page,days_left_spe) # combine home_page and days_left as objects for one job
}
# create a data frame called df_2
df_2 <- as.data.frame(do.call(rbind, res_2))

# data cleaning
# what we get in days_left_spe is a combination of job released date(d-m-y) and days-left( x dagar kvar) info in "()"
# get everything behind "2023"
df_2$days_left_spe <- gsub("^(.*)(2023)(.*)","\\3",df_2$days_left_spe)
# delete everything that is not a number
df_2$days_left_spe <- gsub("[^0-9]+", "",df_2$days_left_spe)

# save df_2
setwd("yourwd")
write.csv(df_2,"detail_page_300_jobs.csv")
# save the final data frame for further use
df <- cbind(df_1,df_2)
write.csv(df,"final_df.csv")

########################################

# load our saved final_df
df <- read.csv("yourwd/final_df.csv")

# But we have to do more adjustments to df
library(tidyverse)

table(df$location)
# check if all job locations are in Sweden

df <- df |> 
  filter(location != "Utland") |>  # There are some oversea jobs(Utland, without city-level location)
  filter(location != "Nordland") |>    # there is also one job located in Norway, take it away as well
  mutate(time = case_when(is.na(days_left) ~ "plenty",  # create a new column based on days_left
                          TRUE ~ "scarce" # if it is NA(the website did not give warning on days_left)
                                          # code it as "plenty" and "scarce" otherwise
  )) |> 
  select(-days_left,-X) |>       # delete the original days_left column and X which contains href number
  mutate(id = row_number()) |>  # create a new id column based on row number to replace X 
  select(id,job,company,location,release_date,blocket_link,home_page,days_left_spe,time) # reorder columns
  
# to add address details to "location"(city) in df
# we need the tidygeocoder package
library(tidygeocoder)
df <- df |> 
  tidygeocoder::geocode(
    address = location,
    method = "osm"
  )
# by doing this, we have two more columns called "long"(longitude) and "lat"(latitude)
# then "location" can be found on the map

# we need to mapview package to give us a map with points on it
library(mapview)
# we need leaflet package to change the look of our maps 
library(leaflet)
# first map without changing the size or color of points(which stands for city)
mapview(df,
        xcol = "long", ycol = "lat", crs = 4326, grid = FALSE) # to be honest, I am not sure why I should use 4326 here
                                                              # I must have seen this number somewhere but I cannot remember
                                                              # Chatgpt gave me something around 3000 but it led me to Africa

# name the same map m(with more adjustments, it will be our second map)
m <- mapview(df,
             xcol = "long", ycol = "lat", crs = 4326, grid = FALSE)
# use functions from leaflet package
m <- leaflet() |> 
  addTiles()  # Add default tile layer
# Add the circle markers to the map
m <- m |>  
  addCircleMarkers(data = df, 
                   lat = ~lat, lng = ~long, 
                   radius = 4,  # Set desired point size
                   color = "grey99") # set the color kind of light grey so that darker color would mean more jobs in that city(because of overlapping)
# Display the second map
m

# Graph 1 
# how many jobs are there in a certain city in Sweden
ggplot(data=df) +
  geom_bar(aes(x=location), stat="count", color='black', fill='cyan') + # count "location"(city names)
  geom_text(aes(x=location, label=after_stat(count)), stat="count", vjust=-0.5) +
  ylab("number of jobs") +
  theme_classic() +
  labs(title = "Graph 1: The location distributions of full-time developer(Data & IT) jobs in Sweden on blocket.se",
       caption = "Data source: https://jobb.blocket.se/(data collected time 2023.4.24 17:00)")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
# the city names are very long
# adjust the angle of the city names displayed on the x-axis so that we can see all of them clearly

# Graph 2
# which company is the most active employer on blocket.se
ggplot(data=df) +
  geom_bar(aes(x=company), stat="count", color='black', fill='cyan') + # count "location"(city names)
  geom_text(aes(x=company, label=after_stat(count)), stat="count", vjust=-0.5) +
  ylab("number of jobs") +
  theme_classic() +
  labs(title = "Graph 2: Full-time developer(Data & IT) jobs in Sweden on blocket.se: employer activity",
       caption = "Data source: https://jobb.blocket.se/(data collected time 2023.4.24 17:00)")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 

# Graph 3
# 3.1
# Is blocket.se a good website for finding jobs?
# how many jobs are "fresh"?
# (How many jobs has a days_left_spe greater than about 10)
ggplot(data=df) +
  geom_histogram(aes(x=days_left_spe),color='black',fill='orange') +
  xlab("days left") +
  ylab("number of jobs") +
  theme_classic()+
  labs(title = "Graph 3.1: The number of full-time developer jobs in Sweden with certain days left for application on blocket.se",
       caption = "Data source: https://jobb.blocket.se/(data collected time 2023.4.24 17:00)")+
  scale_x_continuous(breaks = seq(0, max(df$days_left_spe), 5)) # let x-axis values range from 0 to the greatest value in the "days_left _spe" column
# change the "breaks" and set a step of 5 so that we can see "days_left_spe"  
# 3.2
# use "time" column
ggplot(data=df) +
  geom_bar(aes(x=time), stat="count", color='black', fill='orange') +  # count the number of "scarce and "plenty"
  geom_text(aes(x=time, label=after_stat(count)), stat="count", vjust=-0.5) + # add exact number of jobs to each bar
  xlab("time") +
  ylab("number of jobs") +
  theme_classic() +
  labs(title = "Graph 3.2: The number of full-time developer jobs in Sweden with plenty of/scarce time left for application on blocket.se",
       caption = "Data source: https://jobb.blocket.se/(data collected time 2023.4.24 17:00)")

# save the real final data frame
setwd("yourwd")
write.csv(df,"final_df_true.csv")

# save an excel version of the data frame
# I will do a screenshot of a few rows of the table/data frame and place it in appendix
# just to give an example how my data looks like
library(writexl)
write_xlsx(df, "mydata.xlsx")
