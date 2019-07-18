library(drake)
suppressMessages(library(tidyverse))
library(ggthemes)
suppressMessages(library(scales))
suppressMessages(library(rvest))
library(stringr)
suppressMessages(library(zoo))
suppressMessages(library(sf))
library(r2d3)
suppressMessages(library(lubridate))
library(openssl)
library(lubridate)

source("./scrape.R")


# ogr2ogr au-small.shp area-unit-2015-v1-00-clipped.shp -simplify 1000

base_plan <- drake_plan(
    lookup = read_tsv(file_in('Annual Areas 2018.txt')) %>%
        group_by(AU2013_code, AU2013_name, HDOM2013_code) %>%
        summarise(),
    au_shp = st_read(file_in('au-small.shp'), stringsAsFactors=F),
    au_dep = read_tsv(file_in('otago069931.txt')),
    oia_data = readxl::read_excel(file_in('H201901387 Data.xlsx'), sheet=2) %>%
        left_join(lookup, by=c("DOMICILE_CODE"="HDOM2013_code")) %>%
        left_join(au_dep, by=c("AU2013_code"="CAU_2013")),
    oia_data_geo = oia_data %>% inner_join(au_shp %>% mutate(AU2015_V1_=as.numeric(AU2015_V1_)),
                                           by=c("AU2013_code"="AU2015_V1_"))
)

initial_plan <- drake_plan(
    whole_dom = oia_data %>%
        group_by(AU2013_code,DHB_NAME,DOMICILE_NAME,CAU_average_NZDep2013) %>%
        summarise(Rate=mean(NUMBER_FULLY_IMMUNISED/NUMBER_ELIGIBLE)) %>%
        mutate(Dep.Label=sprintf("%02d",CAU_average_NZDep2013)) %>%
        arrange(Rate),
    initialPlot =  ggplot(whole_dom, aes(x=Dep.Label,y=Rate)) +
        geom_point(position="jitter") +
        geom_boxplot() +
        ylab("Rate") +
        xlab("Deprivation") +
        scale_y_continuous(labels=percent) +
        theme_fivethirtyeight(),
    initialPlot1 = initialPlot + 
        labs(title="Immunisation rate vs Deprivation",
            subtitle="All DHBs"),
    initialPlot2 = initialPlot  + 
            labs(title="Immunisation rate vs Deprivation",
                subtitle="By DHB") +
            geom_smooth() +
            facet_wrap(. ~ DHB_NAME,ncol=3),
    fitted_facets = ggplot(whole_dom, aes(x=CAU_average_NZDep2013,y=Rate)) +
        theme_fivethirtyeight() +
        geom_point() +
        geom_smooth() +
        facet_wrap(. ~ DHB_NAME,ncol=3)  +
        scale_y_continuous(labels=percent) +
        labs(title="Immunisation rate vs Deprivation",
            subtitle="Fitted curve for each DHB")
)

questions_plan <- drake_plan(
    month6 = oia_data %>% filter(AGE_IN_MONTHS == 6, MILESTONE_YEAR == 2018) %>%
        mutate(Rate=NUMBER_FULLY_IMMUNISED/NUMBER_ELIGIBLE),
    month12 = oia_data %>% filter(AGE_IN_MONTHS == 12, MILESTONE_YEAR == 2018) %>%
        mutate(Rate=NUMBER_FULLY_IMMUNISED/NUMBER_ELIGIBLE),
    month18 = oia_data %>% filter(AGE_IN_MONTHS == 18, MILESTONE_YEAR == 2018) %>%
        mutate(Rate=NUMBER_FULLY_IMMUNISED/NUMBER_ELIGIBLE),
    month24 = oia_data %>% filter(AGE_IN_MONTHS == 24, MILESTONE_YEAR == 2018) %>%
        mutate(Rate=NUMBER_FULLY_IMMUNISED/NUMBER_ELIGIBLE),
    month60 = oia_data %>% filter(AGE_IN_MONTHS == 60, MILESTONE_YEAR == 2018) %>%
        mutate(Rate=NUMBER_FULLY_IMMUNISED/NUMBER_ELIGIBLE),
    overall18 = oia_data %>% 
        filter(MILESTONE_YEAR == 2018) %>%
        group_by(AU2013_code,DHB_NAME,DOMICILE_NAME,CAU_average_NZDep2013) %>%
        summarise(Rate=mean(NUMBER_FULLY_IMMUNISED/NUMBER_ELIGIBLE)) %>%
        mutate(Dep.Label=sprintf("%02d",CAU_average_NZDep2013)) %>%
        arrange(Rate) %>%
        ungroup(),
    downloads = download_spreadsheets(),
    reports = ingest_spreadsheets(downloads) %>%
        mutate(Milestone = case_when(Milestone == '6 months' ~ '06 months',
                                     Milestone == '8 months' ~ '08 months',
                                     TRUE ~ Milestone),
               DHB = case_when(DHB == 'Capital and Coast' ~ 'Capital & Coast',
                               DHB == 'MidCentral' ~ 'Midcentral',
                               TRUE ~ DHB),
               Category = case_when(Category == 'Maori' ~ 'Māori',
                                    Category == 'NZE' ~ 'Pākehā',
                                    TRUE ~ Category)) %>%
        filter(!(DHB %in% c('Otago', 'Southland')), Quarter > as.Date("2011-06-01"))
    )

output_plan <- drake_plan(
    ethnicity.json = reports %>%
     filter(Milestone=='06 months', Breakdown=='Ethnicity', Measure=='Percentage') %>%
     select(Category, Value, Quarter, DHB) %>%
     arrange(DHB, Category) %>%
     split(.$DHB) %>%
     map(~select(., -DHB) %>%
         split(.$Category) %>%
         map(~select(., -Category) %>%
             arrange(Quarter))) %>%
     as_d3_data() %>%
     jsonlite::toJSON(),
    ethnicity.json.file = paste0('./interactive/static/ethnicity.',
                           md5(ethnicity.json),
                           '.json'),
    ethnicity.json.out = ethnicity.json %>% write(file_out(ethnicity.json.file)),
    ethnicity.json.srcout = ethnicity.json %>% write(file_out('~/nzme/vaccination-rates/interactive/src/ethnicity.json')),
    deprivation.json = reports %>%
     filter(Milestone=='06 months', Breakdown=='Deprivation', Measure=='Percentage') %>%
     select(Category, Value, Quarter, DHB) %>%
     arrange(DHB, Category) %>%
     split(.$DHB) %>%
     map(~select(., -DHB) %>%
         split(.$Category) %>%
         map(~select(., -Category) %>%
             arrange(Quarter))) %>%
     jsonlite::toJSON(),
    deprivation.jsonfile = paste0('./interactive/static/deprivation.', md5(deprivation.json), '.json'),
    deprivation.json.out = deprivation.json %>% write(file_out(deprivation.jsonfile)),
    deprivation.json.srcout = deprivation.json %>% write(file_out('./interactive/src/deprivation.json')),
    config.json = write(list(ethnicity=paste0("ethnicity.",
                                              md5(ethnicity.json),
                                              ".json"),
                             deprivation=paste0("deprivation.",
                                              md5(deprivation.json),
                                              ".json")) %>% jsonlite::toJSON(auto_unbox=T),
                        './interactive/src/config.json'),

    regions_ethnicity.xlsx = reports %>%
        filter(DHB %in% c('Lakes', 'Northand', 'Bay of Plenty', 'Northland', 'Hawkes Bay',
                          'National', 'Whanganui')) %>%
        filter(Milestone=='06 months',
               Breakdown=='Ethnicity',
               Measure=='Percentage',
               Quarter == "2015-12-01" | Quarter == "2019-03-01") %>%
        select(DHB,`Vaccination Rate`=Value,Quarter,Ethnicity=Category) %>%
        mutate(Quarter=format(Quarter, '%B %Y'), `Vaccination Rate`=percent(`Vaccination Rate`)) %>%
        spread(Quarter, `Vaccination Rate`) %>%
        split(.$DHB) %>%
        writexl::write_xlsx('regions ethnicity.xlsx'),
    regions_deprivation.xlsx = reports %>%
        filter(DHB %in% c('Lakes', 'Northand', 'Bay of Plenty', 'Northland', 'Hawkes Bay',
                          'National', 'Whanganui')) %>%
        filter(Milestone=='06 months',
               Breakdown=='Deprivation',
               Measure=='Percentage',
               Quarter == "2015-12-01" | Quarter == "2019-03-01") %>%
        select(DHB,`Vaccination Rate`=Value,Quarter,Deprivation=Category) %>%
        mutate(Quarter=format(Quarter, '%B %Y'), `Vaccination Rate`=percent(`Vaccination Rate`)) %>%
        spread(Quarter, `Vaccination Rate`) %>%
        split(.$DHB) %>%
        writexl::write_xlsx('regions depivation.xlsx')

)

plan <- bind_rows(base_plan, initial_plan, questions_plan, output_plan)

config <- drake_config(plan)
