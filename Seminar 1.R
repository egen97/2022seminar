library(tidyverse)
library(stortingscrape) 
library(rvest) 


blairIraq <- read_html("https://www.theguardian.com/politics/2003/mar/18/foreignpolicy.iraq1", encoding = "utf-8")  %>% 
  html_nodes(xpath = "//*[@id='maincontent']/div") %>% 
  html_text2()


