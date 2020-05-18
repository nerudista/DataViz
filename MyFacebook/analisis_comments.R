pacman::p_load(tidyverse,
               tidytext,
               tm, #para los stopwords 
               quanteda, #para el text mining
               quanteda.corpora,
               syuzhet,   #para el nrc_sentiment
               ggthemes,
               wordcloud,
               reshape2,   #para el acast
               topicmodels #para el LDA
               )

#Cargar la fuente desde mi Windows
windowsFonts(`Lato` = windowsFont("Lato"))

# Crear theme
# Inspirado en el styleguide del Urban Institute
# https://urbaninstitute.github.io/graphics-styleguide/

theme_fb <- theme(
  #Esto pone blanco el titulo , los ejes, etc
  plot.background = element_rect(fill = '#FFFFFF', colour = '#FFFFFF'),
  #Esto pone blanco el panel de la gráfica, es decir, sobre lo que van los bubbles
  panel.background = element_rect(fill="#FFFFFF",color="#FFFFFF"),
  panel.grid.minor = element_blank(),
  panel.grid.major.y = element_line(color="#DEDDDD"),
  panel.grid.major.x = element_blank(),
  text = element_text(#color = "#1db954",
                      family="Lato"),
  # limpiar la gráfica
  axis.line = element_line(colour="#FFFFFF"),
  #axis.title=element_blank(),
  axis.text=element_text(family="Lato",
                         size=12),
  axis.ticks=element_blank(),
  axis.title.x = element_text( margin=margin(10,0,0,0),
                               family="Lato",
                               size=12,
                               color="#0D1F2D"
                               ),
  axis.title.y = element_text( margin=margin(0,15,0,0),
                               family="Lato",
                               size=12,
                               color="#0D1F2D"
  ),
  # ajustar titulos y notas
  plot.title = element_text(family="Lato",
                            size=18,
                            margin=margin(0,0,15,0),
                            hjust = 0,  #align left
                            color="#0D1F2D"),
  plot.subtitle = element_text(size=14,
                               family="Lato",
                               hjust = 0,  #align left
                               margin=margin(0,0,25,0),
                               color="#0D1F2D"),
  plot.caption = element_text(
    color="#0D1F2D",
    family="Lato",
    size=11,
    hjust = 0  #align left
  ),
  legend.position = "none",
  #para los titulos del facet_wrap
  strip.text.x = element_text(size=12, face="bold"),
  
  complete=FALSE
)


my_caption <-  expression(paste(bold("Fuente:"), " Datos proporcionados por Facebook para el usuario ", bold("nerudista")))


######



data_comments <- read_csv("./Datos/misComentarios.csv")
data_posts <- read_csv("./Datos/misPosts.csv")

data_comments <- data_comments %>%  mutate(tipo = "Comentario")

data_posts <- data_posts%>%  mutate(tipo = "Post")

data <- rbind(data_comments, data_posts)

# cargar stopwords en español
stop_words <- tm::stopwords(kind="es")
my_stop_words <- c("si","p","d","así","tan","!","¡","=","$","esposa",
                   "de","que","a","with","to","ps","made","nocroprc")

final_stop_words <- c(stop_words,my_stop_words)

################# QUANTEDA ###########################
#creo un corpus con QUANTEDA con los comentarios
corp_comments <- quanteda::corpus(data$Comment)

head(docvars(corp_comments))

summary(corp_comments, n=5)



#To extract texts from a corpus, we use an extractor, called texts().
texts(corp_comments)[7]

# voy a tokenizar cada post
tok_comments <-  quanteda::tokens(corp_comments,
                 remove_numbers = TRUE,
                 remove_punct = TRUE) %>% 
  tokens_remove(pattern = final_stop_words,
                valuetype = 'fixed')



# ahora voy a crear una matrix dfm
dfmat_comments <- quanteda::dfm(tok_comments,remove_punct = TRUE)

#otra matrix dfm
dfmat_comments_2 <- quanteda::dfm(corp_comments, groups="tipo")

#veo frecuencias
com_stat_freq <- quanteda::textstat_frequency(dfmat_comments, n=80)

#creo grafica

set.seed(132)
quanteda::textplot_wordcloud(dfmat_comments,
                   color = rev(RColorBrewer::brewer.pal(10, "RdBu")),
                   max_words = 100,
                   random_order =FALSE)

################# TIDYTEXT ###########################

#Voy a limpiar un poco la base para estandarizarla

data.limpia <- data %>%
  mutate(Comment = iconv (Comment,"UTF-8", "ASCII//TRANSLIT")) %>% # QUITA ACENTOS Y CARAC. ESPECIALES
  mutate(Comment = tolower(Comment)) %>% 
  mutate(Comment = str_squish(Comment)) %>% 
  mutate(Comment = str_remove_all(Comment,"[[:punct:]]") ) %>% 
  mutate(Comment = str_remove_all(Comment,"[[:digit:]]") ) 

#Ahora a tokenizar por palabra
tidy.tokens.word <- data.limpia %>% 
  tidytext::unnest_tokens(word,Comment)

#Ahora a tokenizar por oracion
#Da casi lo mismo que la data.limpia.
#Es decir, casi nnca repetí oraciones.
tidy.tokens.sentence <- data.limpia %>% 
  unnest_tokens(sentence, Comment, token = "sentences")

#Ahora por n-gramas
tidy.tokens.ngram <- data.limpia %>% 
  unnest_tokens(ngram, Comment, token = "ngrams", n = 2)


cuenta.ngramas <- tidy.tokens.ngram %>% 
  count(ngram) %>% 
  arrange(-n) %>% 
  #dplyr::filter(!ngram %in% tm::stopwords(kind="es")) %>% 
  dplyr::filter(!ngram %in% final_stop_words) %>% 
  dplyr::filter(nchar(ngram)> 0)

png("graficas/wordcloud_tm.png", width = 1000, height = 1000, res=200)
#Visualizar ngramas
cuenta.ngramas %>% 
  with(wordcloud::wordcloud(ngram,
                            n,
                            max.words = 40,
                            random.order = FALSE,
                            colors = rev(brewer.pal(5,"Paired"))))

dev.off()

# ANALISIS DE SENTIMIENTOS CON AFINN (ESPAÑOL) 
afinn.esp <- read_csv("./datos/lexico_afinn.en.es.csv",
                      locale=locale(encoding = "LATIN1"))

fb.affin.esp <- tidy.tokens.word %>% 
  filter(!word %in% final_stop_words) %>% 
  inner_join(afinn.esp,
             by = c("word" = "Palabra" )) %>% 
  distinct(word, .keep_all = TRUE)

#graficar
fb.affin.esp %>% 
  group_by(tipo) %>% 
  summarise( neto = sum(Puntuacion)) %>% 
  ggplot( aes(x=tipo,
              y=neto,
              fill = tipo))+
  geom_col()+
  geom_text( aes(x=tipo,y=neto,label = neto),
             nudge_y = 8,
             family="Lato",
             fontface="bold",
             size=4.5
  )+
  labs(title="Sentimiento por Tipo de Publicación",
       subtitle = "Calificación Obtenida Usando AFFIN",
       caption = my_caption,
       y= "",
       x="")+
  scale_fill_manual(values = c("#0a4c6a","#cfe8f3"))+
  theme_fb

#otro wordlcoud pero ahora por comparacio´n

#graficar
png("graficas/comparacion_cloud.png", width = 1000, height = 1000, res=200)

affin.count <-  fb.affin.esp %>% 
  mutate(sentimiento = dplyr::case_when(
    Puntuacion < 0 ~ "Negativo",
    Puntuacion > 0 ~ "Positivo"
  )) %>% 
  count(tipo,sentimiento,word) %>% 
  arrange(-n) %>% 
  reshape2::acast(word ~ sentimiento, fill = 0, value.var = "n") %>% 
  wordcloud::comparison.cloud(colors = c("#db2b27", "#12719e"),
                              random.order = FALSE,
                              scale=c(1.5,.5),
                              title.size = 2,
                              max.words = 400)



dev.off()    



# Sentiment analysis con syuzhet

# Aplico NRC a mis posts y comments
fb_sentimientos_nrc <- syuzhet::get_nrc_sentiment(data$Comment , language = "spanish")

df_fb_sentimientos_nrc <-  fb_sentimientos_nrc %>%  
  dplyr::summarise_all(funs(sum)) %>%
  rowid_to_column("id") %>% 
  pivot_longer(-id, names_to = "sentimiento", values_to = "count")  
  
 
## grafica con sentimientos
  df_fb_sentimientos_nrc %>% 
   filter(!sentimiento %in% c('positive','negative')) %>% 
  ggplot( ) +
  geom_col(aes(x= reorder(sentimiento,count),
               y= count,
               fill = sentimiento))+
    scale_fill_brewer(palette="Blues")+
  coord_flip()+
  labs(title ="")
  theme_clean()+
  theme(legend.position = "none")
  
  # treemap
  df_fb_sentimientos_nrc %>% 
    filter(!sentimiento %in% c('positive','negative')) %>% 
  treemap(
          index="sentimiento",
          vSize="count",
          type="index",
          fontsize.labels=c(12),
          fontsize.title = 18,
          palette = "Blues", 
          title="Sentimientos en Post y Comments",
          fontfamily.title = "Lato",
          fontfamily.labels = "Lato",
          border.col = "#191414"
  )+
  theme_fb
  
  
  ## grafica con positivo y negativo
  BarPositiveNegative <- df_fb_sentimientos_nrc %>% 
    filter(sentimiento %in% c('positive','negative')) %>% 
    ggplot( ) +
    geom_col(aes(x= reorder(sentimiento,count),
                 y= count,
                 fill = sentimiento))+
    labs(title = "Clasificación de Palabras Por Sentimiento ",
         caption = my_caption ,
         y = "Número de Palabras",
         x= "")+
    scale_fill_manual(values=c("#db2b27", "#12719e"))+
    scale_x_discrete(labels=c("Negativas","Positivas")) +
    theme_fb;BarPositiveNegative
  
  ggsave("./graficas/BarPositiveNegative.png", BarPositiveNegative, width = 6, height = 9)
  
    
  ################## TF-IDF
  # Term frequency - inerse document frequency
  
  #Necesito que ya esté tokenizado los post y los comments
  # voy a usar el tidy.tokens.word
  
  #para que los DF no me de exponentes en en los resultados.
  options(scipen=99)
  
    
  tfidf <- tidy.tokens.word %>% 
    filter(!word %in% final_stop_words) %>% 
    count(word,tipo) %>% 
    tidytext::bind_tf_idf(word,tipo,n)

  # A graficar tf-idf
  
  #primero creo los labels para los titulos del facet_wrap
  labels <- c(comment = "Comentario", post = "Post")
  
  tfidf %>%   
    group_by(tipo) %>% 
    arrange(-tf_idf) %>% 
    top_n(5) %>% 
    #ungroup() %>% 
    ggplot(aes( x = reorder(word,tf_idf),
                y = tf_idf,
                fill = tipo))+
    geom_col(show.legend = FALSE)+
    scale_fill_manual(values = c("#0a4c6a","#cfe8f3"))+
    facet_wrap( ~  tipo,scales = "free",
                labeller =labeller(tipo=labels))+
    coord_flip()+
    labs(title="Palabras más Representativas por Tipo de Publicación",
         subtitle = "Ranking obtenido por TF_IDF",
         caption = my_caption,
         y= "",
         x="")+
    theme_fb
  
  
  
  #LDA con topic models
  # TRATA DE ENCONTRAR AQUELLAS PALABRAS QUE DEFINEN UNA CATEGORIA
  # cada observación es un documento
  # 
  
  # Crear un corpus
  # lee el vector y lo convierte en un corpus
  corpus.fb <- tm::Corpus(VectorSource(data$Comment))
  
  corpus.fb <- tm::tm_map(corpus.fb, removeWords, stopwords("es"))
  
  corpus.fb <- tm::tm_map(corpus.fb, removePunctuation)  

  corpus.fb <- tm::tm_map(corpus.fb, removeNumbers)  
  
  dtm.fb <- tm::DocumentTermMatrix(corpus.fb)
  
  inspect(dtm.fb)
  
  rowTotals <- apply(dtm.fb , 1, sum)
  
  dtm.fb <- dtm.fb[rowTotals>0,]
  
  
  bd.lda <- topicmodels::LDA(dtm.fb,k=4,control=list(seed=1234))
  
  bd.topics <- tidytext::tidy(bd.lda, matrix="beta")   #Prob por topico por palabra
    
  
  bd.docs <- tidytext::tidy(bd.lda, matrix="gamma") %>%  #Prob por topico por documento
    pivot_wider(names_from = topic, values_from = gamma) 
  
  top_terminos <- bd.topics %>% 
    group_by(topic) %>% 
    top_n(10, beta) %>% 
    ungroup %>% 
    arrange(topic, -beta)
  
  
  top_terminos %>% 
    mutate(term = reorder_within(term,beta,topic)) %>% 
    ggplot(aes(term,
               beta,
               fill=factor(topic)))+
    geom_col()+
    facet_wrap(~ factor(topic), scales = "free")+
    coord_flip()+
    scale_y_continuous(labels = scales::percent_format())+
    scale_fill_manual(values = c("#1696d2","#ec008b","#fdbf11","#5c5859"))+
    scale_x_reordered()+ # necesita el mutate de arriba. Quita el __1, __2 que éste pone.
    labs(title = "Probabilidad de palabras por tópico",
         caption = my_caption ,
         y = "Porcentaje LDA ",
         x= "Palabra")+
    #scale_fill_manual(values=c("#db2b27", "#55b748","fdbf11","898F9C"))+
    theme_fb
  
  #4267B2 azul
  #898F9C gris
  #000000 negro 
  