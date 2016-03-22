# Integrating R with ArcGIS ====================================================
#
# Instructor: Cameron Plouffe - Higher Education Developer/Analyst, Esri Canada
# Author:     Cameron Plouffe <cplouffe@esri.ca>

# 1. Getting started -----------------------------------------------------------

# You can use the source() function to read R code from a file
# Load required helper functions
source('R/helper-functions.R')

# A character vector of the packages that are required
pkgs = c('sp', 'dplyr')

# Install and load required packages using the load_pkgs() function from the
# 'helper-functions.R' file
load_pkgs(pkgs)

# This function loads all required packages specified in a given character
# vector, but will also install any of the packages provided that have not
# already been installed on that machine. This is especially useful if an
# R-ArcGIS script or GP tool is being run on a machine for the first time, and
# the required packages have not yet been installed.

# Create a simple numeric vector of the Fibonacci sequence
fib_nums = c(0, 1, 1, 2, 3, 5, 8, 13, 21, 34)
class(fib_nums)

# Review of basic vector subsetting/indexing in R
fib_nums > 5
fib_nums[fib_nums > 5]
cond = fib_nums < 5
fib_nums[cond]
fib_nums[fib_nums != 5 & fib_nums != 0]
fib_nums[fib_nums == 0 | fib_nums == 1 | fib_nums == 2 | fib_nums == 5]
fib_nums[fib_nums %in% c(0, 1, 2, 5)]
fib_nums[!(fib_nums %in% c(0, 1, 2, 5))]

# Review of data frames

# All source data used in this webinar were obtained from the Toronto Open Data
# Catalogue and are licensed under the Open Government Licence - Toronto.

# Use base R read.csv() function to read in CSV file and create a data frame
crime_df = read.csv('data/toronto-crime.csv', stringsAsFactors = FALSE)
class(crime_df)

# You can inspect the data frame by printing it to the console, but depending
# on the size of the data frame (i.e., number of rows and columns), this can be
# very difficult to interpret
crime_df

# Instead, use the View() function to view the data frame in a more familiar
# spreadsheet-style format within RStudio
View(crime_df)

# To get a more general overview of the structure of the data frame, use
# the str() function
str(crime_df)

# Data frame subsetting/indexing examples
crime_df[crime_df$Neighbourhood == 'Yonge-St.Clair', ]
crime_df[crime_df$Arsons >= 5, ]
crime_df[crime_df$Assaults > 300 & crime_df$Assaults < 350, ]
crime_df[c(1, 2, 3), ]
ncol(crime_df)
crime_df[ , 1:3]
crime_df[ , c('Thefts', 'Arsons')]
crime_df[crime_df$Vehicle.Thefts > 100, c('AREA_S_CD', 'Neighbourhood')]

# Challenges

# a) Create a subset of the last 5 columns of crime_df
crime_df[ , (ncol(crime_df) - 4):ncol(crime_df)]

# b) Create a subset of the first 50 records of crime_df including only the
# assaults and equity score columns
crime_df[1:50, c('Equity_Score', 'Assaults')]

# c) Create a subset of all records from crime_df where there are at least
# 20 thefts, OR where there is at least 1 arson and 300 major crime incidents
crime_df[crime_df$Thefts >= 20 | (crime_df$Arsons >= 1 & crime_df$Total.Major.Crime.Incidents >= 300), ]


# 2. Manipulating data with dplyr ----------------------------------------------

# dplyr is a package designed to give users a fast, consistent tool for working
# with data frame like objects. It is an improvement on many of the base R
# methods for working with and manipulating data structures, as it is much
# faster, and also provides more (subjectively) intuitive syntax similar to SQL.

# dplyr provides a function for each basic verb of data manipulation:
#
# e.g., filter(), arrange(), select(), mutate(), summarize()
#
# Today's workshop will not be covering all of dplyr's functions, but several of
# the simpler functions will be used in conjunction with the arcgisbinding
# package to help with data manipulation.

# 2.1) filter()
# filter() allows you to subset rows from a data frame similar to base R.  The
# first argument for filter() is the data frame, and all subsequent arguments
# are conditions to filter the data frame by.
crime_df[crime_df$Neighbourhood == 'Yonge-St.Clair', ]

# This is equivalent to the following dplyr code:
filter(crime_df, Neighbourhood == 'Yonge-St.Clair')

# If you pass multiple conditions as arguments, they will be joined together
# with the & operator:
filter(crime_df, Arsons > 3, Thefts > 10)
# Otherwise, you can use standard boolean operators:
filter(crime_df, Arsons > 3 | Thefts > 10)

# More examples
filter(crime_df, AREA_S_CD %in% c(27, 118, 44, 121))
filter(crime_df, Murders != 0, Neighbourhood == 'Yonge-St.Clair')

# 2.2) arrange()
# arrange() allows you to sort rows in a data frame based on a set of
# column names provided to the function.  The first argument for
# arrange() is the data frame, and all subsequent arguments are column names
# (or more complicated expressions) to order the data frame.  Each additional
# column will be used to break ties in the preceding columns
arrange(crime_df, Arsons)

# It is much easier to understand what arrange() does by wrapping it with the
# View() function
View(arrange(crime_df, Arsons))

# If you wish to sort in descending order, you can use the desc() function
View(arrange(crime_df, desc(Arsons)))

# Sort by multiple different columns
View(arrange(crime_df, Arsons, Assaults))

# 2.3) select()
# select() allows you to select specified columns (or variables) from a data
# frame.  The first argument for select() is the data frame, and all subsequent
# argument are the columns to 'select'.
select(crime_df, AREA_S_CD, Equity_Score)

# You can also choose to remove columns from a data frame by including a
# minus (-) sign in front of the column name(s):
View(select(crime_df, -Arsons, -Assaults))


# 2.4) summarize()
# summarize() allows you to summarize values from a data frame provided a
# function, and collapse them down to a single row:
summarize(crime_df,
          mean_fire = mean(Fire.Vehicle.Incidents, na.rm = TRUE),
          total_assaults = sum(Assaults, na.rm = TRUE))

# You can also use summarize_each() to apply multiple functions
summarize_each(crime_df, c('mean', 'sum', 'sd'), Assaults)

# While this is useful for calculating summary statistics, when used in
# conjunction with the group_by() tool, it is even more powerful.

# 2.5) %>% - the forward-pipe operator
# The forward-pipe operator (%>%) allows you to pipe (i.e., send) a value
# forward into an expression or function call.  If you were to think of a
# function call as f(x), the same function call can be made using the
# forward-pipe operator using the syntax x %>% f.  If additional arguments need
# to be passed to a function, e.g., f(x, y), an equivalent function call using
# the forward-pipe operator would be x %>% f(y).

# The examples below demonstrate three ways that you can obtain the same
# results using different code:

# a) Using nested functions
View(select(crime_df, Arsons))
# b) Using variables to store intermediate values
crime_arsons = select(crime_df, Arsons)
View(crime_arsons)
# c) Using the dplyr forward-pipe operator
select(crime_df, Arsons) %>%
  View()

# As you can see, all of the examples produce the same results, and it is a
# matter of preference as to which method you choose to employ.  When dealing
# with more complex data manipulation workflows, using %>% can help produce
# easily readable code, for example:
crime_df %>%
  filter(Equity_Score > 80) %>%
  select(Neighbourhood, Thefts, Vehicle.Thefts) %>%
  arrange(Thefts, Vehicle.Thefts)

# Even if you are unfamiliar with R, interpreting this code block is relatively simple:

# i) Take the crime data frame
# ii) Filter it to rows where the equity score is greater than 80
# iii) Select the neighbourhood, thefts, and vehicle thefts columns
# iv) Sort it by thefts, and then vehicle thefts

# Here is the same workflow using nested functions:
arrange(select(filter(crime_df, Equity_Score > 80), Neighbourhood, Thefts, Vehicle.Thefts), Thefts, Vehicle.Thefts)

# and here using variables to store intermediate values:
crime_1 = filter(crime_df, Equity_Score > 80)
crime_2 = select(crime_1, Neighbourhood, Thefts, Vehicle.Thefts)
arrange(crime_2, Thefts, Vehicle.Thefts)

# While this is subjective, one could argue that using the forward-pipe
# operator produces more easily readable code as workflow complexity increases.

# 2.6) group_by
# group_by() allows you to group a data frame given a variable.  This
# grouping can then be used to apply further functions on the data frame using
# dplyr.
arson_groups = group_by(crime_df, Arsons)
summarize(arson_groups, mean_fire = mean(Fire.Vehicle.Incidents, na.rm = TRUE))

# You can see that summarize() is now doing a summary by group, which can be
# a powerful tool.  Experiment with some of the other dplyr functions to see
# how they work with grouped data.

# Challenges

# a) Create a data set containing only the neighbourhood names where there have
# been more than 100 fire vehicle incidents and less than 400 fire medical calls
crime_df %>%
  filter(Fire.Vehicle.Incidents > 100, Fire.Medical.Calls < 400) %>%
  select(Neighbourhood)

# b) Group the crime data set by number of murders, and then calculate the mean
# and standard deviation of total major crime incidents for each group
crime_df %>%
  group_by(Murders) %>%
  summarise_each(c('mean', 'sd'), Total.Major.Crime.Incidents)

# c) Find the neighbourhoods where there have been at least 30 drug arrests,
# and then return the neighbourhoods with the top 20 equity scores from that
# subset

# Hint: You will need to use your indexing skills from base R in conjunction
# with dplyr.
  crime_df %>%
    filter(Drug.Arrests >= 30) %>%
    arrange(desc(Equity_Score)) %>%
    .[1:20, ]


# 3. Spatial data handling with arcgisbinding ----------------------------------

# With the release of ArcGIS for Desktop 10.3.1 and ArcGIS Pro 1.1, Esri
# also released the the first officially supported way to integrate R with
# ArcGIS - the R-ArcGIS Bridge (https://r-arcgis.github.io/).

# Assuming that you have installed the R-ArcGIS Bridge via the ArcGIS Toolbox
# from the R-ArcGIS Bridge Github page, you can load the package using the
# library function.
library(arcgisbinding)

# Note that after loading the package, you will receive the following message
# in the R Console:
# *** Please call arc.check_product() to  define a desktop license.

# This message indicates that you will need to call the arc.check_product()
# function before you will be able to using any of the available tools and
# functions included in the R-ArcGIS Bridge.
arc.check_product()

# Now that you have authenticated your license, you can begin working with
# spatial data in R using arcgisbinding.

# The arcgisbinding package allows you to load data from a geodatabase (GDB) or
# shapefile into R, perform some sort of analysis, and then return that data set
# or some variant of it back to ArcGIS, or write it to disk.

# Note: As of now, the R-ArcGIS Bridge will only allow you to work with vector
# data.  In a future release of the bridge, there are plans to support working
# with several different ArcGIS raster data formats.

# You can read in a feature class from a GDB using the arc.open() function by
# providing a path to the feature class's location.
?arc.open

# Read in the Toronto crime feature class using arc.open():
input_fc = 'data/r-arcgis-data.gdb/toronto_crime'
tor_crime = arc.open(input_fc)

# Note: 'data/r-arcgis-data.gdb/toronto_crime' is a relative path based on your
# current working directory in R.  You can use the getwd() and setwd() functions
# to determine and set your current working directory, or if you prefer, you
# can pass the absolute path instead (e.g., C:/data/geodatabase.gdb/fc).

# Inspect the tor_crime data set:
class(tor_crime)
tor_crime

# arc.select() provides a means to load the tor_crime spatial object to an
# ArcGIS data frame.  You can optionally pass a list of fields and a where
# clause to arc.select() to filter the data before creating the ArcGIS
# data frame.
crime_fields = c('Neighbourhood', 'Hazardous_Incidents')
tor_hazard_df = arc.select(tor_crime, fields = crime_fields)
View(tor_hazard_df)

# You can also create an sp object from the ArcGIS data frame using the
# arc.data2sp() function.
tor_hazard_sp = arc.data2sp(tor_hazard_df)

# Plot the tor_crime_sp object
spplot(tor_hazard_sp)

# Access the attribute data from the sp object:
tor_hazard_sp@data

# In this tutorial, you will need all fields from the toronto-crime feature
# class, so use arc.select() to load all fields:
tor_crime_df = arc.select(tor_crime, fields = '*')

# Challenges

# a) Import the Toronto crime data set and create an ArcGIS data frame
# containing all records from neighbourhoods where the population is greater
# than 15000 (without using dplyr).

# Hint: Use the R-ArcGIS help documentation.
tor_crime_pop = arc.select(tor_crime, where_clause = 'Population > 15000')

# b) Create an sp object containing the fields for neighbourhood names and
# assaults, where the number of assaults is lower than 50.  Use spplot to
# plot the results.
assaults_fields = c('Neighbourhood', 'Assaults')

low_assaults_sp = tor_crime %>%
  arc.select(fields = assaults_fields, where_clause = 'Assaults < 50') %>%
  arc.data2sp()

spplot(low_assaults_sp)

# You can perform analysis on or edit an ArcGIS data frame, and once you are
# finished, you can write it out to a new feature class.

# Create a population density field by dividing each neighbourhood's
# population by its area:
tor_crime_df$pop_density = tor_crime_df$Population / tor_crime_df$Area

# Calculate each neighbourhood's rate of total major crime incidents per
# 1000 inhabitants:
tor_crime_df$crimes_per_1000 = (tor_crime_df$Total_Major_Crime_Incidents / tor_crime_df$Population) * 1000

# Add some new grouping variables to the ArcGIS data frame.  You can use
# the ntile() function to assign groups given a grouping variable.

# Create quartiles based on equity score and major crime incidents per 1000:
equity_quartiles = ntile(tor_crime_df$Equity_Score, 4)
major_crime_quartiles = ntile(tor_crime_df$crimes_per_1000, 4)

# Add quartiles back to the ArcGIS data frame as new columns:
tor_crime_df$equity_rank = equity_quartiles
tor_crime_df$crime_rank = major_crime_quartiles

# Calculate basic summary statistics based on majors crimes for each
# crime_rank group:
summarized_df = tor_crime_df %>%
  group_by(crime_rank) %>%
  summarize_each(c('mean', 'sum'), Total_Major_Crime_Incidents) %>%
  right_join(tor_crime_df) %>%
  select(mean, sum)

tor_crime_df$mean_crime_grouped = summarized_df$mean
tor_crime_df$total_crime_grouped = summarized_df$sum

View(tor_crime_df)

# Now that you have added new columns to the Toronto crime ArcGIS data frame,
# you can write out a new feature class containing these new columns.
# arc.write() allows you to write out a feature class (or shapefile) provided
# a location, and an ArcGIS data frame.
output_fc = 'data/r-arcgis-data.gdb/toronto_crime_grouped'
arc.write(output_fc, tor_crime_df)

# Open ArcGIS Pro and add the toronto_crime_groups feature class to your
# project.  You will see that the new grouping fields have been added to the
# feature class.

# Challenges

# a) Create a new grouping column of your choice in tor_crime_df using the
# ntile() function

# b) Create a new column in tor_crime_df adding Thefts and Vehicle
# Thefts together

# Continue learning about the R-ArcGIS Bridge and by looking through example
# R-ArcGIS script tools provided in the R folder which will be covered in
# part 2 of the webinar.
