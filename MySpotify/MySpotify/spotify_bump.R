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
library(showtext)
library(ggbump)

sysfonts::font_add_google("Raleway","Raleway")


# crear tema
theme_spoty <- theme(
  #Esto pone negro el titulo , los ejes, etc
  plot.background = element_rect(fill = '#191414', colour = '#191414'), 
  #Esto pone negro el panel de la gráfica, es decir, sobre lo que van los bubbles
  panel.background = element_rect(fill="#191414",color="#191414"),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  text = element_text(color = "#1db954",
                      family="Raleway"
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



#importar json como dataframe
df0 <- fromJSON("./Data/StreamingHistory0.json")
df1 <- fromJSON("./Data/StreamingHistory1.json")
df2 <- fromJSON("./Data/StreamingHistory2.json")

#Unir los dataframes
data <- rbind(df0,df1,df2)

Sys.setlocale("LC_TIME", "es_ES.UTF-8")

data$minPlayed = round(data$msPlayed/1000/60,2)

data$endTime <- strptime(data$endTime, "%Y-%m-%d %H:%M")

#obtener columnas de fecha
# ggbump solo acepta POSIXct no as.POSIXlt para contruir la grafica 

data$mesAño <- as.POSIXct(lubridate::floor_date(data$endTime,"month"))

#misArtistas=c("Arcade Fire","Gallina Pintadita","Kanye West","Héctor Lavoe",
#              "Johnny Cash","")

dfArtistaMes <- data %>% 
  group_by(mesAño,artistName)%>% 
  summarise(minutosMes= round((sum(minPlayed)))) %>% 
  top_n(5,minutosMes) %>%  #me da el top1 de cada grupo creado arriba
  arrange(-minutosMes) %>% 
  mutate(rank = row_number())  
 # filter(artistName %in% misArtistas)

# Crear ggbump

  dfArtistaMes %>% 
    ggplot(aes(x=mesAño,
           y=rank,
           color=artistName,
           group=artistName))+
             geom_bump( # hace la grafica
               smooth = 7, 
               size = 2.2
             )+
    scale_y_reverse(
      expand = c(.03, .03),
      breaks = 1:13 # obliga a que se pinten 16 numero al inicio, sin esto, solo se pintan algunos
    )
  
  # probar approach
  # https://github.com/davidsjoberg/ggbump/wiki/My-year-on-Spotify
  p <- dfArtistaMes %>% 
    ggplot(aes(mesAño,rank, color=artistName, group=artistName))+
    geom_bump(smooth = 15, size=2, alpha=0.2)+
    scale_y_reverse(); p

  p <- p +
    geom_bump(data = dfArtistaMes %>% filter(rank <= 1  ),
              aes(mesAño,rank, color=artistName, group= artistName),
              smooth = 15, size = 2, inherit.aes = F
              ); p
  