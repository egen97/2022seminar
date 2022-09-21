library(tidyverse)
library(quanteda)
library(tidytext)
library(ggdark)
library(quanteda.textplots)


githubURL <- ("https://github.com/egen97/2022seminar/raw/master/sma_filer/nrk_artikler.rds")

nrk_artikler <- readRDS(url(githubURL, method="libcurl"))



nrk_df <- as.data.frame(do.call(rbind, nrk_artikler))

names(nrk_df)[1] <- "text"
nrk_df$id <- 1:8

bag_of_words <- nrk_df %>%
  mutate(text = str_split(text,"\\s")) %>%
  unlist()


cat(bag_of_words[sample(1:100)])

cat(nrk_df$text[which(str_detect(nrk_df$text, "EU"))])






#Stoppord
stopwords(language = "no")




nrk_tokens <- nrk_df %>% 
  unnest_tokens(output = token,
                input = text)  

nrk_tokens %>% 
  count(token) %>% 
  slice_max(order_by = n,
            n = 10,
            with_ties = FALSE)




nrk_tokens %>% 
  count(token) %>% 
  filter(!(token %in% quanteda::stopwords("no"))) %>% 
  slice_max(order_by = n,
            n = 10,
            with_ties = FALSE)




idf_stop <- nrk_tokens %>% 
  add_count(token) %>% 
  bind_tf_idf(token, id, n) %>% 
  ungroup() %>% 
  select(token, idf) %>% 
  unique() %>% 
  arrange(idf)

idf_stop





idf_stop2 <- idf_stop %>% 
  filter(idf < 1.1)


nrk_tokens %>%
  filter(token %in% idf_stop$token == FALSE) %>% 
  count(token) %>% 
  slice_max(order_by = n,
            n = 10,
            with_ties = FALSE)


nrk_tokens %>%
  filter(!(token %in% idf_stop$token)) %>% 
  #filter(!str_detect(token, "\\d")) %>% 
  count(token) %>%
  arrange(desc(n)) %>% 
  head(300) %>% 
  ggplot(aes(x = 1:300, y = n)) +
  geom_point() +
  geom_line(aes(group = 1)) +
  scale_y_continuous(trans = "log") +
  scale_x_continuous(trans = "log") +
  geom_smooth(method = "lm", se = FALSE) +
  ggrepel::geom_label_repel(aes(label = token)) +
  ggdark::dark_theme_classic() +
  labs(x = "Rangering (log)", y = "Frekvens (log)", title = "Zipf's lov illustrasjon")






## Lage en data-feature-matrix

nrk_corpus <- corpus(nrk_df, docid_field = "id", text_field = "text")


nrk_tokens <- tokens(nrk_corpus,
  remove_numbers = TRUE,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_separators = TRUE,
  remove_url = TRUE,
  verbose = TRUE
)


nrk_tokens <- tokens_tolower(nrk_tokens)





nrk_tokens <- tokens_remove(nrk_tokens, pattern = c(stopwords('no')))

nrk_tokens <- tokens_remove(nrk_tokens, pattern = c(stopwords('no'), "amp"))

nrk_dfm <- dfm(nrk_tokens)


textplot_wordcloud(nrk_dfm)






kwic(nrk_tokens, "amp")

nrk_kwik <- kwic(nrk_tokens, "EU", window = 6)

nrk_tokens <- tokens_remove(nrk_tokens, pattern = c(stopwords('no'), "amp"))

textplot_xray(nrk_kwik) +
  ggthemes::theme_fivethirtyeight() + 
  aes(color = keyword) + 
  scale_color_manual(values = "red")

textplot_network(nrk_dfm)

spr_time <- stortingscrape::get_question_hour(300)

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

textplot_xray(kwic(spr_time_tokens, "regjering*")) + 
  ggthemes::theme_fivethirtyeight() + 
  aes(color = keyword) + 
  scale_color_manual(values = "red")

textplot_network(spr_time_dfm, min_freq = .9)


?tokens
spr_time_stem <- dfm_wordstem(spr_time_dfm, language = "no")
textplot_wordcloud(spr_time_stem)
textplot_network(spr_time_stem, min_freq = .9)



