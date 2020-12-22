#Cargar paquetes

pacman::p_load("rtweet",
               "tidyverse",
               "quanteda",
               #"quanteda.textplots",
               "showtext", #cargar fuents de Google
               "ggthemes")

#Mac
Sys.setlocale("LC_ALL", "es_ES.UTF-8") # Cambiar locale para prevenir problemas con caracteres especiales


#cargar fuente (de google
font_add_google("Lato","lato")

# to work well with the RStudio graphics device (RStudioGD).
showtext_auto()

# Declarar funcion para obetner timeline y  calcular tipo de contenido
obtener_info <- function(user,num){
  
  df <- get_timeline(user,n=num)
  
  # Revisar contenido propio o retweet
  
  #df$contenido_propio <-  
    df <- df %>% 
    mutate( contenido_propio = case_when(is_quote == "FALSE" & is_retweet == "FALSE" & is.na( reply_to_screen_name) ~ "Contenido Propio" ,
                                         is_quote == "TRUE" ~ "Citar Tweet",
                                         is_retweet == "TRUE" ~ "Retweet",
                                         !is.na(reply_to_screen_name) ~ "Respuesta a Tweet"
    )
    )
  
  return( df)
}

grafica_contenido <- function(tmln){
  # REcupero el usuario
  user <- tmln %>% distinct(screen_name)
  print(user)
  
  num_tweets <- tmln %>% tally( )
  
  ntweets <- num_tweets$n
  
  tmln_group <- tmln %>% 
    group_by(contenido_propio) %>% 
    summarise(ocurrencias= n()) 
  
   print("group terminado")
   
   # Grafica de tipo de contenido 
   #png(paste0( "./03Graficos/contenido_plot_",user,".png"), width = 540, height = 480)
   
     ggplot(data=tmln_group, aes(x=fct_relevel( contenido_propio,
                               "Contenido Propio",
                               "Citar Tweet",
                               "Respuesta a Tweet",
                               "Retweet"),
                y=ocurrencias,
                fill=contenido_propio)
    )+
    geom_col() +
    geom_text(aes(label=ocurrencias),
              nudge_y = 28
    )+
    labs(title= "Distribucion por Tipo de Interacción",
         subtitle = paste0("Últimos ",ntweets, " tweets para el usuario @",user),
         x = NULL,
         y = "Número de Tweets")+
    scale_fill_economist()+
    theme( legend.position = "none",
           title = element_text(size=18, face = "bold"),
           plot.subtitle = element_text(size=15, face = "bold"),
           panel.background = element_blank(),
           panel.grid.major = element_blank(),
           panel.grid = element_blank(),
           text = element_text(family = "lato"),
           axis.title = element_text(size=13),
           axis.text.x = element_text(size=11,face="bold"),
           axis.ticks = element_blank(),
           axis.text.y = element_blank()
    ) +
       ggsave(
         filename = paste0( "./03Graficos/contenido_plot_",user,".png"),
         device = "png",
         dpi =72
       )
     
  print("ggplot done")
  
}

grafica_hashtags <- function(corp_tmln){
  
  tokens_tmln <- tokens(corp_tmln,
                        remove_punct = TRUE,
                        remove_symbols = TRUE,
                        remove_numbers = TRUE,
                        remove_url = TRUE
  )
  
  tokens_tmln <- tokens_select(tokens_tmln, stopwords('es'),selection='remove')
  
  tokens_tmln <- tokens_select(tokens_tmln, stopwords('en'),selection='remove')
  
  tokens_tmln <- tokens_select(tokens_tmln, valuetype = "glob", pattern = ".U000.*", selection = 'remove')
  
  
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
  
  
  textplot_network(topgat_fcm, min_freq = 0.1, edge_alpha = 0.7, edge_size = 4) %>% 
  ggsave(filename = paste0( "./03Graficos/hashtags_net_",user,".png"),
         device = "png",
         dpi = 72)
  
  

}

grafica_usuarios <- function(corp_tmln){
  
  
  tokens_tmln <- tokens(corp_tmln,
                        remove_punct = TRUE,
                        remove_symbols = TRUE,
                        remove_numbers = TRUE,
                        remove_url = TRUE
  )
  
  tokens_tmln <- tokens_select(tokens_tmln, stopwords('es'),selection='remove')
  
  tokens_tmln <- tokens_select(tokens_tmln, stopwords('en'),selection='remove')
  
  tokens_tmln <- tokens_select(tokens_tmln, valuetype = "glob", pattern = ".U000.*", selection = 'remove')
  
  
  # Construir una document  feature matrix a partir del objeto de tokens
  tweet_dfm <- dfm(tokens_tmln)
  #Ahora vamos con usuarios
  
  user_dfm <- dfm_select(tweet_dfm, pattern = "@*")
  
  topuser <- names(topfeatures(user_dfm, 30))
  
  #head(topuser)
  
  #Crear feature-occurrence matrix de usuarios
  user_fcm <- fcm(user_dfm)
  #head(user_fcm)
  
  # Crear grafica
  user_fcm <- fcm_select(user_fcm, pattern = topuser)
  #png(paste0( "./03Graficos/users_net_plot_",user,".png"), width = 480, height = 480)
  
  textplot_network(user_fcm, 
                   min_freq = 0.2, 
                   omit_isolated = TRUE,  
                   edge_color = "orange", 
                   edge_alpha = 0.7, 
                   edge_size = 3) %>% 
    ggsave(filename = paste0( "./03Graficos/usuarios_net_",user,".png"),
           device = "png",
           dpi = 72)
    
  #dev.off()
  
}

graficas_wordcloud_clean <- function(corp_tmln){
  
  tokens_tmln <- tokens(corp_tmln,
                        remove_punct = TRUE,
                        remove_symbols = TRUE,
                        remove_numbers = TRUE,
                        remove_url = TRUE
  )
  
  tokens_tmln <- tokens_select(tokens_tmln, stopwords('es'),selection='remove')
  
  tokens_tmln <- tokens_select(tokens_tmln, stopwords('en'),selection='remove')
  
  tokens_tmln <- tokens_select(tokens_tmln, valuetype = "glob", pattern = ".U000.*", selection = 'remove')
  
  
  # Construir una document  feature matrix a partir del objeto de tokens
  tweet_dfm <- dfm(tokens_tmln)
  
  
  # eliminar hasstags y usuarios hastags para grafica
  words_dfm <- dfm_select(tweet_dfm, pattern = ("#*"), selection = 'remove')
  
  words_dfm <- dfm_select(words_dfm, pattern = ("@*"), selection = 'remove')
  
  #head(words_dfm)
  #words_dfm <- dfm_select(word_fcm,pattern = ("\\U.*"),selection = 'remove')
  
  # Guardar graficos
  #png(paste0( "./03Graficos/clean_word_plot_",user,"_top_100.png"), width = 480, height = 480)
  
   # Grafica sin hastags ni usuarios 
   textplot_wordcloud(words_dfm,
                        min_size = .1,
                        max_size = 5,
                        random_order = FALSE,
                        #color = alpha("#055C9E",seq(.05,1,.20)),
                        color = RColorBrewer::brewer.pal(6, "Blues"),
                        max_words = 100) %>% 
    ggsave(filename = paste0( "./03Graficos/clean_word_plot_",user,"_top_100.png"),
           device = "png",
           dpi = 72)
  
  
  
  
  # Grafica incluyendo hastags y usuarios
  #png(paste0( "./03Graficos/all_word_plot_",user,"_top_100.png"), width = 480, height = 480)
  
   textplot_wordcloud(tweet_dfm,
                     min_size = .8,
                     max_size = 2.5,
                     random_order = FALSE,
                     #color = alpha("#356E40",seq(0.2,1,.23)),
                     color = RColorBrewer::brewer.pal(6, "Reds"),
                     max_words = 100) %>% 
    ggsave(filename = paste0( "./03Graficos/all_word_plot_",user,"_top_100.png"),
           device = "png",
           dpi = 72)
  
}

graficas_wordcloud_all <- function(corp_tmln){
  
  tokens_tmln <- tokens(corp_tmln,
                        remove_punct = TRUE,
                        remove_symbols = TRUE,
                        remove_numbers = TRUE,
                        remove_url = TRUE
  )
  
  tokens_tmln <- tokens_select(tokens_tmln, stopwords('es'),selection='remove')
  
  tokens_tmln <- tokens_select(tokens_tmln, stopwords('en'),selection='remove')
  
  #tokens_tmln <- tokens_select(tokens_tmln, valuetype = "glob", pattern = ".U000.*", selection = 'remove')
  
  
  # Construir una document  feature matrix a partir del objeto de tokens
  tweet_dfm <- dfm(tokens_tmln)
  
  textplot_wordcloud(tweet_dfm,
                     min_size = .8,
                     max_size = 2.5,
                     random_order = FALSE,
                     #color = alpha("#356E40",seq(0.2,1,.23)),
                     color = RColorBrewer::brewer.pal(6, "Reds"),
                     max_words = 100) %>% 
    ggsave(filename = paste0( "./03Graficos/all_word_plot_",user,"_top_100.png"),
           device = "png",
           dpi = 72)
  
}



# Define user
user <- "claudiodanielpc"


# Obtener info de Twitter
tmln_user1 <- obtener_info(user,3000)

#grafica de contenido
grafica_contenido(tmln_user1)

# Primero crear un corpus a partir del df
corp_tmln_user1 <-tmln_user1 %>% 
  filter(contenido_propio != "Retweet")%>% 
  select(text) %>% 
  corpus()  # build a new corpus from the texts


# Generar grafica de hashtags
grafica_hashtags ( corp_tmln_user1)

# Generar grafica de usuarios
grafica_usuarios(corp_tmln_user1)

# Generar  wordcloud sin hashtags ni usuarios
graficas_wordcloud_clean(corp_tmln_user1)

# Generar wordcloud con usuarios y hastags
graficas_wordcloud_all(corp_tmln_user1)

