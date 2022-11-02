### Pakker 
library(quanteda)
library(quanteda.textstats)
library(tidytext)
library(tidyverse)
#devtools::install_github("martigso/NorSentLex")
library(NorSentLex)


## Skaffe tekst
spr_time <- readRDS("sma_filer/spr_time_300.rds")
spr_time <- spr_time$question_time
spr_time_corpus <- corpus(spr_time, docid_field = "question_id", text_field = "question_text")


spr_time_tokens <- tokens(spr_time_corpus,
                          remove_numbers = TRUE,
                          remove_punct = TRUE,
                          remove_symbols = TRUE,
                          remove_separators = TRUE,
                          remove_url = TRUE,
                          verbose = TRUE
)



spr_time_tokens <- tokens_tolower(spr_time_tokens)

spr_time_tokens <- tokens_remove(spr_time_tokens, pattern = stopwords('no'))

spr_time_dfm <- dfm(spr_time_tokens)



### Tekststatistikk ####

spr_cos <- textstat_simil(spr_time_dfm, method = "cosine")


spr_cos %>% # Går inn i cosine-likhet objektet som ble lagd over
  as.data.frame(., diag = FALSE) %>% # Gjør om objektet til en dataframe der diagonalen er 0 (tekster likhet med seg selv er uinteressant)
  arrange(desc(cosine)) %>% # Sorter observasjonene i synkende rekkefølge etter cosine-variabelen
  slice_head(n = 20)





## Sentiment



spr_time_sent <- spr_time %>% 
  group_by(question_id) %>% 
  unnest_tokens(ord, question_text)



spr_time_sent$pos_sent <- ifelse(spr_time_sent$ord %in% nor_fullform_sent$positive, 1, 0)
spr_time_sent$neg_sent <- ifelse(spr_time_sent$ord %in% nor_fullform_sent$negative, 1, 0)

table(spr_time_sent$pos_sent, 
      spr_time_sent$neg_sent, 
      dnn = c("positiv", "negativ"))





spr_time_sent %>% 
  slice_sample(n = 10) %>% 
  mutate(neg_sent = neg_sent * -1) %>% 
  ggplot(., aes(x = str_c(sprintf("%02d", 1:12),
                          ". ",
                          str_sub(question_id, 1, 7),
                          "[...]"))) +
  geom_point(aes(y = neg_sent, color = "Negativ")) +
  geom_point(aes(y = pos_sent, color = "Positiv")) + 
  geom_linerange(aes(ymin = neg_sent, ymax = pos_sent), color = "gray40") +
  scale_color_manual(values = c("red", "cyan", "gray70")) +
  labs(x = NULL, y = "Sentiment", color = NULL) +
  ggdark::dark_theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = .25, hjust = 0))

