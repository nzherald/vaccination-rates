


download_spreadsheets <- function() {
    dl <- function(x) {
        fname <- str_split(x, "/") %>% last() %>% last()
        download.file(paste0(host, x), fname)
        return(fname)
    }
    host <- "https://www.health.govt.nz"
    page <- read_html(paste0(host,
              "/our-work/preventative-health-wellness/immunisation/immunisation-coverage/national-and-dhb-immunisation-data"))
    month3sheets <- ((page %>% html_nodes('.field-items ul'))[2]) %>% html_nodes('a') %>% html_attr('href')
    map(month3sheets, dl)
}

fileToDate <- function(f) {
case_when(
  f == "imm-t1-stats-3-month-period-08apr2019-140817.xlsx" ~ 'Mar 2019',
  f == "immunisation-tier-1-statistics-3-month-period-31-dec-2018.xlsx" ~ 'Dec 2018',
  f == "immunisation-tier-1-stats-3-month-period-08oct2018.xlsx" ~ 'Sep 2018',
  f == "immunisation-tier-1-stats-3-month-period-11jul18.xlsx" ~ 'Jun 2018',
  f == "immunisation_tier_1_stats_3_month_period_31_march_2018_final.xlsx" ~ 'Mar 2018',
  f == "immunisation-three-months-31-dec-2017.xlsx" ~ 'Dec 2017',
  f == "immunisation_tier_1_stats_3_month_period_10oct2017_103549.xlsx" ~ 'Sep 2017',
  f == "tier_1_immunisation_data_1_april_2017_to_30_june_2017.xlsx" ~ 'Jun 2017',
  f == "immunisation-3-month-period-12apr2017-100502.xlsx" ~ 'Mar 2017',
  f == "immunisation-t1-stats-3month-period-q2-31dec2016-final.xlsx" ~ 'Dec 2016',
  f == "immunisation-t1-stats-3month-period-11oct2016-163555.xlsx" ~ 'Sep 2016',
  f == "imm-tier-1-stats-3-month-period-q4-june-2016_0.xlsx" ~ 'Jun 2016',
  f == "imms-tier1-stats-3-month-period-q3-march-2016.xls" ~ 'Mar 2016',
  f == "imms-tier1-stats-webpage-data-3-month-period-q2-dec2015.xls" ~ 'Dec 2015',
  f == "imms-stats-3-month-period-sept-2015.xls" ~ 'Sep 2015',
  f == "immunisation-3months-june-2015.xls" ~ 'Jun 2015',
  f == "imms-data-3-month-period-q3-mar2015.xls" ~ 'Mar 2015',
  f == "immunisation_tier_1_stats_webpage_3month_report_dec_2014.xls" ~ 'Dec 2014',
  f == "immunisation-3months-september_2014_0.xls" ~ 'Sep 2014',
  f == "immunisation-3months-june_2014.xls" ~ 'Jun 2014',
  f == "immunisation-3months-march_2014.xls" ~ 'Mar 2014',
  f == "immunisation-3months-dec-2013.xls" ~ 'Dec 2013',
  f == "immunisation-3months-sep2013.xls" ~ 'Sep 2013',
  f == "immunisation-3months-june_2013_1.xls" ~ 'Jun 2013',
  f == "immunisation-3months-march2013.xls" ~ 'Mar 2013',
  f == "immunisation-3months-dec2012.xls" ~ 'Dec 2012',
  f == "immunisation-3months-september2012.xls" ~ 'Sep 2012',
  f == "immunisation-3months-jun2012.xls" ~ 'Jun 2012',
  f == "immunisation-3months-mar2012.xls" ~ 'Mar 2012',
  f == "immunisation-3months-dec2011.xls" ~ 'Dec 2011',
  f == "immunisation-3months-sep2011.xls" ~ 'Sep 2011',
  f == "immunisation-3months-jun2011.xls" ~ 'Jun 2011',
  f == "immunisation-3months-mar2011.xls" ~ 'Mar 2011',
  f == "immunisation-3months-dec2010_0.xls" ~ 'Dec 2010',
  f == "immunisation-3months-sep2010.xls" ~ 'Sep 2010',
  f == "immunisation-3months-jun2010.xls" ~ 'Jun 2010',
  f == "immunisation-3months-mar2010.xls" ~ 'Mar 2010',
  f == "immunisation-3months-dec2009.xls" ~ 'Dec 2009',
  f == "immunisation-3months-jun2009.xls" ~ 'Jun 2009',
  TRUE ~ f)
}


ingest_spreadsheets <- function(files) {
    fixup <- function(x) {
        x %>% gather(Category, Value, -DHB) %>%
                 mutate(Measure=case_when(
                                         str_detect(Category, 'Eligible') ~ 'Eligible',
                                           str_detect(Category, 'Immunised') ~ 'Immunised',
                                           str_detect(Category, 'Percentage') ~ 'Percentage',
                                           TRUE ~ Category),
                         Category=str_remove(Category, 'Eligible|Immunised|Percentage') %>%
                             str_trim())
    }
    ingest <- function(f) {
        read <- function(i,s) {
            ethnicity <- readxl::read_excel(f, sheet=i, range="A9:S29",
                               col_names=c("DHB",
                                           "Total Eligible", "Total Immunised", "Total Percentage",
                                           "NZE Eligible", "NZE Immunised", "NZE Percentage",
                                           "Maori Eligible", "Maori Immunised", "Maori Percentage",
                                           "Pacific Eligible", "Pacific Immunised", "Pacific Percentage",
                                           "Asian Eligible", "Asian Immunised", "Asian Percentage",
                                           "Other Eligible", "Other Immunised", "Other Percentage"
                                ), col_types = c("text", rep("numeric", 18)), na=c("ns", "n/s", "-")) %>%
                fixup()
                 
            dep <- readxl::read_excel(f, sheet=i, range="A34:S54",
                               col_names=c("DHB",
                                           "Dep 1-2 Eligible", "Dep 1-2 Immunised", "Dep 1-2 Percentage",
                                           "Dep 3-4 Eligible", "Dep 3-4 Immunised", "Dep 3-4 Percentage",
                                           "Dep 5-6 Eligible", "Dep 5-6 Immunised", "Dep 5-6 Percentage",
                                           "Dep 7-8 Eligible", "Dep 7-8 Immunised", "Dep 7-8 Percentage",
                                           "Dep 9-10 Eligible", "Dep 9-10 Immunised", "Dep 9-10 Percentage",
                                           "Dep Unknown Eligible", "Dep Unknown Immunised", "Dep Unknown Percentage"
                                ), col_types = c("text", rep("numeric", 18)), na=c("ns", "n/s", "-")) %>%
            fixup()

            return(bind_rows(mutate(ethnicity, Breakdown='Ethnicity'),
                             mutate(dep, Breakdown='Deprivation')))
        }
        sheet_names <- readxl::excel_sheets(f)
        sheets <- imap(sheet_names, read) %>%
            map2_dfr(sheet_names,
                     ~mutate(.x, Milestone=str_remove(.y, ' \\(2\\)') %>% str_to_lower(),
                             Quarter=fileToDate(f) %>% as.yearmon() %>% as.Date()))
        return(sheets)
    }
    map_dfr(files, ingest)
}
