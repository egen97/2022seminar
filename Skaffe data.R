#Pakke fra Martin/Notebooken om API
#install.packages("stortingscrape")
library(stortingscrape) 
library(rvest) 


spr_time <- stortingscrape::get_question_hour(300) #Henter spørsmål herifra https://www.stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/1997-1998/980520/ordinarsporretime/
cat(spr_time$question_time$question_text)          #Hvorfor id 300? No clue



#Lese fra nettside: NB, bruker xpath her, Martin did something else  funny stuff dunno

#Prime minister Tony Blair's speech opening today's debate on the Iraq crisis in the house of Commons

blairIraq <- read_html("https://www.theguardian.com/politics/2003/mar/18/foreignpolicy.iraq1", encoding = "utf-8")  %>% 
  html_nodes(xpath = "//*[@id='maincontent']/div") %>% 
  html_text2()
