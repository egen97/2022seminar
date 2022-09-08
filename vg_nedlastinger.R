
library(rvest)
library(tidyverse)
library(stringr)





base_url <- "https://arkivet.vg.no/"

#download.file("https://arkivet.vg.no/index.php?selSearch=fulltextSearchAdv&sortby=relevance&fulltext=&dato=&fulltextadv=storting&side=&datofra=07.09.2021&datotil=07.09.2022", destfile = "vgfil.html")


vg_link <- read_html("vgfil.html") %>%
  html_nodes("tr:nth-child(2)  td  a") %>%
  html_attr("href")


komplette_linker <- str_c(base_url, vg_link)
#Ser at de første tre linkene ikke leder til noe
komplette_linker <- komplette_linker[-c(1,2,3)]

for(i in seq_along(komplette_linker)){
  
  download.file(komplette_linker[i], 
                destfile = paste("vg", i, ".html", sep = ""))
}

##### Eksempel med Wikipedia ####

base_url <- "https://en.wikipedia.org"

download.file("https://en.wikipedia.org/wiki/List_of_Latin_phrases_(A)", destfile = "sma_filer/latWiki.html")







wiki_link <- read_html("sma_filer/latWiki.html") %>% 
  html_nodes("div  table  tbody tr  td  i a") %>% 
  html_attr("href")


download.file(str_c(base_url, wiki_link[2]), destfile = "sma_filer/wiki/test.html")

komplette_linker2 <- str_c(base_url, wiki_link[2:135])

for(i in seq_along(komplette_linker)){
  
  tryCatch({ #tryCatch gjør at for-loopen fortsetter selvom noen av linkene ikke fungerer. Hvilke printes i konsollen
    download.file(komplette_linker[i], 
                destfile = paste0("sma_filer/wiki/wikiLatin", i, ".html")
                )}, error = function(e){cat("ERROR :",conditionMessage(e), "\n")}
    
    )
}


wiki_sider <- list.files("sma_filer/wiki/", full.names = TRUE)

wiki_text <- list()

for (i in 1:length(wiki_sider)) { 
  
  page <- read_html(wiki_sider[i]) 
  
  page <- page %>% 
    html_elements("p") %>% 
    html_text2() 
  
  wiki_text[[i]] <- page # Plasser teksten inn på sin respektive plass i info-objektet
  
}

cat(wiki_text[[7]][1])
