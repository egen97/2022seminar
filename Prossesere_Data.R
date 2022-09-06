library(tidyverse)
library(quanteda)
library(janeaustenr)
library(tidytext)
library(ggdark)
library(quanteda.textplots)


spr_time <- readRDS("sma_filer/spr_time_300.rds")
spr_time_tekst <- spr_time$question_time$question_text


bag_of_words <- spr_time_tekst %>%
  str_split("\\s") %>%
  unlist()

set.seed(984301)

cat(bag_of_words[sample(1:length(bag_of_words))])

spr_time_tekst[which(str_detect(spr_time_tekst, "Sverige"))]

original_books <- austen_books() %>%
  group_by(book) %>%
  mutate(line = row_number()) %>%
  ungroup()


tidy_books <- original_books %>%
  unnest_tokens(word, text) %>% 
  count(word) %>% 
  arrange(desc(n))

tidy_books %>% head(300) %>% 
  ggplot(., aes(x = 1:300, y = n)) +
  geom_point() +
  geom_line(aes(group = 1)) +
  scale_y_continuous(trans = "log") +
  scale_x_continuous(trans = "log") +
  geom_smooth(method = "lm", se = FALSE) +
  ggrepel::geom_label_repel(aes(label = word)) +
  ggdark::dark_theme_classic() +
  labs(x = "Rangering (log)", y = "Frekvens (log)", title = "Zipf's lov illustrasjon")





#Stoppord
stopwords(language = "no")




spr_time_tokens <- spr_time$question_time %>% 
  unnest_tokens(output = token,
                input = question_text)  

spr_time_tokens %>% 
  count(token) %>% 
  slice_max(order_by = n,
            n = 2,
            with_ties = FALSE)




spr_time_tokens %>% 
  count(token) %>% 
  filter(token %in% quanteda::stopwords("no") == FALSE) %>% 
  slice_max(order_by = n,
            n = 2,
            with_ties = FALSE)




idf_stop <- spr_time_tokens %>% 
  add_count(token) %>% 
  bind_tf_idf(token, question_id, n) %>% 
  ungroup() %>% 
  select(token, idf) %>% 
  unique() %>% 
  arrange(idf)

idf_stop





idf_stop <- idf_stop %>% 
  filter(idf < 1)


spr_time_tokens %>%
  filter(token %in% idf_stop$token == FALSE) %>% 
  count(token) %>% 
  slice_max(order_by = n,
            n = 10,
            with_ties = FALSE)



## Lage en data-feature-matrix

spr_time_corpus <- corpus(spr_time$question_time, docid_field = "question_id", text_field = "question_text")


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

textplot_network(spr_time_dfm, min_freq = 0.9)
