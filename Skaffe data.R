#Pakke fra Martin/Notebooken om API
library(stortingscrape) 
library(rvest) 





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

#Stortinget API
spr_time <- stortingscrape::get_question_hour(300) #Henter spørsmål herifra https://www.stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/1997-1998/980520/ordinarsporretime/
cat(spr_time$question_time$question_text)          #Hvorfor id 300? No clue


#Ruter API
if(file.exists("./data/ruter.xml") == FALSE){
  download.file(url = "https://api.entur.io/realtime/v1/rest/et?datasetId=RUT",
                destfile = "sma_filer/ruter.xml")
}

ruter <- read_html("sma_filer/ruter.xml")




stopp <- ruter %>% html_elements("recordedcall")

# For hvert av disse elementene lager vi en tibble()
# (merk at bare UNIX-systemer kan bruke flere kjerner enn 1)
# Dette tar litt tid å kjøre
alle_stopp <- lapply(stopp, function(x){
  
  
  tibble::tibble(
    stop_id = x %>% html_elements("stoppointref") %>% html_text(),
    order = x %>% html_elements("order") %>% html_text(),
    stopp_name = x %>% html_elements("stoppointname") %>% html_text(),
    aimed_dep = x %>% html_elements("aimeddeparturetime") %>% html_text(),
    actual_dep = x %>% html_elements("actualdeparturetime") %>% html_text()
  )
}  
)  
  


alle_stopp <- bind_rows(alle_stopp)


