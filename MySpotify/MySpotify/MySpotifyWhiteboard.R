#biblioteca para leer json
library(jsonlite)
#biblioteca para las fechas
library(lubridate)
#biblioteca para el %>%
library(dplyr)
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

dfArtistaMes <- data %>% 
  group_by(mesAño,artistName)%>% 
  summarise(minutosMes= round((sum(minPlayed)))) %>% 
  top_n(1)  #me da el top1 de cada grupo creado arriba


plotArtistaMes <-ggplot(data=dfArtistaMes,
       aes( x=1, 
            y=reorder(mesAño, desc(mesAño))  #ordenar ascendente el mesAño 
       )
       )+
  geom_point( aes( 
                  size=minutosMes, 
                  color=artistName),
              show.legend = FALSE,
              alpha = 1
              )  +
  geom_text(aes(x=1.06,label=mesAño),
            color="#FFFFFF",
            family="Gotham",
            size=6,
            hjust="left")+
  geom_text(aes(x=.94,
                label=artistName,
                color=artistName),
            family="Gotham",
            size=6,
            show.legend = FALSE,
            hjust="right")+
  geom_text(aes(x=.94, label=paste(minutosMes,"m")),
            hjust="right",
            size=6,
            color="#FFFFFF",
            family="Gotham",
            vjust=1.8)+
  geom_line(data=data.frame(x=c(1,1),y=c(1,13)),
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

