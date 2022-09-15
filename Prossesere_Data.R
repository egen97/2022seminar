library(tidyverse)
library(quanteda)
library(janeaustenr)
library(tidytext)
library(ggdark)
library(quanteda.textplots)

nrk_art

nrk_df <- as.data.frame(do.call(rbind, nrk_artikler))

names(nrk_df)[1] <- "text"
nrk_df$id <- 1:8

bag_of_words <- nrk_df %>%
  mutate(text = str_split(text,"\\s")) %>%
  unlist()

set.seed(984301)

cat(bag_of_words[sample(1:length(bag_of_words))])

cat(nrk_df$text[which(str_detect(nrk_df$text, "EU"))])


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




nrk_tokens <- nrk_df %>% 
  unnest_tokens(output = token,
                input = text)  

nrk_tokens %>% 
  count(token) %>% 
  slice_max(order_by = n,
            n = 2,
            with_ties = FALSE)




nrk_tokens %>% 
  count(token) %>% 
  filter(token %in% quanteda::stopwords("no") == FALSE) %>% 
  slice_max(order_by = n,
            n = 2,
            with_ties = FALSE)




idf_stop <- nrk_tokens %>% 
  add_count(token) %>% 
  bind_tf_idf(token, id, n) %>% 
  ungroup() %>% 
  select(token, idf) %>% 
  unique() %>% 
  arrange(idf)

idf_stop





idf_stop <- idf_stop %>% 
  filter(idf < 1)


nrk_tokens %>%
  filter(token %in% idf_stop$token == FALSE) %>% 
  count(token) %>% 
  slice_max(order_by = n,
            n = 10,
            with_ties = FALSE)



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

nrk_tokens <- tokens_remove(nrk_tokens, pattern = stopwords('no'))

nrk_dfm <- dfm(nrk_tokens)

textplot_network(nrk_dfm, min_freq = 1)
textplot_wordcloud(nrk_dfm)
?textplot_xray()
