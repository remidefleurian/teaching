# TIDYVERSE --------------------------------------------------------------------
# coherent system of consistent functions with shared design philosophy:
#   - functions are designed around "tidy data",
#   - always use dataframe as first argument,
#   - and are chained together with pipe operator
# advantages:
#   - focus on human readability (i.e. good for sharing)
#   - easier to teach than base R
#   - active community
# limitations:
#   - opinionated (focus on rectangular, tidy data)
#   - not always the fastest
#   - work in progress!

library(tidyverse)

# TIBBLE -----------------------------------------------------------------------
# for data frames with stricter checking and better printing

# as_tibble
iris
df <- as_tibble(iris)
df 

# str vs. glimpse
str(df)
glimpse(df)

# READR ------------------------------------------------------------------------
# for hassle-free and fast importing (though data.table is faster)

# read_csv (also, read_tsv, read_delim, read_table, read_log, etc.)
read_csv(readr_example("mtcars.csv"))

# col_types
read_csv(readr_example("mtcars.csv"),
         col_types = cols(am = col_logical()))

# compact col_types
read_csv(readr_example("mtcars.csv"), col_types = "didi_ddii?i")

# TIDYR ------------------------------------------------------------------------
# for convenient data reshaping/tidying
# tidy data:
#   - each column is a variable
#   - each row is an observation

# "messy" data
df <- tibble(
  song = c("song 1", "song 2", "song 3", "song 4", "song 5"),
  chills_1 = c("00:30", "01:20", "00:45", "02:50", "03:20"),
  chills_2 = c("02:15", "01:30", "01:20", NA, NA),
  chills_3 = c("00:20", "02:15", NA, NA, NA)
)
df

# gather
df_long <- gather(df, 
                  key = chills, 
                  value = time, 
                  chills_1:chills_3, 
                  na.rm = TRUE)
df_long

# spread
spread(df_long, 
       key = chills,
       value = time)

# separate
df_sep <- separate(df_long,
                   time,
                   into = c("min", "sec"),
                   sep = ":")

# unite
unite(df_sep, 
      time, 
      min:sec, 
      sep = ":")

# DPLYR ------------------------------------------------------------------------
# for fast, human-readable manipulation of data frames and remote database
# based on using small set of verbs and pipe operator
# pipe operator:
#   - %>%, from magrittr package
#   - pipes the output into the first argument of the next function
#   - good to avoid creating intermediate objects or using nested functions
#   - f(x) is eauivalent to x %>% f()

# data
starwars
glimpse(starwars)

# filter
starwars %>% filter(height >= 180)
starwars %>% filter(species %in% c("Droid", "Human"))
starwars %>% filter(str_detect(name, "^R"))

# select
starwars %>% select(name, height)
starwars %>% select(mass:species)
starwars %>% select(-species)
starwars %>% select(ends_with("color"))

# mutate
starwars %>% mutate(bmi = mass / ((height / 100) ^ 2))
starwars %>% mutate(age = if_else(birth_year + 34 >= 100, "old", "young"))
starwars %>% mutate(type = case_when(height > 200 | mass > 200 ~ "large",
                                     species == "Droid" ~ "robot",
                                     TRUE ~ "other"))  

# arrange
starwars %>% arrange(height)
starwars %>% 
  mutate(bmi = mass / ((height / 100) ^ 2)) %>% 
  select(name, bmi) %>%
  arrange(desc(bmi))
  
# group_by and summarise
starwars %>% 
  group_by(homeworld) %>% 
  summarise(height_avg = mean(height))
starwars %>% 
  group_by(homeworld, species) %>%
  count() %>%
  arrange(desc(n))

# combining it all
starwars %>% 
  filter(!is.na(mass),
         !is.na(height)) %>%
  mutate(bmi = mass / ((height / 100) ^ 2)) %>%
  group_by(species) %>%
  summarise(n = n(),
            bmi_avg = mean(bmi, na.rm = TRUE)) %>%
  filter(n > 1) %>%
  arrange(bmi_avg)

# also, joins
?dplyr::join

# PURRR ------------------------------------------------------------------------
# for robust functional programming to iterate over lists or data frame columns

# type-stable methods 
mtcars %>% map(sum)
mtcars %>% map_dbl(sum)
iris %>% map_dbl(max)
iris %>% 
  select(-Species) %>% 
  map_dbl(max)

# map2 for two arguments
map2_dbl(-5:5, 0:10, ~ .x + .y)

# pmap for unlimited arguments
list(x = c("apple", "banana", "cherry"),
     pattern = c("p", "n", "h"),
     replacement = c("x", "f", "q")) %>%
  pmap_chr(gsub)

# linear models on mtcars: base R vs. purrr
results <- c()
for (cyl in unique(mtcars$cyl)) {
  fit <- lm(mpg ~ wt, data = mtcars[mtcars$cyl == cyl,])
  result <- summary(fit)[["r.squared"]]
  names(result) <- cyl
  results <- c(results, result)
}
results

mtcars %>%
  split(.$cyl) %>%
  map(~ lm(mpg ~ wt, data = .)) %>%
  map(summary) %>%
  map_dbl("r.squared")

# GGPLOT2 ----------------------------------------------------------------------
# for a consistent and very flexible grammar of graphics over all types of plots
# careful - written before the pipe, so not perfectly integrated with tidyverse
# arguments:
#   - dataset
#   - aesthetic mapping (axes, groups, etc.)
#   - layers (geom_point, geom_line, etc.)

# basic example 
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

# available mappings
# -- colour
ggplot(mpg) + 
  geom_point(aes(displ, hwy, colour = class))
# -- shape
ggplot(mpg) + 
  geom_point(aes(displ, hwy, shape = class))
# -- alpha
ggplot(mpg) + 
  geom_point(aes(displ, hwy, alpha = class))
# -- size
ggplot(mpg) + 
  geom_point(aes(displ, hwy, size = class))
# -- and many others
ggplot2:::.all_aesthetics

# set aesthetic properties manually, outside aes()
ggplot(mpg) + 
  geom_point(aes(displ, hwy), colour = "blue")

# layers can be stacked
ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(colour = class)) +
  geom_smooth()

# plots can be flipped
ggplot(mpg, aes(class, hwy)) + 
  geom_boxplot() +
  coord_flip()

# or faceted
ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  facet_wrap(~ class, nrow = 2)
ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  facet_grid(drv ~ cyl)

# OTHERS -----------------------------------------------------------------------
# stringr, for manipulation of strings
# forcats, for categorical variable handling
# lubridate and hms, for manipulating dates and times

# RESOURCES --------------------------------------------------------------------
# Book - R for Data Science: http://r4ds.had.co.nz/ 
# Modeling - tidymodels: https://github.com/tidymodels/tidymodels
# Reference - ggplot2: https://ggplot2.tidyverse.org/reference/
# Cheatsheet - readr/tidyr: https://github.com/rstudio/cheatsheets/blob/master/data-import.pdf
# Cheatsheet - dplyr: https://github.com/rstudio/cheatsheets/blob/master/data-transformation.pdf
# Cheatsheet - purrr: https://github.com/rstudio/cheatsheets/blob/master/purrr.pdf
# Cheatsheet - ggplot2: https://github.com/rstudio/cheatsheets/blob/master/data-visualization-2.1.pdf
# Cheatsheet - stringr: https://github.com/rstudio/cheatsheets/blob/master/strings.pdf