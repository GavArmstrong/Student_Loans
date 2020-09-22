Student Loans
=============

How is the existing balance of Federal Student Loans distributed across
different States in the US?

The Office of Federal Student Aid
(<a href="https://studentaid.gov/data-center" class="uri">https://studentaid.gov/data-center</a>)
provides data on the distribution of Federal Student Loans for different
geographic and demographic groups.

One such data file is Federal Student Loan Portfolio by Borrower
Location (Portfolio-by-Location.xls)

    ## # A tibble: 6 x 3
    ##   Location   `Balance (in billions)` `Borrowers (in thousands)`
    ##   <chr>                        <dbl>                      <dbl>
    ## 1 Alabama                       22.1                      600  
    ## 2 Alaska                         2.2                       65.8
    ## 3 Arizona                       29.3                      840. 
    ## 4 Arkansas                      12.2                      371. 
    ## 5 California                   138.                      3807. 
    ## 6 Colorado                      27.1                      743.

This file provides the total Direct, Federal Family Education, and
Perkins open loan amounts owed by borrowers, as well as the total number
of borrowers across each State.

From this data we can calculate the Average Federal Student Loan amount,
in an open status, owed by borrowers in each state:

    ## # A tibble: 6 x 2
    ##   State      `Average Debt per Person`
    ##   <chr>                          <dbl>
    ## 1 Alabama                       27149.
    ## 2 Alaska                        29909.
    ## 3 Arizona                       28666.
    ## 4 Arkansas                      30402.
    ## 5 California                    27628.
    ## 6 Colorado                      27413.

We want to present this data in a concise way. One way to achieve this
is using a choropleth (map disp).

There are many different packages capable of creating choropleths in R.

In this case we want to display the mainland States of the USA. The
“map”-function from the “maps” package is sufficient for our purposes.

    USA <- st_as_sf(maps::map("usa", plot=FALSE, fill=TRUE)) %>%
      mutate(ID = str_to_title(ID))

    States <- st_as_sf(maps::map("state", plot = FALSE, fill = TRUE)) %>%
      mutate(ID = str_to_title(ID)) %>%
      as_tibble() %>%
      rename(State = ID)

We can now join the loan tibble to our simple-features map multigons:

    States %<>% left_join(Loans)

Finally, we can use ggplot2 to create our choropleth:

    ggplot(USA) +
      geom_sf(fill = "antiquewhite1",
              lwd=0,
              color="black") +
      geom_sf(data=States,
              aes(geometry=geom,
                  fill=`Average Debt per Person`),
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

<img src="Debt per Student.png"/>
