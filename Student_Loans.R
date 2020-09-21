library(tidyverse)
library(magrittr)
library(maps)
library(sf)
library(readxl)
library(viridis)
library(extrafont)

#font_import()

library(ggplot2)

rm(list = ls())

# Set work directory
#setwd("Google Drive/Projects/Student Loans/")

# Read student loans data
Loans <- list.files(pattern="Portfolio-by-Location") %>%
  read_excel(skip=5)

# Tidy column names
names(Loans) %<>% make.names(unique=TRUE)

# Format columns
Loans %<>% select(State = Location,
                  Debt = Balance..in.billions.,
                  Borrower_Count = Borrowers..in.thousands.) %>%
  mutate(State = str_to_title(State),
         Debt_per_Person = Borrower_Count*1000/Debt)

# Drop non-States
Loans %<>% filter(!is.na(Debt_per_Person) &
                    State != "Other" &
                    State != "Not Reported")

# Dark-on-light theme for maps
theme_set(theme_bw())

# Read USA multipolygons from the Maps package
USA <- st_as_sf(maps::map("usa", plot=FALSE, fill=TRUE)) %>%
  mutate(ID = str_to_title(ID))

# Read State multipolygons from the Maps package
States <- st_as_sf(maps::map("state", plot = FALSE, fill = TRUE)) %>%
  mutate(ID = str_to_title(ID)) %>%
  as_tibble() %>%
  rename(State = ID) %>%
  filter(State != "District Of Columbia")

# Join States and Loans
States %<>% left_join(Loans)

# Simple plot of State boundaries
Debt_per_Student <- ggplot(USA) +
  geom_sf(fill = "antiquewhite1",
          lwd=0,
          color="black") +
  geom_sf(data=States,
          aes(geometry=geom,
              fill=Debt_per_Person),
          lwd=0.2,
          color="#002240") +
  scale_fill_gradient(low = "#61ff5e",
                      high = "#ea1730",
                      labels=list("$24,000", "$26,000", "$28,000",
                                  "$30,000", "$32,000", "$34,000")) +
  ggtitle("Average Federal Student Loan Debt by State (April, 2020)",
          subtitle = bquote(bold("Source:") ~"https://studentaid.gov/data-center/student/portfolio")) +
  theme(axis.ticks = element_blank(),
        axis.text = element_blank(),
        panel.grid.major = element_blank(),
        panel.background = element_rect(fill = "#002240"),
        plot.background = element_rect(fill = "#002240"),
        legend.text = element_text(color = "white",
                                   family="Arial",
                                   size=7),
        legend.title = element_blank(),
        legend.key.size = unit(0.55,"cm"),
        legend.justification=c(1,0), 
        legend.position=c(0.95, 0.05),  
        legend.background = element_blank(),
        plot.title = element_text(color="white",
                                  family="Arial Rounded MT Bold",
                                  size=12),
        plot.subtitle = element_text(color="white",
                                     family="Arial",
                                     size=7))


ggsave("Debt per Student.png", device="png", width=6.4, height=4)
