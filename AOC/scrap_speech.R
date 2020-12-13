#install packages

pacman::p_load(tidyverse,
               tidytext,
               tm, #para los stopwords 
               quanteda, #para el text mining
               #quanteda.corpora,
               quanteda.dictionaries,
               syuzhet,   #para el nrc_sentiment
               here,
               rvest,
               stringr,
               textdata,
               bbplot
)


devtools::install_github("kbenoit/quanteda.dictionaries") 
devtools::install_github('bbc/bbplot')
###### Scrapear discurso desde pagina web

url <- "https://www.rev.com/blog/transcripts/rep-alexandria-ocasio-cortez-floor-speech-about-yoho-remarks-july-23"

pg <- read_html(url)

parrafos <- pg %>% 
  html_nodes("#transcription p") %>% # Ubicación del selector
  html_text() %>%
  enframe() 

# Remover párrafo del Speaker
parrafos <- parrafos %>% 
            filter(!name==2) %>% 
            mutate(name=row_number())

### limpiar data

# cargar stopwords en español
stop_words <- tm::stopwords(kind="en")
my_stop_words <- c("Rep","Alexandria","Ocasio-Cortez","Mr","Speaker")
final_stop_words <- c(stop_words,my_stop_words)


################# QUANTEDA ###########################
#creo un corpus con QUANTEDA con los comentarios
corp_discurso <- quanteda::corpus(parrafos$value)

head(docvars(corp_discurso))

summary(corp_discurso, n=8)

#To extract texts from a corpus, we use an extractor, called texts().
texts(corp_discurso)[1]

# voy a tokenizar cada post
tok_parrafo <-  quanteda::tokens(corp_discurso,
                                  remove_numbers = TRUE,
                                  remove_punct = TRUE) %>% 
  tokens_remove(pattern = final_stop_words,
                valuetype = 'fixed')

# ahora voy a crear una matrix dfm
dfmat_parrafo <- quanteda::dfm(tok_parrafo,remove_punct = TRUE)


#veo frecuencias
com_stat_freq <- quanteda::textstat_frequency(dfmat_parrafo, n=10)

quanteda::textstat_lexdiv(dfmat_parrafo)

kwic(corp_discurso,pattern = "yoho")%>%
  textplot_xray()

# Wordcloud
font_add_google("Lobster", "lobster")
set.seed(132)
quanteda::textplot_wordcloud(dfmat_parrafo,
                             color = (RColorBrewer::brewer.pal(10, "Paired")),
                             max_words = 100,
                             max_size = 5,
                             random_order =FALSE)


#nrc

output_nrc <-liwcalike(corp_discurso, 
          dictionary = data_dictionary_NRC)

output_afinn <-liwcalike(corp_discurso, 
                       dictionary = data_dictionary_AFINN)

output_genin <-liwcalike(corp_discurso, 
                         dictionary = data_dictionary_geninqposneg)

output_LoughranMcDonald <-liwcalike(corp_discurso, 
                         dictionary = data_dictionary_LoughranMcDonald)

output_MFD <-liwcalike(corp_discurso, 
                                    dictionary = data_dictionary_MFD)

output_sentiws <-liwcalike(corp_discurso, 
                       dictionary = data_dictionary_sentiws)

#### topic models
dfm_trim(dfmat_parrafo,  min_termfreq = 3, min_docfreq = 2)

dtm <- convert(dfmat_parrafo, to = "topicmodels")
lda <- LDA(dtm, k = 5)
terms(lda, 5)

### tf-idf

tf_idf <- dfm_tfidf(dfmat_parrafo)%>% 
  round(digits = 2) %>% 
  convert(to="data.frame") %>% 
  pivot_longer(-doc_id,names_to="sentiment",values_to="count")  %>% 
  group_by(doc_id) %>% 
  arrange(-count) %>% 
  top_n(n=3)
### graficas

output_nrc$docname <- str_replace(output_nrc$docname,"text","Párrafo ")

#### grafica palabras por parrafo
  ggplot(data=output_nrc,
         aes(x=reorder(docname,-Segment), #segment es numerico
             y=WC))+
    geom_bar(stat="identity", 
             position="identity", 
             fill="#1380A1") +
    geom_label(aes(x=docname, y=WC, label =WC),
               hjust = 1, 
               vjust = 0.5, 
               colour = "white", 
               fill = NA, 
               label.size = NA, 
               family="Helvetica", 
               size = 6
               )+
    geom_hline(yintercept = 0, size = 1, colour="#333333") +  
  bbc_style()+
    coord_flip() +
    labs(subtitle="Análisis cuantitativo de palabras por párrafo",
         title = "Discurso de Alexandria Ocasio-Cortez \nacerca de los ataques del Repr. Yoho",
         caption =" Gráfica hecha por @nerudista.\nDiscurso obtenido desde https://www.rev.com/blog/transcripts/rep-alexandria-ocasio-cortez-floor-speech-about-yoho-remarks-july-23")+
    theme(panel.grid.major.x = element_line(color="#cbcbcb"), 
          panel.grid.major.y=element_blank(),
          plot.caption = element_text())
  
  ##### grafica sentimientos por parrafo
  
 df_nrc <-  output_nrc %>% 
    select (docname, Segment, anger, anticipation,disgust,fear,joy, 
            negative, positive,sadness,surprise,trust) %>% 
    #pivot_longer(-docname,names_to=c("sentiment",".value"), names_pattern = "(.*)(.)")
    pivot_longer(cols=anger:trust) %>% 
    
    mutate(facet_order=reorder(docname,Segment)) 
    
  df_nrc %>%   
    filter(!name %in% c("positive","negative")) %>% #negate condition
  ggplot(aes(x=reorder(name,value), y=value, fill=name))+
    geom_bar(stat = "identity",
             position = "identity")+
    geom_hline(yintercept = 0, size = 1, colour = "#333333") +
    bbc_style()+
    coord_flip()+
    facet_wrap(vars(facet_order),nrow = 3 )+
    labs(subtitle="Análisis de sentimientos por párrafo",
         title = "Discurso de Alexandria Ocasio-Cortez \nacerca de los ataques del Repr. Yoho",
         caption =" Gráfica hecha por @nerudista.\nDiscurso obtenido desde https://www.rev.com/blog/transcripts/rep-alexandria-ocasio-cortez-floor-speech-about-yoho-remarks-july-23")+
    theme(panel.grid.major.x = element_line(color="#cbcbcb"), 
          panel.grid.major.y=element_blank(),
          plot.caption = element_text(),
          axis.text.x = element_text(margin=margin(t = 10, b = 10)),
          axis.text.y = element_text(size=9),
          legend.position = "none"
          )

    
  # gafica negativa  positiva

  df_nrc %>%   
    filter(name %in% c("positive","negative")) %>% #negate condition
    ggplot(aes(x=docname, y=value, fill=name))+
    geom_bar(data = subset(df_nrc, name == "positive"),
             aes(y = value), position="stack", stat="identity") +
    geom_bar(data = subset(df_nrc, name == "negative"),
             aes(y = -value), position="stack", stat="identity") +
    geom_hline(yintercept = 0, size = 1, colour = "#333333") +
    bbc_style()+
    coord_flip()
  