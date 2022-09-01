#Pakke fra Martin/Notebooken om API
library(stortingscrape) 
library(rvest) 
library(academictwitteR)


spr_time <- stortingscrape::get_question_hour(300) #Henter spørsmål herifra https://www.stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/1997-1998/980520/ordinarsporretime/
cat(spr_time$question_time$question_text)          #Hvorfor id 300? No clue



#Lese fra nettside: NB, bruker xpath her, Martin did something else  funny stuff dunno

#Prime minister Tony Blair's speech opening today's debate on the Iraq crisis in the house of Commons

blairIraq <- read_html("https://www.theguardian.com/politics/2003/mar/18/foreignpolicy.iraq1", encoding = "utf-8")  %>% 
  html_nodes(xpath = "//*[@id='maincontent']/div") %>% 
  html_text2()

# Laste ned med selector

download.file("https://www.theguardian.com/politics/2003/mar/18/foreignpolicy.iraq1", destfile = "sma_filer/blair_download.html")

blairDownloaded <- read_html("sma_filer/blair_download.html") %>% 
  html_node("#maincontent > div") %>% 
  html_text(trim = TRUE)


writeLines(blairIraq, "sma_filer/blairIraq.txt")

BlairTxT <- readLines("sma_filer/blairIraq.txt")

##Just to show, Twitter (min API nøkell)

set_bearer() #Skriv inn denne AAAAAAAAAAAAAAAAAAAAAPBrggEAAAAADBzvp4FvfyDOkrv1wjNTeTr9jWI%3D68WZraxTObFo3yShgYRmfe40GNGGTQkTwRscXK3oOz0KAOLkCi
get_bearer()

tweets_ <-
  get_all_tweets('(#textanalysis OR #textastweet_data OR (computational text analysis))',
                 "2022-07-20T12:00:00Z",
                 "2022-07-25T00:00:00Z",
                  data_path = "tweets/", #Storage in memory
                 bind_tweets = FALSE,
                 lang="en",
                 bearer_token = "AAAAAAAAAAAAAAAAAAAAAPBrggEAAAAAtPjkwlqhC1R%2FUrRXSja1QxtlGkg%3DquL5lphTM9KjbLvA5gV3ZYcLLAlMF2HmXQ2zizd2TOnOsdcJIc",
                 n = 1, 
                 verbose = TRUE)

