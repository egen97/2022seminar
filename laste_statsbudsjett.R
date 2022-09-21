library(Rcrawler)
#For ett statsbudsjett
temp1 <- tempfile() #Dette bruker jeg istedenfor å laste ned på egen pc, dere bør bruke en mappe

base_url <- "https://www.regjeringen.no/no/dokumenter/prop.-1-s-20212022/id2875540/?ch="
#Legg merke til at url-en for dette budsjettet er helt lik, med untak av ch= peker på kapitellnummeret 
for (i in 1:15) { #Så på nettsiden at det var femten kaptiler
  download.file(paste0(base_url,i), destfile = temp1)
}


# Laste ned flere budsjetter #
#Jeg tror denne skal fungere, men litt usikker. Viktige er å sette "dataUrlfilter" riktig. 
#Får ikke testa den, da den tar veldig lang tid å kjøre. Tror uansett det er enklere (do it simple stupid)
#å bare kjøre koden over for hvert budsjett!





Rcrawler("https://www.regjeringen.no/no/tema/okonomi-og-budsjett/statsbudsjett/tidligere-statsbudsjetter/id450436/", # Nettsiden vi skal kravle
         DIR = temp1,           # mappen vi lagrer filene i
         no_cores = 4,              # kjerner for å prosessere data
         dataUrlfilter = "meld.-st*",  # subset filter for kravling
         RequestsDelay = 2 + abs(rnorm(1)))
