library(tidymodels)
library(tidytext)
library(stringr)
library(textrecipes)
library(rainette)
library(quanteda)
library(tm)

tweets <- read.csv("sma_filer/coded_tweets.csv")

tweets <- tweets %>% 
  select(-status_id, -coder_id)

tweets_splitt <- initial_split(tweets, #  Del datasettet i to
                            prop = 0.8, # 80 prosent av data (dvs. 80 prosen av radene/talksene) skal gå inn i treningsdata, resten blir testdata
                            strata = collection) # Passer på at Y, tema, er godt representert i både treningsdatasett og testdatasett

tweets_trening <- training(tweets_splitt) # Lager treningsdatasett
tweets_test <- testing(tweets_splitt) # Lager testdatasett

tweets_trening %>% head()


tweets_folds <- vfold_cv(tweets_trening, # Splitt treningsdatasettet inn i valideringsdatasett 
                     strata = collection, # Passer på at Y, tema, er godt representert i både valideringsdatasett og treningsdatasett
                     v = 5)


tweets_oppskrift <- recipe(collection ~ ., data = tweets_trening) %>% # Modellen jeg ønsker å kjøre - jeg vil estimere Y ved å bruke resten av dataene
  step_mutate(text = str_to_lower(text)) %>% # Setter alle til liten bokstav
  step_mutate(text = removeNumbers(text)) %>%  # Fjerner tall
  step_mutate(text = removePunctuation(text)) %>% # Fjerner punktsetting
  step_tokenize(text) %>% # Tokeniserer teksten
  step_stem(text) %>% # Lager ordstammer
  step_stopwords(text, custom_stopword_source = stopwords("en")) %>% # Fjerner stoppord
  step_tokenfilter(text, max_tokens = 400, min_times = 2) %>% # Beholder tokens som dukker opp maks 1000 ganger, fjerner de som dukker opp mindre enn 2 ganger
  step_tfidf(text) # Vektoriserer teksten med TF-IDF

prep(tweets_oppskrift) %>% # Iverksetter preprosesseringsstegene slik beskrevet i oppskriften over
  bake(new_data = NULL) %>% # Ser på hvordan oppskrifts-objektet ser ut
  head(5) %>% select(1:5) 



contrl_preds <- control_resamples(save_pred = TRUE)


#### Logit Reg ####

glmn_spec <- 
  logistic_reg(penalty = 0.001, # Setter et par argumenter for å forhinde modeller fra å overtilpasse seg
               mixture = 0.5) %>% # Dette er typisk noe man går fram og tilbake med (kalt å "tune" modellen)
  set_engine("glmnet") %>% # Logistisk modell får vi ved å spesifisere "glmnet"
  set_mode("classification") # Vi ønsker klassifisering, ikke regresjon

glm_wf <- workflow(tweets_oppskrift, # Datasettet vårt etter preprosessering
                   glmn_spec) # Modellen som spesifisert over, altså logitisk

glm_rs <- fit_resamples( # Passer modellen ved å bruke testdata og valideringsdata i sekvens fem ganger
  glm_wf, # Dette objektet forteller hva som er data og hva som er modellen
  resamples = tweets_folds, # Spesifiserer hva valideringsdataene er
  control = contrl_preds # Legger valgene som jeg lagret over
)



final_fittweets <- last_fit(glm_wf, tweets_splitt) # Passer SVM-modellen til testdatasettet

collect_metrics(final_fittweets)


metrikk_glm <- collect_predictions(final_fittweets)
metrikk_glm %>%
  conf_mat(truth = collection, estimate = .pred_class) %>%
  autoplot(type = "heatmap")








### Ikke-veiledet ###
tweets <- read.csv("sma_filer/coded_tweets.csv")

tweets <- tweets %>% 
  select(-status_id, -coder_id)



tweets_tfidf <- tweets %>%
  group_by(status_id) %>%
  unnest_tokens(input = text,
                output = token,
                strip_punct = TRUE,
                strip_numeric = TRUE,
                token = "words") %>%
  filter(!token %in% stopwords("en")) %>%
  count(token) %>% 
  bind_tf_idf(token, status_id, n) %>%
  na.omit()

tweets_dfm <- tweets_tfidf %>%
  cast_dfm(status_id, token, tf_idf) %>%
  dfm_trim(min_termfreq = 2, max_termfreq = 1000)

rainette_cluster <- rainette(
  tweets_dfm,
  k = 4)

rainette_plot(rainette_cluster, tweets_dfm, k = 4)

