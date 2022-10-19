library(tidytext)
library(quanteda)
library(rainette)

tedtalks_tfidf <- tedtalks %>%
  group_by(id) %>%
  unnest_tokens(input = transcript,
                output = token,
                strip_punct = TRUE,
                strip_numeric = TRUE,
                token = "words") %>%
  filter(!token %in% stopwords("en")) %>%
  count(token) %>% 
  bind_tf_idf(token, id, n) %>%
  na.omit()

tedtalks_dfm <- tedtalks_tfidf %>%
  cast_dfm(id, token, tf_idf) %>%
  dfm_trim(min_termfreq = 2, max_termfreq = 1000)

rainette_cluster <- rainette(
  tedtalks_dfm,
  k = 8)