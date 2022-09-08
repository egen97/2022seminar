#install.packages("newsanchor")
library(newsanchor) #Pakke for å bruke API'n 
library(rvest) 
library(tidyverse)
#Må registrere en API-nøkell på nettsiden newsapi.org, er gratis å få! Tenk over denne som ditt passord til api'n, så ikke gi den bort :)
api_key="Putt din API-nøkell her"

newsanchor::terms_sources #Viser hvilke kilder du kan hente fra, bl.a. Aftenposten og NRK

#Hente overskrifter

overskrifter_nrk <- get_headlines(sources = "nrk", api_key = api_key)
cat(overskrifter_nrk$results_df$title)
cat(overskrifter_nrk$results_df$content)


hytte_artikler <- get_everything(query = "hytte", sources = c("nrk", "aftenposten"), api_key = api_key)

#Hente hele artikler
#NB: Aftenposten f.eks. er en abbonementstjeneste, og er dermed ikke mulig å laste ned på denne måten. 
#Bruker derfor NRK her


nrk_lenker <- overskrifter_nrk$results_df$url

#Laste ned filene, og putte dem i en mappe. Her gir jeg dem alle bare navnet nrkart + ett tall, mulig å finne noe smartere
for (i in seq_along(nrk_lenker)) {
  download.file(nrk_lenker[i], paste0("sma_filer/nrk/nrkart", i, ".html"))
}





art1 <- read_html("sma_filer/nrk/nrkart6.html") %>% 
  html_nodes(xpath = "/html/body/div/div[3]/div/div[1]/div/div/article/div[4]/div[1]") %>% 
  html_text2()


nrk_artikler <- list()
nrk_nettsider <- list.files("sma_filer/nrk/", full.names = TRUE)

for (i in 1:length(nrk_nettsider)) {

  page <- read_html(nrk_nettsider[i])
  
  page <- page  %>% 
    html_nodes(xpath = "/html/body/div/div[3]/div/div[1]/div/div/article/div[4]/div[1]") %>% 
    html_text2()
  
  nrk_artikler[[i]] <- page
  print(i)
} #Du vil se at denne ikke gir et resultat for link 2,3,5, og 10. Det er fordi xpath'n vi brukte kun fungerer for nyhetsartikler, og ikke f.eks. mat-artiklene
  #Ønsker vi det må vi skille ut disse, og lage en egen xpath for dem.





