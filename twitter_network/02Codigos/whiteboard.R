#Cargar paquetes

pacman::p_load("rtweet",
               "tidyverse","janitor",
               #"igraph","visNetwork",
               "quanteda","quanteda.textplots",
               "extrafont",
               "showtext", #cargar fuents de Google
               "ggthemes")

#Mac
Sys.setlocale("LC_ALL", "es_ES.UTF-8") # Cambiar locale para prevenir problemas con caracteres especiales

# Cargar fuentes del sistema
#extrafont::font_import()

#cargar fuente (de google
font_add_google("Lato","lato")
font_add_google("Gochi Hand", "gochi")


# to work well with the RStudio graphics device (RStudioGD).
showtext_auto()

# Declarar funcion para calcular tipo de contenido
calcular_cont_propio <- function(df){
  
  # Revisar contenido propio o retweet

  df$contenido_propio <-  df %>% 
    mutate( contenido_propio = case_when(is_quote == "FALSE" & is_retweet == "FALSE" & is.na( reply_to_screen_name) ~ "Contenido Propio" ,
                                         is_quote == "TRUE" ~ "Citar Tweet",
                                         is_retweet == "TRUE" ~ "Retweet",
                                         !is.na(reply_to_screen_name) ~ "Respuesta a Tweet"
    )
    )
  
  return( df$contenido_propio)
}





## get user IDs of accounts following CNN
# Define user
user <- "baijorge"


# Obtener timeline
tmln <- get_timeline(user,n=200)

num_tweets <- tmln %>% tally( name = "num")

# Calcular contenido propio

tmln <- calcular_cont_propio(tmln) 



# Grafica de tipo de contenido 
png(paste0( "./03Graficos/contenido_plot_",user,".png"), width = 540, height = 480)

tmln %>% distinct(screen_name)

tmln %>% 
  group_by(contenido_propio) %>% 
  summarise(ocurrencias= n()) %>% 
ggplot( aes(x=fct_relevel( contenido_propio,
                                      "Contenido Propio",
                                      "Citar Tweet",
                                      "Respuesta a Tweet",
                                      "Retweet"),
            y=ocurrencias,
            fill=contenido_propio)
       )+
  geom_col() +
  geom_text(aes(label=ocurrencias),
            nudge_y = 4
            )+
  labs(title= "Distribucion por Tipo de Interacción ",
       x = NULL,
       y = "Número de Tweets")+
  scale_fill_economist()+
  theme( legend.position = "none",
         title = element_text(size=18, face = "bold"),
         panel.background = element_blank(),
         panel.grid.major = element_blank(),
         panel.grid = element_blank(),
         text = element_text(family = "lato"),
         axis.title = element_text(size=13),
         axis.text.x = element_text(size=11,face="bold"),
         axis.ticks = element_blank(),
         axis.text.y = element_blank()
         ) 

dev.off()
# quanteda


# Primero crear un corpus a partir del df

short <- tmln %>% 
  filter(contenido_propio != "Retweet")

corp_tmln <-tmln %>% 
            filter(contenido_propio != "Retweet")%>% 
            select(text) %>% 
          corpus()  # build a new corpus from the texts

summary(corp_tmln)

tokens_tmln <- tokens(corp_tmln,
                      remove_punct = TRUE,
                      remove_symbols = TRUE,
                      remove_numbers = TRUE,
                      remove_url = TRUE)

tokens_tmln <- tokens_select(tokens_tmln, stopwords('es'),selection='remove')

tokens_tmln <- tokens_select(tokens_tmln, stopwords('en'),selection='remove')

#tokens_tmln <- tokens_select(tokens_tmln, valuetype = "glob", pattern = ".U000.*", selection = 'remove')


# Construir una document  feature matrix a partir del objeto de tokens
tweet_dfm <- dfm(tokens_tmln)
#head(tweet_dfm)

# seleccionar hastags para grafica
tag_dfm <- dfm_select(tweet_dfm, pattern = ("#*"))
#head(tag_dfm)

toptag <- names(topfeatures(tag_dfm, 30))
#head(toptag)

#Crear feature-occurrence matrix de hashtags
tag_fcm <- fcm(tag_dfm)
#head(tag_fcm)

# Crear grafica de hastags
topgat_fcm <- fcm_select(tag_fcm, pattern = toptag)

png(paste0( "./03Graficos/hashtags_net_",user,".png"), width = 480, height = 480)
set.seed(15) ;textplot_network(topgat_fcm, min_freq = 0.1, edge_alpha = 0.6, edge_size = 3)
dev.off()

#Ahora vamos con usuarios

user_dfm <- dfm_select(tweet_dfm, pattern = "@*")

topuser <- names(topfeatures(user_dfm, 15))

#head(topuser)

#Crear feature-occurrence matrix de usuarios
user_fcm <- fcm(user_dfm)
#head(user_fcm)

# Crear grafica
user_fcm <- fcm_select(user_fcm, pattern = topuser)
png(paste0( "./03Graficos/users_net_plot_",user,".png"), width = 480, height = 480)
textplot_network(user_fcm, min_freq = 0.2, omit_isolated = TRUE,  edge_color = "orange", edge_alpha = 0.4, edge_size = 2)
dev.off()


#### Crear wordcloud

# eliminar hasstags y usuarios hastags para grafica
words_dfm <- dfm_select(tweet_dfm, pattern = ("#*"), selection = 'remove')

words_dfm <- dfm_select(words_dfm, pattern = ("@*"), selection = 'remove')

head(words_dfm)
#words_dfm <- dfm_select(word_fcm,pattern = ("\\U.*"),selection = 'remove')


# Guardar graficos
png(paste0( "./03Graficos/clean_word_plot_",user,"_top_100.png"), width = 480, height = 480)

word_plot <- textplot_wordcloud(words_dfm,
                                 #font=
                                  min_size = .1,
                                  max_size = 5,
                                  random_order = FALSE,
                                  #color = alpha("#055C9E",seq(.05,1,.20)),
                                color = RColorBrewer::brewer.pal(10, "Blues"),
                   max_words = 100) %>% 
  ggsave(filename = "03Graficos/test.png")
                   
dev.off()



png(paste0( "./03Graficos/all_word_plot_",user,"_top_100.png"), width = 480, height = 480)
tweet_plot <-   textplot_wordcloud(tweet_dfm,
                                  min_size = .8,
                                  max_size = 2.5,
                                  random_order = FALSE,
                                  #color = alpha("#356E40",seq(0.2,1,.23)),
                                  color = RColorBrewer::brewer.pal(6, "Reds"),
                                  max_words = 100)
dev.off()




######## OTRAS PRUEBAS ----
 
# convertir timeline en un data frame listo para convertirse en igraph
tmln_net <- network_data(tmln,"all")

# Crear objetos de red
g <- graph_from_data_frame(tmln_net, directed = TRUE)


# graficar con visNetwork
visIgraph(g,layout = "layout_in_circle")

# Revisar contenido propio o retweet
tmln_short <- tmln %>% 
  mutate( contenido_propio = case_when(is_quote == "FALSE" & is_retweet == "FALSE" & is.na( reply_to_screen_name) ~ "Contenido Propio" ,
                                       is_quote == "TRUE" ~ "Citar Tweet",
                                       is_retweet == "TRUE" ~ "Retweet",
                                       !is.na(reply_to_screen_name) ~ "Respuesta a Tweet"
                                       )
          ) %>% 
  select (screen_name,text,contenido_propio,created_at) %>% 
  arrange(desc(created_at))



 