library(tidyverse)
library(quanteda)
library(janeaustenr)
library(tidytext)
library(ggdark)



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
