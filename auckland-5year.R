library(tidyverse)

data2018 <- drake::readd(oia_data) %>%
    filter(MILESTONE_YEAR=='2018', AGE_IN_MONTHS==60)
data2010 <- drake::readd(oia_data) %>%
    filter(MILESTONE_YEAR=='2010', AGE_IN_MONTHS==60)
data2011 <- drake::readd(oia_data) %>%
    filter(MILESTONE_YEAR=='2011', AGE_IN_MONTHS==60)
data2012 <- drake::readd(oia_data) %>%
    filter(MILESTONE_YEAR=='2012', AGE_IN_MONTHS==60)
data2009_2 <- drake::readd(oia_data) %>%
    filter(MILESTONE_YEAR=='2009', AGE_IN_MONTHS==24)

areas <- read_tsv('Annual Areas 2018.txt') %>%
    filter(TA2018_name == 'Auckland') %>%
    group_by(TA2018_name, CB2018_name, HDOM2013_code) %>%
    summarise() %>%
    group_by(HDOM2013_code) %>%
    summarise(CB2018_name=sample(CB2018_name,1)) 


wards <- read_tsv('Annual Areas 2018.txt') %>%
    filter(TA2018_name == 'Auckland') %>%
    group_by(TA2018_name, WARD2018_name, HDOM2013_code) %>%
    summarise()

a2009_2 <- areas %>%
  inner_join(data2009_2, by=c("HDOM2013_code"="DOMICILE_CODE")) %>%
  group_by(CB2018_name) %>%
  summarise(Kids=sum(NUMBER_ELIGIBLE), Vaccinated=sum(NUMBER_FULLY_IMMUNISED)) %>%
  mutate(`Not Vaccinated`=Kids-Vaccinated, Rate=`Not Vaccinated`/Kids*100) %>%
  arrange(-`Not Vaccinated`) %>%
  mutate(CB2018_name=str_remove(CB2018_name, ' Area')) %>%
  select(CB2018_name, `Not Vaccinated`, Vaccinated, Kids, Rate) 

a2009_2 %>% write_csv('auckland-5years-2009_2.csv')

a2010 <- areas %>%
  inner_join(data2010, by=c("HDOM2013_code"="DOMICILE_CODE")) %>%
  group_by(CB2018_name) %>%
  summarise(Kids=sum(NUMBER_ELIGIBLE), Vaccinated=sum(NUMBER_FULLY_IMMUNISED)) %>%
  mutate(`Not Vaccinated`=Kids-Vaccinated, Rate=`Not Vaccinated`/Kids*100) %>%
  arrange(-`Not Vaccinated`) %>%
  mutate(CB2018_name=str_remove(CB2018_name, ' Area')) %>%
  select(CB2018_name, `Not Vaccinated`, Vaccinated, Kids, Rate) 

a2010 %>% write_csv('auckland-5years-2010.csv')

a2011 <- areas %>%
  inner_join(data2011, by=c("HDOM2013_code"="DOMICILE_CODE")) %>%
  group_by(CB2018_name) %>%
  summarise(Kids=sum(NUMBER_ELIGIBLE), Vaccinated=sum(NUMBER_FULLY_IMMUNISED)) %>%
  mutate(`Not Vaccinated`=Kids-Vaccinated, Rate=`Not Vaccinated`/Kids*100) %>%
  arrange(-`Not Vaccinated`) %>%
  mutate(CB2018_name=str_remove(CB2018_name, ' Area')) %>%
  select(CB2018_name, `Not Vaccinated`, Vaccinated, Kids, Rate) 

a2011 %>% write_csv('auckland-5years-2011.csv')

a2018 <- areas %>%
  inner_join(data2018, by=c("HDOM2013_code"="DOMICILE_CODE")) %>%
  group_by(CB2018_name) %>%
  summarise(Kids=sum(NUMBER_ELIGIBLE), Vaccinated=sum(NUMBER_FULLY_IMMUNISED)) %>%
  mutate(`Not Vaccinated`=Kids-Vaccinated, Rate=`Not Vaccinated`/Kids*100) %>%
  arrange(-`Not Vaccinated`) %>%
  mutate(CB2018_name=str_remove(CB2018_name, ' Area')) %>%
  select(CB2018_name, `Not Vaccinated`, Vaccinated, Kids, Rate) 

a2018 %>% write_csv('auckland-5years-2018.csv')

ata2010 %>% group_by(DHB_NAME) %>% summarise(Kids=sum(NUMBER_ELIGIBLE),Vacc=sum(NUMBER_FULLY_IMMUNISED)) %>% mutate(Missing=Kids-Vacc,Rate=Vacc/Kids) %>% pull(Missing) %>% sum()

moh2010 <- readxl::read_excel('immunisation-12months-sep2010.xls')
