#biblioteca para leer json
library(jsonlite)
#biblioteca para las fechas
library(lubridate)
#biblioteca para el %>%
library(dplyr)
library(tidyverse)
#biblioteca para los gráficos
library(ggplot2)
library(ggrepel)
library(ggthemes)

#Cargar la fuente desde mi Windows 
windowsFonts(`Gotham` = windowsFont("Gotham"))

#importar json como dataframe
df0 <- fromJSON("./Data/StreamingHistory0.json")
df1 <- fromJSON("./Data/StreamingHistory1.json")
df2 <- fromJSON("./Data/StreamingHistory2.json")

#Unir los dataframes
data <- rbind(df0,df1,df2)

# {
#   "endTime" : "2019-01-16 01:47",
#   "artistName" : "Nouvelle Vague",
#   "trackName" : "Dance With Me",
#   "msPlayed" : 4260
# },





summary(data)

#theme
#colors
# 1db954, 1ed760, ffffff, 191414

theme_spoty <- theme(
    #Esto pone negro el titulo , los ejes, etc
    plot.background = element_rect(fill = '#191414', colour = '#191414'), 
    #Esto pone negro el panel de la gráfica, es decir, sobre lo que van los bubbles
    panel.background = element_rect(fill="#191414",color="#191414"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    text = element_text(color = "#1db954",
                        family="Gotham"
    ),
    # limpiar la gráfica
    axis.line = element_line(colour="#191414"),
    axis.title=element_blank(),
    axis.text=element_blank(),
    axis.ticks=element_blank(),
    # ajustar titulos y notas
    plot.title = element_text(size=32,
                              color="#1db954"),
    plot.subtitle = element_text(size=20,
                              color="#1db954"),
    plot.caption = element_text(
      color="#1db954",
      face="italic",
      size=13
    ),
    complete=FALSE
  )
  

### ¿Qué artista escuché más por mes?

data$segPlayed = data$msPlayed/1000
data$minPlayed = round(data$msPlayed/1000/60,2)


#convertir endTime a fecha
data$endTime <- as.POSIXct(data$endTime)
#obtener columnas de fecha
data$mesAño <- paste(format(data$endTime,"%B"),format(data$endTime,"%y"))

#Cambiar los labels, de los levels, de mesAño
data$mesAño <- factor(data$mesAño,
                      levels = c("enero 19", "febrero 19","marzo 19","abril 19","mayo 19","junio 19",
                                 "julio 19","agosto 19","septiembre 19","octubre 19","noviembre 19",
                                 "diciembre 19","enero 20")
)

dfArtistaMes <- data %>% 
  group_by(mesAño,artistName)%>% 
  summarise(minutosMes= round((sum(minPlayed)))) %>% 
  top_n(1)  #me da el top1 de cada grupo creado arriba


plotArtistaMes <-ggplot(data=dfArtistaMes,
       aes( x=1, 
            y=reorder(mesAño, desc(mesAño))  #ordenar ascendente el mesAño 
       )
       )+
  geom_point( aes(                    #Capa 1
                  size=minutosMes, 
                  color=artistName),
              show.legend = FALSE,
              alpha = 1
              )  +
  geom_text(aes(x=1.06,label=mesAño), #Capa 2
            color="#FFFFFF",
            family="Gotham",
            size=6,
            hjust="left")+
  geom_text(aes(x=.94,                #Capa 3
                label=artistName,
                color=artistName),
            family="Gotham",
            size=6,
            show.legend = FALSE,
            hjust="right")+
  geom_text(aes(x=.94, label=paste(minutosMes,"m")),   #Capa 4
            hjust="right",
            size=6,
            color="#FFFFFF",
            family="Gotham",
            vjust=1.8)+
  geom_line(data=data.frame(x=c(1,1),y=c(1,13)),     #Capa 5
            aes(x=x, y=y),
            alpha=0.4,
            size=.85,
            color="#FFFFFF",
            linetype = "dotted")+
  scale_x_discrete(limits=c(1))+
  scale_radius(range = c(4, 26))+
  scale_color_brewer(palette="Dark2")+
  labs(title="Mi Spotify en el Último Año",
       subtitle="Minutos escuchados por artista",
       caption="Hecho por @nerudista con datos de Spotify") +
  theme(
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )+
  theme_spoty  ; plotArtistaMes
    

ggsave("./graficas/TopMensual.png", plotArtistaMes, width = 10, height = 14)


############### SIMPLE BUBBLES
#install.packages("packcircles")
library("packcircles")


dfCanciones <- data %>%
  group_by(artistName,trackName) %>%
  summarise(min=sum(minPlayed))%>%
  filter (min > 5)

packing <- circleProgressiveLayout(dfCanciones$min, sizetype='area')

# los npoints dicen las caras de la figura 3-triangulo, 4-cuadrado
dat.gg <- circleLayoutVertices(packing, npoints=50)

plotSingleBubble <- ggplot()+
  # Make the bubbles
  geom_polygon(data=dat.gg, aes(x,
                                y,
                                group=id,
                                colour = "black",
                                alpha = 0.6,
                                fill=as.factor(id)
                                )
               ) +
  scale_size_continuous(range = c(1,5)) +
  labs(title="Un Universo de Música",
       subtitle="Minutos de reproducción por canción ",
       caption="Hecho por @nerudista con datos de Spotify") +
  scale_color_brewer(palette="Dark2")+
  #theme_void()+
  theme_spoty+
  theme(legend.position="none") +
  coord_equal(); plotSingleBubble

ggsave("./graficas/SingleBubble.png", plotSingleBubble, width = 6, height = 9)




############### SIMPLE BUBBLES INTERACTIVE


# Add a column with the text you want to display for each bubble:
dfSimpleBubble$text <- paste("Canción: ",dfSimpleBubble$dfCanciones.trackName, "\n", "Min:", dfSimpleBubble$dfCanciones.min)

#install.packages("ggiraph")
library(ggiraph)

plotSingleBubbleInter <- ggplot()+
  geom_polygon_interactive(data=dat.gg,
                           aes(x,y,
                               group=id,
                               fill=as.factor(id),
                               tooltip= dfSimpleBubble$text[id],
                               family="Gotham",
                               data_id = id),
                           colour = "black", alpha = 0.6)+
  theme_spoty +
  scale_color_brewer(palette="Dark2")+
  theme(legend.position="none") +
  labs(title="Un Universo de Música",
       subtitle="Minutos de reproducción por canción ",
       caption="Hecho por @nerudista con datos de Spotify") +
  coord_equal()

widg <- ggiraph(ggobj = plotSingleBubbleInter, width_svg = 6, height_svg = 9)

#widg

# save the widget
#install.packages("htmlwidgets")
 library(htmlwidgets)

# Este falla si quieres guardar en otra locacion que no sea . 
# Es bug por las rutas relativas: 
#https://stackoverflow.com/questions/41399795/savewidget-from-htmlwidget-in-r-cannot-save-html-file-in-another-folder
# destination<- paste0( getwd(), "/graficas/HtmlWidget/circular_packing_interactive.html")
# saveWidget(widg, file=destination)
 
f<-"graficas\\circular_packing_interactive.html"
saveWidget(widg,file.path(normalizePath(dirname(f)),basename(f))) 

############################################################
########################## LOLLIPOP
############################################################

#Crear data frame con el tiempo total por cada canción junto con el artista.
#Necesito el artista para filtrar más adelante.
dfCanciones <- data %>%
  group_by(artistName,trackName) %>%
  summarise(min=sum(minPlayed))%>%
  filter (min > 5)


# Crear df el top n de artistas por minutos reproducidos en el año
dfArtistaAnio <- data%>%
  group_by(artistName)%>%
  summarise(min=sum(minPlayed)) %>%
  top_n(5)%>%   # de una vez me quedo con el top 5
  arrange(min)  # ordeno ya encarrerado el ratón

# crear un df con el group by solo por artistName 
artistas <- dfCanciones %>% group_by(artistName)

# filtrar el df artistas tomando el registro con más minutos. Va inverso porque no hay max_rank()
# sino min_rank(). Solo tomo un row: el más alto
dfTopCanciones <- filter(artistas, min_rank(desc(min)) <= 1 )

# hago un join entre el df dfArtistaAnio y dfTopCanciones por artistName
# así solo me quedan los top artistas con su canción más escuchada
dfCancionesArtistasTop <- merge(x=dfArtistaAnio, y=dfTopCanciones, by="artistName", all.x = TRUE)


dfTemp1 <- data.frame( item = dfCancionesArtistasTop$artistName,
                                          min = dfCancionesArtistasTop$min.x,
                                          type = "A")%>% arrange(-min)

# manualmente pongo el orden en que quiero que aparezcan los artistas
dfTemp1$order <- c(1,3,5,7,9)


dfTemp2 <- data.frame( item = dfCancionesArtistasTop$trackName,
                       min = dfCancionesArtistasTop$min.y,
                       type = "C")

# manualmente pongo el orden en que quiero que aparezcan las canciones
dfTemp2$order <- c(2,6,8,4,10)

dfCancionesArtistasTopList=rbind(dfTemp1,dfTemp2)




#ahora a pintar la gráfica
plotTop5 <- ggplot(data=dfCancionesArtistasTopList,
       aes(x=item,
           y=min
       ))+
  geom_segment(data=dfCancionesArtistasTopList ,
               aes(x=reorder(item,-order),
                   xend=item,
                   y=0,
                   yend=min
                   ),
               color=ifelse(dfCancionesArtistasTopList$type=="A","#67A61F","#E72A8A"),
               size=2
               )+
  geom_point(
             color=ifelse(dfCancionesArtistasTopList$type=="A","#67A61F","#E72A8A"),
             size=7
  )+
  geom_text(aes(label=paste(round(min,0)," min")),
            color=ifelse(dfCancionesArtistasTopList$type=="A","#67A61F","#E72A8A"),
            size=4,
            #color="#FFFFFF",
            family="Gotham",
            nudge_x = -.3)+
  coord_flip()+
  scale_color_brewer(palette="Dark2")+
  ylab("")+
  xlab("")+
  theme(legend.position="none") +
  labs(title="Top 5 de Artistas",
       subtitle="Con su canción más escuchada",
       caption="Hecho por @nerudista con datos de Spotify") +
  theme(
    text = element_text(color = "#1db954",
                        family="Gotham"
    ),
    #Esto pone negro el titulo , los ejes, etc
    plot.background = element_rect(fill = '#191414', colour = '#191414'), 
    #Esto pone negro el panel de la gráfica, es decir, sobre lo que van los lollipops
    panel.background = element_rect(fill="#191414",color="#191414"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size=32,
                              color="#1db954"),
    plot.subtitle = element_text(size=20,
                                 color="#E72A8A"),
    plot.caption = element_text(
      color="#1db954",
      face="italic",
      size=13
    ),
    axis.text=element_text(family = "Gotham",
                           size=13,
                           color="#FFFFFF"),
    axis.ticks=element_blank(),
    axis.text.x = element_blank(),
  );plotTop5


ggsave("./graficas/plotTop5.png", plotTop5, width = 10, height = 7)


################# canciones consucutivas

# con la función RLE puedo detectar los registros consecutivos
# aquí lo explican chido
# https://www.r-bloggers.com/r-function-of-the-day-rle-2/
  
dfConsecutivos <- data.frame( repeticiones = rle(data$trackName)$lengths,
                              cancion = rle(data$trackName)$values
                            ) %>% arrange(desc(repeticiones))%>%
                            top_n(10,repeticiones)

dfTest <- data.frame ( x = c("A","A","A","B","B"),
                       y = c(1,2,3,1,2))

ggplot(data=dfTest, aes(x=x, y=y))+
  geom_point(aes(size=y*1000))+
  coord_flip()


